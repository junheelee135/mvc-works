package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalDeputyDto {
    private long deputyRegId;
    private String delegatorEmpId;
    private String deputyEmpId;
    private String deputyName;
    private Long docId;
    private String startDate;
    private String endDate;
    private String reason;
    private String regTypeCode;
    private String regEmpId;
    private String isActive;
    private String regDate;
    private String deputyDept;
    private String deputyGrade;
}
