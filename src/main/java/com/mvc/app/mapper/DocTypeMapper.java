package com.mvc.app.mapper;

import java.sql.SQLException;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mvc.app.domain.dto.DocTypeDto;

@Mapper
public interface DocTypeMapper {
    public void insertDocType(DocTypeDto dto) throws SQLException;
    public List<DocTypeDto> listDocType();
    public DocTypeDto findById(long docTypeId);
    public void updateDocType(DocTypeDto dto) throws SQLException;
    public void deleteDocType(long docTypeId) throws SQLException;
}