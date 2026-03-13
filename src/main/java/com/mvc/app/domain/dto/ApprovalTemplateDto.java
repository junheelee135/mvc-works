package com.mvc.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalTemplateDto {
    private long tempId;
    private String tempName;
    private String writerEmpId;
    private String regDate;

    // 템플릿 상세 (결재자 목록)
    private List<ApprovalTemplateLineDto> lines;
}