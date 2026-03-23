package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.repository.query.Param;

import com.mvc.app.domain.dto.ProjectsDto;

@Mapper
public interface TaskMapper {

	// task 생성(프로젝트 별)
	public void insertProjectTask(ProjectsDto dto) throws SQLException;
	public void insertNewStage(ProjectsDto dto) throws SQLException;
	List<ProjectsDto> findStagesByProjectId(long projectId) throws SQLException;
	
	// emp task 생성(사원 별)
	public void insertEmpTask(ProjectsDto dto) throws SQLException;
	
	// task 차트 수정
	// 시작일, 종료일, 상태
	public void updateProjectTask(ProjectsDto dto) throws SQLException;
	// 담당자
	public void updateProjectEmp(ProjectsDto dto) throws SQLException;
	// 인서트 되어 있는 담당자의 업무가 바뀔 시 퇴사, 휴직 등의 사유
	public int countEmpTask(String taskId) throws SQLException;
	
	// 히스토리로 인한 삭제 불가로 수정만 진행. 상태 중단으로 고정.
	public void cancelProjectTask(String taskId) throws SQLException;
	
	
	// task 리스트
	public List<ProjectsDto> tasklist(Map<String, Object> map);
	public int taskDataCount(Map<String, Object> map) throws SQLException;
	
	// 사원 task리스트
	List<Map<String, Object>> findByEmpId(@Param("empId") String empId);
	
	// task 매일 진행되는 작업
	public void insertTaskDailylog(ProjectsDto dto) throws SQLException;
	public List<ProjectsDto> taskDailylist(@Param("empTaskId") String empTaskId) throws SQLException;

	// 프로젝트 진척률
	public void projectUpdateProgress(long projectId) throws SQLException;
	// task 진행 체크
	public void taskUpdateStatus(String taskId) throws SQLException;
	
	// 간트
	public List<ProjectsDto> myProjectslist(Map<String, Object> map) throws SQLException;
	public int myDataCount(Map<String, Object> map) throws SQLException;
	
	public void taskAutoDelay() throws SQLException;
	public void projectAutoComplete(long projectId) throws SQLException;
	
	public void taskForceStopByProject(long projectId) throws SQLException;
	
	public String findEmpTaskId(String taskId);
}
