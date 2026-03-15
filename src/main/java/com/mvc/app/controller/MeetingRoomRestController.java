package com.mvc.app.controller;

import com.mvc.app.domain.dto.MeetingRoomDto;
import com.mvc.app.service.MeetingRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/meeting/room")
@RequiredArgsConstructor
public class MeetingRoomRestController {

    private final MeetingRoomService meetingRoomService;

    @GetMapping
    public ResponseEntity<?> list() {
        List<MeetingRoomDto> list = meetingRoomService.listRoom();
        return ResponseEntity.ok(Map.of("list", list));
    }

    @GetMapping("/{roomId}")
    public ResponseEntity<?> get(@PathVariable("roomId") long roomId) {
        MeetingRoomDto dto = meetingRoomService.getRoom(roomId);
        return ResponseEntity.ok(dto);
    }

    @PostMapping
    public ResponseEntity<?> insert(
            @RequestPart("data") MeetingRoomDto dto,
            @RequestPart(value = "photos", required = false) MultipartFile[] photos) {
        meetingRoomService.insertRoom(dto, photos);
        return ResponseEntity.ok(Map.of("msg", "등록 완료"));
    }

    @PutMapping("/{roomId}")
    public ResponseEntity<?> update(
            @PathVariable("roomId") long roomId,
            @RequestPart("data") MeetingRoomDto dto,
            @RequestPart(value = "photos", required = false) MultipartFile[] photos) {
        dto.setRoomId(roomId);
        meetingRoomService.updateRoom(dto, photos);
        return ResponseEntity.ok(Map.of("msg", "수정 완료"));
    }

    @DeleteMapping("/{roomId}")
    public ResponseEntity<?> delete(@PathVariable("roomId") long roomId) {
        meetingRoomService.deleteRoom(roomId);
        return ResponseEntity.ok(Map.of("msg", "삭제 완료"));
    }
}