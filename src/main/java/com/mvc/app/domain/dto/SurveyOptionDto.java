package com.mvc.app.domain.dto;

import lombok.Data;

@Data
public class SurveyOptionDto {
    private long optionId;
    private long questionId;
    private String optionText;
    private int sortOrder;

    // 통계용
    private int selectCount;
}