package com.mvc.app.controller;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.mvc.app.common.PaginateUtil;
import com.mvc.app.domain.dto.ReplyDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.ReplyService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/posts/*")
public class ReplyController {
	private final ReplyService service;
	private final PaginateUtil paginateUtil;

	// 댓글 리스트 : JSON
	@GetMapping("{target}")
	public Map<String, ?> listReply(
			@PathVariable(name = "target") String target,
			@RequestParam(name = "num") long num,
			@RequestParam(name = "pageNo", defaultValue = "1") int current_page) throws Exception {

		Map<String, Object> model = new HashMap<>();

		String state = "true";
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			int size = 5;
			int total_page = 0;
			int dataCount = 0;

			Map<String, Object> map = new HashMap<>();
			map.put("target", target);
			map.put("targetLike", target + "Like");

			map.put("num", num);

			map.put("userLevel", info.getUserLevel());
			map.put("empId", info.getEmpId());

			dataCount = service.replyCount(map);
			total_page = paginateUtil.pageCount(dataCount, size);
			current_page = Math.min(current_page, total_page);

			int offset = (current_page - 1) * size;
			if(offset < 0) offset = 0;

			map.put("offset", offset);
			map.put("size", size);

			List<ReplyDto> listReply = service.listReply(map);

			// AJAX 용 페이징
			String paging = paginateUtil.pagingMethod(current_page, total_page, "loadContent");

			Map<String, Object> sessionMember = new HashMap<>();
			sessionMember.put("empId", info.getEmpId());
			sessionMember.put("userLevel", info.getUserLevel());

			model.put("listReply", listReply);
			model.put("pageNo", current_page);
			model.put("replyCount", dataCount);
			model.put("total_page", total_page);
			model.put("paging", paging);

			model.put("sessionMember", sessionMember);

		} catch (Exception e) {
			log.info("listReply : ", e);

			state = "false";
		}

		model.put("state", state);

		return model;
	}

	// 댓글 및 댓글의 답글 등록 : JSON
	@PostMapping("{target}")
	public Map<String, ?> insertReply(
			@PathVariable(name = "target") String target,
			ReplyDto dto) {
		Map<String, Object> model = new HashMap<>();

		String state = "true";
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			dto.setTarget(target);

			dto.setEmpId(info.getEmpId());
			service.insertReply(dto);
		} catch (Exception e) {
			state = "false";
		}

		model.put("state", state);
		return model;
	}

	// 댓글 및 댓글의 답글 삭제 : JSON
	@DeleteMapping("{target}")
	public Map<String, ?> deleteReply(
			@PathVariable(name = "target") String target,
			@RequestParam Map<String, Object> paramMap) {
		Map<String, Object> model = new HashMap<>();

		String state = "true";
		try {
			paramMap.put("target", target);

			service.deleteReply(paramMap);
		} catch (Exception e) {
			state = "false";
		}

		model.put("state", state);
		return model;
	}

	// 댓글의 답글 리스트 : JSON
	@GetMapping("{target}/answer")
	public Map<String, ?> listReplyAnswer(
			@PathVariable(name = "target") String target,
			@RequestParam Map<String, Object> paramMap) throws Exception {

		Map<String, Object> model = new HashMap<>();
		String state = "true";

		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			paramMap.put("target", target);
			paramMap.put("userLevel", info.getUserLevel());
			paramMap.put("empId", info.getEmpId());

			// 댓글별 답글 개수
			int answerCount = service.replyAnswerCount(paramMap);

			List<ReplyDto> listReplyAnswer = service.listReplyAnswer(paramMap);

			Map<String, Object> sessionMember = new HashMap<>();
			sessionMember.put("empId", info.getEmpId());
			sessionMember.put("userLevel", info.getUserLevel());

			model.put("answerCount", answerCount);
			model.put("listReplyAnswer", listReplyAnswer);
			model.put("sessionMember", sessionMember);

		} catch (Exception e) {
			log.info("listReplyAnswer : ", e);

			state = "false";
		}
		model.put("state", state);

		return model;
	}

	// 댓글의 좋아요/싫어요 추가 : JSON
	@PostMapping("{target}/replyLike")
	public Map<String, ?> insertReplyLike(
			@PathVariable(name = "target") String target,
			@RequestParam Map<String, Object> paramMap) {
		Map<String, Object> model = new HashMap<>();

		String state = "true";
		int likeCount = 0;
		int disLikeCount = 0;
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			paramMap.put("targetLike", target + "Like");
			paramMap.put("empId", info.getEmpId());
			service.insertReplyLike(paramMap);

			Map<String, Object> countMap = service.replyLikeCount(paramMap);
			// 마이바티스의 resultType이 map인 경우 int는 BigDecimal로 넘어옴
			likeCount = ((BigDecimal)countMap.get("LIKECOUNT")).intValue();
			disLikeCount = ((BigDecimal)countMap.get("DISLIKECOUNT")).intValue();
		} catch (DuplicateKeyException e) {
			state = "liked";
		} catch (Exception e) {
			state = "false";
		}

		model.put("likeCount", likeCount);
		model.put("disLikeCount", disLikeCount);
		model.put("state", state);

		return model;
	}

	// 댓글 숨김/표시 : JSON
	@PostMapping("{target}/replyShowHide")
	public Map<String, ?> replyShowHide(
			@PathVariable(name = "target") String target,
			@RequestParam Map<String, Object> paramMap) {
		Map<String, Object> model = new HashMap<>();

		String state = "true";
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			paramMap.put("target", target);
			paramMap.put("empId", info.getEmpId());

			service.updateReplyShowHide(paramMap);
		} catch (Exception e) {
			state = "false";
		}

		model.put("state", state);
		return model;
	}
}
