package com.mvc.app.aop.aspect;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mvc.app.aop.common.ActionType;
import com.mvc.app.aop.dto.ActivityLogDto;
import com.mvc.app.aop.mapper.ActivityLogMapper;
import com.mvc.app.domain.dto.HrmDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.mapper.HrmMapper;          // ← 추가: before 데이터 조회용
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
 * 직원관리 활동 로그 AOP
 *
 *   HrmServiceImpl
 *     insertEmployee   — before: null         / after: 등록 DTO
 *     updateEmployee   — before: DB 현재 데이터 / after: 수정 요청 DTO
 *     updateEmployees  — before: DB 현재 데이터 / after: 수정 요청 리스트
 *     deleteEmployees  — before: DB 현재 데이터 / after: null
 *     importExcel      — before: null         / after: 처리 건수
 */
@Aspect
@Component
@RequiredArgsConstructor
@Slf4j
public class HrmActivityAspect {

    private final ActivityLogMapper activityLogMapper;
    private final HrmMapper         hrmMapper;          // before 데이터 조회용
    private final ObjectMapper      objectMapper;

    // ── Pointcut ──────────────────────────────────────────────────────────────
    private static final String POINTCUT_INSERT =
            "execution(* com.mvc.app.service.HrmServiceImpl.insertEmployee(..))";
    private static final String POINTCUT_UPDATE =
            "execution(* com.mvc.app.service.HrmServiceImpl.updateEmployee(..))";
    private static final String POINTCUT_BULK   =
            "execution(* com.mvc.app.service.HrmServiceImpl.updateEmployees(..))";
    private static final String POINTCUT_DELETE =
            "execution(* com.mvc.app.service.HrmServiceImpl.deleteEmployees(..))";
    private static final String POINTCUT_EXCEL  =
            "execution(* com.mvc.app.service.HrmServiceImpl.importExcel(..))";

    // ── 직원 단건 등록 ─────────────────────────────────────────────────────────
    // 등록은 변경 전 데이터가 없으므로 beforeObj = null
    @Around(POINTCUT_INSERT)
    public Object logInsert(ProceedingJoinPoint pjp) throws Throwable {
        HrmDto dto = (HrmDto) pjp.getArgs()[0];
        return executeWithLog(pjp, ActionType.INSERT, dto.getEmpId(), null, dto);
    }

    // ── 직원 단건 수정 ─────────────────────────────────────────────────────────
    // [수정] pjp.proceed() 전에 DB에서 현재 데이터를 조회해 beforeObj로 전달
    @Around(POINTCUT_UPDATE)
    public Object logUpdate(ProceedingJoinPoint pjp) throws Throwable {
        HrmDto dto = (HrmDto) pjp.getArgs()[0];

        // ★ 수정 전 원본 데이터를 미리 조회 (proceed() 이전)
        HrmDto beforeDto = null;
        try {
            beforeDto = hrmMapper.selectEmployee(dto.getEmpId());
        } catch (Exception e) {
            log.warn("[HrmActivityAspect] before 데이터 조회 실패 empId={} error={}",
                    dto.getEmpId(), e.getMessage());
        }

        return executeWithLog(pjp, ActionType.UPDATE, dto.getEmpId(), beforeDto, dto);
    }

    // ── 직원 벌크 수정 ─────────────────────────────────────────────────────────
    // [수정] pjp.proceed() 전에 대상 직원 전체를 미리 조회해 beforeObj로 전달
    @Around(POINTCUT_BULK)
    public Object logBulkUpdate(ProceedingJoinPoint pjp) throws Throwable {
        @SuppressWarnings("unchecked")
        List<HrmDto> dtoList = (List<HrmDto>) pjp.getArgs()[0];

        String targetIds = dtoList.stream()
                .map(HrmDto::getEmpId)
                .collect(Collectors.joining(","));

        // ★ 수정 전 원본 데이터를 미리 조회 (proceed() 이전)
        List<HrmDto> beforeList = null;
        try {
            List<String> ids = dtoList.stream()
                    .map(HrmDto::getEmpId)
                    .collect(Collectors.toList());
            beforeList = hrmMapper.selectEmployeesByIds(ids);
        } catch (Exception e) {
            log.warn("[HrmActivityAspect] before 데이터 조회 실패 ids={} error={}",
                    targetIds, e.getMessage());
        }

        return executeWithLog(pjp, ActionType.BULK_UPDATE, targetIds, beforeList, dtoList);
    }

    // ── 직원 선택 삭제 ─────────────────────────────────────────────────────────
    // [수정] 삭제 전 대상 직원 데이터를 미리 조회해 beforeObj로 전달
    @Around(POINTCUT_DELETE)
    public Object logDelete(ProceedingJoinPoint pjp) throws Throwable {
        @SuppressWarnings("unchecked")
        List<String> ids = (List<String>) pjp.getArgs()[0];
        String targetIds = String.join(",", ids);

        // ★ 삭제 전 원본 데이터를 미리 조회 (proceed() 이전)
        List<HrmDto> beforeList = null;
        try {
            beforeList = hrmMapper.selectEmployeesByIds(ids);
        } catch (Exception e) {
            log.warn("[HrmActivityAspect] before 데이터 조회 실패 ids={} error={}",
                    targetIds, e.getMessage());
        }

        // 삭제는 after 데이터 없음
        return executeWithLog(pjp, ActionType.DELETE, targetIds, beforeList, null);
    }

    // ── 엑셀 업로드 일괄 등록 ──────────────────────────────────────────────────
    @Around(POINTCUT_EXCEL)
    public Object logExcelImport(ProceedingJoinPoint pjp) throws Throwable {
        return executeWithLog(pjp, ActionType.EXCEL_IMPORT, null, null, null);
    }

    // ── 공통 로그 저장 ─────────────────────────────────────────────────────────
    private Object executeWithLog(ProceedingJoinPoint pjp,
                                  String actionType,
                                  String targetEmpIds,
                                  Object beforeObj,   // ← proceed() 전에 미리 채워진 값
                                  Object afterObj) throws Throwable {

        SessionInfo actor = getSessionInfo();

        Object result     = null;
        String resultCode = "SUCCESS";
        String errorMsg   = null;
        String afterJson  = null;

        try {
            result = pjp.proceed();

            if (afterObj != null) {
                afterJson = toJson(afterObj);
            }
            // 엑셀 임포트: 처리 건수를 after 데이터로 기록
            if (ActionType.EXCEL_IMPORT.equals(actionType) && result instanceof Integer cnt) {
                afterJson = "{\"importedCount\":" + cnt + "}";
            }

        } catch (Throwable ex) {
            resultCode = "FAIL";
            errorMsg   = truncate(ex.getMessage(), 2000);
            throw ex;

        } finally {
            try {
                ActivityLogDto logDto = ActivityLogDto.builder()
                        .actorEmpId  (actor != null ? actor.getEmpId() : "UNKNOWN")
                        .actorName   (actor != null ? actor.getName()  : "UNKNOWN")
                        .actionType  (actionType)
                        .targetMenu  ("HRM")
                        .targetEmpIds(targetEmpIds)
                        .beforeData  (beforeObj != null ? toJson(beforeObj) : null)  // ★ 정상 저장
                        .afterData   (afterJson)
                        .result      (resultCode)
                        .errorMsg    (errorMsg)
                        .ipAddr      (getClientIp())
                        .build();

                activityLogMapper.insertActivityLog(logDto);

            } catch (Exception logEx) {
                log.warn("[HrmActivityAspect] 활동 로그 저장 실패 action={} error={}",
                        actionType, logEx.getMessage());
            }
        }

        return result;
    }

    // ── 세션 조회 ──────────────────────────────────────────────────────────────
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

    // ── 클라이언트 IP 조회 ─────────────────────────────────────────────────────
    private String getClientIp() {
        try {
            ServletRequestAttributes attrs =
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs == null) return null;

            HttpServletRequest req = attrs.getRequest();
            String[] headers = {
                "X-Forwarded-For", "Proxy-Client-IP",
                "WL-Proxy-Client-IP", "HTTP_CLIENT_IP", "HTTP_X_FORWARDED_FOR"
            };
            for (String header : headers) {
                String ip = req.getHeader(header);
                if (ip != null && !ip.isBlank() && !"unknown".equalsIgnoreCase(ip)) {
                    return ip.split(",")[0].trim();
                }
            }
            return req.getRemoteAddr();

        } catch (Exception e) {
            return null;
        }
    }

    // ── 객체 → JSON ────────────────────────────────────────────────────────────
    private String toJson(Object obj) {
        try {
            String json = objectMapper.writeValueAsString(obj);
            return json.replaceAll("(?i)(\"password\"\\s*:\\s*\")([^\"]+)(\")", "$1********$3");
        } catch (Exception e) {
            return "{\"error\":\"직렬화 실패\"}";
        }
    }

    // ── 문자열 길이 제한 ───────────────────────────────────────────────────────
    private String truncate(String s, int maxLen) {
        if (s == null) return null;
        return s.length() <= maxLen ? s : s.substring(0, maxLen);
    }
}