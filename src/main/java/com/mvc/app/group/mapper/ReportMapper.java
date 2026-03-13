package com.mvc.app.group.mapper;

import com.mvc.app.group.dto.ReportDto;
import com.mvc.app.group.dto.ReportFileDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface ReportMapper {

    // ── 보고서 목록 / 카운트 ───────────────────────────────────
    int reportCount(Map<String, Object> map);
    List<ReportDto> listReport(Map<String, Object> map);

    // ── 피드백 목록 / 카운트 ───────────────────────────────────
    int feedbackCount(Map<String, Object> map);
    List<ReportDto> listFeedback(Map<String, Object> map);

    // ── 단건 조회 ──────────────────────────────────────────────
    ReportDto findReportById(Long filenum);
    ReportDto findFeedbackById(Long filenum);

    // ── 보고서에 달린 피드백 단건 조회 (reportDetail 인라인 표시용) ──
    ReportDto findFeedbackByParent(Long parent);

    // ── 시퀀스 채번 ────────────────────────────────────────────
    Long nextReportSeq();
    Long nextReportFileSeq();

    // ── 보고서 등록 / 수정 / 삭제 ──────────────────────────────
    void insertReport(ReportDto dto);
    void updateReport(ReportDto dto);
    void deleteReport(Long filenum);

    // ── 피드백 등록 / 수정 / 삭제 ──────────────────────────────
    void insertFeedback(ReportDto dto);
    void updateFeedback(ReportDto dto);
    void deleteFeedback(Long filenum);

    // ── 조회수 증가 ────────────────────────────────────────────
    void incrementHitcount(Long filenum);

    // ── 첨부파일 등록 / 단건 조회 / 목록 조회 / 삭제 ──────────
    void insertReportFile(ReportFileDto fileDto);
    ReportFileDto findFileById(Long filenum);
    List<ReportFileDto> listFilesByReport(Long filenum2);
    void deleteReportFile(Long filenum);

    // ── 보고서 삭제 시 연관 파일 전체 삭제 ───────────────────
    void deleteFilesByReport(Long filenum2);

    // ── 피드백 작성자의 프로젝트와 겹치는 사원 empId 목록 ─────
    // 요구사항 3: 피드백 작성자와 같은 projectId를 가진 사원들 조회
    List<String> findEmpIdsBySharedProject(@Param("empId") String empId);
}
