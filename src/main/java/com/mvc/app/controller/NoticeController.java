package com.mvc.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/groupware")
public class NoticeController {

    // 공지사항 페이지
    @GetMapping("/notice")
    public String notice() {
        return "groupware/notice";   // /WEB-INF/views/groupware/notice.jsp
    }
}
