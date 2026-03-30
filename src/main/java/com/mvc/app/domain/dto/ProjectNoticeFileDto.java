package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ProjectNoticeFileDto {
    private long   filenum;
    private String savefilename;
    private String originalfilename;
    private long   filesize;
    private long   projectNoticeNum; 
}