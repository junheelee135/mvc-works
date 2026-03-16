package com.mvc.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.mvc.app.service.ProjectNoticeService;

@Controller
@RequestMapping("/projects/projectNotice")
public class ProjectNoticeController {

	private final ProjectNoticeService projectNoticeService;

	public ProjectNoticeController(ProjectNoticeService projectNoticeService) {
		this.projectNoticeService = projectNoticeService;
	}

	@GetMapping("")
	public String list(@AuthenticationPrincipal UserDetails user, Model model) {

		if (user == null) {
			return "redirect:/";
		}

		String empId = user.getUsername();

		List<Map<String, Object>> list = projectNoticeService.getMyProjects(empId);
		model.addAttribute("projectList", list);

		return "projects/projectNotice";
	}

	@GetMapping("/projectNoticeForm")
	public String projectNoticeForm() {
		return "projects/projectNoticeForm";
	}
}