package com.mvc.app.service;

import com.mvc.app.domain.dto.ActivityLogDto;
import org.springframework.core.io.Resource;

import java.util.List;
import java.util.Map;

public interface ActivityLogService {

    int dataCount(Map<String, Object> params);
    List<ActivityLogDto> listActivityLog(Map<String, Object> params);

    /** 단건 조회 */
    ActivityLogDto findById(Long logId);

    /** 엑셀 다운로드 */
    Resource exportExcel(Map<String, Object> params) throws Exception;
}
