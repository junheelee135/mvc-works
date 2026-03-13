package com.mvc.app.controller;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import com.mvc.app.domain.dto.EmployeeDto;
import com.mvc.app.domain.dto.ProjectsDto;
import com.mvc.app.service.ApprovalDocService;
import com.mvc.app.service.EmployeeService;
import com.mvc.app.service.ProjectService;
import com.mvc.app.service.TaskService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
public class HomeController {

	private final ProjectService projectService;
	private final EmployeeService employeeService;
	private final ApprovalDocService approvalDocService;
	private final TaskService taskService;

	// @GetMapping("/")
	@RequestMapping(value = { "/", ""}, method = { RequestMethod.GET, RequestMethod.POST })
	public String loginForm(@RequestParam(name = "error", required = false) String error, Model model) {

		if (error != null) {
			model.addAttribute("message", "아이디 또는 패스워드가 일치하지 않습니다.");
		}

		return "member/login2";
	}

	
	@GetMapping("/home")
	public String home(Authentication authentication, Model model) throws Exception {

		String empId = authentication.getName();

		List<ProjectsDto> list = projectService.projectslist(empId);
		model.addAttribute("projectList", list);

		model.addAttribute("projectCount", list.size());

		EmployeeDto member = employeeService.findByEmpId(empId);
		model.addAttribute("dto", member);
		model.addAttribute("today", new Date());

		Map<String, Object> map = new HashMap<>();
		map.put("empId", empId);

		Map<String, Object> badge = approvalDocService.getBadgeCounts(map);

		model.addAttribute("pendingCount", badge.get("pendingCount"));
		model.addAttribute("unreadCount", badge.get("unreadCount"));
		
		List<Map<String,Object>> todoList = taskService.findByEmpId(empId);
		model.addAttribute("todoList", todoList);

		return "main/home";
	}
}
