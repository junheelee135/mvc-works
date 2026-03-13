package com.mvc.app.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.mvc.app.domain.dto.ApprovalDeputyDto;
import com.mvc.app.mapper.ApprovalDeputyMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ApprovalDeputyServiceImpl implements ApprovalDeputyService {

    private final ApprovalDeputyMapper mapper;

    @Override
    public void registerDeputy(ApprovalDeputyDto dto) throws Exception {
        mapper.insertDeputy(dto);
    }

    @Override
    public void updateDeputy(ApprovalDeputyDto dto) throws Exception {
        mapper.updateDeputy(dto);
    }

    @Override
    public boolean cancelDeputy(long deputyRegId, String empId) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("deputyRegId", deputyRegId);
        map.put("empId", empId);
        return mapper.cancelDeputy(map) > 0;
    }

    @Override
    public Map<String, Object> listDeputy(Map<String, Object> map) throws Exception {
        List<ApprovalDeputyDto> list = mapper.listDeputy(map);
        int total = mapper.countDeputy(map);
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", total);
        return result;
    }

    @Override
    public ApprovalDeputyDto getDeputy(long deputyRegId) throws Exception {
        return mapper.getDeputy(deputyRegId);
    }
}
