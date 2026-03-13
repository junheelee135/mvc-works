package com.mvc.app.domain.dto;

import java.io.Serializable;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// 세션에 저장할 정보(사원번호, 이름, 역할(권한) 등)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SessionInfo implements Serializable{
	
	private static final long serialVersionUID = 1L;
	
	private String empId;       // 사원번호 (로그인 ID)
	private String password;
	private String name;
	private String email;
	private int userLevel;
	private String avatar;      // profilePhoto
	private String deptCode;    
	private String deptName;    
	private String gradeCode;   
	private String gradeName; 
	
}
