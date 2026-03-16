<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>프로젝트 공지사항</title>

<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />

<link
	href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined"
	rel="stylesheet">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/projectnoticelist.css">
<meta name="ctx" content="${pageContext.request.contextPath}">

<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
<style>
/* v-cloak 적용: Vue 렌더 전 템플릿 숨김 */
[v-cloak] {
	display: none !important;
}
</style>
</head>
<body>
	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<div id="app" v-cloak>
		<div class="main-content">
			<div class="page-header">
				<h2 class="page-title">프로젝트 공지사항</h2>
			</div>

			<!-- 프로젝트 선택 -->
			<div class="project-select-wrap">
				<select v-model="selectedProjectId" @change="onProjectChange"
					class="project-select">
					<option value="">-- 프로젝트 선택 --</option>
					<option v-for="p in myProjects" :key="p.PROJECTID"
						:value="p.PROJECTID">{{ p.PROJECTNAME }}</option>
				</select>
			</div>

			<div v-if="!selectedProjectId" class="empty-msg">소속 프로젝트를
				선택해주세요.</div>

			<div v-else>
				<div class="notice-topbar">
					<div class="notice-search-bar">
						<input v-model="keyword" @keyup.enter="fetchList(1)" type="text"
							placeholder="제목 또는 내용 검색">
						<button @click="fetchList(1)" class="btn-search">검색</button>
					</div>
					<!-- 공지 등록 버튼 -->
					<button v-if="isManager" @click="goToForm" class="btn-new-notice">+
						공지 등록</button>
				</div>

				<div class="notice-panel">
					<table class="notice-table">
						<thead>
							<tr>
								<th style="width: 60px">번호</th>
								<th>제목</th>
								<th style="width: 100px">작성자</th>
								<th style="width: 90px">날짜</th>
								<th style="width: 60px">조회</th>
							</tr>
						</thead>
						<tbody>
							<tr v-if="list.length === 0">
								<td colspan="5"
									style="text-align: center; padding: 30px; color: #999;">
									등록된 공지사항이 없습니다.</td>
							</tr>
							<tr v-for="item in list" :key="item.noticenum"
								@click="openDetail(item.noticenum)">
								<td style="text-align: center"><span
									v-if="item.isnotice === 1" class="badge-notice">공지</span> <span
									v-else>{{ item.noticenum }}</span></td>
								<td>{{ item.subject }}</td>
								<td style="text-align: center">{{ item.authorName }}</td>
								<td style="text-align: center">{{ item.regdate }}</td>
								<td style="text-align: center">{{ item.hitcount }}</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>

	<script>
document.addEventListener('DOMContentLoaded', function() {
	const ctx = document.querySelector('meta[name="ctx"]').content
	const { createApp } = Vue

	createApp({
		data() {
			return {
				myProjects: [],
				selectedProjectId: '',
				list: [],
				isManager: false,
				total: 0,
				page: 1,
				pageSize: 10,
				keyword: '',
				detail: {}
			}
		},
		mounted() {
			this.fetchMyProjects()
		},
		methods: {
			async safeApi(url, options={}) {
				const res = await fetch(ctx + url, {
					credentials: "include",
					headers: { "AJAX":"true", "Content-Type":"application/json", ...(options.headers||{}) },
					...options
				});
				if(res.status===401){ alert("로그인이 필요합니다."); location.href=ctx+"/"; return null }
				if(res.status===403){ alert("권한이 없습니다."); return null }
				return res
			},
			async fetchMyProjects() {
				const res = await this.safeApi('/api/projectnotice/myprojects');
				if(!res) return;
				try { this.myProjects = await res.json() } catch(e){ console.error("프로젝트 목록 로드 실패:", await res.text()) }
			},
			onProjectChange() {
				this.keyword = '';
				this.list = [];
				this.fetchList(1);
			},
			async fetchList(p) {
			    if(!this.selectedProjectId) return;
			    this.page = p;
			    const params = new URLSearchParams({
			        projectid: this.selectedProjectId,
			        page: this.page,
			        keyword: this.keyword || ''
			    });
			    try {
			        const res = await fetch(ctx + '/api/projectnotice/list?' + params, {
			            credentials: "include",
			            headers: { "AJAX": "true", "Content-Type": "application/json" }
			        });
			        const text = await res.text();
			        try {
			            const data = JSON.parse(text);
			            this.list = data.list;
			            this.total = data.total;
			            this.isManager = data.isManager;
			        } catch(e) {
			            console.error("공지사항 JSON 파싱 실패:", text);
			            alert("공지사항을 불러오지 못했습니다.");
			        }
			    } catch(err) {
			        console.error("fetch 오류:", err);
			    }
			},
			async openDetail(noticenum) {
				const res = await this.safeApi('/api/projectnotice/' + noticenum);
				if(!res) return;
				try { this.detail = await res.json() }
				catch(e){ console.error("공지사항 상세 JSON 파싱 실패"); alert("공지사항 내용을 불러오지 못했습니다."); }
			},
				goToForm() {
				    window.location.href = ctx + '/projects/projectNotice/projectNoticeForm';
			}
		}
	}).mount('#app')
})
</script>
</body>
</html>