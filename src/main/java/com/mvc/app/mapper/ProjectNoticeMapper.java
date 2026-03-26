package com.mvc.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.mvc.app.domain.dto.ProjectNoticeDto;
import com.mvc.app.domain.dto.ProjectNoticeFileDto;

@Mapper
public interface ProjectNoticeMapper {

	public void insertNotice(ProjectNoticeDto dto);

	public void updateNotice(ProjectNoticeDto dto);

	public void deleteNotice(@Param("noticenum") long noticenum);

	public void increaseHit(@Param("noticenum") long noticenum);

	public List<ProjectNoticeDto> listNotice(Map<String, Object> param);

	public int countNotice(Map<String, Object> param);

	public ProjectNoticeDto getNotice(@Param("noticenum") long noticenum);

	int isManager(@Param("empId") String empId, @Param("projectid") long projectid);

	public List<Map<String, Object>> getMyProjects(@Param("empId") String empId);

	public void insertFile(ProjectNoticeFileDto dto);

	public void deleteFile(@Param("filenum") long filenum);

	public List<ProjectNoticeFileDto> getFiles(@Param("noticenum") long noticenum);

	public ProjectNoticeFileDto getFile(@Param("filenum") long filenum);

	List<Map<String, Object>> getMyPmProjects(@Param("empId") String empId);
}