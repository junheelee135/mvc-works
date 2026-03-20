import { defineStore } from 'pinia';
import { ref } from 'vue';
import http from 'http';

export const useSurveyRespondStore = defineStore('surveyRespond', () => {

    // ── state ──
    const survey = ref({});
    const questions = ref([]);
    const answers = ref({});       // { questionId: 값 } 형태
    const files = ref([]);         // 첨부파일 목록
    const loading = ref(false);
    const responded = ref(false);  // 이미 응답했는지
    const isTarget = ref(false);   // 대상자인지

    // ── 설문 + 응답여부 조회 ──
    async function fetchSurvey(surveyId) {
        loading.value = true;
        try {
            // 설문 상세
            const detailRes = await http.get('/survey/' + surveyId);
            survey.value = detailRes.data.survey;
            questions.value = detailRes.data.questions || [];
            files.value = detailRes.data.files || [];

            // 응답여부 + 대상자 확인
            const checkRes = await http.get('/survey/' + surveyId + '/check');
            responded.value = checkRes.data.responded;
            isTarget.value = checkRes.data.isTarget;

            // 답변 초기값 세팅
            initAnswers();
        } catch (e) {
            console.error('설문 조회 실패:', e);
        } finally {
            loading.value = false;
        }
    }

    // ── 답변 초기값 ──
    function initAnswers() {
        const init = {};
        questions.value.forEach(q => {
            switch (q.questionType) {
                case 'SINGLE':
                    init[q.questionId] = null;        // optionId 하나
                    break;
                case 'MULTI':
                    init[q.questionId] = [];           // optionId 배열
                    break;
                case 'TEXT':
                    init[q.questionId] = '';            // 텍스트
                    break;
                case 'SCORE':
                    init[q.questionId] = null;          // 1~5
                    break;
            }
        });
        answers.value = init;
    }

    // ── MULTI 체크박스 토글 ──
    function toggleMulti(questionId, optionId) {
        const arr = answers.value[questionId];
        const idx = arr.indexOf(optionId);
        if (idx === -1) {
            arr.push(optionId);
        } else {
            arr.splice(idx, 1);
        }
    }

    // ── 응답 제출 ──
    async function submitResponse(surveyId) {
        // answers → SurveyAnswerDto 배열로 변환
        const answerList = [];

        questions.value.forEach(q => {
            const val = answers.value[q.questionId];

            switch (q.questionType) {
                case 'SINGLE':
                    if (val) {
                        answerList.push({ questionId: q.questionId, optionId: val });
                    }
                    break;
                case 'MULTI':
                    if (val && val.length > 0) {
                        val.forEach(optId => {
                            answerList.push({ questionId: q.questionId, optionId: optId });
                        });
                    }
                    break;
                case 'TEXT':
                    if (val && val.trim()) {
                        answerList.push({ questionId: q.questionId, answerText: val.trim() });
                    }
                    break;
                case 'SCORE':
                    if (val) {
                        answerList.push({ questionId: q.questionId, scoreValue: val });
                    }
                    break;
            }
        });

        try {
            await http.post('/survey/' + surveyId + '/respond', {
                answers: answerList
            });
            responded.value = true;
            return true;
        } catch (e) {
            console.error('응답 제출 실패:', e);
            return false;
        }
    }

    return {
        survey, questions, answers, files, loading, responded, isTarget,
        fetchSurvey, toggleMulti, submitResponse
    };
});