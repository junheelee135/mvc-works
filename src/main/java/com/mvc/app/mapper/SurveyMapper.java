package com.mvc.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.mvc.app.domain.dto.SurveyAnswerDto;
import com.mvc.app.domain.dto.SurveyDto;
import com.mvc.app.domain.dto.SurveyFileDto;
import com.mvc.app.domain.dto.SurveyOptionDto;
import com.mvc.app.domain.dto.SurveyQuestionDto;
import com.mvc.app.domain.dto.SurveyResponseDto;
import com.mvc.app.domain.dto.SurveyTargetDto;

@Mapper
public interface SurveyMapper {

    List<SurveyDto> listSurvey(Map<String, Object> map);
    int countSurvey(Map<String, Object> map);
    SurveyDto findById(long surveyId);
    void insertSurvey(SurveyDto dto);
    void updateSurvey(SurveyDto dto);
    void updateStatus(Map<String, Object> map);
    void deleteSurvey(long surveyId);

    List<SurveyQuestionDto> listQuestion(long surveyId);
    void insertQuestion(SurveyQuestionDto dto);
    void deleteQuestionsBySurveyId(long surveyId);

    List<SurveyOptionDto> listOption(long questionId);
    void insertOption(SurveyOptionDto dto);
    void deleteOptionsByQuestionId(long questionId);

    List<SurveyTargetDto> listTarget(long surveyId);
    void insertTarget(SurveyTargetDto dto);
    void deleteTargetsBySurveyId(long surveyId);
    int checkTarget(Map<String, Object> map);

    void insertResponse(SurveyResponseDto dto);
    int checkResponse(Map<String, Object> map);
    void deleteAnswersBySurveyId(long surveyId);
    void deleteResponsesBySurveyId(long surveyId);

    void insertAnswer(SurveyAnswerDto dto);

    int countResponse(long surveyId);
    List<SurveyOptionDto> statOptionCount(long questionId);
    List<SurveyAnswerDto> statTextAnswers(long questionId);
    double statScoreAvg(long questionId);

    void insertFile(SurveyFileDto dto);
    List<SurveyFileDto> listFiles(long surveyId);
    SurveyFileDto getFileById(long fileId);
    void deleteFilesBySurveyId(long surveyId);
}