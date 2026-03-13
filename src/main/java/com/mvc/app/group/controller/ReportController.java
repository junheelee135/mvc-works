package com.mvc.app.group.controller;

import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.group.dto.ReportDto;
import com.mvc.app.group.service.ReportService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Controller
@RequestMapping("/report")
public class ReportController {

    private final ReportService reportService;

    private static final int PAGE_SIZE = 10;

    // ============================================================
    // 공통 헬퍼 - 세션 정보 추출
    // ============================================================
    private SessionInfo getSession(HttpSession session) {
        return (SessionInfo) session.getAttribute("member");
    }

    /** 접근 제어용 Map 파라미터 구성 */
    private void fillAccessParams(Map<String, Object> params, SessionInfo si) {
        params.put("sessionEmpId", si.getEmpId());
        params.put("userLevel",    si.getUserLevel());
        // levelCode 51~98: 같은 프로젝트 사원 목록 필요
        if (si.getUserLevel() >= 51 && si.getUserLevel() < 99) {
            List<String> empIdList = reportService.getSharedProjectEmpIds(si.getEmpId());
            params.put("empIdList", empIdList);
        }
    }

    // ============================================================
    // 목록 (Main - reportMain.jsp 포함 진입점)
    // ============================================================
    @GetMapping("/list")
    public String list(
            @RequestParam(name = "page",        defaultValue = "1")      int    page,
            @RequestParam(name = "fbPage",      defaultValue = "1")      int    fbPage,
            @RequestParam(name = "writerName",  defaultValue = "")       String writerName,
            @RequestParam(name = "subject",     defaultValue = "")       String subject,
            @RequestParam(name = "periodStart", defaultValue = "")       String periodStart,
            @RequestParam(name = "periodEnd",   defaultValue = "")       String periodEnd,
            @RequestParam(name = "feedbackYn",  defaultValue = "")       String feedbackYn,
            @RequestParam(name = "targetName",  defaultValue = "")       String targetName,
            @RequestParam(name = "startDate",   defaultValue = "")       String startDate,
            @RequestParam(name = "endDate",     defaultValue = "")       String endDate,
            @RequestParam(name = "tab",         defaultValue = "report") String tab,
            HttpSession session,
            Model model) {

        SessionInfo si = getSession(session);

        // ── 보고서 탭 ──────────────────────────────────────────
        Map<String, Object> rParams = new HashMap<>();
        rParams.put("writerName",  writerName);
        rParams.put("subject",     subject);
        rParams.put("periodStart", periodStart);
        rParams.put("periodEnd",   periodEnd);
        rParams.put("feedbackYn",  feedbackYn);
        fillAccessParams(rParams, si);

        int reportTotal = reportService.reportCount(rParams);
        int reportTotalPage = Math.max(1, (int) Math.ceil((double) reportTotal / PAGE_SIZE));
        page = Math.max(1, Math.min(page, reportTotalPage));
        rParams.put("startRow", (page - 1) * PAGE_SIZE + 1);
        rParams.put("endRow",    page * PAGE_SIZE);

        List<ReportDto> reportList = reportService.listReport(rParams);

        model.addAttribute("reportList",      reportList);
        model.addAttribute("reportTotal",     reportTotal);
        model.addAttribute("reportTotalPage", reportTotalPage);
        model.addAttribute("page",            page);

        // 검색 조건 유지
        model.addAttribute("writerName",  writerName);
        model.addAttribute("subject",     subject);
        model.addAttribute("periodStart", periodStart);
        model.addAttribute("periodEnd",   periodEnd);
        model.addAttribute("feedbackYn",  feedbackYn);

        // ── 피드백 탭 (levelCode 51 이상 또는 99만 접근 가능) ──
        // 일반 사원(51 미만)은 자기 보고서에 달린 피드백만 조회 가능
        Map<String, Object> fParams = new HashMap<>();
        fParams.put("targetName", targetName);
        fParams.put("subject",    subject);
        fParams.put("startDate",  startDate);
        fParams.put("endDate",    endDate);
        fillAccessParams(fParams, si);

        int feedbackTotal = reportService.feedbackCount(fParams);
        int feedbackTotalPage = Math.max(1, (int) Math.ceil((double) feedbackTotal / PAGE_SIZE));
        fbPage = Math.max(1, Math.min(fbPage, feedbackTotalPage));
        fParams.put("startRow", (fbPage - 1) * PAGE_SIZE + 1);
        fParams.put("endRow",    fbPage * PAGE_SIZE);

        List<ReportDto> feedbackList = reportService.listFeedback(fParams);

        model.addAttribute("feedbackList",      feedbackList);
        model.addAttribute("feedbackTotal",     feedbackTotal);
        model.addAttribute("feedbackTotalPage", feedbackTotalPage);
        model.addAttribute("fbPage",            fbPage);

        model.addAttribute("targetName", targetName);
        model.addAttribute("startDate",  startDate);
        model.addAttribute("endDate",    endDate);

        // 탭 상태 유지
        model.addAttribute("activeTab",  tab);

        // 권한 정보 (JSP 분기용)
        model.addAttribute("userLevel", si.getUserLevel());
        model.addAttribute("sessionEmpId", si.getEmpId());

        return "report/reportMain";
    }

    // ============================================================
    // 보고서 상세
    // ============================================================
    @GetMapping("/detail")
    public String detail(@RequestParam(name = "filenum") Long filenum, HttpSession session, Model model) {
        SessionInfo si = getSession(session);
        ReportDto dto = reportService.getReport(filenum);

        if (dto == null) {
            return "redirect:/report/list";
        }

        // 접근 제어: 일반 사원은 자기 보고서만
        if (si.getUserLevel() < 51 && !dto.getEmpId().equals(si.getEmpId())) {
            return "redirect:/report/list";
        }
        // 51~98: 같은 프로젝트 사원 보고서만
        if (si.getUserLevel() >= 51 && si.getUserLevel() < 99) {
            List<String> empIds = reportService.getSharedProjectEmpIds(si.getEmpId());
            if (!empIds.contains(dto.getEmpId())) {
                return "redirect:/report/list";
            }
        }

        // 인라인 피드백 (보고서에 달린 첫 번째 피드백)
        // Service를 통해 조회 - Mapper는 Service에서만 호출
        ReportDto inlineFeedback = reportService.getInlineFeedback(filenum);
        model.addAttribute("dto",            dto);
        model.addAttribute("inlineFeedback", inlineFeedback);
        model.addAttribute("userLevel",      si.getUserLevel());
        model.addAttribute("sessionEmpId",   si.getEmpId());

        return "report/reportDetail";
    }

    // ============================================================
    // 보고서 작성 화면
    // ============================================================
    @GetMapping("/write")
    public String writeForm(HttpSession session, Model model) {
        SessionInfo si = getSession(session);
        // 피드백 작성자(51 이상)는 보고서 작성 불가 - 선택적 제한
        model.addAttribute("userLevel", si.getUserLevel());
        return "report/reportWrite";
    }

    // ============================================================
    // 보고서 등록 처리
    // ============================================================
    @PostMapping("/write")
    public String write(ReportDto dto,
                        @RequestParam(name = "files", required = false) List<MultipartFile> files,
                        HttpSession session) {
        SessionInfo si = getSession(session);
        dto.setEmpId(si.getEmpId());

        try {
            reportService.insertReport(dto, files);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/report/write?error=1";
        }
        return "redirect:/report/list";
    }

    // ============================================================
    // 보고서 수정 화면
    // ============================================================
    @GetMapping("/edit")
    public String editForm(@RequestParam(name = "filenum") Long filenum, HttpSession session, Model model) {
        SessionInfo si = getSession(session);
        ReportDto dto = reportService.getReportForRef(filenum);

        if (dto == null) {
            return "redirect:/report/list";
        }
        // 권한 체크: 본인 또는 99 관리자만
        if (!dto.getEmpId().equals(si.getEmpId()) && si.getUserLevel() < 99) {
            return "redirect:/report/detail?filenum=" + filenum;
        }
        // 첨부파일 목록 세팅 (조회수 증가 없는 getReportForRef 재활용)
        ReportDto withFiles = reportService.getReportForRef(filenum);
        dto.setFileList(withFiles != null ? withFiles.getFileList() : new ArrayList<>());

        model.addAttribute("dto",       dto);
        model.addAttribute("userLevel", si.getUserLevel());
        return "report/reportEdit";
    }

    // ============================================================
    // 보고서 수정 처리
    // ============================================================
    @PostMapping("/edit")
    public String edit(ReportDto dto,
                       @RequestParam(name = "newFiles",      required = false) List<MultipartFile> newFiles,
                       @RequestParam(name = "deleteFilenum", required = false) List<Long>          deleteFilenums,
                       HttpSession session) {
        SessionInfo si = getSession(session);
        ReportDto origin = reportService.getReportForRef(dto.getFilenum());

        if (origin == null) return "redirect:/report/list";
        if (!origin.getEmpId().equals(si.getEmpId()) && si.getUserLevel() < 99) {
            return "redirect:/report/detail?filenum=" + dto.getFilenum();
        }

        try {
            reportService.updateReport(dto, newFiles, deleteFilenums);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/report/edit?filenum=" + dto.getFilenum() + "&error=1";
        }
        return "redirect:/report/detail?filenum=" + dto.getFilenum();
    }

    // ============================================================
    // 보고서 삭제
    // ============================================================
    @GetMapping("/delete")
    public String delete(@RequestParam(name = "filenum") Long filenum, HttpSession session) {
        SessionInfo si = getSession(session);
        ReportDto dto = reportService.getReportForRef(filenum);

        if (dto == null) return "redirect:/report/list";
        if (!dto.getEmpId().equals(si.getEmpId()) && si.getUserLevel() < 99) {
            return "redirect:/report/detail?filenum=" + filenum;
        }

        try {
            reportService.deleteReport(filenum);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/report/list";
    }

    // ============================================================
    // 피드백 작성 화면
    // ============================================================
    @GetMapping("/feedback/write")
    public String feedbackWriteForm(@RequestParam(name = "refFilenum") Long refFilenum, HttpSession session, Model model) {
        SessionInfo si = getSession(session);
        // 일반 사원 접근 차단
        if (si.getUserLevel() < 51) {
            return "redirect:/report/detail?filenum=" + refFilenum;
        }
        ReportDto refDto = reportService.getReportForRef(refFilenum);
        if (refDto == null) return "redirect:/report/list";

        model.addAttribute("refDto",    refDto);
        model.addAttribute("userLevel", si.getUserLevel());
        return "report/feedbackWrite";
    }

    // ============================================================
    // 피드백 등록 처리
    // ============================================================
    @PostMapping("/feedback/write")
    public String feedbackWrite(ReportDto dto,
                                @RequestParam(name = "files", required = false) List<MultipartFile> files,
                                HttpSession session) {
        SessionInfo si = getSession(session);
        if (si.getUserLevel() < 51) {
            return "redirect:/report/list";
        }
        dto.setEmpId(si.getEmpId());
        dto.setWriterName(si.getName());

        try {
            reportService.insertFeedback(dto, files);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/report/feedback/write?refFilenum=" + dto.getParent() + "&error=1";
        }
        return "redirect:/report/detail?filenum=" + dto.getParent();
    }

    // ============================================================
    // 피드백 상세
    // ============================================================
    @GetMapping("/feedback/detail")
    public String feedbackDetail(@RequestParam(name = "filenum") Long filenum, HttpSession session, Model model) {
        SessionInfo si = getSession(session);
        ReportDto dto = reportService.getFeedback(filenum);

        if (dto == null) return "redirect:/report/list";

        // 접근 제어
        if (si.getUserLevel() < 51) {
            // 일반 사원: 자기 보고서에 달린 피드백만
            ReportDto refReport = reportService.getReportForRef(dto.getParent());
            if (refReport == null || !refReport.getEmpId().equals(si.getEmpId())) {
                return "redirect:/report/list";
            }
        } else if (si.getUserLevel() < 99) {
            // 51~98: 같은 프로젝트 사원 보고서 피드백만
            ReportDto refReport = reportService.getReportForRef(dto.getParent());
            if (refReport != null) {
                List<String> empIds = reportService.getSharedProjectEmpIds(si.getEmpId());
                if (!empIds.contains(refReport.getEmpId())) {
                    return "redirect:/report/list";
                }
            }
        }

        model.addAttribute("feedbackDto", dto);
        model.addAttribute("userLevel",   si.getUserLevel());
        model.addAttribute("sessionEmpId", si.getEmpId());
        return "report/feedbackDetail";
    }

    // ============================================================
    // 피드백 수정 화면
    // ============================================================
    @GetMapping("/feedback/edit")
    public String feedbackEditForm(@RequestParam(name = "filenum") Long filenum, HttpSession session, Model model) {
        SessionInfo si = getSession(session);
        ReportDto dto = reportService.getFeedback(filenum);

        if (dto == null) return "redirect:/report/list";
        // 권한: 피드백 작성자 본인 또는 99 관리자
        if (!dto.getEmpId().equals(si.getEmpId()) && si.getUserLevel() < 99) {
            return "redirect:/report/feedback/detail?filenum=" + filenum;
        }
        // 원본 보고서 참조 정보
        ReportDto refDto = reportService.getReportForRef(dto.getParent());

        model.addAttribute("dto",       dto);
        model.addAttribute("refDto",    refDto);
        model.addAttribute("userLevel", si.getUserLevel());
        return "report/feedbackEdit";
    }

    // ============================================================
    // 피드백 수정 처리
    // ============================================================
    @PostMapping("/feedback/edit")
    public String feedbackEdit(ReportDto dto,
                               @RequestParam(name = "newFiles",      required = false) List<MultipartFile> newFiles,
                               @RequestParam(name = "deleteFilenum", required = false) List<Long>          deleteFilenums,
                               HttpSession session) {
        SessionInfo si = getSession(session);
        ReportDto origin = reportService.getFeedback(dto.getFilenum());

        if (origin == null) return "redirect:/report/list";
        if (!origin.getEmpId().equals(si.getEmpId()) && si.getUserLevel() < 99) {
            return "redirect:/report/feedback/detail?filenum=" + dto.getFilenum();
        }

        try {
            reportService.updateFeedback(dto, newFiles, deleteFilenums);
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/report/feedback/edit?filenum=" + dto.getFilenum() + "&error=1";
        }
        return "redirect:/report/feedback/detail?filenum=" + dto.getFilenum();
    }

    // ============================================================
    // 피드백 삭제
    // ============================================================
    @GetMapping("/feedback/delete")
    public String feedbackDelete(@RequestParam(name = "filenum") Long filenum, HttpSession session) {
        SessionInfo si = getSession(session);
        ReportDto dto = reportService.getFeedback(filenum);

        if (dto == null) return "redirect:/report/list";
        if (!dto.getEmpId().equals(si.getEmpId()) && si.getUserLevel() < 99) {
            return "redirect:/report/feedback/detail?filenum=" + filenum;
        }

        Long parentFilenum = dto.getParent();
        try {
            reportService.deleteFeedback(filenum);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "redirect:/report/detail?filenum=" + parentFilenum;
    }

    // ============================================================
    // 파일 다운로드
    // ============================================================
    @GetMapping("/file/download")
    @ResponseBody
    public ResponseEntity<?> fileDownload(@RequestParam(name = "filenum") Long filenum) {
        try {
            return reportService.downloadFile(filenum);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}
