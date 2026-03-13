package com.mvc.app.notification.dto;

import com.mvc.app.notification.entity.NotificationEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 알림 DTO
 * - SSE push 전송 시 사용
 * - 알림 목록 조회 응답 시 사용
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationDto {

    private Long   notiId;       // 알림 ID (읽음 처리 시 필요)
    private String senderId;     // 발신자 사번
    private String senderName;   // 발신자 이름
    private String notiType;     // 알림 종류 → 프론트 아이콘/색상 구분용
    private String title;        // 알림 제목
    private String message;      // 알림 내용
    private String targetType;   // 이동 페이지 종류
    private String targetId;     // 이동 대상 ID
    private String targetUrl;    // 이동 URL
    private String moveType;     // 이동 방식 (PAGE / VUE / NONE)
    private String isRead;       // 읽음 여부
    private String regDate;      // 등록일시 (포맷 문자열)

    /** Entity → DTO 변환 */
    public static NotificationDto from(NotificationEntity e) {
        return NotificationDto.builder()
                .notiId    (e.getNotiId())
                .senderId  (e.getSenderId())
                .senderName(e.getSenderName())
                .notiType  (e.getNotiType())
                .title     (e.getTitle())
                .message   (e.getMessage())
                .targetType(e.getTargetType())
                .targetId  (e.getTargetId())
                .targetUrl (e.getTargetUrl())
                .moveType  (e.getMoveType())
                .isRead    (e.getIsRead())
                .regDate   (e.getRegDate() != null
                        ? e.getRegDate().toString().substring(0, 16).replace("T", " ")
                        : "")
                .build();
    }
}
