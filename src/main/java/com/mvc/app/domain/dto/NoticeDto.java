package com.mvc.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class NoticeDto {
    private long   noticenum;       // 공지사항 고유번호 (PK)
    private String subject;         // 제목
    private String content;         // 내용
    private int    hitcount;        // 조회수
    private String regdate;         // 작성일자
    private String updateDate;          // 수정일자
    private int    isnotice;        // 공지 여부 (1=공지, 0=일반)
    private int    state;           // 상태 (1=정상, 0=삭제)

    // JOIN으로 가져오는 필드
    private String authorEmpId;     // 작성자 사원번호
    private String authorName;      // 작성자 이름

    // 첨부파일 목록 (목록/상세 조회 시 포함)
    private List<NoticeFileDto> files;
    private int fileCount;      // 목록 조회 시 첨부파일 수
    private Long firstFilenum;  // 목록 조회 시 첫 번째 파일번호
}

