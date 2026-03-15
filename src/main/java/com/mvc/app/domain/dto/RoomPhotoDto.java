package com.mvc.app.domain.dto;

import lombok.Data;

@Data
public class RoomPhotoDto {
    private long photoId;
    private long roomId;
    private String oriFilename;
    private String saveFilename;
    private int sortOrder;
    private String regDate;
}