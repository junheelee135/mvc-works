package com.mvc.app.service;

import com.mvc.app.domain.dto.ActivityLogDto;
import com.mvc.app.mapper.ActivityLogQueryMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class ActivityLogServiceImpl implements ActivityLogService {

    private final ActivityLogQueryMapper mapper;

    // ──────────────────────────────────────────────
    // [1] 건수
    // ──────────────────────────────────────────────
    @Override
    public int dataCount(Map<String, Object> params) {
        try {
            return mapper.dataCount(params);
        } catch (Exception e) {
            log.error("dataCount error", e);
            return 0;
        }
    }

    // ──────────────────────────────────────────────
    // [2] 목록
    // ──────────────────────────────────────────────
    @Override
    public List<ActivityLogDto> listActivityLog(Map<String, Object> params) {
        try {
            return mapper.listActivityLog(params);
        } catch (Exception e) {
            log.error("listActivityLog error", e);
            return new ArrayList<>();
        }
    }

    // ──────────────────────────────────────────────
    // [3] 단건
    // ──────────────────────────────────────────────
    @Override
    public ActivityLogDto findById(Long logId) {
        try {
            return mapper.findById(logId);
        } catch (Exception e) {
            log.error("findById error logId={}", logId, e);
            return null;
        }
    }

    // ──────────────────────────────────────────────
    // [5] 엑셀 다운로드
    // ──────────────────────────────────────────────
    @Override
    public Resource exportExcel(Map<String, Object> params) throws Exception {
        params.put("offset", 0);
        params.put("size", Integer.MAX_VALUE);
        List<ActivityLogDto> list = mapper.listActivityLog(params);

        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("활동로그");

            // 헤더 스타일
            CellStyle headerStyle = wb.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.CORNFLOWER_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            Font hFont = wb.createFont();
            hFont.setBold(true);
            hFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(hFont);

            String[] headers = {
                "로그ID", "수행자 사원번호", "수행자 이름",
                "작업유형", "메뉴", "대상 사원번호",
                "처리결과", "오류메시지", "접속IP", "로그일시"
            };

            Row header = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = header.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 5500);
            }

            int rowNum = 1;
            for (ActivityLogDto dto : list) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(dto.getLogId() != null ? dto.getLogId() : 0);
                row.createCell(1).setCellValue(nvl(dto.getActorEmpId()));
                row.createCell(2).setCellValue(nvl(dto.getActorName()));
                row.createCell(3).setCellValue(nvl(dto.getActionType()));
                row.createCell(4).setCellValue(nvl(dto.getTargetMenu()));
                row.createCell(5).setCellValue(nvl(dto.getTargetEmpIds()));
                row.createCell(6).setCellValue(nvl(dto.getResult()));
                row.createCell(7).setCellValue(nvl(dto.getErrorMsg()));
                row.createCell(8).setCellValue(nvl(dto.getIpAddr()));
                row.createCell(9).setCellValue(nvl(dto.getLogDate()));
            }

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            wb.write(baos);
            return new ByteArrayResource(baos.toByteArray());
        }
    }

    private String nvl(String s) { return s == null ? "" : s; }
}
