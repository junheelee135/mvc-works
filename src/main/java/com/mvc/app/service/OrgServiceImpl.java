package com.mvc.app.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.mvc.app.domain.dto.DepartmentDto;
import com.mvc.app.mapper.OrgMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrgServiceImpl implements OrgService {
    private final OrgMapper mapper;

    @Override
    public List<DepartmentDto> getDeptTree() {
        try {
            List<DepartmentDto> all = mapper.listDepartment();
            return buildTree(all);
        } catch (Exception e) {
            log.info("getDeptTree : ", e);
        }
        return null;
    }

    @Override
    public List<Map<String, Object>> listEmpByDept(String deptCode) {
        try {
            return mapper.listEmpByDept(deptCode);
        } catch (Exception e) {
            log.info("listEmpByDept : ", e);
        }
        return null;
    }

    @Override
    public List<Map<String, Object>> searchEmp(String keyword) {
        try {
            return mapper.searchEmp(keyword);
        } catch (Exception e) {
            log.info("searchEmp : ", e);
        }
        return null;
    }

    // flat 리스트 → 트리 변환 (superDeptCode가 null이면 최상위)
    private List<DepartmentDto> buildTree(List<DepartmentDto> all) {
        List<DepartmentDto> roots = new ArrayList<>();

        for (DepartmentDto dept : all) {
            if (dept.getSuperDeptCode() == null || dept.getSuperDeptCode().isEmpty()) {
                dept.setChildren(findChildren(dept.getDeptCode(), all));
                roots.add(dept);
            }
        }
        return roots;
    }

    private List<DepartmentDto> findChildren(String parentCode, List<DepartmentDto> all) {
        List<DepartmentDto> children = new ArrayList<>();
        for (DepartmentDto dept : all) {
            if (parentCode.equals(dept.getSuperDeptCode())) {
                dept.setChildren(findChildren(dept.getDeptCode(), all));
                children.add(dept);
            }
        }
        return children;
    }
}
