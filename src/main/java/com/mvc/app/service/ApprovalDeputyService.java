package com.mvc.app.service;

import java.util.Map;

import com.mvc.app.domain.dto.ApprovalDeputyDto;

public interface ApprovalDeputyService {
    void registerDeputy(ApprovalDeputyDto dto) throws Exception;
    void updateDeputy(ApprovalDeputyDto dto) throws Exception;
    boolean cancelDeputy(long deputyRegId, String empId) throws Exception;
    Map<String, Object> listDeputy(Map<String, Object> map) throws Exception;
    ApprovalDeputyDto getDeputy(long deputyRegId) throws Exception;
}
