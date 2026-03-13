package com.mvc.app.domain.dto;

import org.springframework.web.multipart.MultipartFile;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class BoardDto {
	private long num;
	private String empId;           // 사원번호 (employee2 FK)
	private String name;
	private String subject;
	private String content;
	private String regDate;         // 등록일자
	private int hitCount;
	private int block;

	private String saveFilename;
	private String originalFilename;
	private MultipartFile selectFile;

	private int replyCount;
	private int boardLikeCount;
}
