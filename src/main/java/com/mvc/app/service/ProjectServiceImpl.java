package com.mvc.app.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mvc.app.domain.dto.ProjectsDto;
import com.mvc.app.mapper.ProjectNoticeMapper;
import com.mvc.app.mapper.ProjectsMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProjectServiceImpl implements ProjectService {

	private final ProjectsMapper mapper;
	private final ObjectMapper objectMapper;
	private final ProjectNoticeMapper noticeMapper;

	public List<Map<String, Object>> getManagerProjects(String empId) {
		return noticeMapper.getMyPmProjects(empId);
	}

	@Transactional
	@Override
	public void createFullProject(ProjectsDto dto, List<Map<String, Object>> members, List<Map<String, Object>> stages)
			throws Exception {

		try {

			// 프로젝트 생성
			mapper.insertProject(dto);
			long project = dto.getProjectId();

			// 프로젝트 구성원
			if (members != null && !members.isEmpty()) {

				Map<String, Object> memberParam = new HashMap<>();
				memberParam.put("projectId", project);
				memberParam.put("members", members);

				mapper.insertProjectMembers(memberParam);
			}

			// 프로젝트 단계
			if (stages != null && !stages.isEmpty()) {

				Map<String, Object> stage = new HashMap<>();
				stage.put("projectId", project);
				stage.put("stages", stages);

				mapper.insertProjectStep(stage);

				// stageId 조회
				List<Map<String, Object>> stageList = mapper.findStageByProjectId(project);

				for (int i = 0; i < stageList.size(); i++) {

					Map<String, Object> stageMap = stageList.get(i);
					String stageId = (String) stageMap.get("STAGEID");

					Map<String, Object> stg = stages.get(i);

					List<Map<String, Object>> tasks = (List<Map<String, Object>>) stg.get("tasks");

					if (tasks != null && !tasks.isEmpty()) {

						String tasksJson = objectMapper.writeValueAsString(tasks);

						Map<String, Object> taskMap = new HashMap<>();
						taskMap.put("stageId", stageId);
						taskMap.put("tasks", tasksJson);
						taskMap.put("creator", dto.getEmpId());

						mapper.insertTasks(taskMap);
					}
				}
			}

		} catch (Exception e) {
			log.info("createFullProject : ", e);
			throw e;
		}
	}

	@Override
	public List<ProjectsDto> projectslist(Map<String, Object> map) throws Exception {
		List<ProjectsDto> list = null;

		try {
			list = mapper.projectslist(map);
		} catch (Exception e) {
			log.info("projectslist : ", e);
		}

		return list;
	}

	@Override
	public int dataCount(Map<String, Object> map) {

		int result = 0;

		try {
			result = mapper.dataCount(map);
		} catch (Exception e) {
			log.info("dataCount : ", e);
		}

		return result;
	}

	@Override
	public ProjectsDto projectarticle(long projectId) {

		ProjectsDto dto = null;

		try {
			dto = mapper.findById(projectId);
		} catch (Exception e) {
			log.info("projectarticle : ", e);
		}

		return dto;
	}

	@Override
	public List<ProjectsDto> projectMembers(long projectId) throws Exception {

		List<ProjectsDto> list = null;

		try {
			list = mapper.projectMembers(projectId);
		} catch (Exception e) {
			log.info("projectMembers : ", e);
		}

		return list;
	}

	@Override
	public ProjectsDto findById(long projectId) {

		ProjectsDto dto = null;

		try {
			dto = mapper.findById(projectId);
		} catch (Exception e) {
			log.info("findById : ", e);
		}

		return dto;
	}

	@Override
	public List<ProjectsDto> projectslist(String empId) throws Exception {

		try {
			return mapper.findProjectsByEmpId(empId);
		} catch (Exception e) {
			log.info("projectslist : ", e);
			throw e;
		}
	}

	@Override
	public int myProjectsCount(Map<String, Object> map) {
		int count = 0;
		try {
			count = mapper.myProjectsCount(map);
		} catch (Exception e) {
			log.info("myProjectsCount : ", e);
		}
		return count;
	}

	@Override
	public List<ProjectsDto> myProjectsList(Map<String, Object> map) {
		List<ProjectsDto> list = null;
		try {
			list = mapper.myProjectsList(map);
		} catch (Exception e) {
			log.info("myProjectsList : ", e);
		}
		return list;
	}

	@Override
	public List<ProjectsDto> statusCount(Map<String, Object> map) {
		List<ProjectsDto> list = null;

		try {
			list = mapper.statusCount(map);
		} catch (Exception e) {
			log.info("statusCount : ", e);
		}
		return list;
	}

	@Override
	public List<ProjectsDto> myProjectstatusCount(String empId) {
		List<ProjectsDto> list = null;

		try {
			list = mapper.myProjectstatusCount(empId);
		} catch (Exception e) {
			log.info("myProjectstatusCount : ", e);
		}
		return list;
	}

	@Override
	public void projectAutoStart() throws Exception {
		try {
			mapper.projectAutoStart();
		} catch (Exception e) {
			log.info("projectAutoStart : ", e);
			throw e;
		}
	}

	@Override
	public void projectAutoDelay() throws Exception {
		try {
			mapper.projectAutoDelay();
		} catch (Exception e) {
			log.info("projectAutoDelay : ", e);
			throw e;
		}
	}

	@Override
	public void projectForceStop(long projectId) throws Exception {
		try {
			mapper.projectForceStop(projectId);
		} catch (Exception e) {
			log.info("projectForceStop : ", e);
			throw e;
		}
	}

	@Override
	public void changeMember(Map<String, Object> map) throws Exception {
		try {
			mapper.changeEmpTask(map);
			mapper.updatePredecessor(map);
			mapper.updateNewEmpId(map);
		} catch (Exception e) {
			log.info("changeMember : ", e);
			throw e;
		}
	}

	@Override
	public void projectAutoCompleteAll() throws Exception {
		try {
			mapper.projectAutoCompleteAll();
		} catch (Exception e) {
			log.info("projectAutoCompleteAll : ", e);
			throw e;
		}
	}

	@Override
	public void updateProjectDate(Map<String, Object> map) throws Exception {
		try {
			mapper.updateProjectDate(map);
		} catch (Exception e) {
			log.info("updateProjectDate : ", e);
		}

	}

	@Override
	public boolean isProjectManager(long projectId, String empId) {
		try {
			// 사용자가 PM인 프로젝트 리스트를 가져옴
			List<Map<String, Object>> managerProjects = noticeMapper.getMyPmProjects(empId);

			if (managerProjects == null || managerProjects.isEmpty()) {
				return false;
			}

			// 가져온 리스트 중 현재 projectId와 일치하는 것이 있는지 확인
			return managerProjects.stream().anyMatch(m -> {
				Object pid = m.get("PROJECTID");
				return pid != null && String.valueOf(pid).equals(String.valueOf(projectId));
			});
		} catch (Exception e) {
			log.info("isProjectManager error : ", e);
			return false;
		}
	}

	@Override // 인터페이스에 정의된 이름과 맞춤
	public List<Map<String, Object>> ManagerProjects(String empId) {
		return noticeMapper.getMyPmProjects(empId);
	}
}