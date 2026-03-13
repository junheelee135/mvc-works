package com.mvc.app.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.mvc.app.common.RequestUtils;
import com.mvc.app.domain.dto.EmployeeDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.EmployeeService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping(value = "/member/*")
public class EmployeeController {
	private final EmployeeService service;

	@Value("${file.upload-root}/member")
	private String uploadPath;

	@GetMapping("account")
	public String memberForm(Model model) {
		model.addAttribute("mode", "account");

		return "member/member";
	}

	@PostMapping("account")
	public String memberSubmit(EmployeeDto dto, final RedirectAttributes reAttr, Model model) {

		try {
			dto.setIpAddr(RequestUtils.getClientIp());

			service.insertEmployee(dto, uploadPath);

			StringBuilder sb = new StringBuilder();
			sb.append(dto.getName() + "님의 회원 가입이 정상적으로 처리되었습니다.<br>");
			sb.append("메인화면으로 이동하여 로그인 하시기 바랍니다.<br>");

			reAttr.addFlashAttribute("message", sb.toString());
			reAttr.addFlashAttribute("title", "회원 가입");

			return "redirect:/member/complete";

		} catch (DuplicateKeyException e) {
			model.addAttribute("mode", "account");
			model.addAttribute("message", "아이디 중복으로 회원가입이 실패했습니다.");
		} catch (DataIntegrityViolationException e) {
			model.addAttribute("mode", "account");
			model.addAttribute("message", "제약 조건 위반으로 회원가입이 실패했습니다.");
		} catch (Exception e) {
			model.addAttribute("mode", "account");
			model.addAttribute("message", "회원가입이 실패했습니다.");
		}

		return "member/member";
	}

	@GetMapping("complete")
	public String complete(@ModelAttribute("message") String message) throws Exception {

		if (message == null || message.isBlank()) {
			return "redirect:/";
		}

		return "member/complete";
	}

	@ResponseBody
	@PostMapping("userIdCheck")
	public Map<String, ?> idCheck(@RequestParam(name = "empId") String empId) throws Exception {
		// ID 중복 검사
		Map<String, Object> model = new HashMap<>();

		String p = "false";
		try {
			EmployeeDto dto = service.findByEmpId(empId);
			if (dto == null) {
				p = "true";
			}
		} catch (Exception e) {
		}

		model.put("passed", p);

		return model;
	}

	@GetMapping("pwd")
	public String pwdForm(@RequestParam(name = "dropout", required = false) String dropout, Model model) {

		if (dropout == null) {
			model.addAttribute("mode", "update");
		} else {
			model.addAttribute("mode", "dropout");
		}

		return "member/pwd";
	}

	@PostMapping("pwd")
	public String pwdSubmit(@RequestParam(name = "password") String password, @RequestParam(name = "mode") String mode,
			final RedirectAttributes reAttr, Model model) {

		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			EmployeeDto dto = Objects.requireNonNull(service.findByEmpId(info.getEmpId()));

			boolean bPwd = service.isPasswordCheck(info.getEmpId(), password);

			if (!bPwd) {
				model.addAttribute("mode", mode);
				model.addAttribute("message", "패스워드가 일치하지 않습니다.");

				return "member/pwd";
			}

			if (mode.equals("dropout")) {
				// 게시판 테이블등 자료 삭제

				// 회원탈퇴 처리
				/*
				 * Map<String, Object> map = new HashMap<>(); map.put("empId", info.getEmpId());
				 * map.put("filename", info.getAvatar());
				 */

				// 로그아웃
				LoginMemberUtil.logout();

				StringBuilder sb = new StringBuilder();
				sb.append(dto.getName() + "님의 회원 탈퇴 처리가 정상적으로 처리되었습니다.<br>");
				sb.append("메인화면으로 이동 하시기 바랍니다.<br>");

				reAttr.addFlashAttribute("title", "회원 탈퇴");
				reAttr.addFlashAttribute("message", sb.toString());

				return "redirect:/member/complete";
			}

			model.addAttribute("dto", dto);
			model.addAttribute("mode", "update");

			// 회원정보수정폼
			return "member/editProfile";

		} catch (NullPointerException e) {
			LoginMemberUtil.logout();
		} catch (Exception e) {
		}

		return "redirect:/";
	}

	@PostMapping("update")
	public String updateSubmit(EmployeeDto dto, @RequestParam(name = "newPwd", required = false) String newPwd,
			@RequestParam(name = "confirmPwd", required = false) String confirmPwd,
			@RequestParam(name = "deleteProfile", required = false) String deleteProfile, RedirectAttributes reAttr,
			Model model) {

		StringBuilder sb = new StringBuilder();

		try {

			SessionInfo info = LoginMemberUtil.getSessionInfo();
			dto.setEmpId(info.getEmpId());

			if ("Y".equals(deleteProfile)) {

				Map<String, Object> map = new HashMap<>();
				map.put("empId", info.getEmpId());
				map.put("filename", info.getAvatar());

				service.deleteProfilePhoto(map, uploadPath);

				dto.setProfilePhoto(null);
				info.setAvatar("");
			}

			if (newPwd != null && !newPwd.isBlank()) {

				if (!newPwd.equals(confirmPwd)) {
					model.addAttribute("message", "비밀번호가 일치하지 않습니다.");
					model.addAttribute("dto", dto);
					return "member/editProfile";
				}

				dto.setPassword(newPwd);
			}

			service.updateEmployee(dto, uploadPath);
			EmployeeDto newDto = service.findByEmpId(info.getEmpId());

			info.setAvatar(newDto.getProfilePhoto());

			reAttr.addFlashAttribute("dto", newDto);

			sb.append(dto.getName() + "님의 회원정보가 정상적으로 변경되었습니다.<br>");

		} catch (Exception e) {

			sb.append("회원정보 변경이 실패했습니다.<br>");
		}

		reAttr.addFlashAttribute("title", "회원 정보 수정");
		reAttr.addFlashAttribute("message", sb.toString());

		return "redirect:/home";
	}

	// 패스워드 찾기
	@GetMapping("pwdFind")
	public String pwdFindForm(HttpSession session) throws Exception {
		SessionInfo info = LoginMemberUtil.getSessionInfo();

		if (info != null) {
			return "redirect:/";
		}

		return "member/pwdFind";
	}

	@PostMapping("pwdFind")
	public String pwdFindSubmit(@RequestParam(name = "empId") String empId, RedirectAttributes reAttr, Model model)
			throws Exception {

		try {
			EmployeeDto dto = service.findByEmpId(empId);
			if (dto == null || dto.getEmail() == null || dto.getEnabled() == 0) {
				model.addAttribute("message", "등록된 아이디가 아닙니다.");

				return "member/pwdFind";
			}

			service.generatePwd(dto);

			StringBuilder sb = new StringBuilder();
			sb.append("회원님의 이메일로 임시패스워드를 전송했습니다.<br>");
			sb.append("로그인 후 패스워드를 변경하시기 바랍니다.<br>");

			reAttr.addFlashAttribute("title", "패스워드 찾기");
			reAttr.addFlashAttribute("message", sb.toString());

			return "redirect:/member/complete";

		} catch (Exception e) {
			model.addAttribute("message", "이메일 전송이 실패했습니다.");
		}

		return "member/pwdFind";
	}

	@ResponseBody
	@PostMapping("deleteProfile")
	public Map<String, ?> deleteProfilePhoto() {

		Map<String, Object> model = new HashMap<>();

		SessionInfo info = LoginMemberUtil.getSessionInfo();

		String state = "false";

		try {

			Map<String, Object> map = new HashMap<>();
			map.put("empId", info.getEmpId());
			map.put("filename", info.getAvatar());

			service.deleteProfilePhoto(map, uploadPath);

			info.setAvatar("");

			state = "true";

		} catch (Exception e) {
			log.error("deleteProfile error", e);
		}

		model.put("state", state);

		return model;
	}

	@GetMapping("updatePwd")
	public String updatePwdForm() throws Exception {
		return "member/updatePwd";
	}

	@PostMapping("updatePwd")
	public String updatePwdSubmit(@RequestParam(name = "password") String password, Model model) throws Exception {

		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			EmployeeDto dto = new EmployeeDto();
			dto.setEmpId(info.getEmpId());
			dto.setPassword(password);

			service.updatePassword(dto);

		} catch (RuntimeException e) {
			model.addAttribute("message", "변경할 패스워드가 기존 패스워드와 일치합니다.");
			return "member/updatePwd";
		} catch (Exception e) {
		}

		return "redirect:/";
	}

	@GetMapping("noAuthorized")
	public String noAuthorized(Model model) {
		// 권한이 없는 경우
		return "member/noAuthorized";
	}

	@GetMapping("expired")
	public String expired() throws Exception {
		// 세션이 익스파이어드(만료) 된 경우
		return "member/expired";
	}
}