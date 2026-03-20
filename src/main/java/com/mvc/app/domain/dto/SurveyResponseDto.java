package com.mvc.app.domain.dto;

import java.util.List;
import lombok.Data;

@Data
public class SurveyResponseDto {
    private long responseId;
    private long surveyId;
    private String empId;
    private String respondedDate;

    // 하위 데이터 (개별 답변 목록)
    private List<SurveyAnswerDto> answers;
}