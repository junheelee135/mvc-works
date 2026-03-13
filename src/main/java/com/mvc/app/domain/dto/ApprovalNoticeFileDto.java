package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ApprovalNoticeFileDto {
    private long fileId;
    private long noticeId;
    private String oriFilename;
    private String saveFilename;
    private long fileSize;
    private String regDate;
}