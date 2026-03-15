package com.mvc.app.service;

import com.mvc.app.domain.dto.HrmDto;
import com.mvc.app.mapper.HrmMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class HrmServiceImpl implements HrmService {

    private final HrmMapper       mapper;
    private final PasswordEncoder passwordEncoder;   // BCryptPasswordEncoder 빈 주입 (strength 10, 단건 등록용)

    // 엑셀 대량 업로드 전용 저강도 인코더 (strength 4 → 1회 약 5~10ms)
    // 업로드 초기 비밀번호는 첫 로그인 후 변경을 전제로 하므로 strength 완화
    private static final PasswordEncoder BULK_ENCODER = new BCryptPasswordEncoder(4);

    //조회 건 수
    @Override
    public int dataCount(Map<String, Object> params) {
        int result = 0;
        try {
            result = mapper.dataCount(params);
        } catch (Exception e) {
            log.error("dataCount error", e);
        }
        return result;
    }
    
    //조회 리스트
    @Override
    public List<HrmDto> listEmployee(Map<String, Object> params) {
        List<HrmDto> list = new ArrayList<>();
        try {
            list = mapper.listEmployee(params);
            // 비밀번호 마스킹 (* 8자리 고정)
            list.forEach(e -> e.setPassword("********"));
        } catch (Exception e) {
            log.error("listEmployee error", e);
        }
        return list;
    }

    //사원번호 중복 체크
    @Override
    public boolean isDuplicateEmpId(String empId) {
        try {
            return mapper.findByEmpId(empId) != null;
        } catch (Exception e) {
            log.error("isDuplicateEmpId error", e);
            return false;
        }
    }

    //사원번호 자동채번
    @Override
    public String getNextEmpId() {
        try {
            String maxStr = mapper.findMaxEmpId();
            long   next   = Long.parseLong(maxStr) + 1;
            return String.format("%011d", next);            // 제로패딩
        } catch (Exception e) {
            log.error("getNextEmpId error", e);
            return String.format("%011d", 1L);
        }
    }

    //직원 신규 등록
    @Override
    @Transactional
    public void insertEmployee(HrmDto dto) throws Exception {
        try {
            // 사원번호 중복 체크
            if (isDuplicateEmpId(dto.getEmpId())) {
                throw new IllegalArgumentException("이미 존재하는 사원번호입니다: " + dto.getEmpId());
            }
            // 비밀번호 BCrypt 암호화
            if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
                dto.setPassword(passwordEncoder.encode(dto.getPassword()));
            } else {
                throw new IllegalArgumentException("비밀번호는 필수입니다.");
            }
            // 기본값 처리
            if (dto.getEnabled()       == null) dto.setEnabled(1);
            if (dto.getEmpStatusCode() == null || dto.getEmpStatusCode().isBlank()) {
                dto.setEmpStatusCode("ES01");
            }
            // levelCode: 엑셀 업로드 등에서 이미 값이 설정된 경우 유지, null일 때만 기본값 1 적용
            if (dto.getLevelCode() == null) {
                dto.setLevelCode(1);
            }

            mapper.insertEmployee1(dto);
            mapper.insertEmployee2(dto);
            mapper.insertAuthority(dto);

        } catch (Exception e) {
            log.error("insertEmployee error", e);
            throw e;
        }
    }

    //단건 수정
    @Override
    @Transactional
    public void updateEmployee(HrmDto dto) throws Exception {
        try {
        	
            String pw = dto.getPassword();
            if (pw == null || pw.isBlank() || "********".equals(pw)) {
                dto.setPassword(null);
            } else {
                dto.setPassword(passwordEncoder.encode(pw));
            }
            mapper.updateEmployee1(dto);
            mapper.updateEmployee2(dto);
            mapper.updateAuthority(dto);
        } catch (Exception e) {
            log.error("updateEmployee error", e);
            throw e;
        }
    }

    //벌크 수정
    @Override
    @Transactional
    public void updateEmployees(List<HrmDto> dtoList) throws Exception {
        for (HrmDto dto : dtoList) {
            updateEmployee(dto);
        }
    }

    //선택 삭제
    @Override
    @Transactional
    public void deleteEmployees(List<String> ids) throws Exception {
        try {
            mapper.deleteEmployees1(ids);
        } catch (Exception e) {
            log.error("deleteEmployees error", e);
            throw e;
        }
    }

    //엑셀 다운로드 (Apache POI)
    @Override
    public Resource exportExcel(Map<String, Object> params) throws Exception {
        // 페이징 없이 전체 조회
        params.put("offset", 0);
        params.put("size", Integer.MAX_VALUE);
        List<HrmDto> list = mapper.listEmployee(params);

        try (Workbook wb = new SXSSFWorkbook(100)) {
            Sheet sheet = wb.createSheet("직원목록");

            // 헤더 스타일
            CellStyle headerStyle = wb.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.CORNFLOWER_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            Font hFont = wb.createFont();
            hFont.setBold(true);
            hFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(hFont);

            // 헤더 행 (비밀번호 컬럼 제외한 헤더)
            String[] downloadHeaders = {
                "사원번호", "이름", "부서명", "직급명",
                "권한", "재직상태", "입사일", "참여프로젝트"
            };
            Row header = sheet.createRow(0);
            for (int i = 0; i < downloadHeaders.length; i++) {
                Cell cell = header.createCell(i);
                cell.setCellValue(downloadHeaders[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 5000);
            }

            // 데이터 행
            int rowNum = 1;
            for (HrmDto dto : list) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(nvl(dto.getEmpId()));
                row.createCell(1).setCellValue(nvl(dto.getName()));
                row.createCell(2).setCellValue(nvl(dto.getDeptName()));
                row.createCell(3).setCellValue(nvl(dto.getGradeName()));
                row.createCell(4).setCellValue(nvl(dto.getAuthorityName()));
                row.createCell(5).setCellValue(nvl(dto.getEmpStatusName()));
                row.createCell(6).setCellValue(nvl(dto.getHireDate()));
                row.createCell(7).setCellValue(nvl(dto.getProjectNames()));
            }

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            wb.write(baos);
            
            ((SXSSFWorkbook) wb).dispose();
            return new ByteArrayResource(baos.toByteArray());
        }
    }

    //엑셀 업로드 양식 다운로드 (Apache POI)
    //헤더: 이름 / 비밀번호 / 부서코드 / 직급코드 / 권한코드 /권한레벨 / 재직상태코드
    @Override
    public Resource exportExcelTemplate() throws Exception {
        String[] templateHeaders = {
            "이름", "비밀번호", "부서코드", "직급코드", "권한코드", "권한레벨", "재직상태코드"
        };

        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("직원업로드양식");

            // 헤더 스타일
            CellStyle headerStyle = wb.createCellStyle();
            headerStyle.setFillForegroundColor(IndexedColors.CORNFLOWER_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            Font hFont = wb.createFont();
            hFont.setBold(true);
            hFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(hFont);

            // 헤더 행만 생성 (데이터 행 없음)
            Row header = sheet.createRow(0);
            for (int i = 0; i < templateHeaders.length; i++) {
                Cell cell = header.createCell(i);
                cell.setCellValue(templateHeaders[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 5000);
            }

            // 안내 행 (2번째 행 — 연한 노란 배경)
            CellStyle guideStyle = wb.createCellStyle();
            guideStyle.setFillForegroundColor(IndexedColors.LIGHT_YELLOW.getIndex());
            guideStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            Font gFont = wb.createFont();
            gFont.setItalic(true);
            gFont.setColor(IndexedColors.GREY_50_PERCENT.getIndex());
            guideStyle.setFont(gFont);

            Row guideRow = sheet.createRow(1);
            String[] guides = {
                "예) 홍길동", "예) password123", "예) D00121", "예) RANK03",
                "예) AUTH01", "예) 1", "예) ES01"
            };
            for (int i = 0; i < guides.length; i++) {
                Cell cell = guideRow.createCell(i);
                cell.setCellValue(guides[i]);
                cell.setCellStyle(guideStyle);
            }

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            wb.write(baos);
            return new ByteArrayResource(baos.toByteArray());
        }
    }

    // 엑셀 업로드 (Apache POI) — 배치 INSERT 방식
    @Override
    @Transactional
    public int importExcel(MultipartFile file) throws Exception {
        int count = 0;
        try (Workbook wb = WorkbookFactory.create(file.getInputStream())) {
            Sheet sheet  = wb.getSheetAt(0);
            int lastRow  = sheet.getLastRowNum();

            // ① MAX(empId) 는 업로드 시작 전 딱 한 번만 조회
            String maxStr  = mapper.findMaxEmpId();
            long   nextSeq = Long.parseLong(maxStr) + 1;

            List<HrmDto> batchList = new ArrayList<>();

            for (int i = 1; i <= lastRow; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                String name = cellStr(row, 0);
                if (name.isBlank()) continue;

                // ② DB 호출 없이 Java에서 순번 증가
                String nextEmpId = String.format("%011d", nextSeq++);

                HrmDto dto = new HrmDto();
                dto.setEmpId(nextEmpId);
                dto.setName(name);
                dto.setDeptCode(cellStr(row, 2));
                dto.setGradeCode(cellStr(row, 3));
                dto.setAuthorityCode(cellStr(row, 4));

                // 권한레벨
                String levelStr = cellStr(row, 5);
                dto.setLevelCode(!levelStr.isBlank() ? parseIntOrDefault(levelStr, 1) : 1);

                // 재직상태코드 (기본값 ES01=재직)
                String statusCode = cellStr(row, 6);
                dto.setEmpStatusCode(statusCode.isBlank() ? "ES01" : statusCode);

                // ③ 엑셀 업로드 전용 저강도 인코더로 암호화 (strength 4)
                //    단건 등록(strength 10, ~150ms)과 달리 대량 처리 성능 우선
                String pw = cellStr(row, 1);
                dto.setPassword(BULK_ENCODER.encode(pw.isBlank() ? "password123" : pw));

                dto.setEnabled(1);
                batchList.add(dto);
                count++;
            }

            // ④ 1,000건 단위로 배치 INSERT (Oracle INSERT ALL 한계 고려)
            int batchSize = 1000;
            for (int i = 0; i < batchList.size(); i += batchSize) {
                List<HrmDto> chunk = batchList.subList(i,
                        Math.min(i + batchSize, batchList.size()));
                mapper.batchInsertEmployee1(chunk);
                mapper.batchInsertEmployee2(chunk);
                mapper.batchInsertAuthority(chunk);
            }
        }
        return count;
    }

    // 헬퍼: 숫자 변환 실패 시 기본값 반환
    private int parseIntOrDefault(String s, int defaultVal) {
        try { return Integer.parseInt(s); }
        catch (NumberFormatException e) { return defaultVal; }
    }

    //공통코드 조회
    @Override
    public List<Map<String, String>> getCommonCodes(String codeGroup) {
        try {
            return mapper.listCommonCode(codeGroup);
        } catch (Exception e) {
            log.error("getCommonCodes error codeGroup={}", codeGroup, e);
            return new ArrayList<>();
        }
    }
    private String nvl(String s) { return s == null ? "" : s; }

    private String cellStr(Row row, int col) {
        Cell cell = row.getCell(col);
        if (cell == null) return "";
        switch (cell.getCellType()) {
            case NUMERIC:
                double d = cell.getNumericCellValue();
                if (d == Math.floor(d) && !Double.isInfinite(d)) {
                    return String.valueOf((long) d).trim();
                }
                return String.valueOf(d).trim();
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue()).trim();
            case FORMULA:
                try { return String.valueOf((long) cell.getNumericCellValue()).trim(); }
                catch (Exception e) { return cell.getStringCellValue().trim(); }
            case BLANK:
                return "";
            default:
                return cell.getStringCellValue().trim();
        }
    }
}