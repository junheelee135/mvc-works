import { defineStore } from 'pinia';
import http from 'http';
import { getPagination } from 'paginate';

export const useEmpPerformanceStore = defineStore('empPerformance', {

    state: () => ({

        // ── 세션 정보 (Main.jsp에서 주입) ────────────────────────
        sessionEmpId : '',
        sessionName  : '',
        sessionLevel : 0,

        // ── 직원 목록 ────────────────────────────────────────────
        list    : [],
        loading : false,

        // ── 검색 파라미터 ─────────────────────────────────────────
        searchParams: {
            empId      : '',   // 사원번호
            empName    : '',   // 이름
            deptName   : '',   // 부서
            gradeName  : '',   // 직급
            empStatus  : '',   // 재직상태 (ES01~ES04)
            projectId  : '',   // 참여 프로젝트 ID
            page       : 1
        },

        // ── 페이지 정보 ───────────────────────────────────────────
        pageInfo: {
            totalCount : 0,
            totalPage  : 1,
            pageSize   : 10
        },
        pagination: null,

        // ── 참여 프로젝트 select 옵션 (세션 기준) ────────────────
        projectOptions: [],

        // ── 재직상태 select 옵션 (공통코드 EMPSTATUS 기준) ───────
        statusOptions: [],

        // ── 인사평가 모달 ─────────────────────────────────────────
        showEvalModal   : false,
        evalTarget      : null,    // 선택된 직원 정보
        evalYear        : null,    // 선택된 연도
        evalYearOptions : [],      // 보고서 존재 연도 목록
        evalGridMap     : {},      // { '월-주차': evaluation }
        evalLoading     : false,
    }),

    getters: {
        // ── 평가 요약 통계 ─────────────────────────────────────────
        evalSummary(state) {
            let positive = 0, normal = 0, negative = 0, none = 0, total = 0;

            for (let month = 1; month <= 12; month++) {
                for (let week = 1; week <= 4; week++) {
                    // 달력상 항상 존재하는 1~4주차 기준
                    const key = `${month}-${week}`;
                    const val = Object.prototype.hasOwnProperty.call(state.evalGridMap, key)
                        ? state.evalGridMap[key]
                        : 'NONE';

                    total++;
                    if      (val === 'POSITIVE') positive++;
                    else if (val === 'NORMAL')   normal++;
                    else if (val === 'NEGATIVE') negative++;
                    else                         none++;
                }
            }

            const submitted  = positive + normal + negative;
            const submitRate = total > 0 ? Math.round((submitted / total) * 100) : 0;
            return { positive, normal, negative, none, submitRate };
        }
    },

    actions: {

        // ════════════════════════════════════════════════════════
        //  직원 목록 조회
        // ════════════════════════════════════════════════════════
        async fetchList(page = this.searchParams.page) {
            this.loading = true;
            this.searchParams.page = page;

            try {
                const res = await http.get('/emp-performance', {
                    params: {
                        page      : this.searchParams.page,
                        pageSize  : this.pageInfo.pageSize,
                        empId     : this.searchParams.empId,
                        empName   : this.searchParams.empName,
                        deptName  : this.searchParams.deptName,
                        gradeName : this.searchParams.gradeName,
                        empStatus : this.searchParams.empStatus,
                        projectId : this.searchParams.projectId,
                    }
                });

                this.list                = res.data.list       || [];
                this.pageInfo.totalCount = res.data.totalCount || 0;
                this.pageInfo.totalPage  = res.data.totalPage  || 1;
                this.searchParams.page   = res.data.page       || 1;

                this.pagination = getPagination(
                    this.searchParams.page,
                    this.pageInfo.totalPage,
                    10
                );
            } catch (error) {
                console.error('직원 성과 목록 조회 오류:', error);
                alert('목록을 불러오는 중 오류가 발생했습니다.');
            } finally {
                this.loading = false;
            }
        },

        // ── 검색 ─────────────────────────────────────────────────
        search() {
            this.fetchList(1);
        },

        // ── 검색 조건 초기화 ──────────────────────────────────────
        resetSearch() {
            this.searchParams = {
                empId     : '',
                empName   : '',
                deptName  : '',
                gradeName : '',
                empStatus : '',
                projectId : '',
                page      : 1
            };
            this.fetchList(1);
        },

        // ── 순번 역순 계산 ────────────────────────────────────────
        getRowNo(index) {
            const offset = (this.searchParams.page - 1) * this.pageInfo.pageSize;
            return this.pageInfo.totalCount - offset - index;
        },

        // ── 재직상태 한글 라벨 (statusOptions 기반 동적 변환) ────
        //    statusOptions 로드 전 폴백: 하드코딩 맵으로 대응
        statusLabel(code) {
            if (this.statusOptions.length > 0) {
                const found = this.statusOptions.find(s => s.code === code);
                return found ? found.codeName : (code || '-');
            }
            const fallback = { ES01:'재직', ES02:'휴직', ES03:'퇴직', ES04:'계약만료' };
            return fallback[code] || code || '-';
        },

        // ── 재직상태 공통코드 로드 (EMPSTATUS)
        //    Main.jsp onMounted에서 fetchList(), fetchMyProjects()와 함께 호출
        // ════════════════════════════════════════════════════════
        async fetchEmpStatusCodes() {
            try {
                const res = await http.get('/emp-performance/status-codes');
                // Oracle resultType="map" → 컬럼명 쌍따옴표 alias로 카멜케이스 보장
                // code(value), codeName(label) 형태로 저장
                this.statusOptions = res.data || [];
            } catch (error) {
                console.error('재직상태 공통코드 조회 오류:', error);
                this.statusOptions = [];
            }
        },

        // ── 참여 프로젝트 목록 로드 (세션 empId 기준)
        //  Main.jsp onMounted에서 fetchList()와 함께 호출
        // ════════════════════════════════════════════════════════
        async fetchMyProjects() {
            try {
                const res = await http.get('/emp-performance/my-projects');
                // projectId가 DB에서 NUMBER로 반환되므로 String으로 변환
                // → v-model의 searchParams.projectId(빈 문자열 초기값)와 타입 일치
                this.projectOptions = (res.data || []).map(p => ({
                    ...p,
                    projectId: String(p.projectId)
                }));
            } catch (error) {
                console.error('소속 프로젝트 목록 조회 오류:', error);
                this.projectOptions = [];
            }
        },

        // ════════════════════════════════════════════════════════
        //  인사평가 모달 — 열기
        // ════════════════════════════════════════════════════════
        async openEvalModal(emp) {
            this.evalTarget      = emp;
            this.evalYearOptions = [];
            this.evalYear        = null;
            this.evalGridMap     = {};
            this.showEvalModal   = true;
            this.evalLoading     = true;

            try {
                // 해당 직원의 보고서 존재 연도 목록 조회
                const res = await http.get('/emp-performance/eval-years', {
                    params: { empId: emp.empId }
                });
                this.evalYearOptions = res.data || [];

                if (this.evalYearOptions.length > 0) {
                    // 가장 최근 연도 기본 선택 (내림차순 정렬 기준 첫 번째)
                    this.evalYear = this.evalYearOptions[0];
                    await this.fetchEvalData();
                }
            } catch (error) {
                console.error('평가 연도 조회 오류:', error);
            } finally {
                this.evalLoading = false;
            }
        },

        // ── 모달 닫기 ─────────────────────────────────────────────
        closeEvalModal() {
            this.showEvalModal   = false;
            this.evalTarget      = null;
            this.evalYear        = null;
            this.evalYearOptions = [];
            this.evalGridMap     = {};
        },

        // ════════════════════════════════════════════════════════
        //  인사평가 그리드 데이터 조회 (연도 변경 시 재호출)
        // ════════════════════════════════════════════════════════
        async fetchEvalData() {
            if (!this.evalTarget || !this.evalYear) return;
            this.evalLoading = true;

            try {
                const res = await http.get('/emp-performance/eval-grid', {
                    params: {
                        empId : this.evalTarget.empId,
                        year  : this.evalYear
                    }
                });

                // 배열 → { '월-주차': evaluation } Map으로 변환
                // 예: { reportMonth:3, reportWeek:2, evaluation:'POSITIVE' }
                //   → evalGridMap['3-2'] = 'POSITIVE'
                const map = {};
                (res.data || []).forEach(item => {
                    map[`${item.reportMonth}-${item.reportWeek}`] = item.evaluation;
                });
                this.evalGridMap = map;

            } catch (error) {
                console.error('평가 그리드 조회 오류:', error);
                this.evalGridMap = {};
            } finally {
                this.evalLoading = false;
            }
        },

        // ════════════════════════════════════════════════════════
        //  평가 그리드 셀 값 반환
        //
        //  반환값:
        //    'POSITIVE' | 'NORMAL' | 'NEGATIVE'  → 피드백 평가값
        //    'NONE'                               → 보고서 제출했으나 피드백 없음
        //    null                                 → 달력상 해당 주차 존재하지 않음
        //
        //  달력상 없는 주차 판별:
        //    보고서 period_start 기준으로 주차를 구분하므로
        //    해당 연도/월의 총 일수가 (week-1)*7 + 1 일 이상이어야 해당 주차가 존재
        //    예: 2월(28일) → 4주차 시작일=22일 → 22 <= 28 → 4주차 존재
        //         2월(28일) → 5주차 시작일=29일 → 29 > 28  → 5주차 없음
        //    현재 그리드는 1~4주차까지만 표시하므로 모든 달에서 4주차 존재
        // ════════════════════════════════════════════════════════
        getEval(month, week) {
            const key = `${month}-${week}`;

            // evalGridMap에 해당 키가 있으면 → 실제 평가값(POSITIVE/NORMAL/NEGATIVE/NONE)
            if (Object.prototype.hasOwnProperty.call(this.evalGridMap, key)) {
                return this.evalGridMap[key];
            }

            // 연도 미선택 또는 보고서 없는 연도: 전체 셀 NONE 처리
            if (!this.evalYear) return null;

            // 달력상 해당 월/주차가 존재하는지 확인
            // 주차 시작일: (week - 1) * 7 + 1
            const weekStartDay  = (week - 1) * 7 + 1;
            const daysInMonth   = new Date(this.evalYear, month, 0).getDate(); // 해당 월 총 일수
            if (weekStartDay > daysInMonth) {
                return null;  // 달력상 없는 주차 → '-' 표시
            }

            // 달력상 존재하나 보고서 미제출 → NONE
            return 'NONE';
        },

        // ── 평가값 한글 라벨 ──────────────────────────────────────
        evalLabel(val) {
            const map = { POSITIVE:'우수', NORMAL:'보통', NEGATIVE:'부정', NONE:'미제출' };
            return map[val] || '-';
        },

        // ════════════════════════════════════════════════════════
        //  보고서 보기 — 해당 직원의 /report/list 로 이동
        //
        //  ReportController.list() 는 현재 sessionEmpId 기준 접근 제어를 하므로
        //  다른 직원의 보고서를 보려면 writerName 검색 파라미터를 활용
        //  → /report/list?writerName={empName} 으로 이동
        //  (관리자 userLevel >= 99 는 전체 조회 가능)
        // ════════════════════════════════════════════════════════
        goToReport(emp) {
            const cp  = document.querySelector('meta[name="contextPath"]')?.content || '';
            const url = `${cp}/report/list?writerName=${encodeURIComponent(emp.empName)}`;
            window.location.href = url;
        },
    }
});