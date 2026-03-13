package com.mvc.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mvc.app.domain.dto.DocTypeDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.DocTypeService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/approval/doctype")
public class DocTypeRestController {
    private final DocTypeService service;

    // 목록 조회
    @GetMapping
    public ResponseEntity<?> list() {
        try {
            List<DocTypeDto> list = service.listDocType();
            return ResponseEntity.ok(Map.of("list", list));
        } catch (Exception e) {
            log.info("list : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "목록 조회 실패"));
        }
    }

    // 등록
    @PostMapping
    public ResponseEntity<?> insert(@RequestBody DocTypeDto dto) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            dto.setRegEmpId(info.getEmpId());

            service.insertDocType(dto);
            return ResponseEntity.ok(Map.of("msg", "등록 완료"));
        } catch (Exception e) {
            log.info("insert : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "등록 실패"));
        }
    }

    // 수정
    @PutMapping("/{docTypeId}")
    public ResponseEntity<?> update(@PathVariable("docTypeId") long docTypeId,
                                    @RequestBody DocTypeDto dto) {
        try {
            dto.setDocTypeId(docTypeId);
            service.updateDocType(dto);
            return ResponseEntity.ok(Map.of("msg", "수정 완료"));
        } catch (Exception e) {
            log.info("update : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "수정 실패"));
        }
    }

    // 삭제
    @DeleteMapping("/{docTypeId}")
    public ResponseEntity<?> delete(@PathVariable("docTypeId") long docTypeId) {
        try {
            service.deleteDocType(docTypeId);
            return ResponseEntity.ok(Map.of("msg", "삭제 완료"));
        } catch (Exception e) {
            log.info("delete : ", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "삭제 실패"));
        }
    }
}