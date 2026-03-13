package com.mvc.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
public class ViewController {
	@GetMapping("/hrm")
	public String handleHrmEmployee() {
		return "hrm/employeeMain";  
	}
	
	@GetMapping("/activity-log")
	public String handleHrmactivitylog() {
		return "hrm/activityLogMain";  
	}

	@GetMapping("/hrm/org")
	public String handleHrmOrg() {
		return "hrm/orgMain";      
	}

	
	 @GetMapping("/hrm/performance") 
	 public String handleHrmPerformance() { 
		 return "hrm/empPerformanceMain"; 
	 }
	 

	@GetMapping("/hrm/records")
	public String handleHrmRecords() {
		return "hrm/recordsMain";
	}
}
