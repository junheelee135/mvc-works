package com.mvc.app.service;

import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.ApprovalDocDto;

public interface ApprovalDocService {
	public void saveDraft(ApprovalDocDto dto, MultipartFile[] files) throws Exception;
	public Map<String, Object> listDraft(Map<String, Object> map) throws Exception;
	public Map<String, Object> listSent(Map<String, Object> map) throws Exception;
	public Map<String, Object> listInbox(Map<String, Object> map) throws Exception;
	public Map<String, Object> listRef(Map<String, Object> map) throws Exception;
    public Map<String, Object> listAll(Map<String, Object> map) throws Exception;
    public ApprovalDocDto getDoc(long docId) throws Exception;
    public boolean cancelDoc(long docId, String empId) throws Exception;

    public boolean approveDoc(long docId, String empId, String empName, String comment) throws Exception;
    public boolean rejectDoc(long docId, String empId, String empName, String comment) throws Exception;
    public boolean holdDoc(long docId, String empId, String empName, String comment) throws Exception;
    public boolean updateRefComment(long docId, String empId, String comment) throws Exception;

    public Map<String, Object> listPendingInbox(Map<String, Object> map) throws Exception;
    public Map<String, Object> listUnreadRef(Map<String, Object> map) throws Exception;
    public Map<String, Object> getBadgeCounts(Map<String, Object> map) throws Exception;
    public boolean markRefAsRead(long docId, String empId) throws Exception;
    public Map<String, Object> checkDeputy(long docId, String empId) throws Exception;
}
