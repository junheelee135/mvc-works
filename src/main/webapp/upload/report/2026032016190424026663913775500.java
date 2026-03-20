package com.mvc.app.group.scheduler;

import com.mvc.app.common.StorageService;
import com.mvc.app.group.dto.ChatFileDto;
import com.mvc.app.group.mapper.ChatMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 채팅 만료 데이터 정리 스케줄러
 * - 매일 새벽 3시에 7일 경과 메시지 및 파일 삭제
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChatScheduler {

    private final ChatMapper     chatMapper;
    private final StorageService storageService;

    private static final String UPLOAD_WEB_PATH = "upload/chat";

    /**
     * 매일 새벽 03:00 실행
     * 1. 만료 파일 목록 조회 → 물리 파일 삭제
     * 2. chatfile DB 삭제
     * 3. chatmessage DB 삭제
     */
    @Scheduled(cron = "0 0 3 * * *")
    @Transactional
    public void deleteExpiredChatData() {
        log.info("[ChatScheduler] 만료 채팅 데이터 삭제 시작");

        try {
            // 1. 만료 파일 물리 삭제
            List<ChatFileDto> expiredFiles = chatMapper.listExpiredFiles();
            String uploadPath = storageService.getRealPath(UPLOAD_WEB_PATH);

            for (ChatFileDto file : expiredFiles) {
                try {
                    storageService.deleteFile(uploadPath, file.getSaveName());
                } catch (Exception e) {
                    log.warn("[ChatScheduler] 물리 파일 삭제 실패: {}", file.getSaveName());
                }
            }

            // 2. DB 삭제 (chatfile → chatmessage 순서)
            int deletedFiles    = chatMapper.deleteExpiredFiles();
            int deletedMessages = chatMapper.deleteExpiredMessages();

            log.info("[ChatScheduler] 삭제 완료 - 파일: {}건, 메시지: {}건",
                    deletedFiles, deletedMessages);

        } catch (Exception e) {
            log.error("[ChatScheduler] 만료 데이터 삭제 오류", e);
        }
    }
}
