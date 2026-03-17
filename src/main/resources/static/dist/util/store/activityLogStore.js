import { defineStore } from 'pinia';
import http from 'http';
import { getPagination } from 'paginate';

export const useActivityLogStore = defineStore('activityLog', {
    state: () => ({
        list: [],
        sessionName: '',

        // 검색 파라메터
        searchParams: {
            actorEmpId: '',
            actorName:  '',
            targetMenu: '',
            result:     '',
            actionType: '',
            startDate:  '',
            endDate:    '',
            page:       1
        },

        pageInfo: { totalCount: 0, totalPage: 1, pageSize: 10 },
        pagination: null,
        loading: false,

        sortCol: 'logDate',
        sortDir: 'desc',

        // 상세 모달
        detailItem: null,
        showDetail: false,

        // ★ 공통코드 맵 (code → codeName)
        commonCodeMap: {
            DEPT:      {},   // 부서
            RANK:      {},   // 직급
            EMPSTATUS: {},   // 재직상태
            AUTHORITY: {},   // 권한
        },

    }),

    actions: {

        // ── 공통코드 로드 ────────────────────────────────────────────────────────
        // GET /api/hrm/codes — dept / rank / empStatus / authority 한 번에 반환
        async loadCommonCodes() {
            try {
                const res = await http.get('/hrm/codes');
                const data = res.data;

                // 컨트롤러 응답 키 → commonCodeMap 키 매핑
                const keyMap = {
                    dept:      'DEPT',
                    rank:      'RANK',
                    empStatus: 'EMPSTATUS',
                    authority: 'AUTHORITY',
                };

                Object.entries(keyMap).forEach(([resKey, storeKey]) => {
                    const map = {};
                    (data[resKey] || []).forEach(item => {
                        map[item.CODE] = item.CODENAME;
                    });
                    this.commonCodeMap[storeKey] = map;
                });
            } catch (e) {
                console.error('공통코드 로드 오류:', e);
            }
        },

        // ── 목록 조회 ─────────────────────────────────────────────────────────
        async fetchList(page = this.searchParams.page) {
            this.loading = true;
            this.searchParams.page = page;

            try {
                const res = await http.get('/activity-log', {
                    params: {
                        ...this.searchParams,
                        pageSize: this.pageInfo.pageSize,
                        sortCol:  this.sortCol,
                        sortDir:  this.sortDir,
                    }
                });

                this.list = res.data.list || [];
                this.pageInfo.totalCount = res.data.totalCount;
                this.pageInfo.totalPage  = res.data.totalPage;

                this.pagination = getPagination(
                    this.searchParams.page,
                    this.pageInfo.totalPage,
                    10
                );
            } catch (error) {
                console.error('활동 로그 조회 오류:', error);
                alert('목록을 불러오는 중 오류가 발생했습니다.');
            } finally {
                this.loading = false;
            }
        },

        // 검색
        search() {
            this.fetchList(1);
        },

        // 검색 조건 초기화
        resetSearch() {
            this.searchParams = {
                actorEmpId: '',
                actorName:  '',
                targetMenu: '',
                result:     '',
                actionType: '',
                startDate:  '',
                endDate:    '',
                page:       1
            };
            this.sortCol = 'logDate';
            this.sortDir = 'desc';
            this.fetchList(1);
        },

        // 정렬
        sortBy(col) {
            if (this.sortCol === col) {
                this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc';
            } else {
                this.sortCol = col;
                this.sortDir = 'desc';
            }
            this.fetchList(1);
        },
        getSortClass(col) {
            if (this.sortCol !== col) return '';
            return this.sortDir === 'asc' ? 'asc' : 'desc';
        },

        // 상세 모달
        openDetail(item) {
            this.detailItem = item;
            this.showDetail = true;
        },
        closeDetail() {
            this.detailItem = null;
            this.showDetail = false;
        },

        // 순번 계산
        getRowNo(index) {
            const offset = (this.searchParams.page - 1) * this.pageInfo.pageSize;
            return this.pageInfo.totalCount - offset - index;
        },

        // 한글 label
        actionLabel(type) {
            const map = {
                INSERT:       '등록',
                UPDATE:       '수정',
                DELETE:       '삭제',
                BULK_UPDATE:  '일괄수정',
                EXCEL_IMPORT: '엑셀 업로드',
            };
            return map[type] || type;
        },

        // ★ JSON 문자열 → 사용자 표시용 필드 배열로 파싱
        //   단건(object) / 복수(array) 모두 처리
        //   반환: [{ label, code, name }, ...]  행(row) 배열
        parseEmployeeData(jsonStr) {
            if (!jsonStr) return null;

            // EXCEL_IMPORT 결과값 처리 (importedCount 형태)
            try {
                const parsed = JSON.parse(jsonStr);
                if (parsed && typeof parsed.importedCount === 'number') {
                    return [{ single: true, rows: [{ label: '처리 건수', value: parsed.importedCount + '건' }] }];
                }
            } catch { /* 아래에서 재시도 */ }

            let records;
            try {
                const parsed = JSON.parse(jsonStr);
                records = Array.isArray(parsed) ? parsed : [parsed];
            } catch {
                return null;
            }

            // 출력할 필드 정의 (label + codeGroup: null이면 그대로 출력)
            const FIELDS = [
                { key: 'empId',         label: '사원번호',   codeGroup: null        },
                { key: 'name',          label: '이름',       codeGroup: null        },
                { key: 'levelCode',     label: '권한레벨',   codeGroup: null        },
                { key: 'empStatusCode', label: '재직상태',   codeGroup: 'EMPSTATUS' },
                { key: 'deptCode',      label: '부서',       codeGroup: 'DEPT'      },
                { key: 'gradeCode',     label: '직급',       codeGroup: 'RANK'      },
                { key: 'authorityCode', label: '권한',       codeGroup: 'AUTHORITY' },
            ];

            return records.map(record => {
                const rows = FIELDS
                    .filter(f => record[f.key] !== undefined && record[f.key] !== null && record[f.key] !== '')
                    .map(f => {
                        const raw = String(record[f.key]);
                        let name = raw;

                        if (f.codeGroup && this.commonCodeMap[f.codeGroup]) {
                            name = this.commonCodeMap[f.codeGroup][raw] || raw;
                        }

                        return {
                            label: f.label,
                            code:  raw,
                            name:  name,
                            // code와 name이 같으면(미매핑) code만 표시
                            showBoth: name !== raw,
                        };
                    });

                return { empId: record.empId || '-', rows };
            });
        },

        // 엑셀 다운로드
        excelDownload() {
            const { actorEmpId, actorName, targetMenu, result, actionType, startDate, endDate } = this.searchParams;
            const qs = new URLSearchParams({ actorEmpId, actorName, targetMenu, result, actionType, startDate, endDate });
            location.href = '/api/activity-log/excel/download?' + qs;
        },
    }
});