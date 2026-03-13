package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import com.mvc.app.domain.dto.ApprovalNoticeDto;
import com.mvc.app.domain.dto.ApprovalNoticeFileDto;

@Mapper
public interface ApprovalNoticeMapper {

    public List<ApprovalNoticeDto> listNotice(Map<String, Object> map);
    public int countNotice(Map<String, Object> map);
    public ApprovalNoticeDto findById(long noticeId);
    public void updateHitCount(long noticeId) throws SQLException;
    public void insertNotice(ApprovalNoticeDto dto) throws SQLException;
    public void updateNotice(ApprovalNoticeDto dto) throws SQLException;
    public void deleteNotice(long noticeId) throws SQLException;
    
    public void insertFile(ApprovalNoticeFileDto dto);
    public List<ApprovalNoticeFileDto> listFilesByNoticeId(long noticeId);
    public void deleteFile(long fileId);
    public void deleteFilesByNoticeId(long noticeId);
    public ApprovalNoticeFileDto findFileById(long fileId);
}