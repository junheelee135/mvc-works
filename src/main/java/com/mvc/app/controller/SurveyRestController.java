package com.mvc.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mvc.app.common.StorageService;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.domain.dto.SurveyDto;
import com.mvc.app.domain.dto.SurveyFileDto;
import com.mvc.app.domain.dto.SurveyOptionDto;
import com.mvc.app.domain.dto.SurveyQuestionDto;
import com.mvc.app.domain.dto.SurveyResponseDto;
import com.mvc.app.domain.dto.SurveyTargetDto;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.SurveyService;

import java.time.LocalDate;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/survey")
@RequiredArgsConstructor
public class SurveyRestController {

    private final SurveyService service;
    private final StorageService storageService;
    private final ObjectMapper objectMapper;

    @Value("${file.upload-root}/survey")
    private String uploadPath;

    // 관리자 여부 확인
    private boolean isAdmin(SessionInfo info) {
        return info != null && info.getUserLevel() == 99;
    }

    // 설문 목록
    @GetMapping
    public ResponseEntity<?> list(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "status", required = false) String status,
            @RequestParam(name = "pageNo", defaultValue = "1") int pageNo,
            @RequestParam(name = "pageSize", defaultValue = "20") int pageSize) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            Map<String, Object> map = new HashMap<>();
            map.put("keyword", keyword);
            map.put("status", status);
            map.put("pageNo", pageNo);
            map.put("pageSize", pageSize);
            map.put("empId", info.getEmpId());
            return ResponseEntity.ok(service.listSurvey(map));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 설문 상세
    @GetMapping("/{surveyId}")
    public ResponseEntity<?> findById(@PathVariable("surveyId") long surveyId) {
        try {
            return ResponseEntity.ok(service.findById(surveyId));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 설문 등록 (관리자만) — 멀티파트
    @PostMapping
    public ResponseEntity<?> create(
            @RequestPart("data") String dataJson,
            @RequestPart(value = "files", required = false) MultipartFile[] files) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (!isAdmin(info)) {
                return ResponseEntity.status(403).body(Map.of("msg", "관리자만 등록할 수 있습니다."));
            }

            Map<String, Object> body = objectMapper.readValue(dataJson, new TypeReference<>() {});

            SurveyDto dto = new SurveyDto();
            dto.setTitle((String) body.get("title"));
            dto.setDescription((String) body.get("description"));
            dto.setAnonymousYn((String) body.get("anonymousYn"));
            dto.setStatus((String) body.get("status"));
            dto.setStartDate((String) body.get("startDate"));
            dto.setEndDate((String) body.get("endDate"));
            dto.setWriterEmpId(info.getEmpId());

            List<SurveyQuestionDto> questions = parseQuestions(body);
            List<SurveyTargetDto> targets = parseTargets(body);

            service.createSurvey(dto, questions, targets, files);
            return ResponseEntity.ok(Map.of("surveyId", dto.getSurveyId()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 설문 수정 (관리자만) — 멀티파트
    @PostMapping("/{surveyId}")
    public ResponseEntity<?> update(
            @PathVariable("surveyId") long surveyId,
            @RequestPart("data") String dataJson,
            @RequestPart(value = "files", required = false) MultipartFile[] files) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (!isAdmin(info)) {
                return ResponseEntity.status(403).body(Map.of("msg", "관리자만 수정할 수 있습니다."));
            }

            Map<String, Object> body = objectMapper.readValue(dataJson, new TypeReference<>() {});

            SurveyDto dto = new SurveyDto();
            dto.setSurveyId(surveyId);
            dto.setTitle((String) body.get("title"));
            dto.setDescription((String) body.get("description"));
            dto.setAnonymousYn((String) body.get("anonymousYn"));
            dto.setStartDate((String) body.get("startDate"));
            dto.setEndDate((String) body.get("endDate"));

            List<SurveyQuestionDto> questions = parseQuestions(body);
            List<SurveyTargetDto> targets = parseTargets(body);

            service.updateSurvey(dto, questions, targets, files);
            return ResponseEntity.ok(Map.of("result", "ok"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 설문 삭제 (관리자만)
    @DeleteMapping("/{surveyId}")
    public ResponseEntity<?> delete(@PathVariable("surveyId") long surveyId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (!isAdmin(info)) {
                return ResponseEntity.status(403).body(Map.of("msg", "관리자만 삭제할 수 있습니다."));
            }
            service.deleteSurvey(surveyId);
            return ResponseEntity.ok(Map.of("result", "ok"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 배포 (DRAFT → ACTIVE) (관리자만)
    @PostMapping("/{surveyId}/publish")
    public ResponseEntity<?> publish(@PathVariable("surveyId") long surveyId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (!isAdmin(info)) {
                return ResponseEntity.status(403).body(Map.of("msg", "관리자만 배포할 수 있습니다."));
            }
            service.updateStatus(surveyId, "ACTIVE");
            return ResponseEntity.ok(Map.of("result", "ok"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 마감 (ACTIVE → CLOSED) (관리자만)
    @PostMapping("/{surveyId}/close")
    public ResponseEntity<?> close(@PathVariable("surveyId") long surveyId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            if (!isAdmin(info)) {
                return ResponseEntity.status(403).body(Map.of("msg", "관리자만 마감할 수 있습니다."));
            }
            service.updateStatus(surveyId, "CLOSED");
            return ResponseEntity.ok(Map.of("result", "ok"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 응답 여부 확인
    @GetMapping("/{surveyId}/check")
    public ResponseEntity<?> checkResponse(@PathVariable("surveyId") long surveyId) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();
            boolean responded = service.checkResponse(surveyId, info.getEmpId());
            boolean isTarget = service.checkTarget(surveyId, info.getEmpId(), info.getDeptCode());
            return ResponseEntity.ok(Map.of("responded", responded, "isTarget", isTarget));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 응답 제출
    @PostMapping("/{surveyId}/respond")
    public ResponseEntity<?> respond(@PathVariable("surveyId") long surveyId, @RequestBody SurveyResponseDto dto) {
        try {
            SessionInfo info = LoginMemberUtil.getSessionInfo();

            // 날짜 검증
            Map<String, Object> detail = service.findById(surveyId);
            SurveyDto survey = (SurveyDto) detail.get("survey");
            LocalDate today = LocalDate.now();
            if (survey.getStartDate() != null && !survey.getStartDate().isEmpty()) {
                if (today.isBefore(LocalDate.parse(survey.getStartDate()))) {
                    return ResponseEntity.status(403).body(Map.of("msg", "응답 가능 기간이 아닙니다."));
                }
            }
            if (survey.getEndDate() != null && !survey.getEndDate().isEmpty()) {
                if (today.isAfter(LocalDate.parse(survey.getEndDate()))) {
                    return ResponseEntity.status(403).body(Map.of("msg", "응답 가능 기간이 아닙니다."));
                }
            }

            dto.setSurveyId(surveyId);
            dto.setEmpId(info.getEmpId());
            service.submitResponse(dto);
            return ResponseEntity.ok(Map.of("result", "ok"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 결과 통계
    @GetMapping("/{surveyId}/result")
    public ResponseEntity<?> result(@PathVariable("surveyId") long surveyId) {
        try {
            return ResponseEntity.ok(service.getResult(surveyId));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }

    // 첨부파일 다운로드
    @GetMapping("/file/{fileId}")
    public ResponseEntity<?> downloadFile(@PathVariable("fileId") long fileId) {
        try {
            SurveyFileDto file = service.findFileById(fileId);
            if (file == null) {
                return ResponseEntity.notFound().build();
            }
            return storageService.downloadFile(uploadPath, file.getSaveFilename(), file.getOriFilename());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("msg", "파일 다운로드에 실패했습니다."));
        }
    }

    @SuppressWarnings("unchecked")
    private List<SurveyQuestionDto> parseQuestions(Map<String, Object> body) {
        List<SurveyQuestionDto> questions = new java.util.ArrayList<>();
        List<Map<String, Object>> qList = (List<Map<String, Object>>) body.get("questions");
        if (qList == null) return questions;

        for (Map<String, Object> qMap : qList) {
            SurveyQuestionDto q = new SurveyQuestionDto();
            q.setQuestionText((String) qMap.get("questionText"));
            q.setQuestionType((String) qMap.get("questionType"));
            q.setSortOrder(qMap.get("sortOrder") != null ? ((Number) qMap.get("sortOrder")).intValue() : 1);

            // 선택지 파싱
            List<Map<String, Object>> optList = (List<Map<String, Object>>) qMap.get("options");
            if (optList != null) {
                List<SurveyOptionDto> options = new java.util.ArrayList<>();
                for (Map<String, Object> oMap : optList) {
                    SurveyOptionDto opt = new SurveyOptionDto();
                    opt.setOptionText((String) oMap.get("optionText"));
                    opt.setSortOrder(oMap.get("sortOrder") != null ? ((Number) oMap.get("sortOrder")).intValue() : 1);
                    options.add(opt);
                }
                q.setOptions(options);
            }

            questions.add(q);
        }
        return questions;
    }

    @SuppressWarnings("unchecked")
    private List<SurveyTargetDto> parseTargets(Map<String, Object> body) {
        List<SurveyTargetDto> targets = new java.util.ArrayList<>();
        List<Map<String, Object>> tList = (List<Map<String, Object>>) body.get("targets");
        if (tList == null) return targets;

        for (Map<String, Object> tMap : tList) {
            SurveyTargetDto t = new SurveyTargetDto();
            t.setTargetType((String) tMap.get("targetType"));
            t.setTargetValue((String) tMap.get("targetValue"));
            targets.add(t);
        }
        return targets;
    }
}
