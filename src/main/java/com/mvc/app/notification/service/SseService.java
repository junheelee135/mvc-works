package com.mvc.app.notification.service;

import com.mvc.app.notification.dto.NotificationDto;
import jakarta.annotation.PreDestroy;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * SSE 연결 관리 서비스
 * - 접속 중인 사용자의 SseEmitter를 ConcurrentHashMap으로 관리
 * - 알림 발생 시 해당 수신자에게 push
 */
@Slf4j
@Service
public class SseService {

    // 접속 중인 사용자 Emitter 보관 (empId → SseEmitter)
    private final Map<String, SseEmitter> emitterMap = new ConcurrentHashMap<>();

    /**
     * SSE 연결 등록
     * @param empId 사원번호
     * @return SseEmitter
     */
    public SseEmitter connect(String empId) {
        // 기존 연결이 있으면 먼저 종료
        SseEmitter existing = emitterMap.get(empId);
        if (existing != null) {
            existing.complete();
            emitterMap.remove(empId);
        }

        // 0L: 타임아웃을 Tomcat에 위임하지 않고 애플리케이션이 직접 제어
        // → @PreDestroy에서 complete() 호출 시 깔끔하게 종료됨
        // → Long.MAX_VALUE 사용 시 서버 종료 타이밍에 AsyncRequestTimeoutException 발생 가능
        SseEmitter emitter = new SseEmitter(0L);

        // 연결 종료 / 타임아웃 / 에러 시 Map에서 제거
        emitter.onCompletion(() -> {
            emitterMap.remove(empId);
            log.debug("[SSE] 연결 종료 empId={}", empId);
        });
        emitter.onTimeout(() -> {
            emitterMap.remove(empId);
            log.debug("[SSE] 타임아웃 empId={}", empId);
        });
        emitter.onError(e -> {
            emitterMap.remove(empId);
            log.debug("[SSE] 에러 empId={} error={}", empId, e.getMessage());
        });

        emitterMap.put(empId, emitter);

        // 연결 직후 더미 이벤트 전송 (브라우저 연결 확인용)
        try {
            emitter.send(SseEmitter.event()
                    .name("connect")
                    .data("connected"));
        } catch (IOException e) {
            emitterMap.remove(empId);
        }

        log.debug("[SSE] 연결 등록 empId={} 현재 접속자={}", empId, emitterMap.size());
        return emitter;
    }

    /**
     * 특정 사용자에게 알림 push
     * @param receiverId 수신자 사번
     * @param dto        전송할 알림 데이터
     */
    public void push(String receiverId, NotificationDto dto) {
        SseEmitter emitter = emitterMap.get(receiverId);
        if (emitter == null) {
            log.debug("[SSE] 수신자 미접속 receiverId={}", receiverId);
            return;
        }
        try {
            emitter.send(SseEmitter.event()
                    .name("notification")
                    .data(dto));
            log.debug("[SSE] push 완료 receiverId={} notiType={}", receiverId, dto.getNotiType());
        } catch (IOException e) {
            emitterMap.remove(receiverId);
            log.warn("[SSE] push 실패 receiverId={} error={}", receiverId, e.getMessage());
        }
    }

    /** 현재 접속 중인 사용자 수 (모니터링용) */
    public int getConnectedCount() {
        return emitterMap.size();
    }

    /**
     * 서버 종료 시 모든 SSE 연결을 명시적으로 닫음
     * → Graceful Shutdown이 "열린 요청 없음"으로 인식하여 즉시 종료
     * → AsyncRequestTimeoutException 발생 방지
     */
    @PreDestroy
    public void closeAllOnShutdown() {
        log.info("[SSE] 서버 종료 — SSE 연결 정리 시작, 활성 연결 수: {}", emitterMap.size());
        emitterMap.values().forEach(emitter -> {
            try {
                emitter.complete();
            } catch (Exception ignored) {
                // 이미 닫힌 연결은 무시
            }
        });
        emitterMap.clear();
        log.info("[SSE] SSE 연결 정리 완료");
    }
}