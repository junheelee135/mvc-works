<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<div class="al-wrapper">
    <div class="al-content">
        <div class="al-main">
            <!-- 타이틀 -->
            <div class="al-page-title">
                <i class="bi bi-clock-history al-title-icon"></i>
                <h2>활동내역</h2>
                <i class="bi bi-question-circle al-help-icon" title="도움말"></i>
            </div>
            <!-- 검색 필터 -->
            <div class="al-filter-card">
                <div class="al-filter-row">
                    <div class="al-filter-group">
                        <label>사원번호</label>
                        <input type="text" 
                        	   v-model="store.searchParams.actorEmpId"
                               placeholder="사원번호 입력"
                               @keyup.enter="store.search()"/>
                    </div>
                    <div class="al-filter-group">
                        <label>이름</label>
                        <input type="text"
                         	   v-model="store.searchParams.actorName"
                               placeholder="이름 입력" 
                               @keyup.enter="store.search()"/>
                    </div>
                    <div class="al-filter-group">
                        <label>메뉴</label>
                        <input type="text" 
                        	   v-model="store.searchParams.targetMenu"
                               placeholder="메뉴 입력"
                               @keyup.enter="store.search()"/>
                    </div>
                    <div class="al-filter-group">
                        <label>처리결과</label>
                        <select v-model="store.searchParams.result"
                        		@change="store.search()">
                            <option value="">전체</option>
                            <option value="SUCCESS">SUCCESS</option>
                            <option value="FAIL">FAIL</option>
                        </select>
                    </div>
                    <div class="al-filter-group">
                        <label>작업유형</label>
                        <select v-model="store.searchParams.actionType"
                        		@change="store.search()">
                            <option value="">전체</option>
                            <option value="INSERT">등록</option>
                            <option value="UPDATE">수정</option>
                            <option value="DELETE">삭제</option>
                            <option value="BULK_UPDATE">일괄수정</option>
                            <option value="EXCEL_IMPORT">엑셀 업로드</option>
                        </select>
                    </div>
                    <div class="al-filter-group">
                        <label>로그일(시작)</label>
                        <input type="date" 
                        	   v-model="store.searchParams.startDate"
                               @change="store.search()">
                    </div>
                    <div class="al-filter-group">
                        <label>로그일(종료)</label>
                        <input type="date" 
                        	   v-model="store.searchParams.endDate"
                               @change="store.search()">
                    </div>
                    <div class="al-filter-btns">
                        <button class="al-btn al-btn-search" 
                        		@click="store.search()">
                            <i class="bi bi-search"></i> 검색
                        </button>
                        <button class="al-btn al-btn-reset" 
                        		@click="store.resetSearch()">
                            <i class="bi bi-arrow-counterclockwise"></i> 초기화
                        </button>
                    </div>
                </div>
            </div>
            <!-- 검색 필터 끝 -->

            <div class="al-toolbar">
                <div class="al-toolbar-left">
                    전체 <strong class="mx-1">{{ store.pageInfo.totalCount }}</strong>건
                </div>
                <div class="al-toolbar-right">
                    <button class="al-btn al-btn-excel-down" 
                    		@click="store.excelDownload()">
                        <i class="bi bi-file-earmark-arrow-down"></i> 엑셀 다운로드
                    </button>
                </div>
            </div>

            <!-- 컨텐츠 -->
            <div class="al-table-card">
                <div style="overflow-x:auto;">
                    <table class="al-table">
                        <thead>
                            <tr>
                                <th>순번</th>
                                <th class="sortable" 
                                	@click="store.sortBy('logId')">
                                    로그ID
                                    <span class="sort-icons" :class="store.getSortClass('logId')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th class="sortable" 
                                	@click="store.sortBy('actorEmpId')">
                                    사원번호
                                    <span class="sort-icons" :class="store.getSortClass('actorEmpId')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th class="sortable"
                                	@click="store.sortBy('actorName')">
                                    이름
                                    <span class="sort-icons" :class="store.getSortClass('actorName')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th class="sortable" 
                                	@click="store.sortBy('actionType')">
                                    작업유형
                                    <span class="sort-icons" :class="store.getSortClass('actionType')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th class="sortable" 
                                	@click="store.sortBy('targetMenu')">
                                    메뉴
                                    <span class="sort-icons" :class="store.getSortClass('targetMenu')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th>대상 사원</th>
                                <th class="sortable" 
                                	@click="store.sortBy('result')">
                                    처리결과
                                    <span class="sort-icons" :class="store.getSortClass('result')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th>접속 IP</th>
                                <th class="sortable" 
                                	@click="store.sortBy('logDate')">
                                    로그일시
                                    <span class="sort-icons" :class="store.getSortClass('logDate')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th>상세</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-if="store.loading">
                                <td colspan="11" class="al-empty-cell">
                                    <i class="bi bi-arrow-repeat" style="animation:spin 1s linear infinite;"></i>
                                    &nbsp;불러오는 중...
                                </td>
                            </tr>
                            <tr v-else-if="store.list.length === 0">
                                <td colspan="11" class="al-empty-cell">
                                    조회된 활동내역이 없습니다.
                                </td>
                            </tr>
                            <tr v-else
                                v-for="(log, index) in store.list"
                                :key="log.logId"
                                :class="{ 'al-row-fail': log.result === 'FAIL' }">

                                <!-- 순번 -->
                                <td class="text-center">{{ store.getRowNo(index) }}</td>

                                <!-- 로그ID -->
                                <td class="text-center al-log-id">{{ log.logId }}</td>

                                <!-- 사원번호 -->
                                <td class="text-center">{{ log.actorEmpId }}</td>

                                <!-- 이름 -->
                                <td class="text-center">{{ log.actorName || '-' }}</td>

                                <!-- 작업유형 -->
                                <td class="text-center">
                                    <span class="al-action-badge"
                                          :class="{
                                              'al-action-insert' : log.actionType === 'INSERT',
                                              'al-action-update' : log.actionType === 'UPDATE',
                                              'al-action-delete' : log.actionType === 'DELETE',
                                              'al-action-bulk'   : log.actionType === 'BULK_UPDATE',
                                              'al-action-excel'  : log.actionType === 'EXCEL_IMPORT'
                                          }">
                                        {{ store.actionLabel(log.actionType) }}
                                    </span>
                                </td>
                                <td class="text-center">{{ log.targetMenu || '-' }}</td>
                                <td class="al-target-cell">
                                    <span v-if="log.targetEmpIds" :title="log.targetEmpIds">
                                        {{ log.targetEmpIds.length > 30
                                            ? log.targetEmpIds.substring(0, 30) + '...'
                                            : log.targetEmpIds }}
                                    </span>
                                    <span v-else class="al-dash">-</span>
                                </td>
                                <td class="text-center">
                                    <span class="al-result-badge"
                                          :class="{
                                              'al-result-success': log.result === 'SUCCESS',
                                              'al-result-fail':    log.result === 'FAIL'
                                          }">
                                        <span class="al-dot"></span>
                                        {{ log.result }}
                                    </span>
                                </td>

                                <!-- 접속 IP -->
                                <td class="text-center al-ip-cell">{{ log.ipAddr || '-' }}</td>

                                <!-- 로그일시 -->
                                <td class="text-center al-date-cell">{{ log.logDate || '-' }}</td>

                                <!-- 상세 보기 -->
                                <td class="text-center">
                                    <button class="al-btn-detail"
                                            @click="store.openDetail(log)"
                                            title="변경 내용 상세 보기">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </td>

                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- 페이징 처리 -->
                <div class="al-pagination" v-if="store.pagination">
                    <div>총 <strong>{{ store.pageInfo.totalCount }}</strong>건
                         / {{ store.pageInfo.totalPage }} 페이지</div>
                    <div class="al-pagination-pages">

                        <!-- 첫 페이지 -->
                        <a class="al-page-btn" :class="{ disabled: !store.pagination.showPrev }"
                           @click="store.pagination.showPrev && store.fetchList(store.pagination.firstPage)">
                            <i class="bi bi-chevron-double-left"></i>
                        </a>

                        <!-- 이전 페이지 -->
                        <a class="al-page-btn" :class="{ disabled: !store.pagination.showPrev }"
                           @click="store.pagination.prevBlockPage && store.fetchList(store.pagination.prevBlockPage)">
                            <i class="bi bi-chevron-left"></i>
                        </a>

                        <!-- 페이지 번호 -->
                        <a v-for="p in store.pagination.pages" :key="p"
                           class="al-page-btn" :class="{ active: store.searchParams.page === p }"
                           @click="store.fetchList(p)">
                            {{ p }}
                        </a>

                        <!-- 다음 페이지 -->
                        <a class="al-page-btn" :class="{ disabled: !store.pagination.showNext }"
                           @click="store.pagination.nextBlockPage && store.fetchList(store.pagination.nextBlockPage)">
                            <i class="bi bi-chevron-right"></i>
                        </a>

                        <!-- 마지막 페이지 -->
                        <a class="al-page-btn" :class="{ disabled: !store.pagination.showNext }"
                           @click="store.pagination.showNext && store.fetchList(store.pagination.lastPage)">
                            <i class="bi bi-chevron-double-right"></i>
                        </a>

                    </div>
                </div>

            </div>
            <!-- 컨텐츠 끝 -->
        </div>
    </div>
</div>

<!-- 상세 보기 모달 창 -->
<div class="al-modal-overlay" 
	 v-if="store.showDetail" 
	 @click.self="store.closeDetail()">
    <div class="al-modal" 
    	 v-if="store.detailItem">
        <div class="al-modal-header">
            <span><i class="bi bi-clock-history"></i> 활동 상세</span>
            <button class="al-modal-close" @click="store.closeDetail()">
                <i class="bi bi-x-lg"></i>
            </button>
        </div>
        <div class="al-modal-body">

            <!-- 기본 정보 -->
            <table class="al-detail-table">
                <tbody>
                    <tr>
                        <th>로그 ID</th>
                        <td>{{ store.detailItem.logId }}</td>
                        <th>로그일시</th>
                        <td>{{ store.detailItem.logDate }}</td>
                    </tr>
                    <tr>
                        <th>수행자 사원번호</th>
                        <td>{{ store.detailItem.actorEmpId }}</td>
                        <th>수행자 이름</th>
                        <td>{{ store.detailItem.actorName || '-' }}</td>
                    </tr>
                    <tr>
                        <th>작업유형</th>
                        <td>
                            <span class="al-action-badge"
                                  :class="{
                                      'al-action-insert' : store.detailItem.actionType === 'INSERT',
                                      'al-action-update' : store.detailItem.actionType === 'UPDATE',
                                      'al-action-delete' : store.detailItem.actionType === 'DELETE',
                                      'al-action-bulk'   : store.detailItem.actionType === 'BULK_UPDATE',
                                      'al-action-excel'  : store.detailItem.actionType === 'EXCEL_IMPORT'
                                  }">
                                {{ store.actionLabel(store.detailItem.actionType) }}
                            </span>
                        </td>
                        <th>메뉴</th>
                        <td>{{ store.detailItem.targetMenu || '-' }}</td>
                    </tr>
                    <tr>
                        <th>대상 사원번호</th>
                        <td colspan="3">{{ store.detailItem.targetEmpIds || '-' }}</td>
                    </tr>
                    <tr>
                        <th>처리결과</th>
                        <td>
                            <span class="al-result-badge"
                                  :class="{
                                      'al-result-success': store.detailItem.result === 'SUCCESS',
                                      'al-result-fail':    store.detailItem.result === 'FAIL'
                                  }">
                                <span class="al-dot"></span>
                                {{ store.detailItem.result }}
                            </span>
                        </td>
                        <th>접속 IP</th>
                        <td>{{ store.detailItem.ipAddr || '-' }}</td>
                    </tr>
                    <tr v-if="store.detailItem.errorMsg">
                        <th>오류 메시지</th>
                        <td colspan="3" class="al-error-msg">{{ store.detailItem.errorMsg }}</td>
                    </tr>
                </tbody>
            </table>

            <!-- 변경 전 / 후 데이터 -->
            <div class="al-diff-wrap">

                <!-- 변경 전 -->
                <div class="al-diff-panel">
                    <div class="al-diff-title">
                        <i class="bi bi-arrow-left-circle"></i> 변경 전
                    </div>

                    <!-- 데이터 없음 -->
                    <div v-if="!store.parseEmployeeData(store.detailItem.beforeData)"
                         class="al-diff-empty">-</div>

                    <!-- 단건 또는 복수 레코드 -->
                    <template v-else
                              v-for="(record, rIdx) in store.parseEmployeeData(store.detailItem.beforeData)"
                              :key="rIdx">
                        <!-- 복수 레코드일 때 사원번호 소제목 -->
                        <div v-if="store.parseEmployeeData(store.detailItem.beforeData).length > 1"
                             class="al-diff-record-title">
                            사원번호: {{ record.empId }}
                        </div>
                        <table class="al-diff-table al-before-table">
                            <tbody>
                                <tr v-for="row in record.rows" :key="row.label">
                                    <th class="al-diff-th">{{ row.label }}</th>
                                    <td class="al-diff-td">
                                        <!-- 코드명이 있으면 "이름 (코드)" 형태로, 없으면 값만 표시 -->
                                        <span v-if="row.showBoth">
                                            {{ row.name }}
                                            <span class="al-diff-code">({{ row.code }})</span>
                                        </span>
                                        <span v-else>{{ row.code }}</span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </template>
                </div>

                <!-- 변경 후 -->
                <div class="al-diff-panel">
                    <div class="al-diff-title">
                        <i class="bi bi-arrow-right-circle"></i> 변경 후
                    </div>

                    <!-- 데이터 없음 -->
                    <div v-if="!store.parseEmployeeData(store.detailItem.afterData)"
                         class="al-diff-empty">-</div>

                    <!-- 단건 또는 복수 레코드 -->
                    <template v-else
                              v-for="(record, rIdx) in store.parseEmployeeData(store.detailItem.afterData)"
                              :key="rIdx">
                        <div v-if="store.parseEmployeeData(store.detailItem.afterData).length > 1"
                             class="al-diff-record-title">
                            사원번호: {{ record.empId }}
                        </div>
                        <table class="al-diff-table al-after-table">
                            <tbody>
                                <tr v-for="row in record.rows" :key="row.label">
                                    <th class="al-diff-th">{{ row.label }}</th>
                                    <td class="al-diff-td">
                                        <span v-if="row.showBoth">
                                            {{ row.name }}
                                            <span class="al-diff-code">({{ row.code }})</span>
                                        </span>
                                        <span v-else>{{ row.code }}</span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </template>
                </div>

            </div>
        </div>
        <div class="al-modal-footer">
            <button class="al-btn al-btn-reset" @click="store.closeDetail()">닫기</button>
        </div>
    </div>
</div>
