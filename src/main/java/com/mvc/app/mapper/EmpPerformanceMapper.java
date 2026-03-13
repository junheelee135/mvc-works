package com.mvc.app.mapper;

import com.mvc.app.domain.dto.EmpPerformanceDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface EmpPerformanceMapper {

    // ── 직원 목록 ──────────────────────────────────────────────
    int dataCount(Map<String, Object> params);
    List<EmpPerformanceDto> listEmpPerformance(Map<String, Object> params);

    // ── 세션 empId 기준 소속 프로젝트 목록 ────────────────────
    // 반환: [{projectId, projectName}, ...]
    List<Map<String, Object>> listMyProjects(String empId);

    // ── 재직상태 공통코드 목록 (codeGroup = 'EMPSTATUS') ──────
    // 반환: [{code, codeName}, ...]
    List<Map<String, Object>> listEmpStatusCodes();

    // ── 인사평가 모달 - 해당 직원의 보고서가 존재하는 연도 목록 ─
    List<Integer> listEvalYears(String empId);

    // ── 인사평가 모달 - 연도별 월×주차 평가 그리드 데이터 ──────
    // 반환: [{reportMonth, reportWeek, evaluation}, ...]
    List<EmpPerformanceDto> listEvalGrid(Map<String, Object> params);
}
