/* ============================================================
   feedbackDetail.js
   피드백 상세보기 전용 스크립트
   경로: /dist/js/feedbackDetail.js
   ============================================================ */

/* Quill readOnly 뷰어 초기화는 JSP 인라인에서 처리
   (content 값이 JSP EL로 주입되어야 하므로 여기서는 분리 불가)

   아래 함수만 외부 파일로 분리합니다. */

/**
 * 피드백 삭제 확인 후 이동
 * @param {number} filenum - 삭제할 피드백 filenum
 * @param {string} contextPath - Spring contextPath (JSP에서 전달)
 */
function rpConfirmFeedbackDelete(filenum, contextPath) {
    if (confirm('이 피드백을 삭제하시겠습니까?\n삭제 후 복구가 불가능합니다.')) {
        location.href = contextPath + '/report/feedback/delete?filenum=' + filenum;
    }
}
