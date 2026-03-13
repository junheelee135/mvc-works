package com.mvc.app.aop.mapper;

import com.mvc.app.aop.dto.ActivityLogDto;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ActivityLogMapper {
    void insertActivityLog(ActivityLogDto dto);
}
