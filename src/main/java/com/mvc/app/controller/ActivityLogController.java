package com.mvc.app.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.mvc.app.domain.dto.ActivityLogDto;
import com.mvc.app.service.ActivityLogService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * ActivityLogController — 활동 로그 REST API
 *
 *  GET  /api/activity-log                직원관리 활동 로그 목록 조회 (검색 + 페이징)
 *  GET  /api/activity-log/{logId}        로그 단건 조회
 *  GET  /api/activity-log/excel/download 엑셀 다운로드
 */
@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/activity-log")
public class ActivityLogController {

    private final ActivityLogService activityLogService;

    // ──────────────────────────────────────────────
    // [1] 활동 로그 목록 조회 (GET /api/activity-log)
    // ──────────────────────────────────────────────
    @GetMapping
    public ResponseEntity<?> getActivityLogList(
            @RequestParam(name = "page",        defaultValue = "1")     int currentPage,
            @RequestParam(name = "pageSize",    defaultValue = "10")    int size,
            @RequestParam(name = "actorEmpId",  defaultValue = "")      String actorEmpId,
            @RequestParam(name = "actorName",   defaultValue = "")      String actorName,
            @RequestParam(name = "targetMenu",  defaultValue = "")      String targetMenu,
            @RequestParam(name = "result",      defaultValue = "")      String result,
            @RequestParam(name = "actionType",  defaultValue = "")      String actionType,
            @RequestParam(name = "startDate",   defaultValue = "")      String startDate,
            @RequestParam(name = "endDate",     defaultValue = "")      String endDate,
            @RequestParam(name = "sortCol",     defaultValue = "logDate") String sortCol,
            @RequestParam(name = "sortDir",     defaultValue = "desc")  String sortDir) {

        try {
            Map<String, Object> params = buildSearchParams(
                actorEmpId, actorName, targetMenu, result, actionType,
                startDate, endDate, sortCol, sortDir
            );

            int totalCount = activityLogService.dataCount(params);
            int totalPage  = (totalCount == 0) ? 0
                    : totalCount / size + (totalCount % size > 0 ? 1 : 0);

            currentPage = Math.min(currentPage, Math.max(totalPage, 1));
            int offset  = Math.max((currentPage - 1) * size, 0);
            params.put("offset", offset);
            params.put("size",   size);

            List<ActivityLogDto> list = activityLogService.listActivityLog(params);

            return ResponseEntity.ok(Map.of(
                "list",       list,
                "page",       currentPage,
                "totalPage",  totalPage,
                "totalCount", totalCount
            ));
        } catch (Exception e) {
            log.error("활동 로그 목록 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [2] 단건 조회 (GET /api/activity-log/{logId})
    // ──────────────────────────────────────────────
    @GetMapping("/{logId}")
    public ResponseEntity<?> getActivityLog(@PathVariable Long logId) {
        try {
            ActivityLogDto dto = activityLogService.findById(logId);
            if (dto == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("로그를 찾을 수 없습니다.");
            }
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            log.error("활동 로그 단건 조회 오류", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // [3] 엑셀 다운로드 (GET /api/activity-log/excel/download)
    // ──────────────────────────────────────────────
    @GetMapping("/excel/download")
    public ResponseEntity<?> downloadExcel(
            @RequestParam(name = "actorEmpId",  defaultValue = "") String actorEmpId,
            @RequestParam(name = "actorName",   defaultValue = "") String actorName,
            @RequestParam(name = "targetMenu",  defaultValue = "") String targetMenu,
            @RequestParam(name = "result",      defaultValue = "") String result,
            @RequestParam(name = "actionType",  defaultValue = "") String actionType,
            @RequestParam(name = "startDate",   defaultValue = "") String startDate,
            @RequestParam(name = "endDate",     defaultValue = "") String endDate) {

        try {
            Map<String, Object> params = buildSearchParams(
                actorEmpId, actorName, targetMenu, result, actionType,
                startDate, endDate, "logDate", "desc"
            );

            Resource resource = activityLogService.exportExcel(params);
            String filename = URLEncoder.encode("활동로그.xlsx", StandardCharsets.UTF_8)
                              .replace("+", "%20");

            return ResponseEntity.ok()
                    .header("Content-Disposition", "attachment; filename*=UTF-8''" + filename)
                    .header("Content-Type",
                            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                    .body(resource);
        } catch (Exception e) {
            log.error("활동 로그 엑셀 다운로드 오류", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    // ──────────────────────────────────────────────
    // 내부 헬퍼 — 검색 파라미터 Map 구성
    // ──────────────────────────────────────────────
    private Map<String, Object> buildSearchParams(
            String actorEmpId, String actorName, String targetMenu,
            String result, String actionType,
            String startDate, String endDate,
            String sortCol, String sortDir) {

        Map<String, Object> map = new HashMap<>();
        map.put("actorEmpId", actorEmpId.isBlank() ? null : actorEmpId.trim());
        map.put("actorName",  actorName.isBlank()  ? null : actorName.trim());
        map.put("targetMenu", targetMenu.isBlank()  ? null : targetMenu.trim());
        map.put("result",     result.isBlank()      ? null : result.trim());
        map.put("actionType", actionType.isBlank()  ? null : actionType.trim());
        map.put("startDate",  startDate.isBlank()   ? null : startDate.trim());
        map.put("endDate",    endDate.isBlank()      ? null : endDate.trim());

        // sortCol 화이트리스트 검증 (SQL Injection 방지)
        String safeCol = switch (sortCol) {
            case "logId", "actorEmpId", "actorName", "actionType",
                 "targetMenu", "result", "logDate" -> sortCol;
            default -> "logDate";
        };
        map.put("sortCol", safeCol);
        map.put("sortDir", "asc".equalsIgnoreCase(sortDir) ? "ASC" : "DESC");
        return map;
    }
}
