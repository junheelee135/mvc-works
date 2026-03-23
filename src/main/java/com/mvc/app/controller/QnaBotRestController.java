package com.mvc.app.controller;

import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.mvc.app.service.QnaBotService;

import lombok.RequiredArgsConstructor;
import reactor.core.publisher.Flux;

@RestController
@RequiredArgsConstructor
public class QnaBotRestController {
	private final QnaBotService qnaBotService;

    @GetMapping("/api/question")
	public Flux<String> handleChat(@RequestParam("question") String question, Model model) throws Exception {
    	return qnaBotService.generateAnswer(question);
	}
}
