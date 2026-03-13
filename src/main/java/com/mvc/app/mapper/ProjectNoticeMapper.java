package com.mvc.app.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import com.mvc.app.domain.dto.ProjectNoticeDto;
import com.mvc.app.domain.dto.ProjectNoticeFileDto;

@Mapper
public interface ProjectNoticeMapper {

    // 공지 CRUD
    void insertNotice(ProjectNoticeDto dto);
    void updateNotice(ProjectNoticeDto dto);
    void deleteNotice(long noticenum);
    void increaseHit(long noticenum);

    // 목록/조회
    List<ProjectNoticeDto> listNotice(Map<String, Object> param);
    int countNotice(Map<String, Object> param);
    ProjectNoticeDto getNotice(long noticenum);

    // 내 프로젝트 목록 (셀렉트박스용)
    List<Map<String, Object>> getMyProjects(String empId);

    // 파일
    void insertFile(ProjectNoticeFileDto dto);
    void deleteFile(long filenum);
    List<ProjectNoticeFileDto> getFiles(long noticenum);
    ProjectNoticeFileDto getFile(long filenum);
}
