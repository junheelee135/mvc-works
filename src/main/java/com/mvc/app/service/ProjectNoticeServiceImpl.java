package com.mvc.app.service;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.ProjectNoticeDto;
import com.mvc.app.domain.dto.ProjectNoticeFileDto;
import com.mvc.app.mapper.ProjectNoticeMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProjectNoticeServiceImpl implements ProjectNoticeService {

    private final ProjectNoticeMapper mapper;

    @Value("${file.upload-root}")
    private String uploadRoot;

    @Override
    @Transactional
    public void insertNotice(ProjectNoticeDto dto, List<MultipartFile> files) throws Exception {
        mapper.insertNotice(dto);
        saveFiles(files, dto.getNoticenum());
    }

    @Override
    @Transactional
    public void updateNotice(ProjectNoticeDto dto, List<MultipartFile> files) throws Exception {
        mapper.updateNotice(dto);
        saveFiles(files, dto.getNoticenum());
    }

    @Override
    @Transactional
    public void deleteNotice(long noticenum) throws Exception {
        mapper.deleteNotice(noticenum);
    }

    @Override
    public List<ProjectNoticeDto> listNotice(Map<String, Object> param) {
        return mapper.listNotice(param);
    }

    @Override
    public int countNotice(Map<String, Object> param) {
        return mapper.countNotice(param);
    }

    @Override
    public ProjectNoticeDto getNotice(long noticenum) {
        mapper.increaseHit(noticenum);
        ProjectNoticeDto dto = mapper.getNotice(noticenum);
        if (dto != null) {
            dto.setFiles(mapper.getFiles(noticenum));
        }
        return dto;
    }

    @Override
    public List<Map<String, Object>> getMyProjects(String empId) {
        return mapper.getMyProjects(empId);
    }

    @Override
    @Transactional
    public void deleteFile(long filenum) throws Exception {
        ProjectNoticeFileDto file = mapper.getFile(filenum);
        if (file != null) {
            File f = new File(uploadRoot + File.separator + file.getSavefilename());
            if (f.exists()) f.delete();
            mapper.deleteFile(filenum);
        }
    }

    @Override
    public ProjectNoticeFileDto getFile(long filenum) {
        return mapper.getFile(filenum);
    }

    // ── 파일 저장 헬퍼 ──
    private void saveFiles(List<MultipartFile> files, long noticenum) throws Exception {
        if (files == null || files.isEmpty()) return;
        File dir = new File(uploadRoot);
        if (!dir.exists()) dir.mkdirs();

        for (MultipartFile mf : files) {
            if (mf.isEmpty()) continue;
            String saveName = UUID.randomUUID().toString().replace("-", "") + "_" + mf.getOriginalFilename();
            File dest = new File(uploadRoot + File.separator + saveName);
            mf.transferTo(dest);

            ProjectNoticeFileDto fDto = new ProjectNoticeFileDto();
            fDto.setSavefilename(saveName);
            fDto.setOriginalfilename(mf.getOriginalFilename());
            fDto.setFilesize(mf.getSize());
            fDto.setNoticenum(noticenum);
            mapper.insertFile(fDto);
        }
    }
}
