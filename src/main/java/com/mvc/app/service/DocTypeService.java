package com.mvc.app.service;

import java.util.List;

import com.mvc.app.domain.dto.DocTypeDto;

public interface DocTypeService {
    public void insertDocType(DocTypeDto dto) throws Exception;
    public List<DocTypeDto> listDocType();
    public DocTypeDto findById(long docTypeId);
    public void updateDocType(DocTypeDto dto) throws Exception;
    public void deleteDocType(long docTypeId) throws Exception;
}