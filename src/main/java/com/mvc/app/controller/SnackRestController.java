package com.mvc.app.controller;

import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.domain.dto.SnackCommentDto;
import com.mvc.app.domain.dto.SnackDto;
import com.mvc.app.mapper.SnackMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.mvc.app.security.LoginMemberUtil;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/snack")
public class SnackRestController {

    private final SnackMapper mapper;

    private boolean isAdmin(SessionInfo info) {
        return info.getUserLevel() == 99;
    }

    // ── 목록 조회 ──
    @GetMapping("/list")
    public ResponseEntity<?> list(
            @RequestParam(name = "pageNo",   defaultValue = "1")  int pageNo,
            @RequestParam(name = "pageSize", defaultValue = "10") int pageSize,
            @RequestParam(name = "keyword",  defaultValue = "")   String keyword,
            @RequestParam(name = "status",   defaultValue = "")   String status) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("offset",   (pageNo - 1) * pageSize);
            map.put("pageSize", pageSize);
            map.put("keyword",  keyword.isBlank() ? null : keyword);
            map.put("status",   status.isBlank()  ? null : status);
            map.put("empId",    info.getEmpId());

            Map<String, Object> result = new HashMap<>();
            result.put("list",  mapper.listSnack(map));
            result.put("total", mapper.countSnack(map));
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.error("listSnack:", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회 실패"));
        }
    }

    // ── 단건 조회 ──
    @GetMapping("/{snackId}")
    public ResponseEntity<?> get(@PathVariable("snackId") long snackId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("snackId", snackId);
            map.put("empId",   info.getEmpId());
            SnackDto dto = mapper.getSnack(map);
            if (dto == null) return ResponseEntity.notFound().build();
            dto.setComments(mapper.listComment(snackId));
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            log.error("getSnack:", e);
            return ResponseEntity.internalServerError().body(Map.of("msg", "조회 실패"));
        }
    }

    // ── 신청 등록 ──
    @PostMapping
    public ResponseEntity<?> insert(@RequestBody SnackDto dto) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            dto.setRequesterEmpId(info.getEmpId());
            mapper.insertSnack(dto);
            return ResponseEntity.ok(Map.of("msg", "신청이 등록되었습니다."));
        } catch (Exception e) {
            log.error("insertSnack:", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "등록 실패"));
        }
    }

    // ── 상태 변경 (관리자: 승인/반려) ──
    @PutMapping("/{snackId}/status")
    public ResponseEntity<?> updateStatus(
            @PathVariable("snackId") long snackId,
            @RequestBody Map<String, String> body) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (!isAdmin(info)) return ResponseEntity.status(403).body(Map.of("msg", "권한 없음"));
            Map<String, Object> map = new HashMap<>();
            map.put("snackId",      snackId);
            map.put("status",       body.get("status"));
            map.put("adminComment", body.getOrDefault("adminComment", ""));
            mapper.updateSnackStatus(map);
            return ResponseEntity.ok(Map.of("msg", "처리되었습니다."));
        } catch (Exception e) {
            log.error("updateSnackStatus:", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "처리 실패"));
        }
    }

    // ── 삭제 (본인 또는 관리자) ──
    @DeleteMapping("/{snackId}")
    public ResponseEntity<?> delete(@PathVariable("snackId") long snackId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> param = new HashMap<>();
            param.put("snackId", snackId);
            param.put("empId",   info.getEmpId());
            SnackDto dto = mapper.getSnack(param);
            if (dto == null) return ResponseEntity.notFound().build();
            if (!isAdmin(info) && !dto.getRequesterEmpId().equals(info.getEmpId())) {
                return ResponseEntity.status(403).body(Map.of("msg", "권한 없음"));
            }
            mapper.deleteSnack(snackId);
            return ResponseEntity.ok(Map.of("msg", "삭제되었습니다."));
        } catch (Exception e) {
            log.error("deleteSnack:", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "삭제 실패"));
        }
    }

    // ── 공감 토글 ──
    @PostMapping("/{snackId}/vote")
    public ResponseEntity<?> vote(@PathVariable long snackId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("snackId", snackId);
            map.put("empId",   info.getEmpId());
            if (mapper.existsVote(map) > 0) {
                mapper.deleteVote(map);
            } else {
                mapper.insertVote(map);
            }
            return ResponseEntity.ok(Map.of("voteCount", mapper.countVote(snackId)));
        } catch (Exception e) {
            log.error("vote:", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "공감 처리 실패"));
        }
    }

    // ── 댓글 등록 ──
    @PostMapping("/{snackId}/comment")
    public ResponseEntity<?> insertComment(
            @PathVariable long snackId,
            @RequestBody Map<String, String> body) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            SnackCommentDto dto = new SnackCommentDto();
            dto.setSnackId(snackId);
            dto.setContent(body.get("content"));
            dto.setAuthorEmpId(info.getEmpId());
            mapper.insertComment(dto);
            return ResponseEntity.ok(Map.of("msg", "댓글이 등록되었습니다."));
        } catch (Exception e) {
            log.error("insertComment:", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "댓글 등록 실패"));
        }
    }

    // ── 댓글 삭제 ──
    @DeleteMapping("/comment/{commentId}")
    public ResponseEntity<?> deleteComment(@PathVariable long commentId) {
        try {
            mapper.deleteComment(commentId);
            return ResponseEntity.ok(Map.of("msg", "댓글이 삭제되었습니다."));
        } catch (Exception e) {
            log.error("deleteComment:", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "댓글 삭제 실패"));
        }
    }
}
