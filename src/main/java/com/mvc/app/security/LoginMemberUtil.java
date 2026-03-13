package com.mvc.app.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;

import com.mvc.app.common.RequestUtils;
import com.mvc.app.domain.dto.SessionInfo;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// SecurityContextHolder : 
public class LoginMemberUtil {
	public static SessionInfo getSessionInfo() {
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

		if (authentication == null || !authentication.isAuthenticated()) {
			return null;
		}

		Object principal = authentication.getPrincipal();

		if (principal instanceof CustomUserDetails) {
			return ((CustomUserDetails) principal).getMember();
		}

		return null;
	}

	public static void logout() {
		try {
			HttpServletRequest request = RequestUtils.getCurrentRequest();
			HttpServletResponse response = RequestUtils.getCurrentResponse();
			Authentication auth = SecurityContextHolder.getContext().getAuthentication();

			if (auth != null) {
				// Spring Security의 로그아웃 핸들러 호출
				new SecurityContextLogoutHandler().logout(request, response, auth);
			}
		} catch (Exception e) {
		}
	}

}
