package com.mvc.app.controller;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.HrmDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.service.HrmService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * HrmController — 직원 통합관리
 *
 *  GET    /api/hrm                  직원 목록 조회 (검색 + 페이징)
 *  POST   /api/hrm                  직원 단건 등록
 *  PUT    /api/hrm/bulk             직원 벌크 수정
 *  DELETE /api/hrm                  직원 선택 삭제 (관리자 권한)
 *  GET    /api/hrm/excel/download   엑셀 다운로드
 *  POST   /api/hrm/excel/upload     엑셀 업로드 (관리자 권한)
 */
@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/hrm")
public class HrmController {

    private final HrmService hrmService;

    // ──────────────────────────────────────────────
    // [1] 직원 목록 조회 (GET /api/hrm)
    // ──────────────────────────────────────────────
    @GetMapping
    public ResponseEntity<?> getEmployeeList(
            @RequestParam(name = "page",           defaultValue = "1")     int currentPage,
            @RequestParam(name = "pageSize",       defaultValue = "10")    int size,
            @RequestParam(name = "name",           defaultValue = "")      String name,
            @RequestParam(name = "empNo",          defaultValue = "")      String empNo,
            @RequestParam(name = "project",        defaultValue = "")      String project,
            @RequestParam(name = "empStatusCode",  defaultValue = "")      String empStatusCode,
            @RequestParam(name = "levelCode",      defaultValue = "")      String levelCode,
            @RequestParam(name = "pmoY",           defaultValue = "false") boolean pmoY,
            @RequestParam(name = "pmoN",           defaultValue = "false") boolean pmoN,
            @RequestParam(name = "sortCol",        defaultValue = "")      String sortCol,
            @RequestParam(name = "sortDir",        defaultValue = "asc")   String sortDir,
            @RequestParam(name = "authorityCode",  defaultValue = "")	   String authorityCode,
            @RequestParam(name = "deptCode",       defaultValue = "")      String deptCode,
            @RequestParam(name = "gradeCode",      defaultValue = "")      String gradeCode) {

        try {
            Map<String, Object> params = buildSearchParams(
                name, empNo, project, empStatusCode, levelCode, pmoY, pmoN, sortCol, sortDir, authorityCode, deptCode, gradeCode
            );

            int totalCount = hrmService.dataCount(params);
            int totalPage  = (totalCount == 0) ? 0
                    : totalCount / size + (totalCount % size > 0 ? 1 : 0);

            currentPage = Math.min(currentPage, Math.max(totalPage, 1));
            int offset  = Math.max((currentPage - 1) * size, 0);
            params.put("offset", offset);
            params.put("size",   size);

            List<HrmDto> list = hrmService.listEmployee(params);

            return ResponseEntity.ok(Map.of(
                "list",       list,
                "page",       currentPage,
                "totalPage",  totalPage,
                "totalCount", totalCount
            ));
        } catch (Exception e) {
            log.error("직원 목록 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [2] 직원 단건 등록 (POST /api/hrm)
    // ──────────────────────────────────────────────
    @PostMapping
    public ResponseEntity<?> createEmployee(
            @RequestBody HrmDto dto,
            @SessionAttribute("member") SessionInfo info) {

        try {
            if (dto.getEmpId() == null || dto.getEmpId().isBlank()) {
                return ResponseEntity.badRequest().body("사원번호는 필수입니다.");
            }
            if (dto.getName() == null || dto.getName().isBlank()) {
                return ResponseEntity.badRequest().body("이름은 필수입니다.");
            }
            if (dto.getPassword() == null || dto.getPassword().isBlank()) {
                return ResponseEntity.badRequest().body("비밀번호는 필수입니다.");
            }

            dto.setRegEmpId(info.getEmpId());

            hrmService.insertEmployee(dto);
            return ResponseEntity.ok().build();

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
        } catch (Exception e) {
            log.error("직원 등록 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [3] 직원 벌크 수정 (PUT /api/hrm/bulk)
    // ──────────────────────────────────────────────
    @PutMapping("/bulk")
    public ResponseEntity<?> updateEmployeesBulk(
            @RequestBody List<HrmDto> dtoList,
            @SessionAttribute("member") SessionInfo info) {

        try {
            hrmService.updateEmployees(dtoList);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("직원 벌크 수정 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [4] 직원 선택 삭제 (DELETE /api/hrm)
    //   - userLevel >= 51 만 삭제 가능
    // ──────────────────────────────────────────────
    @DeleteMapping
    public ResponseEntity<?> deleteEmployees(
            @RequestBody Map<String, List<String>> body,
            @SessionAttribute("member") SessionInfo info) {

        try {
            List<String> ids = body.get("ids");
            if (ids == null || ids.isEmpty()) {
                return ResponseEntity.badRequest().body("삭제할 항목이 없습니다.");
            }
            if (info.getUserLevel() < 51) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("삭제 권한이 없습니다.");
            }
            hrmService.deleteEmployees(ids);
            return ResponseEntity.ok().build();

        } catch (Exception e) {
            log.error("직원 삭제 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [5] 엑셀 다운로드 (GET /api/hrm/excel/download)
    // ──────────────────────────────────────────────
    @GetMapping("/excel/download")
    public ResponseEntity<?> downloadExcel(
            @RequestParam(name = "name",          defaultValue = "") String name,
            @RequestParam(name = "empNo",         defaultValue = "") String empNo,
            @RequestParam(name = "project",       defaultValue = "") String project,
            @RequestParam(name = "empStatusCode", defaultValue = "") String empStatusCode,
            @RequestParam(name = "levelCode",     defaultValue = "") String levelCode,
            @RequestParam(name = "pmoY",          defaultValue = "false") boolean pmoY,
            @RequestParam(name = "pmoN",          defaultValue = "false") boolean pmoN,
            @RequestParam(name = "authorityCode", defaultValue = "") String authorityCode,
            @RequestParam(name = "deptCode",      defaultValue = "") String deptCode,
            @RequestParam(name = "gradeCode",     defaultValue = "") String gradeCode) {

        try {
            Map<String, Object> params = buildSearchParams(
                name, empNo, project, empStatusCode, levelCode, pmoY, pmoN, "", "asc", authorityCode, deptCode, gradeCode
            );

            Resource resource = hrmService.exportExcel(params);
            String filename = URLEncoder.encode("직원목록.xlsx", StandardCharsets.UTF_8)
                              .replace("+", "%20");

            return ResponseEntity.ok()
                    .header("Content-Disposition", "attachment; filename*=UTF-8''" + filename)
                    .header("Content-Type",
                            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                    .body(resource);

        } catch (Exception e) {
            log.error("엑셀 다운로드 오류", e);
            return ResponseEntity.status(HttpStatus.FOUND)
                    .location(URI.create("/error/downloadFailed")).build();
        }
    }

    // ──────────────────────────────────────────────
    // [6] 엑셀 업로드 (POST /api/hrm/excel/upload)
    //   - userLevel >= 51 만 업로드 가능
    // ──────────────────────────────────────────────
    @PostMapping("/excel/upload")
    public ResponseEntity<?> uploadExcel(
            @RequestParam("file") MultipartFile file,
            @SessionAttribute("member") SessionInfo info) {

        try {
            if (info.getUserLevel() < 51) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("업로드 권한이 없습니다.");
            }
            int insertedCount = hrmService.importExcel(file);
            return ResponseEntity.ok(Map.of(
                "message",       "업로드 완료",
                "insertedCount", insertedCount
            ));
        } catch (Exception e) {
            log.error("엑셀 업로드 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [7] 다음 사원번호 자동채번 (GET /api/hrm/next-emp-id)
    //   EMPLOYEE1 테이블의 MAX(empId) + 1 을 11자리 zero-padding 으로 반환
    //   ex) 현재 최댓값 "00000000005" → "00000000006"
    // ──────────────────────────────────────────────
    @GetMapping("/next-emp-id")
    public ResponseEntity<?> getNextEmpId() {
        try {
            String maxId = hrmService.getNextEmpId();
            return ResponseEntity.ok(Map.of("nextEmpId", maxId));
        } catch (Exception e) {
            log.error("다음 사원번호 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [8-1] 엑셀 업로드 양식 다운로드 (GET /api/hrm/excel/template)
    //   헤더 행(이름, 비밀번호, 부서코드, 직급코드, 권한코드, 권한레벨, 재직상태코드)만 있는 빈 양식 반환
    //   ※ 사원번호·참여 프로젝트는 자동처리이므로 양식에 포함하지 않음
    // ──────────────────────────────────────────────
    @GetMapping("/excel/template")
    public ResponseEntity<?> downloadExcelTemplate() {
        try {
            Resource resource = hrmService.exportExcelTemplate();
            String filename = URLEncoder.encode("직원업로드양식.xlsx", StandardCharsets.UTF_8)
                              .replace("+", "%20");
            return ResponseEntity.ok()
                    .header("Content-Disposition", "attachment; filename*=UTF-8''" + filename)
                    .header("Content-Type",
                            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                    .body(resource);
        } catch (Exception e) {
            log.error("엑셀 양식 다운로드 오류", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [8] 공통코드 일괄 조회 (GET /api/hrm/codes)
    //   화면 초기 로딩 시 부서·직급·재직상태 옵션 조회
    // ──────────────────────────────────────────────
    @GetMapping("/codes")
    public ResponseEntity<?> getCodes() {
        try {
            return ResponseEntity.ok(Map.of(
                "dept",      hrmService.getCommonCodes("DEPT"),
                "rank",      hrmService.getCommonCodes("RANK"),
                "empStatus", hrmService.getCommonCodes("EMPSTATUS"),
                "authority", hrmService.getCommonCodes("AUTHORITY")
            ));
        } catch (Exception e) {
            log.error("공통코드 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    // ──────────────────────────────────────────────
    // 내부 헬퍼 — 검색 파라미터 Map 구성
    // ──────────────────────────────────────────────
    private Map<String, Object> buildSearchParams(
            String name, String empNo, String project,
            String empStatusCode, String levelCode,
            boolean pmoY, boolean pmoN,
            String sortCol, String sortDir,
            String authorityCode,
            String deptCode, String gradeCode) {

        Map<String, Object> map = new HashMap<>();
        map.put("name",          name);
        map.put("empNo",         empNo);
        map.put("project",       project);
        map.put("empStatusCode", empStatusCode);
        map.put("pmoY",          pmoY);
        map.put("pmoN",          pmoN);
        map.put("authorityCode", (authorityCode != null && !authorityCode.isBlank()) ? authorityCode : null);
        map.put("deptCode",      (deptCode  != null && !deptCode.isBlank())  ? deptCode  : null);
        map.put("gradeCode",     (gradeCode != null && !gradeCode.isBlank()) ? gradeCode : null);
        if (levelCode != null && !levelCode.isBlank()) {
            try { map.put("levelCode", Integer.parseInt(levelCode)); }
            catch (NumberFormatException e) { map.put("levelCode", null); }
        } else {
            map.put("levelCode", null);
        }
        map.put("sortCol", sortCol);
        map.put("sortDir", "desc".equalsIgnoreCase(sortDir) ? "DESC" : "ASC");
        return map;
    }
}