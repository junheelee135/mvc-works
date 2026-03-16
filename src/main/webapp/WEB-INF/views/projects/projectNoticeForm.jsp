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
	href="${pageContext.request.contextPath}/dist/css/projectnoticelist.css">
<meta name="ctx" content="${pageContext.request.contextPath}">

<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
</head>
<body>
	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<div id="app" v-cloak>
		<div class="main-content">
			<div class="page-header">
				<h2>공지 등록</h2>
			</div>

			<div class="notice-form">
				<label>프로젝트 선택</label> <select v-model="selectedProjectId">
					<option value="">-- 프로젝트 선택 --</option>
					<option v-for="p in myProjects" :key="p.PROJECTID"
						:value="p.PROJECTID">{{ p.PROJECTNAME }}</option>
				</select> <label>제목</label> <input type="text" v-model="formData.subject">

				<label>내용</label>
				<textarea v-model="formData.content"></textarea>

				<label>첨부 파일</label> <input type="file" @change="handleFiles"
					multiple>
				<ul>
					<li v-for="f in formData.files">{{ f.name }}</li>
				</ul>

				<button @click="submitForm">저장</button>
				<button @click="goBack">취소</button>
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
                formData: { subject:'', content:'', files:[] }
            }
        },
        mounted() { this.fetchMyProjects() },
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
                try { this.myProjects = await res.json() } 
                catch(e) { console.error("로드 실패:", await res.text()) }
            },
            handleFiles(e){ this.formData.files=Array.from(e.target.files) },
            async submitForm(){
                if(!this.selectedProjectId){ alert("프로젝트를 선택해주세요"); return; }
                if(!this.formData.subject || !this.formData.content){ alert("제목과 내용을 입력해주세요"); return; }

                const form = new FormData()
                form.append("projectid", this.selectedProjectId)
                form.append("subject", this.formData.subject)
                form.append("content", this.formData.content)
                this.formData.files.forEach(f=>form.append("files", f))

                try{
                    const res = await fetch(ctx+'/api/projectnotice', { method:'POST', body:form, credentials:'include' })
                    if(res.ok){ alert("공지 등록 완료"); location.href=ctx+"/projectnotice/list"; }
                    else { const text=await res.text(); alert("등록 실패: "+text) }
                }catch(err){ console.error(err); alert("등록 중 오류 발생") }
            },
            goBack() { history.back() }
        }
    }).mount('#app')
})
</script>

</body>
</html>