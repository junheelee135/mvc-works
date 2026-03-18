package com.mvc.app.domain.dto;

import java.util.List;
import java.util.Map;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ProjectsDto {
	// 프로젝트
	private long projectId;
	private String projectType; // 프로젝트 타입(I: 개인, T: 팀-디폴트)
	private String pmoType; // pmo 타입(S: 지정-디폴트, A: 전원)
	private String title;
	private String description;
	private String startDate;
	private String endDate;
	private String createdDate;
	private String status;
	private long progress; // project 진척도
	
	
	private List<Map<String, Object>> members; 
	private List<Map<String, Object>> stages;
	
	private String managerName;  // 매니저 이름
	private String remainDays;      // 잔여일
	private String totalDays;
	
	// 프로젝트 생성 시 필요 사항
	private int levelCode; // 권한레벨코드
	private String empStatusCode; // 재직상태코드
	private String deptCode; // 부서코드
	private String gradeCode; // 직급코드
		
	// 프로젝트 단계(stage)
	private String stageId;
	private String stgTitle; 
	private int sequence; // project 단계 순서
	private String stgStartDate;
	private String stgEndDate;
	private String stgStatus;
	private int stgProgress;
	private String stgCreatedDate;
	
	// 프로젝트 업무(사원 - empProject)
	private String empProjId;
	private String empId;
	private String name;
	private String predecessor; // 전임자
	private String empStartDate;
	private String empEndDate;
	private String role; // 매니저 - M, 디자이너 - D, 개발자 - P
	
	// 업무(task)
	private String taskId;
	private String taskTitle;
	private String taskDescription;
	private String taskStartDate;
	private String taskEndDate;
	private String taskStatus;
	private String taskCreatedDate;
	private String taskCreator;
	
	// 개인업무(emptask)
	private String empTaskId;
	private String empTaskStartDate;
	private String empTaskEndDate;
	private String empTaskStatus;
	
	// 매일 작업량
	private String logId;
	private String logDate;
	private String logStatus; // 완료 - F / 진행 - I / 중단 - S
	private String logReason; 
}
