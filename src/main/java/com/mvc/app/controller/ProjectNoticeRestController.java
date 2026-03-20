package com.mvc.app.controller;

import java.io.File;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.ProjectNoticeDto;
import com.mvc.app.domain.dto.ProjectNoticeFileDto;
import com.mvc.app.service.ProjectNoticeService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/projectnotice")
@RequiredArgsConstructor
public class ProjectNoticeRestController {

	private final ProjectNoticeService service;

	@Value("${file.upload-root}")
	private String uploadRoot;

	@GetMapping("/myprojects")
	public ResponseEntity<?> myProjects(@AuthenticationPrincipal UserDetails user) {
		if (user == null)
			return ResponseEntity.status(401).body("로그인 필요");

		String empId = user.getUsername();
		List<Map<String, Object>> list = service.getMyProjects(empId);

		return ResponseEntity.ok(list);
	}

	@GetMapping("/myprojects/pm")
	public ResponseEntity<?> myPmProjects(@AuthenticationPrincipal UserDetails user) {
		if (user == null)
			return ResponseEntity.status(401).body("로그인 필요");

		String empId = user.getUsername();
		List<Map<String, Object>> list = service.getMyPmProjects(empId);

		return ResponseEntity.ok(list);
	}

	@GetMapping("/list")
	public ResponseEntity<?> list(@RequestParam(value = "projectid", required = false) Long projectid,
			@RequestParam(value = "page", defaultValue = "1") int page,
			@RequestParam(value = "keyword", defaultValue = "") String keyword,
			@AuthenticationPrincipal UserDetails user) {

		if (user == null)
			return ResponseEntity.status(401).body("로그인 필요");

		String empId = user.getUsername();
		int pageSize = 10;
		int offset = (page - 1) * pageSize;

		Map<String, Object> param = new HashMap<>();
		param.put("empId", empId);
		param.put("projectid", projectid);
		param.put("keyword", keyword);
		param.put("offset", offset);
		param.put("pageSize", pageSize);
		param.put("limit", pageSize);

		List<ProjectNoticeDto> list = service.listNotice(param);
		int total = service.countNotice(param);

		boolean isManager = (projectid != null) ? service.isManager(empId, projectid) : false;

		Map<String, Object> result = new HashMap<>();
		result.put("list", list);
		result.put("total", total);
		result.put("page", page);
		result.put("pageSize", pageSize);
		result.put("isManager", isManager);

		return ResponseEntity.ok(result);
	}

	@PostMapping
	public ResponseEntity<?> insert(@RequestParam("projectid") long projectid, @RequestParam("subject") String subject,
			@RequestParam("content") String content, @RequestParam(value = "isnotice", defaultValue = "0") int isnotice,
			@RequestParam(value = "files", required = false) List<MultipartFile> files,
			@AuthenticationPrincipal UserDetails user) {

		if (user == null)
			return ResponseEntity.status(401).body("로그인 필요");

		String empId = user.getUsername();

		if (!service.isManager(empId, projectid))
			return ResponseEntity.status(403).body("권한 없음");

		try {
			ProjectNoticeDto dto = new ProjectNoticeDto();
			dto.setProjectid(projectid);
			dto.setSubject(subject);
			dto.setContent(content);
			dto.setIsnotice(isnotice);
			dto.setAuthorempid(empId);

			service.insertNotice(dto, files);

			return ResponseEntity.ok("등록 완료");

		} catch (Exception e) {
			log.error("insertNotice", e);
			return ResponseEntity.status(500).body("등록 실패");
		}
	}

	@GetMapping("/detail")
	public ResponseEntity<?> detail(@RequestParam("noticenum") long noticenum,
			@AuthenticationPrincipal UserDetails user) {

		if (user == null)
			return ResponseEntity.status(401).body("로그인 필요");

		String empId = user.getUsername();

		ProjectNoticeDto dto = service.getNotice(noticenum);
		if (dto == null)
			return ResponseEntity.status(404).body("공지 없음");

		boolean isManager = service.isManager(empId, dto.getProjectid());

		Map<String, Object> result = new HashMap<>();
		result.put("detail", dto);
		result.put("isManager", isManager);

		return ResponseEntity.ok(result);
	}

	@PostMapping("/update")
	public ResponseEntity<?> update(@RequestParam("noticenum") long noticenum, @RequestParam("subject") String subject,
			@RequestParam("content") String content, @RequestParam(value = "isnotice", defaultValue = "0") int isnotice,
			@AuthenticationPrincipal UserDetails user) {

		if (user == null)
			return ResponseEntity.status(401).body("로그인 필요");

		try {
			String empId = user.getUsername();

			ProjectNoticeDto origin = service.getNotice(noticenum);
			if (origin == null)
				return ResponseEntity.status(404).body("공지 없음");

			if (!service.isManager(empId, origin.getProjectid()))
				return ResponseEntity.status(403).body("권한 없음");

			ProjectNoticeDto dto = new ProjectNoticeDto();
			dto.setNoticenum(noticenum);
			dto.setSubject(subject);
			dto.setContent(content);
			dto.setIsnotice(isnotice);

			service.updateNotice(dto, null);

			return ResponseEntity.ok("수정 완료");

		} catch (Exception e) {
			log.error("updateNotice", e);
			return ResponseEntity.status(500).body("수정 실패");
		}
	}

	@PostMapping("/delete")
	public ResponseEntity<?> delete(@RequestParam("noticenum") long noticenum,
			@AuthenticationPrincipal UserDetails user) {

		if (user == null)
			return ResponseEntity.status(401).body("로그인 필요");

		try {
			String empId = user.getUsername();

			ProjectNoticeDto dto = service.getNotice(noticenum);
			if (dto == null)
				return ResponseEntity.status(404).body("공지 없음");

			if (!service.isManager(empId, dto.getProjectid()))
				return ResponseEntity.status(403).body("권한 없음");

			service.deleteNotice(noticenum);

			return ResponseEntity.ok().build();

		} catch (Exception e) {
			log.error("deleteNotice", e);
			return ResponseEntity.status(500).body("삭제 실패");
		}
	}

	@GetMapping("/file/{filenum}")
	public ResponseEntity<?> downloadFile(@PathVariable("filenum") long filenum) {
		try {
			ProjectNoticeFileDto file = service.getFile(filenum);
			if (file == null)
				return ResponseEntity.notFound().build();

			File f = new File(uploadRoot, file.getSavefilename());
			if (!f.exists())
				return ResponseEntity.notFound().build();

			Resource resource = new FileSystemResource(f);
			String encodedName = URLEncoder.encode(file.getOriginalfilename(), "UTF-8").replaceAll("\\+", "%20");

			return ResponseEntity.ok()
					.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + encodedName + "\"")
					.contentLength(f.length()).contentType(MediaType.APPLICATION_OCTET_STREAM).body(resource);

		} catch (Exception e) {
			log.error("file download error", e);
			return ResponseEntity.status(500).body("파일 다운로드 실패");
		}
	}
}