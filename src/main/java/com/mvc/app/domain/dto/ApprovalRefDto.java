package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalRefDto {
    private long refId;
    private long docId;
    private String refEmpId;
    private String refEmpName;
    private String refDeptCode;
    private String refDeptName;
    private String refGradeCode;
    private String refGradeName;
    private String readYn;
    private String readDate;
    private String refComment;
    private String refCommentDate;
}