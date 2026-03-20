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

    // 설문 목록 + 페이징
    Map<String, Object> listSurvey(Map<String, Object> map) throws Exception;

    // 설문 상세 (질문 + 선택지 + 대상자 포함)
    Map<String, Object> findById(long surveyId) throws Exception;

    // 설문 등록 (질문 + 선택지 + 대상자 + 첨부파일)
    void createSurvey(SurveyDto dto, List<SurveyQuestionDto> questions, List<SurveyTargetDto> targets, MultipartFile[] files) throws Exception;

    // 설문 수정 (기존 삭제 → 새로 등록)
    void updateSurvey(SurveyDto dto, List<SurveyQuestionDto> questions, List<SurveyTargetDto> targets, MultipartFile[] files) throws Exception;

    // 상태 변경 (DRAFT→ACTIVE, ACTIVE→CLOSED)
    void updateStatus(long surveyId, String status) throws Exception;

    // 설문 삭제 (DRAFT만, 자식 먼저 삭제)
    void deleteSurvey(long surveyId) throws Exception;

    // 대상자 확인
    boolean checkTarget(long surveyId, String empId, String deptCode) throws Exception;

    // 응답 여부 확인
    boolean checkResponse(long surveyId, String empId) throws Exception;

    // 응답 제출
    void submitResponse(SurveyResponseDto dto) throws Exception;

    // 결과 통계
    Map<String, Object> getResult(long surveyId) throws Exception;

    // 첨부파일 조회
    SurveyFileDto findFileById(long fileId) throws Exception;
}