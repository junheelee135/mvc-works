package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalLineDto {
    private long lineId;
    private long docId;
    private int stepOrder;
    private String apprEmpId;
    private String apprEmpName;
    private String apprDeptCode;
    private String apprDeptName;
    private String apprGradeCode;
    private String apprGradeName;
    private String apprTypeCode;    // APPROVER
    private String apprStatus;      // PENDING, APPROVED, REJECTED
    private String apprComment;     // 결재의견
    private String apprDate;        // 결재처리일
    private String isDeputy;        // 대결여부 (Y/N)
    private String deputyEmpId;     // 대결자 사원번호
    private String deputyName;      // 대결자 이름
    private String activeDeputyName; // 현재 활성 대결자 이름 (부재 등록 기준)
}