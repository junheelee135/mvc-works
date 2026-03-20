package com.mvc.app.domain.dto;

import lombok.Data;

@Data
public class SurveyDto {
    private long surveyId;
    private String title;
    private String description;
    private String anonymousYn;
    private String status;
    private String startDate;
    private String endDate;
    private String writerEmpId;
    private String regDate;
    private String updateDate;

    private String writerName;
    private int questionCount;
    private int responseCount;
    private int targetCount;  
    private String respondedYn;
}