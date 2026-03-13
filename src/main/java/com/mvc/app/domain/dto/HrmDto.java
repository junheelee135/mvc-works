package com.mvc.app.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class HrmDto {

    //employee1
    private String  empId;              // 사원번호
    private String  password;           // 비밀번호
    private Integer levelCode;          // 권한레벨
    private Integer enabled;            // 계정 활성화
    private String  empStatusCode;      // 재직상태 코드
    private String  empStatusName;		// 재직상태 이름
    private String  lastLoginDate;      // 마지막 로그인일
    private Integer loginFailureCount;  // 로그인 실패 횟수
    private String  e1RegDate;          // 작성일
    private String  updateDate;         // 수정일

    //employee2
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
    private String deptCode;            // 부서 코드
    private String gradeCode;           // 직급 코드
    private String deptName;            // 부서 명
    private String gradeName;           // 직급 명
    private String regEmpId;            // 작성 사원번호
    private String e2RegDate;           // 작성일
    
    //employeeAuthority
    private String authority;
    private String authorityCode;
    private String authorityName;

    private String projectNames;        // 참여 프로젝트명
}