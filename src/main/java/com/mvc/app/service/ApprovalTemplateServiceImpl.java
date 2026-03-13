package com.mvc.app.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mvc.app.domain.dto.ApprovalTemplateDto;
import com.mvc.app.domain.dto.ApprovalTemplateLineDto;
import com.mvc.app.mapper.ApprovalTemplateMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ApprovalTemplateServiceImpl implements ApprovalTemplateService {
    private final ApprovalTemplateMapper mapper;

    @Override
    @Transactional
    public void saveTemplate(ApprovalTemplateDto dto) throws Exception {
        try {
            // 1. 템플릿 헤더 저장 (selectKey로 tempId 자동 세팅)
            mapper.insertTemplate(dto);

            // 2. 템플릿 상세 (결재자 목록) 저장
            int order = 1;
            for (ApprovalTemplateLineDto line : dto.getLines()) {
                line.setTempId(dto.getTempId());
                line.setStepOrder(order++);
                mapper.insertTemplateLine(line);
            }
        } catch (Exception e) {
            log.info("saveTemplate : ", e);
            throw e;
        }
    }

    @Override
    public List<ApprovalTemplateDto> listTemplate(String writerEmpId) {
        try {
            return mapper.listTemplate(writerEmpId);
        } catch (Exception e) {
            log.info("listTemplate : ", e);
        }
        return null;
    }

    @Override
    public List<ApprovalTemplateLineDto> listTemplateLine(long tempId) {
        try {
            return mapper.listTemplateLine(tempId);
        } catch (Exception e) {
            log.info("listTemplateLine : ", e);
        }
        return null;
    }

    @Override
    @Transactional
    public void deleteTemplate(long tempId) throws Exception {
        try {
            // 상세 먼저 삭제 → 헤더 삭제
            mapper.deleteTemplateLine(tempId);
            mapper.deleteTemplate(tempId);
        } catch (Exception e) {
            log.info("deleteTemplate : ", e);
            throw e;
        }
    }
}