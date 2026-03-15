package com.mvc.app.controller;

import com.mvc.app.domain.dto.MeetingReserveDto;
import com.mvc.app.domain.dto.MeetingRoomDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.MeetingReserveService;
import com.mvc.app.service.MeetingRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/meeting/reserve")
@RequiredArgsConstructor
public class MeetingReserveRestController {

    private final MeetingReserveService reserveService;
    private final MeetingRoomService roomService;

    @GetMapping
    public ResponseEntity<?> listByDate(
            @RequestParam(name = "date") String date,
            @RequestParam(name = "roomId", required = false) Long roomId) {
        List<MeetingReserveDto> list = reserveService.listByDate(date, roomId);
        return ResponseEntity.ok(Map.of("list", list));
    }

    @GetMapping("/month")
    public ResponseEntity<?> listByMonth(
            @RequestParam(name = "yearMonth") String yearMonth) {
        List<MeetingReserveDto> list = reserveService.listByMonth(yearMonth);
        return ResponseEntity.ok(Map.of("list", list));
    }

    @GetMapping("/stats")
    public ResponseEntity<?> stats() {
        SessionInfo si = LoginMemberUtil.getSessionInfo();
        String empId = si != null ? si.getEmpId() : "";
        Map<String, Integer> stats = reserveService.getStats(empId);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/rooms")
    public ResponseEntity<?> rooms() {
        List<MeetingRoomDto> all = roomService.listRoom();
        List<MeetingRoomDto> active = all.stream()
                .filter(r -> "Y".equals(r.getUseYn()))
                .collect(Collectors.toList());
        return ResponseEntity.ok(Map.of("list", active));
    }

    @PostMapping
    public ResponseEntity<?> insert(@RequestBody MeetingReserveDto dto) {
        SessionInfo si = LoginMemberUtil.getSessionInfo();
        if (si != null) {
            dto.setReserveEmpId(si.getEmpId());
            dto.setReserveEmpName(si.getName());
            dto.setReserveDeptName(si.getDeptName());
        }
        try {
            reserveService.insertReserve(dto);
            return ResponseEntity.ok(Map.of("msg", "예약 완료"));
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{reserveId}")
    public ResponseEntity<?> cancel(@PathVariable("reserveId") long reserveId) {
        reserveService.cancelReserve(reserveId);
        return ResponseEntity.ok(Map.of("msg", "예약 취소 완료"));
    }
}
