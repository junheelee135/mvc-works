<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC - 설문 응답</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/surveyRespond.css?v=2" type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
<style>[v-cloak] { display: none; }</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
    <div id="vue-app" v-cloak>

        <div v-if="store.loading" style="text-align:center;padding:60px;color:#9aa0b4;">
            설문을 불러오는 중...
        </div>

        <div v-else-if="!store.isTarget" class="respond-done">
            <div class="done-icon"><i class="fas fa-ban"></i></div>
            <h3>응답 권한이 없습니다</h3>
            <p>이 설문의 대상자가 아닙니다.</p>
            <button class="btn-back" style="margin-top:20px;" @click="goList">
                <i class="fas fa-arrow-left"></i> 목록으로
            </button>
        </div>

        <div v-else-if="store.responded" class="respond-done">
            <div class="done-icon"><i class="fas fa-check-circle"></i></div>
            <h3>이미 응답을 완료했습니다</h3>
            <p>해당 설문에 대한 응답이 이미 제출되었습니다.</p>
            <button class="btn-back" style="margin-top:20px;" @click="goList">
                <i class="fas fa-arrow-left"></i> 목록으로
            </button>
        </div>

        <div v-else-if="periodBlock === 'before'" class="respond-done">
            <div class="done-icon" style="color:#6366f1;"><i class="fas fa-clock"></i></div>
            <h3>아직 응답 기간이 아닙니다</h3>
            <p>이 설문은 {{ store.survey.startDate }}부터 응답할 수 있습니다.</p>
            <button class="btn-back" style="margin-top:20px;" @click="goList">
                <i class="fas fa-arrow-left"></i> 목록으로
            </button>
        </div>

        <div v-else-if="periodBlock === 'after'" class="respond-done">
            <div class="done-icon" style="color:#ef4444;"><i class="fas fa-clock"></i></div>
            <h3>응답 기간이 종료되었습니다</h3>
            <p>이 설문의 응답 가능 기간이 지났습니다.</p>
            <button class="btn-back" style="margin-top:20px;" @click="goList">
                <i class="fas fa-arrow-left"></i> 목록으로
            </button>
        </div>

        <div v-else>

            <button class="btn-back" @click="goList">
                <i class="fas fa-arrow-left"></i> 설문 목록
            </button>

            <div class="respond-header">
                <h4>{{ store.survey.title }}</h4>
                <p class="respond-desc" v-if="store.survey.description">{{ store.survey.description }}</p>
                <div class="respond-meta">
                    <span><i class="far fa-calendar"></i> {{ store.survey.startDate || '-' }} ~ {{ store.survey.endDate || '-' }}</span>
                    <span><i class="fas fa-user-secret"></i> {{ store.survey.anonymousYn === 'Y' ? '익명 설문' : '실명 설문' }}</span>
                    <span><i class="fas fa-list-ol"></i> 총 {{ store.questions.length }}개 질문</span>
                </div>
            </div>

            <div v-if="store.files.length > 0" class="respond-files" style="background:#f8f9fb;border-radius:8px;padding:14px 18px;margin-bottom:20px;">
                <div style="font-weight:600;font-size:13px;color:#1d2939;margin-bottom:8px;">
                    <i class="fas fa-paperclip"></i> 첨부파일 ({{ store.files.length }})
                </div>
                <div v-for="f in store.files" :key="f.fileId" style="display:flex;align-items:center;gap:8px;margin-bottom:4px;">
                    <a :href="ctx + '/api/survey/file/' + f.fileId" style="color:#4b7bec;text-decoration:none;font-size:13px;">
                        <i class="fas fa-download" style="margin-right:4px;"></i>{{ f.oriFilename }}
                    </a>
                    <span style="color:#9aa0b4;font-size:12px;">({{ formatFileSize(f.fileSize) }})</span>
                </div>
            </div>

            <div class="respond-question" v-for="(q, qi) in store.questions" :key="q.questionId">
                <div class="q-label">Q{{ qi + 1 }}. {{ q.questionText }}</div>
                <span class="q-type-badge" :class="q.questionType">{{ typeName(q.questionType) }}</span>

                <div v-if="q.questionType === 'SINGLE'" class="respond-options">
                    <div class="respond-option"
                         v-for="opt in q.options" :key="opt.optionId"
                         :class="{ selected: store.answers[q.questionId] === opt.optionId }"
                         @click="store.answers[q.questionId] = opt.optionId">
                        <input type="radio" :name="'q_' + q.questionId"
                               :value="opt.optionId"
                               v-model="store.answers[q.questionId]">
                        <label>{{ opt.optionText }}</label>
                    </div>
                </div>

                <div v-if="q.questionType === 'MULTI'" class="respond-options">
                    <div class="respond-option"
                         v-for="opt in q.options" :key="opt.optionId"
                         :class="{ selected: store.answers[q.questionId] && store.answers[q.questionId].includes(opt.optionId) }"
                         @click="store.toggleMulti(q.questionId, opt.optionId)">
                        <input type="checkbox"
                               :checked="store.answers[q.questionId] && store.answers[q.questionId].includes(opt.optionId)">
                        <label>{{ opt.optionText }}</label>
                    </div>
                </div>

                <div v-if="q.questionType === 'TEXT'">
                    <textarea class="respond-textarea"
                              v-model="store.answers[q.questionId]"
                              placeholder="답변을 입력해주세요"></textarea>
                </div>

                <div v-if="q.questionType === 'SCORE'">
                    <div class="respond-score">
                        <button class="score-btn" v-for="n in 5" :key="n"
                                :class="{ selected: store.answers[q.questionId] === n }"
                                @click="store.answers[q.questionId] = n">{{ n }}</button>
                    </div>
                    <div class="score-labels">
                        <span>매우 불만족</span>
                        <span>매우 만족</span>
                    </div>
                </div>
            </div>

            <div class="respond-footer">
                <button class="btn-submit" @click="doSubmit">응답 제출</button>
            </div>

        </div>

    </div>
</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
    "imports": {
        "http": "${pageContext.request.contextPath}/dist/util/http.js",
        "surveyRespondStore": "${pageContext.request.contextPath}/dist/util/store/surveyRespondStore.js?v=3"
    }
}
</script>

<script type="module">
import { createApp, ref, computed, onMounted } from 'vue';
import { createPinia } from 'pinia';
import { useSurveyRespondStore } from 'surveyRespondStore';

const app = createApp({
    setup() {
        const store = useSurveyRespondStore();

        // URL에서 surveyId 추출
        const params = new URLSearchParams(location.search);
        const surveyId = Number(params.get('surveyId'));

        const ctx = document.querySelector('meta[name="ctx"]').content;

        // 기간 체크: 'before' | 'after' | null
        const periodBlock = computed(() => {
            const s = store.survey;
            if (!s || !s.surveyId) return null;
            const today = new Date().toISOString().slice(0, 10);
            if (s.startDate && today < s.startDate) return 'before';
            if (s.endDate && today > s.endDate) return 'after';
            return null;
        });

        // 질문유형 한글
        function typeName(code) {
            const map = { 'SINGLE': '단일선택', 'MULTI': '복수선택', 'TEXT': '서술형', 'SCORE': '점수형' };
            return map[code] || code;
        }

        // 파일 크기 포맷
        function formatFileSize(bytes) {
            if (bytes < 1024) return bytes + ' B';
            if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
            return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
        }

        // 목록으로
        function goList() {
            location.href = ctx + '/survey/list';
        }

        // 응답 제출
        async function doSubmit() {
            if (!confirm('응답을 제출하시겠습니까? 제출 후에는 수정할 수 없습니다.')) return;
            const ok = await store.submitResponse(surveyId);
            if (ok) {
                alert('응답이 제출되었습니다.');
            }
        }

        onMounted(() => {
            if (surveyId) {
                store.fetchSurvey(surveyId);
            }
        });

        return { store, ctx, periodBlock, typeName, formatFileSize, goList, doSubmit };
    }
});

app.use(createPinia());
app.mount('#vue-app');
</script>
