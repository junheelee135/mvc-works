<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 공지사항</title>
    <jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
	<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projectnoticelist.css" type="text/css">
	<meta name="ctx" content="${pageContext.request.contextPath}">
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>
    
    <div class="main-content">

            <!-- ── 목록 뷰 ── -->
            <div v-if="view === 'list'">
                <div class="page-header">
                    <h2 class="page-title">프로젝트 공지사항</h2>
                </div>

                <!-- 프로젝트 셀렉트박스 -->
                <div class="project-select-wrap">
                    <select v-model="selectedProjectId" @change="onProjectChange" class="form-select project-select">
                        <option value="">-- 프로젝트 선택 --</option>
                        <option v-for="p in myProjects" :key="p.PROJECTID" :value="p.PROJECTID">
                            {{ p.PROJECTNAME }}
                        </option>
                    </select>
                </div>

                <!-- 프로젝트 미선택 -->
                <div v-if="!selectedProjectId" class="empty-msg">
                    소속 프로젝트를 선택해 주세요.
                </div>

                <template v-else>
                    <!-- 검색 + 등록 버튼 -->
                    <div class="toolbar">
                        <div class="search-wrap">
                            <input v-model="keyword" @keyup.enter="fetchList(1)"
                                   type="text" placeholder="제목 또는 내용 검색" class="search-input">
                            <button @click="fetchList(1)" class="btn btn-search">검색</button>
                        </div>
                        <button v-if="isManager" @click="openForm(null)" class="btn btn-primary">+ 공지 등록</button>
                    </div>

                    <!-- 목록 테이블 -->
                    <div class="table-wrap">
                        <table class="notice-table">
                            <thead>
                                <tr>
                                    <th style="width:60px">번호</th>
                                    <th>제목</th>
                                    <th style="width:100px">작성자</th>
                                    <th style="width:90px">날짜</th>
                                    <th style="width:60px">조회</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-if="list.length === 0">
                                    <td colspan="5" style="text-align:center;padding:30px;color:#999">
                                        등록된 공지사항이 없습니다.
                                    </td>
                                </tr>
                                <tr v-for="item in list" :key="item.noticenum"
                                    @click="openDetail(item.noticenum)"
                                    :class="{ 'pinned': item.isnotice === 1 }"
                                    style="cursor:pointer">
                                    <td style="text-align:center">
                                        <span v-if="item.isnotice === 1" class="badge-notice">공지</span>
                                        <span v-else>{{ item.noticenum }}</span>
                                    </td>
                                    <td>{{ item.subject }}</td>
                                    <td style="text-align:center">{{ item.authorName }}</td>
                                    <td style="text-align:center">{{ item.regdate }}</td>
                                    <td style="text-align:center">{{ item.hitcount }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- 페이징 -->
                    <div class="paging">
                        <button @click="fetchList(page - 1)" :disabled="page <= 1" class="btn-page">이전</button>
                        <span class="page-info">{{ page }} / {{ totalPages }}</span>
                        <button @click="fetchList(page + 1)" :disabled="page >= totalPages" class="btn-page">다음</button>
                    </div>
                </template>
            </div>

            <!-- ── 상세 뷰 ── -->
            <div v-if="view === 'detail'" class="detail-wrap">
                <div class="detail-header">
                    <span v-if="detail.isnotice === 1" class="badge-notice">공지</span>
                    <h3 class="detail-title">{{ detail.subject }}</h3>
                    <div class="detail-meta">
                        <span>{{ detail.authorName }}</span>
                        <span>{{ detail.regdate }}</span>
                        <span>조회 {{ detail.hitcount }}</span>
                    </div>
                </div>

                <div class="detail-content" v-html="detail.content"></div>

                <!-- 첨부파일 -->
                <div v-if="detail.files && detail.files.length > 0" class="file-list">
                    <strong>첨부파일</strong>
                    <ul>
                        <li v-for="f in detail.files" :key="f.filenum">
                            <a :href="'/api/projectnotice/download/' + f.filenum" target="_blank">
                                {{ f.originalfilename }}
                            </a>
                            <button v-if="isManager" @click="deleteFile(f.filenum)" class="btn-file-del">✕</button>
                        </li>
                    </ul>
                </div>

                <div class="detail-actions">
                    <button @click="view = 'list'" class="btn btn-secondary">목록</button>
                    <template v-if="isManager">
                        <button @click="openForm(detail)" class="btn btn-primary">수정</button>
                        <button @click="deleteNotice(detail.noticenum)" class="btn btn-danger">삭제</button>
                    </template>
                </div>
            </div>

            <!-- ── 등록/수정 폼 ── -->
            <div v-if="view === 'form'" class="form-wrap">
                <h3>{{ form.noticenum ? '공지 수정' : '공지 등록' }}</h3>

                <div class="form-group">
                    <label>제목 *</label>
                    <input v-model="form.subject" type="text" class="form-control" placeholder="제목을 입력하세요">
                </div>

                <div class="form-group">
                    <label>내용 *</label>
                    <textarea v-model="form.content" class="form-control" rows="12" placeholder="내용을 입력하세요"></textarea>
                </div>

                <div class="form-group form-check">
                    <input v-model="form.isnotice" type="checkbox" :true-value="1" :false-value="0" id="chkPin">
                    <label for="chkPin">상단 고정</label>
                </div>

                <div class="form-group">
                    <label>첨부파일</label>
                    <input type="file" multiple @change="onFileChange" class="form-control">
                </div>

                <div class="form-actions">
                    <button @click="cancelForm" class="btn btn-secondary">취소</button>
                    <button @click="submitForm" class="btn btn-primary">저장</button>
                </div>
            </div>

    </div><!-- /main-content -->


<script>
const { createApp } = Vue;
createApp({
    data() {
        return {
            view: 'list',          // list | detail | form
            myProjects: [],
            selectedProjectId: '',
            isManager: false,

            // 목록
            list: [],
            total: 0,
            page: 1,
            pageSize: 10,
            keyword: '',

            // 상세
            detail: {},

            // 폼
            form: { noticenum: 0, subject: '', content: '', isnotice: 0 },
            selectedFiles: [],
        };
    },
    computed: {
        totalPages() {
            return Math.max(1, Math.ceil(this.total / this.pageSize));
        }
    },
    mounted() {
        this.fetchMyProjects();
    },
    methods: {
        // ── 내 프로젝트 목록 ──
        async fetchMyProjects() {
            const res = await fetch('/api/projectnotice/myprojects');
            if (!res.ok) return;
            this.myProjects = await res.json();
            if (this.myProjects.length === 1) {
                this.selectedProjectId = this.myProjects[0].PROJECTID;
                this.fetchList(1);
            }
        },

        onProjectChange() {
            this.keyword = '';
            this.view = 'list';
            if (this.selectedProjectId) this.fetchList(1);
        },

        // ── 목록 ──
        async fetchList(p) {
            if (!this.selectedProjectId) return;
            this.page = p;
            const params = new URLSearchParams({
                projectid: this.selectedProjectId,
                page: this.page,
                keyword: this.keyword
            });
            const res = await fetch('/api/projectnotice/list?' + params);
            if (!res.ok) return;
            const data = await res.json();
            this.list      = data.list;
            this.total     = data.total;
            this.isManager = data.isManager;
            this.view = 'list';
        },

        // ── 상세 ──
        async openDetail(noticenum) {
            const res = await fetch('/api/projectnotice/' + noticenum);
            if (!res.ok) return;
            this.detail = await res.json();
            this.view = 'detail';
        },

        // ── 삭제 ──
        async deleteNotice(noticenum) {
            if (!confirm('삭제하시겠습니까?')) return;
            const res = await fetch('/api/projectnotice/' + noticenum + '?projectid=' + this.selectedProjectId, { method: 'DELETE' });
            if (res.ok) {
                alert('삭제되었습니다.');
                this.fetchList(1);
            } else {
                alert('삭제 실패');
            }
        },

        // ── 파일 삭제 ──
        async deleteFile(filenum) {
            if (!confirm('파일을 삭제하시겠습니까?')) return;
            const res = await fetch('/api/projectnotice/file/' + filenum + '?projectid=' + this.selectedProjectId, { method: 'DELETE' });
            if (res.ok) {
                this.detail.files = this.detail.files.filter(f => f.filenum !== filenum);
            } else {
                alert('파일 삭제 실패');
            }
        },

        // ── 폼 열기 ──
        openForm(item) {
            if (item) {
                this.form = { noticenum: item.noticenum, subject: item.subject, content: item.content, isnotice: item.isnotice };
            } else {
                this.form = { noticenum: 0, subject: '', content: '', isnotice: 0 };
            }
            this.selectedFiles = [];
            this.view = 'form';
        },

        cancelForm() {
            this.view = this.form.noticenum ? 'detail' : 'list';
        },

        onFileChange(e) {
            this.selectedFiles = Array.from(e.target.files);
        },

        // ── 저장 ──
        async submitForm() {
            if (!this.form.subject.trim()) { alert('제목을 입력하세요.'); return; }
            if (!this.form.content.trim()) { alert('내용을 입력하세요.'); return; }

            const fd = new FormData();
            fd.append('projectid', this.selectedProjectId);
            fd.append('subject',   this.form.subject);
            fd.append('content',   this.form.content);
            fd.append('isnotice',  this.form.isnotice);
            this.selectedFiles.forEach(f => fd.append('files', f));

            const isEdit = !!this.form.noticenum;
            const url    = isEdit ? '/api/projectnotice/' + this.form.noticenum : '/api/projectnotice';
            const method = isEdit ? 'PUT' : 'POST';

            const res = await fetch(url, { method, body: fd });
            if (res.ok) {
                alert(isEdit ? '수정되었습니다.' : '등록되었습니다.');
                this.fetchList(1);
            } else {
                alert('저장 실패');
            }
        }
    }
}).mount('#app');
</script>


