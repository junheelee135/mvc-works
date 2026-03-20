package com.mvc.app.group.service;

import com.mvc.app.common.StorageService;
import com.mvc.app.group.dto.ChatFileDto;
import com.mvc.app.group.dto.ChatMessageDto;
import com.mvc.app.group.dto.ChatRoomDto;
import com.mvc.app.group.dto.ChatUserDto;
import com.mvc.app.group.mapper.ChatMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ChatMapper     chatMapper;
    private final StorageService storageService;

    private static final String UPLOAD_WEB_PATH = "upload/chat";

    private String getUploadPath() {
        return storageService.getRealPath(UPLOAD_WEB_PATH);
    }

    /* ── 직원 목록 (무한스크롤) ── */
    @Override
    public List<ChatUserDto> listChatUsers(ChatUserDto params) {
        return chatMapper.listChatUsers(params);
    }

    /* ── 내 프로젝트 목록 ── */
    @Override
    public List<Map<String, Object>> listMyProjects(String empId) {
        return chatMapper.listMyProjects(empId);
    }

    /* ── 채팅방 조회 또는 생성 ── */
    @Override
    @Transactional
    public ChatRoomDto getOrCreateRoom(String myEmpId, String targetEmpId) {
        // 1. 기존 방 조회 (중복 방 생성 방지)
        ChatRoomDto room = chatMapper.findRoomByUsers(myEmpId, targetEmpId);
        if (room != null) {
            return room;
        }

        // 2. 신규 방 생성
        Long roomId = chatMapper.nextRoomSeq();
        ChatRoomDto newRoom = new ChatRoomDto();
        newRoom.setRoomId(roomId);
        newRoom.setUserAid(myEmpId);
        newRoom.setUserBid(targetEmpId);
        chatMapper.insertRoom(newRoom);

        // 3. 참여자 등록 (chatroommember - 권한 검증 테이블)
        chatMapper.insertRoomMember(chatMapper.nextRoomMemberSeq(), roomId, myEmpId);
        chatMapper.insertRoomMember(chatMapper.nextRoomMemberSeq(), roomId, targetEmpId);

        newRoom.setStatus("ACTIVE");
        return newRoom;
    }

    /* ── 채팅방 참여자 검증 ── */
    @Override
    public boolean isRoomMember(Long roomId, String empId) {
        return chatMapper.countRoomMember(roomId, empId) > 0;
    }

    /* ── 텍스트 메시지 저장 ── */
    @Override
    @Transactional
    public ChatMessageDto saveMessage(ChatMessageDto dto) {
        // 빈 메시지 차단
        if (dto.getContent() == null || dto.getContent().trim().isEmpty()) {
            throw new IllegalArgumentException("빈 메시지는 전송할 수 없습니다.");
        }
        // 200자 길이 제한
        if (dto.getContent().length() > 200) {
            throw new IllegalArgumentException("메시지는 200자를 초과할 수 없습니다.");
        }

        Long messageId = chatMapper.nextMessageSeq();
        dto.setMessageId(messageId);
        dto.setMsgType("TEXT");

        chatMapper.insertMessage(dto);
        chatMapper.updateRoomLastMessageAt(dto.getRoomId());

        return dto;
    }

    /* ── 메시지 목록 조회 ── */
    @Override
    public List<ChatMessageDto> listMessages(Long roomId, int offset, int size) {
        return chatMapper.listMessages(roomId, offset, size);
    }

    /* ── 입장 시 미읽음 일괄 읽음 처리 ── */
    @Override
    @Transactional
    public void markAsRead(Long roomId, String empId) {
        chatMapper.markAsRead(roomId, empId);
    }

    /* ── 파일 업로드 후 메시지 저장 ── */
    @Override
    @Transactional
    public ChatMessageDto saveFileMessage(Long roomId, String senderId,
                                          MultipartFile file) throws Exception {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("파일이 없습니다.");
        }

        // 파일 업로드
        String saveName = storageService.uploadFileToServer(file, getUploadPath());
        if (saveName == null) {
            throw new RuntimeException("파일 업로드에 실패했습니다.");
        }

        String originalName = file.getOriginalFilename();
        String fileExt      = "";
        if (originalName != null && originalName.contains(".")) {
            fileExt = originalName.substring(originalName.lastIndexOf('.') + 1).toLowerCase();
        }

        // 메시지 저장 (content = 파일명으로 저장)
        Long messageId = chatMapper.nextMessageSeq();
        ChatMessageDto msgDto = new ChatMessageDto();
        msgDto.setMessageId(messageId);
        msgDto.setRoomId(roomId);
        msgDto.setSenderId(senderId);
        msgDto.setMsgType("FILE");
        msgDto.setContent(originalName);    // 파일명을 content에 저장
        chatMapper.insertMessage(msgDto);

        // 파일 정보 저장
        Long fileId = chatMapper.nextFileSeq();
        ChatFileDto fileDto = new ChatFileDto();
        fileDto.setFileId(fileId);
        fileDto.setMessageId(messageId);
        fileDto.setRoomId(roomId);
        fileDto.setUploaderId(senderId);
        fileDto.setOriginalName(originalName);
        fileDto.setSaveName(saveName);
        fileDto.setFileSize(file.getSize());
        fileDto.setFileExt(fileExt);
        chatMapper.insertFile(fileDto);

        // 채팅방 마지막 메시지 시각 갱신
        chatMapper.updateRoomLastMessageAt(roomId);

        // 응답 DTO 구성
        msgDto.setFileId(fileId);
        msgDto.setOriginalName(originalName);
        msgDto.setSaveName(saveName);
        msgDto.setFileSize(file.getSize());
        msgDto.setFileExt(fileExt);
        
        msgDto.setSentAt(java.time.LocalDateTime.now()
        .format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss")));

        return msgDto;
    }

    /* ── 파일 다운로드 ── */
    @Override
    public ResponseEntity<?> downloadFile(Long fileId) throws Exception {
        ChatFileDto fileDto = chatMapper.findFileById(fileId);
        if (fileDto == null) {
            throw new IllegalArgumentException("파일을 찾을 수 없습니다.");
        }
        return storageService.downloadFile(
                getUploadPath(),
                fileDto.getSaveName(),
                fileDto.getOriginalName()
        );
    }
}
