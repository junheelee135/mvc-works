package com.mvc.app.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.mvc.app.service.ProjectNoticeService;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/projects/projectNotice")
@RequiredArgsConstructor
public class ProjectNoticeController {

	private final ProjectNoticeService projectNoticeService;

	@GetMapping({ "", "/" })
	public String list(@AuthenticationPrincipal UserDetails user) {
		if (user == null)
			return "redirect:/";

		return "projects/projectNotice";
	}

	@GetMapping("/projectNoticeForm")
	public String projectNoticeForm(@AuthenticationPrincipal UserDetails user, Model model,
			@RequestParam(name = "projectid", required = false) String projectid) {
		if (user == null)
			return "redirect:/";

		String empId = user.getUsername();
		java.util.List<java.util.Map<String, Object>> projectList = projectNoticeService.getMyPmProjects(empId);

		if (projectList.isEmpty()) {
			return "redirect:/projects/projectNotice/";
		}

		model.addAttribute("projectList", projectList);
		model.addAttribute("selectedProjectId", projectid);
		return "projects/projectNoticeForm";
	}

	@GetMapping("/projectNoticeDetail")
	public String detail(@AuthenticationPrincipal UserDetails user, Model model,
			@RequestParam(name = "projectNoticeNum", required = true) Long projectNoticeNum) {
		if (user == null)
			return "redirect:/";
		model.addAttribute("projectNoticeNum", projectNoticeNum);
		return "projects/projectNoticeDetail";
	}
}