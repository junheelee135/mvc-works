package com.mvc.app.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.ApprovalNoticeDto;
import com.mvc.app.domain.dto.ApprovalNoticeFileDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.ApprovalNoticeService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/approval/notice")
public class ApprovalNoticeRestController {
	private final ApprovalNoticeService service;

	@Value("${file.upload-root}/approval/notice")
	private String uploadPath;

	@GetMapping
	public ResponseEntity<?> list(
			@RequestParam(name = "keyword", defaultValue="") String keyword,
			@RequestParam(name = "pageNo", defaultValue="1") int pageNo,
			@RequestParam(name = "pageSize", defaultValue="10") int pageSize) {
		try {
			Map<String, Object> map = new HashMap<>();
			map.put("keyword", keyword);
			map.put("offset", (pageNo - 1) * pageSize);
			map.put("pageSize", pageSize);

			Map<String, Object> result = service.listNotice(map);

			return ResponseEntity.ok(result);
		} catch (Exception e) {
			log.info("list : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
		}
	}

	@GetMapping("/{noticeId}")
	public ResponseEntity<?> detail(@PathVariable("noticeId") long noticeId) {
		try {
			ApprovalNoticeDto dto = service.findById(noticeId);
			if(dto == null) {
				return ResponseEntity.status(404).body(Map.of("msg", "게시글을 찾을 수 없습니다"));
			}
			return ResponseEntity.ok(dto);
		} catch (Exception e) {
            log.info("detail : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "조회에 실패했습니다."));
		}
	}

	@PostMapping
	public ResponseEntity<?> insert(
	        @RequestPart("data") ApprovalNoticeDto dto,
	        @RequestPart(value = "files", required = false) MultipartFile[] files) {
    	try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (info == null || info.getUserLevel() != 99) {
                return ResponseEntity.status(403).body(Map.of("msg", "권한이 없습니다"));
            }

            dto.setWriterEmpId(info.getEmpId());
            dto.setWriterName(info.getName());
            service.insertNotice(dto, files);
            return ResponseEntity.ok(Map.of("msg", "등록 완료"));
		} catch (Exception e) {
            log.info("insert : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "등록에 실패했습니다."));
		}
    }

	@PostMapping("/{noticeId}")
	public ResponseEntity<?> update(@PathVariable("noticeId") long noticeId,
	                                @RequestPart("data") ApprovalNoticeDto dto,
	                                @RequestPart(value = "files", required = false) MultipartFile[] files){
		try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (info == null || info.getUserLevel() != 99) {
                return ResponseEntity.status(403).body(Map.of("msg", "권한이 없습니다"));
            }

            dto.setNoticeId(noticeId);
            service.updateNotice(dto, files);
            return ResponseEntity.ok(Map.of("msg", "수정 완료"));
		} catch (Exception e) {
            log.info("update : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "수정에 실패했습니다."));
		}

    }

    @DeleteMapping("/{noticeId}")
    public ResponseEntity<?> delete(@PathVariable("noticeId") long noticeId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (info == null || info.getUserLevel() != 99) {
                return ResponseEntity.status(403).body(Map.of("msg", "권한이 없습니다"));
            }

            service.deleteNotice(noticeId);
            return ResponseEntity.ok(Map.of("msg", "삭제 완료"));
        } catch (Exception e) {
            log.info("delete : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "삭제에 실패했습니다."));
        }
    }

    @GetMapping("/file/{fileId}/download")
    public ResponseEntity<?> downloadFile(@PathVariable("fileId") long fileId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (info == null) {
                return ResponseEntity.status(401).body(Map.of("msg", "로그인이 필요합니다."));
            }

            ApprovalNoticeFileDto fileDto = service.findFileById(fileId);
            if (fileDto == null) {
                return ResponseEntity.status(404).body(Map.of("msg", "파일을 찾을 수 없습니다"));
            }

            java.nio.file.Path filePath = java.nio.file.Paths.get(uploadPath, fileDto.getSaveFilename());
            org.springframework.core.io.Resource resource =
                    new org.springframework.core.io.UrlResource(filePath.toUri());

            if (!resource.exists()) {
                return ResponseEntity.status(404).body(Map.of("msg", "파일이 존재하지 않습니다"));
            }

            String encodedName = java.net.URLEncoder.encode(fileDto.getOriFilename(), "UTF-8")
                    .replaceAll("\\+", "%20");

            return ResponseEntity.ok()
                    .header("Content-Disposition", "attachment; filename*=UTF-8''" + encodedName)
                    .body(resource);
        } catch (Exception e) {
            log.info("downloadFile : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "다운로드에 실패했습니다."));
        }
    }

    @PostMapping("/file/{fileId}/delete")
    public ResponseEntity<String> deleteFile(@PathVariable("fileId") long fileId) {
        service.deleteFile(fileId);
        return ResponseEntity.ok("deleted");
    }
}
