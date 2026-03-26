<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC - 부재 등록</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvalAbsencelist.css?v=2" type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
<style>
[v-cloak] { display: none; }

/* 페이지네이션 */
.table-pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 6px;
    padding: 16px;
    border-top: 1px solid #f0f2f9;
}
.page-btn {
    background: none;
    border: 1px solid #e6eaf4;
    border-radius: 5px;
    padding: 5px 10px;
    font-size: 12px;
    color: #7b82a0;
    cursor: pointer;
    transition: all .15s;
}
.page-btn:hover:not(:disabled) { background: #f0f3ff; border-color: #4e73df; color: #4e73df; }
.page-btn.active { background: #4e73df; border-color: #4e73df; color: #fff; font-weight: 700; }
.page-btn:disabled { opacity: .4; cursor: default; }
.status-active   { background: #e0f5ef; color: #1a9660; }
.status-inactive { background: #f0f0f0; color: #6b7280; }
</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
<div id="vue-app" v-cloak>

    <div class="absence-topbar">
        <button class="btn-new-absence" @click="openForm">
            <span class="material-symbols-outlined">add</span>
            부재 등록
        </button>
    </div>

    <div class="absence-body">

        <div class="form-panel" v-if="showForm">
            <div class="form-panel-header">
                <span class="material-symbols-outlined">event_busy</span>
                부재 등록
            </div>
            <div class="form-panel-body">

                <div class="form-field">
                    <label class="form-label">부재 기간 <span class="required">*</span></label>
                    <div class="date-range">
                        <input type="date" v-model="form.startDate" class="form-input">
                        <span class="date-sep">~</span>
                        <input type="date" v-model="form.endDate" class="form-input">
                    </div>
                </div>

                <div class="form-field">
                    <label class="form-label">부재 사유</label>
                    <select v-model="form.reason" class="form-select">
                        <option value="">사유 선택 (선택)</option>
                        <option v-for="lv in codeStore.getCodes('LEAVETYPE')"
                                :key="lv.code"
                                :value="lv.code">
                            {{ lv.name }}
                        </option>
                    </select>
                </div>

                <div class="form-field">
                    <label class="form-label">대결자 <span class="required">*</span></label>

                    <div class="member-selected" v-if="form.deputyEmpId">
                        <span class="material-symbols-outlined" style="color:#1a9660; font-size:16px;">check_circle</span>
                        <span style="font-size:13px; font-weight:600;">{{ form.deputyName }}</span>
                        <span style="font-size:12px; color:#667085; margin-left:6px;">{{ form.deputyGrade }}</span>
                        <button class="btn-clear-member" @click="form.deputyEmpId = ''; form.deputyName = ''; form.deputyGrade = ''">
                            <span class="material-symbols-outlined" style="font-size:14px;">close</span>
                        </button>
                    </div>

                    <button class="btn-search-member"
                            type="button"
                            data-bs-toggle="modal"
                            data-bs-target="#absenceOrgModal">
                        <span class="material-symbols-outlined" style="font-size:16px;">search</span>
                        대결자 검색
                    </button>
                </div>

                <div class="notice-box">
                    <span class="material-symbols-outlined" style="font-size:14px; color:#d97706;">info</span>
                    부재 기간 중 배정된 결재는 선택한 대결자가 처리합니다.
                </div>

                <div class="form-footer">
                    <button class="btn-cancel-form" @click="cancelForm">취소</button>
                    <button class="btn-submit" @click="submitForm">등록</button>
                </div>

            </div>
        </div>

        <div class="table-panel">
            <table class="absence-table">
                <thead>
                    <tr>
                        <th>부재 기간</th>
                        <th>부재 사유</th>
                        <th>대결자</th>
                        <th>부서 · 직급</th>
                        <th>상태</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-if="absenceList.length === 0">
                        <td colspan="6" style="text-align:center; padding:40px; color:#9aa0b4;">
                            등록된 부재 일정이 없습니다.
                        </td>
                    </tr>
                    <tr v-for="item in absenceList" :key="item.deputyRegId">
                        <td>
                            <div class="td-period">{{ item.startDate }} ~ {{ item.endDate }}</div>
                        </td>
                        <td>{{ getCodeName('LEAVETYPE', item.reason) || '-' }}</td>
                        <td>{{ item.deputyName }}</td>
                        <td>{{ item.deputyDept || '-' }} · {{ item.deputyGrade || '-' }}</td>
                        <td>
                            <span class="status-badge" :class="item.isActive === 'Y' ? 'status-active' : 'status-inactive'">
                                {{ item.isActive === 'Y' ? '활성' : '비활성' }}
                            </span>
                        </td>
                        <td>
                            <button class="btn-delete" @click="deleteAbsence(item.deputyRegId)">취소</button>
                        </td>
                    </tr>
                </tbody>
            </table>

            <div class="table-pagination">
                <button class="page-btn" :disabled="pageNo <= 1"
                        @click="changePage(1)">&laquo; 처음</button>
                <button class="page-btn" :disabled="pageNo <= 1"
                        @click="changePage(pageNo - 1)">&lsaquo; 이전</button>
                <button class="page-btn"
                        v-for="p in totalPages" :key="p"
                        :class="{ active: p === pageNo }"
                        @click="changePage(p)">{{ p }}</button>
                <button class="page-btn" :disabled="pageNo >= totalPages"
                        @click="changePage(pageNo + 1)">다음 &rsaquo;</button>
                <button class="page-btn" :disabled="pageNo >= totalPages"
                        @click="changePage(totalPages)">마지막 &raquo;</button>
            </div>
        </div>

    </div>
</div>
</main>

<div class="modal fade" id="absenceOrgModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header" style="background:#1d2939; color:#fff;">
                <span style="font-size:11px; color:#94a3b8;">전자결재 &gt;</span>
                <span style="font-size:13px; font-weight:600; color:#fff; margin-left:6px;">대결자 검색</span>
                <button type="button" class="btn-close btn-close-white ms-auto" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-0">
                <div style="display:flex; gap:6px; padding:12px 16px; border-bottom:1px solid #f0f2f9;">
                    <input type="text" id="absenceSearchKeyword" class="form-control form-control-sm"
                           placeholder="이름, 부서, 직급으로 검색..."
                           onkeyup="if(event.key==='Enter') absenceSearchEmp()">
                    <button class="btn btn-primary btn-sm" onclick="absenceSearchEmp()">
                        <span class="material-symbols-outlined" style="font-size:15px; vertical-align:middle;">search</span>
                        검색
                    </button>
                </div>
                <div style="display:flex; height:380px;">
                    <div style="width:220px; border-right:1px solid #f0f2f9; overflow-y:auto; flex-shrink:0;">
                        <div style="padding:10px 14px; font-size:11px; font-weight:700; color:#9aa0b4; border-bottom:1px solid #f0f2f9;">조직도</div>
                        <ul class="list-unstyled mb-0" id="absenceDeptTree"></ul>
                    </div>
                    <div style="flex:1; overflow-y:auto;">
                        <div id="absenceDeptHeader" style="padding:10px 14px; font-size:11px; font-weight:700; color:#9aa0b4; border-bottom:1px solid #f0f2f9;">부서를 선택하세요</div>
                        <div id="absenceMemberList"></div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
    "imports": {
        "vue":               "https://unpkg.com/vue@3/dist/vue.esm-browser.js",
        "vue-demi":          "https://unpkg.com/vue-demi/lib/index.mjs",
        "pinia":             "https://unpkg.com/pinia@2/dist/pinia.esm-browser.js",
        "@vue/devtools-api": "https://unpkg.com/@vue/devtools-api@6/lib/esm/index.js",
        "axios":             "https://unpkg.com/axios@1/dist/esm/axios.js",
        "http":              "/dist/util/http.js",
        "commonCodeStore":   "/dist/util/store/commonCodeStore.js"
    }
}
</script>

<script type="module">
    import { createApp, ref, computed, onMounted } from 'vue';
    import { createPinia } from 'pinia';
    import { useCommonCodeStore } from 'commonCodeStore';

    const pinia = createPinia();

    const app = createApp({
        setup() {
            const ctx       = document.querySelector('meta[name="ctx"]').content;
            const codeStore = useCommonCodeStore();

            const showForm    = ref(false);
            const absenceList = ref([]);
            const total       = ref(0);
            const pageNo      = ref(1);
            const pageSize    = ref(10);

            const totalPages = computed(() => Math.max(1, Math.ceil(total.value / pageSize.value)));

            const form = ref({
                startDate:   '',
                endDate:     '',
                reason:      '',
                deputyEmpId: '',
                deputyName:  '',
                deputyGrade: ''
            });

            const openForm   = () => { showForm.value = true; };
            const cancelForm = () => { showForm.value = false; resetForm(); };
            const resetForm  = () => {
                form.value = {
                    startDate: '', endDate: '', reason: '',
                    deputyEmpId: '', deputyName: '', deputyGrade: ''
                };
            };

            const getCodeName = (group, code) => {
                if (!code) return '';
                const found = codeStore.getCodes(group).find(c => c.code === code);
                return found ? found.name : code;
            };

            const submitForm = async () => {
                if (!form.value.startDate || !form.value.endDate) {
                    alert('부재 기간을 입력해주세요.'); return;
                }
                if (!form.value.deputyEmpId) {
                    alert('대결자를 선택해주세요.'); return;
                }
                try {
                    const res = await fetch(ctx + '/api/absence', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(form.value)
                    });
                    if (!res.ok) throw new Error();
                    alert('부재가 등록되었습니다.');
                    cancelForm();
                    fetchAbsenceList();
                } catch(e) {
                    alert('등록 중 오류가 발생했습니다.');
                }
            };

            const deleteAbsence = async (id) => {
                if (!confirm('부재 일정을 취소하시겠습니까?')) return;
                try {
                    const res = await fetch(ctx + '/api/absence/' + id, { method: 'DELETE' });
                    if (!res.ok) throw new Error();
                    fetchAbsenceList();
                } catch(e) {
                    alert('취소 중 오류가 발생했습니다.');
                }
            };

            const fetchAbsenceList = async () => {
                try {
                    const res  = await fetch(ctx + '/api/absence/list?pageNo=' + pageNo.value + '&pageSize=' + pageSize.value);
                    const data = await res.json();
                    absenceList.value = data.list  || [];
                    total.value       = data.total || 0;
                } catch(e) {
                    console.error('부재 목록 조회 실패:', e);
                }
            };

            const changePage = (p) => {
                if (p < 1 || p > totalPages.value) return;
                pageNo.value = p;
                fetchAbsenceList();
            };

            // 모달에서 대결자 선택 시 호출
            window.absenceSelectMember = (empId, empName, empGrade) => {
                form.value.deputyEmpId = empId;
                form.value.deputyName  = empName;
                form.value.deputyGrade = empGrade;
                bootstrap.Modal.getInstance(document.getElementById('absenceOrgModal')).hide();
            };

            onMounted(async () => {
                await codeStore.fetchCodes('LEAVETYPE');
                fetchAbsenceList();
            });

            return {
                showForm, absenceList, form, codeStore,
                pageNo, pageSize, total, totalPages,
                openForm, cancelForm, submitForm, deleteAbsence,
                getCodeName, changePage
            };
        }
    });

    app.use(pinia);
    app.mount('#vue-app');
</script>

<script>
const CTX = document.querySelector('meta[name="ctx"]').content;

function absenceRenderTree(nodes, parentEl, depth) {
    nodes.forEach(dept => {
        const hasChildren = dept.children && dept.children.length > 0;
        const li = document.createElement('li');

        const row = document.createElement('div');
        row.style.cssText = 'display:flex; align-items:center; gap:4px; padding:5px 10px; padding-left:' + (10 + depth * 16) + 'px; cursor:pointer; font-size:12px; color:#3a3f51;';
        row.onmouseover = () => row.style.background = '#f0f3ff';
        row.onmouseout  = () => row.style.background = '';

        const arrow = document.createElement('span');
        arrow.style.cssText = 'font-size:8px; color:#b0b7cc; width:12px; display:inline-block; transition:transform .2s;';
        arrow.innerHTML = hasChildren ? '&#9654;' : '&bull;';
        row.appendChild(arrow);

        const icon = document.createElement('span');
        icon.className = 'material-symbols-outlined';
        icon.style.cssText = 'font-size:14px; color:#9aa0b4;';
        icon.textContent = depth === 0 ? 'apartment' : (hasChildren ? 'business' : 'groups');
        row.appendChild(icon);

        const label = document.createElement('span');
        label.textContent = dept.deptName;
        row.appendChild(label);
        li.appendChild(row);

        let childUl = null;
        if (hasChildren) {
            childUl = document.createElement('ul');
            childUl.className = 'list-unstyled mb-0';
            childUl.style.display = 'none';
            absenceRenderTree(dept.children, childUl, depth + 1);
            li.appendChild(childUl);

            arrow.addEventListener('click', (e) => {
                e.stopPropagation();
                const isOpen = childUl.style.display === 'block';
                childUl.style.display = isOpen ? 'none' : 'block';
                arrow.style.transform = isOpen ? '' : 'rotate(90deg)';
                arrow.style.color = isOpen ? '#b0b7cc' : '#4e73df';
            });
        }

        row.addEventListener('click', () => {
            absenceLoadMembers(dept.deptCode, dept.deptName);
        });

        parentEl.appendChild(li);
    });
}

function absenceLoadMembers(deptCode, deptName) {
    document.getElementById('absenceDeptHeader').textContent = deptName + ' (조회 중...)';
    document.getElementById('absenceMemberList').innerHTML = '<p style="padding:20px; color:#9aa0b4; font-size:13px;">불러오는 중...</p>';

    fetch(CTX + '/api/approval/org/emp?deptCode=' + encodeURIComponent(deptCode))
        .then(r => r.json())
        .then(res => {
            const list = res.list || [];
            document.getElementById('absenceDeptHeader').textContent = deptName + ' (' + list.length + '명)';
            absenceRenderMembers(list);
        })
        .catch(() => {
            document.getElementById('absenceDeptHeader').textContent = deptName + ' (조회 실패)';
            document.getElementById('absenceMemberList').innerHTML = '<p style="padding:20px; color:#e53e3e; font-size:13px;">사원 조회에 실패했습니다.</p>';
        });
}

function absenceSearchEmp() {
    const keyword = document.getElementById('absenceSearchKeyword').value.trim();
    if (!keyword) return;
    document.getElementById('absenceDeptHeader').textContent = '검색 중...';
    document.getElementById('absenceMemberList').innerHTML = '<p style="padding:20px; color:#9aa0b4; font-size:13px;">검색 중...</p>';

    fetch(CTX + '/api/approval/org/emp/search?keyword=' + encodeURIComponent(keyword))
        .then(r => r.json())
        .then(res => {
            const list = res.list || [];
            document.getElementById('absenceDeptHeader').textContent = '검색 결과 (' + list.length + '건)';
            absenceRenderMembers(list);
        })
        .catch(() => {
            document.getElementById('absenceDeptHeader').textContent = '검색 실패';
            document.getElementById('absenceMemberList').innerHTML = '<p style="padding:20px; color:#e53e3e; font-size:13px;">검색에 실패했습니다.</p>';
        });
}

function absenceRenderMembers(list) {
    const container = document.getElementById('absenceMemberList');
    if (!list || list.length === 0) {
        container.innerHTML = '<p style="padding:20px; color:#9aa0b4; font-size:13px;">소속 사원이 없습니다.</p>';
        return;
    }
    container.innerHTML = '';
    list.forEach(emp => {
        const empId = emp.empId || emp.EMPID || '';
        const name  = emp.name  || emp.NAME  || '';
        const dept  = emp.dept  || emp.DEPT  || '';
        const grade = emp.grade || emp.GRADE || '';

        const item = document.createElement('div');
        item.style.cssText = 'display:flex; align-items:center; justify-content:space-between; padding:9px 14px; border-bottom:1px solid #f8f9fc; cursor:pointer;';
        item.onmouseover = () => item.style.background = '#f0f3ff';
        item.onmouseout  = () => item.style.background = '';

        item.innerHTML =
            '<div style="display:flex; align-items:center; gap:12px;">' +
                '<span style="font-size:13px; font-weight:600; color:#1d2939; min-width:60px;">' + name + '</span>' +
                '<span style="font-size:12px; color:#667085;">' + dept + '</span>' +
                '<span style="font-size:11px; color:#9aa0b4; background:#f1f3f9; padding:2px 8px; border-radius:10px;">' + grade + '</span>' +
            '</div>' +
            '<span style="font-size:11px; font-weight:600; color:#4e73df;">+ 선택</span>';

        item.addEventListener('click', () => {
            window.absenceSelectMember(empId, name, grade);
        });

        container.appendChild(item);
    });
}

document.getElementById('absenceOrgModal').addEventListener('show.bs.modal', () => {
    const tree = document.getElementById('absenceDeptTree');
    if (tree.children.length > 0) return;

    fetch(CTX + '/api/approval/org/dept')
        .then(r => r.json())
        .then(res => {
            tree.innerHTML = '';
            absenceRenderTree(res.tree || [], tree, 0);
        })
        .catch(err => console.error('조직도 로드 실패:', err));
});
</script>

</body>
</html>
