package com.mvc.app.service;

import com.mvc.app.domain.dto.MeetingRoomDto;
import com.mvc.app.domain.dto.RoomPhotoDto;
import com.mvc.app.mapper.MeetingRoomMapper;
import com.mvc.app.common.StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MeetingRoomServiceImpl implements MeetingRoomService {

    private final MeetingRoomMapper mapper;
    private final StorageService storageService;

    @Value("${file.upload-root}/meeting")
    private String uploadPath;

    @Override
    public List<MeetingRoomDto> listRoom() {
        List<MeetingRoomDto> list = mapper.listRoom();
        for (MeetingRoomDto dto : list) {
            dto.setEquipCodes(mapper.listEquipByRoom(dto.getRoomId()));
            dto.setPhotos(mapper.listPhotoByRoom(dto.getRoomId()));
        }
        return list;
    }

    @Override
    public MeetingRoomDto getRoom(long roomId) {
        MeetingRoomDto dto = mapper.getRoom(roomId);
        if (dto != null) {
            dto.setEquipCodes(mapper.listEquipByRoom(roomId));
            dto.setPhotos(mapper.listPhotoByRoom(roomId));
        }
        return dto;
    }

    @Override
    @Transactional
    public void insertRoom(MeetingRoomDto dto, MultipartFile[] photos) {
        mapper.insertRoom(dto);
		
        long roomId = dto.getRoomId();

        saveEquips(roomId, dto.getEquipCodes());

        savePhotos(roomId, photos);
    }

    @Override
    @Transactional
    public void updateRoom(MeetingRoomDto dto, MultipartFile[] photos) {
        mapper.updateRoom(dto);
        long roomId = dto.getRoomId();

        mapper.deleteEquipByRoom(roomId);

        saveEquips(roomId, dto.getEquipCodes());

        savePhotos(roomId, photos);
    }

    @Override
    @Transactional
    public void deleteRoom(long roomId) {
        mapper.deletePhotoByRoom(roomId);
        mapper.deleteEquipByRoom(roomId);
        mapper.deleteRoom(roomId);
    }

    private void saveEquips(long roomId, List<String> equipCodes) {
        if (equipCodes == null) return;
        for (String code : equipCodes) {
            Map<String, Object> map = new HashMap<>();
            map.put("roomId", roomId);
            map.put("equipCode", code);
            mapper.insertEquip(map);
        }
    }

    private void savePhotos(long roomId, MultipartFile[] photos) {
        if (photos == null) return;
        int order = 0;
        for (MultipartFile file : photos) {
            if (file.isEmpty()) continue;
            String savedName = storageService.uploadFileToServer(file, uploadPath);
            RoomPhotoDto photo = new RoomPhotoDto();
            photo.setRoomId(roomId);
            photo.setOriFilename(file.getOriginalFilename());
            photo.setSaveFilename(savedName);
            photo.setSortOrder(order++);
            mapper.insertPhoto(photo);
        }
    }
}