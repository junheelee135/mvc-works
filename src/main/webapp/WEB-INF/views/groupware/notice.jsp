<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC - 공지사항</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/noticelist.css" type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
<div id="vue-app" v-cloak>

    <template v-if="view === 'list'">

        <div class="notice-topbar">
            <div class="notice-topbar-left">
                <span style="font-size:18px; font-weight:700; color:#1d2939;">공지사항</span>
            </div>
            <div class="notice-topbar-right">
                <div class="notice-search-bar">
                    <input type="text" v-model="keyword" placeholder="제목, 내용 검색..."
                           @keyup.enter="searchNotice">
                    <button class="btn-search" @click="searchNotice">
                        <span class="material-symbols-outlined">search</span>
                    </button>
                </div>
                <button class="btn-new-notice" v-if="isAdmin" @click="openForm(null)">
                    <span class="material-symbols-outlined">add</span>
                    공지 등록
                </button>
            </div>
        </div>

        <div class="notice-tabs" v-if="isAdmin && myProjects.length > 0">
            <button class="tab-btn" :class="{active: selectedProjectId === ''}" @click="filterByProject('')">전체</button>
            <button v-for="p in myProjects" :key="p.projectId" 
                    class="tab-btn" :class="{active: selectedProjectId === p.projectId}"
                    @click="filterByProject(p.projectId)">
                {{ p.projectName }}
            </button>
        </div>

        <div class="notice-panel">
            <table class="notice-table">
                <thead>
                    <tr>
                        <th style="width:60px;">번호</th>
                        <th>제목</th>
                        <th style="width:100px;">작성자</th>
                        <th style="width:110px;">작성일</th>
                        <th style="width:70px;">조회</th>
                        <th style="width:50px;">파일</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-if="noticeList.length === 0">
                        <td colspan="6" style="text-align:center; padding:50px; color:#9aa0b4;">
                            등록된 공지사항이 없습니다.
                        </td>
                    </tr>
                    <tr v-for="item in noticeList" :key="item.noticenum"
                        @click="openDetail(item.noticenum)">
                        <td class="td-date">{{ item.noticenum }}</td>
                        <td class="td-subject">
                            <span class="badge-notice" v-if="item.isnotice === 1">공지</span>
                            {{ item.subject }}
                        </td>
                        <td class="td-author">{{ item.authorName }}</td>
                        <td class="td-date">{{ item.regdate }}</td>
                        <td class="td-hit">{{ item.hitcount }}</td>
                        <td class="td-file">
                            <span class="material-symbols-outlined"
                                  v-if="item.files && item.files.length > 0">attach_file</span>
                        </td>
                    </tr>
                </tbody>
            </table>

            <div class="table-pagination">
                <button class="page-btn" :disabled="pageNo <= 1" @click="changePage(1)">&laquo;</button>
                <button class="page-btn" :disabled="pageNo <= 1" @click="changePage(pageNo - 1)">&lsaquo;</button>
                <button class="page-btn" v-for="p in pageRange" :key="p"
                        :class="{ active: p === pageNo }" @click="changePage(p)">{{ p }}</button>
                <button class="page-btn" :disabled="pageNo >= totalPages" @click="changePage(pageNo + 1)">&rsaquo;</button>
                <button class="page-btn" :disabled="pageNo >= totalPages" @click="changePage(totalPages)">&raquo;</button>
            </div>
        </div>

    </template>

    <template v-else-if="view === 'detail' && detail">
        <div class="notice-topbar">
            <button class="btn-back" @click="view = 'list'">
                <span class="material-symbols-outlined" style="font-size:16px;">arrow_back</span>
                목록으로
            </button>
        </div>
        <div class="notice-panel">
            <div class="detail-header">
                <div class="detail-title">
                    <span class="badge-notice" v-if="detail.isnotice === 1">공지</span>
                    {{ detail.subject }}
                </div>
                <div class="detail-meta">
                    <span><b>작성자</b> {{ detail.authorName }}</span>
                    <span><b>작성일</b> {{ detail.regdate }}</span>
                    <span><b>조회</b> {{ detail.hitcount }}</span>
                </div>
            </div>
            <div class="detail-body" style="white-space: pre-wrap;">{{ detail.content }}</div>
            
            <div class="detail-footer">
                <button class="btn-back" @click="view = 'list'">목록</button>
                <div class="detail-footer-btns" v-if="isAdmin">
                    <button class="btn-edit" @click="openForm(detail)">수정</button>
                    <button class="btn-delete" @click="deleteNotice(detail.noticenum)">삭제</button>
                </div>
            </div>
        </div>
    </template>

    <template v-else-if="view === 'form'">
        <div class="notice-topbar">
            <button class="btn-back" @click="cancelForm">
                <span class="material-symbols-outlined" style="font-size:16px;">arrow_back</span>
                취소
            </button>
        </div>

        <div class="notice-panel">
            <div class="form-panel-header">
                <span class="material-symbols-outlined">edit_note</span>
                {{ form.noticenum ? '공지사항 수정' : '공지사항 등록' }}
            </div>
            <div class="form-panel-body">

                <div class="form-field" v-if="isAdmin">
                    <label class="form-label">대상 프로젝트 <span class="required">*</span></label>
                    <select class="form-input" v-model="form.projectId">
                        <option value="">프로젝트 선택</option>
                        <c:forEach var="p" items="${sessionScope.loginInfo.projectList}">
                            <option value="${p.projectId}">${p.projectName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-field">
                    <label class="form-label">제목 <span class="required">*</span></label>
                    <input type="text" class="form-input" v-model="form.subject" placeholder="제목을 입력하세요">
                </div>

                <div class="form-field">
                    <label class="form-label">내용 <span class="required">*</span></label>
                    <textarea class="form-textarea" v-model="form.content" placeholder="내용을 입력하세요"></textarea>
                </div>

                <div class="form-check-row">
                    <input type="checkbox" id="isnotice" :checked="form.isnotice === 1"
                           @change="form.isnotice = $event.target.checked ? 1 : 0">
                    <label for="isnotice">상단 공지로 고정</label>
                </div>

                <div class="form-footer">
                    <button class="btn-cancel-form" @click="cancelForm">취소</button>
                    <button class="btn-submit" @click="submitForm">
                        {{ form.noticenum ? '수정' : '등록' }}
                    </button>
                </div>
            </div>
        </div>
    </template>

</div>
</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="module">
import { createApp, ref, computed, onMounted } from 'vue';

const ctx = document.querySelector('meta[name="ctx"]').content;

const app = createApp({
    setup() {
        // ── 권한 정보 (role 활용) ──
        //const isAdmin = ref('${sessionScope.loginInfo.role}' === 'm'); 
        const isAdmin = ref('true');
        const myEmpId = ref('${sessionScope.loginInfo.empId}');
        const myProjectId = ref('${sessionScope.loginInfo.projectId}');
        
        // 관리자가 관리하는 프로젝트 목록 (필요시 탭 렌더링용)
        const myProjects = ref([]);

        // ── 상태 ──
        const view = ref('list');
        const noticeList = ref([]);
        const total = ref(0);
        const pageNo = ref(1);
        const pageSize = ref(10);
        const keyword = ref('');
        const selectedProjectId = ref(''); // 필터용
        const detail = ref(null);

        const form = ref({
            noticenum: null,
            subject: '',
            content: '',
            isnotice: 0,
            projectId: '', // 추가
            existingFiles: [],
            deleteFileNums: []
        });

        const totalPages = computed(() => Math.max(1, Math.ceil(total.value / pageSize.value)));
        const pageRange = computed(() => {
            const start = Math.max(1, pageNo.value - 2);
            const end = Math.min(totalPages.value, start + 4);
            return Array.from({ length: end - start + 1 }, (_, i) => start + i);
        });

        // ── 목록 조회 (프로젝트 필터 포함) ──
        const fetchList = async () => {
            let url = `\${ctx}/api/notice/list?pageNo=\${pageNo.value}&pageSize=\${pageSize.value}&keyword=\${encodeURIComponent(keyword.value)}`;
            
            // 관리자가 탭을 선택했거나, 일반 사원인 경우 프로젝트 ID를 파라미터로 보냄
            if (selectedProjectId.value) {
                url += `&projectId=\${selectedProjectId.value}`;
            } else if (!isAdmin.value) {
                url += `&projectId=\${myProjectId.value}`;
            }

            const res = await fetch(url);
            const data = await res.json();
            noticeList.value = data.list || [];
            total.value = data.total || 0;
        };

        const filterByProject = (id) => {
            selectedProjectId.value = id;
            pageNo.value = 1;
            fetchList();
        };

        const searchNotice = () => { pageNo.value = 1; fetchList(); };
        const changePage = (p) => { if (p < 1 || p > totalPages.value) return; pageNo.value = p; fetchList(); };

        const openDetail = async (noticenum) => {
            const res = await fetch(`\${ctx}/api/notice/\${noticenum}`);
            detail.value = await res.json();
            view.value = 'detail';
        };

        const openForm = (item) => {
            if (item) {
                form.value = {
                    noticenum: item.noticenum,
                    subject: item.subject,
                    content: item.content,
                    isnotice: item.isnotice,
                    projectId: item.projectId || '',
                    existingFiles: item.files ? [...item.files] : [],
                    deleteFileNums: []
                };
            } else {
                form.value = { 
                    noticenum: null, subject: '', content: '', isnotice: 0, 
                    projectId: isAdmin.value ? '' : myProjectId.value, // 사원은 소속 프로젝트 고정
                    existingFiles: [], deleteFileNums: [] 
                };
            }
            view.value = 'form';
        };

        const cancelForm = () => { view.value = form.value.noticenum ? 'detail' : 'list'; };

        const submitForm = async () => {
            if (!form.value.subject.trim()) { alert('제목을 입력해주세요.'); return; }
            if (isAdmin.value && !form.value.projectId) { alert('대상 프로젝트를 선택해주세요.'); return; }

            const fd = new FormData();
            fd.append('data', new Blob([JSON.stringify({
                noticenum: form.value.noticenum,
                subject: form.value.subject,
                content: form.value.content,
                isnotice: form.value.isnotice,
                projectId: form.value.projectId
            })], { type: 'application/json' }));

            const isEdit = !!form.value.noticenum;
            const url = isEdit ? `\${ctx}/api/notice/\${form.value.noticenum}` : `\${ctx}/api/notice`;
            const method = isEdit ? 'PUT' : 'POST';

            const res = await fetch(url, { method, body: fd });
            if (res.ok) {
                alert(isEdit ? '수정되었습니다.' : '등록되었습니다.');
                view.value = 'list';
                fetchList();
            } else {
                alert('처리 중 오류가 발생했습니다.');
            }
        };

        onMounted(() => {
            fetchList();
        });

        return {
            ctx, isAdmin, myEmpId, view, noticeList, total, pageNo, pageSize, keyword,
            totalPages, pageRange, detail, form, selectedProjectId, myProjects,
            fetchList, searchNotice, changePage, openDetail, openForm, cancelForm,
            submitForm, filterByProject
        };
    }
});

app.mount('#vue-app');
</script>

</body>
</html>