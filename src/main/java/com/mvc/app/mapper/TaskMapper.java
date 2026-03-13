package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.repository.query.Param;

import com.mvc.app.domain.dto.ProjectsDto;

@Mapper
public interface TaskMapper {

	// task 생성
	public void insertProjectTask(ProjectsDto dto) throws SQLException;
	// emp task 생성
	public void insertEmpTask(ProjectsDto dto) throws SQLException;
	
	// task 차트 수정(시작일, 종료일, 상태, 담당자)
	public void updateProjectTask(ProjectsDto dto) throws SQLException;
	
	// 히스토리로 인한 삭제 불가로 수정만 진행. 상태 중단으로 고정.
	public void cancelProjectTask(String taskId) throws SQLException;
	
	List<ProjectsDto> findStagesByProjectId(long projectId) throws SQLException;
	

	List<Map<String, Object>> findByEmpId(@Param("empId") String empId);
	public List<ProjectsDto> tasklist(Map<String, Object> map);

}
