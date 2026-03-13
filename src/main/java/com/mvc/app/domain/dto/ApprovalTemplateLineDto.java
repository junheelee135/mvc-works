package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalTemplateLineDto {
    private long tempLineId;
    private long tempId;
    private int stepOrder;
    private String apprEmpId;
    private String apprEmpName;
    private String apprDeptCode;
    private String apprDeptName;
    private String apprGradeCode;
    private String apprGradeName;
    private String apprTypeCode;
}