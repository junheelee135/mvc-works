package com.mvc.app.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.common.StorageService;
import com.mvc.app.domain.dto.SurveyAnswerDto;
import com.mvc.app.domain.dto.SurveyDto;
import com.mvc.app.domain.dto.SurveyFileDto;
import com.mvc.app.domain.dto.SurveyOptionDto;
import com.mvc.app.domain.dto.SurveyQuestionDto;
import com.mvc.app.domain.dto.SurveyResponseDto;
import com.mvc.app.domain.dto.SurveyTargetDto;
import com.mvc.app.mapper.SurveyMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SurveyServiceImpl implements SurveyService {

    private final SurveyMapper mapper;
    private final StorageService storageService;

    @Value("${file.upload-root}/survey")
    private String uploadPath;

    @Override
    public Map<String, Object> listSurvey(Map<String, Object> map) throws Exception {
        int totalCount = mapper.countSurvey(map);
        List<SurveyDto> list = mapper.listSurvey(map);
        return Map.of("totalCount", totalCount, "list", list);
    }

    @Override
    public Map<String, Object> findById(long surveyId) throws Exception {
        SurveyDto survey = mapper.findById(surveyId);
        if (survey == null) {
            throw new IllegalArgumentException("존재하지 않는 설문입니다.");
        }

        List<SurveyQuestionDto> questions = mapper.listQuestion(surveyId);
        for (SurveyQuestionDto q : questions) {
            if ("SINGLE".equals(q.getQuestionType()) || "MULTI".equals(q.getQuestionType())) {
                q.setOptions(mapper.listOption(q.getQuestionId()));
            }
        }

        List<SurveyTargetDto> targets = mapper.listTarget(surveyId);

        List<SurveyFileDto> files = mapper.listFiles(surveyId);

        Map<String, Object> result = new HashMap<>();
        result.put("survey", survey);
        result.put("questions", questions);
        result.put("targets", targets);
        result.put("files", files);
        return result;
    }

    @Override
    @Transactional
    public void createSurvey(SurveyDto dto, List<SurveyQuestionDto> questions, List<SurveyTargetDto> targets, MultipartFile[] files) throws Exception {
        mapper.insertSurvey(dto);
        long surveyId = dto.getSurveyId();

        for (SurveyQuestionDto q : questions) {
            q.setSurveyId(surveyId);
            mapper.insertQuestion(q);

            if (q.getOptions() != null) {
                for (SurveyOptionDto opt : q.getOptions()) {
                    opt.setQuestionId(q.getQuestionId());
                    mapper.insertOption(opt);
                }
            }
        }

        for (SurveyTargetDto t : targets) {
            t.setSurveyId(surveyId);
            mapper.insertTarget(t);
        }

        saveFiles(surveyId, files);
    }

    @Override
    @Transactional
    public void updateSurvey(SurveyDto dto, List<SurveyQuestionDto> questions, List<SurveyTargetDto> targets, MultipartFile[] files) throws Exception {
        long surveyId = dto.getSurveyId();

        if (mapper.countResponse(surveyId) > 0) {
            throw new IllegalStateException("이미 응답이 있는 설문은 수정할 수 없습니다.");
        }

        List<SurveyQuestionDto> oldQuestions = mapper.listQuestion(surveyId);
        for (SurveyQuestionDto q : oldQuestions) {
            mapper.deleteOptionsByQuestionId(q.getQuestionId());
        }
        mapper.deleteQuestionsBySurveyId(surveyId);
        mapper.deleteTargetsBySurveyId(surveyId);

        mapper.updateSurvey(dto);

        for (SurveyQuestionDto q : questions) {
            q.setSurveyId(surveyId);
            mapper.insertQuestion(q);

            if (q.getOptions() != null) {
                for (SurveyOptionDto opt : q.getOptions()) {
                    opt.setQuestionId(q.getQuestionId());
                    mapper.insertOption(opt);
                }
            }
        }

        for (SurveyTargetDto t : targets) {
            t.setSurveyId(surveyId);
            mapper.insertTarget(t);
        }

        saveFiles(surveyId, files);
    }

    @Override
    public void updateStatus(long surveyId, String status) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("surveyId", surveyId);
        map.put("status", status);
        mapper.updateStatus(map);
    }

    @Override
    @Transactional
    public void deleteSurvey(long surveyId) throws Exception {

        mapper.deleteAnswersBySurveyId(surveyId);
        mapper.deleteResponsesBySurveyId(surveyId);

        List<SurveyQuestionDto> questions = mapper.listQuestion(surveyId);
        for (SurveyQuestionDto q : questions) {
            mapper.deleteOptionsByQuestionId(q.getQuestionId());
        }
        mapper.deleteQuestionsBySurveyId(surveyId);

        mapper.deleteTargetsBySurveyId(surveyId);

        List<SurveyFileDto> files = mapper.listFiles(surveyId);
        for (SurveyFileDto f : files) {
            storageService.deleteFile(uploadPath, f.getSaveFilename());
        }
        mapper.deleteFilesBySurveyId(surveyId);

        mapper.deleteSurvey(surveyId);
    }

    @Override
    public boolean checkTarget(long surveyId, String empId, String deptCode) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("surveyId", surveyId);
        map.put("empId", empId);
        map.put("deptCode", deptCode);
        return mapper.checkTarget(map) > 0;
    }

    @Override
    public boolean checkResponse(long surveyId, String empId) throws Exception {
        Map<String, Object> map = new HashMap<>();
        map.put("surveyId", surveyId);
        map.put("empId", empId);
        return mapper.checkResponse(map) > 0;
    }

    @Override
    @Transactional
    public void submitResponse(SurveyResponseDto dto) throws Exception {
        if (checkResponse(dto.getSurveyId(), dto.getEmpId())) {
            throw new IllegalStateException("이미 응답한 설문입니다.");
        }

        mapper.insertResponse(dto);

        if (dto.getAnswers() != null) {
            for (SurveyAnswerDto answer : dto.getAnswers()) {
                answer.setResponseId(dto.getResponseId());
                mapper.insertAnswer(answer);
            }
        }
    }

    @Override
    public Map<String, Object> getResult(long surveyId) throws Exception {
        SurveyDto survey = mapper.findById(surveyId);
        int responseCount = mapper.countResponse(surveyId);

        List<SurveyQuestionDto> questions = mapper.listQuestion(surveyId);
        List<Map<String, Object>> stats = new ArrayList<>();

        for (SurveyQuestionDto q : questions) {
            Map<String, Object> stat = new HashMap<>();
            stat.put("question", q);

            switch (q.getQuestionType()) {
                case "SINGLE":
                case "MULTI":
                    stat.put("options", mapper.statOptionCount(q.getQuestionId()));
                    break;
                case "TEXT":
                    stat.put("textAnswers", mapper.statTextAnswers(q.getQuestionId()));
                    break;
                case "SCORE":
                    stat.put("avgScore", mapper.statScoreAvg(q.getQuestionId()));
                    break;
                default:
                    break;
            }

            stats.add(stat);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("survey", survey);
        result.put("responseCount", responseCount);
        result.put("stats", stats);

        result.put("files", mapper.listFiles(surveyId));

        return result;
    }

    @Override
    public SurveyFileDto findFileById(long fileId) throws Exception {
        return mapper.getFileById(fileId);
    }

    private void saveFiles(long surveyId, MultipartFile[] files) throws Exception {
        if (files == null) return;
        for (MultipartFile mf : files) {
            if (mf.isEmpty()) continue;
            String saveFilename = storageService.uploadFileToServer(mf, uploadPath);
            SurveyFileDto fileDto = new SurveyFileDto();
            fileDto.setSurveyId(surveyId);
            fileDto.setOriFilename(mf.getOriginalFilename());
            fileDto.setSaveFilename(saveFilename);
            fileDto.setFileSize(mf.getSize());
            mapper.insertFile(fileDto);
        }
    }
}
