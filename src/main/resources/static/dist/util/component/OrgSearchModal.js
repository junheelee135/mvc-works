import { ref, reactive, computed, watch, provide, inject } from 'vue';
import http from 'http';

// 모듈 레벨 트리 캐시 (모든 인스턴스 공유)
let cachedDeptTree = null;

// ── 재귀 트리 노드 (내부 컴포넌트) ──
const TreeNode = {
    name: 'tree-node',
    props: ['node', 'depth'],
    template: `
        <div class="tree-node">
            <div class="tree-label"
                 :class="['depth-' + depth, { active: ctx.selectedDeptCode === node.deptCode }]"
                 @click="handleClick">
                <span v-if="hasChildren" class="tree-arrow"
                      :class="{ open: ctx.expandedDepts[node.deptCode] }">&#9654;</span>
                <span v-else class="tree-dot">&#8226;</span>
                <span class="material-symbols-outlined tree-icon">{{ icon }}</span>
                <span class="tree-name">{{ node.deptName }}</span>
            </div>
            <div v-if="hasChildren" class="tree-children"
                 :class="{ open: ctx.expandedDepts[node.deptCode] }">
                <tree-node v-for="child in node.children" :key="child.deptCode"
                          :node="child" :depth="depth + 1" />
            </div>
        </div>
    `,
    setup(props) {
        const ctx = inject('orgModalCtx');
        const icons = ['apartment', 'business', 'groups'];
        const hasChildren = computed(() => props.node.children && props.node.children.length > 0);
        const icon = computed(() => icons[props.depth] || 'groups');

        const handleClick = () => {
            if (hasChildren.value) ctx.toggleDept(props.node.deptCode);
            ctx.selectDept(props.node.deptCode, props.node.deptName);
        };

        return { ctx, hasChildren, icon, handleClick };
    }
};

// ── 조직도 사원 검색 모달 (재사용 가능) ──
export const OrgSearchModal = {
    name: 'OrgSearchModal',
    components: { 'tree-node': TreeNode },
    props: {
        visible:     { type: Boolean, default: false },
        title:       { type: String,  default: '사원 검색' },
        addedEmpIds: { type: Array,   default: () => [] }
    },
    emits: ['update:visible', 'add'],
    template: `
        <div class="modal-overlay" v-show="visible">
            <div class="modal-box org-search-box">
                <div class="modal-header">
                    <div class="modal-breadcrumb">전자 결재 &gt; <span>{{ title }}</span></div>
                    <div class="modal-header-btns">
                        <button title="닫기" @click="close">
                            <span class="material-symbols-outlined" style="font-size:18px">close</span>
                        </button>
                    </div>
                </div>
                <div class="modal-body org-search-body">
                    <div class="org-search-bar">
                        <input type="text" v-model="keyword"
                               placeholder="이름, 부서, 직급으로 검색..."
                               @keyup.enter="searchEmp">
                        <button class="btn-org-search" @click="searchEmp">
                            <span class="material-symbols-outlined" style="font-size:16px">search</span>
                            검색
                        </button>
                    </div>
                    <div class="org-search-content">
                        <div class="org-tree-panel">
                            <div class="org-tree-header">조직도</div>
                            <div class="org-tree">
                                <tree-node v-for="node in deptTree" :key="node.deptCode"
                                           :node="node" :depth="0" />
                            </div>
                        </div>
                        <div class="org-emp-panel">
                            <div class="org-emp-header">{{ empHeader }}</div>
                            <div class="org-emp-list">
                                <div v-if="empList.length === 0 && !empLoaded" class="org-emp-empty">
                                    <span class="material-symbols-outlined">account_tree</span>
                                    왼쪽 조직도에서 부서를 선택하세요.
                                </div>
                                <div v-else-if="empList.length === 0 && empLoaded" class="org-emp-empty">
                                    <span class="material-symbols-outlined">person_off</span>
                                    소속 사원이 없습니다.
                                </div>
                                <div v-for="(emp, idx) in empList" :key="emp.empId"
                                     class="org-emp-item"
                                     :class="{ added: isAdded(emp.empId) }"
                                     @click="addPerson(idx)">
                                    <div class="org-emp-info">
                                        <span class="org-emp-name">{{ emp.name }}</span>
                                        <span class="org-emp-dept">{{ emp.dept }}</span>
                                        <span class="org-emp-grade">{{ emp.grade }}</span>
                                    </div>
                                    <span class="org-emp-action">
                                        {{ isAdded(emp.empId) ? '추가됨' : '+ 추가' }}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button class="btn-close-modal" @click="close">닫기</button>
                </div>
            </div>
        </div>
    `,
    setup(props, { emit }) {
        const keyword = ref('');
        const deptTree = ref([]);
        const expandedDepts = reactive({});
        const selectedDeptCode = ref(null);
        const empList = ref([]);
        const empHeader = ref('부서를 선택하세요');
        const empLoaded = ref(false);

        // TreeNode에 provide (reactive로 감싸서 ref 자동 언래핑)
        const toggleDept = (code) => { expandedDepts[code] = !expandedDepts[code]; };
        const selectDept = async (code, name) => {
            selectedDeptCode.value = code;
            empHeader.value = name + ' (조회 중...)';
            empLoaded.value = false;
            try {
                const res = await http.get('/approval/org/emp', { params: { deptCode: code } });
                empList.value = (res.data.list || []).map(normalize);
                empHeader.value = name + ' (' + empList.value.length + '명)';
                empLoaded.value = true;
            } catch (e) {
                console.error('사원 조회 실패:', e);
                empHeader.value = name + ' (조회 실패)';
            }
        };

        provide('orgModalCtx', reactive({ expandedDepts, selectedDeptCode, toggleDept, selectDept }));

        // 부서 트리 (캐시 공유)
        async function loadDeptTree() {
            if (cachedDeptTree) { deptTree.value = cachedDeptTree; return; }
            try {
                const res = await http.get('/approval/org/dept');
                cachedDeptTree = res.data.tree || [];
                deptTree.value = cachedDeptTree;
            } catch (e) {
                console.error('조직도 로딩 실패:', e);
            }
        }

        // 사원 검색
        async function searchEmp() {
            const kw = keyword.value.trim();
            if (!kw) return;
            selectedDeptCode.value = null;
            empHeader.value = '검색 중...';
            empLoaded.value = false;
            try {
                const res = await http.get('/approval/org/emp/search', { params: { keyword: kw } });
                empList.value = (res.data.list || []).map(normalize);
                empHeader.value = '검색 결과 (' + empList.value.length + '건)';
                empLoaded.value = true;
            } catch (e) {
                console.error('사원 검색 실패:', e);
                empHeader.value = '검색 실패';
            }
        }

        // Oracle 대문자 키 정규화
        function normalize(emp) {
            return {
                empId:     emp.empId     || emp.EMPID,
                name:      emp.name      || emp.NAME,
                dept:      emp.dept      || emp.DEPT,
                grade:     emp.grade     || emp.GRADE,
                deptCode:  emp.deptCode  || emp.DEPTCODE,
                gradeCode: emp.gradeCode || emp.GRADECODE
            };
        }

        function isAdded(empId) { return props.addedEmpIds.includes(empId); }

        function addPerson(idx) {
            const emp = empList.value[idx];
            if (emp && !isAdded(emp.empId)) emit('add', { ...emp });
        }

        function close() { emit('update:visible', false); }

        // 모달 열릴 때 초기화 + 트리 로드
        watch(() => props.visible, (val) => {
            if (val) {
                keyword.value = '';
                empList.value = [];
                empHeader.value = '부서를 선택하세요';
                empLoaded.value = false;
                selectedDeptCode.value = null;
                if (deptTree.value.length === 0) loadDeptTree();
            }
        });

        return {
            keyword, deptTree, empList, empHeader, empLoaded,
            searchEmp, isAdded, addPerson, close
        };
    }
};
