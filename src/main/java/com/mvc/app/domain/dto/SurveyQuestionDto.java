package com.mvc.app.domain.dto;

import java.util.List;
import lombok.Data;

@Data
public class SurveyQuestionDto {
    private long questionId;
    private long surveyId;
    private String questionText;
    private String questionType;
    private int sortOrder;

    // 하위 데이터 (선택지 목록)
    private List<SurveyOptionDto> options;
}