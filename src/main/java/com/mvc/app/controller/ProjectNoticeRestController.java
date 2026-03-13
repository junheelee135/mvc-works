package com.mvc.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.ProjectNoticeDto;
import com.mvc.app.domain.dto.ProjectNoticeFileDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.service.ProjectNoticeService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Value;

import java.io.File;
import java.net.URLEncoder;

@Slf4j
@RestController
@RequestMapping("/api/projectnotice")
@RequiredArgsConstructor
public class ProjectNoticeRestController {

    private final ProjectNoticeService service;

    @Value("${file.upload-root}")
    private String uploadRoot;

    // ── 내 프로젝트 목록 (셀렉트박스) ──────────────────────────
    @GetMapping("/myprojects")
    public ResponseEntity<?> myProjects(HttpSession session) {
        SessionInfo info = (SessionInfo) session.getAttribute("sessionInfo");
        if (info == null) return ResponseEntity.status(401).body("로그인 필요");

        List<Map<String, Object>> projects = service.getMyProjects(info.getEmpId());
        return ResponseEntity.ok(projects);
    }

    // ── 목록 ──────────────────────────────────────────────────
    @GetMapping("/list")
    public ResponseEntity<?> list(@RequestParam String projectid,
                                  @RequestParam(defaultValue = "1") int page,
                                  @RequestParam(defaultValue = "") String keyword,
                                  HttpSession session) {
        SessionInfo info = (SessionInfo) session.getAttribute("sessionInfo");
        if (info == null) return ResponseEntity.status(401).body("로그인 필요");

        int pageSize = 10;
        int offset   = (page - 1) * pageSize;

        Map<String, Object> param = new HashMap<>();
        param.put("projectid", projectid);
        param.put("keyword",   keyword);
        param.put("offset",    offset);
        param.put("pageSize",  pageSize);

        List<ProjectNoticeDto> list  = service.listNotice(param);
        int total                    = service.countNotice(param);

        // 해당 프로젝트에서 내 role 확인
        List<Map<String, Object>> myProjects = service.getMyProjects(info.getEmpId());
        boolean isManager = myProjects.stream()
            .anyMatch(p -> projectid.equals(p.get("PROJECTID")) && "m".equals(p.get("ROLE")));

        Map<String, Object> result = new HashMap<>();
        result.put("list",      list);
        result.put("total",     total);
        result.put("page",      page);
        result.put("pageSize",  pageSize);
        result.put("isManager", isManager);
        return ResponseEntity.ok(result);
    }

    // ── 단건 ──────────────────────────────────────────────────
    @GetMapping("/{noticenum}")
    public ResponseEntity<?> get(@PathVariable long noticenum, HttpSession session) {
        SessionInfo info = (SessionInfo) session.getAttribute("sessionInfo");
        if (info == null) return ResponseEntity.status(401).body("로그인 필요");

        ProjectNoticeDto dto = service.getNotice(noticenum);
        if (dto == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(dto);
    }

    // ── 등록 ──────────────────────────────────────────────────
    @PostMapping
    public ResponseEntity<?> insert(@RequestParam long projectid,
                                    @RequestParam String subject,
                                    @RequestParam String content,
                                    @RequestParam(defaultValue = "0") int isnotice,
                                    @RequestParam(required = false) List<MultipartFile> files,
                                    HttpSession session) {
        SessionInfo info = (SessionInfo) session.getAttribute("sessionInfo");
        if (info == null) return ResponseEntity.status(401).body("로그인 필요");
        if (!isManager(info, projectid)) return ResponseEntity.status(403).body("권한 없음");

        try {
            ProjectNoticeDto dto = new ProjectNoticeDto();
            dto.setProjectid(projectid);
            dto.setSubject(subject);
            dto.setContent(content);
            dto.setIsnotice(isnotice);
            dto.setAuthorempid(info.getEmpId());
            service.insertNotice(dto, files);
            return ResponseEntity.ok("등록 완료");
        } catch (Exception e) {
            log.error("insertNotice : ", e);
            return ResponseEntity.status(500).body("등록 실패");
        }
    }

    private boolean isManager(SessionInfo info, long projectid) {
		// TODO Auto-generated method stub
		return false;
	}

	// ── 수정 ──────────────────────────────────────────────────
    @PutMapping("/{noticenum}")
    public ResponseEntity<?> update(@PathVariable long noticenum,
                                    @RequestParam String projectid,
                                    @RequestParam String subject,
                                    @RequestParam String content,
                                    @RequestParam(defaultValue = "0") int isnotice,
                                    @RequestParam(required = false) List<MultipartFile> files,
                                    HttpSession session) {
        SessionInfo info = (SessionInfo) session.getAttribute("sessionInfo");
        if (info == null) return ResponseEntity.status(401).body("로그인 필요");
        if (!isManager(info, projectid)) return ResponseEntity.status(403).body("권한 없음");

        try {
            ProjectNoticeDto dto = new ProjectNoticeDto();
            dto.setNoticenum(noticenum);
            dto.setSubject(subject);
            dto.setContent(content);
            dto.setIsnotice(isnotice);
            service.updateNotice(dto, files);
            return ResponseEntity.ok("수정 완료");
        } catch (Exception e) {
            log.error("updateNotice : ", e);
            return ResponseEntity.status(500).body("수정 실패");
        }
    }

    // ── 삭제 ──────────────────────────────────────────────────
    @DeleteMapping("/{noticenum}")
    public ResponseEntity<?> delete(@PathVariable long noticenum,
                                    @RequestParam String projectid,
                                    HttpSession session) {
        SessionInfo info = (SessionInfo) session.getAttribute("sessionInfo");
        if (info == null) return ResponseEntity.status(401).body("로그인 필요");
        if (!isManager(info, projectid)) return ResponseEntity.status(403).body("권한 없음");

        try {
            service.deleteNotice(noticenum);
            return ResponseEntity.ok("삭제 완료");
        } catch (Exception e) {
            log.error("deleteNotice : ", e);
            return ResponseEntity.status(500).body("삭제 실패");
        }
    }

    // ── 파일 삭제 ──────────────────────────────────────────────
    @DeleteMapping("/file/{filenum}")
    public ResponseEntity<?> deleteFile(@PathVariable long filenum,
                                        @RequestParam String projectid,
                                        HttpSession session) {
        SessionInfo info = (SessionInfo) session.getAttribute("sessionInfo");
        if (info == null) return ResponseEntity.status(401).body("로그인 필요");
        if (!isManager(info, projectid)) return ResponseEntity.status(403).body("권한 없음");

        try {
            service.deleteFile(filenum);
            return ResponseEntity.ok("파일 삭제 완료");
        } catch (Exception e) {
            log.error("deleteFile : ", e);
            return ResponseEntity.status(500).body("파일 삭제 실패");
        }
    }

    // ── 파일 다운로드 ───────────────────────────────────────────
    @GetMapping("/download/{filenum}")
    public ResponseEntity<Resource> download(@PathVariable long filenum) throws Exception {
        ProjectNoticeFileDto file = service.getFile(filenum);
        if (file == null) return ResponseEntity.notFound().build();

        Resource resource = new FileSystemResource(uploadRoot + File.separator + file.getSavefilename());
        if (!resource.exists()) return ResponseEntity.notFound().build();

        String encoded = URLEncoder.encode(file.getOriginalfilename(), "UTF-8").replace("+", "%20");
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encoded)
                .body(resource);
    }

    // ── 매니저 여부 확인 (empProject role = 'm') ───────────────
    private boolean isManager(SessionInfo info, String projectid) {
        List<Map<String, Object>> myProjects = service.getMyProjects(info.getEmpId());
        return myProjects.stream()
            .anyMatch(p -> projectid.equals(p.get("PROJECTID")) && "m".equals(p.get("ROLE")));
    }
}
