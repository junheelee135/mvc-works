package com.mvc.app.security;

import java.util.ArrayList;
import java.util.List;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.mvc.app.domain.dto.EmployeeDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.service.EmployeeService;

import lombok.RequiredArgsConstructor;

/*
## UserDetailsService
  - 스프링 시큐리티에서 사용자 인증을 처리할 때 사용되는 인터페이스
  - 주로 사용자 정보를 데이터베이스나 다른 저장소에서 조회하여 인증 및 권한 부여에 필요한 사용자 정보를 제공하는 역할
  - 스프링 시큐리티는 UserDetailsService를 통해 사용자가 로그인할 때 필요한
    사용자 정보(Username, Password, 권한 등)을 UserDetails 객체로 반환하여 인증 처리 및 권한 검증을 진행
*/
@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {
	private final EmployeeService memberService;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		EmployeeDto member = memberService.findByEmpId(username);

		if(member == null) {
			throw new UsernameNotFoundException("아이디가 존재하지 않습니다.");
		}

		List<String> authorities = new ArrayList<>();
		String authority = memberService.findByAuthority(username);
		authorities.add(authority);

		return toUserDetails(member, authorities);
	}

	private UserDetails toUserDetails(EmployeeDto member, List<String> authorities) {
		SessionInfo info = SessionInfo.builder()
				.empId(member.getEmpId())
				.password(member.getPassword())
				.name(member.getName())
				.email(member.getEmail())
				.userLevel(NumericRoleGranted.getUserLevel(member.getAuthority()))
				.avatar(member.getProfilePhoto())
		        .deptCode(member.getDeptCode())
		        .deptName(member.getDeptName())
		        .gradeCode(member.getGradeCode())
		        .gradeName(member.getGradeName())				
				.build();

		return CustomUserDetails.builder()
				.sessionInfo(info)
				.disabled(member.getEnabled() == 0)
				.roles(authorities)
				.build();
	}

}
