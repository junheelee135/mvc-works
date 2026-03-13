package com.mvc.app.domain.dto;

import org.springframework.beans.factory.annotation.Value;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ReplyDto {
	private String target; // 댓글 테이블
	private String targetLike; // 좋아요 테이블
	private long replyNum;
	private long num;
	private String empId;           // 사원번호 (employee2 FK)
	private String name;
	private String profilePhoto;    // 프로필사진저장경로
	private String content;
	private String regDate;         // 등록일자
	private long parentNum;
	private int showReply;
	private int block;
	private String ipAddr; 
	
	private int answerCount;
	private int likeCount;
	private int disLikeCount;
	
	@Value("-1")
	private int userReplyLiked; // 리플 좋아요/싫어요 유무(-1:하지않음, 1:좋아요, 0:싫어요)
}
