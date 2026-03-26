<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC - 설문관리</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/survey.css?v=2"
type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css"
type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
<meta name="userLevel" content="${sessionScope.member.userLevel}">
<style>[v-cloak] { display: none; }</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
    <div id="vue-app" v-cloak>

        <div v-if="viewMode === 'list'">

            <div class="survey-header">
                <h4>설문 관리</h4>
                <div class="btn-group" v-if="isAdmin">
                    <button class="btn-primary" @click="goCreate">
                        <span class="material-symbols-outlined" style="font-size:16px;vertical-align:middle;">add</span>
                        새 설문 만들기
                    </button>
                </div>
            </div>

            <div class="survey-searchbar">
                <select v-model="store.statusFilter" @change="store.search()">
                    <option value="">전체 상태</option>
                    <option value="DRAFT">임시저장</option>
                    <option value="ACTIVE">진행중</option>
                    <option value="CLOSED">마감</option>
                </select>
                <input type="text" v-model="store.keyword" placeholder="제목 검색"
                       @keyup.enter="store.search()">
                <button class="btn-primary" @click="store.search()">
                    <span class="material-symbols-outlined" style="font-size:16px;vertical-align:middle;">search</span>
                    검색
                </button>
            </div>

            <table class="survey-table">
                <thead>
                    <tr>
                        <th style="width:50px;text-align:center;">No.</th>
                        <th style="width:250px;">제목</th>
                        <th style="width:80px;text-align:center;">상태</th>
                        <th style="width:60px;text-align:center;">익명</th>
                        <th style="width:70px;text-align:right;">질문수</th>
                        <th style="width:70px;text-align:right;">응답수</th>
                        <th style="width:100px;text-align:center;">시작일</th>
                        <th style="width:100px;text-align:center;">종료일</th>
                        <th style="width:80px;">작성자</th>
                        <th style="width:100px;text-align:center;">작성일</th>
                        <th style="width:90px;text-align:center;">동작</th>
                        <th style="width:80px;text-align:center;">결과</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-if="store.list.length === 0">
                        <td colspan="12" style="text-align:center;padding:40px;color:#9aa0b4;">
                            등록된 설문이 없습니다.
                        </td>
                    </tr>
                    <tr v-for="(item, index) in store.list" :key="item.surveyId">
                        <td style="text-align:center;">{{ store.totalCount - ((store.pageNo - 1) * store.pageSize) - index }}</td>
                        <td style="cursor:pointer;" @click="goDetail(item)">{{ item.title }}</td>
                        <td style="text-align:center;"><span class="survey-status" :class="item.status">{{ statusName(item.status) }}</span></td>
                        <td style="text-align:center;">{{ item.anonymousYn === 'Y' ? '익명' : '실명' }}</td>
                        <td style="text-align:right;">{{ item.questionCount }}</td>
                        <td style="text-align:right;">{{ item.responseCount }}</td>
                        <td style="text-align:center;">{{ item.startDate || '-' }}</td>
                        <td style="text-align:center;">{{ item.endDate || '-' }}</td>
                        <td>{{ item.writerName }}</td>
                        <td style="text-align:center;">{{ item.regDate }}</td>
                        <td style="text-align:center;" @click.stop>
                            <button v-if="item.status === 'ACTIVE' && isInPeriod(item) && item.respondedYn !== 'Y'"
                                    class="btn-action respond" @click="goRespond(item.surveyId)">응답</button>
                            <span v-if="item.respondedYn === 'Y' && item.status === 'ACTIVE'"
                                  style="display:inline-block;padding:2px 10px;border-radius:12px;background:#d1fae5;color:#065f46;font-size:12px;font-weight:600;">완료</span>
                            <span v-if="item.status === 'ACTIVE' && periodStatus(item) === 'before' && item.respondedYn !== 'Y'"
                                  style="display:inline-block;padding:2px 10px;border-radius:12px;background:#e0e7ff;color:#3730a3;font-size:12px;font-weight:600;">시작전</span>
                            <span v-if="item.status === 'ACTIVE' && periodStatus(item) === 'after' && item.respondedYn !== 'Y'"
                                  style="display:inline-block;padding:2px 10px;border-radius:12px;background:#fee2e2;color:#991b1b;font-size:12px;font-weight:600;">기간종료</span>
                        </td>
                        <td style="text-align:center;" @click.stop>
                            <button v-if="isAdmin ? item.status !== 'DRAFT' : item.status === 'CLOSED'"
                                    class="btn-action result" @click="goResult(item.surveyId)">결과</button>
                        </td>
                    </tr>
                </tbody>
            </table>

            <div class="table-pagination" v-if="store.totalPages > 1">
                <button class="page-btn" :disabled="store.pageNo <= 1" @click="store.goPage(1)">&laquo; 처음</button>
                <button class="page-btn" :disabled="store.pageNo <= 1" @click="store.goPage(store.pageNo - 1)">&lsaquo; 이전</button>
                <button class="page-btn" v-for="p in store.totalPages" :key="p"
                        :class="{ active: p === store.pageNo }" @click="store.goPage(p)">{{ p }}</button>
                <button class="page-btn" :disabled="store.pageNo >= store.totalPages" @click="store.goPage(store.pageNo + 1)">다음 &rsaquo;</button>
                <button class="page-btn" :disabled="store.pageNo >= store.totalPages" @click="store.goPage(store.totalPages)">마지막 &raquo;</button>
            </div>

        </div>

        <div v-if="isAdmin && (viewMode === 'create' || viewMode === 'edit')">

            <div class="survey-header">
                <h4>{{ viewMode === 'create' ? '새 설문 만들기' : '설문 수정' }}</h4>
                <div class="btn-group">
                    <button class="btn-secondary" @click="goList">목록으로</button>
                    <button class="btn-danger" v-if="viewMode === 'edit'" @click="doDelete">삭제</button>
                    <button class="btn-success" v-if="viewMode === 'edit' && store.form.status === 'DRAFT'" @click="doPublish">배포하기</button>
                    <button class="btn-warning" v-if="viewMode === 'edit' && store.form.status === 'ACTIVE'" @click="doClose"
                            style="background:#f59e0b;color:#fff;border:none;padding:6px 16px;border-radius:6px;cursor:pointer;font-size:13px;font-weight:600;">마감하기</button>
                    <button class="btn-primary" @click="doSave">저장</button>
                </div>
            </div>

            <div class="survey-form">

                <div class="form-group">
                    <label>설문 제목 *</label>
                    <input type="text" v-model="store.form.title" placeholder="설문 제목을 입력하세요">
                </div>

                <div class="form-group">
                    <label>설문 설명</label>
                    <textarea v-model="store.form.description" placeholder="설문에 대한 설명을 입력하세요"></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>시작일</label>
                        <input type="date" v-model="store.form.startDate">
                    </div>
                    <div class="form-group">
                        <label>종료일</label>
                        <input type="date" v-model="store.form.endDate">
                    </div>
                    <div class="form-group">
                        <label>익명 여부</label>
                        <select v-model="store.form.anonymousYn">
                            <option value="N">실명</option>
                            <option value="Y">익명</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label>대상자 설정</label>
                    <div class="target-input-row">
                        <select v-model="targetInput.type">
                            <option value="ALL">전체</option>
                            <option value="DEPT">부서</option>
                            <option value="EMP">개인</option>
                        </select>
                        <input type="text" v-if="targetInput.type !== 'ALL'"
                               v-model="targetInput.value"
                               :placeholder="targetInput.type === 'DEPT' ? '부서코드' : '사번'">
                        <button class="btn-primary" @click="addTarget">추가</button>
                    </div>
                    <div class="target-list">
                        <span class="target-tag" v-for="(t, i) in store.form.targets" :key="i">
                            {{ t.targetType === 'ALL' ? '전체' : (t.targetType === 'DEPT' ? '부서' : '사원') + ': ' + t.targetValue }}
                            <button class="btn-remove-target" @click="store.form.targets.splice(i, 1)">&times;</button>
                        </span>
                        <span v-if="store.form.targets.length === 0" class="target-list-empty">
                            대상자 미지정 시 전체 직원이 응답할 수 있습니다.
                        </span>
                    </div>
                </div>

                <div class="form-group">
                    <label>첨부파일</label>
                    <div>
                        <input type="file" ref="fileInput" multiple style="display:none"
                               @change="onFileSelect">
                        <button type="button" class="btn-secondary" @click="$refs.fileInput.click()">
                            <span class="material-symbols-outlined" style="font-size:16px;vertical-align:middle;">attach_file</span>
                            파일 선택
                        </button>
                    </div>
                    <div v-if="store.existingFiles.length > 0" style="margin-top:8px;">
                        <div class="file-item" v-for="(f, fi) in store.existingFiles" :key="'ex-'+fi">
                            <span class="material-symbols-outlined" style="font-size:16px;color:#4b7bec;vertical-align:middle;">description</span>
                            <span style="margin-left:4px;">{{ f.oriFilename }}</span>
                            <span style="color:#9aa0b4;margin-left:6px;">({{ store.formatFileSize(f.fileSize) }})</span>
                            <button class="btn-remove-opt" @click="store.removeExistingFile(fi)" title="삭제">
                                <span class="material-symbols-outlined" style="font-size:16px;">close</span>
                            </button>
                        </div>
                    </div>
                    <div v-if="store.attachedFiles.length > 0" style="margin-top:8px;">
                        <div class="file-item" v-for="(f, fi) in store.attachedFiles" :key="'new-'+fi">
                            <span class="material-symbols-outlined" style="font-size:16px;color:#1a9660;vertical-align:middle;">upload_file</span>
                            <span style="margin-left:4px;">{{ f.name }}</span>
                            <span style="color:#9aa0b4;margin-left:6px;">({{ store.formatFileSize(f.size) }})</span>
                            <button class="btn-remove-opt" @click="store.removeFile(fi)" title="삭제">
                                <span class="material-symbols-outlined" style="font-size:16px;">close</span>
                            </button>
                        </div>
                    </div>
                    <div v-if="store.existingFiles.length === 0 && store.attachedFiles.length === 0"
                         style="color:#9aa0b4;font-size:13px;margin-top:6px;">
                        첨부된 파일이 없습니다.
                    </div>
                </div>

                <hr style="border:none;border-top:1px solid #e6eaf4;margin:24px 0;">

                <label style="font-size:14px;font-weight:700;color:#1d2939;margin-bottom:12px;display:block;">
                    질문 ({{ store.form.questions.length }}개)
                </label>

                <div class="question-card" v-for="(q, qi) in store.form.questions" :key="qi">
                    <div class="question-card-header">
                        <span class="q-number">Q{{ qi + 1 }}</span>
                        <button class="btn-remove-q" @click="store.removeQuestion(qi)" title="질문 삭제">
                            <span class="material-symbols-outlined">close</span>
                        </button>
                    </div>

                    <div class="form-row" style="margin-bottom:12px;">
                        <div class="form-group" style="flex:3;margin-bottom:0;">
                            <input type="text" v-model="q.questionText" placeholder="질문을 입력하세요">
                        </div>
                        <div class="form-group" style="flex:1;margin-bottom:0;">
                            <select v-model="q.questionType" @change="onTypeChange(qi)">
                                <option value="SINGLE">단일선택</option>
                                <option value="MULTI">복수선택</option>
                                <option value="TEXT">서술형</option>
                                <option value="SCORE">점수형</option>
                            </select>
                        </div>
                    </div>

                    <div v-if="q.questionType === 'SINGLE' || q.questionType === 'MULTI'">
                        <div class="option-row" v-for="(opt, oi) in q.options" :key="oi">
                            <span style="font-size:12px;color:#9aa0b4;width:20px;">{{ oi + 1 }}.</span>
                            <input v-model="opt.optionText" placeholder="선택지를 입력하세요">
                            <button class="btn-remove-opt" @click="store.removeOption(qi, oi)" title="선택지 삭제">
                                <span class="material-symbols-outlined" style="font-size:16px;">close</span>
                            </button>
                        </div>
                        <button class="btn-add-option" @click="store.addOption(qi)">+ 선택지 추가</button>
                    </div>

                    <div v-if="q.questionType === 'TEXT'" class="question-type-hint">
                        <i class="fas fa-pen-to-square"></i>
                        응답자가 자유롭게 텍스트를 입력합니다.
                    </div>

                    <div v-if="q.questionType === 'SCORE'" class="question-type-hint">
                        <i class="fas fa-star"></i>
                        응답자가 1~5점을 선택합니다.
                    </div>
                </div>

                <button class="btn-add-question" @click="store.addQuestion()">+ 질문 추가</button>

            </div>
        </div>

    </div>
</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
  "imports": {
    "http": "${pageContext.request.contextPath}/dist/util/http.js",
    "surveyListStore": "${pageContext.request.contextPath}/dist/util/store/surveyListStore.js?v=5"
  }
}
</script>

<script type="module">
import { createApp, ref, computed, onMounted, nextTick } from 'vue';
import { createPinia } from 'pinia';
import { useSurveyListStore } from 'surveyListStore';

const app = createApp({
    /* ── Options API 껍데기 (template 은 DOM 에서 가져옴) ── */
    setup() {
        const store = useSurveyListStore();

        /* ── 관리자 여부 ── */
        const isAdmin = Number(document.querySelector('meta[name="userLevel"]').content) === 99;

        /* ── viewMode: 'list' | 'create' | 'edit' ── */
        const viewMode = ref('list');

        /* ── 화면 전환 함수 ── */
        function goList() {
            viewMode.value = 'list';
            store.resetForm();          // 폼 초기화
            store.fetchList();          // 목록 새로고침
            history.pushState({ mode: 'list' }, '', '${pageContext.request.contextPath}/survey/list');
        }

        function goCreate() {
            viewMode.value = 'create';
            store.resetForm();
            store.addQuestion();        // 빈 질문 1개 기본 추가
            history.pushState({ mode: 'create' }, '', '${pageContext.request.contextPath}/survey/list');
        }

        async function goEdit(surveyId) {
            await store.fetchDetail(surveyId);
            viewMode.value = 'edit';
            history.pushState({ mode: 'edit' }, '', '${pageContext.request.contextPath}/survey/list');
        }

        function goDetail(item) {
            if (isAdmin) {
                goEdit(item.surveyId);
            } else if (item.status === 'ACTIVE') {
                goRespond(item.surveyId);
            } else if (item.status === 'CLOSED') {
                goResult(item.surveyId);
            }
        }

        const ctx = document.querySelector('meta[name="ctx"]').content;

        function goRespond(surveyId) {
            location.href = ctx + '/survey/respond?surveyId=' + surveyId;
        }

        function goResult(surveyId) {
            location.href = ctx + '/survey/result?surveyId=' + surveyId;
        }

        /* ── 저장 (등록 / 수정 공용) ── */
        async function doSave() {
            const ok = await store.saveForm();
            if (ok) goList();
        }

        /* ── 삭제 ── */
        async function doDelete() {
            if (!confirm('정말 삭제하시겠습니까?')) return;
            const ok = await store.deleteSurvey(store.form.surveyId);
            if (ok) goList();
        }

        /* ── 상신(배포) ── */
        async function doPublish() {
            if (!confirm('설문을 배포하시겠습니까? 배포 후에는 수정할 수 없습니다.')) return;
            const ok = await store.publish(store.form.surveyId);
            if (ok) goList();
        }

        /* ── 마감 ── */
        async function doClose() {
            if (!confirm('설문을 마감하시겠습니까?')) return;
            const ok = await store.closeSurvey(store.form.surveyId);
            if (ok) goList();
        }

        /* ── 상태코드 → 한글 ── */
        function statusName(code) {
            const map = { 'DRAFT': '임시저장', 'ACTIVE': '진행중', 'CLOSED': '마감' };
            return map[code] || code;
        }

        /* ── 상태 뱃지 CSS 클래스 ── */
        function statusClass(code) {
            const map = { 'DRAFT': 'badge-draft', 'ACTIVE': 'badge-active', 'CLOSED': 'badge-closed' };
            return map[code] || '';
        }

        /* ── 기간 체크 함수 ── */
        function isInPeriod(item) {
            const today = new Date().toISOString().slice(0, 10);
            if (item.startDate && today < item.startDate) return false;
            if (item.endDate && today > item.endDate) return false;
            return true;
        }

        // 'before' = 시작 전, 'after' = 기간 종료, null = 기간 내
        function periodStatus(item) {
            const today = new Date().toISOString().slice(0, 10);
            if (item.startDate && today < item.startDate) return 'before';
            if (item.endDate && today > item.endDate) return 'after';
            return null;
        }

        /* ── 질문유형 변경 시 옵션 초기화 ── */
        function onTypeChange(qIndex) {
            const q = store.form.questions[qIndex];
            // TEXT/SCORE 유형은 옵션 불필요 → 비우기
            if (q.questionType === 'TEXT' || q.questionType === 'SCORE') {
                q.options = [];
            } else if (q.options.length === 0) {
                // SINGLE/MULTI 인데 옵션 없으면 2개 기본 추가
                store.addOption(qIndex);
                store.addOption(qIndex);
            }
        }

        /* ── 파일 선택 ── */
        const fileInput = ref(null);

        function onFileSelect(e) {
            store.addFiles(e.target.files);
            e.target.value = '';  // 같은 파일 재선택 가능하도록
        }

        /* ── 대상자 입력 상태 ── */
        const targetInput = ref({ type: 'ALL', value: '' });

        function addTarget() {
            const t = targetInput.value;
            if (t.type === 'ALL') {
                // 중복 방지
                if (!store.form.targets.some(x => x.targetType === 'ALL')) {
                    store.form.targets.push({ targetType: 'ALL', targetValue: 'ALL' });
                }
            } else {
                if (!t.value.trim()) { alert('값을 입력하세요.'); return; }
                store.form.targets.push({ targetType: t.type, targetValue: t.value.trim() });
            }
            targetInput.value = { type: 'ALL', value: '' };
        }

        /* ── 뒤로가기 처리 ── */
        window.addEventListener('popstate', (e) => {
            if (e.state && e.state.mode) {
                viewMode.value = e.state.mode;
                if (e.state.mode === 'list') {
                    store.resetForm();
                    store.fetchList();
                }
            } else {
                viewMode.value = 'list';
                store.resetForm();
                store.fetchList();
            }
        });

        /* ── 초기 로드 ── */
        onMounted(() => {
            history.replaceState({ mode: 'list' }, '', '${pageContext.request.contextPath}/survey/list');
            store.fetchList();
        });

        return {
            store, viewMode, targetInput, isAdmin,
            fileInput,
            goList, goCreate, goEdit, goDetail, goRespond, goResult,
            doSave, doDelete, doPublish, doClose,
            statusName, statusClass, isInPeriod, periodStatus,
            onTypeChange, addTarget, onFileSelect
        };
    }
});

app.use(createPinia());
app.mount('#vue-app');
</script>
