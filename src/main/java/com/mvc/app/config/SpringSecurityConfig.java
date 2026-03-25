package com.mvc.app.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.ExceptionTranslationFilter;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;

import com.mvc.app.security.AjaxSessionTimeoutFilter;
import com.mvc.app.security.LoginFailureHandler;
import com.mvc.app.security.LoginSuccessHandler;

@Configuration
@EnableWebSecurity
public class SpringSecurityConfig {
	@Bean
	SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
		// configure HTTP security

		// ?continue 제거를 위해
		HttpSessionRequestCache requestCache = new HttpSessionRequestCache();
		requestCache.setMatchingRequestParameterName(null);

		String[] excludeUri = { "/", "/member/login", "/member/logout",
				"/member/expired", "/member/noAuthorized", "/dist/**",
				"/favicon.ico", "/WEB-INF/views/**",
				"/api/notifications/connect", "/ws/chat/**"};

		http.cors(Customizer.withDefaults()) // CORS 설정 : 기본값 사용
			.csrf(AbstractHttpConfigurer::disable) // CSRF 비활성화
			.requestCache(request -> request.requestCache(requestCache)); // 요청 캐시 설정, ?continue 제거

		http.authorizeHttpRequests(authorize -> authorize
			.dispatcherTypeMatchers(jakarta.servlet.DispatcherType.ASYNC).permitAll()
			.requestMatchers(excludeUri).permitAll()
			//hrm 권한 handler
			.requestMatchers("/hrm", "/activity-log").hasAnyRole("ADMIN")
			.requestMatchers("/hrm/**").hasAnyRole("ADMIN", "EMP")
			
			.requestMatchers("/admin", "/admin/**").hasAnyRole("ADMIN")
			.requestMatchers("/api/projectnotice/**").hasAnyRole("EMP","ADMIN")
			.requestMatchers("/api/notifications/**").authenticated()// 알림 처리 허용
			.requestMatchers("/**").hasAnyRole("EMP", "ADMIN", "USER") // configurer 에서 ROLE_ 붙여줌
			.anyRequest().authenticated() // 설정 외 모든 요청은 권한과 무관하고 로그인 유저만 사용
		)
		.formLogin(login -> login
			.loginPage("/")
			.loginProcessingUrl("/member/login")
			.usernameParameter("empId")
			.passwordParameter("password")
			.successHandler(loginSuccessHandler())
			.failureHandler(loginFailureHandler())
			.permitAll()
		)
		.logout(logout -> logout
			.logoutUrl("/member/logout")
			.invalidateHttpSession(true)
			.deleteCookies("JSESSIONID")
			.logoutSuccessUrl("/")
		)
		.addFilterAfter(ajaxSessionTimeoutFilter(), ExceptionTranslationFilter.class)
		.sessionManagement(management -> management
			.maximumSessions(1)
			.expiredUrl("/member/expired"));

		// 인증 거부 관련 처리
		http.exceptionHandling((exceptionConfig) -> exceptionConfig.accessDeniedPage("/member/noAuthorized"));

		return http.build();
	}

	@Bean
	PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	@Bean
	LoginSuccessHandler loginSuccessHandler() {
		LoginSuccessHandler handler = new LoginSuccessHandler();
		handler.setDefaultUrl("/home");
		return handler;
	}

	@Bean
	LoginFailureHandler loginFailureHandler() {
		LoginFailureHandler handler = new LoginFailureHandler();
		handler.setDefaultFailureUrl("/?error");
		return handler;
	}

	@Bean
	AjaxSessionTimeoutFilter ajaxSessionTimeoutFilter() {
		AjaxSessionTimeoutFilter filter = new AjaxSessionTimeoutFilter();
		filter.setAjaxHeader("AJAX");
		return filter;
	}
}
