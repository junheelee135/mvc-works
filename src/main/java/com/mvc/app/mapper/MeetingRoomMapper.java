package com.mvc.app.mapper;

import com.mvc.app.domain.dto.MeetingRoomDto;
import com.mvc.app.domain.dto.RoomPhotoDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface MeetingRoomMapper {

    List<MeetingRoomDto> listRoom();
    MeetingRoomDto getRoom(long roomId);
    void insertRoom(MeetingRoomDto dto);
    void updateRoom(MeetingRoomDto dto);
    void deleteRoom(long roomId);

    List<String> listEquipByRoom(long roomId);
    void insertEquip(Map<String, Object> map);
    void deleteEquipByRoom(long roomId);

    List<RoomPhotoDto> listPhotoByRoom(long roomId);
    void insertPhoto(RoomPhotoDto dto);
    void deletePhoto(long photoId);
    void deletePhotoByRoom(long roomId);
}