package com.mvc.app.service;

import com.mvc.app.domain.dto.HrmDto;
import org.springframework.core.io.Resource;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface HrmService {

    int dataCount(Map<String, Object> params);
    List<HrmDto> listEmployee(Map<String, Object> params);

    //사원 번호 중복 체크 조회(employee1)
    boolean isDuplicateEmpId(String empId);

    // 사원 번호 자동체번 용
    String getNextEmpId();

    //등록
    void insertEmployee(HrmDto dto) throws Exception;

    //수정
    void updateEmployee(HrmDto dto) throws Exception;

    //다 건 수정
    void updateEmployees(List<HrmDto> dtoList) throws Exception;

    //다 건 삭제
    void deleteEmployees(List<String> ids) throws Exception;

    //현재 검색 조건 기준 전체 데이터를 엑셀로 반환
    Resource exportExcel(Map<String, Object> params) throws Exception;

    /**
     * 엑셀 업로드용 양식 파일 반환
     *  헤더: 이름 / 비밀번호 / 부서코드 / 직급코드 / 권한코드 / 권한레벨 / 재직상태코드
     *  사원번호, 참여 프로젝트는 자동처리
     */
    Resource exportExcelTemplate() throws Exception;

    //엑셀 업로드
    int importExcel(MultipartFile file) throws Exception;

    //공통코드 조회
    List<Map<String, String>> getCommonCodes(String codeGroup);
}
