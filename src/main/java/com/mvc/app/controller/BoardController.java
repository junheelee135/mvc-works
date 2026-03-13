package com.mvc.app.controller;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.mvc.app.common.MyUtil;
import com.mvc.app.common.PaginateUtil;
import com.mvc.app.common.RequestUtils;
import com.mvc.app.common.StorageService;
import com.mvc.app.domain.dto.BoardDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.exception.StorageException;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.BoardService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/bbs/*")
public class BoardController {
	private final BoardService service;
	private final PaginateUtil paginateUtil;
	private final StorageService storageService;
	private final MyUtil myUtil;

	@Value("${file.upload-root}/bbs")
	private String uploadPath;

	@GetMapping("list")
	public String list(@RequestParam(name = "page", defaultValue = "1") int current_page,
			@RequestParam(name = "schType", defaultValue = "all") String schType,
			@RequestParam(name = "kwd", defaultValue = "") String kwd,
			Model model) throws Exception {

		try {
			int size = 10;
			int total_page = 0;
			int dataCount = 0;

			kwd = myUtil.decodeUrl(kwd);

			Map<String, Object> map = new HashMap<String, Object>();
			map.put("schType", schType);
			map.put("kwd", kwd);

			dataCount = service.dataCount(map);
			if (dataCount != 0) {
				total_page = dataCount / size + (dataCount % size > 0 ? 1 : 0);
			}

			current_page = Math.min(current_page, total_page);

			int offset = (current_page - 1) * size;
			if(offset < 0) offset = 0;

			map.put("offset", offset);
			map.put("size", size);

			List<BoardDto> list = service.listBoard(map);

			String cp = RequestUtils.getContextPath();
			String query = "";
			String listUrl = cp + "/bbs/list";
			String articleUrl = cp + "/bbs/article?page=" + current_page;
			if (! kwd.isBlank()) {
				query = "schType=" + schType + "&kwd=" + myUtil.encodeUrl(kwd);

				listUrl += "?" + query;
				articleUrl += "&" + query;
			}
			String paging = paginateUtil.paging(current_page, total_page, listUrl);

			model.addAttribute("list", list);
			model.addAttribute("dataCount", dataCount);
			model.addAttribute("size", size);
			model.addAttribute("total_page", total_page);
			model.addAttribute("page", current_page);

			model.addAttribute("paging", paging);
			model.addAttribute("articleUrl", articleUrl);

			model.addAttribute("schType", schType);
			model.addAttribute("kwd", kwd);

		} catch (Exception e) {
			log.info("list : ", e);
		}

		return "bbs/list";
	}

	@GetMapping("write")
	public String writeForm(Model model) throws Exception {

		model.addAttribute("mode", "write");

		return "bbs/write";
	}

	@PostMapping("write")
	public String writeSubmit(BoardDto dto) throws Exception {

		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			dto.setEmpId(info.getEmpId());

			service.insertBoard(dto, uploadPath);

		} catch (Exception e) {
			log.info("writeSubmit : ", e);
		}

		return "redirect:/bbs/list";
	}

	@GetMapping("article")
	public String article(@RequestParam(name = "num") long num,
			@RequestParam(name = "page") String page,
			@RequestParam(name = "schType", defaultValue = "all") String schType,
			@RequestParam(name = "kwd", defaultValue = "") String kwd,
			Model model) throws Exception {

		String query = "page=" + page;
		try {
			kwd = myUtil.decodeUrl(kwd);
			if (! kwd.isBlank()) {
				query += "&schType=" + schType +
						"&kwd=" + myUtil.encodeUrl(kwd);
			}

			service.updateHitCount(num);

			BoardDto dto = Objects.requireNonNull(service.findById(num));

			dto.setName(myUtil.nameMasking(dto.getName()));

			dto.setContent(myUtil.sanitize(dto.getContent()));

			Map<String, Object> map = new HashMap<String, Object>();
			map.put("schType", schType);
			map.put("kwd", kwd);
			map.put("num", num);

			BoardDto prevDto = service.findByPrev(map);
			BoardDto nextDto = service.findByNext(map);

			// 게시글 좋아요 여부
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			map.put("empId", info.getEmpId());
			boolean isUserLiked = service.isUserBoardLiked(map);

			model.addAttribute("dto", dto);
			model.addAttribute("prevDto", prevDto);
			model.addAttribute("nextDto", nextDto);

			model.addAttribute("isUserLiked", isUserLiked);

			model.addAttribute("page", page);
			model.addAttribute("query", query);

			return "bbs/article";

		} catch (NullPointerException e) {
			log.info("article : ", e);
		} catch (Exception e) {
			log.info("article : ", e);
		}

		return "redirect:/bbs/list?" + query;
	}

	@GetMapping("update")
	public String updateForm(@RequestParam(name = "num") long num,
			@RequestParam(name = "page") String page,
			Model model) throws Exception {

		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			BoardDto dto = Objects.requireNonNull(service.findById(num));

			if (!dto.getEmpId().equals(info.getEmpId())) {
				return "redirect:/bbs/list?page=" + page;
			}

			model.addAttribute("dto", dto);
			model.addAttribute("mode", "update");
			model.addAttribute("page", page);

			return "bbs/write";

		} catch (NullPointerException e) {
		} catch (Exception e) {
			log.info("updateForm : ", e);
		}

		return "redirect:/bbs/list?page=" + page;
	}

	@PostMapping("update")
	public String updateSubmit(BoardDto dto,
			@RequestParam(name = "page") String page) throws Exception {

		try {
			service.updateBoard(dto, uploadPath);
		} catch (Exception e) {
			log.info("updateSubmit : ", e);
		}

		return "redirect:/bbs/list?page=" + page;
	}

	@GetMapping("deleteFile")
	public String deleteFile(@RequestParam(name = "num") long num,
			@RequestParam(name = "page") String page) throws Exception {

		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			BoardDto dto = Objects.requireNonNull(service.findById(num));

			if (!dto.getEmpId().equals(info.getEmpId())) {
				return "redirect:/bbs/list?page=" + page;
			}

			if (dto.getSaveFilename() != null) {
				storageService.deleteFile(uploadPath, dto.getSaveFilename());

				dto.setSaveFilename("");
				dto.setOriginalFilename("");
				service.updateBoard(dto, uploadPath);
			}

			return "redirect:/bbs/update?num=" + num + "&page=" + page;

		} catch (NullPointerException e) {
		} catch (Exception e) {
			log.info("deleteFile : ", e);
		}

		return "redirect:/bbs/list?page=" + page;
	}

	@GetMapping("delete")
	public String delete(@RequestParam(name = "num") long num,
			@RequestParam(name = "page") String page,
			@RequestParam(name = "schType", defaultValue = "all") String schType,
			@RequestParam(name = "kwd", defaultValue = "") String kwd) throws Exception {

		String query = "page=" + page;
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			kwd = myUtil.decodeUrl(kwd);
			if (! kwd.isBlank()) {
				query += "&schType=" + schType + "&kwd=" + myUtil.encodeUrl(kwd);
			}

			service.deleteBoard(num, uploadPath, info.getEmpId(), info.getUserLevel());

		} catch (Exception e) {
			log.info("delete : ", e);
		}

		return "redirect:/bbs/list?" + query;
	}

	/*
	  - ResponseEntity
	  	: 스프링에서 HTTP 응답을 나타내는 클래스
	    : 클라이언트에게 응답을 보낼 때, 상태 코드, 응답 헤더, 응답 바디를 명시적으로 설정
	*/
	@GetMapping("download")
	public ResponseEntity<?> download(
			@RequestParam(name = "num") long num) throws Exception {

		try {
			BoardDto dto = Objects.requireNonNull(service.findById(num));

			return storageService.downloadFile(uploadPath, dto.getSaveFilename(), dto.getOriginalFilename());

		} catch (NullPointerException | StorageException e) {
			log.info("download : ", e);
		} catch (Exception e) {
			log.info("download : ", e);
		}

		String redirectUrl = RequestUtils.getContextPath() + "/bbs/downloadFailed";
		return ResponseEntity
				.status(HttpStatus.FOUND)
				.location(URI.create(redirectUrl))
				.build();
	}

	@GetMapping("downloadFailed")
	public String downloadFailed() {
		return "error/downloadFailure";
	}

	// 게시글 좋아요 추가 : AJAX-JSON
	@ResponseBody
	@PostMapping("boardLike/{num}")
	public Map<String, ?> insertBoardLike(
			@PathVariable(name = "num") long num) {
		Map<String, Object> model = new HashMap<>();

		String state = "true";

		int boardLikeCount = 0;
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			Map<String, Object> paramMap = new HashMap<>();
			paramMap.put("num", num);
			paramMap.put("empId", info.getEmpId());

			service.insertBoardLike(paramMap);

			boardLikeCount = service.boardLikeCount(num);

		} catch (DuplicateKeyException e) {
			state = "liked";
		} catch (Exception e) {
			state = "false";
		}

		model.put("state", state);
		model.put("boardLikeCount", boardLikeCount);

		return model;
	}

	//  좋아요 해제 : AJAX-JSON
	@ResponseBody
	@DeleteMapping("boardLike/{num}")
	public Map<String, ?> deleteBoardLike(@PathVariable(name = "num") long num) {
		Map<String, Object> model = new HashMap<>();

		String state = "true";
		int boardLikeCount = 0;

		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			Map<String, Object> paramMap = new HashMap<>();
			paramMap.put("num", num);
			paramMap.put("empId", info.getEmpId());

			service.deleteBoardLike(paramMap);

			boardLikeCount = service.boardLikeCount(num);

		} catch (Exception e) {
			state = "false";
		}

		model.put("state", state);
		model.put("boardLikeCount", boardLikeCount);

		return model;
	}
}
