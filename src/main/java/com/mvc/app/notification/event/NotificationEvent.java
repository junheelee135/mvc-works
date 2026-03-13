package com.mvc.app.notification.event;

import lombok.Getter;

/**
 * 알림 이벤트 클래스 모음
 *
 * 사용 패턴:
 *   eventPublisher.publishEvent(new NotificationEvent.Approval(...));
 *
 * 종류:
 *   Approval  - 결재 알림    (VUE  이동: /approval/view?docId={id})
 *   Project   - 프로젝트     (PAGE 이동: /projects/ganttarticle)
 *   Auth      - 권한 변동    (NONE 이동 없음, 기존→변경 권한명 표시)
 *   Feedback  - 보고서 피드백 (PAGE 이동: /report/detail?filenum={id})
 *   Chat      - 채팅 알림    (VUE  이동: 미구현, 확장성 고려)
 */
public class NotificationEvent {

    // ══════════════════════════════════════════
    // [1] 결재 알림
    // ══════════════════════════════════════════
    @Getter
    public static class Approval {
        private final String receiverId;   // 수신자 사번 (결재 요청자)
        private final String senderId;     // 발신자 사번 (결재 처리자)
        private final String senderName;   // 발신자 이름
        private final Long   docId;        // 결재 문서 ID
        private final String docTitle;     // 결재 문서 제목
        private final String actionType;   // 결재 상태

        public Approval(String receiverId, String senderId, String senderName,
                Long docId, String docTitle, String actionType) {  // ← 파라미터 추가
        		this.receiverId = receiverId;
        		this.senderId   = senderId;
        		this.senderName = senderName;
        		this.docId      = docId;
        		this.docTitle   = docTitle;
        		this.actionType = actionType;   // ← 이거 추가
        }
    }

    // ══════════════════════════════════════════
    // [2] 프로젝트 알림
    // ══════════════════════════════════════════
    @Getter
    public static class Project {
        private final String receiverId;
        private final String senderId;
        private final String senderName;
        private final String projectName;
        private final String message;

        public Project(String receiverId, String senderId, String senderName,
                       String projectName, String message) {
            this.receiverId  = receiverId;
            this.senderId    = senderId;
            this.senderName  = senderName;
            this.projectName = projectName;
            this.message     = message;
        }
    }

    // ══════════════════════════════════════════
    // [3] 권한 변동 알림 (화면 이동 없음)
    // ══════════════════════════════════════════
    @Getter
    public static class Auth {
        private final String receiverId;      // 수신자 사번 (권한 변경 대상자)
        private final String senderId;        // 발신자 사번 (처리자)
        private final String senderName;      // 발신자 이름
        private final String beforeAuthName;  // 변경 전 권한명
        private final String afterAuthName;   // 변경 후 권한명

        public Auth(String receiverId, String senderId, String senderName,
                    String beforeAuthName, String afterAuthName) {
            this.receiverId     = receiverId;
            this.senderId       = senderId;
            this.senderName     = senderName;
            this.beforeAuthName = beforeAuthName;
            this.afterAuthName  = afterAuthName;
        }
    }

    // ══════════════════════════════════════════
    // [4] 보고서 피드백 알림
    // ══════════════════════════════════════════
    @Getter
    public static class Feedback {
        private final String receiverId;   // 수신자 사번 (보고서 작성자)
        private final String senderId;     // 발신자 사번 (피드백 작성자)
        private final String senderName;   // 발신자 이름
        private final Long   filenum;      // 보고서 filenum
        private final String reportTitle;  // 보고서 제목

        public Feedback(String receiverId, String senderId, String senderName,
                        Long filenum, String reportTitle) {
            this.receiverId  = receiverId;
            this.senderId    = senderId;
            this.senderName  = senderName;
            this.filenum     = filenum;
            this.reportTitle = reportTitle;
        }
    }

    // ══════════════════════════════════════════
    // [5] 채팅 알림 (URL 미구현 - 확장성 고려)
    // ══════════════════════════════════════════
    @Getter
    public static class Chat {
        private final String receiverId;
        private final String senderId;
        private final String senderName;
        private final String roomId;      // 채팅방 ID (미구현 시 null 가능)
        private final String preview;     // 메시지 미리보기

        public Chat(String receiverId, String senderId, String senderName,
                    String roomId, String preview) {
            this.receiverId = receiverId;
            this.senderId   = senderId;
            this.senderName = senderName;
            this.roomId     = roomId;
            this.preview    = preview;
        }
    }
}
