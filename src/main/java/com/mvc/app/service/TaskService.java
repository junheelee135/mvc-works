package com.mvc.app.service;

import java.util.List;
import java.util.Map;

import com.mvc.app.domain.dto.ProjectsDto;

public interface TaskService {
	//한건씩 처리
	public void insertProjectTask(ProjectsDto dto) throws Exception;
	
	public void updateProjectTask(ProjectsDto dto) throws Exception;
	public void cancelProjectTask(String taskId) throws Exception;
	
	
	List<ProjectsDto> findStagesByProjectId(long projectId) throws Exception;
	
	List<Map<String,Object>> findByEmpId(String empId) throws Exception;
	public List<ProjectsDto> tasklist(Map<String, Object> map);	
}
