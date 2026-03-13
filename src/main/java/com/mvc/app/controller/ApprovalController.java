package com.mvc.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/approval/*")
public class ApprovalController {

    @GetMapping("list")
    public String approvalList() {
        return "approval/list";
    }

    @GetMapping("create")
    public String approvalCreate() {
        return "approval/create";
    }
    
    @GetMapping("manage/doctype")
    public String docTypeManage() {
        return "approval/doctype";
    }

    @GetMapping("view")
    public String approvalView() {
        return "approval/view";
    }

    @GetMapping("absence")
    public String approvalAbsence() {
        return "approval/approvalAbsence";
    }

	@GetMapping("notice")
	public String approvalNotice() {
	    return "approval/notice";
	}	    
    
}
