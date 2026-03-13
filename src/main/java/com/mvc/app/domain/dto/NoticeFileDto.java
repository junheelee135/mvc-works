package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class NoticeFileDto {
    private long   filenum;           // 첨부파일 고유번호 (PK)
    private long   savefilename;      // 첨부파일 저장 이름 (NUMBER)
    private String originalfilename;  // 첨부파일 원래 이름
    private long    filesize;          // 파일 크기
    private long   noticenum;         // 공지사항 고유번호 (FK)
}


