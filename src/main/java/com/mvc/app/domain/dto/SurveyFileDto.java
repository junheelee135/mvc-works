package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class SurveyFileDto {
    private long fileId;
    private long surveyId;
    private String oriFilename;
    private String saveFilename;
    private long fileSize;
    private String regDate;
}
