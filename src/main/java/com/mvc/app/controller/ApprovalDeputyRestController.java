package com.mvc.app.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.mvc.app.domain.dto.ApprovalDeputyDto;
import com.mvc.app.domain.dto.SessionInfo;
import com.mvc.app.security.LoginMemberUtil;
import com.mvc.app.service.ApprovalDeputyService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/api/absence")
public class ApprovalDeputyRestController {

	private final ApprovalDeputyService service;

	@PostMapping
	public ResponseEntity<?> registerDeputy(@RequestBody ApprovalDeputyDto dto) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			dto.setDelegatorEmpId(info.getEmpId());
			dto.setRegEmpId(info.getEmpId());
			dto.setRegTypeCode("SELF");
			dto.setIsActive("Y");
			service.registerDeputy(dto);
			return ResponseEntity.ok(Map.of("msg", "부재 등록 완료"));
		} catch (Exception e) {
			log.info("registerDeputy : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "부재 등록에 실패했습니다."));
		}
	}

	@PutMapping("/{deputyRegId}")
	public ResponseEntity<?> updateDeputy(@PathVariable("deputyRegId") long deputyRegId,
			@RequestBody ApprovalDeputyDto dto) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			dto.setDeputyRegId(deputyRegId);
			dto.setDelegatorEmpId(info.getEmpId());
			service.updateDeputy(dto);
			return ResponseEntity.ok(Map.of("msg", "부재 수정 완료"));
		} catch (Exception e) {
			log.info("updateDeputy : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "부재 수정에 실패했습니다."));
		}
	}

	@DeleteMapping("/{deputyRegId}")
	public ResponseEntity<?> cancelDeputy(@PathVariable("deputyRegId") long deputyRegId) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			boolean ok = service.cancelDeputy(deputyRegId, info.getEmpId());
			if (ok)
				return ResponseEntity.ok(Map.of("msg", "부재가 취소되었습니다."));
			return ResponseEntity.badRequest().body(Map.of("msg", "취소할 수 없는 부재입니다."));
		} catch (Exception e) {
			log.info("cancelDeputy : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "취소 처리에 실패했습니다."));
		}
	}

	@GetMapping("/list")
	public ResponseEntity<?> listDeputy(@RequestParam(name = "pageNo", defaultValue = "1") int pageNo,
			@RequestParam(name = "pageSize", defaultValue = "20") int pageSize) {
		try {
			SessionInfo info = LoginMemberUtil.getSessionInfo();
			Map<String, Object> map = new HashMap<>();
			map.put("empId", info.getEmpId());
			map.put("pageSize", pageSize);
			map.put("offset", (pageNo - 1) * pageSize);
			return ResponseEntity.ok(service.listDeputy(map));
		} catch (Exception e) {
			log.info("listDeputy : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "목록 조회에 실패했습니다."));
		}
	}

	@GetMapping("/{deputyRegId}")
	public ResponseEntity<?> getDeputy(@PathVariable("deputyRegId") long deputyRegId) {
		try {
			ApprovalDeputyDto dto = service.getDeputy(deputyRegId);
			if (dto == null)
				return ResponseEntity.notFound().build();
			return ResponseEntity.ok(dto);
		} catch (Exception e) {
			log.info("getDeputy : ", e);
			return ResponseEntity.badRequest().body(Map.of("msg", "조회에 실패했습니다."));
		}
	}
}
