 <%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvallist.css?v=4" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvaldoctype.css" type="text/css">
<link href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css" rel="stylesheet">
<style>
[v-cloak] { display: none; }
.sortable-ghost { background: #eef2ff !important; }
.drag-handle:hover { color: #4e73df !important; }
</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">

    <div id="vue-app" v-cloak>

        <div class="doctype-header">
            <div>
                <h4>
                    <span class="material-symbols-outlined">description</span>
                    문서유형 관리
                </h4>
                <p>결재 문서유형을 관리합니다. 기안서 작성 시 기안자가 선택하는 유형입니다.</p>
            </div>
            <button class="btn-add-type" @click="store.openAddForm()" data-bs-toggle="modal" data-bs-target="#formModal">
                <span class="material-symbols-outlined">add</span>
                유형 추가
            </button>
        </div>

        <div class="stat-row">
            <div class="stat-item">
                <div class="stat-num total">{{ list.length }}</div>
                <div class="stat-label">전체 유형</div>
            </div>
            <div class="stat-item">
                <div class="stat-num active">{{ list.filter(i => i.useYn === 'Y').length }}</div>
                <div class="stat-label">사용중</div>
            </div>
            <div class="stat-item">
                <div class="stat-num inactive">{{ list.filter(i => i.useYn === 'N').length }}</div>
                <div class="stat-label">미사용</div>
            </div>
        </div>

        <div class="table-panel">
            <div class="doctype-table-header">문서유형 목록</div>
            <table class="doctype-table">
                <thead>
                    <tr>
                        <th style="width:50px; text-align:center;"></th>
                        <th style="width:120px;">유형코드</th>
                        <th style="width:160px;">유형명</th>
                        <th>설명</th>
                        <th style="width:100px; text-align:center;">사용여부</th>
                        <th style="width:120px; text-align:center;">등록일</th>
                        <th style="width:130px; text-align:center;">관리</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(item, idx) in list" :key="item.docTypeId"
                        :class="{ 'row-disabled': item.useYn === 'N' }">
                        <td style="text-align:center;">
                            <span class="drag-handle" style="cursor:grab; color:#bfc4ce; font-size:16px; user-select:none;">⠿</span>
                        </td>
                        <td><span class="type-code-badge">{{ item.typeCode }}</span></td>
                        <td style="font-weight:500;">{{ item.typeName }}</td>
                        <td style="color:#667085; font-size:12px;">{{ item.description || '-' }}</td>
                        <td style="text-align:center;">
                            <span class="use-badge" :class="item.useYn === 'Y' ? 'on' : 'off'"
                                  @click="store.toggleUseYn(item)">
                                {{ item.useYn === 'Y' ? '사용' : '미사용' }}
                            </span>
                        </td>
                        <td style="text-align:center; color:#9aa0b4; font-size:12px;">{{ item.regDate }}</td>
                        <td style="text-align:center;">
                            <button class="btn-edit" @click="store.openEditForm(item)" data-bs-toggle="modal" data-bs-target="#formModal">수정</button>
                            <button class="btn-del" @click="store.deleteDocType(item.docTypeId)">삭제</button>
                        </td>
                    </tr>
                    <tr v-if="list.length === 0">
                        <td colspan="7" style="text-align:center; color:#9aa0b4; padding:48px;">등록된 문서유형이 없습니다.</td>
                    </tr>
                </tbody>
            </table>
            <div class="table-footer">
                <span class="material-symbols-outlined">info</span>
                미사용 유형은 기안서 작성 시 선택 목록에서 숨겨집니다.
            </div>
        </div>

        <div class="modal fade" id="formModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="material-symbols-outlined">{{ store.formMode === 'ADD' ? 'add_circle' : 'edit' }}</span>
                            {{ store.formMode === 'ADD' ? '문서유형 추가' : '문서유형 수정' }}
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                      <div class="modal-body p-4">
                          <div class="mb-3" v-if="store.formMode === 'EDIT'">
                              <label>유형코드</label>
                              <input type="text" :value="store.form.typeCode" readonly
                                     style="background:#f8f9fc; color:#9aa0b4;">
                              <div style="font-size:11px; color:#9aa0b4; margin-top:6px;">유형코드는 자동 생성되며 변경할 수 없습니다.</div>
                          </div>
                          <div class="mb-3">
                              <label>유형명 <span style="color:#d93025;">*</span></label>
                              <input type="text" v-model="store.form.typeName" placeholder="예: 휴가신청서">
                          </div>
                          <div class="mb-3">
                              <label>양식코드</label>
                              <select v-model="store.form.formCode"
                                      style="width:100%; border:1px solid #d1d5db; border-radius:6px; padding:8px 12px; font-size:13px;">
                                  <option value="">선택</option>
                                  <option v-for="fc in store.formCodes" :key="fc.code" :value="fc.code">
                                      {{ fc.code }} - {{ fc.name }}
                                  </option>
                              </select>
                          </div>
                          <div class="mb-3">
                              <label>설명</label>
                              <textarea v-model="store.form.description" rows="2"
                                        placeholder="예: 연차, 병가 등 각종 휴가 사용 시 제출"
                                        style="width:100%; resize:vertical; border:1px solid #d1d5db; border-radius:6px; padding:8px 12px; font-size:13px;"></textarea>
                          </div>
                          <div class="mb-3" v-if="store.formMode === 'EDIT'">
                              <label>정렬순서</label>
                              <input type="number" :value="store.form.sortOrder" readonly
                                     style="background:#f8f9fc; color:#9aa0b4;">
                              <div style="font-size:11px; color:#9aa0b4; margin-top:6px;">정렬순서는 드래그앤드롭으로 변경할 수 있습니다.</div>
                          </div>
                          <div class="mb-3">
                              <label>참고사항</label>
                              <div id="quill-editor" style="height:180px;"></div>
                          </div>
                          <div class="mb-2">
                              <label>사용여부</label>
                              <div style="display:flex; gap:16px; margin-top:6px;">
                                  <label style="display:flex; align-items:center; gap:6px; font-size:13px; font-weight:400; cursor:pointer;">
                                      <input type="radio" v-model="store.form.useYn" value="Y" style="accent-color:#4e73df;"> 사용
                                  </label>
                                  <label style="display:flex; align-items:center; gap:6px; font-size:13px; font-weight:400; cursor:pointer;">
                                      <input type="radio" v-model="store.form.useYn" value="N" style="accent-color:#4e73df;"> 미사용
                                  </label>
                              </div>
                          </div>
                      </div>
                    <div class="modal-footer">
                        <button class="btn-modal-cancel" data-bs-dismiss="modal">취소</button>
                        <button class="btn-modal-save" @click="handleSave">저장</button>
                    </div>
                </div>
            </div>
        </div>

    </div>

</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
	"imports": {
		"http": "/dist/util/http.js?v=2",
		"docTypeStore": "/dist/util/store/docTypeStore.js?v=5"
	}
}
</script>

<script type="module">
    import { createApp, onMounted, computed } from 'vue';
    import { createPinia } from 'pinia';
    import { useDocTypeStore } from 'docTypeStore';

    let quill = null;

    const app = createApp({
        setup() {
            const store = useDocTypeStore();
            const list = computed(() => store.list);

            onMounted(() => {
                store.fetchList();

                // 드래그앤드롭 정렬
                const tbody = document.querySelector('.doctype-table tbody');
                new Sortable(tbody, {
                    handle: '.drag-handle',
                    animation: 200,
                    ghostClass: 'sortable-ghost',
                    onEnd(evt) {
                        const moved = store.list.splice(evt.oldIndex, 1)[0];
                        store.list.splice(evt.newIndex, 0, moved);
                        store.list.forEach((item, i) => item.sortOrder = i + 1);
                        store.saveSortOrders();
                    }
                });

                document.getElementById('formModal').addEventListener('shown.bs.modal', () => {
                    if (!quill) {
                        quill = new Quill('#quill-editor', {
                            theme: 'snow',
                            placeholder: '참고사항을 입력하세요...',
                            modules: {
                                toolbar: [
                                    ['bold', 'italic', 'underline'],
                                    [{ 'color': [] }],
                                    [{ 'list': 'ordered' }, { 'list': 'bullet' }],
                                    ['clean']
                                ]
                            }
                        });
                    }
                    quill.clipboard.dangerouslyPasteHTML(store.form.notice || '');
                });
            });

            const handleSave = async () => {
                if (quill) {
                    store.form.notice = quill.root.innerHTML;
                }
                const isAdd = store.formMode === 'ADD';
                const result = await store.saveForm();
                if (result) {
                    const modalEl = document.getElementById('formModal');
                    modalEl.classList.remove('show');
                    modalEl.style.display = 'none';
                    modalEl.removeAttribute('aria-modal');
                    modalEl.removeAttribute('role');
                    modalEl.setAttribute('aria-hidden', 'true');
                    document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
                    document.body.classList.remove('modal-open');
                    document.body.style.removeProperty('overflow');
                    document.body.style.removeProperty('padding-right');
                    alert(isAdd ? '등록되었습니다.' : '수정되었습니다.');
                }
            };

            return { store, list, handleSave };
        }
    });

    app.use(createPinia());
    app.mount('#vue-app');
</script>

<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.6/Sortable.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
