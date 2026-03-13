package com.mvc.app.aop.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ActivityLogDto {

    private String actorEmpId;      // 작업 수행자 사원번호
    private String actorName;       // 작업 수행자 이름

    private String actionType;      // 작업 유형 (ActionType 상수 사용)
    private String targetMenu;      // 작업 메뉴 (기본 "HRM")

    private String targetEmpIds;    // 대상 사원번호 (단건: empId, 복수: "A,B,C")

    private String beforeData;      // 변경 전 JSON (수정·삭제 시)
    private String afterData;       // 변경 후 JSON (등록·수정 시)

    private String result;          // "SUCCESS" / "FAIL"
    private String errorMsg;        // 실패 시 오류 메시지

    private String ipAddr;          // 접속 IP
}
