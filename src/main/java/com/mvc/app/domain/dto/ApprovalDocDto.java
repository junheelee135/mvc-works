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
    private String detailData;      // 세부양식 JSON 문자열
    private String docStatus;       // DRAFT, PENDING, APPROVED, REJECTED
    private String writerEmpId;
    private String writerEmpName;
    private String writerDeptCode;
    private String writerDeptName;
    private String writerGradeCode;
    private String writerGradeName;
    private String regDate;
    private String submitDate;
    private String myLineStatus;   // 전체결재함: 현재 사용자의 결재선 상태
    private int approvedCount;     // 승인 완료된 결재선 수
    private int totalLineCount;    // 전체 결재선 수
    private String readYn;         // 참조 결재함: 읽음 여부

    // 결재선 + 참조자 + 첨부파일
    private List<ApprovalLineDto> lines;
    private List<ApprovalRefDto> refs;
    private List<ApprovalFileDto> files;
    private String typeName;
    private String formCode;
    private long oldDocId;    // 임시저장 수정 시 기존 문서 ID
    private int versionIncrement; // 재상신 시 1, 그 외 0
}