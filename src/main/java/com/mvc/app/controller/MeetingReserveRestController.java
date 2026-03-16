package com.mvc.app.controller;

import com.mvc.app.domain.dto.MeetingReserveDto;
import com.mvc.app.domain.dto.MeetingRoomDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.MeetingReserveService;
import com.mvc.app.service.MeetingRoomService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/meeting/reserve")
@RequiredArgsConstructor
@Slf4j
public class MeetingReserveRestController {

    private final MeetingReserveService reserveService;
    private final MeetingRoomService roomService;

    @GetMapping
    public ResponseEntity<?> listByDate(
            @RequestParam(name = "date") String date,
            @RequestParam(name = "roomId", required = false) Long roomId) {
        try {
            List<MeetingReserveDto> list = reserveService.listByDate(date, roomId);
            return ResponseEntity.ok(Map.of("list", list));
        } catch (Exception e) {
            log.info("listByDate : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "예약 목록 조회에 실패했습니다."));
        }
    }

    @GetMapping("/month")
    public ResponseEntity<?> listByMonth(
            @RequestParam(name = "yearMonth") String yearMonth) {
        try {
            List<MeetingReserveDto> list = reserveService.listByMonth(yearMonth);
            return ResponseEntity.ok(Map.of("list", list));
        } catch (Exception e) {
            log.info("listByMonth : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "월별 예약 조회에 실패했습니다."));
        }
    }

    @GetMapping("/stats")
    public ResponseEntity<?> stats() {
        try {
            SessionInfo si = LoginMemberUtil.getSessionInfo();
            String empId = si != null ? si.getEmpId() : "";
            Map<String, Integer> stats = reserveService.getStats(empId);
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            log.info("stats : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "통계 조회에 실패했습니다."));
        }
    }

    @GetMapping("/rooms")
    public ResponseEntity<?> rooms() {
        try {
            List<MeetingRoomDto> all = roomService.listRoom();
            List<MeetingRoomDto> active = all.stream()
                    .filter(r -> "Y".equals(r.getUseYn()))
                    .collect(Collectors.toList());
            return ResponseEntity.ok(Map.of("list", active));
        } catch (Exception e) {
            log.info("rooms : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "회의실 목록 조회에 실패했습니다."));
        }
    }

    @PostMapping
    public ResponseEntity<?> insert(@RequestBody MeetingReserveDto dto) {
        try {
            SessionInfo si = LoginMemberUtil.getSessionInfo();
            if (si != null) {
                dto.setReserveEmpId(si.getEmpId());
                dto.setReserveEmpName(si.getName());
                dto.setReserveDeptName(si.getDeptName());
            }
            reserveService.insertReserve(dto);
            return ResponseEntity.ok(Map.of("msg", "예약 완료"));
        } catch (Exception e) {
            log.info("insert : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "예약 등록에 실패했습니다."));
        }
    }

    @DeleteMapping("/{reserveId}")
    public ResponseEntity<?> cancel(@PathVariable("reserveId") long reserveId) {
        try {
            reserveService.cancelReserve(reserveId);
            return ResponseEntity.ok(Map.of("msg", "예약 취소 완료"));
        } catch (Exception e) {
            log.info("cancel : ", e);
            return ResponseEntity.badRequest().body(Map.of("msg", "예약 취소에 실패했습니다."));
        }
    }
}
