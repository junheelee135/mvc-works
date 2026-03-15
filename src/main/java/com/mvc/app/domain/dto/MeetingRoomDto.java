package com.mvc.app.domain.dto;

import lombok.Data;
import java.util.List;

@Data
public class MeetingRoomDto {
    private long roomId;
    private String roomName;
    private String location;
    private int capacity;
    private int sortOrder;
    private String useYn;
    private String regDate;
    private List<String> equipCodes;
    private List<RoomPhotoDto> photos;
}