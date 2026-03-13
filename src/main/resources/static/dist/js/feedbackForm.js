/* ============================================================
   feedbackForm.js
   피드백 작성 / 수정 공통 스크립트
   경로: /dist/js/feedbackForm.js
   ============================================================ */

/**
 * 인사평가 배지 업데이트
 * @param {string} value - 'POSITIVE' | 'NORMAL' | 'NEGATIVE'
 */
function rpUpdateEvalBadge(value) {
    var badge = document.getElementById('evalBadge');
    var map = {
        'POSITIVE': '<span class="rp-eval-badge rp-eval-positive">긍정 (우수)</span>',
        'NORMAL':   '<span class="rp-eval-badge rp-eval-normal">평범 (보통)</span>',
        'NEGATIVE': '<span class="rp-eval-badge rp-eval-negative">부정 (미흡)</span>'
    };
    badge.innerHTML = map[value] || '';
}

/**
 * 기존 첨부파일 삭제 표시
 * @param {HTMLElement} btn   - 삭제 버튼 요소
 * @param {number}      fileid - 삭제할 filenum
 */
function rpRemoveFile(btn, fileid) {
    if (confirm('첨부파일을 삭제하시겠습니까?')) {
        var li = btn.closest('li');
        li.querySelector('.del-fnum').value = fileid;
        li.style.textDecoration = 'line-through';
        li.style.opacity = '0.4';
        btn.disabled = true;
    }
}

/**
 * 파일 첨부 개수·크기 검사
 * @param {HTMLInputElement} input - 파일 input 요소
 */
function rpCheckFileCount(input) {
    if (input.files.length > 5) {
        alert('파일은 최대 5개까지 첨부 가능합니다.');
        input.value = '';
        return;
    }
    for (var i = 0; i < input.files.length; i++) {
        if (input.files[i].size > 10 * 1024 * 1024) {
            alert('파일 크기는 최대 10MB까지 가능합니다.\n(' + input.files[i].name + ')');
            input.value = '';
            return;
        }
    }
}

/**
 * 피드백 작성 폼 유효성 검사 후 제출
 * quillFeedback 인스턴스는 JSP 인라인에서 전역으로 선언되어야 합니다.
 */
function rpSubmitFeedback() {
    var subject = document.getElementById('feedbackSubject').value.trim();
    if (!subject) {
        alert('피드백 제목을 입력해 주세요.');
        document.getElementById('feedbackSubject').focus();
        return;
    }
    var evaluation = document.getElementById('evaluation').value;
    if (!evaluation) {
        alert('인사평가 항목을 선택해 주세요.');
        document.getElementById('evaluation').focus();
        return;
    }
    var content = quillFeedback.root.innerHTML;
    if (!content || content === '<p><br></p>') {
        alert('피드백 내용을 입력해 주세요.');
        return;
    }
    document.getElementById('hiddenFeedbackContent').value = content;
    document.getElementById('feedbackWriteForm').submit();
}

/**
 * 피드백 수정 폼 유효성 검사 후 제출
 * quillFeedback 인스턴스는 JSP 인라인에서 전역으로 선언되어야 합니다.
 */
function rpSubmitFeedbackEdit() {
    var subject = document.getElementById('feedbackSubject').value.trim();
    if (!subject) {
        alert('피드백 제목을 입력해 주세요.');
        document.getElementById('feedbackSubject').focus();
        return;
    }
    var evaluation = document.getElementById('evaluation').value;
    if (!evaluation) {
        alert('인사평가 항목을 선택해 주세요.');
        document.getElementById('evaluation').focus();
        return;
    }
    var content = quillFeedback.root.innerHTML;
    if (!content || content === '<p><br></p>') {
        alert('피드백 내용을 입력해 주세요.');
        return;
    }
    document.getElementById('hiddenFeedbackContent').value = content;
    document.getElementById('feedbackEditForm').submit();
}
