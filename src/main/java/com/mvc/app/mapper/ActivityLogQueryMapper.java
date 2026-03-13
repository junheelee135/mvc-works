package com.mvc.app.mapper;

import com.mvc.app.domain.dto.ActivityLogDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface ActivityLogQueryMapper {

    // ── 목록 / 카운트 ──────────────────────────────────────────
    int dataCount(Map<String, Object> map);
    List<ActivityLogDto> listActivityLog(Map<String, Object> map);

    // ── 단건 조회 ──────────────────────────────────────────────
    ActivityLogDto findById(Long logId);
}
