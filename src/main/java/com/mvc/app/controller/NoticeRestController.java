package com.mvc.app.controller;

import java.io.File;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.NoticeDto;
import com.mvc.app.domain.dto.NoticeFileDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.NoticeService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/notice")
public class NoticeRestController {

	private final NoticeService service;

	@Value("${file.upload-root}")
	private String uploadPath;

	private boolean isManager(SessionInfo info) {
		return info.getUserLevel() == 99;
	}

	@PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<?> insert(@RequestPart("data") NoticeDto dto,
			@RequestPart(value = "files", required = false) List<MultipartFile> files) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			if (!isManager(info)) {
				return ResponseEntity.status(403).body(Map.of("msg", "관리자만 등록할 수 있습니다."));
			}
			dto.setAuthorEmpId(info.getEmpId());
			service.insertNotice(dto, files);
			return ResponseEntity.ok(Map.of("msg", "공지사항이 등록되었습니다."));
		} catch (Exception e) {
			log.error("insertNotice : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "등록 실패"));
		}
	}

	@PutMapping(value = "/{noticenum}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
	public ResponseEntity<?> update(@PathVariable("noticenum") long noticenum, @RequestPart("data") NoticeDto dto,
			@RequestPart(value = "files", required = false) List<MultipartFile> files,
			@RequestPart(value = "deleteFileNums", required = false) List<Long> deleteFileNums) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			if (!isManager(info)) {
				return ResponseEntity.status(403).body(Map.of("msg", "관리자만 수정할 수 있습니다."));
			}
			dto.setNoticenum(noticenum);
			service.updateNotice(dto, files, deleteFileNums);
			return ResponseEntity.ok(Map.of("msg", "공지사항이 수정되었습니다."));
		} catch (Exception e) {
			log.error("updateNotice : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "수정 실패"));
		}
	}

	@DeleteMapping("/{noticenum}")
	public ResponseEntity<?> delete(@PathVariable("noticenum") long noticenum) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			if (!isManager(info)) {
				return ResponseEntity.status(403).body(Map.of("msg", "관리자만 삭제할 수 있습니다."));
			}
			service.deleteNotice(noticenum);
			return ResponseEntity.ok(Map.of("msg", "삭제되었습니다."));
		} catch (Exception e) {
			log.error("deleteNotice : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "삭제 실패"));
		}
	}

	@GetMapping("/list")
	public ResponseEntity<?> list(@RequestParam(name = "pageNo", defaultValue = "1") int pageNo,
			@RequestParam(name = "pageSize", defaultValue = "10") int pageSize,
			@RequestParam(name = "keyword", defaultValue = "") String keyword) {
		try {
			Map<String, Object> map = new HashMap<>();
			map.put("pageSize", pageSize);
			map.put("offset", (pageNo - 1) * pageSize);
			map.put("keyword", keyword.isBlank() ? null : keyword);
			return ResponseEntity.ok(service.listNotice(map));
		} catch (Exception e) {
			log.error("listNotice : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회 실패"));
		}
	}

	@GetMapping("/{noticenum}")
	public ResponseEntity<?> get(@PathVariable("noticenum") long noticenum) {
		try {
			NoticeDto dto = service.getNotice(noticenum);
			if (dto == null)
				return ResponseEntity.notFound().build();
			return ResponseEntity.ok(dto);
		} catch (Exception e) {
			log.error("getNotice : ", e);
			return ResponseEntity.internalServerError().body(Map.of("msg", "조회 실패"));
		}
	}

	@GetMapping("/file/{filenum}")
	public ResponseEntity<Resource> download(@PathVariable("filenum") long filenum) {
		try {
			NoticeFileDto file = service.getFile(filenum);
			if (file == null)
				return ResponseEntity.notFound().build();

			File savedFile = new File(uploadPath + file.getSavefilename());
			if (!savedFile.exists())
				return ResponseEntity.notFound().build();

			Resource resource = new FileSystemResource(savedFile);
			String encoded = URLEncoder.encode(file.getOriginalfilename(), "UTF-8").replace("+", "%20");
			String contentType = Files.probeContentType(savedFile.toPath());
			if (contentType == null)
				contentType = "application/octet-stream";

			return ResponseEntity.ok()
					.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encoded)
					.contentType(MediaType.parseMediaType(contentType)).body(resource);
		} catch (Exception e) {
			log.error("download : ", e);
			return ResponseEntity.internalServerError().build();
		}
	}

	@DeleteMapping("/file/{filenum}")
	public ResponseEntity<?> deleteFile(@PathVariable("filenum") long filenum) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			if (!isManager(info)) {
				return ResponseEntity.status(403).body(Map.of("msg", "권한 없음"));
			}
			service.deleteFile(filenum);
			return ResponseEntity.ok(Map.of("msg", "파일이 삭제되었습니다."));
		} catch (Exception e) {
			log.error("deleteFile : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "파일 삭제 실패"));
		}
	}
}
