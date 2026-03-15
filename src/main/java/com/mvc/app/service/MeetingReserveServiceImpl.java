package com.mvc.app.service;

import com.mvc.app.domain.dto.MeetingReserveDto;
import com.mvc.app.mapper.MeetingReserveMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MeetingReserveServiceImpl implements MeetingReserveService {

    private final MeetingReserveMapper mapper;

    @Override
    public List<MeetingReserveDto> listByDate(String reserveDate, Long roomId) {
        Map<String, Object> param = new HashMap<>();
        param.put("reserveDate", reserveDate);
        param.put("roomId", roomId != null ? roomId : 0);
        return mapper.listByDate(param);
    }

    @Override
    public List<MeetingReserveDto> listByMonth(String yearMonth) {
        Map<String, Object> param = new HashMap<>();
        param.put("yearMonth", yearMonth);
        return mapper.listByMonth(param);
    }

    @Override
    public MeetingReserveDto getReserve(long reserveId) {
        return mapper.getReserve(reserveId);
    }

    @Override
    @Transactional
    public void insertReserve(MeetingReserveDto dto) {
        // 시간 중복 체크
        Map<String, Object> param = new HashMap<>();
        param.put("roomId", dto.getRoomId());
        param.put("reserveDate", dto.getReserveDate());
        param.put("startTime", dto.getStartTime());
        param.put("endTime", dto.getEndTime());

        int overlap = mapper.checkOverlap(param);
        if (overlap > 0) {
            throw new IllegalStateException("해당 시간대에 이미 예약이 있습니다.");
        }

        mapper.insertReserve(dto);
    }

    @Override
    @Transactional
    public void cancelReserve(long reserveId) {
        mapper.cancelReserve(reserveId);
    }

    @Override
    public Map<String, Integer> getStats(String empId) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("today", mapper.countToday(empId));
        stats.put("week", mapper.countWeek(empId));
        stats.put("month", mapper.countMonth(empId));
        return stats;
    }
}
