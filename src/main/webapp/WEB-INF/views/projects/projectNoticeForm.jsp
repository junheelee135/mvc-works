<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>공지 등록</title>

<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/projectnoticeform.css">
<meta name="ctx" content="${pageContext.request.contextPath}">

<!-- Vue -->
<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

<!-- Quill -->
<link href="https://cdn.quilljs.com/1.3.6/quill.snow.css"
	rel="stylesheet">
<script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>
</head>

<body>
	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<div id="app" v-cloak>
		<div class="main-content">
			<div class="page-header">
				<h2 class="page-title">{{ isEdit ? '공지사항 수정' : '공지사항 등록' }}</h2>
			</div>

			<div class="notice-card">

				<!-- 프로젝트 선택 -->
				<div class="form-row">
					<label>프로젝트 *</label> <select v-model="selectedProjectId">
						<option value="">선택하세요</option>
						<option v-for="p in projects" :key="p.projectid"
							:value="p.projectid">{{ p.projectName }}</option>
					</select>
				</div>

				<!-- 제목 -->
				<div class="form-row">
					<label>제목 *</label> <input class="form-input" type="text"
						v-model="formData.subject" placeholder="제목을 입력하세요">
				</div>

				<!-- 내용 -->
				<div class="form-row">
					<label>내용</label>
					<div id="editor" style="height: 200px;"></div>
				</div>

				<!-- 첨부파일 -->
				<div class="form-row">
					<label>첨부 파일</label>
					<div class="file-area">
						<input type="file" @change="handleFiles" multiple>
						<ul class="file-list">
							<li v-for="f in formData.files" :key="f.name">{{ f.name }}</li>
						</ul>
					</div>
				</div>

				<!-- 버튼 -->
				<div class="form-buttons">
					<button class="btn-cancel" @click="goBack">취소</button>
					<button class="btn-save" @click="submitForm">{{ isEdit ?
						'수정' : '저장' }}</button>
				</div>

			</div>
		</div>
	</div>

	<script>
document.addEventListener('DOMContentLoaded', function() {
	const ctx = document.querySelector('meta[name="ctx"]').content;
	const { createApp } = Vue;

	createApp({
		data() {
			return {
				projects: [],
				selectedProjectId: '',
				formData: {
					projectNoticeNum: null, // ⭐ 추가
					subject: '',
					content: '',
					files: []
				},
				quill: null,
				isEdit: false // ⭐ 수정모드 여부
			}
		},

		async mounted() {
			const params = new URLSearchParams(window.location.search);

			const pid = params.get("projectid");
			const projectNoticeNum = params.get("projectNoticeNum");
			
			// ⭐ 수정모드 체크
			if (projectNoticeNum) {
				this.isEdit = true;
				this.formData.projectNoticeNum = projectNoticeNum;
			}

			if (pid) this.selectedProjectId = pid;

			// Quill
			this.quill = new Quill('#editor', {
				theme: 'snow',
				placeholder: '내용을 입력하세요'
			});

			// 프로젝트 목록
			await this.loadProjects();

			// ⭐ 수정일 때 기존 데이터 불러오기
			if (this.isEdit) {
				await this.loadDetail();
			}
		},

		methods: {
			async loadProjects() {
				try {
					const res = await fetch(ctx + "/api/projectnotice/myprojects/pm", {
						credentials: "include"
					});
					const data = await res.json();

					this.projects = data.map(p => ({
						projectid: p.PROJECTID,
						projectName: p.PROJECTNAME
					}));
				} catch (err) {
					console.error(err);
				}
			},

			// ⭐ 기존 데이터 로드
			async loadDetail() {
				try {
					const res = await fetch(ctx + '/api/projectnotice/detail?projectNoticeNum=' + this.formData.projectNoticeNum, {
						credentials: "include"
					});

					const data = await res.json();

					this.formData.subject = data.detail.subject;
					this.selectedProjectId = data.detail.projectid;

					this.quill.root.innerHTML = data.detail.content;

				} catch (e) {
					console.error(e);
					alert("데이터 불러오기 실패");
				}
			},

			handleFiles(e) {
				this.formData.files = Array.from(e.target.files);
			},

			async submitForm() {
				if (!this.selectedProjectId) {
					alert("프로젝트를 선택해주세요.");
					return;
				}
				if (!this.formData.subject) {
					alert("제목을 입력해주세요.");
					return;
				}

				this.formData.content = this.quill.root.innerHTML;

				if (!this.formData.content || this.formData.content === '<p><br></p>') {
					alert("내용을 입력해주세요.");
					return;
				}

				const form = new FormData();

				form.append("projectid", this.selectedProjectId);
				form.append("subject", this.formData.subject);
				form.append("content", this.formData.content);

				// ⭐ 수정이면 projectNoticeNum 추가
				if (this.isEdit) {
					form.append("projectNoticeNum", this.formData.projectNoticeNum);
				}

				this.formData.files.forEach(f => form.append("files", f));

				try {
					const url = this.isEdit
						? ctx + "/api/projectnotice/update"
						: ctx + "/api/projectnotice";

					const res = await fetch(url, {
						method: "POST",
						body: form,
						credentials: "include"
					});

					if (res.ok) {
						alert(this.isEdit ? "수정 완료" : "등록 완료");

						location.href = ctx + "/projects/projectNotice";
					} else {
						const text = await res.text();
						alert("실패 : " + text);
					}
				} catch (err) {
					console.error(err);
					alert("오류 발생");
				}
			},

			goBack() {
				history.back();
			}
		}
	}).mount("#app");
});
</script>

</body>
</html>