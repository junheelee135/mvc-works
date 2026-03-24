package com.mvc.app.group.controller;

import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.group.dto.ChatMessageDto;
import com.mvc.app.group.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.Map;

/**
 * STOMP 메시지 처리 컨트롤러
 *
 * 클라이언트 → 서버 전송 경로 (/app prefix 포함)
 *   /app/chat/message   : 텍스트 메시지 전송
 *   /app/chat/read      : 읽음 처리 요청
 *   /app/chat/enter     : 채팅방 입장 알림
 *   /app/chat/leave     : 채팅방 퇴장 알림
 *
 * 서버 → 클라이언트 브로드캐스트
 *   /topic/chat/{roomId} : 채팅방 구독
 */
@Slf4j
@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final ChatService           chatService;
    private final SimpMessagingTemplate messagingTemplate;

    /**
     * 텍스트 메시지 전송
     * 클라이언트: stompClient.publish({ destination: '/app/chat/message', body: JSON.stringify(dto) })
     */
    @MessageMapping("/chat/message")
    public void sendMessage(@Payload ChatMessageDto dto,
                            SimpMessageHeaderAccessor headerAccessor) {
        try {
            // 세션에서 발신자 정보 추출
            SessionInfo session = getSession(headerAccessor);
            if (session == null) return;

            // 채팅방 참여자 검증 (권한 체크)
            if (!chatService.isRoomMember(dto.getRoomId(), session.getEmpId())) {
                log.warn("채팅방 권한 없음 - roomId:{}, empId:{}", dto.getRoomId(), session.getEmpId());
                return;
            }

            dto.setSenderId(session.getEmpId());
            dto.setSenderName(session.getName());
            dto.setSenderAvatar(session.getAvatar());
            
            if ("FILE".equals(dto.getMsgType())) {
                dto.setType("CHAT");
                messagingTemplate.convertAndSend("/topic/chat/" + dto.getRoomId(), dto);
                return;
            }
            
            // DB 저장 (빈 메시지·200자 제한 검증 포함)
            ChatMessageDto saved = chatService.saveMessage(dto);
            saved.setType("CHAT");

            // 채팅방 구독자 전체에게 브로드캐스트
            messagingTemplate.convertAndSend(
                    "/topic/chat/" + dto.getRoomId(), saved);

        } catch (IllegalArgumentException e) {
            // 빈 메시지 / 길이 초과 → 발신자에게만 에러 전송
            sendError(headerAccessor, dto.getRoomId(), e.getMessage());
        } catch (Exception e) {
            log.error("메시지 전송 오류", e);
            sendError(headerAccessor, dto.getRoomId(), "전송 실패");
        }
    }

    /**
     * 읽음 처리 요청
     * 클라이언트: stompClient.publish({ destination: '/app/chat/read', body: JSON.stringify({ roomId }) })
     */
    @MessageMapping("/chat/read")
    public void markRead(@Payload Map<String, Object> payload,
                         SimpMessageHeaderAccessor headerAccessor) {
        try {
            SessionInfo session = getSession(headerAccessor);
            if (session == null) return;

            Long roomId = Long.valueOf(payload.get("roomId").toString());

            // 권한 검증
            if (!chatService.isRoomMember(roomId, session.getEmpId())) return;

            // 미읽음 일괄 읽음 처리
            chatService.markAsRead(roomId, session.getEmpId());

            // 상대방에게 읽음 알림 브로드캐스트
            ChatMessageDto readDto = new ChatMessageDto();
            readDto.setType("READ");
            readDto.setRoomId(roomId);
            readDto.setSenderId(session.getEmpId());

            messagingTemplate.convertAndSend("/topic/chat/" + roomId, readDto);

        } catch (Exception e) {
            log.error("읽음 처리 오류", e);
        }
    }

    /**
     * 채팅방 입장 알림 (상대방 온라인 여부 갱신용)
     */
    @MessageMapping("/chat/enter")
    public void enter(@Payload Map<String, Object> payload,
                      SimpMessageHeaderAccessor headerAccessor) {
        try {
            SessionInfo session = getSession(headerAccessor);
            if (session == null) return;

            Long roomId = Long.valueOf(payload.get("roomId").toString());
            if (!chatService.isRoomMember(roomId, session.getEmpId())) return;

            ChatMessageDto enterDto = new ChatMessageDto();
            enterDto.setType("ENTER");
            enterDto.setRoomId(roomId);
            enterDto.setSenderId(session.getEmpId());
            enterDto.setSenderName(session.getName());

            messagingTemplate.convertAndSend("/topic/chat/" + roomId, enterDto);

        } catch (Exception e) {
            log.error("입장 알림 오류", e);
        }
    }

    /**
     * 채팅방 퇴장 알림
     */
    @MessageMapping("/chat/leave")
    public void leave(@Payload Map<String, Object> payload,
                      SimpMessageHeaderAccessor headerAccessor) {
        try {
            SessionInfo session = getSession(headerAccessor);
            if (session == null) return;

            Long roomId = Long.valueOf(payload.get("roomId").toString());

            ChatMessageDto leaveDto = new ChatMessageDto();
            leaveDto.setType("LEAVE");
            leaveDto.setRoomId(roomId);
            leaveDto.setSenderId(session.getEmpId());

            messagingTemplate.convertAndSend("/topic/chat/" + roomId, leaveDto);

        } catch (Exception e) {
            log.error("퇴장 알림 오류", e);
        }
    }

    /* ── 헬퍼 ── */
    private SessionInfo getSession(SimpMessageHeaderAccessor headerAccessor) {
        Map<String, Object> attrs = headerAccessor.getSessionAttributes();
        if (attrs == null) return null;
        return (SessionInfo) attrs.get("member");
    }

    private void sendError(SimpMessageHeaderAccessor headerAccessor,
                           Long roomId, String message) {
        ChatMessageDto errDto = new ChatMessageDto();
        errDto.setType("ERROR");
        errDto.setRoomId(roomId);
        errDto.setContent(message);

        String sessionId = headerAccessor.getSessionId();
        messagingTemplate.convertAndSendToUser(
                sessionId, "/queue/errors", errDto,
                org.springframework.messaging.simp.SimpMessageHeaderAccessor
                        .create(org.springframework.messaging.simp.SimpMessageType.MESSAGE)
                        .getMessageHeaders()
        );
    }
}
