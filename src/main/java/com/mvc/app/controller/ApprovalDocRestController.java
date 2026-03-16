package com.mvc.app.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.HashMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import com.mvc.app.domain.dto.ApprovalDocDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.ApprovalDocService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/approval/doc")
public class ApprovalDocRestController {
    private final ApprovalDocService service;

    // 임시저장
    @PostMapping
    public ResponseEntity<?> saveDraft(
            @RequestPart("data") ApprovalDocDto dto,
            @RequestPart(value = "files", required = false) MultipartFile[] files) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            dto.setWriterEmpId(info.getEmpId());
            dto.setWriterEmpName(info.getName());
            dto.setWriterDeptCode(info.getDeptCode());
            dto.setWriterDeptName(info.getDeptName());
            dto.setWriterGradeCode(info.getGradeCode());
            dto.setWriterGradeName(info.getGradeName());
        	
            log.info("★ deptCode={}, deptName={}, gradeCode={}, gradeName={}",
            	      info.getDeptCode(), info.getDeptName(), info.getGradeCode(), info.getGradeName());
            
            service.saveDraft(dto, files);
            return ResponseEntity.ok(Map.of("msg", "임시저장 완료"));
        } catch (Exception e) {
            log.info("saveDraft : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "임시저장에 실패했습니다."));
        }
    }
    
    @GetMapping
    public ResponseEntity<?> listDraft(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate", required = false) String endDate,
            @RequestParam(name = "sortField", required = false) String sortField,
            @RequestParam(name = "sortOrder", required = false) String sortOrder,
            @RequestParam(name = "statusFilter", required = false) String statusFilter,
            @RequestParam(name = "pageNo", defaultValue = "1") int pageNo,
            @RequestParam(name = "pageSize", defaultValue = "20") int pageSize) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("empId", info.getEmpId());
            map.put("keyword", keyword);
            map.put("startDate", startDate);
            map.put("endDate", endDate);
            map.put("sortField", sortField);
            map.put("sortOrder", sortOrder);
            map.put("statusFilter", statusFilter);
            map.put("pageSize", pageSize);
            map.put("offset", (pageNo - 1) * pageSize);

            Map<String, Object> result = service.listDraft(map);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.info("listDraft : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
        }
    }
    
    // 보낸 결재함
    @GetMapping("/sent")
    public ResponseEntity<?> listSent(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate", required = false) String endDate,
            @RequestParam(name = "sortField", required = false) String sortField,
            @RequestParam(name = "sortOrder", required = false) String sortOrder,
            @RequestParam(name = "statusFilter", required = false) String statusFilter,
            @RequestParam(name = "pageNo", defaultValue = "1") int pageNo,
            @RequestParam(name = "pageSize", defaultValue = "20") int pageSize) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("empId", info.getEmpId());
            map.put("keyword", keyword);
            map.put("startDate", startDate);
            map.put("endDate", endDate);
            map.put("sortField", sortField);
            map.put("sortOrder", sortOrder);
            map.put("statusFilter", statusFilter);
            map.put("pageSize", pageSize);
            map.put("offset", (pageNo - 1) * pageSize);
            return ResponseEntity.ok(service.listSent(map));
        } catch (Exception e) {
            log.info("listSent : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
        }
    }

    // 받은 결재함
    @GetMapping("/inbox")
    public ResponseEntity<?> listInbox(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate", required = false) String endDate,
            @RequestParam(name = "sortField", required = false) String sortField,
            @RequestParam(name = "sortOrder", required = false) String sortOrder,
            @RequestParam(name = "statusFilter", required = false) String statusFilter,
            @RequestParam(name = "pageNo", defaultValue = "1") int pageNo,
            @RequestParam(name = "pageSize", defaultValue = "20") int pageSize) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("empId", info.getEmpId());
            map.put("keyword", keyword);
            map.put("startDate", startDate);
            map.put("endDate", endDate);
            map.put("sortField", sortField);
            map.put("sortOrder", sortOrder);
            map.put("statusFilter", statusFilter);
            map.put("pageSize", pageSize);
            map.put("offset", (pageNo - 1) * pageSize);
            return ResponseEntity.ok(service.listInbox(map));
        } catch (Exception e) {
            log.info("listInbox : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
        }
    }
    
    @GetMapping("/ref")
    public ResponseEntity<?> listRef(
            @RequestParam(name = "keyword",   required = false) String keyword,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate",   required = false) String endDate,
            @RequestParam(name = "sortField", required = false) String sortField,
            @RequestParam(name = "sortOrder", required = false) String sortOrder,
            @RequestParam(name = "statusFilter", required = false) String statusFilter,
            @RequestParam(name = "pageNo",    defaultValue = "1")  int pageNo,
            @RequestParam(name = "pageSize",  defaultValue = "20") int pageSize) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("empId",     info.getEmpId());
            map.put("keyword",   keyword);
            map.put("startDate", startDate);
            map.put("endDate",   endDate);
            map.put("sortField", sortField);
            map.put("sortOrder", sortOrder);
            map.put("statusFilter", statusFilter);
            map.put("pageSize",  pageSize);
            map.put("offset",    (pageNo - 1) * pageSize);
            return ResponseEntity.ok(service.listRef(map));
        } catch (Exception e) {
            log.info("listRef : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
        }
    }

    @GetMapping("/all")
    public ResponseEntity<?> listAll(
            @RequestParam(name = "keyword",   required = false) String keyword,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate",   required = false) String endDate,
            @RequestParam(name = "sortField", required = false) String sortField,
            @RequestParam(name = "sortOrder", required = false) String sortOrder,
            @RequestParam(name = "statusFilter", required = false) String statusFilter,
            @RequestParam(name = "pageNo",    defaultValue = "1")  int pageNo,
            @RequestParam(name = "pageSize",  defaultValue = "20") int pageSize) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("empId",     info.getEmpId());
            map.put("keyword",   keyword);
            map.put("startDate", startDate);
            map.put("endDate",   endDate);
            map.put("sortField", sortField);
            map.put("sortOrder", sortOrder);
            map.put("statusFilter", statusFilter);
            map.put("pageSize",  pageSize);
            map.put("offset",    (pageNo - 1) * pageSize);
            return ResponseEntity.ok(service.listAll(map));
        } catch (Exception e) {
            log.info("listAll : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
        }
    }
    
 // 문서 상세 조회
    @GetMapping("/{docId}")
    public ResponseEntity<?> getDoc(@PathVariable("docId") long docId) {
        try {
            ApprovalDocDto doc = service.getDoc(docId);
            if (doc == null) return ResponseEntity.notFound().build();
            return ResponseEntity.ok(doc);
        } catch (Exception e) {
            log.info("getDoc : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "문서 조회에 실패했습니다."));
        }
    }

    // 결재취소
    @PostMapping("/{docId}/cancel")
    public ResponseEntity<?> cancelDoc(@PathVariable("docId") long docId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            boolean ok = service.cancelDoc(docId, info.getEmpId());
            if (ok) {
                return ResponseEntity.ok(Map.of("msg", "결재가 취소되었습니다."));
            } else {
                return ResponseEntity.badRequest().body(Map.of("msg", "취소할 수 없는 문서입니다."));
            }
        } catch (Exception e) {
            log.info("cancelDoc : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "취소 처리에 실패했습니다."));
        }
    }

    // 승인
    @PostMapping("/{docId}/approve")
    public ResponseEntity<?> approveDoc(
            @PathVariable("docId") long docId,
            @RequestBody Map<String, String> body) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            boolean ok = service.approveDoc(docId, info.getEmpId(), info.getName(), body.get("comment"));
            if (ok) return ResponseEntity.ok(Map.of("msg", "승인되었습니다."));
            return ResponseEntity.badRequest().body(Map.of("msg", "승인 권한이 없거나 이미 처리된 문서입니다."));
        } catch (Exception e) {
            log.info("approveDoc : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "승인 처리에 실패했습니다."));
        }
    }

    // 반려
    @PostMapping("/{docId}/reject")
    public ResponseEntity<?> rejectDoc(
            @PathVariable("docId") long docId,
            @RequestBody Map<String, String> body) {
        try {
            String comment = body.get("comment");
            if (comment == null || comment.isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("msg", "반려 사유를 입력해주세요."));
            }
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            boolean ok = service.rejectDoc(docId, info.getEmpId(), info.getName(), comment);
            if (ok) return ResponseEntity.ok(Map.of("msg", "반려되었습니다."));
            return ResponseEntity.badRequest().body(Map.of("msg", "반려 권한이 없거나 이미 처리된 문서입니다."));
        } catch (Exception e) {
            log.info("rejectDoc : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "반려 처리에 실패했습니다."));
        }
    }

    // 보류
    @PostMapping("/{docId}/hold")
    public ResponseEntity<?> holdDoc(
            @PathVariable("docId") long docId,
            @RequestBody Map<String, String> body) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            boolean ok = service.holdDoc(docId, info.getEmpId(), info.getName(), body.get("comment"));
            if (ok) return ResponseEntity.ok(Map.of("msg", "보류 처리되었습니다."));
            return ResponseEntity.badRequest().body(Map.of("msg", "보류 권한이 없거나 이미 처리된 문서입니다."));
        } catch (Exception e) {
            log.info("holdDoc : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "보류 처리에 실패했습니다."));
        }
    }

    // 참조자 코멘트
    @PostMapping("/{docId}/ref-comment")
    public ResponseEntity<?> refComment(
            @PathVariable("docId") long docId,
            @RequestBody Map<String, String> body) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            boolean ok = service.updateRefComment(docId, info.getEmpId(), body.get("comment"));
            if (ok) return ResponseEntity.ok(Map.of("msg", "의견이 등록되었습니다."));
            return ResponseEntity.badRequest().body(Map.of("msg", "참조자가 아닙니다."));
        } catch (Exception e) {
            log.info("refComment : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "의견 등록에 실패했습니다."));
        }
    }

    // 미결재 문서
    @GetMapping("/inbox/pending")
    public ResponseEntity<?> listPendingInbox(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate", required = false) String endDate,
            @RequestParam(name = "sortField", required = false) String sortField,
            @RequestParam(name = "sortOrder", required = false) String sortOrder,
            @RequestParam(name = "statusFilter", required = false) String statusFilter,
            @RequestParam(name = "pageNo", defaultValue = "1") int pageNo,
            @RequestParam(name = "pageSize", defaultValue = "20") int pageSize) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("empId", info.getEmpId());
            map.put("keyword", keyword);
            map.put("startDate", startDate);
            map.put("endDate", endDate);
            map.put("sortField", sortField);
            map.put("sortOrder", sortOrder);
            map.put("statusFilter", statusFilter);
            map.put("pageSize", pageSize);
            map.put("offset", (pageNo - 1) * pageSize);
            return ResponseEntity.ok(service.listPendingInbox(map));
        } catch (Exception e) {
            log.info("listPendingInbox : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
        }
    }

    // 미확인 문서
    @GetMapping("/ref/unread")
    public ResponseEntity<?> listUnreadRef(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "startDate", required = false) String startDate,
            @RequestParam(name = "endDate", required = false) String endDate,
            @RequestParam(name = "sortField", required = false) String sortField,
            @RequestParam(name = "sortOrder", required = false) String sortOrder,
            @RequestParam(name = "statusFilter", required = false) String statusFilter,
            @RequestParam(name = "pageNo", defaultValue = "1") int pageNo,
            @RequestParam(name = "pageSize", defaultValue = "20") int pageSize) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("empId", info.getEmpId());
            map.put("keyword", keyword);
            map.put("startDate", startDate);
            map.put("endDate", endDate);
            map.put("sortField", sortField);
            map.put("sortOrder", sortOrder);
            map.put("statusFilter", statusFilter);
            map.put("pageSize", pageSize);
            map.put("offset", (pageNo - 1) * pageSize);
            return ResponseEntity.ok(service.listUnreadRef(map));
        } catch (Exception e) {
            log.info("listUnreadRef : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
        }
    }

    // 뱃지 카운트 (미결재 + 미확인)
    @GetMapping("/badge-counts")
    public ResponseEntity<?> badgeCounts() {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("empId", info.getEmpId());
            return ResponseEntity.ok(service.getBadgeCounts(map));
        } catch (Exception e) {
            log.info("badgeCounts : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "건수 조회에 실패했습니다."));
        }
    }

    // 대결 여부 확인
    @GetMapping("/{docId}/deputy-check")
    public ResponseEntity<?> deputyCheck(@PathVariable("docId") long docId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> result = service.checkDeputy(docId, info.getEmpId());
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            log.info("deputyCheck : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "대결 확인에 실패했습니다."));
        }
    }

    // 참조 읽음 처리
    @PostMapping("/{docId}/mark-read")
    public ResponseEntity<?> markRead(@PathVariable("docId") long docId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            service.markRefAsRead(docId, info.getEmpId());
            return ResponseEntity.ok(Map.of("msg", "읽음 처리 완료"));
        } catch (Exception e) {
            log.info("markRead : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "읽음 처리에 실패했습니다."));
        }
    }
}