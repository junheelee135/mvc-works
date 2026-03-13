package com.mvc.app.service;

import java.util.List;
import java.util.Map;

public interface CommonCodeService {
    List<Map<String, Object>> listByGroup(String codeGroup);
}