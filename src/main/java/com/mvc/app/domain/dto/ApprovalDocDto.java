package com.mvc.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalDocDto {
    private long docId;
    private long docTypeId;
    private String title;
    private String content;
    private String detailData;
    private String docStatus;
    private String writerEmpId;
    private String writerEmpName;
    private String writerDeptCode;
    private String writerDeptName;
    private String writerGradeCode;
    private String writerGradeName;
    private String regDate;
    private String submitDate;
    private String myLineStatus;
    private int approvedCount;
    private int totalLineCount;
    private String readYn;

    private List<ApprovalLineDto> lines;
    private List<ApprovalRefDto> refs;
    private List<ApprovalFileDto> files;
    private String typeName;
    private String formCode;
    private long oldDocId;
    private int versionIncrement;
    private List<Long> keepFileIds;
}