package com.mvc.app.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mvc.app.service.CommonCodeService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/common/code")
public class CommonCodeRestController {

    private final CommonCodeService commonCodeService;

    @GetMapping("/{codeGroup}")
    public ResponseEntity<?> listByGroup(@PathVariable("codeGroup") String codeGroup) {
        return ResponseEntity.ok(Map.of("list", commonCodeService.listByGroup(codeGroup)));
    }
}