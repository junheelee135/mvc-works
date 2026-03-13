package com.mvc.app.aop.aspect;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mvc.app.aop.common.ActionType;
import com.mvc.app.aop.dto.ActivityLogDto;
import com.mvc.app.aop.mapper.ActivityLogMapper;
import com.mvc.app.domain.dto.HrmDto;
import com.mvc.app.domain.dto.SessionInfo;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.List;
import java.util.stream.Collectors;

/**
 * HRM 직원관리 활동 로그 AOP Aspect
 *
 *  적용 대상 (HrmServiceImpl 메서드):
 *    - insertEmployee   : 직원 단건 등록
 *    - updateEmployee   : 직원 단건 수정
 *    - updateEmployees  : 직원 벌크 수정
 *    - deleteEmployees  : 직원 선택 삭제
 *    - importExcel      : 엑셀 업로드 일괄 등록
 *
 *  동작 방식: @Around
 *    → 메서드 실행 전 before_data 스냅샷 (수정/삭제 시)
 *    → 메서드 정상 완료: result = SUCCESS, after_data 기록
 *    → 메서드 예외 발생: result = FAIL, error_msg 기록
 *    → 로그 저장 실패 시 원래 비즈니스 로직 결과에 영향 없음 (try-catch 독립)
 */
@Aspect
@Component
@RequiredArgsConstructor
@Slf4j
public class HrmActivityAspect {

    private final ActivityLogMapper activityLogMapper;
    private final ObjectMapper      objectMapper;       // Spring Boot 자동 등록 Bean

    // ── Pointcut 표현식 상수 ─────────────────────────────────
    private static final String POINTCUT_INSERT  =
            "execution(* com.mvc.app.service.HrmServiceImpl.insertEmployee(..))";
    private static final String POINTCUT_UPDATE  =
            "execution(* com.mvc.app.service.HrmServiceImpl.updateEmployee(..))";
    private static final String POINTCUT_BULK    =
            "execution(* com.mvc.app.service.HrmServiceImpl.updateEmployees(..))";
    private static final String POINTCUT_DELETE  =
            "execution(* com.mvc.app.service.HrmServiceImpl.deleteEmployees(..))";
    private static final String POINTCUT_EXCEL   =
            "execution(* com.mvc.app.service.HrmServiceImpl.importExcel(..))";

    // ════════════════════════════════════════════════════════
    // [1] 직원 단건 등록 — insertEmployee(HrmDto)
    // ════════════════════════════════════════════════════════
    @Around(POINTCUT_INSERT)
    public Object logInsert(ProceedingJoinPoint pjp) throws Throwable {
        HrmDto dto = (HrmDto) pjp.getArgs()[0];
        return executeWithLog(pjp, ActionType.INSERT, dto.getEmpId(), null, dto);
    }

    // ════════════════════════════════════════════════════════
    // [2] 직원 단건 수정 — updateEmployee(HrmDto)
    // ════════════════════════════════════════════════════════
    @Around(POINTCUT_UPDATE)
    public Object logUpdate(ProceedingJoinPoint pjp) throws Throwable {
        HrmDto dto = (HrmDto) pjp.getArgs()[0];
        return executeWithLog(pjp, ActionType.UPDATE, dto.getEmpId(), null, dto);
    }

    // ════════════════════════════════════════════════════════
    // [3] 직원 벌크 수정 — updateEmployees(List<HrmDto>)
    // ════════════════════════════════════════════════════════
    @Around(POINTCUT_BULK)
    public Object logBulkUpdate(ProceedingJoinPoint pjp) throws Throwable {
        @SuppressWarnings("unchecked")
        List<HrmDto> dtoList = (List<HrmDto>) pjp.getArgs()[0];

        // 대상 사원번호 콤마 구분 문자열
        String targetIds = dtoList.stream()
                .map(HrmDto::getEmpId)
                .collect(Collectors.joining(","));

        return executeWithLog(pjp, ActionType.BULK_UPDATE, targetIds, null, dtoList);
    }

    // ════════════════════════════════════════════════════════
    // [4] 직원 선택 삭제 — deleteEmployees(List<String>)
    // ════════════════════════════════════════════════════════
    @Around(POINTCUT_DELETE)
    public Object logDelete(ProceedingJoinPoint pjp) throws Throwable {
        @SuppressWarnings("unchecked")
        List<String> ids = (List<String>) pjp.getArgs()[0];
        String targetIds = String.join(",", ids);

        return executeWithLog(pjp, ActionType.DELETE, targetIds, null, null);
    }

    // ════════════════════════════════════════════════════════
    // [5] 엑셀 업로드 일괄 등록 — importExcel(MultipartFile)
    //     반환값: int (등록 건수)
    // ════════════════════════════════════════════════════════
    @Around(POINTCUT_EXCEL)
    public Object logExcelImport(ProceedingJoinPoint pjp) throws Throwable {
        return executeWithLog(pjp, ActionType.EXCEL_IMPORT, null, null, null);
    }

    // ════════════════════════════════════════════════════════
    //  공통 실행 + 로그 저장 메서드
    //  - 비즈니스 로직 성공/실패와 독립적으로 로그 저장
    //  - 로그 저장 자체 실패 시 비즈니스 결과에 영향 없음
    // ════════════════════════════════════════════════════════
    private Object executeWithLog(ProceedingJoinPoint pjp,
                                  String actionType,
                                  String targetEmpIds,
                                  Object beforeObj,
                                  Object afterObj) throws Throwable {

        // 수행자 정보 (세션)
        SessionInfo actor = getSessionInfo();

        Object result     = null;
        String resultCode = "SUCCESS";
        String errorMsg   = null;
        String afterJson  = null;

        try {
            // ── 비즈니스 메서드 실행 ──────────────────────
            result = pjp.proceed();

            // 성공 시 after_data: 등록·수정은 DTO JSON, 삭제는 null
            if (afterObj != null) {
                afterJson = toJson(afterObj);
            }
            // EXCEL_IMPORT 성공 시 등록 건수를 after_data 에 기록
            if (ActionType.EXCEL_IMPORT.equals(actionType) && result instanceof Integer cnt) {
                afterJson = "{\"importedCount\":" + cnt + "}";
            }

        } catch (Throwable ex) {
            resultCode = "FAIL";
            errorMsg   = truncate(ex.getMessage(), 2000);
            throw ex;     // 비즈니스 예외는 그대로 재던짐

        } finally {
            // ── 로그 저장 (독립 try — 로그 실패가 비즈니스에 영향 없도록) ──
            try {
                ActivityLogDto logDto = ActivityLogDto.builder()
                        .actorEmpId (actor != null ? actor.getEmpId()  : "UNKNOWN")
                        .actorName  (actor != null ? actor.getName()   : "UNKNOWN")
                        .actionType (actionType)
                        .targetMenu ("HRM")
                        .targetEmpIds(targetEmpIds)
                        .beforeData (beforeObj != null ? toJson(beforeObj) : null)
                        .afterData  (afterJson)
                        .result     (resultCode)
                        .errorMsg   (errorMsg)
                        .ipAddr     (getClientIp())
                        .build();

                activityLogMapper.insertActivityLog(logDto);

            } catch (Exception logEx) {
                // 로그 저장 실패는 경고만 남기고 무시
                log.warn("[HrmActivityAspect] 활동 로그 저장 실패 action={} error={}",
                        actionType, logEx.getMessage());
            }
        }

        return result;
    }

    // ── 세션에서 현재 로그인 사원 정보 조회 ────────────────
    private SessionInfo getSessionInfo() {
        try {
            ServletRequestAttributes attrs =
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs == null) return null;

            HttpSession session = attrs.getRequest().getSession(false);
            if (session == null) return null;

            return (SessionInfo) session.getAttribute("member");
        } catch (Exception e) {
            log.warn("[HrmActivityAspect] 세션 조회 실패: {}", e.getMessage());
            return null;
        }
    }

    // ── 클라이언트 IP 조회 (Proxy/LB 헤더 우선) ────────────
    private String getClientIp() {
        try {
            ServletRequestAttributes attrs =
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs == null) return null;

            HttpServletRequest req = attrs.getRequest();

            // X-Forwarded-For → Proxy-Client-IP → WL-Proxy-Client-IP → RemoteAddr 순
            String[] headers = {
                "X-Forwarded-For", "Proxy-Client-IP",
                "WL-Proxy-Client-IP", "HTTP_CLIENT_IP", "HTTP_X_FORWARDED_FOR"
            };
            for (String header : headers) {
                String ip = req.getHeader(header);
                if (ip != null && !ip.isBlank() && !"unknown".equalsIgnoreCase(ip)) {
                    // X-Forwarded-For 는 "클라이언트, 프록시1, 프록시2" 형태일 수 있음
                    return ip.split(",")[0].trim();
                }
            }
            return req.getRemoteAddr();

        } catch (Exception e) {
            return null;
        }
    }

    // ── 객체 → JSON 변환 (비밀번호 필드 마스킹 포함) ────────
    private String toJson(Object obj) {
        try {
            String json = objectMapper.writeValueAsString(obj);
            // 비밀번호가 JSON 에 포함되면 마스킹 처리
            return json.replaceAll("(?i)(\"password\"\\s*:\\s*\")([^\"]+)(\")", "$1********$3");
        } catch (Exception e) {
            return "{\"error\":\"직렬화 실패\"}";
        }
    }

    // ── 문자열 길이 제한 ────────────────────────────────────
    private String truncate(String s, int maxLen) {
        if (s == null) return null;
        return s.length() <= maxLen ? s : s.substring(0, maxLen);
    }
}
