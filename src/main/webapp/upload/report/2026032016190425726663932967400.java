package com.mvc.app.group.controller;

import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.group.dto.ChatMessageDto;
import com.mvc.app.group.dto.ChatRoomDto;
import com.mvc.app.group.dto.ChatUserDto;
import com.mvc.app.group.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Slf4j
@Controller
@RequiredArgsConstructor
@RequestMapping("/chat")
public class ChatController {

    private final ChatService chatService;

    /* ── 채팅 메인 페이지 뷰 ── */
    @GetMapping
    public String chatMain() {
        return "groupware/chatMain";
    }

    /* ==========================================================
       REST API (/api/chat/...)
       ========================================================== */

    /**
     * 내가 참여 중인 프로젝트 목록
     * GET /api/chat/projects
     */
    @GetMapping("/api/chat/projects")
    @ResponseBody
    public ResponseEntity<?> getMyProjects(
            @SessionAttribute("member") SessionInfo info) {
        try {
            List<Map<String, Object>> projects = chatService.listMyProjects(info.getEmpId());
            return ResponseEntity.ok(projects);
        } catch (Exception e) {
            log.error("프로젝트 목록 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    /**
     * 직원 목록 (무한스크롤)
     * GET /api/chat/users
     */
    @GetMapping("/api/chat/users")
    @ResponseBody
    public ResponseEntity<?> getChatUsers(
            @RequestParam(defaultValue = "")  String projectId,
            @RequestParam(defaultValue = "")  String keyword,
            @RequestParam(defaultValue = "0") int    offset,
            @RequestParam(defaultValue = "20") int   size,
            @SessionAttribute("member") SessionInfo  info) {
        try {
            ChatUserDto params = new ChatUserDto();
            params.setMyEmpId(info.getEmpId());
            params.setProjectId(projectId.isBlank() ? null : projectId);
            params.setKeyword(keyword.isBlank()     ? null : keyword);
            params.setOffset(offset);
            params.setSize(size);

            List<ChatUserDto> list = chatService.listChatUsers(params);
            return ResponseEntity.ok(Map.of(
                    "list",    list,
                    "hasMore", list.size() == size
            ));
        } catch (Exception e) {
            log.error("직원 목록 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    /**
     * 채팅방 조회 또는 생성
     * POST /api/chat/rooms
     */
    @PostMapping("/api/chat/rooms")
    @ResponseBody
    public ResponseEntity<?> getOrCreateRoom(
            @RequestBody Map<String, String>      body,
            @SessionAttribute("member") SessionInfo info) {
        try {
            String targetEmpId = body.get("targetEmpId");
            if (targetEmpId == null || targetEmpId.isBlank()) {
                return ResponseEntity.badRequest().body("대상 사원번호가 없습니다.");
            }
            if (targetEmpId.equals(info.getEmpId())) {
                return ResponseEntity.badRequest().body("본인과 채팅할 수 없습니다.");
            }

            ChatRoomDto room = chatService.getOrCreateRoom(info.getEmpId(), targetEmpId);
            return ResponseEntity.ok(room);
        } catch (Exception e) {
            log.error("채팅방 생성 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    /**
     * 채팅 메시지 목록 조회 (무한스크롤)
     * GET /api/chat/rooms/{roomId}/messages
     */
    @GetMapping("/api/chat/rooms/{roomId}/messages")
    @ResponseBody
    public ResponseEntity<?> getMessages(
            @PathVariable Long roomId,
            @RequestParam(defaultValue = "0")  int offset,
            @RequestParam(defaultValue = "20") int size,
            @SessionAttribute("member") SessionInfo info) {
        try {
            // 17-2: 채팅방 참여자 검증
            if (!chatService.isRoomMember(roomId, info.getEmpId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("채팅방 접근 권한이 없습니다.");
            }

            List<ChatMessageDto> list = chatService.listMessages(roomId, offset, size);
            return ResponseEntity.ok(Map.of(
                    "list",    list,
                    "hasMore", list.size() == size
            ));
        } catch (Exception e) {
            log.error("메시지 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    /**
     * 파일 업로드 (채팅)
     * POST /api/chat/rooms/{roomId}/files
     */
    @PostMapping("/api/chat/rooms/{roomId}/files")
    @ResponseBody
    public ResponseEntity<?> uploadFile(
            @PathVariable Long roomId,
            @RequestParam("file") MultipartFile file,
            @SessionAttribute("member") SessionInfo info) {
        try {
            // 권한 검증
            if (!chatService.isRoomMember(roomId, info.getEmpId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("채팅방 접근 권한이 없습니다.");
            }

            ChatMessageDto saved = chatService.saveFileMessage(
                    roomId, info.getEmpId(), file);
            saved.setType("CHAT");
            saved.setSenderName(info.getName());
            saved.setSenderAvatar(info.getAvatar());

            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            log.error("파일 업로드 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("파일 오류: " + e.getMessage());
        }
    }

    /**
     * 파일 다운로드
     * GET /api/chat/files/{fileId}/download
     */
    @GetMapping("/api/chat/files/{fileId}/download")
    @ResponseBody
    public ResponseEntity<?> downloadFile(
            @PathVariable Long fileId,
            @SessionAttribute("member") SessionInfo info) {
        try {
            return chatService.downloadFile(fileId);
        } catch (Exception e) {
            log.error("파일 다운로드 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("파일 오류: " + e.getMessage());
        }
    }
}
