package com.mvc.app.service;

import java.util.List;
import java.util.Map;
import org.springframework.web.multipart.MultipartFile;
import com.mvc.app.domain.dto.ProjectNoticeDto;
import com.mvc.app.domain.dto.ProjectNoticeFileDto;

public interface ProjectNoticeService {
    void insertNotice(ProjectNoticeDto dto, List<MultipartFile> files) throws Exception;
    void updateNotice(ProjectNoticeDto dto, List<MultipartFile> files) throws Exception;
    void deleteNotice(long noticenum) throws Exception;

    List<ProjectNoticeDto> listNotice(Map<String, Object> param);
    int countNotice(Map<String, Object> param);
    ProjectNoticeDto getNotice(long noticenum);

    List<Map<String, Object>> getMyProjects(String empId);

    void deleteFile(long filenum) throws Exception;
    ProjectNoticeFileDto getFile(long filenum);
}
