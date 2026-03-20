package com.mvc.app.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.context.ApplicationEventPublisher;

import com.mvc.app.common.StorageService;
import com.mvc.app.domain.dto.ApprovalDocDto;
import com.mvc.app.domain.dto.ApprovalFileDto;
import com.mvc.app.domain.dto.ApprovalLineDto;
import com.mvc.app.domain.dto.ApprovalRefDto;
import com.mvc.app.domain.dto.ApprovalDeputyDto;
import com.mvc.app.mapper.ApprovalDocMapper;
import com.mvc.app.mapper.ApprovalDeputyMapper;
import com.mvc.app.notification.event.NotificationEvent;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ApprovalDocServiceImpl implements ApprovalDocService {
    private final ApprovalDocMapper mapper;
    private final ApprovalDeputyMapper deputyMapper;
    private final StorageService storageService;
    private final ApplicationEventPublisher eventPublisher;

    @Value("${file.upload-root}/approval")
    private String uploadPath;
    
    @Override
    @Transactional
    public void saveDraft(ApprovalDocDto dto, MultipartFile[] files) throws Exception {
        try {
            // 1. 결재 저장
        	if (dto.getDocStatus() == null || dto.getDocStatus().isBlank()) {
        	    dto.setDocStatus("DRAFT");
        	}

            if (dto.getOldDocId() > 0) {
                // 편집 모드: 결재선/참조자/파일 삭제 후 재생성, 문서는 UPDATE
                mapper.deleteFiles(dto.getOldDocId());
                mapper.deleteRefs(dto.getOldDocId());
                mapper.deleteLines(dto.getOldDocId());
                dto.setDocId(dto.getOldDocId());
                mapper.updateDoc(dto);
            } else {
                mapper.insertDoc(dto);
            }

            // 2. 결재선 저장
            if (dto.getLines() != null) {
                int order = 1;
                for (ApprovalLineDto line : dto.getLines()) {
                    line.setDocId(dto.getDocId());
                    line.setStepOrder(order++);
                    mapper.insertLine(line);
                }
            }

            // 3. 참조자 저장
            if (dto.getRefs() != null) {
                for (ApprovalRefDto ref : dto.getRefs()) {
                    ref.setDocId(dto.getDocId());
                    mapper.insertRef(ref);
                }
            }

            // 4. 첨부파일 저장
            if (files != null) {
                for (MultipartFile file : files) {
                    if (file.isEmpty()) continue;
                    String saveFilename = storageService.uploadFileToServer(file, uploadPath);
                    ApprovalFileDto fileDto = new ApprovalFileDto();
                    fileDto.setDocId(dto.getDocId());
                    fileDto.setOriFilename(file.getOriginalFilename());
                    fileDto.setSaveFilename(saveFilename);
                    fileDto.setFileSize(file.getSize());
                    mapper.insertFile(fileDto);
                }
            }
            
            // 5. 상신알림
            if ("PENDING".equals(dto.getDocStatus()) && dto.getLines() != null && !dto.getLines().isEmpty()) {
                String firstApprover = dto.getLines().get(0).getApprEmpId();
                pushAlarm(firstApprover, dto.getWriterEmpId(), dto.getWriterEmpName(), dto.getDocId(), dto.getTitle(), "SUBMIT");
                pushAlarm(dto.getWriterEmpId(), dto.getWriterEmpId(), dto.getWriterEmpName(), dto.getDocId(), dto.getTitle(), "SUBMIT");
                // 참조자 알림
                if (dto.getRefs() != null) {
                    for (ApprovalRefDto ref : dto.getRefs()) {
                        pushAlarm(ref.getRefEmpId(), dto.getWriterEmpId(), dto.getWriterEmpName(), dto.getDocId(), dto.getTitle(), "REF");
                    }
                }
            }         
        } catch (Exception e) {
            log.error("saveDraft : ", e);
            throw e;
        }
    }
    
    @Override
    public Map<String, Object> listDraft(Map<String, Object> map) throws Exception {
        int totalCount = mapper.countDraft(map);
        List<ApprovalDocDto> list = mapper.listDraft(map);
        return Map.of("totalCount", totalCount, "list", list);
    }
    
    @Override
    public Map<String, Object> listSent(Map<String, Object> map) throws Exception {
        int totalCount = mapper.countSent(map);
        List<ApprovalDocDto> list = mapper.listSent(map);
        return Map.of("totalCount", totalCount, "list", list);
    }

    @Override
    public Map<String, Object> listInbox(Map<String, Object> map) throws Exception {
        int totalCount = mapper.countInbox(map);
        List<ApprovalDocDto> list = mapper.listInbox(map);
        return Map.of("totalCount", totalCount, "list", list);
    }
    
    @Override
    public Map<String, Object> listRef(Map<String, Object> map) throws Exception {
        int totalCount = mapper.countRef(map);
        List<ApprovalDocDto> list = mapper.listRef(map);
        return Map.of("totalCount", totalCount, "list", list);
    }

    @Override
    public Map<String, Object> listAll(Map<String, Object> map) throws Exception {
        int totalCount = mapper.countAll(map);
        List<ApprovalDocDto> list = mapper.listAll(map);
        return Map.of("totalCount", totalCount, "list", list);
    }
    
    @Override
    public ApprovalDocDto getDoc(long docId) throws Exception {
        ApprovalDocDto doc = mapper.getDoc(docId);
        if (doc != null) {
            doc.setLines(mapper.getLines(docId));
            doc.setFiles(mapper.getFiles(docId));
            doc.setRefs(mapper.getRefs(docId));
        }
        return doc;
    }

    @Override
    public boolean cancelDoc(long docId, String empId) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("docId", docId);
        map.put("empId", empId);
        int cnt = mapper.cancelDoc(map);
        return cnt > 0;
    }
    
    @Override
    @Transactional
    public boolean approveDoc(long docId, String empId, String empName, String comment) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("docId", docId);
        map.put("empId", empId);
        map.put("empName", empName);
        map.put("comment", comment);

        int cnt = mapper.approveDoc(map);
        if (cnt == 0) {
            // 원결재자가 아님 → 대결자인지 확인
            cnt = mapper.approveDocAsDeputy(map);
            if (cnt == 0) return false;
        }

        // 남은 WAIT가 0이면 최종 승인, 아니면 PENDING 복원 (ON_HOLD → PENDING)
        int remaining = mapper.countRemainingWait(docId);
        if (remaining == 0) {
            mapper.completeDoc(docId);
        } else {
            mapper.resumeDocStatus(docId);
        }
        
        ApprovalDocDto doc = mapper.getDoc(docId);
        
        // 승인 알림
        if (remaining == 0) {
        	pushAlarm(doc.getWriterEmpId(), empId, empName, docId, doc.getTitle(), "APPROVE_FINAL");
        } else {
            String nextApprover = mapper.getCurrentWaitApprover(docId);
            if (nextApprover != null) {
                pushAlarm(nextApprover, empId, empName, docId, doc.getTitle(), "APPROVE_NEXT");
            }
            pushAlarm(doc.getWriterEmpId(), empId, empName, docId, doc.getTitle(), "APPROVE");
        }       
        
        return true;
    }

    @Override
    @Transactional
    public boolean rejectDoc(long docId, String empId, String empName, String comment) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("docId", docId);
        map.put("empId", empId);
        map.put("empName", empName);
        map.put("comment", comment);

        int cnt = mapper.rejectDoc(map);
        if (cnt == 0) {
            cnt = mapper.rejectDocAsDeputy(map);
            if (cnt == 0) return false;
        }

        mapper.rejectDocStatus(docId);
        
        // 반려 알림
        ApprovalDocDto doc = mapper.getDoc(docId);
        List<ApprovalLineDto> lines = mapper.getLines(docId);
        pushAlarm(doc.getWriterEmpId(), empId, empName, docId, doc.getTitle(), "REJECT");
        for (ApprovalLineDto line : lines) {
            if ("APPROVED".equals(line.getApprStatus())) {
                pushAlarm(line.getApprEmpId(), empId, empName, docId, doc.getTitle(), "REJECT");
            }
        }        
        
        return true;
    }

    @Override
    @Transactional
    public boolean holdDoc(long docId, String empId, String empName, String comment) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("docId", docId);
        map.put("empId", empId);
        map.put("empName", empName);
        map.put("comment", comment);

        int cnt = mapper.holdDoc(map);
        if (cnt == 0) {
            cnt = mapper.holdDocAsDeputy(map);
            if (cnt == 0) return false;
        }

        mapper.holdDocStatus(docId);
        
        // 보류 알림
        ApprovalDocDto doc = mapper.getDoc(docId);
        List<ApprovalLineDto> lines = mapper.getLines(docId);
        pushAlarm(doc.getWriterEmpId(), empId, empName, docId, doc.getTitle(), "HOLD");
        for (ApprovalLineDto line : lines) {
            if ("APPROVED".equals(line.getApprStatus())) {
                pushAlarm(line.getApprEmpId(), empId, empName, docId, doc.getTitle(), "HOLD");
            }
        }
        
        return true;
    }

    @Override
    public boolean updateRefComment(long docId, String empId, String comment) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("docId", docId);
        map.put("empId", empId);
        map.put("comment", comment);
        return mapper.updateRefComment(map) > 0;
    }

    @Override
    public Map<String, Object> listPendingInbox(Map<String, Object> map) throws Exception {
        int totalCount = mapper.countPendingInbox(map);
        List<ApprovalDocDto> list = mapper.listPendingInbox(map);
        return Map.of("totalCount", totalCount, "list", list);
    }

    @Override
    public Map<String, Object> listUnreadRef(Map<String, Object> map) throws Exception {
        int totalCount = mapper.countUnreadRef(map);
        List<ApprovalDocDto> list = mapper.listUnreadRef(map);
        return Map.of("totalCount", totalCount, "list", list);
    }

    @Override
    public Map<String, Object> getBadgeCounts(Map<String, Object> map) throws Exception {
        int pendingCount = mapper.countPendingInbox(map);
        int unreadCount = mapper.countUnreadRef(map);
        return Map.of("pendingCount", pendingCount, "unreadCount", unreadCount);
    }

    @Override
    public boolean markRefAsRead(long docId, String empId) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("docId", docId);
        map.put("empId", empId);
        return mapper.markRefAsRead(map) > 0;
    }

    @Override
    public Map<String, Object> checkDeputy(long docId, String empId) throws Exception {
        // 현재 WAIT 순서의 원결재자 조회
        String originalApprover = mapper.getCurrentWaitApprover(docId);
        if (originalApprover == null) {
            return Map.of("isDeputy", false);
        }
        // 원결재자가 본인이면 대결 아님
        if (originalApprover.equals(empId)) {
            return Map.of("isDeputy", false);
        }
        // 원결재자의 활성 대결자 조회
        ApprovalDeputyDto deputy = deputyMapper.findActiveDeputy(originalApprover);
        if (deputy != null && empId.equals(deputy.getDeputyEmpId())) {
            // 원결재자 이름 조회
            List<ApprovalLineDto> lines = mapper.getLines(docId);
            String originalName = lines.stream()
                .filter(l -> l.getApprEmpId().equals(originalApprover))
                .map(ApprovalLineDto::getApprEmpName)
                .findFirst().orElse("");
            Map<String, Object> result = new HashMap<>();
            result.put("isDeputy", true);
            result.put("originalApproverName", originalName);
            return result;
        }
        return Map.of("isDeputy", false);
    }
    
    private void pushAlarm(String receiverId, String senderId, String senderName, long docId, String docTitle, String actionType)
    {
        eventPublisher.publishEvent(
            new NotificationEvent.Approval(receiverId, senderId, senderName, docId, docTitle, actionType)
        );
        try {
            ApprovalDeputyDto deputy = deputyMapper.findActiveDeputy(receiverId);
            if (deputy != null) {
                eventPublisher.publishEvent(
                    new NotificationEvent.Approval(deputy.getDeputyEmpId(), senderId, senderName, docId, docTitle, actionType)
                );
            }
        } catch (Exception e) {
            log.error("대결자 알림 조회 실패: ", e);
        }
    } 
}