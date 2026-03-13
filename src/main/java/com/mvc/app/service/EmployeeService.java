package com.mvc.app.service;

import java.util.List;
import java.util.Map;

import com.mvc.app.domain.dto.EmployeeDto;

public interface EmployeeService {

	public void insertEmployee(EmployeeDto dto, String uploadPath) throws Exception;
	public void insertEmployeeStatus(EmployeeDto dto) throws Exception;

	public void updatePassword(EmployeeDto dto) throws Exception;
	public void updateEmployeeEnabled(Map<String, Object> map) throws Exception;
	public void updateEmployee(EmployeeDto dto, String uploadPath) throws Exception;

	public void updateLastLogin(String empId) throws Exception;

	public EmployeeDto findByEmpId(String empId);

	public Integer checkFailureCount(String empId);
	public void updateFailureCountReset(String empId) throws Exception;
	public void updateFailureCount(String empId) throws Exception;

	public void deleteEmployee(Map<String, Object> map, String uploadPath) throws Exception;
	public void deleteProfilePhoto(Map<String, Object> map, String uploadPath) throws Exception;

	public void generatePwd(EmployeeDto dto) throws Exception;

	public List<EmployeeDto> listFindMember(Map<String, Object> map);

	public String findByAuthority(String empId);

	public void insertRefreshToken(EmployeeDto dto) throws Exception;
	public void updateRefreshToken(EmployeeDto dto) throws Exception;
	public EmployeeDto findByToken(String empId);

	public boolean isPasswordCheck(String empId, String password);
}
