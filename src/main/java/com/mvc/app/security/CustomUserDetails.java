package com.mvc.app.security;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import com.mvc.app.domain.dto.SessionInfo;

// UserDetails : 사용자 인증(Authentication) 정보를 담기 위한 인테페이스
public class CustomUserDetails implements UserDetails {
	private static final long serialVersionUID = 1L;
	
	private final SessionInfo member;
	private final List<String> roles;
	private final boolean disabled;
	
	private CustomUserDetails(Builder builder) {
		this.member = builder.member;
		this.roles = builder.roles;
		this.disabled = builder.disabled;
	}
	
	// Builder 클래스 정의
	public static class Builder {
		private SessionInfo member;
		private List<String> roles;
		private boolean disabled;
		
		public Builder sessionInfo(SessionInfo member) {
			this.member = member;
			return this;
		}
		
		public Builder roles(List<String> roles) {
			this.roles = roles;
			return this;
		}

		public Builder disabled(boolean disabled) {
			this.disabled = disabled;
			return this;
		}
		
		public CustomUserDetails build() {
			if(this.member == null) {
				throw new IllegalStateException("SessionInfo 객체는 필수 입니다.");
			}
			
			return new CustomUserDetails(this);
		}
		
	}
	
	// 빌더 시작 정적 메서드
	public static Builder builder() {
		return new Builder();
	}

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return roles.stream()
				.map(role -> new SimpleGrantedAuthority(role.startsWith("ROLE_") ? role : "ROLE_" + role))
				.collect(Collectors.toList());
	}

	@Override
	public String getPassword() {
		// 로그인 유저 패스워드
		return member.getPassword();
	}

	@Override
	public String getUsername() {
		// 로그인 유저 아이디
		return member.getEmpId();
	}
	
	@Override
	public boolean isEnabled() {
		return ! disabled;
	}
	
	@Override
	public boolean isAccountNonExpired() {
		return true;
	}
	
	@Override
	public boolean isAccountNonLocked() {
		return true;
	}
	
	@Override
	public boolean isCredentialsNonExpired() {
		return true;
	}
	
	public SessionInfo getMember() {
		return member;
	}
}
