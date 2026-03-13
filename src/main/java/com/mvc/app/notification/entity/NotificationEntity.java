package com.mvc.app.notification.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * 알림 엔티티
 * 테이블: notification
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationEntity {

    private Long          notiId;       // 알림 ID (PK, Sequence)
    private String        receiverId;   // 수신자 사번
    private String        senderId;     // 발신자 사번
    private String        senderName;   // 발신자 이름
    private String        notiType;     // 알림 종류 (APPROVAL / PROJECT / AUTH / FEEDBACK / CHAT)
    private String        title;        // 알림 제목
    private String        message;      // 알림 내용
    private String        targetType;   // 이동 페이지 종류
    private String        targetId;     // 이동 대상 ID
    private String        targetUrl;    // 이동 URL
    private String        moveType;     // 이동 방식: PAGE / VUE / NONE
    private String        isRead;       // 읽음 여부 (N/Y)
    private LocalDateTime regDate;      // 등록일시
}
