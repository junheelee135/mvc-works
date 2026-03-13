package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.mvc.app.domain.dto.NoticeDto;
import com.mvc.app.domain.dto.NoticeFileDto;

@Mapper
public interface NoticeMapper {

    // ── 공지사항 ──
    void insertNotice(NoticeDto dto) throws SQLException;
    void updateNotice(NoticeDto dto) throws SQLException;
    void deleteNotice(long noticenum) throws SQLException;         // state = 0
    List<NoticeDto> listNotice(Map<String, Object> map) throws SQLException;
    int countNotice(Map<String, Object> map) throws SQLException;
    NoticeDto getNotice(long noticenum) throws SQLException;
    void increaseHit(long noticenum) throws SQLException;          // 조회수 +1

    // ── 첨부파일 ──
    void insertFile(NoticeFileDto dto) throws SQLException;
    void deleteFile(long filenum) throws SQLException;
    List<NoticeFileDto> getFiles(long noticenum) throws SQLException;
    NoticeFileDto getFile(long filenum) throws SQLException;
}
