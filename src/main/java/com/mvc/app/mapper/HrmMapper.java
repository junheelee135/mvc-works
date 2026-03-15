package com.mvc.app.mapper;

import com.mvc.app.domain.dto.HrmDto;
import org.apache.ibatis.annotations.Mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Mapper
public interface HrmMapper {

    int dataCount(Map<String, Object> map);
    List<HrmDto> listEmployee(Map<String, Object> map);
    HrmDto findById(String empId);

    //사원 번호 중복 체크 조회
    HrmDto findByEmpId(String empId);

    //사원 번호 자동체번 용
    String findMaxEmpId();

    //등록
    void insertEmployee1(HrmDto dto) throws SQLException;
    void insertEmployee2(HrmDto dto) throws SQLException;
    void insertAuthority(HrmDto dto) throws SQLException;

    //수정
    void updateEmployee1(HrmDto dto) throws SQLException;
    void updateEmployee2(HrmDto dto) throws SQLException;
    void updateAuthority(HrmDto dto) throws SQLException;

    //삭제
    void deleteEmployee2(String empId) throws SQLException;
    void deleteEmployee1(String empId) throws SQLException;

    //다 건 삭제
    void deleteEmployees2(List<String> ids) throws SQLException;
    void deleteEmployees1(List<String> ids) throws SQLException;

    //엑셀 업로드 배치
    void batchInsertEmployee1(List<HrmDto> list) throws SQLException;
    void batchInsertEmployee2(List<HrmDto> list) throws SQLException;
    void batchInsertAuthority(List<HrmDto> list) throws SQLException;

    //공통코드 조회
    List<Map<String, String>> listCommonCode(String codeGroup);
}