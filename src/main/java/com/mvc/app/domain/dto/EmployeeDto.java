package com.mvc.app.domain.dto;

import org.springframework.web.multipart.MultipartFile;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class EmployeeDto {
	private String empId;           // 사원번호 (PK, 로그인 ID)
	private String password;        // 비밀번호
	private int levelCode;          // 권한레벨코드
	private int enabled;            // 로그인 가능 여부
	private String regDate;         // 등록일자
	private String updateDate;      // 수정일자
	private String lastLoginDate;   // 마지막로그인일자
	private int loginFailureCount;  // 로그인 실패 횟수
	private String empStatusCode;   // 재직상태코드

	private String name;
	private String birth;
	private String profilePhoto;
	private String tel;
	private String zip;
	private String addr1;
	private String addr2;
	private String email;
	private String ipAddr;
	private String deptCode;        // 부서코드
	private String deptName;        // 부서명
	private String gradeCode;       // 직급코드
	private String gradeName;       // 직급명	

	private MultipartFile selectFile;

	private String authority;
	private String oldAuthority;

	private String refreshTokenValue;
	
	private String newPwd;
	private String confirmPwd;

	private long num;
	private String regEmpId;        // 등록사원번호 (employeeStatus 등록자)
	private String memo;
}
