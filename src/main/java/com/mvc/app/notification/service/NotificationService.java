package com.mvc.app.notification.service;

import com.mvc.app.notification.dto.NotificationDto;
import com.mvc.app.notification.entity.NotificationEntity;
import com.mvc.app.notification.mapper.NotificationMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 알림 서비스
 * - 알림 저장 (DB INSERT)
 * - 목록 조회 / 읽음 처리
 * - SSE push 위임
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationMapper notificationMapper;
    private final SseService         sseService;

    /**
     * 알림 저장 + SSE push
     * EventListener에서 호출
     */
    @Transactional
    public void saveAndPush(NotificationEntity entity) {
        try {
            // 1. DB 저장
            notificationMapper.insertNotification(entity);

            // 2. SSE push (접속 중인 경우에만)
            NotificationDto dto = NotificationDto.from(entity);
            sseService.push(entity.getReceiverId(), dto);

        } catch (Exception e) {
            log.error("[NotificationService] 알림 저장/push 실패 receiverId={} error={}",
                    entity.getReceiverId(), e.getMessage());
        }
    }

    /**
     * 알림 목록 조회 (최신 20건)
     */
    @Transactional(readOnly = true)
    public List<NotificationDto> getList(String receiverId) {
        return notificationMapper.selectByReceiverId(receiverId)
                .stream()
                .map(NotificationDto::from)
                .collect(Collectors.toList());
    }

    /**
     * 읽지 않은 알림 수
     */
    @Transactional(readOnly = true)
    public int getUnreadCount(String receiverId) {
        return notificationMapper.countUnread(receiverId);
    }

    /**
     * 단건 읽음 처리
     */
    @Transactional
    public void markAsRead(Long notiId, String receiverId) {
        notificationMapper.updateRead(notiId, receiverId);
    }

    /**
     * 전체 읽음 처리
     */
    @Transactional
    public void markAllAsRead(String receiverId) {
        notificationMapper.updateReadAll(receiverId);
    }
}
