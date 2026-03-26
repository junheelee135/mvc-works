<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC - 설문 결과</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/surveyResult.css?v=2" type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
<style>[v-cloak] { display: none; }</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
    <div id="vue-app" v-cloak>

        <div v-if="store.loading" style="text-align:center;padding:60px;color:#9aa0b4;">
            결과를 불러오는 중...
        </div>

        <div v-else>

            <button class="btn-back" @click="goList">
                <i class="fas fa-arrow-left"></i> 설문 목록
            </button>

            <div class="result-header">
                <h4>{{ store.survey.title }}</h4>
                <div class="result-meta">
                    <span><i class="far fa-calendar"></i> {{ store.survey.startDate || '-' }} ~ {{ store.survey.endDate || '-' }}</span>
                    <span><i class="fas fa-users"></i> 총 응답: <strong class="response-count">{{ store.responseCount }}명</strong></span>
                    <span><i class="fas fa-user-secret"></i> {{ store.survey.anonymousYn === 'Y' ? '익명' : '실명' }}</span>
                    <span>
                        <i class="fas fa-circle" :style="{ color: store.survey.status === 'ACTIVE' ? '#1a9660' : '#9aa0b4', fontSize: '8px' }"></i>
                        {{ store.survey.status === 'ACTIVE' ? '진행중' : '마감' }}
                    </span>
                </div>
            </div>

            <div v-if="store.files.length > 0" style="background:#f8f9fb;border-radius:8px;padding:14px 18px;margin-bottom:20px;">
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

            <div v-if="store.responseCount === 0" class="no-response">
                <i class="fas fa-chart-bar" style="font-size:36px;margin-bottom:12px;display:block;"></i>
                아직 응답이 없습니다.
            </div>

            <div class="result-card" v-for="(stat, si) in store.stats" :key="si">
                <div class="q-title">Q{{ si + 1 }}. {{ stat.question.questionText }}</div>
                <span class="q-type-badge" :class="stat.question.questionType">{{ typeName(stat.question.questionType) }}</span>

                <div v-if="stat.question.questionType === 'SINGLE' || stat.question.questionType === 'MULTI'" class="bar-chart">
                    <div class="bar-item" v-for="opt in stat.options" :key="opt.optionId">
                        <span class="bar-label">{{ opt.optionText }}</span>
                        <div class="bar-track">
                            <div class="bar-fill" :style="{ width: store.percent(opt.selectCount) + '%' }"></div>
                        </div>
                        <span class="bar-value">{{ opt.selectCount }}표 ({{ store.percent(opt.selectCount) }}%)</span>
                    </div>
                </div>

                <div v-if="stat.question.questionType === 'TEXT'" class="text-answers">
                    <div v-if="!stat.textAnswers || stat.textAnswers.length === 0" style="color:#9aa0b4;font-size:13px;">
                        텍스트 응답이 없습니다.
                    </div>
                    <div class="text-answer-item" v-for="(txt, ti) in stat.textAnswers" :key="ti">
                        {{ txt.answerText }}
                    </div>
                </div>

                <div v-if="stat.question.questionType === 'SCORE'" class="score-result">
                    <div>
                        <div class="score-big">{{ stat.avgScore ? stat.avgScore.toFixed(1) : '0.0' }}</div>
                        <div class="score-label">/ 5.0점</div>
                    </div>
                    <div>
                        <div class="score-stars">
                            <span v-for="(s, idx) in store.starArray(stat.avgScore || 0)" :key="idx"
                                  :class="s === 'filled' ? 'star-filled' : 'star-empty'">&#9733;</span>
                        </div>
                        <div class="score-label" style="margin-top:4px;">{{ store.responseCount }}명 응답</div>
                    </div>
                </div>
            </div>

        </div>

    </div>
</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
    "imports": {
        "http": "${pageContext.request.contextPath}/dist/util/http.js",
        "surveyResultStore": "${pageContext.request.contextPath}/dist/util/store/surveyResultStore.js?v=3"
    }
}
</script>

<script type="module">
import { createApp, ref, onMounted } from 'vue';
import { createPinia } from 'pinia';
import { useSurveyResultStore } from 'surveyResultStore';

const app = createApp({
    setup() {
        const store = useSurveyResultStore();

        // URL에서 surveyId 추출
        const params = new URLSearchParams(location.search);
        const surveyId = Number(params.get('surveyId'));

        const ctx = document.querySelector('meta[name="ctx"]').content;

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

        onMounted(() => {
            if (surveyId) {
                store.fetchResult(surveyId);
            }
        });

        return { store, ctx, typeName, formatFileSize, goList };
    }
});

app.use(createPinia());
app.mount('#vue-app');
</script>
