import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import http from 'http';

export const useSurveyResultStore = defineStore('surveyResult', () => {

    // ── state ──
    const survey = ref({});
    const responseCount = ref(0);
    const stats = ref([]);         // [ { question, options/textAnswers/avgScore }, ... ]
    const files = ref([]);         // 첨부파일 목록
    const loading = ref(false);

    // ── 결과 조회 ──
    async function fetchResult(surveyId) {
        loading.value = true;
        try {
            const res = await http.get('/survey/' + surveyId + '/result');
            survey.value = res.data.survey;
            responseCount.value = res.data.responseCount || 0;
            stats.value = res.data.stats || [];
            files.value = res.data.files || [];
        } catch (e) {
            console.error('결과 조회 실패:', e);
        } finally {
            loading.value = false;
        }
    }

    // ── 선택형 질문의 최대 응답 수 (막대 차트 비율 계산용) ──
    function maxCount(options) {
        if (!options || options.length === 0) return 1;
        const max = Math.max(...options.map(o => o.selectCount));
        return max > 0 ? max : 1;
    }

    // ── 선택형 질문의 퍼센트 계산 ──
    function percent(selectCount) {
        if (responseCount.value === 0) return 0;
        return Math.round((selectCount / responseCount.value) * 100);
    }

    // ── 점수를 별 배열로 변환 (★★★☆☆) ──
    function starArray(avgScore) {
        const rounded = Math.round(avgScore);
        const arr = [];
        for (let i = 1; i <= 5; i++) {
            arr.push(i <= rounded ? 'filled' : 'empty');
        }
        return arr;
    }

    return {
        survey, responseCount, stats, files, loading,
        fetchResult, maxCount, percent, starArray
    };
});