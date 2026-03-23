package com.mvc.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class QnaBotController {
	@GetMapping("/qnaBot")
	public String chatForm() {
		return "qnaBot/qnaBot";
	}
}
