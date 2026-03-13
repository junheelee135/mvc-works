package com.mvc.app.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.mvc.app.mapper.CommonCodeMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CommonCodeServiceImpl implements CommonCodeService {

    private final CommonCodeMapper commonCodeMapper;

    @Override
    public List<Map<String, Object>> listByGroup(String codeGroup) {
        return commonCodeMapper.listByGroup(codeGroup);
    }
}