package com.mvc.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.mvc.app.domain.dto.DepartmentDto;

@Mapper
public interface OrgMapper {
    public List<DepartmentDto> listDepartment();
    public List<Map<String, Object>> listEmpByDept(String deptCode);
    public List<Map<String, Object>> searchEmp(String keyword);
}
