package com.mvc.app.service;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.mvc.app.domain.dto.ProjectNoticeDto;
import com.mvc.app.domain.dto.ProjectNoticeFileDto;
import com.mvc.app.mapper.ProjectNoticeMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProjectNoticeServiceImpl implements ProjectNoticeService {

	private final ProjectNoticeMapper mapper;

	@Value("${file.upload-root}")
	private String uploadRoot;

	@Override
	@Transactional
	public void insertNotice(ProjectNoticeDto dto, List<MultipartFile> files) throws Exception {

		mapper.insertNotice(dto);

		if (files != null && !files.isEmpty()) {
			// ✅ DTO 필드명 변경 반영: getProjectNoticeNum()
			saveFiles(files, dto.getProjectNoticeNum());
		}
	}

	@Override
	@Transactional
	public void updateNotice(ProjectNoticeDto dto, List<MultipartFile> files) throws Exception {

		mapper.updateNotice(dto);

		// ✅ DTO 필드명 변경 반영: getProjectNoticeNum()
		List<ProjectNoticeFileDto> oldFiles = mapper.getFiles(dto.getProjectNoticeNum());

		if (oldFiles != null && !oldFiles.isEmpty()) {
			for (ProjectNoticeFileDto file : oldFiles) {

				File f = new File(uploadRoot, file.getSavefilename());

				if (f.exists()) {
					f.delete();
				}

				mapper.deleteFile(file.getFilenum());
			}
		}

		if (files != null && !files.isEmpty()) {
			// ✅ DTO 필드명 변경 반영: getProjectNoticeNum()
			saveFiles(files, dto.getProjectNoticeNum());
		}
	}

	@Override
	@Transactional
	public void deleteNotice(long projectNoticeNum) throws Exception {

		List<ProjectNoticeFileDto> files = mapper.getFiles(projectNoticeNum);

		if (files != null && !files.isEmpty()) {
			for (ProjectNoticeFileDto file : files) {

				File f = new File(uploadRoot, file.getSavefilename());

				if (f.exists()) {
					f.delete();
				}

				mapper.deleteFile(file.getFilenum());
			}
		}

		mapper.deleteNotice(projectNoticeNum);
	}

	@Override
	public List<ProjectNoticeDto> listNotice(Map<String, Object> param) {
		return mapper.listNotice(param);
	}

	@Override
	public int countNotice(Map<String, Object> param) {
		return mapper.countNotice(param);
	}

	@Override
	@Transactional
	public ProjectNoticeDto getNotice(long projectNoticeNum) {

		mapper.increaseHit(projectNoticeNum);

		ProjectNoticeDto dto = mapper.getNotice(projectNoticeNum);

		if (dto != null) {
			dto.setFiles(mapper.getFiles(projectNoticeNum));
		}

		return dto;
	}

	@Override
	public List<Map<String, Object>> getMyProjects(String empId) {
		return mapper.getMyProjects(empId);
	}

	@Override
	public List<Map<String, Object>> getMyPmProjects(String empId) {
		return mapper.getMyPmProjects(empId);
	}

	@Override
	@Transactional
	public void deleteFile(long filenum) throws Exception {

		ProjectNoticeFileDto file = mapper.getFile(filenum);

		if (file == null)
			return;

		File f = new File(uploadRoot, file.getSavefilename());

		if (f.exists()) {
			f.delete();
		}

		mapper.deleteFile(filenum);
	}

	@Override
	public ProjectNoticeFileDto getFile(long filenum) {
		return mapper.getFile(filenum);
	}

	@Override
	public List<ProjectNoticeFileDto> getFiles(long projectNoticeNum) {
		return mapper.getFiles(projectNoticeNum);
	}

	private void saveFiles(List<MultipartFile> files, long projectNoticeNum) throws Exception {

		File dir = new File(uploadRoot);

		if (!dir.exists()) {
			dir.mkdirs();
		}

		for (MultipartFile mf : files) {

			if (mf == null || mf.isEmpty())
				continue;

			String origin = mf.getOriginalFilename();

			if (origin == null)
				continue;

			String ext = "";

			int idx = origin.lastIndexOf(".");
			if (idx != -1) {
				ext = origin.substring(idx);
			}

			String saveName = UUID.randomUUID().toString().replace("-", "") + ext;

			File dest = new File(uploadRoot, saveName);

			mf.transferTo(dest);

			ProjectNoticeFileDto fileDto = new ProjectNoticeFileDto();

			fileDto.setSavefilename(saveName);
			fileDto.setOriginalfilename(origin);
			fileDto.setFilesize(mf.getSize());
			fileDto.setProjectNoticeNum(projectNoticeNum); 

			mapper.insertFile(fileDto);
		}
	}

	@Override
	public boolean isManager(String empId, long projectid) {
		return mapper.isManager(empId, projectid) > 0;
	}
}