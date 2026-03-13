package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class DocTypeDto {
    private long docTypeId;      // 문서유형ID
    private String typeName;     // 유형명
    private String typeCode;     // 유형코드
    private String description;  // 설명
    private int sortOrder;       // 정렬순서
    private String useYn;        // 사용여부
    private String regEmpId;     // 등록자사원번호
    private String regDate;      // 등록일
    private String formCode;     // 양식코드
    private String notice;       // 참고사항
}
