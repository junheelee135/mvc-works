package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class EmpPerformanceDto {

    // ── 직원 기본 정보 (employee1 + employee2 JOIN) ────────────
    private String empId;           // 사원번호
    private String empName;         // 이름
    private String deptCode;        // 부서코드
    private String deptName;        // 부서명
    private String gradeCode;       // 직급코드
    private String gradeName;       // 직급명
    private String empStatusCode;   // 재직상태 코드 (ES01~ES04)
    private String empStatusName;   // 재직상태 명
    private String projectNames;    // 참여 프로젝트명 (LISTAGG)

    // ── 인사평가 그리드용 ──────────────────────────────────────
    private int    reportMonth;     // 보고 기간 월 (1~12)
    private int    reportWeek;      // 보고 기간 주차 (1~4)
    private String evaluation;      // POSITIVE / NORMAL / NEGATIVE / null(미제출)

    // ── 검색 파라미터 ──────────────────────────────────────────
    private String searchEmpId;
    private String searchEmpName;
    private String searchDeptName;
    private String searchGradeName;
    private String searchEmpStatus;
    private String searchProjectId;     // 참여 프로젝트 ID 기준 필터
}
