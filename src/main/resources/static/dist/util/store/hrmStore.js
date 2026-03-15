import { defineStore } from 'pinia';
import http from 'http';
import { getPagination } from 'paginate';

export const useHrmStore = defineStore('hrm', {
    state: () => ({
        list: [],
        sessionName: '',

		//검색 파라메터
        searchParams: {
            name:          '',		// 직원 이름
            empNo:         '',      // 사원 번호
            project:       '',		// 프로젝트 이름
            deptCode:      '',      // 부서 공통코드
            gradeCode:     '',      // 직급 공통코드
            empStatusCode: '',      // 재직 공통코드
            levelCode:     '',      // 권한레벨
			authorityCode: '',      // 권한등급 공통코드
            pmoY:          false,
            pmoN:          false,
            page:          1
        },

        pageInfo: { totalCount: 0, totalPage: 1, pageSize: 10 },
        pagination: null,
        loading: false,

        sortCol: '',
        sortDir: 'asc',

        //inline select option
        deptOptions:   [],
        gradeOptions:  [],
        statusOptions: [],
		authorityOptions: []
    }),
	
    getters: {
        isAllChecked:    (state) => state.list.length > 0 && state.list.every(e => e._checked),
        isIndeterminate: (state) => state.list.some(e => e._checked) && !state.list.every(e => e._checked),
    },

    actions: {
        async loadCodes() {
            try {
				//공통코드 조회
                const res = await http.get('/hrm/codes');
                this.deptOptions   = res.data.dept      || [];
                this.gradeOptions  = res.data.rank      || [];
                this.statusOptions = res.data.empStatus || [];
				this.authorityOptions = res.data.authority || [];
            } catch (error) {
                console.error('공통코드 조회 오류:', error);
            }
        },
		
		//리스트 조회
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
            } catch (error) {
                console.error('직원 목록 조회 오류:', error);
                alert('목록을 불러오는 중 오류가 발생했습니다.');
            } finally {
                this.loading = false;
            }
        },
		
		//조회
        search() {
            this.fetchList(1);
        },
		//PMO 필터
        setPmoFilter(value) {
            this.searchParams.pmoY = (value === 'Y');
            this.searchParams.pmoN = (value === 'N');
        },
		
		//행 추가
        async addRow() {
            try {
                //자동채번 API 호출
                const res = await http.get('/hrm/next-emp-id');
				//사원번호 자동채번
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

		//저장
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
					if (!emp.authorityCode) {
						alert('권한은 필수 선택사항입니다.');
						return;
					}
					if(emp.levelCode === null || emp.levelCode === undefined || emp.levelCode === ''){
						alert('레벨은 필수 입력 사항입니다.');
						return;
					}
					if(emp.levelCode <= 0 || emp.levelCode >= 99) {
						alert('레벨 입력 범위는 1 ~ 98 입니다.')
						return;
					}
					if(!emp.empStatusCode) {
						alert('재직상태는 필수 선택사항입니다.');
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

		//더블 클릭 행 편집
        activateRowEdit(emp) {
            this.list.forEach(e => {
                if (e !== emp && e._editing && !e._isNew) {
                    e._editing = false;
                }
            });
            emp._editing = true;
        },

		//삭제
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
                    const ids = serverRows.map(e => e.empId);
                    await http.delete('/hrm', { data: { ids } });
                    this.fetchList();
                } catch (error) {
                    console.error('삭제 오류:', error);
                    alert(error?.response?.data || '삭제 중 오류가 발생했습니다.');
                }
            }
        },

        //취소
        cancelEdit() {
            const hasChanges = this.list.some(e => e._dirty || e._isNew || e._editing);
            if (!hasChanges) { alert('취소할 내용이 없습니다.'); return; }
            if (!confirm('모든 변경 내용을 취소하고 새로 조회하시겠습니까?')) return;
            this.fetchList();
        },

		//엑셀 다운로드
        excelDownload() {
            const { name, empNo, project, deptCode, gradeCode, empStatusCode, levelCode, authorityCode, pmoY, pmoN } = this.searchParams;
            const qs = new URLSearchParams({ name, empNo, project, deptCode, gradeCode, empStatusCode, levelCode, authorityCode, pmoY, pmoN });
            location.href = '/api/hrm/excel/download?' + qs;
        },

        //엑셀 업로드 양식 다운로드
        excelTemplateDownload() {
            location.href = '/api/hrm/excel/template';
        },

		//엑셀 업로드
        triggerExcelUpload() {
            document.querySelector('input[type="file"][accept=".xlsx,.xls"]')?.click();
        },

        async excelUpload(event) {
            const file = event.target.files?.[0];
            if (!file) return;

            const formData = new FormData();
            formData.append('file', file);

            try {
                const startTime = performance.now();

                const res = await http.post('/hrm/excel/upload', formData, {
                    headers: { 'Content-Type': 'multipart/form-data' },
					timeout: 300000
                });

                const elapsed = ((performance.now() - startTime) / 1000).toFixed(2);
                const cnt = res.data?.insertedCount ?? '';
                alert(`엑셀 업로드 완료${cnt !== '' ? ' (' + cnt + '건 등록)' : ''}\n소요 시간: ${elapsed}초`);
                this.fetchList(1);
            } catch (error) {
                console.error('엑셀 업로드 오류:', error);
                alert(error?.response?.data || '엑셀 업로드 중 오류가 발생했습니다.');
            } finally {
                event.target.value = '';
            }
        },

        // 체크박스
        toggleAll(checked) { this.list.forEach(emp => { emp._checked = checked; }); },
        toggleRow(emp, checked) { emp._checked = checked; },

        // 인라인 편집
        deactivateAll() { this.list.forEach(e => { e._editing = false; }); },
        markDirty(emp)  { emp._dirty = true; },

        // 코드값 변경 시 코드명을 emp 객체 동기화
        onDeptChange(emp) {
            const found = this.deptOptions.find(d => d.CODE === emp.deptCode);
            emp.deptName = found ? found.CODENAME : emp.deptCode;
            emp._dirty = true;
        },
        onGradeChange(emp) {
            const found = this.gradeOptions.find(g => g.CODE === emp.gradeCode);
            emp.gradeName = found ? found.CODENAME : emp.gradeCode;
            emp._dirty = true;
        },
        onAuthorityChange(emp) {
            const found = this.authorityOptions.find(a => a.CODE === emp.authorityCode);
            emp.authorityName = found ? found.CODENAME : emp.authorityCode;
            emp._dirty = true;
        },

        // 정렬
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

        // 순번 계산 (신규 행 추가 제외)
        getRowNo(index) {
            const newRowsBefore = this.list.slice(0, index).filter(e => e._isNew).length;
            const realIndex     = index - newRowsBefore;
            const offset        = (this.searchParams.page - 1) * this.pageInfo.pageSize;
            return this.pageInfo.totalCount - offset - realIndex;
        },

        // 재직상태 라벨
        statusLabel(code) {
            const found = this.statusOptions.find(s => s.code === code);
            if (found) return found.codeName;
            return { ES01: '재직', ES02: '휴직', ES03: '퇴직', ES04: '계약만료' }[code] || code;
        },

        _wrapRow(emp) {
            return { ...emp, _checked: false, _editing: false, _dirty: false, _isNew: false };
        },
        _toPayload(emp) {
            const { _checked, _editing, _dirty, _isNew, _tempId, ...payload } = emp;
            return payload;
        },
    }
});