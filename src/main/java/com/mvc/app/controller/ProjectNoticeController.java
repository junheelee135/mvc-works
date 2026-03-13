package com.mvc.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ProjectNoticeController {

    @GetMapping("/projects/projectNotice")
    public String noticeView() {
        return "projects/projectNotice";
    }
}
