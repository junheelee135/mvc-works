package com.mvc.app.domain.dto;

import lombok.Data;

@Data
public class SurveyAnswerDto {
    private long answerId;
    private long responseId;
    private long questionId;
    private Long optionId;
    private String answerText;
    private Integer scoreValue;
}