package com.mvc.app.service;

import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.ApprovalNoticeDto;
import com.mvc.app.domain.dto.ApprovalNoticeFileDto;

public interface ApprovalNoticeService {

    public Map<String, Object> listNotice(Map<String, Object> map);
    public ApprovalNoticeDto findById(long noticeId);
    public void insertNotice(ApprovalNoticeDto dto, MultipartFile[] files) throws Exception;
    public void updateNotice(ApprovalNoticeDto dto, MultipartFile[] files) throws Exception;
    public void deleteNotice(long noticeId) throws Exception;
    public ApprovalNoticeFileDto findFileById(long fileId);
    public void deleteFile(long fileId);
}