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
<link href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css" rel="stylesheet">
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

        <div class="notice-panel">
            <table class="notice-table">
                <thead>
                    <tr>
                        <th style="width:70px; text-align:center;">번호</th>
                        <th>제목</th>
                        <th style="width:70px; text-align:center;">작성자</th>
                        <th style="width:70px; text-align:center;">작성일</th>
                        <th style="width:80px; text-align:center;">조회수</th>
                        <th style="width:50px; text-align:center;">파일</th>
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
                        <td class="td-date" style="text-align:center;">{{ item.noticenum }}</td>
                        <td class="td-subject">
                            <span class="badge-notice" v-if="item.isnotice === 1">공지</span>
                            {{ item.subject }}
                        </td>
                        <td class="td-author">{{ item.authorName }}</td>
                        <td class="td-date">{{ item.regdate }}</td>
                        <td class="td-hit" style="text-align:center;">{{ item.hitcount }}</td>
                        <td class="td-file" @click.stop>
                            <a v-if="item.fileCount > 0"
                               href="javascript:void(0)"
                               @click.stop="downloadFile(item.firstFilenum)">
                                <span class="material-symbols-outlined" style="color:#9aa0b4;">attach_file</span>
                            </a>
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
            <div class="detail-body" v-html="detail.content"></div>

            <!-- 첨부파일 -->
            <div class="detail-files" v-if="detail.files && detail.files.length > 0">
                <div class="detail-files-title">첨부파일</div>
                <a v-for="file in detail.files" :key="file.filenum"
                   href="javascript:void(0)"
                   class="file-item" @click="downloadFile(file.filenum)">
                    <span class="material-symbols-outlined">attach_file</span>
                    {{ file.originalfilename }}
                </a>
            </div>

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

                <div class="form-field">
                    <label class="form-label">제목 <span class="required">*</span></label>
                    <input type="text" class="form-input" v-model="form.subject" placeholder="제목을 입력하세요">
                </div>

                <div class="form-field">
                    <label class="form-label">내용 <span class="required">*</span></label>
                    <div id="quill-editor" style="height:300px; background:#fff;"></div>
                </div>

                <div class="form-check-row">
                    <input type="checkbox" id="isnotice" :checked="form.isnotice === 1"
                           @change="form.isnotice = $event.target.checked ? 1 : 0">
                    <label for="isnotice">상단 공지로 고정</label>
                </div>

                <!-- 파일 첨부 -->
                <div class="form-field">
                    <label class="form-label">첨부파일</label>
                    <!-- 기존 파일 목록 (수정 시) -->
                    <div class="file-preview-list" v-if="form.existingFiles && form.existingFiles.length > 0">
                        <div class="file-preview-item" v-for="file in form.existingFiles" :key="file.filenum">
                            <span><span class="material-symbols-outlined" style="font-size:14px;vertical-align:middle;">attach_file</span> {{ file.originalfilename }}</span>
                            <button class="btn-remove-file" @click="removeExistingFile(file.filenum)" type="button">
                                <span class="material-symbols-outlined">close</span>
                            </button>
                        </div>
                    </div>
                    <!-- 새 파일 선택 -->
                    <div class="file-upload-area" @click="$refs.fileInput.click()">
                        <span class="material-symbols-outlined">upload_file</span>
                        <p>클릭하여 파일을 선택하세요</p>
                        <input type="file" ref="fileInput" multiple @change="onFileChange" style="display:none;">
                    </div>
                    <!-- 새로 선택한 파일 미리보기 -->
                    <div class="file-preview-list" v-if="form.newFiles && form.newFiles.length > 0">
                        <div class="file-preview-item" v-for="(f, idx) in form.newFiles" :key="idx">
                            <span><span class="material-symbols-outlined" style="font-size:14px;vertical-align:middle;">attach_file</span> {{ f.name }}</span>
                            <button class="btn-remove-file" @click="form.newFiles.splice(idx, 1)" type="button">
                                <span class="material-symbols-outlined">close</span>
                            </button>
                        </div>
                    </div>
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
import { createApp, ref, computed, onMounted, watch } from 'vue';

const ctx = document.querySelector('meta[name="ctx"]').content;

let quill = null; // Quill 에디터 인스턴스

const app = createApp({
    setup() {
        // ── 권한 정보: userLevel=99 이면 ADMIN (등록/수정/삭제 가능) ──
        const isAdmin = ref('${sessionScope.member.userLevel}' === '99');
        const myEmpId = ref('${sessionScope.member.empId}');

        // ── 상태 ──
        const view = ref('list');
        const noticeList = ref([]);
        const total = ref(0);
        const pageNo = ref(1);
        const pageSize = ref(10);
        const keyword = ref('');
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

        // ── 목록 조회 (전사 공지) ──
        const fetchList = async () => {
            const url = `\${ctx}/api/notice/list?pageNo=\${pageNo.value}&pageSize=\${pageSize.value}&keyword=\${encodeURIComponent(keyword.value)}`;
            const res = await fetch(url);
            const data = await res.json();
            noticeList.value = data.list || [];
            total.value = data.total || 0;
        };

        const searchNotice = () => { pageNo.value = 1; fetchList(); };
        const changePage = (p) => { if (p < 1 || p > totalPages.value) return; pageNo.value = p; fetchList(); };

        const openDetail = async (noticenum) => {
            const res = await fetch(`\${ctx}/api/notice/\${noticenum}`);
            detail.value = await res.json();
            // 목록의 조회수도 실시간 반영
            const item = noticeList.value.find(n => n.noticenum === noticenum);
            if (item) item.hitcount = detail.value.hitcount;
            view.value = 'detail';
        };

        const openForm = (item) => {
            if (item) {
                form.value = {
                    noticenum: item.noticenum,
                    subject: item.subject,
                    content: item.content,
                    isnotice: item.isnotice,
                    existingFiles: item.files ? [...item.files] : [],
                    deleteFileNums: [],
                    newFiles: []
                };
            } else {
                form.value = { 
                    noticenum: null, subject: '', content: '', isnotice: 0,
                    existingFiles: [], deleteFileNums: [], newFiles: []
                };
            }
            view.value = 'form';
        };

        const cancelForm = () => { view.value = form.value.noticenum ? 'detail' : 'list'; };

        const onFileChange = (e) => {
            const files = Array.from(e.target.files);
            form.value.newFiles = [...(form.value.newFiles || []), ...files];
            e.target.value = ''; // 같은 파일 재선택 가능하도록 초기화
        };

        const removeExistingFile = (filenum) => {
            form.value.deleteFileNums.push(filenum);
            form.value.existingFiles = form.value.existingFiles.filter(f => f.filenum !== filenum);
        };

        const downloadFile = async (filenum) => {
            try {
                const res = await fetch(`\${ctx}/api/notice/file/\${filenum}`);
                if (!res.ok) {
                    alert('파일을 찾을 수 없습니다.');
                    return;
                }
                // 정상 응답 → Blob으로 변환 후 다운로드
                const blob = await res.blob();
                const disposition = res.headers.get('Content-Disposition') || '';
                let filename = '첨부파일';
                const match = disposition.match(/filename\*?=(?:UTF-8'')?([^;]+)/i);
                if (match) filename = decodeURIComponent(match[1]);

                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = filename;
                document.body.appendChild(a);
                a.click();
                a.remove();
                URL.revokeObjectURL(url);
            } catch (e) {
                alert('파일 다운로드 중 오류가 발생했습니다.');
            }
        };

        const deleteNotice = async (noticenum) => {
            if (!confirm('공지사항을 삭제하시겠습니까?')) return;
            const res = await fetch(`\${ctx}/api/notice/\${noticenum}`, { method: 'DELETE' });
            if (res.ok) {
                alert('삭제되었습니다.');
                view.value = 'list';
                fetchList();
            } else {
                alert('삭제 중 오류가 발생했습니다.');
            }
        };

        const submitForm = async () => {
            if (!form.value.subject.trim()) { alert('제목을 입력해주세요.'); return; }

            // Quill 에디터 내용 반영
            if (quill) {
                form.value.content = quill.root.innerHTML;
            }

            const fd = new FormData();
            fd.append('data', new Blob([JSON.stringify({
                noticenum: form.value.noticenum,
                subject: form.value.subject,
                content: form.value.content,
                isnotice: form.value.isnotice
            })], { type: 'application/json' }));

            // 새 첨부파일
            if (form.value.newFiles && form.value.newFiles.length > 0) {
                form.value.newFiles.forEach(f => fd.append('files', f));
            }

            // 삭제할 기존 파일 번호 (수정 시)
            if (form.value.deleteFileNums && form.value.deleteFileNums.length > 0) {
                fd.append('deleteFileNums', new Blob([JSON.stringify(form.value.deleteFileNums)], { type: 'application/json' }));
            }

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
            // URL 파라미터 ?num=123 → 해당 공지 상세 자동 열기
            const params = new URLSearchParams(window.location.search);
            const num = params.get('num');
            if (num) {
                openDetail(Number(num));
            }
        });

        // 폼 뷰 전환 시 Quill 초기화
        watch(view, (newView) => {
            if (newView === 'form') {
                setTimeout(() => {
                    const container = document.getElementById('quill-editor');
                    if (!container) return;
                    quill = new Quill('#quill-editor', {
                        theme: 'snow',
                        placeholder: '내용을 입력하세요...',
                        modules: {
                            toolbar: [
                                [{ 'header': [1, 2, 3, false] }],
                                ['bold', 'italic', 'underline'],
                                [{ 'color': [] }, { 'background': [] }],
                                [{ 'list': 'ordered' }, { 'list': 'bullet' }],
                                ['link'],
                                ['clean']
                            ]
                        }
                    });
                    // 수정 시 기존 내용 로드
                    if (form.value.content) {
                        quill.clipboard.dangerouslyPasteHTML(form.value.content);
                    }
                }, 100);
            } else {
                quill = null;
            }
        });

        return {
            ctx, isAdmin, myEmpId, view, noticeList, total, pageNo, pageSize, keyword,
            totalPages, pageRange, detail, form,
            fetchList, searchNotice, changePage, openDetail, openForm, cancelForm,
            submitForm, deleteNotice, downloadFile, onFileChange, removeExistingFile
        };
    }
});

app.mount('#vue-app');
</script>

<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
</body>
</html>