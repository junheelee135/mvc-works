package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.mvc.app.domain.dto.ProjectsDto;

@Mapper
public interface ProjectsMapper {
	// 프로젝트 생성
	public void insertProject(ProjectsDto dto) throws SQLException;

	// 프로젝트 생성 시 구성원 조성 및 역할부여
	public void insertProjectMembers(Map<String, Object> member) throws SQLException;
	public void insertProjectStep(Map<String, Object> stage) throws SQLException;
	List<Map<String,Object>> findStageByProjectId(@Param("projectId") Long projectId);
	public void insertTasks(Map<String, Object> map) throws SQLException;

	
	public List<ProjectsDto> projectslist(Map<String, Object> map);
	// 필터 적용 시 사용하는 카운트
	public int dataCount(Map<String, Object> map);	
	public ProjectsDto findById(Long projectId);
	public ProjectsDto projectarticle(long projectId);
	public List<ProjectsDto> projectMembers(long projectId);

	// 내가 참여한 프로젝트 조회
	List<ProjectsDto> findProjectsByEmpId(@Param("empId") String empId);

	List<ProjectsDto> myProjectsList(Map<String, Object> map);
	int myProjectsCount(Map<String, Object> map);
	
	public List<ProjectsDto> statusCount(Map<String, Object> map);
	public List<ProjectsDto> myProjectstatusCount(String empId);
	
	
	public void projectAutoStart() throws SQLException;
	public void projectAutoDelay() throws SQLException;
	
	public void projectForceStop(long projectId) throws SQLException;
	
	public void changeEmpTask(Map<String, Object> map) throws SQLException;
	
	public void updatePredecessor(Map<String, Object> map) throws SQLException;
	public void updateNewEmpId(Map<String, Object> map) throws SQLException;
}
