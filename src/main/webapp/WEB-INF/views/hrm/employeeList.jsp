<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<div class="emp-wrapper">
    <div class="emp-content">
        <div class="emp-main">
            <div class="emp-page-title">
                <i class="bi bi-people-fill emp-title-icon"></i>
                <h2>직원관리</h2>
                <i class="bi bi-question-circle emp-help-icon" title="도움말"></i>
            </div>

            <div class="emp-filter-card">
                <div class="emp-filter-row">
                    <div class="emp-filter-group">
                        <label>이름</label>
                        <input type="text" 
                        	   v-model="store.searchParams.name"
                               placeholder="이름 입력" 
                               @keyup.enter="store.search()">
                    </div>
                    <div class="emp-filter-group">
                        <label>사원번호</label>
                        <input type="text"
                        	   v-model="store.searchParams.empNo"
                               placeholder="사원번호 입력" 
                               @keyup.enter="store.search()">
                    </div>
                    <div class="emp-filter-group" style="min-width:160px;">
                        <label>참여 프로젝트</label>
                        <input type="text" v-model="store.searchParams.project"
                               placeholder="프로젝트명 입력" 
                               @keyup.enter="store.search()">
                    </div>
                    <div class="emp-filter-group">
                        <label>부서</label>
                        <select v-model="store.searchParams.deptCode" 
                        		@change="store.search()">
                            <option value="">전체</option>
                            <option v-for="d in store.deptOptions"
                                    :key="d.CODE" :value="d.CODE">
                                {{ d.CODENAME }}
                            </option>
                        </select>
                    </div>
                    <div class="emp-filter-group">
                        <label>직급</label>
                        <select v-model="store.searchParams.gradeCode" 
                        		@change="store.search()">
                            <option value="">전체</option>
                            <option v-for="g in store.gradeOptions"
                                    :key="g.CODE" :value="g.CODE">
                                {{ g.CODENAME }}
                            </option>
                        </select>
                    </div>
                    <div class="emp-filter-group">
                        <label>재직상태</label>
                        <select v-model="store.searchParams.empStatusCode" 
                        		@change="store.search()">
                            <option value="">전체</option>
                            <option v-for="s in store.statusOptions"
                                    :key="s.CODE" :value="s.CODE">
                                {{ s.CODENAME }}
                            </option>
                        </select>
                    </div>
                    <div class="emp-filter-group" style="min-width:150px;">
                        <label>권한등급</label>
                        <select v-model="store.searchParams.authorityCode" 
                        		@change="store.search()">
                            <option value="">전체</option>
                            <option v-for="lv in store.authorityOptions"
                                    :key="lv.CODE" :value="lv.CODE">
                                {{ lv.CODENAME }}
                            </option>
                        </select>
                    </div>
                    <div class="emp-filter-group">
                        <label>권한레벨</label>
                        <input type="text" 
                        	   v-model="store.searchParams.levelCode"
                               placeholder="권한레벨 입력" 
                               @keyup.enter="store.search()">
                    </div>
                    <div class="emp-filter-check-group">
                        <label class="group-label">PMO</label>
                        <div class="emp-check-items">
                            <label class="emp-check-item">
                                <input type="radio" 
                                	   name="pmoFilter" 
                                	   value="Y"
                                       :checked="store.searchParams.pmoY"
                                       @change="store.setPmoFilter('Y')"> Y
                            </label>
                            <label class="emp-check-item">
                                <input type="radio" 
                                	   name="pmoFilter" 
                                	   value="N"
                                       :checked="store.searchParams.pmoN"
                                       @change="store.setPmoFilter('N')"> N
                            </label>
                            <label class="emp-check-item">
                                <input type="radio" 
                                	   name="pmoFilter" 
                                	   value=""
                                       :checked="!store.searchParams.pmoY && !store.searchParams.pmoN"
                                       @change="store.setPmoFilter('')"> 전체
                            </label>
                        </div>
                    </div>
                    <div class="emp-filter-btns">
                        <button class="emp-btn emp-btn-search" @click="store.search()">
                            <i class="bi bi-search"></i> 검색
                        </button>
                    </div>
                </div>
            </div>
            <div class="emp-toolbar">
                <div class="emp-toolbar-left">
                    전체 <strong class="mx-1">{{ store.pageInfo.totalCount }}</strong>건
                </div>
                <div class="emp-toolbar-right">
                    <button class="emp-btn emp-btn-add"
                    		@click="store.addRow()">
                        <i class="bi bi-plus-lg"></i> 행 추가
                    </button>
                    <button class="emp-btn emp-btn-save"
                    		@click="store.saveRows()">
                        <i class="bi bi-floppy"></i> 저장
                    </button>
                    <button class="emp-btn emp-btn-delete"
                    		@click="store.deleteSelected()">
                        <i class="bi bi-trash3"></i> 삭제
                    </button>
                    <button class="emp-btn emp-btn-cancel"
                    		@click="store.cancelEdit()">
                        <i class="bi bi-x-lg"></i> 취소
                    </button>
                    <button class="emp-btn emp-btn-excel-down" 
                    		@click="store.excelDownload()">
                        <i class="bi bi-file-earmark-arrow-down"></i> 엑셀 다운로드
                    </button>
                    <button class="emp-btn emp-btn-excel-template"
                    		@click="store.excelTemplateDownload()">
                        <i class="bi bi-file-earmark-ruled"></i> 엑셀 양식 다운로드
                    </button>
                    <button class="emp-btn emp-btn-excel-up"
                    		@click="store.triggerExcelUpload()">
                        <i class="bi bi-file-earmark-arrow-up"></i> 엑셀 업로드
                    </button>
                    <input type="file" 
                    	   accept=".xlsx,.xls"
                           style="display:none;" 
                           @change="store.excelUpload($event)">
                </div>
            </div>

            <!-- 컨텐츠 -->
            <div class="emp-table-card">
                <div style="overflow-x:auto;">
                    <table class="emp-table">
                        <thead>
                            <tr>
                                <th class="col-chk">
                                    <input type="checkbox"
                                           :checked="store.isAllChecked"
                                           :indeterminate="store.isIndeterminate"
                                           @change="store.toggleAll($event.target.checked)">
                                </th>
                                <th>순번</th>
                                <th class="sortable" 
                                	@click="store.sortBy('name')">
                                    이름
                                    <span class="sort-icons" :class="store.getSortClass('name')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th class="sortable" 
                                	@click="store.sortBy('empNo')">
                                    사원번호
                                    <span class="sort-icons" :class="store.getSortClass('empNo')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th>비밀번호</th>
                                <th>참여 프로젝트</th>
                                <th class="sortable" 
                                	@click="store.sortBy('dept')">
                                    부서
                                    <span class="sort-icons" :class="store.getSortClass('dept')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th class="sortable" 
                                	@click="store.sortBy('rank')">
                                    직급
                                    <span class="sort-icons" :class="store.getSortClass('rank')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                                <th>권한</th>
                                <th>레벨</th>
                                <th class="sortable" 
                                	@click="store.sortBy('status')">
                                    재직상태
                                    <span class="sort-icons" :class="store.getSortClass('status')">
                                        <i class="bi bi-caret-up-fill"></i>
                                        <i class="bi bi-caret-down-fill"></i>
                                    </span>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-if="store.loading">
                                <td colspan="11" style="text-align:center; padding:30px; color:#94a3b8;">
                                    <i class="bi bi-arrow-repeat" style="animation:spin 1s linear infinite;"></i>
                                    &nbsp;불러오는 중...
                                </td>
                            </tr>
                            <tr v-else-if="store.list.length === 0">
                                <td colspan="11" style="text-align:center; padding:30px; color:#94a3b8;">
                                    조회된 직원 정보가 없습니다.
                                </td>
                            </tr>
                            <tr v-else
                                v-for="(emp, index) in store.list"
                                :key="emp.empId || emp._tempId"
                                :class="{ selected: emp._checked, editing: emp._editing, dirty: emp._dirty }"
                                @dblclick="store.activateRowEdit(emp)">
                                <td class="col-chk">
                                    <input type="checkbox"
                                           :checked="emp._checked"
                                           @change="store.toggleRow(emp, $event.target.checked)"
                                           @click.stop>
                                </td>
                                <td>
                                    <template v-if="emp._isNew">-</template>
                                    <template v-else>{{ store.getRowNo(index) }}</template>
                                </td>
                                <td :class="emp._isNew ? 'emp-editable' : 'emp-readonly'">
                                    <div class="emp-name-cell">
                                        <img v-if="emp.profilePhoto"
                                             :src="emp.profilePhoto"
                                             class="emp-avatar"
                                             onerror="this.onerror=null;this.src='/dist/images/avatar.png';">
                                        <span v-else class="emp-avatar-placeholder">
                                            <i class="bi bi-person"></i>
                                        </span>
                                        <input v-if="emp._isNew"
                                               type="text" v-model="emp.name"
                                               placeholder="이름"
                                               class="emp-edit-input"
                                               style="width:80px;"
                                               @click.stop>
                                        <span v-else>{{ emp.name }}</span>
                                    </div>
                                </td>
                                <td class="emp-readonly">
                                    <span>{{ emp.empId }}</span>
                                </td>
                                <td class="emp-editable" @dblclick.stop="store.activateRowEdit(emp)">
                                    <%-- 비밀번호 필수 입력 --%>
                                    <input v-if="emp._isNew"
                                           type="password" v-model="emp.password"
                                           placeholder="비밀번호"
                                           class="emp-edit-input"
                                           style="width:110px;"
                                           autocomplete="new-password"
                                           @click.stop>
                                    <%-- 수정 : 빈 값이면 기존 유지 --%>
                                    <input v-else-if="emp._editing"
                                           type="password" v-model="emp.password"
                                           placeholder="변경 시 입력"
                                           class="emp-edit-input"
                                           style="width:110px;"
                                           autocomplete="new-password"
                                           @input="store.markDirty(emp)"
                                           @click.stop>
                                    <%-- 조회 : 마스킹 --%>
                                    <span v-else class="emp-pw-mask">{{ emp.password }}</span>
                                </td>

                                <!-- 참여 프로젝트 : 등록, 수정 불가 -->
                                <td class="emp-readonly">
                                    <span v-if="emp._isNew" style="color:#94a3b8;font-size:0.8rem;">자동 연동</span>
                                    <span v-else>{{ emp.projectNames || '-' }}</span>
                                </td>

                                <!-- 부서코드 -->
                                <td class="emp-editable" 
                                	@dblclick.stop="store.activateRowEdit(emp)">
                                    <select v-if="emp._editing || emp._isNew" 
                                    		class="emp-edit-select"
                                            v-model="emp.deptCode"
                                            @change="store.onDeptChange(emp)" @click.stop>
                                        <option value="">（없음）</option>
                                        <option v-for="d in store.deptOptions" :key="d.CODE" :value="d.CODE">{{ d.CODENAME }}</option>
                                    </select>
                                    <span v-else>{{ emp.deptName || emp.deptCode || '-' }}</span>
                                </td>

                                <!-- 직급코드 -->
                                <td class="emp-editable" 
                                	@dblclick.stop="store.activateRowEdit(emp)">
                                    <select v-if="emp._editing || emp._isNew" 
                                    		class="emp-edit-select"
                                            v-model="emp.gradeCode"
                                            @change="store.onGradeChange(emp)" @click.stop>
                                        <option value="">（없음）</option>
                                        <option v-for="g in store.gradeOptions" :key="g.CODE" :value="g.CODE">{{ g.CODENAME }}</option>
                                    </select>
                                    <span v-else>{{ emp.gradeName || emp.gradeCode || '-' }}</span>
                                </td>

                                <!-- 권한 -->
                                <td class="emp-editable" 
                                	@dblclick.stop="store.activateRowEdit(emp)">
                                    <select v-if="emp._editing || emp._isNew" 
                                    		class="emp-edit-select"
                                            v-model="emp.authorityCode"
                                            @change="store.onAuthorityChange(emp)" @click.stop>
                                        <option value="">（없음）</option>
                                        <option v-for="l in store.authorityOptions" :key="l.CODE" :value="l.CODE">{{ l.CODENAME }}</option>
                                    </select>
                                    <span v-else>{{ emp.authorityName || emp.authorityCode || '-' }}</span>
                                </td>

                                <!-- 레벨 -->
                                <td class="emp-editable" 
                                	@dblclick.stop="store.activateRowEdit(emp)">
                                    <input v-if="emp._editing || emp._isNew"
                                           type="number" 
                                           v-model.number="emp.levelCode"
                                           class="emp-edit-input"
                                           style="width:60px; text-align:center;"
                                           min="1" max="99"
                                           @input="store.markDirty(emp)" @click.stop>
                                    <span v-else>{{ emp.levelCode != null ? emp.levelCode : '-' }}</span>
                                </td>

                                <!-- 재직상태 -->
                                <td class="emp-editable" 
                                	@dblclick.stop="store.activateRowEdit(emp)">
                                    <select v-if="emp._editing || emp._isNew" 
                                    		class="emp-edit-select"
                                            v-model="emp.empStatusCode"
                                            @change="store.markDirty(emp)" @click.stop>
                                        <option value="">（없음）</option>
                                        <option v-for="s in store.statusOptions"
                                                :key="s.CODE" :value="s.CODE">
                                            {{ s.CODENAME }}
                                        </option>
                                    </select>
                                    <template v-else>
                                        <span class="emp-status-badge"
                                              :class="{
                                                  'emp-status-employed'  : emp.empStatusCode === 'ES01',
                                                  'emp-status-leave'     : emp.empStatusCode === 'ES02',
                                                  'emp-status-resigned'  : emp.empStatusCode === 'ES03',
                                                  'emp-status-terminated': emp.empStatusCode === 'ES04'
                                              }">
                                            <span class="emp-dot"></span>
                                            {{ store.statusLabel(emp.empStatusCode) }}
                                        </span>
                                    </template>
                                </td>

                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- 페이징 처리 -->
                <div class="emp-pagination" v-if="store.pagination">
                    <div>총 <strong>{{ store.pageInfo.totalCount }}</strong>건
                         / {{ store.pageInfo.totalPage }} 페이지</div>
                    <div class="emp-pagination-pages">

                        <%-- 첫 페이지 --%>
                        <a class="emp-page-btn" :class="{ disabled: !store.pagination.showPrev }"
                           @click="store.pagination.showPrev && store.fetchList(store.pagination.firstPage)">
                            <i class="bi bi-chevron-double-left"></i>
                        </a>

                        <%-- 이전 페이지 --%>
                        <a class="emp-page-btn" :class="{ disabled: !store.pagination.showPrev }"
                           @click="store.pagination.prevBlockPage && store.fetchList(store.pagination.prevBlockPage)">
                            <i class="bi bi-chevron-left"></i>
                        </a>

                        <%-- 페이지 번호 --%>
                        <a v-for="p in store.pagination.pages" :key="p"
                           class="emp-page-btn" :class="{ active: store.searchParams.page === p }"
                           @click="store.fetchList(p)">
                            {{ p }}
                        </a>

                        <%-- 다음 페이지 --%>
                        <a class="emp-page-btn" :class="{ disabled: !store.pagination.showNext }"
                           @click="store.pagination.nextBlockPage && store.fetchList(store.pagination.nextBlockPage)">
                            <i class="bi bi-chevron-right"></i>
                        </a>

                        <%-- 마지막 페이지 --%>
                        <a class="emp-page-btn" :class="{ disabled: !store.pagination.showNext }"
                           @click="store.pagination.showNext && store.fetchList(store.pagination.lastPage)">
                            <i class="bi bi-chevron-double-right"></i>
                        </a>

                    </div>
                </div>

            </div>

        </div>
    </div>
</div>
