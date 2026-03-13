package com.mvc.app.service;

import java.util.List;

import com.mvc.app.domain.dto.ApprovalTemplateDto;
import com.mvc.app.domain.dto.ApprovalTemplateLineDto;

public interface ApprovalTemplateService {
    public void saveTemplate(ApprovalTemplateDto dto) throws Exception;
    public List<ApprovalTemplateDto> listTemplate(String writerEmpId);
    public List<ApprovalTemplateLineDto> listTemplateLine(long tempId);
    public void deleteTemplate(long tempId) throws Exception;
}