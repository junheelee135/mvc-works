package com.mvc.app.notification.controller;

import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.notification.dto.NotificationDto;
import com.mvc.app.notification.service.NotificationService;
import com.mvc.app.notification.service.SseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.Map;

/**
 * 알림 Controller
 *
 * GET  /api/notifications/stream     - SSE 연결
 * GET  /api/notifications            - 알림 목록 조회
 * GET  /api/notifications/unread     - 읽지 않은 알림 수
 * PATCH /api/notifications/{notiId}/read  - 단건 읽음 처리
 * PATCH /api/notifications/read-all  - 전체 읽음 처리
 */
@Slf4j
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final SseService          sseService;

    /**
     * SSE 연결
     * 브라우저 접속 시 EventSource로 연결
     */
    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream(@SessionAttribute("member") SessionInfo member) {
        log.debug("[NotificationController] SSE 연결 요청 empId={}", member.getEmpId());
        return sseService.connect(member.getEmpId());
    }

    /**
     * 알림 목록 조회 (최신 20건)
     */
    @GetMapping
    public ResponseEntity<List<NotificationDto>> getList(
            @SessionAttribute("member") SessionInfo member) {
        List<NotificationDto> list = notificationService.getList(member.getEmpId());
        return ResponseEntity.ok(list);
    }

    /**
     * 읽지 않은 알림 수
     */
    @GetMapping("/unread")
    public ResponseEntity<Map<String, Integer>> getUnreadCount(
            @SessionAttribute("member") SessionInfo member) {
        int count = notificationService.getUnreadCount(member.getEmpId());
        return ResponseEntity.ok(Map.of("count", count));
    }

    /**
     * 단건 읽음 처리
     */
    @PatchMapping("/{notiId}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long notiId,
            @SessionAttribute("member") SessionInfo member) {
        notificationService.markAsRead(notiId, member.getEmpId());
        return ResponseEntity.ok().build();
    }

    /**
     * 전체 읽음 처리
     */
    @PatchMapping("/read-all")
    public ResponseEntity<Void> markAllAsRead(
            @SessionAttribute("member") SessionInfo member) {
        notificationService.markAllAsRead(member.getEmpId());
        return ResponseEntity.ok().build();
    }
}
