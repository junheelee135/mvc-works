package com.mvc.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mvc.app.domain.dto.ApprovalTemplateDto;
import com.mvc.app.domain.dto.ApprovalTemplateLineDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.ApprovalTemplateService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/approval/template")
public class ApprovalTemplateRestController {
    private final ApprovalTemplateService service;

    // 템플릿 저장
    @PostMapping
    public ResponseEntity<?> save(@RequestBody ApprovalTemplateDto dto) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            dto.setWriterEmpId(info.getEmpId());

            service.saveTemplate(dto);
            return ResponseEntity.ok(Map.of("msg", "템플릿 저장 완료"));
        } catch (Exception e) {
            log.info("save : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "템플릿 저장 실패"));
        }
    }

    // 내 템플릿 목록
    @GetMapping
    public ResponseEntity<?> list() {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            List<ApprovalTemplateDto> list = service.listTemplate(info.getEmpId());
            return ResponseEntity.ok(Map.of("list", list));
        } catch (Exception e) {
            log.info("list : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "목록 조회 실패"));
        }
    }

    // 템플릿 상세 (결재자 목록)
    @GetMapping("/{tempId}")
    public ResponseEntity<?> detail(@PathVariable("tempId") long tempId) {
        try {
            List<ApprovalTemplateLineDto> lines = service.listTemplateLine(tempId);
            return ResponseEntity.ok(Map.of("lines", lines));
        } catch (Exception e) {
            log.info("detail : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "상세 조회 실패"));
        }
    }

    // 템플릿 삭제
    @DeleteMapping("/{tempId}")
    public ResponseEntity<?> delete(@PathVariable("tempId") long tempId) {
        try {
            service.deleteTemplate(tempId);
            return ResponseEntity.ok(Map.of("msg", "템플릿 삭제 완료"));
        } catch (Exception e) {
            log.info("delete : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "템플릿 삭제 실패"));
        }
    }
}