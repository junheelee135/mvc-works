package com.mvc.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalNoticeDto {
    private long noticeId;         
    private String title;          
    private String content;        
    private String writerEmpId;    
    private String writerName;     
    private int hitCount;          
    private String regDate;        
    private String updateDate;     
    private List<ApprovalNoticeFileDto> files;
}