package com.mvc.app.controller;

import com.mvc.app.domain.dto.EmpPerformanceDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.service.EmpPerformanceService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * EmpPerformanceController — 직원 성과 관리 REST API
 *
 *  GET /api/emp-performance                직원 목록 (검색 + 페이징)
 *  GET /api/emp-performance/my-projects    세션 기준 소속 프로젝트 목록
 *  GET /api/emp-performance/eval-years     평가 모달 연도 목록
 *  GET /api/emp-performance/eval-grid      평가 월×주차 그리드
 */
@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/emp-performance")
public class EmpPerformanceController {

    private final EmpPerformanceService empPerformanceService;

    // ──────────────────────────────────────────────────────────────
    // [1] 직원 목록 조회
    //     GET /api/emp-performance
    // ──────────────────────────────────────────────────────────────
    @GetMapping
    public ResponseEntity<?> getEmpPerformanceList(
            @RequestParam(name = "page",       defaultValue = "1")  int    currentPage,
            @RequestParam(name = "pageSize",   defaultValue = "10") int    size,
            @RequestParam(name = "empId",      defaultValue = "")   String empId,
            @RequestParam(name = "empName",    defaultValue = "")   String empName,
            @RequestParam(name = "deptName",   defaultValue = "")   String deptName,
            @RequestParam(name = "gradeName",  defaultValue = "")   String gradeName,
            @RequestParam(name = "empStatus",  defaultValue = "")   String empStatus,
            @RequestParam(name = "projectId",  defaultValue = "")   String projectId,
            @SessionAttribute(name = "member") SessionInfo si) {

        try {
            Map<String, Object> params = buildSearchParams(
                empId, empName, deptName, gradeName, empStatus, projectId
            );
            // 세션 empId를 항상 주입 — XML의 기본 필터(소속 프로젝트 직원만)에 사용
            params.put("sessionEmpId", si.getEmpId());

            int totalCount = empPerformanceService.dataCount(params);
            int totalPage  = (totalCount == 0) ? 0
                    : totalCount / size + (totalCount % size > 0 ? 1 : 0);

            currentPage = Math.min(currentPage, Math.max(totalPage, 1));
            int offset  = Math.max((currentPage - 1) * size, 0);
            params.put("offset", offset);
            params.put("size",   size);

            List<EmpPerformanceDto> list = empPerformanceService.listEmpPerformance(params);

            return ResponseEntity.ok(Map.of(
                "list",       list,
                "page",       currentPage,
                "totalPage",  totalPage,
                "totalCount", totalCount
            ));
        } catch (Exception e) {
            log.error("직원 성과 목록 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────────────────────
    // [2] 재직상태 공통코드 목록
    //     GET /api/emp-performance/status-codes
    //     → 재직상태 select 옵션 데이터 (codeGroup = 'EMPSTATUS')
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/status-codes")
    public ResponseEntity<?> getEmpStatusCodes() {
        try {
            List<Map<String, Object>> codes = empPerformanceService.listEmpStatusCodes();
            return ResponseEntity.ok(codes);
        } catch (Exception e) {
            log.error("재직상태 공통코드 목록 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────────────────────
    // [3] 세션 기준 소속 프로젝트 목록
    //     GET /api/emp-performance/my-projects
    //     → 참여 프로젝트 select 옵션 데이터
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/my-projects")
    public ResponseEntity<?> getMyProjects(
            @SessionAttribute(name = "member") SessionInfo si) {
        try {
            List<Map<String, Object>> projects = empPerformanceService.listMyProjects(si.getEmpId());
            return ResponseEntity.ok(projects);
        } catch (Exception e) {
            log.error("소속 프로젝트 목록 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────────────────────
    // [4] 평가 모달 — 보고서 존재 연도 목록
    //     GET /api/emp-performance/eval-years?empId={empId}
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/eval-years")
    public ResponseEntity<?> getEvalYears(
            @RequestParam(name = "empId") String empId) {
        try {
            List<Integer> years = empPerformanceService.listEvalYears(empId);
            return ResponseEntity.ok(years);
        } catch (Exception e) {
            log.error("평가 연도 목록 조회 오류 empId={}", empId, e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────────────────────
    // [5] 평가 모달 — 월×주차 그리드 데이터
    //     GET /api/emp-performance/eval-grid?empId={empId}&year={year}
    // ──────────────────────────────────────────────────────────────
    @GetMapping("/eval-grid")
    public ResponseEntity<?> getEvalGrid(
            @RequestParam(name = "empId") String empId,
            @RequestParam(name = "year")  int    year) {
        try {
            Map<String, Object> params = new HashMap<>();
            params.put("empId", empId);
            params.put("year",  year);

            List<EmpPerformanceDto> grid = empPerformanceService.listEvalGrid(params);
            return ResponseEntity.ok(grid);
        } catch (Exception e) {
            log.error("평가 그리드 조회 오류 empId={} year={}", empId, year, e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────────────────────
    // 내부 헬퍼 — 검색 파라미터 Map 구성 (빈 문자열 → null)
    // ──────────────────────────────────────────────────────────────
    private Map<String, Object> buildSearchParams(
            String empId, String empName, String deptName,
            String gradeName, String empStatus, String projectId) {

        Map<String, Object> map = new HashMap<>();
        map.put("empId",     empId.isBlank()     ? null : empId.trim());
        map.put("empName",   empName.isBlank()   ? null : empName.trim());
        map.put("deptName",  deptName.isBlank()  ? null : deptName.trim());
        map.put("gradeName", gradeName.isBlank() ? null : gradeName.trim());
        map.put("empStatus", empStatus.isBlank() ? null : empStatus.trim());
        map.put("projectId", projectId.isBlank() ? null : projectId.trim());
        return map;
    }
}