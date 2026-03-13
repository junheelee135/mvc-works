package com.mvc.app.service;

import com.mvc.app.domain.dto.HrmDto;
import org.springframework.core.io.Resource;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface HrmService {

    int dataCount(Map<String, Object> params);
    List<HrmDto> listEmployee(Map<String, Object> params);

    /** 사원번호 중복 여부 (true = 이미 존재) */
    boolean isDuplicateEmpId(String empId);

    /**
     * 다음 사원번호 자동채번
     *  EMPLOYEE1.empId MAX 값 + 1 을 11자리 zero-padding 문자열로 반환
     */
    String getNextEmpId();

    /**
     * 직원 신규 등록
     *  1. 사원번호 중복 체크
     *  2. 비밀번호 BCrypt 암호화
     *  3. employee1 INSERT → employee2 INSERT (FK 순서)
     */
    void insertEmployee(HrmDto dto) throws Exception;

    /**
     * 직원 수정
     *  - 비밀번호 입력 없으면(null / "********") employee1 password 변경 안 함
     *  - 사원번호(empId)는 수정 불가
     */
    void updateEmployee(HrmDto dto) throws Exception;

    /** 벌크 수정 */
    void updateEmployees(List<HrmDto> dtoList) throws Exception;

    /**
     * 선택 삭제
     *  - employee2 DELETE → employee1 DELETE (FK 순서)
     */
    void deleteEmployees(List<String> ids) throws Exception;

    /** 현재 검색 조건 기준 전체 데이터를 엑셀로 반환 */
    Resource exportExcel(Map<String, Object> params) throws Exception;

    /**
     * 엑셀 업로드용 빈 양식 파일 반환
     *  헤더: 이름 | 비밀번호 | 부서코드 | 직급코드 | 권한코드 | 권한레벨 | 재직상태코드
     *  ※ 사원번호·참여 프로젝트는 자동처리이므로 양식에 포함하지 않음
     */
    Resource exportExcelTemplate() throws Exception;

    /** 엑셀 업로드 → DB 일괄 등록, 등록된 건수 반환 */
    int importExcel(MultipartFile file) throws Exception;

    /** 공통코드 조회 (codeGroup 기준, value=code / label=codeName) */
    List<Map<String, String>> getCommonCodes(String codeGroup);
}
