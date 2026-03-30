package com.mvc.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.mvc.app.common.MyUtil;
import com.mvc.app.common.PaginateUtil;
import com.mvc.app.common.RequestUtils;
import com.mvc.app.domain.dto.EmployeeDto;
import com.mvc.app.domain.dto.ProjectsDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.EmployeeService;
import com.mvc.app.service.ProjectService;
import com.mvc.app.service.TaskService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/projects/*")
public class ProjectController {
	private final ProjectService service;
	private final EmployeeService employeeService;
	private final TaskService taskService;
	private final PaginateUtil paginateUtil;
	private final MyUtil myUtil;

	@GetMapping("list")
	public String projectlist(@RequestParam(name = "page", defaultValue = "1") int current_page,
			@RequestParam(name = "schType", defaultValue = "all") String schType,
			@RequestParam(name = "status", defaultValue = "") String status,
			@RequestParam(name = "kwd", defaultValue = "") String kwd, Model model) throws Exception {

		try {
			// 자동 상태 업데이트 로직들
			service.projectAutoCompleteAll();
			service.projectAutoStart();
			service.projectAutoDelay();
			taskService.taskAutoDelay();

			int size = 10;
			int total_page = 0;

			kwd = myUtil.decodeUrl(kwd);
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			Map<String, Object> map = new HashMap<>();
			map.put("empId", info.getEmpId());
			map.put("schType", schType);
			map.put("kwd", kwd);
			map.put("status", status);

			int dataCount = service.dataCount(map);
			if (dataCount != 0) {
				total_page = (int) Math.ceil((double) dataCount / size);
			}
			current_page = Math.min(current_page, total_page > 0 ? total_page : 1);
			int offset = (current_page - 1) * size;
			map.put("offset", offset < 0 ? 0 : offset);
			map.put("size", size);

			List<ProjectsDto> list = service.projectslist(map);

			// 상태별 카운트 (상단 대시보드용)
			Map<String, Object> emptyMap = new HashMap<>();
			List<ProjectsDto> allList = service.statusCount(emptyMap);

			long totalProjects = allList.size();
			long activeProjects = allList.stream().filter(p -> "2".equals(p.getStatus())).count();
			long finishedProjects = allList.stream().filter(p -> "4".equals(p.getStatus())).count();
			long delayedProjects = allList.stream().filter(p -> "5".equals(p.getStatus())).count();

			String cp = RequestUtils.getContextPath();
			String query = "";
			String listUrl = cp + "/projects/list";

			if (!kwd.isBlank() || !status.isBlank()) {
				query = "schType=" + schType + "&kwd=" + myUtil.encodeUrl(kwd);
				if (!status.isBlank()) {
					query += "&status=" + status;
				}
				listUrl += "?" + query;
			}

			String paging = paginateUtil.paging(current_page, total_page, listUrl);

			model.addAttribute("list", list);
			model.addAttribute("dataCount", dataCount);
			model.addAttribute("page", current_page);
			model.addAttribute("paging", paging);
			model.addAttribute("schType", schType);
			model.addAttribute("kwd", kwd);
			model.addAttribute("status", status);

			model.addAttribute("totalProjects", totalProjects);
			model.addAttribute("activeProjects", activeProjects);
			model.addAttribute("finishedProjects", finishedProjects);
			model.addAttribute("delayedProjects", delayedProjects);

		} catch (Exception e) {
			log.error("projectlist error: ", e);
		}

		return "projects/list";
	}

	@GetMapping("create")
	public String projectCreate(Model model) {
		SessionInfo info = LoginMemberUtil.getSessionInfo();
		EmployeeDto emp = employeeService.findByEmpId(info.getEmpId());
		model.addAttribute("empId", emp.getEmpId());
		model.addAttribute("empName", emp.getName());
		model.addAttribute("empDept", emp.getDeptName());
		model.addAttribute("empGrade", emp.getGradeName());
		model.addAttribute("empGradeCode", emp.getGradeCode());

		return "projects/create";
	}

	@PostMapping("create")
	@ResponseBody
	public ResponseEntity<?> createFullProject(@RequestBody ProjectsDto dto) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			dto.setEmpId(info.getEmpId());

			service.createFullProject(dto, dto.getMembers(), dto.getStages());
			return ResponseEntity.ok().build();

		} catch (Exception e) {
			log.error("createFullProject error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}

	@GetMapping("article")
	public String projectarticle(@RequestParam(name = "projectId") long projectId, Model model) {
		try {
			ProjectsDto dto = service.projectarticle(projectId);
			List<ProjectsDto> members = service.projectMembers(projectId);

			model.addAttribute("dto", dto);
			model.addAttribute("members", members);

		} catch (Exception e) {
			log.error("projectarticle error: ", e);
		}
		return "projects/article";
	}

	@PostMapping("updateDate")
	@ResponseBody
	public ResponseEntity<?> updateProjectDate(@RequestBody Map<String, Object> map) {
		try {
			service.updateProjectDate(map);
			return ResponseEntity.ok().build();
		} catch (Exception e) {
			log.error("updateProjectDate error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}

	@GetMapping("gantt")
	public String projectgantt(@RequestParam(name = "page", defaultValue = "1") int current_page,
			@RequestParam(name = "schType", defaultValue = "all") String schType,
			@RequestParam(name = "kwd", defaultValue = "") String kwd, Model model) {

		try {
			service.projectAutoStart();
			service.projectAutoDelay();
			taskService.taskAutoDelay();

			int size = 10;
			int total_page = 0;

			kwd = myUtil.decodeUrl(kwd);
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			Map<String, Object> map = new HashMap<>();
			map.put("empId", info.getEmpId());
			map.put("schType", schType);
			map.put("kwd", kwd);

			int dataCount = taskService.myDataCount(map);
			if (dataCount != 0) {
				total_page = (int) Math.ceil((double) dataCount / size);
			}
			current_page = Math.min(current_page, total_page > 0 ? total_page : 1);
			int offset = (current_page - 1) * size;
			map.put("offset", offset < 0 ? 0 : offset);
			map.put("size", size);

			List<ProjectsDto> list = taskService.myProjectslist(map);

			String cp = RequestUtils.getContextPath();
			String listUrl = cp + "/projects/gantt";
			if (!kwd.isBlank()) {
				listUrl += "?schType=" + schType + "&kwd=" + myUtil.encodeUrl(kwd);
			}

			String paging = paginateUtil.paging(current_page, total_page, listUrl);

			model.addAttribute("list", list);
			model.addAttribute("paging", paging);
			model.addAttribute("page", current_page);
			model.addAttribute("schType", schType);
			model.addAttribute("kwd", kwd);

		} catch (Exception e) {
			log.error("projectgantt error: ", e);
		}
		return "projects/gantt";
	}

	@GetMapping("task")
	public String projectask(@RequestParam(name = "page", defaultValue = "1") int current_page,
			@RequestParam(name = "projectId") long projectId,
			@RequestParam(name = "schType", defaultValue = "all") String schType,
			@RequestParam(name = "kwd", defaultValue = "") String kwd, Model model) {

		try {
			service.projectAutoStart();
			service.projectAutoDelay();
			taskService.taskAutoDelay();

			int size = 30;
			kwd = myUtil.decodeUrl(kwd);

			Map<String, Object> map = new HashMap<>();
			map.put("projectId", projectId);
			map.put("schType", schType);
			map.put("kwd", kwd);

			int taskDataCount = taskService.taskDataCount(map);
			int total_page = (taskDataCount != 0) ? (int) Math.ceil((double) taskDataCount / size) : 0;

			current_page = Math.min(current_page, total_page > 0 ? total_page : 1);
			int offset = (current_page - 1) * size;
			map.put("offset", offset < 0 ? 0 : offset);
			map.put("size", size);

			List<ProjectsDto> members = service.projectMembers(projectId);
			List<ProjectsDto> stages = taskService.findStagesByProjectId(projectId);

			SessionInfo info = LoginMemberUtil.getSessionInfo();
			String loginEmpId = info.getEmpId();

			boolean isManager = members.stream()
					.anyMatch(m -> m.getEmpId().equals(loginEmpId) && "M".equals(m.getRole()));

			model.addAttribute("isManager", isManager);
			model.addAttribute("loginEmpId", loginEmpId);

			String cp = RequestUtils.getContextPath();
			String listUrl = cp + "/projects/task?projectId=" + projectId;
			if (!kwd.isBlank()) {
				listUrl += "&schType=" + schType + "&kwd=" + myUtil.encodeUrl(kwd);
			}

			String paging = paginateUtil.paging(current_page, total_page, listUrl);

			List<ProjectsDto> list = taskService.tasklist(map);
			model.addAttribute("list", list);
			model.addAttribute("paging", paging);
			model.addAttribute("projectId", projectId);
			model.addAttribute("stages", stages);
			model.addAttribute("members", members);

			ProjectsDto dto = service.projectarticle(projectId);
			model.addAttribute("projectStart", dto.getStartDate() != null ? dto.getStartDate().replace("/", "-") : "");
			model.addAttribute("projectEnd", dto.getEndDate() != null ? dto.getEndDate().replace("/", "-") : "");
			model.addAttribute("projectTitle", dto.getTitle());
			model.addAttribute("projectStatus", dto.getStatus());

		} catch (Exception e) {
			log.error("projecttask error: ", e);
		}

		return "projects/task";
	}

	@GetMapping("/myTask")
	public String myTaskList(@RequestParam(name = "page", defaultValue = "1") int current_page,
			@RequestParam(name = "projectId", required = false, defaultValue = "0") long projectId,
			@RequestParam(name = "schType", defaultValue = "all") String schType,
			@RequestParam(name = "kwd", defaultValue = "") String kwd, Model model) {

		try {
			service.projectAutoStart();
			service.projectAutoDelay();
			taskService.taskAutoDelay();

			int size = 30;
			kwd = myUtil.decodeUrl(kwd);

			SessionInfo info = LoginMemberUtil.getSessionInfo();
			String loginEmpId = info.getEmpId();

			// 1. 셀렉트 박스용 내 프로젝트 목록
			Map<String, Object> projectParams = new HashMap<>();
			projectParams.put("empId", loginEmpId);
			projectParams.put("offset", 0);
			projectParams.put("size", 1000);

			List<ProjectsDto> myProjects = service.myProjectsList(projectParams);
			model.addAttribute("myProjects", myProjects);

			// 2. 내 업무(Task) 목록
			Map<String, Object> map = new HashMap<>();
			if (projectId != 0)
				map.put("projectId", projectId);
			map.put("empId", loginEmpId);
			map.put("schType", schType);
			map.put("kwd", kwd);

			int taskDataCount = taskService.myTaskDataCount(map);
			int total_page = (taskDataCount != 0) ? (int) Math.ceil((double) taskDataCount / size) : 0;

			current_page = Math.min(current_page, total_page > 0 ? total_page : 1);
			int offset = (current_page - 1) * size;
			map.put("offset", offset < 0 ? 0 : offset);
			map.put("size", size);

			List<ProjectsDto> list = taskService.myTasklist(map);
			model.addAttribute("list", list);

			String cp = RequestUtils.getContextPath();
			String listUrl = cp + "/projects/myTask?projectId=" + projectId;
			String paging = paginateUtil.paging(current_page, total_page, listUrl);

			model.addAttribute("paging", paging);
			model.addAttribute("projectId", projectId);
			model.addAttribute("loginEmpId", loginEmpId);

			if (projectId != 0) {
				ProjectsDto dto = service.projectarticle(projectId);
				if (dto != null) {
					model.addAttribute("projectTitle", dto.getTitle());
					model.addAttribute("projectStart",
							dto.getStartDate() != null ? dto.getStartDate().replace("/", "-") : "");
					model.addAttribute("projectEnd",
							dto.getEndDate() != null ? dto.getEndDate().replace("/", "-") : "");

					// 매니저 권한 체크
					List<Map<String, Object>> managerProjects = service.ManagerProjects(loginEmpId);
					boolean isManager = managerProjects != null && managerProjects.stream()
							.anyMatch(m -> String.valueOf(m.get("PROJECTID")).equals(String.valueOf(projectId)));

					model.addAttribute("isManager", isManager);
					model.addAttribute("stages", taskService.findStagesByProjectId(projectId));
					model.addAttribute("members", service.projectMembers(projectId));
				}
			}

		} catch (Exception e) {
			log.error("myTaskList error: ", e);
		}

		return "projects/myTask";
	}

	@PostMapping("task/insert")
	@ResponseBody
	public ResponseEntity<?> insertTask(@RequestBody ProjectsDto dto) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			dto.setTaskCreator(info.getEmpId());

			if (dto.getEmpId() == null || dto.getEmpId().isEmpty()) {
				dto.setEmpId(info.getEmpId());
			}

			taskService.insertProjectTask(dto);
			return ResponseEntity.ok().build();
		} catch (Exception e) {
			log.error("insertTask error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}

	@PostMapping("task/update")
	@ResponseBody
	public ResponseEntity<?> updateTask(@RequestBody List<ProjectsDto> list) {
		try {
			for (ProjectsDto dto : list) {
				taskService.updateProjectTask(dto);
			}

			Map<String, Object> result = new HashMap<>();
			if (!list.isEmpty()) {
				String empTaskId = taskService.findEmpTaskId(list.get(0).getTaskId());
				result.put("empTaskId", empTaskId);
			}
			return ResponseEntity.ok(result);
		} catch (Exception e) {
			log.error("updateTask error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}

	@PostMapping("task/dailyinsert")
	@ResponseBody
	public ResponseEntity<?> insertTaskDailylog(@RequestBody ProjectsDto dto) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			dto.setEmpId(info.getEmpId());
			taskService.insertTaskDailylog(dto);
			return ResponseEntity.ok().build();
		} catch (Exception e) {
			log.error("insertTaskDailylog error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}

	@GetMapping("task/dailylist")
	@ResponseBody
	public ResponseEntity<?> taskDailylist(@RequestParam("empTaskId") String empTaskId) {
		try {
			List<ProjectsDto> logs = taskService.taskDailylist(empTaskId);
			return ResponseEntity.ok(logs);
		} catch (Exception e) {
			log.error("taskDailylist error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}

	@GetMapping("ganttarticle")
	public String projectganttarticle() {
		return "projects/ganttarticle";
	}

	@GetMapping("/myProjectList")
	public String myProjectList(@RequestParam(name = "page", defaultValue = "1") int current_page,
			@RequestParam(name = "schType", defaultValue = "all") String schType,
			@RequestParam(name = "status", defaultValue = "") String status,
			@RequestParam(name = "kwd", defaultValue = "") String kwd, Model model) {

		try {
			service.projectAutoStart();
			service.projectAutoDelay();
			taskService.taskAutoDelay();

			int size = 10;
			kwd = myUtil.decodeUrl(kwd);
			SessionInfo info = LoginMemberUtil.getSessionInfo();

			Map<String, Object> map = new HashMap<>();
			map.put("empId", info.getEmpId());
			map.put("schType", schType);
			map.put("kwd", kwd);
			map.put("status", status);

			int dataCount = service.myProjectsCount(map);
			int total_page = (dataCount != 0) ? (int) Math.ceil((double) dataCount / size) : 0;

			current_page = Math.min(current_page, total_page > 0 ? total_page : 1);
			int offset = (current_page - 1) * size;
			map.put("offset", offset < 0 ? 0 : offset);
			map.put("size", size);

			List<ProjectsDto> list = service.myProjectsList(map);
			List<ProjectsDto> myList = service.myProjectstatusCount(info.getEmpId());

			long totalProjects = myList.size();
			long activeProjects = myList.stream().filter(p -> "2".equals(p.getStatus())).count();
			long finishedProjects = myList.stream().filter(p -> "4".equals(p.getStatus())).count();
			long delayedProjects = myList.stream().filter(p -> "5".equals(p.getStatus())).count();

			String cp = RequestUtils.getContextPath();
			String listUrl = cp + "/projects/myProjectList";
			if (!kwd.isBlank() || !status.isBlank()) {
				listUrl += "?schType=" + schType + "&kwd=" + myUtil.encodeUrl(kwd);
				if (!status.isBlank())
					listUrl += "&status=" + status;
			}

			String paging = paginateUtil.paging(current_page, total_page, listUrl);

			model.addAttribute("list", list);
			model.addAttribute("dataCount", dataCount);
			model.addAttribute("page", current_page);
			model.addAttribute("paging", paging);
			model.addAttribute("totalProjects", totalProjects);
			model.addAttribute("activeProjects", activeProjects);
			model.addAttribute("finishedProjects", finishedProjects);
			model.addAttribute("delayedProjects", delayedProjects);

		} catch (Exception e) {
			log.error("myProjectList error: ", e);
		}

		return "projects/myProjectList";
	}

	@GetMapping("members")
	@ResponseBody
	public ResponseEntity<?> getProjectMembers(@RequestParam("projectId") long projectId) {
		try {
			List<ProjectsDto> members = service.projectMembers(projectId);
			return ResponseEntity.ok(members);
		} catch (Exception e) {
			log.error("getProjectMembers error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}

	@PostMapping("forceStop")
	@ResponseBody
	public ResponseEntity<?> projectForceStop(@RequestParam("projectId") long projectId) {
		try {
			taskService.taskForceStopByProject(projectId);
			service.projectForceStop(projectId);
			return ResponseEntity.ok().build();
		} catch (Exception e) {
			log.error("projectForceStop error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}

	@PostMapping("member/change")
	@ResponseBody
	public ResponseEntity<?> changeMember(@RequestBody Map<String, Object> map) {
		try {
			service.changeMember(map);
			return ResponseEntity.ok().build();
		} catch (Exception e) {
			log.error("changeMember error: ", e);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
		}
	}
}