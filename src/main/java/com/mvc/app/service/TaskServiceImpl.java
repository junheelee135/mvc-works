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
		// task 생성
		try {
			if(dto.getStageId() == null && dto.getStgTitle() != null && !dto.getStgTitle().isEmpty()) {
				mapper.insertNewStage(dto);				
			}
			
			mapper.insertProjectTask(dto);
			
			if (dto.getEmpId() != null && !dto.getEmpId().isEmpty()) {
				mapper.insertEmpTask(dto);
			}
			mapper.taskUpdateStatus(dto.getTaskId());
			mapper.projectUpdateProgress(dto.getProjectId());
			
		} catch (Exception e) {
			log.info("insertProjectTask : ", e);
		}
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

	@Override
	public void updateProjectTask(ProjectsDto dto) throws Exception {
		try {
			mapper.updateProjectTask(dto);
			
			if(dto.getEmpId() != null && !dto.getEmpId().isEmpty()) {
				int count = mapper.countEmpTask(dto.getTaskId());
				
	            if(count > 0) {
	                mapper.updateProjectEmp(dto); 
	            } else {
	                mapper.insertEmpTask(dto);
	            }
			}	
			
			mapper.projectUpdateProgress(dto.getProjectId());
			
		} catch (Exception e) {
			log.info("updateProjectTask : ", e);
			throw e;
		}
		
	}

	@Override
	public int taskDataCount(Map<String, Object> map) throws Exception {
		int result = 0;
		
		try {
			result = mapper.taskDataCount(map);
		} catch (Exception e) {
			log.info("taskDataCount : ", e);
		}
		
		return result;
	}

	@Override
	public void insertTaskDailylog(ProjectsDto dto) throws Exception {
		try {
			
	        log.info("taskId 확인: {}", dto.getTaskId());      // 여기 추가
	        log.info("projectId 확인: {}", dto.getProjectId());
	        
			mapper.insertTaskDailylog(dto);
			
	        mapper.taskUpdateStatus(dto.getTaskId());
	        mapper.projectUpdateProgress(dto.getProjectId());
	        mapper.projectAutoComplete(dto.getProjectId());
	        
		} catch (Exception e) {
			log.info("insertTaskDailylog : ", e);
			throw e;
		}
		
	}

	@Override
	public List<ProjectsDto> taskDailylist(String empTaskId) throws Exception {
		List<ProjectsDto> list = null;
		
		try {
			list = mapper.taskDailylist(empTaskId);
			
		} catch (Exception e) {
			log.info("taskDailylist : ", e);
			throw e;
		}
		return list;
	}

	@Override
	public List<ProjectsDto> myProjectslist(Map<String, Object> map) throws Exception {
		List<ProjectsDto> list = null;
		
		try {
			list = mapper.myProjectslist(map);
		} catch (Exception e) {
			log.info("myProjectslist : ", e);
			throw e;
		}
	    return list;
	}

	@Override
	public int myDataCount(Map<String, Object> map) throws Exception {
		int result = 0;
		
		try {
			result = mapper.myDataCount(map);
		} catch (Exception e) {
			log.info("myDataCount : ", e);
			throw e;
		}
		
	    return result;
	}

	@Override
	public void taskAutoDelay() throws Exception {
	    try {
	        mapper.taskAutoDelay();
	    } catch (Exception e) {
	        log.info("taskAutoDelay : ", e);
	        throw e;
	    }
	}

	@Override
	public void projectAutoComplete(long projectId) throws Exception {
	    try {
	        mapper.projectAutoComplete(projectId);
	    } catch (Exception e) {
	        log.info("projectAutoComplete : ", e);
	        throw e;
	    }
	}

	@Override
	public void taskForceStopByProject(long projectId) throws Exception {
	    try {
	        mapper.taskForceStopByProject(projectId);
	    } catch (Exception e) {
	        log.info("taskForceStopByProject : ", e);
	        throw e;
	    }
	}
	
	@Override
	public String findEmpTaskId(String taskId) throws Exception {
		String empTaskId = null;
		
	    try {
	        empTaskId = mapper.findEmpTaskId(taskId);
	    } catch (Exception e) {
	        log.info("findEmpTaskId : ", e);
	        throw e;
	    }
	    return empTaskId;
	}

	@Override
	public List<ProjectsDto> myTasklist(Map<String, Object> map) throws Exception {
	    List<ProjectsDto> list = null;
	    try {
	        list = mapper.myTasklist(map);
	    } catch (Exception e) {
	        log.info("myTasklist : ", e);
	        throw e;
	    }
	    return list;
	}

	@Override
	public int myTaskDataCount(Map<String, Object> map) throws Exception {
	    int result = 0;
	    try {
	        result = mapper.myTaskDataCount(map);
	    } catch (Exception e) {
	        log.info("myTaskDataCount : ", e);
	        throw e;
	    }
	    return result;
	}
}
