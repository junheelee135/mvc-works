package com.mvc.app.service;

import com.mvc.app.domain.dto.EmpPerformanceDto;
import com.mvc.app.mapper.EmpPerformanceMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmpPerformanceServiceImpl implements EmpPerformanceService {

    private final EmpPerformanceMapper mapper;

    // ──────────────────────────────────────────────
    // [1] 전체 건수
    // ──────────────────────────────────────────────
    @Override
    public int dataCount(Map<String, Object> params) {
        try {
            return mapper.dataCount(params);
        } catch (Exception e) {
            log.error("EmpPerformance dataCount error", e);
            return 0;
        }
    }

    // ──────────────────────────────────────────────
    // [2] 직원 목록
    // ──────────────────────────────────────────────
    @Override
    public List<EmpPerformanceDto> listEmpPerformance(Map<String, Object> params) {
        try {
            return mapper.listEmpPerformance(params);
        } catch (Exception e) {
            log.error("EmpPerformance listEmpPerformance error", e);
            return new ArrayList<>();
        }
    }

    // ──────────────────────────────────────────────
    // [3] 재직상태 공통코드 목록
    // ──────────────────────────────────────────────
    @Override
    public List<Map<String, Object>> listEmpStatusCodes() {
        try {
            return mapper.listEmpStatusCodes();
        } catch (Exception e) {
            log.error("EmpPerformance listEmpStatusCodes error", e);
            return new ArrayList<>();
        }
    }

    // ──────────────────────────────────────────────
    // [4] 세션 기준 소속 프로젝트 목록
    // ──────────────────────────────────────────────
    @Override
    public List<Map<String, Object>> listMyProjects(String empId) {
        try {
            return mapper.listMyProjects(empId);
        } catch (Exception e) {
            log.error("EmpPerformance listMyProjects error empId={}", empId, e);
            return new ArrayList<>();
        }
    }

    // ──────────────────────────────────────────────
    // [4] 보고서 존재 연도 목록
    // ──────────────────────────────────────────────
    @Override
    public List<Integer> listEvalYears(String empId) {
        try {
            return mapper.listEvalYears(empId);
        } catch (Exception e) {
            log.error("EmpPerformance listEvalYears error empId={}", empId, e);
            return new ArrayList<>();
        }
    }

    // ──────────────────────────────────────────────
    // [5] 연도별 월×주차 평가 그리드
    // ──────────────────────────────────────────────
    @Override
    public List<EmpPerformanceDto> listEvalGrid(Map<String, Object> params) {
        try {
            return mapper.listEvalGrid(params);
        } catch (Exception e) {
            log.error("EmpPerformance listEvalGrid error params={}", params, e);
            return new ArrayList<>();
        }
    }
}
