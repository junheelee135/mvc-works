package com.mvc.app.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.SurveyDto;
import com.mvc.app.domain.dto.SurveyFileDto;
import com.mvc.app.domain.dto.SurveyQuestionDto;
import com.mvc.app.domain.dto.SurveyResponseDto;
import com.mvc.app.domain.dto.SurveyTargetDto;

public interface SurveyService {

    Map<String, Object> listSurvey(Map<String, Object> map) throws Exception;

    Map<String, Object> findById(long surveyId) throws Exception;

    void createSurvey(SurveyDto dto, List<SurveyQuestionDto> questions, List<SurveyTargetDto> targets, MultipartFile[] files) throws Exception;

    void updateSurvey(SurveyDto dto, List<SurveyQuestionDto> questions, List<SurveyTargetDto> targets, MultipartFile[] files) throws Exception;

    void updateStatus(long surveyId, String status) throws Exception;

    void deleteSurvey(long surveyId) throws Exception;

    boolean checkTarget(long surveyId, String empId, String deptCode) throws Exception;

    boolean checkResponse(long surveyId, String empId) throws Exception;

    void submitResponse(SurveyResponseDto dto) throws Exception;

    Map<String, Object> getResult(long surveyId) throws Exception;

    SurveyFileDto findFileById(long fileId) throws Exception;
}
