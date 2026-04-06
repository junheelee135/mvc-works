package com.mvc.app.service;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.NoticeDto;
import com.mvc.app.domain.dto.NoticeFileDto;
import com.mvc.app.mapper.NoticeMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class NoticeServiceImpl implements NoticeService {

    private final NoticeMapper mapper;

    @Value("${file.upload-root}")
    private String uploadPath;

    // ── 등록 ──
    @Override
    @Transactional
    public void insertNotice(NoticeDto dto, List<MultipartFile> files) throws Exception {
        mapper.insertNotice(dto);   // noticenum 채번됨
        saveFiles(dto.getNoticenum(), files);
    }

    // ── 수정 ──
    @Override
    @Transactional
    public void updateNotice(NoticeDto dto, List<MultipartFile> files, List<Long> deleteFileNums) throws Exception {
        mapper.updateNotice(dto);

        // 삭제 요청된 기존 파일 처리
        if (deleteFileNums != null) {
            for (long filenum : deleteFileNums) {
                NoticeFileDto file = mapper.getFile(filenum);
                if (file != null) {
                    new File(uploadPath + File.separator + file.getSavefilename()).delete();
                    mapper.deleteFile(filenum);
                }
            }
        }

        // 새 파일 저장
        saveFiles(dto.getNoticenum(), files);
    }

    // ── 삭제 (소프트 삭제) ──
    @Override
    public void deleteNotice(long noticenum) throws Exception {
        mapper.deleteNotice(noticenum);
    }

    // ── 목록 ──
    @Override
    public Map<String, Object> listNotice(Map<String, Object> map) throws Exception {
        List<NoticeDto> list  = mapper.listNotice(map);
        int             total = mapper.countNotice(map);
        Map<String, Object> result = new HashMap<>();
        result.put("list",  list);
        result.put("total", total);
        return result;
    }

    // ── 단건 조회 (조회수 증가 포함) ──
    @Override
    public NoticeDto getNotice(long noticenum) throws Exception {
        mapper.increaseHit(noticenum);
        NoticeDto dto = mapper.getNotice(noticenum);
        if (dto != null) {
            dto.setFiles(mapper.getFiles(noticenum));
        }
        return dto;
    }

    // ── 첨부파일 목록 ──
    @Override
    public List<NoticeFileDto> getFiles(long noticenum) throws Exception {
        return mapper.getFiles(noticenum);
    }

    // ── 첨부파일 단건 ──
    @Override
    public NoticeFileDto getFile(long filenum) throws Exception {
        return mapper.getFile(filenum);
    }

    // ── 첨부파일 삭제 ──
    @Override
    public void deleteFile(long filenum) throws Exception {
        NoticeFileDto file = mapper.getFile(filenum);
        if (file != null) {
            new File(uploadPath + File.separator + file.getSavefilename()).delete();
            mapper.deleteFile(filenum);
        }
    }

    // ── 내부: 파일 저장 공통 ──
    private void saveFiles(long noticenum, List<MultipartFile> files) throws Exception {
        if (files == null || files.isEmpty()) return;
        File dir = new File(uploadPath);
        if (!dir.exists()) dir.mkdirs();

        for (MultipartFile f : files) {
            if (f.isEmpty()) continue;
            
            String originalFilename = f.getOriginalFilename();
            
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            // 저장 파일명: UUID 기반 숫자 (savefilename이 NUMBER 타입이므로)
            long savedName = Math.abs(UUID.randomUUID().getMostSignificantBits());
            f.transferTo(new File(uploadPath + File.separator + savedName + extension));

            NoticeFileDto fileDto = new NoticeFileDto();
            fileDto.setNoticenum(noticenum);
            fileDto.setSavefilename(savedName + extension);
            fileDto.setOriginalfilename(f.getOriginalFilename());
            fileDto.setFilesize((int) f.getSize());
            mapper.insertFile(fileDto);
        }
    }
}
