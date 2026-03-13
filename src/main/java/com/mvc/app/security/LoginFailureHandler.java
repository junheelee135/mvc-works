package com.mvc.app.security;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;

import com.mvc.app.domain.dto.EmployeeDto;
import com.mvc.app.service.EmployeeService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class LoginFailureHandler implements AuthenticationFailureHandler {
	@Autowired
	private EmployeeService memberService;

	private String defaultFailureUrl;

	@Override
	public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException exception) throws IOException, ServletException {

		String empId = request.getParameter("empId");

		String msg = "로그인 실패";
		try {
			if(exception instanceof BadCredentialsException) {
				// 패스워드가 일치하지 않은 경우

				int cnt = memberService.checkFailureCount(empId);
				if(cnt <= 4) {
					memberService.updateFailureCount(empId);
				}

				if(cnt >= 4) {
					EmployeeDto dto = memberService.findByEmpId(empId);

					// 계정 비활성화
					Map<String, Object> map = new HashMap<>();
					map.put("enabled", 0);
					map.put("empId", dto.getEmpId());
					memberService.updateEmployeeEnabled(map);

					// 비활성화 상태 저장
					dto.setRegEmpId(dto.getEmpId());
					dto.setEmpStatusCode("1");
					dto.setMemo("패스워드 5회이상 실패");
					memberService.insertEmployeeStatus(dto);
				}

				msg = "패스워드 불일치";
			} else if(exception instanceof InternalAuthenticationServiceException) {
				// 존재하지 않은 아이디인 경우

				msg = "존재하지 않은 아이디";
			} else if(exception instanceof DisabledException) {
				// 인증거부 : 계정 비활성화
				msg = "계정 비활성화";
			}


		} catch (Exception e) {
			log.info("Login Failure : " + msg, e);
		}

		response.sendRedirect(defaultFailureUrl);
	}

	public void setDefaultFailureUrl(String defaultFailureUrl) {
		this.defaultFailureUrl = defaultFailureUrl;
	}
}
