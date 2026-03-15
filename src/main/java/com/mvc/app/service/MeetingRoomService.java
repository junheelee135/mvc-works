package com.mvc.app.service;

import com.mvc.app.domain.dto.MeetingRoomDto;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface MeetingRoomService {
    List<MeetingRoomDto> listRoom();
    MeetingRoomDto getRoom(long roomId);
    void insertRoom(MeetingRoomDto dto, MultipartFile[] photos);
    void updateRoom(MeetingRoomDto dto, MultipartFile[] photos);
    void deleteRoom(long roomId);
}