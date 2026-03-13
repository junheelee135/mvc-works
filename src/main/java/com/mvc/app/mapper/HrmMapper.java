package com.mvc.app.mapper;

import com.mvc.app.domain.dto.HrmDto;
import org.apache.ibatis.annotations.Mapper;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Mapper
public interface HrmMapper {

    // ── 목록 / 카운트 ──────────────────────────────────────────
    int dataCount(Map<String, Object> map);
    List<HrmDto> listEmployee(Map<String, Object> map);

    // ── 단건 조회 ──────────────────────────────────────────────
    HrmDto findById(String empId);

    // ── 사원번호 중복 체크 ─────────────────────────────────────
    HrmDto findByEmpId(String empId);  // employee1 기준

    // ── 가장 큰 사원번호 조회 (자동채번용) ────────────────────
    String findMaxEmpId();

    // ── 등록 : employee1 → employee2 순서로 INSERT ─────────────
    void insertEmployee1(HrmDto dto) throws SQLException;  // 인증 정보 먼저
    void insertEmployee2(HrmDto dto) throws SQLException;  // 인적 정보 후
    void insertAuthority(HrmDto dto) throws SQLException;  // 권한 정보

    // ── 수정 : 각 테이블 개별 UPDATE ──────────────────────────
    void updateEmployee1(HrmDto dto) throws SQLException;  // 비밀번호, levelCode 등
    void updateEmployee2(HrmDto dto) throws SQLException;  // 이름, 부서 등
    void updateAuthority(HrmDto dto) throws SQLException;  // Authority 권한

    // ── 삭제 : employee2 → employee1 순서 (FK 제약 고려) ──────
    void deleteEmployee2(String empId) throws SQLException;
    void deleteEmployee1(String empId) throws SQLException;

    // ── 벌크 삭제 ─────────────────────────────────────────────
    void deleteEmployees2(List<String> ids) throws SQLException;
    void deleteEmployees1(List<String> ids) throws SQLException;

    // ── 공통코드 조회 (codeGroup 기준) ────────────────────────
    List<Map<String, String>> listCommonCode(String codeGroup);
}
