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

/*
  - url?continue
    : 주소 뒤에 ?continue 붙는 경우가 발생
    : 스프링 시큐리티가 6.x로 업그레이드되면서 스프링부트 안정성을 추구하면서 발생되는 현상
    
  - CORS(Cross-Origin Resource Sharing)
    : 교차 출처 리소스 공유라는 의미
    : 웹 브라우저에서 다른 출처(origin)의 리소스에 접근할 수 있도록 허용하는 메커니즘
    
  - CSRF(Cross-Site Request Forgery)
    : 교차 사이트 요청 위조
    : 사용자가 의도하지 않은 요청을 악의적인 웹사이트가 사용자의 브라우저를 통해 
      특정 웹사이트로 보내는 공격 방식
      
  - authorizeHttpRequests()
    : 스프링 시큐리티의 구성 메서드 내에서 사용되는 메서드로, HTTP 요청에 대한 인가 설정을 구성하는 데 사용
    : 다양한 인가 규칙을 정의할 수 있으며, 경로별로 다른 권한 설정이 가능하다.
    	    
  - requestMatchers()
    : authorizeHttpRequests()와 함께 사용되어 특정한 HTTP 요청 매처(Request Matcher)를 적용할 수 있게 해준다.
    : 요청의 종류는 HTTP 메서드(GET, POST 등)나 서블릿 경로를 기반으로 지정할 수 있다.
      requestMatchers(HttpMethod.GET,  "/public/**") 처럼 
      HTTP GET 요청 중 "/public/"으로 시작하는 URL에 대한 보안 설정  

  - UserDetailsService
    : JDBC 연동은 UserDetailsService 구현 클래스 작성
    : 스프링 시큐리티에서 사용자 인증을 처리할 때 사용되는 인터페이스
    : 주로 사용자 정보를 데이터베이스나 다른 저장소에서 조회하여 인증 및 권한 부여에 필요한 사용자 정보를 제공하는 역할
    : 스프링 시큐리티는 UserDetailsService를 통해 사용자가 로그인할 때 필요한 
      사용자 정보(Username, Password, 권한 등)을 UserDetails 객체로 반환하여 인증 처리 및 권한 검증을 진행       
*/

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
				"/favicon.ico", "/WEB-INF/views/**" };

		http.cors(Customizer.withDefaults()) // CORS 설정 : 기본값 사용
			.csrf(AbstractHttpConfigurer::disable) // CSRF 비활성화
			.requestCache(request -> request.requestCache(requestCache)); // 요청 캐시 설정, ?continue 제거

		http.authorizeHttpRequests(authorize -> authorize
			.requestMatchers(excludeUri).permitAll()
			.requestMatchers("/admin", "/admin/**").hasAnyRole("ADMIN")
			.requestMatchers("/**").hasAnyRole("EMP", "ADMIN") // configurer 에서 ROLE_ 붙여줌
			.requestMatchers("/api/notifications/**").authenticated()// 알림 처리 허용
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
