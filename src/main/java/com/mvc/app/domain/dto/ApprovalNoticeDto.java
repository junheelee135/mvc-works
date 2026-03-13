package com.mvc.app.domain.dto;

import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ApprovalNoticeDto {
    private long noticeId;         // PK (approvalNotice_seq)
    private String title;          // 제목
    private String content;        // 내용 (CLOB, Quill HTML)
    private String writerEmpId;    // 작성자 사원번호
    private String writerName;     // 작성자 이름
    private int hitCount;          // 조회수
    private String regDate;        // 등록일
    private String updateDate;     // 수정일
    private List<ApprovalNoticeFileDto> files;
}