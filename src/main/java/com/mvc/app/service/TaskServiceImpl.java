package com.mvc.app.service;

import java.rmi.server.ExportException;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.mvc.app.domain.dto.ProjectsDto;
import com.mvc.app.mapper.TaskMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class TaskServiceImpl implements TaskService{
	private final TaskMapper mapper;
	
	
	@Override
	public void insertProjectTask(ProjectsDto dto) throws ExportException {
		try {
			mapper.insertProjectTask(dto);
			if (dto.getEmpId() != null && !dto.getEmpId().isEmpty()) {
				mapper.insertEmpTask(dto);
			}
		} catch (Exception e) {
			log.info("insertProjectTask : ", e);
		}
	}
	

	@Override
	public void updateProjectTask(ProjectsDto dto) throws Exception {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void cancelProjectTask(String taskId) throws Exception {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<Map<String, Object>> findByEmpId(String empId) throws Exception {

		List<Map<String, Object>> list = null;

		try {
			list = mapper.findByEmpId(empId);
		} catch (Exception e) {
			log.info("findByEmpId : ", e);
			throw e;
		}

		return list;
	}
	
	@Override
	public List<ProjectsDto> tasklist(Map<String, Object> map) {
		List<ProjectsDto> list = null;
		
		try {
			list = mapper.tasklist(map);
		} catch (Exception e) {
			log.info("tasklist : ", e);
		}
		return list;
	}

	@Override
	public List<ProjectsDto> findStagesByProjectId(long projectId) throws Exception {
		List<ProjectsDto> list = null;
		
		try {
			list = mapper.findStagesByProjectId(projectId);
		} catch (Exception e) {
			log.info("findStagesByProjectId : ", e);
			throw e;
		}
		
		return list;
	}


}
