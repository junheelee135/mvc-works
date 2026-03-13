  package com.mvc.app.mapper;

  import java.util.List;
  import java.util.Map;

  import org.apache.ibatis.annotations.Mapper;
  import org.apache.ibatis.annotations.Param;

  @Mapper
  public interface CommonCodeMapper {
      List<Map<String, Object>> listByGroup(@Param("codeGroup") String codeGroup);
  }