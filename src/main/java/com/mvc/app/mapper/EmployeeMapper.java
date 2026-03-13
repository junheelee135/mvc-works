package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.mvc.app.domain.dto.EmployeeDto;

@Mapper
public interface EmployeeMapper {

	public void insertEmployee1(EmployeeDto dto) throws SQLException;
	public void insertEmployee2(EmployeeDto dto) throws SQLException;
	public void insertEmployee12(EmployeeDto dto) throws SQLException;
	public void insertEmployeeStatus(EmployeeDto dto) throws SQLException;

	public void updateEmployeeEnabled(Map<String, Object> map) throws SQLException;
	public void updateEmployeePassword(EmployeeDto dto) throws SQLException;
	public void updateEmployee2(EmployeeDto dto) throws SQLException;
	public void deleteProfilePhoto(Map<String, Object> map) throws SQLException;

	public void updateLastLogin(String empId) throws SQLException;

	public EmployeeDto findByEmpId(String empId);

	public Integer checkFailureCount(String empId);
	public void updateFailureCountReset(String empId) throws SQLException;
	public void updateFailureCount(String empId) throws SQLException;

	public void deleteEmployee2(Map<String, Object> map) throws SQLException;

	public List<EmployeeDto> listFindMember(Map<String, Object> map);

	public void insertAuthority(EmployeeDto dto) throws SQLException;
	public void deleteAuthority(Map<String, Object> map) throws SQLException;
	public String findByAuthority(String empId);

	public void insertRefreshToken(EmployeeDto dto) throws SQLException;
	public void updateRefreshToken(EmployeeDto dto) throws SQLException;
	public void deleteRefreshToken(String empId) throws SQLException;
	public EmployeeDto findByToken(String empId);
}
