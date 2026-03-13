import { defineStore } from 'pinia';
import http from 'http';
import { getPagination } from 'paginate';

export const useHrmStore = defineStore('hrm', {

    // ──────────────────────────────────────────────
    // State
    // ──────────────────────────────────────────────
    state: () => ({
        list: [],
        sessionName: '',

        searchParams: {
            name:          '',
            empNo:         '',      // empId 검색용 (LIKE)
            project:       '',
            deptCode:      '',      // 부서 공통코드 검색용
            gradeCode:     '',      // 직급 공통코드 검색용
            empStatusCode: '',      // E=재직 / L=휴직 / R=퇴직
            levelCode:     '',      // 권한레벨 숫자
			authorityCode: '',      // 권한 공통코드 검색용
            pmoY:          false,   // isPmo = 'Y' 검색
            pmoN:          false,   // isPmo = 'N' 검색
            page:          1
        },

        pageInfo: { totalCount: 0, totalPage: 1, pageSize: 10 },
        pagination: null,
        loading: false,

        sortCol: '',
        sortDir: 'asc',

        // 인라인 편집용 셀렉트 옵션 (화면 초기 로딩 시 GET /api/hrm/codes 로 채워짐)
        deptOptions:   [],   // { code, codeName } — codeGroup='DEPT'
        gradeOptions:  [],   // { code, codeName } — codeGroup='RANK'
        statusOptions: [],   // { code, codeName } — codeGroup='EMPSTATUS'
		authorityOptions: []
    }),

    // ──────────────────────────────────────────────
    // Getters
    // ──────────────────────────────────────────────
    getters: {
        isAllChecked:    (state) => state.list.length > 0 && state.list.every(e => e._checked),
        isIndeterminate: (state) => state.list.some(e => e._checked) && !state.list.every(e => e._checked),
    },

    // ──────────────────────────────────────────────
    // Actions
    // ──────────────────────────────────────────────
    actions: {

        // ════════════════════════════════════════════
        // [1] 공통코드 로드 (GET /api/hrm/codes)
        //   화면 초기 진입 시 1회 호출 — 부서·직급·재직상태 옵션 세팅
        // ════════════════════════════════════════════
        async loadCodes() {
            try {
                const res = await http.get('/hrm/codes');
                // 서버 응답: { dept: [{code, codeName}], rank: [...], empStatus: [...] }
                this.deptOptions   = res.data.dept      || [];
                this.gradeOptions  = res.data.rank      || [];
                this.statusOptions = res.data.empStatus || [];
				this.authorityOptions = res.data.authority || [];
            } catch (error) {
                console.error('공통코드 조회 오류:', error);
            }
        },

        // ════════════════════════════════════════════
        // [2] 목록 조회 (GET /api/hrm)
        // ════════════════════════════════════════════
        async fetchList(page = this.searchParams.page) {
            this.loading = true;
            this.searchParams.page = page;

            try {
                const res = await http.get('/hrm', {
                    params: {
                        ...this.searchParams,
                        pageSize: this.pageInfo.pageSize,
                        sortCol:  this.sortCol,
                        sortDir:  this.sortDir,
                    }
                });

                this.list = (res.data.list || []).map(emp => this._wrapRow(emp));

                this.pageInfo.totalCount = res.data.totalCount;
                this.pageInfo.totalPage  = res.data.totalPage;

                this.pagination = getPagination(
                    this.searchParams.page,
                    this.pageInfo.totalPage,
                    10
                );
                // getPagination 반환: prevBlockPage/nextBlockPage 는 이동 불가 시 null
                // showPrev/showNext 는 boolean — jsp에서 disabled 판단에 사용
            } catch (error) {
                console.error('직원 목록 조회 오류:', error);
                alert('목록을 불러오는 중 오류가 발생했습니다.');
            } finally {
                this.loading = false;
            }
        },

        // ════════════════════════════════════════════
        // [2] 검색
        // ════════════════════════════════════════════
        search() {
            this.fetchList(1);
        },

        // PMO 필터 : radio 방식 (Y / N / 전체)
        setPmoFilter(value) {
            this.searchParams.pmoY = (value === 'Y');
            this.searchParams.pmoN = (value === 'N');
        },

        // ════════════════════════════════════════════
        // [3] 행 추가 — 사원번호 자동채번 (GET /api/hrm/next-emp-id)
        //   empId 는 서버에서 MAX+1 을 받아 자동 할당 (readonly)
        // ════════════════════════════════════════════
        async addRow() {
            try {
                // 자동채번 API 호출
                const res = await http.get('/hrm/next-emp-id');
                const nextEmpId = res.data?.nextEmpId || '';

                const newEmp = {
                    _tempId:       'new_' + Date.now(),
                    empId:         nextEmpId,   // 자동채번된 사원번호 (readonly)
                    name:          '',
                    password:      '',           // 신규 등록 시 필수
                    deptCode:      '',
                    gradeCode:     '',
                    authorityCode: '',
                    levelCode:     1,
                    empStatusCode: '',           // (없음) 상태로 시작
                    enabled:       1,
                    hireDate:      '',
                    projectNames:  '',
                    profilePhoto:  '',
                    _checked:      true,
                    _editing:      true,
                    _dirty:        false,
                    _isNew:        true,
                };
                this.list.push(newEmp);
            } catch (error) {
                console.error('사원번호 채번 오류:', error);
                alert('사원번호 자동 채번 중 오류가 발생했습니다.');
            }
        },

        // ════════════════════════════════════════════
        // [4] 저장 — 신규(POST) + 수정된 기존 행(PUT bulk)
        // ════════════════════════════════════════════
        async saveRows() {
            this.deactivateAll();

            const newRows   = this.list.filter(e => e._isNew);
            const dirtyRows = this.list.filter(e => e._dirty && !e._isNew);

            if (newRows.length === 0 && dirtyRows.length === 0) {
                alert('변경된 내용이 없습니다.');
                return;
            }

            try {
                // 신규 등록 (POST /api/hrm)
                for (const emp of newRows) {
                    if (!emp.empId?.trim()) {
                        alert('사원번호는 필수입니다.');
                        return;
                    }
                    if (!emp.name?.trim()) {
                        alert('이름은 필수입니다.');
                        return;
                    }
                    if (!emp.password?.trim()) {
                        alert('비밀번호는 필수입니다.');
                        return;
                    }

                    try {
                        await http.post('/hrm', this._toPayload(emp));
                    } catch (err) {
                        if (err?.response?.status === 409) {
                            alert(`사원번호 중복: ${emp.empId}`);
                            return;
                        }
                        throw err;
                    }
                }

                // 벌크 수정 (PUT /api/hrm/bulk)
                if (dirtyRows.length > 0) {
                    await http.put('/hrm/bulk', dirtyRows.map(e => this._toPayload(e)));
                }

                alert('저장되었습니다.');
                this.fetchList();

            } catch (error) {
                console.error('저장 오류:', error);
                alert(error?.response?.data || '저장 중 오류가 발생했습니다.');
            }
        },

        // ════════════════════════════════════════════
        // [5] 더블클릭 행 편집 활성화
        //   - 사원번호(empId)는 _isNew=true 일 때만 수정 가능
        // ════════════════════════════════════════════
        activateRowEdit(emp) {
            this.list.forEach(e => {
                if (e !== emp && e._editing && !e._isNew) {
                    // 편집 중인 행의 현재 값을 스냅샷으로 저장 (Vue 반응형 객체 보존)
                    e._snapshot = {
                        deptCode:      e.deptCode,
                        deptName:      e.deptName,
                        gradeCode:     e.gradeCode,
                        gradeName:     e.gradeName,
                        authorityCode: e.authorityCode,
                        authorityName: e.authorityName,
                        empStatusCode: e.empStatusCode,
                        levelCode:     e.levelCode,
                        password:      e.password,
                    };
                    e._editing = false;
                }
            });
            emp._editing = true;
        },

        // ════════════════════════════════════════════
        // [7] 삭제 — empId 는 String
        // ════════════════════════════════════════════
        async deleteSelected() {
            const checked = this.list.filter(e => e._checked);
            if (checked.length === 0) { alert('삭제할 항목을 선택해 주세요.'); return; }
            if (!confirm(checked.length + '건을 삭제하시겠습니까?')) return;

            const newRows    = checked.filter(e => e._isNew);
            const serverRows = checked.filter(e => !e._isNew);

            newRows.forEach(e => {
                const idx = this.list.indexOf(e);
                if (idx > -1) this.list.splice(idx, 1);
            });

            if (serverRows.length > 0) {
                try {
                    const ids = serverRows.map(e => e.empId);   // String[]
                    await http.delete('/hrm', { data: { ids } });
                    this.fetchList();
                } catch (error) {
                    console.error('삭제 오류:', error);
                    alert(error?.response?.data || '삭제 중 오류가 발생했습니다.');
                }
            }
        },

        // ════════════════════════════════════════════
        // [8] 취소 — 모든 변경 취소 후 전체 조회
        // ════════════════════════════════════════════
        cancelEdit() {
            const hasChanges = this.list.some(e => e._dirty || e._isNew || e._editing);
            if (!hasChanges) { alert('취소할 내용이 없습니다.'); return; }
            if (!confirm('모든 변경 내용을 취소하고 새로 조회하시겠습니까?')) return;
            this.fetchList();
        },

        // ════════════════════════════════════════════
        // [9] 엑셀 다운로드
        // ════════════════════════════════════════════
        excelDownload() {
            const { name, empNo, project, deptCode, gradeCode, empStatusCode, levelCode, authorityCode, pmoY, pmoN } = this.searchParams;
            const qs = new URLSearchParams({ name, empNo, project, deptCode, gradeCode, empStatusCode, levelCode, authorityCode, pmoY, pmoN });
            location.href = '/api/hrm/excel/download?' + qs;
        },

        // ════════════════════════════════════════════
        // [9-1] 엑셀 업로드 양식 다운로드
        //   헤더(이름·비밀번호·부서코드·직급코드·권한코드·권한레벨·재직상태코드)만 있는 빈 양식
        // ════════════════════════════════════════════
        excelTemplateDownload() {
            location.href = '/api/hrm/excel/template';
        },

        // ════════════════════════════════════════════
        // [10] 엑셀 업로드
        // ════════════════════════════════════════════
        triggerExcelUpload() {
            document.querySelector('input[type="file"][accept=".xlsx,.xls"]')?.click();
        },

        async excelUpload(event) {
            const file = event.target.files?.[0];
            if (!file) return;

            const formData = new FormData();
            formData.append('file', file);

            try {
                const res = await http.post('/hrm/excel/upload', formData, {
                    headers: { 'Content-Type': 'multipart/form-data' }
                });
                const cnt = res.data?.insertedCount ?? '';
                alert(`엑셀 업로드 완료${cnt !== '' ? ' (' + cnt + '건 등록)' : ''}`);
                this.fetchList(1);
            } catch (error) {
                console.error('엑셀 업로드 오류:', error);
                alert(error?.response?.data || '엑셀 업로드 중 오류가 발생했습니다.');
            } finally {
                event.target.value = '';
            }
        },

        // ════════════════════════════════════════════
        // 체크박스
        // ════════════════════════════════════════════
        toggleAll(checked) { this.list.forEach(emp => { emp._checked = checked; }); },
        toggleRow(emp, checked) { emp._checked = checked; },

        // ════════════════════════════════════════════
        // 인라인 편집 헬퍼
        // ════════════════════════════════════════════
        deactivateAll() { this.list.forEach(e => { e._editing = false; }); },
        markDirty(emp)  { emp._dirty = true; },

        // ════════════════════════════════════════════
        // 정렬
        // ════════════════════════════════════════════
        sortBy(col) {
            if (this.sortCol === col) {
                this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc';
            } else {
                this.sortCol = col;
                this.sortDir = 'asc';
            }
            this.fetchList(1);
        },
        getSortClass(col) {
            if (this.sortCol !== col) return '';
            return this.sortDir === 'asc' ? 'asc' : 'desc';
        },

        // ════════════════════════════════════════════
        // 순번 계산 (신규 행 제외)
        // ════════════════════════════════════════════
        getRowNo(index) {
            const newRowsBefore = this.list.slice(0, index).filter(e => e._isNew).length;
            const realIndex     = index - newRowsBefore;
            const offset        = (this.searchParams.page - 1) * this.pageInfo.pageSize;
            return this.pageInfo.totalCount - offset - realIndex;
        },

        // ════════════════════════════════════════════
        // 재직상태 라벨 (empStatusCode → 한글)
        //   statusOptions가 로드된 후에는 DB 코드명 사용
        // ════════════════════════════════════════════
        statusLabel(code) {
            const found = this.statusOptions.find(s => s.code === code);
            if (found) return found.codeName;
            return { ES01: '재직', ES02: '휴직', ES03: '퇴직', ES04: '계약만료' }[code] || code;
        },

        // ════════════════════════════════════════════
        // 내부 헬퍼
        // ════════════════════════════════════════════
        _wrapRow(emp) {
            return { ...emp, _checked: false, _editing: false, _dirty: false, _isNew: false, _snapshot: null };
        },
        _toPayload(emp) {
            const { _checked, _editing, _dirty, _isNew, _tempId, ...payload } = emp;
            return payload;
        },
    }
});