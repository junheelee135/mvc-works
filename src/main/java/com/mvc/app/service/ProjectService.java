package com.mvc.app.service;

import java.util.List;
import java.util.Map;

import com.mvc.app.domain.dto.ProjectsDto;

public interface ProjectService {
	// 프로젝트 생성
	public void createFullProject(ProjectsDto dto, List<Map<String, Object>> members, List<Map<String, Object>> stages)
			throws Exception;

	public List<ProjectsDto> projectslist(Map<String, Object> map) throws Exception;

	public int dataCount(Map<String, Object> map);

	public List<ProjectsDto> projectslist(String empId) throws Exception;

	public ProjectsDto projectarticle(long projectId) throws Exception;

	// 프로젝트 멤버
	public List<ProjectsDto> projectMembers(long projectId) throws Exception;

	// 프로젝트 조회
	public ProjectsDto findById(long projectId);

	public int myProjectsCount(Map<String, Object> map);

	public List<ProjectsDto> myProjectsList(Map<String, Object> map);

	public List<ProjectsDto> statusCount(Map<String, Object> map);

	public List<ProjectsDto> myProjectstatusCount(String empId);

	public void projectAutoStart() throws Exception;

	public void projectAutoDelay() throws Exception;

	public void projectForceStop(long projectId) throws Exception;

	public void changeMember(Map<String, Object> map) throws Exception;

	public void projectAutoCompleteAll() throws Exception;

	public void updateProjectDate(Map<String, Object> map) throws Exception;

	public List<Map<String, Object>> ManagerProjects(String empId);

	public boolean isProjectManager(long projectId, String empId);
}
