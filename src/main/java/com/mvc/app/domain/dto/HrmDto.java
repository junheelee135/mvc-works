package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class HrmDto {

    // ── employee1 (인증 / 계정 정보) ───────────────────────────
    private String  empId;              // 사원번호 PK (VARCHAR2(11))
    private String  password;           // 비밀번호 (BCrypt 암호화 저장, 조회 시 마스킹)
    private Integer levelCode;          // 권한레벨 숫자 (1~99 등, 51 이상=관리자)
    private Integer enabled;            // 계정 활성화 (1=활성, 0=비활성)
    private String  empStatusCode;      // 재직상태 코드 (ES01=재직, ES02=휴직, ES03=퇴직, ES04=계약만료)
    private String  empStatusName;		// 재직상태 이름
    private String  lastLoginDate;      // 마지막 로그인일
    private Integer loginFailureCount;  // 로그인 실패 횟수
    private String  e1RegDate;          // employee1 등록일 (컬럼명 충돌 방지용 alias)
    private String  updateDate;         // 계정 수정일

    // ── employee2 (인적 정보) ──────────────────────────────────
    private String name;                // 이름
    private String birth;               // 생년월일
    private String profilePhoto;        // 프로필 사진 경로
    private String tel;                 // 전화번호
    private String zip;                 // 우편번호
    private String addr1;               // 기본 주소
    private String addr2;               // 상세 주소
    private String email;               // 이메일
    private String ipAddr;              // 최근 접속 IP
    private String hireDate;            // 입사일
    private String deptCode;            // 부서 코드 (DEPT 코드값, ex: D00121)
    private String gradeCode;           // 직급 코드 (RANK 코드값, ex: RANK03)
    private String deptName;            // 부서명 (ex: 인사팀)  — 조회 전용
    private String gradeName;           // 직급명 (ex: 대리)    — 조회 전용
    private String regEmpId;            // 등록자 사원번호
    private String e2RegDate;           // employee2 등록일
    
    //employeeAuthority (권한)
    private String authority;
    private String authorityCode;
    private String authorityName;

    // ── JOIN 추가 컬럼 ─────────────────────────────────────────
    private String projectNames;        // 참여 프로젝트명 (서브쿼리 결과)
}