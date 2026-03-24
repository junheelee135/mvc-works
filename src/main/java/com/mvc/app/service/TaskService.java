package com.mvc.app.service;

import java.util.List;
import java.util.Map;

import org.springframework.data.repository.query.Param;

import com.mvc.app.domain.dto.ProjectsDto;

public interface TaskService {
	//한건씩 처리
	public void insertProjectTask(ProjectsDto dto) throws Exception;
	
	public void updateProjectTask(ProjectsDto dto) throws Exception;

	List<ProjectsDto> findStagesByProjectId(long projectId) throws Exception;
	
	List<Map<String,Object>> findByEmpId(String empId) throws Exception;
	public List<ProjectsDto> tasklist(Map<String, Object> map);
	
	public int taskDataCount(Map<String, Object> map) throws Exception;
	
	public void insertTaskDailylog(ProjectsDto dto) throws Exception;
	public List<ProjectsDto> taskDailylist(@Param("empTaskId") String empTaskId) throws Exception;

	List<ProjectsDto> myProjectslist(Map<String, Object> map) throws Exception;
	int myDataCount(Map<String, Object> map) throws Exception;
	
	public void taskAutoDelay() throws Exception;
	public void projectAutoComplete(long projectId) throws Exception;
	
	public void taskForceStopByProject(long projectId) throws Exception;
	
	public String findEmpTaskId(String taskId) throws Exception;
	public List<ProjectsDto> myTasklist(Map<String, Object> map) throws Exception;
	public int myTaskDataCount(Map<String, Object> map) throws Exception;

}
