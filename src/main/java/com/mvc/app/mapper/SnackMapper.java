package com.mvc.app.mapper;

import com.mvc.app.domain.dto.SnackCommentDto;
import com.mvc.app.domain.dto.SnackDto;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface SnackMapper {

	void insertSnack(SnackDto dto);

	void updateSnackStatus(Map<String, Object> map);

	void deleteSnack(long snackId);

	List<SnackDto> listSnack(Map<String, Object> map);

	int countSnack(Map<String, Object> map);

	SnackDto getSnack(Map<String, Object> map);

	void insertVote(Map<String, Object> map);

	void deleteVote(Map<String, Object> map);

	int countVote(long snackId);

	int existsVote(Map<String, Object> map);

	void insertComment(SnackCommentDto dto);

	void deleteComment(long commentId);

	List<SnackCommentDto> listComment(long snackId);
}
