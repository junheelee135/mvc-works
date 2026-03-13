package com.mvc.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.mvc.app.domain.dto.DepartmentDto;
import com.mvc.app.service.OrgService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/approval/org")
public class OrgRestController {
    private final OrgService service;

    // 부서 트리 조회
    @GetMapping("/dept")
    public ResponseEntity<?> deptTree() {
        try {
            List<DepartmentDto> tree = service.getDeptTree();
            return ResponseEntity.ok(Map.of("tree", tree));
        } catch (Exception e) {
            log.info("deptTree : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "부서 조회 실패"));
        }
    }

    // 부서별 사원 목록
    @GetMapping("/emp")
    public ResponseEntity<?> empByDept(@RequestParam("deptCode") String deptCode) {
        try {
            List<Map<String, Object>> list = service.listEmpByDept(deptCode);
            return ResponseEntity.ok(Map.of("list", list));
        } catch (Exception e) {
            log.info("empByDept : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "사원 조회 실패"));
        }
    }

    // 사원 검색
    @GetMapping("/emp/search")
    public ResponseEntity<?> searchEmp(@RequestParam("keyword") String keyword) {
        try {
            List<Map<String, Object>> list = service.searchEmp(keyword);
            return ResponseEntity.ok(Map.of("list", list));
        } catch (Exception e) {
            log.info("searchEmp : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "검색 실패"));
        }
    }
}
