package com.mvc.app.group.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ReportFileDto {

    private Long   filenum;           // PK (reportfile_seq)
    private String savefilename;      // 서버 저장 파일명
    private String originalfilename;  // 원본 파일명
    private Long   filesize;          // 파일 크기 (bytes)
    private Long   filenum2;          // report.filenum FK
}
