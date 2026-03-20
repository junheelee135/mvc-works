package com.mvc.app.domain.dto;

import lombok.Data;

@Data
public class SurveyTargetDto {
    private long targetId;
    private long surveyId;
    private String targetType;
    private String targetValue;

    // 조회용
    private String targetName;
}