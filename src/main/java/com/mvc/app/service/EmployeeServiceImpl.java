package com.mvc.app.service;

import java.security.SecureRandom;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mvc.app.common.StorageService;
import com.mvc.app.domain.dto.EmployeeDto;
import com.mvc.app.mail.Mail;
import com.mvc.app.mail.MailSender;
import com.mvc.app.mapper.EmployeeMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmployeeServiceImpl implements EmployeeService {
	private final EmployeeMapper mapper;
	private final StorageService storageService;
	private final MailSender mailSender;
	private final PasswordEncoder bcryptEncoder;

	@Transactional(rollbackFor = { Exception.class })
	@Override
	public void insertEmployee(EmployeeDto dto, String uploadPath) throws Exception {
		try {
			if (dto.getSelectFile() != null && !dto.getSelectFile().isEmpty()) {
				String saveFilename = storageService.uploadFileToServer(dto.getSelectFile(), uploadPath);
				dto.setProfilePhoto(saveFilename);
			}

			String encPassword = bcryptEncoder.encode(dto.getPassword());
			dto.setPassword(encPassword);

			mapper.insertEmployee12(dto); // employee1, employee2 동시 입력

			dto.setAuthority("EMP");
			mapper.insertAuthority(dto);

		} catch (Exception e) {
			log.info("insertEmployee : ", e);
			throw e;
		}
	}

	@Override
	public void insertEmployeeStatus(EmployeeDto dto) throws Exception {
		try {
			mapper.insertEmployeeStatus(dto);
		} catch (Exception e) {
			log.info("insertEmployeeStatus : ", e);
			throw e;
		}
	}

	@Override
	public void updatePassword(EmployeeDto dto) throws Exception {
		if (isPasswordCheck(dto.getEmpId(), dto.getPassword())) {
			throw new RuntimeException("패스워드가 기존 패스워드와 일치합니다.");
		}

		try {
			String encPassword = bcryptEncoder.encode(dto.getPassword());
			dto.setPassword(encPassword);

			mapper.updateEmployeePassword(dto);
		} catch (Exception e) {
			log.info("updatePassword : ", e);
			throw e;
		}
	}

	@Override
	public void updateEmployeeEnabled(Map<String, Object> map) throws Exception {
		try {
			mapper.updateEmployeeEnabled(map);
		} catch (Exception e) {
			log.info("updateEmployeeEnabled : ", e);
			throw e;
		}
	}

	@Transactional(rollbackFor = { Exception.class })
	@Override
	public void updateEmployee(EmployeeDto dto, String uploadPath) throws Exception {

		try {

			if (dto.getSelectFile() != null && !dto.getSelectFile().isEmpty()) {

				if (dto.getProfilePhoto() != null && !dto.getProfilePhoto().isBlank()) {
					storageService.deleteFile(uploadPath, dto.getProfilePhoto());
				}

				String saveFilename = storageService.uploadFileToServer(dto.getSelectFile(), uploadPath);

				dto.setProfilePhoto(saveFilename);
			}
			String newPwd = dto.getNewPwd();

			if (newPwd != null && !newPwd.isBlank()) {

				// 기존 비밀번호와 다르면 변경
				if (!isPasswordCheck(dto.getEmpId(), newPwd)) {

					dto.setPassword(bcryptEncoder.encode(newPwd));

					mapper.updateEmployeePassword(dto);
				}
			}
			mapper.updateEmployee2(dto);

		} catch (Exception e) {
			log.info("updateEmployee : ", e);
			throw e;
		}
	}

	@Override
	public void updateLastLogin(String empId) throws Exception {
		try {
			mapper.updateLastLogin(empId);
		} catch (Exception e) {
			log.info("updateLastLogin : ", e);
			throw e;
		}
	}

	@Override
	public EmployeeDto findByEmpId(String empId) {
		EmployeeDto dto = null;
		System.out.println("empId=[" + empId + "]");
		try {
			dto = Objects.requireNonNull(mapper.findByEmpId(empId));
		} catch (NullPointerException e) {
			e.printStackTrace();
		} catch (Exception e) {
			log.info("findByEmpId : ", e);
		}

		return dto;
	}

	@Override
	public Integer checkFailureCount(String empId) {
		int result = 0;

		try {
			Integer count = mapper.checkFailureCount(empId);
			result = (count != null) ? count : 0;
		} catch (Exception e) {
			log.info("checkFailureCount : ", e);
		}

		return result;
	}

	@Override
	public void updateFailureCountReset(String empId) throws Exception {
		try {
			mapper.updateFailureCountReset(empId);
		} catch (Exception e) {
			log.info("updateFailureCountReset : ", e);
			throw e;
		}
	}

	@Override
	public void updateFailureCount(String empId) throws Exception {
		try {
			mapper.updateFailureCount(empId);
		} catch (Exception e) {
			log.info("updateFailureCount : ", e);
			throw e;
		}
	}

	@Transactional(rollbackFor = { Exception.class })
	@Override
	public void deleteEmployee(Map<String, Object> map, String uploadPath) throws Exception {
		try {
			mapper.deleteAuthority(map);

			map.put("enabled", 0);
			mapper.updateEmployeeEnabled(map);

			String filename = (String) map.get("filename");
			if (filename != null && !filename.isBlank()) {
				storageService.deleteFile(uploadPath, filename);
			}

			mapper.deleteEmployee2(map);
		} catch (Exception e) {
			log.info("deleteEmployee : ", e);
			throw e;
		}
	}

	@Override
	public void deleteProfilePhoto(Map<String, Object> map, String uploadPath) throws Exception {
		try {
			String filename = (String) map.get("filename");
			if (filename != null && !filename.isBlank()) {
				storageService.deleteFile(uploadPath, filename);
			}

			mapper.deleteProfilePhoto(map);
		} catch (Exception e) {
			log.info("deleteProfilePhoto : ", e);
			throw e;
		}
	}

	@Override
	public void generatePwd(EmployeeDto dto) throws Exception {
		String lowercase = "abcdefghijklmnopqrstuvwxyz";
		String uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		String digits = "0123456789";
		String special_characters = "!#@$%^&*()-_=+[]{}?";
		String all_characters = lowercase + digits + uppercase + special_characters;

		try {
			SecureRandom random = new SecureRandom();
			StringBuilder sb = new StringBuilder();

			sb.append(lowercase.charAt(random.nextInt(lowercase.length())));
			sb.append(uppercase.charAt(random.nextInt(uppercase.length())));
			sb.append(digits.charAt(random.nextInt(digits.length())));
			sb.append(special_characters.charAt(random.nextInt(special_characters.length())));

			for (int i = sb.length(); i < 10; i++) {
				sb.append(all_characters.charAt(random.nextInt(all_characters.length())));
			}

			StringBuilder password = new StringBuilder();
			while (sb.length() > 0) {
				int index = random.nextInt(sb.length());
				password.append(sb.charAt(index));
				sb.deleteCharAt(index);
			}

			String result = dto.getName() + "님의 새로 발급된 임시 패스워드는 <b> " + password.toString() + " </b> 입니다.<br>"
					+ "로그인 후 반드시 패스워드를 변경하시기 바랍니다.";

			Mail mail = new Mail();
			mail.setReceiverEmail(dto.getEmail());
			mail.setSenderEmail("메일설정이메일@도메인");
			mail.setSenderName("관리자");
			mail.setSubject("임시 패스워드 발급");
			mail.setContent(result);

			String encPassword = bcryptEncoder.encode(password.toString());
			dto.setPassword(encPassword);
			mapper.updateEmployeePassword(dto);

			mapper.updateFailureCountReset(dto.getEmpId());

			boolean b = mailSender.mailSend(mail);
			if (!b) {
				throw new Exception("이메일 전송중 오류가 발생했습니다.");
			}

		} catch (Exception e) {
			throw e;
		}
	}

	@Override
	public List<EmployeeDto> listFindMember(Map<String, Object> map) {
		List<EmployeeDto> list = null;

		try {
			list = mapper.listFindMember(map);
		} catch (Exception e) {
			log.info("listFindMember : ", e);
		}

		return list;
	}

	@Override
	public String findByAuthority(String empId) {
		String authority = null;

		try {
			authority = mapper.findByAuthority(empId);
		} catch (Exception e) {
			log.info("findByAuthority", e);
		}

		return authority;
	}

	@Override
	public void insertRefreshToken(EmployeeDto dto) throws Exception {
		try {
			mapper.insertRefreshToken(dto);
		} catch (Exception e) {
			log.info("insertRefreshToken", e);
			throw e;
		}
	}

	@Transactional(rollbackFor = { Exception.class })
	@Override
	public void updateRefreshToken(EmployeeDto dto) throws Exception {
		try {
			mapper.updateRefreshToken(dto);
		} catch (Exception e) {
			log.info("updateRefreshToken", e);
			throw e;
		}
	}

	@Override
	public EmployeeDto findByToken(String empId) {
		EmployeeDto dto = null;

		try {
			dto = mapper.findByToken(empId);
		} catch (Exception e) {
			log.info("findByToken", e);
		}

		return dto;
	}

	@Override
	public boolean isPasswordCheck(String empId, String password) {

		if (password == null || password.isBlank()) {
			return false;
		}

		try {
			EmployeeDto dto = Objects.requireNonNull(findByEmpId(empId));
			return bcryptEncoder.matches(password, dto.getPassword());

		} catch (Exception e) {
			return false;
		}
	}

	
}
