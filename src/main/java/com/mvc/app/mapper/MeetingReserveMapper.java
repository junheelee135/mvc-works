package com.mvc.app.mapper;

import com.mvc.app.domain.dto.MeetingReserveDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface MeetingReserveMapper {

    List<MeetingReserveDto> listByDate(Map<String, Object> param);

    List<MeetingReserveDto> listByMonth(Map<String, Object> param);

    MeetingReserveDto getReserve(long reserveId);

    void insertReserve(MeetingReserveDto dto);

    void cancelReserve(long reserveId);

    int checkOverlap(Map<String, Object> param);

    int countToday(String empId);

    int countWeek(String empId);

    int countMonth(String empId);
}
