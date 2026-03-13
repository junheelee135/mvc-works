package com.mvc.app.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.NoticeDto;
import com.mvc.app.domain.dto.NoticeFileDto;

public interface NoticeService {
    void insertNotice(NoticeDto dto, List<MultipartFile> files) throws Exception;
    void updateNotice(NoticeDto dto, List<MultipartFile> files, List<Long> deleteFileNums) throws Exception;
    void deleteNotice(long noticenum) throws Exception;
    Map<String, Object> listNotice(Map<String, Object> map) throws Exception;
    NoticeDto getNotice(long noticenum) throws Exception;           // 조회수 증가 포함
    List<NoticeFileDto> getFiles(long noticenum) throws Exception;
    NoticeFileDto getFile(long filenum) throws Exception;
    void deleteFile(long filenum) throws Exception;
}
