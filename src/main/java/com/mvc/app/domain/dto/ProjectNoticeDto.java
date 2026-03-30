package com.mvc.app.domain.dto;

import java.util.List;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ProjectNoticeDto {
	
    private long   projectNoticeNum; 
    
    private long   projectid;
    private String subject;
    private String content;
    private int    hitcount;
    private String regdate;
    private String updatedate;
    private int    isnotice;
    private int    state;
    private String authorempid;

    // JOIN 결과 담는 필드
    private String authorName;
    private String projectName;   // project 테이블 JOIN

    // 첨부파일 리스트
    private List<ProjectNoticeFileDto> files;
}