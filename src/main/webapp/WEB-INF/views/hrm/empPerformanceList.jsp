<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<div class="ep-wrapper">
    <div class="ep-content">
        <div class="ep-main">

            <!-- 페이지 타이틀 -->
            <div class="ep-page-title">
                <i class="bi bi-bar-chart-line ep-title-icon"></i>
                <h2>직원 성과 관리</h2>
                <i class="bi bi-question-circle ep-help-icon" title="도움말"></i>
            </div>

            <!-- 검색 필터 -->
            <div class="ep-filter-card">
                <div class="ep-filter-row">
                    <div class="ep-filter-group">
                        <label>사원번호</label>
                        <input type="text"
                               v-model="store.searchParams.empId"
                               placeholder="사원번호 입력"
                               @keyup.enter="store.search()"/>
                    </div>
                    <div class="ep-filter-group">
                        <label>이름</label>
                        <input type="text"
                               v-model="store.searchParams.empName"
                               placeholder="이름 입력"
                               @keyup.enter="store.search()"/>
                    </div>
                    <div class="ep-filter-group">
                        <label>부서</label>
                        <input type="text"
                               v-model="store.searchParams.deptName"
                               placeholder="부서명 입력"
                               @keyup.enter="store.search()"/>
                    </div>
                    <div class="ep-filter-group">
                        <label>직급</label>
                        <input type="text"
                               v-model="store.searchParams.gradeName"
                               placeholder="직급 입력"
                               @keyup.enter="store.search()"/>
                    </div>
                    <div class="ep-filter-group">
                        <label>참여 프로젝트</label>
                        <select v-model="store.searchParams.projectId"
						        @change="store.search()">
						    <option value="">전체</option>
						    <option v-for="project in store.projectOptions"
						            :key="project.projectId"
						            :value="project.projectId">
						        {{ project.projectName }}
						    </option>
						</select>
                    </div>
                    <div class="ep-filter-group">
                        <label>재직상태</label>
                        <select v-model="store.searchParams.empStatus"
						        @change="store.search()">
						    <option value="">전체</option>
						    <option v-for="status in store.statusOptions"
						            :key="status.code"
						            :value="status.code">
						        {{ status.codeName }}
						    </option>
						</select>
                    </div>
                    <div class="ep-filter-btns">
                        <button class="ep-btn ep-btn-search"
                                @click="store.search()">
                            <i class="bi bi-search"></i> 검색
                        </button>
                        <button class="ep-btn ep-btn-reset"
                                @click="store.resetSearch()">
                            <i class="bi bi-arrow-counterclockwise"></i> 초기화
                        </button>
                    </div>
                </div>
            </div>
            <!-- 검색 필터 끝 -->

            <!-- 툴바 -->
            <div class="ep-toolbar">
                <div class="ep-toolbar-left">
                    전체 <strong class="mx-1">{{ store.pageInfo.totalCount }}</strong>건
                </div>
                <div class="ep-toolbar-right">
                    <%-- 기능 개발 후 버튼 추가 가능 --%>
                </div>
            </div>

            <!-- 테이블 카드 -->
            <div class="ep-table-card">
                <div style="overflow-x:auto;">
                    <table class="ep-table">
                        <thead>
                            <tr>
                                <th>순번</th>
                                <th>이름</th>
                                <th>사원번호</th>
                                <th>참여 프로젝트</th>
                                <th>부서</th>
                                <th>직급</th>
                                <th>재직상태</th>
                                <th>인사평가</th>
                                <th>보고서 보기</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- 로딩 중 -->
                            <tr v-if="store.loading">
                                <td colspan="9" class="ep-empty-cell">
                                    <i class="bi bi-arrow-repeat"
                                       style="animation: spin 1s linear infinite; display:inline-block;"></i>
                                    로딩 중...
                                </td>
                            </tr>
                            <!-- 데이터 없음 -->
                            <tr v-else-if="!store.list || store.list.length === 0">
                                <td colspan="9" class="ep-empty-cell">
                                    <i class="bi bi-inbox" style="font-size:1.4rem; display:block; margin-bottom:6px;"></i>
                                    조회된 데이터가 없습니다.
                                </td>
                            </tr>
                            <!-- 데이터 행 -->
                            <tr v-else v-for="(emp, index) in store.list" :key="emp.empId">
                                <!-- 순번 -->
                                <td>{{ store.getRowNo(index) }}</td>

                                <!-- 이름 -->
                                <td>{{ emp.empName || '-' }}</td>

                                <!-- 사원번호 -->
                                <td style="font-family: monospace; font-size:0.8rem;">
                                    {{ emp.empId || '-' }}
                                </td>

                                <!-- 참여 프로젝트 -->
                                <td style="max-width:180px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                    :title="emp.projectNames">
                                    {{ emp.projectNames || '-' }}
                                </td>

                                <!-- 부서 -->
                                <td>{{ emp.deptName || '-' }}</td>

                                <!-- 직급 -->
                                <td>{{ emp.gradeName || '-' }}</td>

                                <!-- 재직상태 -->
                                <td>
                                    <span class="ep-status-badge"
                                          :class="{
                                              'ep-status-active'  : emp.empStatusCode === 'ES01',
                                              'ep-status-leave'   : emp.empStatusCode === 'ES02',
                                              'ep-status-resigned': emp.empStatusCode === 'ES03',
                                              'ep-status-false': emp.empStatusCode === 'ES04'
                                          }">
                                        {{ store.statusLabel(emp.empStatusCode) }}
                                    </span>
                                </td>

                                <!-- 인사평가 (클릭 → 모달) -->
                                <td>
                                    <button class="ep-btn-eval ep-btn-eval-default"
                                            @click="store.openEvalModal(emp)">
                                        <i class="bi bi-clipboard-data"></i> 평가 보기
                                    </button>
                                </td>

                                <!-- 보고서 보기 -->
                                <td>
                                    <a class="ep-btn-view"
									   @click="store.goToReport(emp)"
									   style="cursor:pointer;"
									   title="주간보고서 목록으로 이동">
									    <i class="bi bi-file-text"></i> 보기
									</a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- 페이지네이션 -->
                <div class="ep-pagination" v-if="store.pagination">
                    <div>총 <strong>{{ store.pageInfo.totalCount }}</strong>건
                         / {{ store.pageInfo.totalPage }} 페이지</div>
                    <div class="ep-pagination-pages">

                        <!-- 첫 페이지 -->
                        <a class="ep-page-btn"
                           :class="{ disabled: !store.pagination.showPrev }"
                           @click="store.pagination.showPrev && store.fetchList(store.pagination.firstPage)">
                            <i class="bi bi-chevron-double-left"></i>
                        </a>

                        <!-- 이전 블록 -->
                        <a class="ep-page-btn"
                           :class="{ disabled: !store.pagination.showPrev }"
                           @click="store.pagination.prevBlockPage && store.fetchList(store.pagination.prevBlockPage)">
                            <i class="bi bi-chevron-left"></i>
                        </a>

                        <!-- 페이지 번호 -->
                        <a v-for="p in store.pagination.pages" :key="p"
                           class="ep-page-btn"
                           :class="{ active: store.searchParams.page === p }"
                           @click="store.fetchList(p)">
                            {{ p }}
                        </a>

                        <!-- 다음 블록 -->
                        <a class="ep-page-btn"
                           :class="{ disabled: !store.pagination.showNext }"
                           @click="store.pagination.nextBlockPage && store.fetchList(store.pagination.nextBlockPage)">
                            <i class="bi bi-chevron-right"></i>
                        </a>

                        <!-- 마지막 페이지 -->
                        <a class="ep-page-btn"
                           :class="{ disabled: !store.pagination.showNext }"
                           @click="store.pagination.showNext && store.fetchList(store.pagination.lastPage)">
                            <i class="bi bi-chevron-double-right"></i>
                        </a>

                    </div>
                </div>
            </div>
            <!-- 테이블 카드 끝 -->

        </div>
    </div>
</div>

<!-- ================================================
     인사평가 모달
     - 연도별 월(1~12월) × 주차(1~4주) 그리드
     - 평가값: POSITIVE(우수) / NORMAL(보통) / NEGATIVE(부정) / null(미제출)
     ================================================ -->
<div class="ep-modal-overlay"
     v-if="store.showEvalModal"
     @click.self="store.closeEvalModal()">

    <div class="ep-modal" v-if="store.evalTarget">

        <!-- 모달 헤더 -->
        <div class="ep-modal-header">
            <div class="ep-modal-header-info">
                <i class="bi bi-clipboard-data" style="color: var(--accent-color); font-size:1.1rem;"></i>
                <span class="ep-modal-emp-name">{{ store.evalTarget.empName }}</span>
                <span class="ep-modal-emp-sub">
                    {{ store.evalTarget.deptName }} · {{ store.evalTarget.gradeName }} ·
                    사원번호 {{ store.evalTarget.empId }}
                </span>
            </div>
            <button class="ep-modal-close" @click="store.closeEvalModal()">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>

        <!-- 모달 바디 -->
        <div class="ep-modal-body">

            <!-- 연도 선택 + 범례 -->
            <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:8px;">
                <div style="display:flex; align-items:center; gap:8px;">
                    <label style="font-size:0.82rem; font-weight:600; color:#64748b;">조회 연도</label>
                    <select v-model="store.evalYear"
                            @change="store.fetchEvalData()"
                            style="font-size:0.85rem; padding:4px 8px; border:1px solid #cbd5e1;
                                   border-radius:5px; height:32px; color:var(--default-color);">
                        <option v-for="y in store.evalYearOptions" :key="y" :value="y">{{ y }}년</option>
                    </select>
                </div>
                <div class="ep-legend">
                    <span class="ep-legend-item">
                        <span class="ep-legend-dot" style="background:#dcfce7; border:1px solid #86efac;"></span>우수
                    </span>
                    <span class="ep-legend-item">
                        <span class="ep-legend-dot" style="background:#dbeafe; border:1px solid #93c5fd;"></span>보통
                    </span>
                    <span class="ep-legend-item">
                        <span class="ep-legend-dot" style="background:#fee2e2; border:1px solid #fca5a5;"></span>부정
                    </span>
                    <span class="ep-legend-item">
                        <span class="ep-legend-dot" style="background:#f1f5f9; border:1px solid #cbd5e1;"></span>미제출
                    </span>
                </div>
            </div>

            <!-- 요약 통계 -->
            <div class="ep-eval-summary">
                <div class="ep-summary-card">
                    <span class="ep-summary-label">우수</span>
                    <span class="ep-summary-count positive">{{ store.evalSummary.positive }}</span>
                </div>
                <div class="ep-summary-card">
                    <span class="ep-summary-label">보통</span>
                    <span class="ep-summary-count normal">{{ store.evalSummary.normal }}</span>
                </div>
                <div class="ep-summary-card">
                    <span class="ep-summary-label">부정</span>
                    <span class="ep-summary-count negative">{{ store.evalSummary.negative }}</span>
                </div>
                <div class="ep-summary-card">
                    <span class="ep-summary-label">미제출</span>
                    <span class="ep-summary-count none">{{ store.evalSummary.none }}</span>
                </div>
                <div class="ep-summary-card">
                    <span class="ep-summary-label">제출률</span>
                    <span class="ep-summary-count" style="color: var(--accent-color);">
                        {{ store.evalSummary.submitRate }}%
                    </span>
                </div>
            </div>

            <!-- 평가 그리드 테이블
                 행: 1주차 ~ 4주차
                 열: 1월 ~ 12월  -->
            <div class="ep-eval-table-wrap">
                <table class="ep-eval-table">
                    <thead>
                        <tr>
                            <th style="width:60px;">주차</th>
                            <th class="ep-th-month" v-for="m in 12" :key="m">{{ m }}월</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="week in 4" :key="week">
                            <!-- 주차 헤더 -->
                            <td class="ep-td-week">{{ week }}주</td>

                            <!-- 월별 평가값 -->
                            <td v-for="month in 12" :key="month">
                                <template v-if="store.getEval(month, week) !== null">
                                    <span class="ep-eval-chip"
                                          :class="{
                                              'ep-eval-positive': store.getEval(month, week) === 'POSITIVE',
                                              'ep-eval-normal'  : store.getEval(month, week) === 'NORMAL',
                                              'ep-eval-negative': store.getEval(month, week) === 'NEGATIVE',
                                              'ep-eval-none'    : store.getEval(month, week) === 'NONE'
                                          }">
                                        {{ store.evalLabel(store.getEval(month, week)) }}
                                    </span>
                                </template>
                                <template v-else>
                                    <!-- 해당 월에 해당 주차 자체가 없는 경우 (달력 구조상 존재 X) -->
                                    <span style="color:#e2e8f0; font-size:0.75rem;">-</span>
                                </template>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <!-- 평가 그리드 끝 -->

        </div>

        <!-- 모달 푸터 -->
        <div class="ep-modal-footer">
            <button class="ep-btn ep-btn-reset" @click="store.closeEvalModal()">닫기</button>
        </div>
    </div>
</div>
<!-- 인사평가 모달 끝 -->
