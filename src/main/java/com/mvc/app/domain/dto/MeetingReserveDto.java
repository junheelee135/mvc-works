package com.mvc.app.domain.dto;

import lombok.Data;

@Data
public class MeetingReserveDto {
    private long reserveId;
    private long roomId;
    private String roomName;
    private String reserveDate;
    private String startTime;
    private String endTime;
    private String title;
    private String memo;
    private String attendees;
    private String reserveEmpId;
    private String reserveEmpName;
    private String reserveDeptName;
    private String status;
    private String regDate;
}
