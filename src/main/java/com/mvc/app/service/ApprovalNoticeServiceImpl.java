package com.mvc.app.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.common.StorageService;
import com.mvc.app.domain.dto.ApprovalNoticeDto;
import com.mvc.app.domain.dto.ApprovalNoticeFileDto;
import com.mvc.app.mapper.ApprovalNoticeMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ApprovalNoticeServiceImpl implements ApprovalNoticeService {
    private final ApprovalNoticeMapper mapper;
    private final StorageService storageService;

    @Value("${file.upload-root}/approval/notice")
    private String uploadPath;

    @Override
    public Map<String, Object> listNotice(Map<String, Object> map) {
        Map<String, Object> result = new HashMap<>();
        try {
            int totalCount = mapper.countNotice(map);
            List<ApprovalNoticeDto> list = mapper.listNotice(map);
            result.put("totalCount", totalCount);
            result.put("list", list);
        } catch (Exception e) {
            log.info("listNotice : ", e);
        }
        return result;
    }

    @Override
    public ApprovalNoticeDto findById(long noticeId) {
        try {
            mapper.updateHitCount(noticeId);
            ApprovalNoticeDto dto = mapper.findById(noticeId);
            if (dto != null) {
                dto.setFiles(mapper.listFilesByNoticeId(noticeId));
            }
            return dto;
        } catch (Exception e) {
            log.info("findById : ", e);
        }
        return null;
    }

    @Override
    @Transactional
    public void insertNotice(ApprovalNoticeDto dto, MultipartFile[] files) throws Exception {
        try {
            mapper.insertNotice(dto);
            saveFiles(dto.getNoticeId(), files);
        } catch (Exception e) {
            log.info("insertNotice : ", e);
            throw e;
        }
    }

    @Override
    @Transactional
    public void updateNotice(ApprovalNoticeDto dto, MultipartFile[] files) throws Exception {
        try {
            mapper.updateNotice(dto);
            saveFiles(dto.getNoticeId(), files);
        } catch (Exception e) {
            log.info("updateNotice : ", e);
            throw e;
        }
    }

    @Override
    @Transactional
    public void deleteNotice(long noticeId) throws Exception {
        try {
            mapper.deleteFilesByNoticeId(noticeId);
            mapper.deleteNotice(noticeId);
        } catch (Exception e) {
            log.info("deleteNotice : ", e);
            throw e;
        }
    }

    private void saveFiles(long noticeId, MultipartFile[] files) throws Exception {
        if (files == null) return;
        for (MultipartFile mf : files) {
            if (mf.isEmpty()) continue;
            String saveFilename = storageService.uploadFileToServer(mf, uploadPath);
            ApprovalNoticeFileDto fileDto = new ApprovalNoticeFileDto();
            fileDto.setNoticeId(noticeId);
            fileDto.setOriFilename(mf.getOriginalFilename());
            fileDto.setSaveFilename(saveFilename);
            fileDto.setFileSize(mf.getSize());
            mapper.insertFile(fileDto);
        }
    }
    
    @Override
    public ApprovalNoticeFileDto findFileById(long fileId) {
        return mapper.findFileById(fileId);
    }

    @Override
    public void deleteFile(long fileId) {
        mapper.deleteFile(fileId);
    }
}