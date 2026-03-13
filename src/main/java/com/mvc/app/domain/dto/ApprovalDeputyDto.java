package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalDeputyDto {
    private long deputyRegId;        // 대결 등록 ID (PK)
    private String delegatorEmpId;   // 위임자 사원번호
    private String deputyEmpId;      // 대결자 사원번호
    private String deputyName;       // 대결자 이름
    private Long docId;              // 문서 ID (URGENT 타입만 사용)
    private String startDate;        // 부재 시작일
    private String endDate;          // 부재 종료일
    private String reason;           // 부재 사유 코드
    private String regTypeCode;      // 등록유형코드
    private String regEmpId;         // 등록자 사원번호
    private String isActive;         // 활성여부 (Y/N)
    private String regDate;          // 등록일
    // JOIN으로 가져오는 필드
    private String deputyDept;       // 대결자 부서명
    private String deputyGrade;      // 대결자 직급명
}
