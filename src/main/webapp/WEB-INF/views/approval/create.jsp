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
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projectlist.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvalcreate.css" type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
<meta name="docId" content="${param.docId}">
<link href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
<style>[v-cloak] { display: none; }</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">

    <div id="vue-app" v-cloak>

        <div class="page-header">
            <span class="material-symbols-outlined">forward_to_inbox</span>
            <span class="page-header-label">전자결재</span>
            <span class="page-header-divider">›</span>
            <span class="page-header-doc">{{ store.selectedDocTypeName }}</span>
        </div>

        <div class="modal-overlay" v-if="!store.formVisible">
            <div class="modal-box">
                <div class="modal-header">
                    <div class="modal-breadcrumb">전자 결재 &gt; <span>등록</span></div>
                    <div class="modal-header-btns">
                        <button title="전체화면">
                            <span class="material-symbols-outlined" style="font-size:18px">open_in_full</span>
                        </button>
                        <button title="닫기" @click="goList">
                            <span class="material-symbols-outlined" style="font-size:18px">close</span>
                        </button>
                    </div>
                </div>
                <div class="modal-body">
                    <div class="modal-section-title">
                        <span class="material-symbols-outlined">description</span>
                        결재양식 선택
                    </div>
                    <div class="form-type-list">
                        <div v-if="store.docTypeList.length === 0"
                             style="text-align:center; color:#9aa0b4; padding:40px;">
                            등록된 문서유형이 없습니다.
                        </div>
                        <div v-for="item in store.docTypeList" :key="item.docTypeId"
                             class="form-type-item"
                             @click="store.selectDocType(item.docTypeId, item.typeName)">
                            <span class="material-symbols-outlined">description</span>
                            <div class="form-type-item-content">
                                <div class="form-type-item-title">{{ item.typeName }}</div>
                                <div class="form-type-item-desc">{{ item.description ? '• ' + item.description : '' }}</div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn-close-modal" @click="goList">닫기</button>
                </div>
            </div>
        </div>

        <org-search-modal
            v-model:visible="approverModalVisible"
            title="결재자 검색"
            :added-emp-ids="approverEmpIds"
            @add="store.addApprover($event)">
        </org-search-modal>

        <org-search-modal
            v-model:visible="referenceModalVisible"
            title="참조자 검색"
            :added-emp-ids="referenceEmpIds"
            @add="store.addReference($event)">
        </org-search-modal>

        <org-search-modal
            v-model:visible="companionModalVisible"
            title="동행자 검색"
            :added-emp-ids="companionEmpIds"
            @add="store.addCompanion($event)">
        </org-search-modal>

        <div class="approval-form-wrap" :class="{ active: store.formVisible }">

            <div class="form-doc-title">{{ store.selectedDocTypeName }}</div>

            <div class="form-section">
      			<div class="form-section-body">
          			<div class="form-field">
              			<label>제목</label>
              			<input type="text" placeholder="제목을 입력하세요." v-model="store.title">
          			</div>
      			</div>
  			</div>

            <jsp:include page="/WEB-INF/views/approval/include/approvalBasicInfo.jsp"/>

            <jsp:include page="/WEB-INF/views/approval/include/approvalLine.jsp"/>

            <jsp:include page="/WEB-INF/views/approval/include/approvalRef.jsp"/>

            <jsp:include page="/WEB-INF/views/approval/include/approvalDetailLeave.jsp"/>
            <jsp:include page="/WEB-INF/views/approval/include/approvalDetailBiztrip.jsp"/>
            <jsp:include page="/WEB-INF/views/approval/include/approvalDetailExpense.jsp"/>
            <jsp:include page="/WEB-INF/views/approval/include/approvalDetailClaim.jsp"/>
            <jsp:include page="/WEB-INF/views/approval/include/approvalDetailGeneral.jsp"/>

            <jsp:include page="/WEB-INF/views/approval/include/approvalAttach.jsp"/>

            <div class="form-section" v-if="store.selectedNotice">
                <div class="form-section-header">
                    <div class="form-section-title">
                        <span class="material-symbols-outlined">info</span>
                        참고사항
                    </div>
                </div>
                <div class="form-section-body" v-html="store.selectedNotice"></div>
            </div>

            <div class="form-footer">
                <button class="btn-delete-draft"
                        v-if="store.editMode && store.editDocStatus === 'DRAFT'"
                        @click="deleteDraft">
                    <span class="material-symbols-outlined" style="font-size:16px">delete</span>
                    삭제
                </button>
                <button class="btn-save-temp" @click="store.saveDraft()">
                    <span class="material-symbols-outlined" style="font-size:16px">save</span>
                    임시저장
                </button>
                <button class="btn-submit" @click="store.submitDoc()">
                    <span class="material-symbols-outlined" style="font-size:16px">send</span>
                    결재전송
                </button>
                <button class="btn-cancel" @click="goList">
                    <span class="material-symbols-outlined" style="font-size:16px">close</span>
                    목록
                </button>
            </div>

        </div>

    </div>

</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
	"imports": {
		"http": "/dist/util/http.js",
		"approvalCreateStore": "/dist/util/store/approvalCreateStore.js?v=9",
		"OrgSearchModal": "/dist/util/component/OrgSearchModal.js?v=2",
        "commonCodeStore": "/dist/util/store/commonCodeStore.js"
	}
}
</script>

<script type="module">
    import { createApp, ref, reactive, computed, onMounted } from 'vue';
    import { createPinia } from 'pinia';
    import { useApprovalCreateStore } from 'approvalCreateStore';
    import { OrgSearchModal } from 'OrgSearchModal';
    import { useCommonCodeStore } from 'commonCodeStore';

    const app = createApp({
        setup() {
            const store = useApprovalCreateStore();
            const ctx = document.querySelector('meta[name="ctx"]').content;
            const codeStore = useCommonCodeStore();

            const docId = document.querySelector('meta[name="docId"]').content;
            if (docId) {
                store.formVisible = true;
            }

            const todayDate = new Date().toLocaleDateString('ko-KR', {
                year: 'numeric', month: '2-digit', day: '2-digit', weekday: 'short'
            });

            // 모달 상태 (각각 독립)
            const approverModalVisible = ref(false);
            const referenceModalVisible = ref(false);
            const approverEmpIds = computed(() => store.approvers.map(a => a.empId));
            const referenceEmpIds = computed(() => store.references.map(r => r.empId));
            const companionModalVisible = ref(false);
            const companionEmpIds = computed(() => (store.detailData.companions || []).map(c => c.empId));

            // 템플릿 불러오기 모달
            const templateLoadModalVisible = ref(false);
            const templateList = ref([])

            // 임시저장 삭제
            const deleteDraft = async () => {
                if (!confirm('임시저장 문서를 삭제하시겠습니까?')) return;
                await store.deleteDraft();
            };

            // 네비게이션
            const goList = () => { location.href = ctx + '/approval/list'; };

            // 템플릿 저장
            const saveTemplate = async () => {
                const name = prompt('템플릿 이름을 입력하세요.');
                if (!name || !name.trim()) return;
                await store.saveTemplate(name.trim());
            };

            // 템플릿 목록 열기
            const openTemplateLoad = async () => {
            	templateList.value = await store.fetchTemplates();
      			templateLoadModalVisible.value = true;
  			};

            // 템플릿 선택 → 결재선 적용
            const onLoadTemplate = async (tempId) => {
                const ok = await store.loadTemplate(tempId);
                if (ok) templateLoadModalVisible.value = false;
            };

            // 템플릿 삭제
            const onDeleteTemplate = async (tempId) => {
                if (!confirm('이 템플릿을 삭제하시겠습니까?')) return;
                const ok = await store.deleteTemplate(tempId);
                if (ok) templateList.value = await store.fetchTemplates();
            };

            // 드래그 앤 드롭
            const drag = reactive({ fromIdx: null, overIdx: null });

            const onDragStart = (idx, e) => {
                drag.fromIdx = idx;
                e.dataTransfer.effectAllowed = 'move';
            };
            const onDragOver = (idx) => { drag.overIdx = idx; };
            const onDrop = (toIdx) => {
                if (drag.fromIdx !== null) {
                    store.reorderApprover(drag.fromIdx, toIdx);
                }
                drag.fromIdx = null;
                drag.overIdx = null;
            };
            const onDragEnd = () => {
                drag.fromIdx = null;
                drag.overIdx = null;
            };

            onMounted(async () => {
                await store.fetchDocTypes();
                codeStore.fetchCodes('LEAVETYPE');
                if (docId) {
                    await store.loadDraft(docId);
                }
            });

            return {
      				store, codeStore, todayDate,
    				approverModalVisible, referenceModalVisible,
      				approverEmpIds, referenceEmpIds,
                    companionModalVisible, companionEmpIds,
                    deleteDraft, goList, saveTemplate,
                    templateLoadModalVisible, templateList,
                    openTemplateLoad, onLoadTemplate, onDeleteTemplate,
      				drag, onDragStart, onDragOver, onDrop, onDragEnd
  				};
        }
    });

    app.component('org-search-modal', OrgSearchModal);
    app.use(createPinia());
    app.mount('#vue-app');
</script>
<script>
(function() {
    let quill = null;
    const observer = new MutationObserver(function() {
        const el = document.getElementById('general-editor');
        if (el && !quill) {
            quill = new Quill(el, {
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
        }
    });
    const app = document.getElementById('vue-app');
    if (app) observer.observe(app, { childList: true, subtree: true });
})();
</script>
</body>
</html>
