package com.mvc.app.mapper;

import java.sql.SQLException;

import org.apache.ibatis.annotations.Mapper;

import com.mvc.app.domain.dto.ApprovalDocDto;
import com.mvc.app.domain.dto.ApprovalFileDto;
import com.mvc.app.domain.dto.ApprovalLineDto;
import com.mvc.app.domain.dto.ApprovalRefDto;
import java.util.List;
import java.util.Map;

@Mapper
public interface ApprovalDocMapper {
    public void insertDoc(ApprovalDocDto dto) throws SQLException;
    public void updateDoc(ApprovalDocDto dto) throws SQLException;
    public void insertLine(ApprovalLineDto dto) throws SQLException;
    public void insertRef(ApprovalRefDto dto) throws SQLException;
    public void insertFile(ApprovalFileDto dto) throws SQLException;
    public List<ApprovalDocDto> listDraft(Map<String, Object> map) throws SQLException;
    public int countDraft(Map<String, Object> map) throws SQLException;
    public List<ApprovalDocDto> listSent(Map<String, Object> map) throws SQLException;
    public int countSent(Map<String, Object> map) throws SQLException;
    public List<ApprovalDocDto> listInbox(Map<String, Object> map) throws SQLException;
    public int countInbox(Map<String, Object> map) throws SQLException;
    public List<ApprovalDocDto> listRef(Map<String, Object> map) throws SQLException;
    public int countRef(Map<String, Object> map) throws SQLException;
    public List<ApprovalDocDto> listAll(Map<String, Object> map) throws SQLException;
    public int countAll(Map<String, Object> map) throws SQLException;
    public ApprovalDocDto getDoc(long docId) throws SQLException;
    public List<ApprovalLineDto> getLines(long docId) throws SQLException;
    public List<ApprovalFileDto> getFiles(long docId) throws SQLException;
    public List<ApprovalRefDto> getRefs(long docId) throws SQLException;
    public void deleteFiles(long docId) throws SQLException;
    public void deleteRefs(long docId) throws SQLException;
    public void deleteLines(long docId) throws SQLException;
    public void deleteDoc(long docId) throws SQLException;
    public int cancelDoc(Map<String, Object> map) throws SQLException;
    
    // 승인
    public int approveDoc(Map<String, Object> map) throws SQLException;
    public int countRemainingWait(long docId) throws SQLException;
    public void completeDoc(long docId) throws SQLException;

    // 반려
    public int rejectDoc(Map<String, Object> map) throws SQLException;
    public void rejectDocStatus(long docId) throws SQLException;

    // 보류
    public int holdDoc(Map<String, Object> map) throws SQLException;
    public void holdDocStatus(long docId) throws SQLException;

    // 참조자 코멘트
    public int updateRefComment(Map<String, Object> map) throws SQLException;

    // 미결재 문서
    public List<ApprovalDocDto> listPendingInbox(Map<String, Object> map) throws SQLException;
    public int countPendingInbox(Map<String, Object> map) throws SQLException;

    // 미확인 문서
    public List<ApprovalDocDto> listUnreadRef(Map<String, Object> map) throws SQLException;
    public int countUnreadRef(Map<String, Object> map) throws SQLException;

    // 참조 읽음 처리
    public int markRefAsRead(Map<String, Object> map) throws SQLException;

    // 대결 처리
    public int approveDocAsDeputy(Map<String, Object> map) throws SQLException;
    public int rejectDocAsDeputy(Map<String, Object> map) throws SQLException;
    public int holdDocAsDeputy(Map<String, Object> map) throws SQLException;
    public String getCurrentWaitApprover(long docId) throws SQLException;
}