package com.mvc.app.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.mvc.app.domain.dto.DocTypeDto;
import com.mvc.app.mapper.DocTypeMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class DocTypeServiceImpl implements DocTypeService {
    private final DocTypeMapper mapper;

    @Override
    public void insertDocType(DocTypeDto dto) throws Exception {
        try {
            mapper.insertDocType(dto);
        } catch (Exception e) {
            log.info("insertDocType : ", e);
            throw e;
        }
    }

    @Override
    public List<DocTypeDto> listDocType() {
        try {
            return mapper.listDocType();
        } catch (Exception e) {
            log.info("listDocType : ", e);
        }
        return null;
    }

    @Override
    public DocTypeDto findById(long docTypeId) {
        try {
            return mapper.findById(docTypeId);
        } catch (Exception e) {
            log.info("findById : ", e);
        }
        return null;
    }

    @Override
    public void updateDocType(DocTypeDto dto) throws Exception {
        try {
            mapper.updateDocType(dto);
        } catch (Exception e) {
            log.info("updateDocType : ", e);
            throw e;
        }
    }

    @Override
    public void deleteDocType(long docTypeId) throws Exception {
        try {
            mapper.deleteDocType(docTypeId);
        } catch (Exception e) {
            log.info("deleteDocType : ", e);
            throw e;
        }
    }
}