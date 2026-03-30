package com.mvc.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.mvc.app.domain.dto.ProjectNoticeDto;
import com.mvc.app.domain.dto.ProjectNoticeFileDto;

@Mapper
public interface ProjectNoticeMapper {

    void insertNotice(ProjectNoticeDto dto);

    void updateNotice(ProjectNoticeDto dto);

    void deleteNotice(@Param("projectNoticeNum") long projectNoticeNum);

    void increaseHit(@Param("projectNoticeNum") long projectNoticeNum);

    List<ProjectNoticeDto> listNotice(Map<String, Object> param);

    int countNotice(Map<String, Object> param);

    ProjectNoticeDto getNotice(@Param("projectNoticeNum") long projectNoticeNum);

    int isManager(@Param("empId") String empId, @Param("projectid") long projectid);

    List<Map<String, Object>> getMyProjects(@Param("empId") String empId);

    List<Map<String, Object>> getMyPmProjects(@Param("empId") String empId);

    void insertFile(ProjectNoticeFileDto dto);

    void deleteFile(@Param("filenum") long filenum);

    List<ProjectNoticeFileDto> getFiles(@Param("projectNoticeNum") long projectNoticeNum);

    ProjectNoticeFileDto getFile(@Param("filenum") long filenum);
}