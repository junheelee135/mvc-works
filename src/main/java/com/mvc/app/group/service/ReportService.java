package com.mvc.app.group.service;

import com.mvc.app.group.dto.ReportDto;
import com.mvc.app.group.dto.ReportFileDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface ReportService {

    // ── 보고서 목록 / 카운트 ───────────────────────────────────
    int reportCount(Map<String, Object> params);
    List<ReportDto> listReport(Map<String, Object> params);

    // ── 피드백 목록 / 카운트 ───────────────────────────────────
    int feedbackCount(Map<String, Object> params);
    List<ReportDto> listFeedback(Map<String, Object> params);

    // ── 보고서 단건 조회 (조회수 증가 포함) ───────────────────
    ReportDto getReport(Long filenum);

    // ── 피드백 단건 조회 (조회수 증가 포함) ───────────────────
    ReportDto getFeedback(Long filenum);

    // ── 피드백 작성 화면용 원본 보고서 조회 (조회수 증가 없음) ─
    ReportDto getReportForRef(Long filenum);

    // ── 보고서 등록 / 수정 / 삭제 ──────────────────────────────
    void insertReport(ReportDto dto, List<MultipartFile> files) throws Exception;
    void updateReport(ReportDto dto, List<MultipartFile> newFiles, List<Long> deleteFilenums) throws Exception;
    void deleteReport(Long filenum) throws Exception;

    // ── 피드백 등록 / 수정 / 삭제 ──────────────────────────────
    void insertFeedback(ReportDto dto, List<MultipartFile> files) throws Exception;
    void updateFeedback(ReportDto dto, List<MultipartFile> newFiles, List<Long> deleteFilenums) throws Exception;
    void deleteFeedback(Long filenum) throws Exception;

    // ── 첨부파일 다운로드 ──────────────────────────────────────
    ResponseEntity<?> downloadFile(Long filenum) throws Exception;

    /** 보고서 상세 화면 인라인용 피드백 조회 (조회수 증가 없음) */
    ReportDto getInlineFeedback(Long reportFilenum);

    // ── 같은 프로젝트 사원 empId 목록 (접근 제어용) ───────────
    List<String> getSharedProjectEmpIds(String empId);
}
