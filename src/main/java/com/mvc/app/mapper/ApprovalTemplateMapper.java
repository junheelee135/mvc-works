package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mvc.app.domain.dto.ApprovalTemplateDto;
import com.mvc.app.domain.dto.ApprovalTemplateLineDto;

@Mapper
public interface ApprovalTemplateMapper {
    public void insertTemplate(ApprovalTemplateDto dto) throws SQLException;
    public void insertTemplateLine(ApprovalTemplateLineDto dto) throws SQLException;
    public List<ApprovalTemplateDto> listTemplate(String writerEmpId);
    public List<ApprovalTemplateLineDto> listTemplateLine(long tempId);
    public void deleteTemplateLine(long tempId) throws SQLException;
    public void deleteTemplate(long tempId) throws SQLException;
}