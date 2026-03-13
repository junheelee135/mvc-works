package com.mvc.app.group.service;

import com.mvc.app.common.StorageService;
import com.mvc.app.group.dto.ReportDto;
import com.mvc.app.group.dto.ReportFileDto;
import com.mvc.app.group.mapper.ReportMapper;
import com.mvc.app.notification.event.NotificationEvent;

import lombok.RequiredArgsConstructor;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Service
public class ReportServiceImpl implements ReportService {

    private final ReportMapper reportMapper;
    private final StorageService storageService;
    private final ApplicationEventPublisher eventPublisher;

    /** 보고서 파일 업로드 경로 (웹루트 하위 상대 경로) */
    private static final String UPLOAD_WEB_PATH = "upload/report";

    // ── 업로드 실제 경로 반환 헬퍼 ────────────────────────────
    private String getUploadPath() {
        return storageService.getRealPath(UPLOAD_WEB_PATH);
    }

    // ============================================================
    // 보고서 목록 / 카운트
    // ============================================================
    @Override
    public int reportCount(Map<String, Object> params) {
        return reportMapper.reportCount(params);
    }

    @Override
    public List<ReportDto> listReport(Map<String, Object> params) {
        return reportMapper.listReport(params);
    }

    // ============================================================
    // 피드백 목록 / 카운트
    // ============================================================
    @Override
    public int feedbackCount(Map<String, Object> params) {
        return reportMapper.feedbackCount(params);
    }

    @Override
    public List<ReportDto> listFeedback(Map<String, Object> params) {
        return reportMapper.listFeedback(params);
    }

    // ============================================================
    // 보고서 단건 조회 (조회수 증가)
    // ============================================================
    @Override
    @Transactional
    public ReportDto getReport(Long filenum) {
        reportMapper.incrementHitcount(filenum);
        ReportDto dto = reportMapper.findReportById(filenum);
        if (dto != null) {
            dto.setFileList(reportMapper.listFilesByReport(filenum));
            // 인라인 피드백 조회
            ReportDto feedback = reportMapper.findFeedbackByParent(filenum);
            // 보고서 DTO에 직접 담지 않고 Controller에서 model에 별도 추가하므로 여기서는 반환값으로 사용
        }
        return dto;
    }

    // ============================================================
    // 피드백 단건 조회 (조회수 증가)
    // ============================================================
    @Override
    @Transactional
    public ReportDto getFeedback(Long filenum) {
        reportMapper.incrementHitcount(filenum);
        ReportDto dto = reportMapper.findFeedbackById(filenum);
        if (dto != null) {
            dto.setFileList(reportMapper.listFilesByReport(filenum));
        }
        return dto;
    }

    // ============================================================
    // 피드백 작성 화면 - 원본 보고서 조회 (조회수 증가 없음)
    // ============================================================
    @Override
    public ReportDto getReportForRef(Long filenum) {
        ReportDto dto = reportMapper.findReportById(filenum);
        if (dto != null) {
            dto.setFileList(reportMapper.listFilesByReport(filenum));
        }
        return dto;
    }

    // ============================================================
    // 보고서 등록
    // ============================================================
    @Override
    @Transactional
    public void insertReport(ReportDto dto, List<MultipartFile> files) throws Exception {
        // 시퀀스 채번
        Long seq = reportMapper.nextReportSeq();
        dto.setFilenum(seq);

        reportMapper.insertReport(dto);

        // 파일 업로드
        if (files != null) {
            saveFiles(files, seq);
        }
    }

    // ============================================================
    // 보고서 수정
    // ============================================================
    @Override
    @Transactional
    public void updateReport(ReportDto dto, List<MultipartFile> newFiles, List<Long> deleteFilenums) throws Exception {
        reportMapper.updateReport(dto);

        // 기존 파일 삭제
        if (deleteFilenums != null) {
            for (Long fnum : deleteFilenums) {
                ReportFileDto fileDto = reportMapper.findFileById(fnum);
                if (fileDto != null) {
                    storageService.deleteFile(getUploadPath(), fileDto.getSavefilename());
                    reportMapper.deleteReportFile(fnum);
                }
            }
        }

        // 새 파일 업로드
        if (newFiles != null) {
            saveFiles(newFiles, dto.getFilenum());
        }
    }

    // ============================================================
    // 보고서 삭제 (연관 피드백 + 파일 모두 삭제)
    // ============================================================
    @Override
    @Transactional
    public void deleteReport(Long filenum) throws Exception {
        // 1. 보고서 첨부파일 물리 삭제
        deletePhysicalFiles(filenum);

        // 2. 연관 피드백 처리
        ReportDto feedback = reportMapper.findFeedbackByParent(filenum);
        if (feedback != null) {
            // 피드백 첨부파일 물리 삭제
            deletePhysicalFiles(feedback.getFilenum());
            reportMapper.deleteFilesByReport(feedback.getFilenum());
            reportMapper.deleteFeedback(feedback.getFilenum());
        }

        // 3. 보고서 첨부파일 DB 삭제
        reportMapper.deleteFilesByReport(filenum);

        // 4. 보고서 삭제
        reportMapper.deleteReport(filenum);
    }

    // ============================================================
    // 피드백 등록
    // ============================================================
    @Override
    @Transactional
    public void insertFeedback(ReportDto dto, List<MultipartFile> files) throws Exception {
        Long seq = reportMapper.nextReportSeq();
        dto.setFilenum(seq);

        reportMapper.insertFeedback(dto);

        if (files != null) {
            saveFiles(files, seq);
        }
        ReportDto originalReport = reportMapper.findReportById(dto.getParent());

        if (originalReport != null) {
            eventPublisher.publishEvent(
                new NotificationEvent.Feedback(
                    originalReport.getEmpId(),    // 수신자: 원본 보고서 작성자 사번
                    dto.getEmpId(),               // 발신자: 피드백 작성자 사번
                    dto.getWriterName(),          // 발신자 이름
                    dto.getParent(),              // 원본 보고서 filenum
                    originalReport.getSubject()   // 원본 보고서 제목
                )
            );
        }
    }

    // ============================================================
    // 피드백 수정
    // ============================================================
    @Override
    @Transactional
    public void updateFeedback(ReportDto dto, List<MultipartFile> newFiles, List<Long> deleteFilenums) throws Exception {
        reportMapper.updateFeedback(dto);

        if (deleteFilenums != null) {
            for (Long fnum : deleteFilenums) {
                ReportFileDto fileDto = reportMapper.findFileById(fnum);
                if (fileDto != null) {
                    storageService.deleteFile(getUploadPath(), fileDto.getSavefilename());
                    reportMapper.deleteReportFile(fnum);
                }
            }
        }

        if (newFiles != null) {
            saveFiles(newFiles, dto.getFilenum());
        }
    }

    // ============================================================
    // 피드백 삭제
    // ============================================================
    @Override
    @Transactional
    public void deleteFeedback(Long filenum) throws Exception {
        deletePhysicalFiles(filenum);
        reportMapper.deleteFilesByReport(filenum);
        reportMapper.deleteFeedback(filenum);
    }

    // ============================================================
    // 첨부파일 다운로드
    // ============================================================
    @Override
    public ResponseEntity<?> downloadFile(Long filenum) throws Exception {
        ReportFileDto fileDto = reportMapper.findFileById(filenum);
        if (fileDto == null) {
            throw new IllegalArgumentException("파일을 찾을 수 없습니다.");
        }
        return storageService.downloadFile(
                getUploadPath(),
                fileDto.getSavefilename(),
                fileDto.getOriginalfilename()
        );
    }

    @Override
    public ReportDto getInlineFeedback(Long reportFilenum) {
        ReportDto dto = reportMapper.findFeedbackByParent(reportFilenum);
        if (dto != null) {
            dto.setFileList(reportMapper.listFilesByReport(dto.getFilenum()));
        }
        return dto;
    }

    // ============================================================
    // 같은 프로젝트 사원 empId 목록
    // ============================================================
    @Override
    public List<String> getSharedProjectEmpIds(String empId) {
        return reportMapper.findEmpIdsBySharedProject(empId);
    }

    // ============================================================
    // 내부 헬퍼 - 파일 저장
    // ============================================================
    private void saveFiles(List<MultipartFile> files, Long reportFilenum) throws Exception {
        String uploadPath = getUploadPath();
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) continue;

            String saveFilename = storageService.uploadFileToServer(file, uploadPath);
            if (saveFilename == null) continue;

            Long fileSeq = reportMapper.nextReportFileSeq();
            ReportFileDto fileDto = new ReportFileDto();
            fileDto.setFilenum(fileSeq);
            fileDto.setSavefilename(saveFilename);
            fileDto.setOriginalfilename(file.getOriginalFilename());
            fileDto.setFilesize(file.getSize());
            fileDto.setFilenum2(reportFilenum);

            reportMapper.insertReportFile(fileDto);
        }
    }

    // 내부 헬퍼 - 물리 파일 삭제
    private void deletePhysicalFiles(Long reportFilenum) {
        List<ReportFileDto> files = reportMapper.listFilesByReport(reportFilenum);
        if (files == null) return;
        String uploadPath = getUploadPath();
        for (ReportFileDto f : files) {
            storageService.deleteFile(uploadPath, f.getSavefilename());
        }
    }
}
