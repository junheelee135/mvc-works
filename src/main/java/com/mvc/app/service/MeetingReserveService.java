package com.mvc.app.service;

import com.mvc.app.domain.dto.MeetingReserveDto;

import java.util.List;
import java.util.Map;

public interface MeetingReserveService {

    List<MeetingReserveDto> listByDate(String reserveDate, Long roomId);

    List<MeetingReserveDto> listByMonth(String yearMonth);

    MeetingReserveDto getReserve(long reserveId);

    void insertReserve(MeetingReserveDto dto);

    void cancelReserve(long reserveId);

    Map<String, Integer> getStats(String empId);
}
