package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.mvc.app.domain.dto.ApprovalDeputyDto;

@Mapper
public interface ApprovalDeputyMapper {
    void insertDeputy(ApprovalDeputyDto dto) throws SQLException;
    void updateDeputy(ApprovalDeputyDto dto) throws SQLException;
    int cancelDeputy(Map<String, Object> map) throws SQLException;
    List<ApprovalDeputyDto> listDeputy(Map<String, Object> map) throws SQLException;
    int countDeputy(Map<String, Object> map) throws SQLException;
    ApprovalDeputyDto getDeputy(long deputyRegId) throws SQLException;
    ApprovalDeputyDto findActiveDeputy(String delegatorEmpId) throws SQLException;
}
