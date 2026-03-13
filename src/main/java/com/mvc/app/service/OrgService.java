package com.mvc.app.service;

import java.util.List;
import java.util.Map;

import com.mvc.app.domain.dto.DepartmentDto;

public interface OrgService {
    public List<DepartmentDto> getDeptTree();
    public List<Map<String, Object>> listEmpByDept(String deptCode);
    public List<Map<String, Object>> searchEmp(String keyword);
}
