package com.mvc.app.security;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.DefaultRedirectStrategy;
import org.springframework.security.web.RedirectStrategy;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.savedrequest.SavedRequest;

import com.mvc.app.domain.dto.EmployeeDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.service.EmployeeService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/*
- RequestCache
  사용자가 인증되지 않은 상태에서 보호된 URL에 접근했을 때,
  원래 요청했던 URL을 저장해두었다가 로그인 성공 후 다시 그 URL로 보내주는 기능
- RedirectStrategy
  로그인 성공 / 실패 / 인증 필요 상황 등에서 "어디로 어떻게 리다이렉트할지"를 실제로 수행하는 전략 객체
*/
public class LoginSuccessHandler implements AuthenticationSuccessHandler{
	private RequestCache requestCache = new HttpSessionRequestCache();
	private RedirectStrategy redirectStrategy = new DefaultRedirectStrategy();
	private String defaultUrl;
	
	@Autowired
	private EmployeeService memberService;
	
	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
			Authentication authentication) throws IOException, ServletException {
		// System.out.println(authentication.getName()); // 로그인 아이디
		
		try {
			EmployeeDto dto = memberService.findByEmpId(authentication.getName());
			
			// 로그인 날짜 변경
			memberService.updateLastLogin(authentication.getName());
			
			
			//SessionInfo에 세션관련 값 builder
			SessionInfo sessionInfo = SessionInfo.builder()
			        .empId(dto.getEmpId())
			        .name(dto.getName())
			        .email(dto.getEmail())
			        .userLevel(dto.getLevelCode() > 0 ? dto.getLevelCode() : 1)
			        .avatar(dto.getProfilePhoto())
			        .deptCode(dto.getDeptCode())
			        .deptName(dto.getDeptName())
			        .gradeCode(dto.getGradeCode())
			        .gradeName(dto.getGradeName())
			        .build();

			//session member로 가져오기 위한 set
			HttpSession session = request.getSession();
			session.setAttribute("member", sessionInfo);
			
			
			// 패스워드 변경이 90일이 지난 경우 패스워드 변경 폼으로 이동
			DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
			LocalDateTime curDate = LocalDateTime.now();
			LocalDateTime targetDate = LocalDateTime.parse(dto.getUpdateDate(), dtf);
			long daysBetween = ChronoUnit.DAYS.between(targetDate, curDate);
			
			if(daysBetween >= 90) {
				String targetUrl = "/member/updatePwd";
				redirectStrategy.sendRedirect(request, response, targetUrl);
				return;
			}
			
		} catch (Exception e) {
		}
		
		// redirect 설정
		resultRedirectStrategy(request, response, authentication);
	}
	
	protected void resultRedirectStrategy(HttpServletRequest request, 
			HttpServletResponse response,
			Authentication authentication) throws IOException, ServletException {

		SavedRequest savedRequest = requestCache.getRequest(request, response);

		if (savedRequest != null) {
			// 로그인이 필요한 페이지에 접근했을 경우
			String targetUrl = savedRequest.getRedirectUrl();
			redirectStrategy.sendRedirect(request, response, targetUrl);
		} else {
			// 직접 로그인 주소로 이동했을 경우
			redirectStrategy.sendRedirect(request, response, defaultUrl);
		}
	}

	public void setDefaultUrl(String defaultUrl) {
		this.defaultUrl = defaultUrl;
	}
}
