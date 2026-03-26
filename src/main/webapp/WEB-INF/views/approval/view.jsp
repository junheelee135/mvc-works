<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projectlist.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvalview.css?v=4" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvalcreate.css" type="text/css">
<meta name="ctx"   content="${pageContext.request.contextPath}">
<meta name="docId" content="${param.docId}">
<style>[v-cloak] { display: none; }</style>
<style>
.form-section input,
.form-section select,
.form-section textarea {
    pointer-events: none;
    background-color: #f9fafb;
    color: #344054;
}
.btn-expense-add, .btn-expense-remove,
.btn-companion-add, .companion-remove {
    display: none;
}
.ql-toolbar { display: none; }
.ql-editor { pointer-events: none; background-color: #f9fafb; color: #344054; }
</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
<div id="vue-app" v-cloak>

    <div v-if="store.loading" style="text-align:center; padding:60px; color:#9aa0b4;">
        <span class="material-symbols-outlined" style="font-size:32px;">hourglass_empty</span>
        <p>불러오는 중...</p>
    </div>

    <div v-else-if="store.error" style="text-align:center; padding:60px; color:#e53e3e;">
        <span class="material-symbols-outlined" style="font-size:32px;">error</span>
        <p>{{ store.error }}</p>
    </div>

    <template v-else-if="store.doc">

	    <div class="page-header">
	        <span class="material-symbols-outlined">forward_to_inbox</span>
	        <span class="page-header-label">전자결재</span>
	        <span class="page-header-divider">›</span>
	        <span class="page-header-doc">{{ store.doc.typeName }}</span>
	        <button class="btn-pdf"
	                v-if="store.doc.docStatus !== 'DRAFT'"
	                @click="openPdf">
	            <span class="material-symbols-outlined" style="font-size:15px">picture_as_pdf</span>
	            PDF 저장
	        </button>
	    </div>

        <div class="view-section">
            <div class="view-section-header">
                <span class="material-symbols-outlined">info</span>
                기본 정보
            </div>
            <div class="view-section-body">
                <div class="info-grid">
                    <div class="view-field">
                        <label>문서번호</label>
                        <div class="view-value">{{ store.doc.docId }}</div>
                    </div>
                    <div class="view-field">
                        <label>작성일</label>
                        <div class="view-value">{{ store.doc.regDate }}</div>
                    </div>
                    <div class="view-field">
                        <label>작성자</label>
                        <div class="view-value">{{ store.doc.writerDeptName }} | {{ store.doc.writerEmpName }} {{ store.doc.writerGradeName }}</div>
                    </div>
                    <div class="view-field">
                        <label>결재 유형</label>
                        <div class="view-value">{{ store.doc.typeName }}</div>
                    </div>
                    <div class="view-field">
                        <label>제목</label>
                        <div class="view-value">{{ store.doc.title }}</div>
                    </div>
                    <div class="view-field">
                        <label>결재 상태</label>
                        <div class="view-value">
                            <span class="status-badge" :class="store.statusBadgeClass(store.doc.docStatus, currentEmpId)">
                                {{ store.statusLabel(store.doc.docStatus, currentEmpId) }}
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="view-section">
            <div class="view-section-header">
                <span class="material-symbols-outlined">group</span>
                결재선 정보
            </div>
            <div class="view-section-body">
                <div v-if="store.doc.lines && store.doc.lines.length > 0" class="line-grid">
                    <div class="line-card" :class="'line-' + line.apprStatus" v-for="line in store.doc.lines" :key="line.lineId">
                        <div class="line-card-header">{{ line.stepOrder }}단계</div>
                        <div class="line-card-body">
                            <div class="line-card-name">{{ line.apprEmpName }}</div>
                            <div class="line-card-dept">{{ line.apprDeptName }} · {{ line.apprGradeName }}</div>
                            <span class="status-badge" :class="'status-' + line.apprStatus">
                                {{ store.lineStatusLabel(line.apprStatus) }}
                            </span>
                            <div v-if="line.isDeputy === 'Y'" class="deputy-badge">
                                대결: {{ line.deputyName }}
                            </div>
                            <div v-else-if="line.apprStatus === 'WAIT' && line.activeDeputyName" class="deputy-badge deputy-scheduled">
                                대결 예정: {{ line.activeDeputyName }}
                            </div>
                            <div v-if="line.apprComment"
                                 style="margin-top:8px; padding-top:8px; border-top:1px solid #eee; text-align:left;">
                                <div :style="line._expanded ? '' : 'display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;'"
                                     style="font-size:11px; color:#667085; cursor:pointer;"
                                     @click="line._expanded = !line._expanded">
                                    {{ line.apprComment }}
                                </div>
                                <div style="color:#9aa0b4; font-size:10px; margin-top:2px;">{{ line.apprDate }}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div v-else style="font-size:12px; color:#9aa0b4;">결재선 정보가 없습니다.</div>
            </div>
        </div>

        <div class="view-section" v-if="store.doc.refs && store.doc.refs.length > 0">
            <div class="view-section-header">
                <span class="material-symbols-outlined">visibility</span>
                참조자 정보
            </div>
            <div class="view-section-body">
                <div class="line-grid">
                    <div class="line-card" :class="ref.readYn === 'Y' ? 'ref-READ' : 'ref-UNREAD'" v-for="ref in store.doc.refs" :key="ref.refId">
                        <div class="line-card-header">참조</div>
                        <div class="line-card-body">
                            <div class="line-card-name">{{ ref.refEmpName }}</div>
                            <div class="line-card-dept">{{ ref.refDeptName }} · {{ ref.refGradeName }}</div>
                            <span class="status-badge" :class="ref.readYn === 'Y' ? 'status-READ' : 'status-UNREAD'">
                                {{ ref.readYn === 'Y' ? '읽음' : '안읽음' }}
                            </span>
                            <div v-if="ref.refComment"
                                 style="margin-top:8px; padding-top:8px; border-top:1px solid #eee; text-align:left;">
                                <div :style="ref._expanded ? '' : 'display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden;'"
                                     style="font-size:11px; color:#667085; cursor:pointer;"
                                     @click="ref._expanded = !ref._expanded">
                                    {{ ref.refComment }}
                                </div>
                                <div style="color:#9aa0b4; font-size:10px; margin-top:2px;">{{ ref.refCommentDate }}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div v-if="store.isReference(currentEmpId)" style="margin-top:12px; display:flex; gap:8px;">
                    <input type="text" class="form-control" v-model="refCommentText"
                           placeholder="참조 의견을 입력하세요"
                           style="pointer-events:auto; background:#fff;">
                    <button class="btn btn-sm btn-outline-primary" @click="submitRefComment"
                            style="white-space:nowrap;">등록</button>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/approval/include/approvalDetailLeave.jsp"/>
        <jsp:include page="/WEB-INF/views/approval/include/approvalDetailBiztrip.jsp"/>
        <jsp:include page="/WEB-INF/views/approval/include/approvalDetailExpense.jsp"/>
        <jsp:include page="/WEB-INF/views/approval/include/approvalDetailClaim.jsp"/>
        <jsp:include page="/WEB-INF/views/approval/include/approvalDetailGeneral.jsp"/>

        <div class="view-section">
            <div class="view-section-header">
                <span class="material-symbols-outlined">attach_file</span>
                첨부파일
            </div>
            <div class="view-section-body">
                <div v-if="store.doc.files && store.doc.files.length > 0" class="file-list">
                    <div class="file-item" v-for="file in store.doc.files" :key="file.fileId">
                        <span class="material-symbols-outlined">description</span>
                        <span class="file-item-name">{{ file.oriFilename }}</span>
                        <span class="file-item-size">{{ store.formatSize(file.fileSize) }}</span>
                        <button class="file-item-btn"
                                @click="download(file.fileId)">
                            다운로드
                        </button>
                    </div>
                </div>
                <div v-else class="no-file">첨부된 파일이 없습니다.</div>
            </div>
        </div>

        <div class="view-footer">
            <span v-if="store.isDeputy && store.isCurrentApprover(currentEmpId)" class="deputy-notice">
                <span class="material-symbols-outlined" style="font-size:14px">swap_horiz</span>
                대결 처리 중 (원결재자: {{ store.originalApproverName }})
            </span>
            <template v-if="store.isCurrentApprover(currentEmpId)">
                <button class="btn-approve" @click="openApproveModal('approve')">
                    <span class="material-symbols-outlined" style="font-size:15px">check_circle</span>
                    승인
                </button>
                <button class="btn-reject" @click="openApproveModal('reject')">
                    <span class="material-symbols-outlined" style="font-size:15px">cancel</span>
                    반려
                </button>
                <button v-if="store.doc.docStatus !== 'ON_HOLD'" class="btn-hold" @click="openApproveModal('hold')">
                    <span class="material-symbols-outlined" style="font-size:15px">pause_circle</span>
                    보류
                </button>
            </template>

            <button class="btn-cancel"
                    v-if="store.doc.writerEmpId === currentEmpId && store.canCancel"
                    @click="cancelDoc">
                <span class="material-symbols-outlined" style="font-size:15px">cancel</span>
                결재취소
            </button>
            <button class="btn-resubmit"
                    v-if="store.canResubmit(currentEmpId)"
                    @click="resubmit">
                <span class="material-symbols-outlined" style="font-size:15px">replay</span>
                재상신
            </button>
            <button class="btn-back" @click="goList">
                <span class="material-symbols-outlined" style="font-size:15px">arrow_back</span>
                목록
            </button>
        </div>
        <div class="modal fade" id="approveModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">{{ modalTitle }}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <label class="form-label">의견 <span v-if="modalType === 'reject'" style="color:red">*필수</span></label>
                        <textarea class="form-control" v-model="apprComment" rows="4"
                                  style="pointer-events:auto; background:#fff;"
                                  :placeholder="modalType === 'reject' ? '반려 사유를 입력해주세요 (필수)' : '의견을 입력해주세요 (선택)'">
                        </textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                        <button type="button" class="btn" :class="modalBtnClass" @click="processApproval">확인</button>
                    </div>
                </div>
            </div>
        </div>
    </template>

</div>
</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
    "imports": {
        "http":              "/dist/util/http.js",
        "approvalViewStore": "/dist/util/store/approvalViewStore.js?v=8",
        "commonCodeStore":   "/dist/util/store/commonCodeStore.js"
    }
}
</script>

<script type="module">
    import { createApp, onMounted, ref } from 'vue';
    import { createPinia } from 'pinia';
    import { useApprovalViewStore } from 'approvalViewStore';
    import { useCommonCodeStore }   from 'commonCodeStore';
    import http from 'http';

    const pinia = createPinia();

    const app = createApp({
        setup() {
            const store     = useApprovalViewStore();
            const codeStore = useCommonCodeStore();   // ← Leave.jsp 에서 사용
            const ctx   = document.querySelector('meta[name="ctx"]').content;
            const docId = document.querySelector('meta[name="docId"]').content;

            const currentEmpId = '${sessionScope.member.empId}';

            const apprComment = ref('');
            const modalType = ref('');
            const modalTitle = ref('');
            const modalBtnClass = ref('');
            const refCommentText = ref('');

            const openApproveModal = (type) => {
                modalType.value = type;
                if (type === 'approve') { modalTitle.value = '승인'; modalBtnClass.value = 'btn-success'; }
                else if (type === 'reject') { modalTitle.value = '반려'; modalBtnClass.value = 'btn-danger'; }
                else { modalTitle.value = '보류'; modalBtnClass.value = 'btn-warning'; }
                apprComment.value = '';
                new bootstrap.Modal(document.getElementById('approveModal')).show();
            };

            const processApproval = async () => {
                let ok = false;
                if (modalType.value === 'approve') {
                    if (!confirm('승인하시겠습니까?')) return;
                    ok = await store.approveDoc(docId, apprComment.value);
                } else if (modalType.value === 'reject') {
                    if (!apprComment.value.trim()) { alert('반려 사유를 입력해주세요.'); return; }
                    if (!confirm('반려하시겠습니까?')) return;
                    ok = await store.rejectDoc(docId, apprComment.value);
                } else {
                    if (!confirm('보류하시겠습니까?')) return;
                    ok = await store.holdDoc(docId, apprComment.value);
                }
                if (ok) {
                    bootstrap.Modal.getInstance(document.getElementById('approveModal')).hide();
                    await store.fetchDoc(docId);
                }
            };

            const submitRefComment = async () => {
                if (!refCommentText.value.trim()) { alert('의견을 입력해주세요.'); return; }
                const ok = await store.saveRefComment(docId, refCommentText.value);
                if (ok) {
                    refCommentText.value = '';
                    await store.fetchDoc(docId);
                }
            };

            const goList = () => { location.href = ctx + '/approval/list'; };

            const openPdf = () => {
                window.open(ctx + '/approval/pdf?docId=' + docId, '_blank',
                    'width=900,height=800,scrollbars=yes');
            };

            const resubmit = () => {
                location.href = ctx + '/approval/create?docId=' + docId;
            };

            const cancelDoc = async () => {
                if (!confirm('결재를 취소하시겠습니까?')) return;
                const ok = await store.cancelDoc(docId);
                if (ok) location.href = ctx + '/approval/list';
            };

            const download = async (fileId) => {
                try {
                    const res = await fetch(ctx + '/api/approval/doc/file/' + fileId);
                    if (!res.ok) {
                        alert('파일을 찾을 수 없습니다.');
                        return;
                    }
                    const blob = await res.blob();
                    const disposition = res.headers.get('Content-Disposition') || '';
                    let filename = '첨부파일';
                    const match = disposition.match(/filename="([^"]+)"/);
                    if (match) filename = decodeURIComponent(escape(match[1]));

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

            onMounted(async () => {
                  await codeStore.fetchCodes('DOCSTATUS');
                  await codeStore.fetchCodes('LINESTATUS');
                  if (docId) {
   					  await store.fetchDoc(docId);
      				  // formCode에 따라 필요한 공통코드 로드
      				  if (store.selectedFormCode === 'FM001') {
                          await codeStore.fetchCodes('LEAVETYPE');
                      }
                      // 참조자인 경우 읽음 처리
                      if (store.isReference(currentEmpId)) {
                          try { await http.post('/approval/doc/' + docId + '/mark-read'); } catch(e) {}
                      }
            }

                if (typeof Quill !== 'undefined') {
                    const tryInit = setInterval(() => {
                        const el = document.getElementById('general-editor');
                        if (el && !el.__quill) {
                            el.__quill = new Quill(el, {
                                theme: 'snow',
                                placeholder: '상세 내용을 입력해주세요.',
                                modules: {
                                    toolbar: [
                                        [{ 'header': [1, 2, 3, false] }],
                                        ['bold', 'italic', 'underline', 'strike'],
                                        [{ 'color': [] }, { 'background': [] }],
                                        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                                        [{ 'align': [] }],
                                        ['link', 'image'],
                                        ['clean']
                                    ]
                                }
                            });
                            // 저장된 내용 복원
                            if (store.detailData?.description) {
                                el.__quill.root.innerHTML = store.detailData.description;
                            }
                            clearInterval(tryInit);
                        }
                    }, 300);
                }
            });

            return { store, codeStore, goList, download, cancelDoc, resubmit, openPdf, currentEmpId,
                     apprComment, modalType, modalTitle, modalBtnClass, refCommentText,
                     openApproveModal, processApproval, submitRefComment };

        }
    });

    app.use(pinia);
    app.mount('#vue-app');
</script>

</body>
</html>
