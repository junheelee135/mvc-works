/* ============================================================
   reportForm.js
   보고서 작성 / 수정 공통 스크립트
   경로: /dist/js/reportForm.js
   ============================================================ */

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
 * 기존 첨부파일 삭제 표시 (수정 화면)
 * @param {HTMLElement} btn    - 삭제 버튼 요소
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
 * 보고서 작성 폼 유효성 검사 후 제출
 * quillReport 인스턴스는 JSP 인라인에서 전역으로 선언되어야 합니다.
 */
function rpSubmitWrite() {
    var subject = document.getElementById('subject').value.trim();
    if (!subject) {
        alert('제목을 입력해 주세요.');
        document.getElementById('subject').focus();
        return;
    }
    var periodStart = document.getElementById('periodStart').value;
    var periodEnd   = document.getElementById('periodEnd').value;
    if (!periodStart || !periodEnd) {
        alert('보고 기간을 입력해 주세요.');
        return;
    }
    if (periodStart > periodEnd) {
        alert('보고 기간 시작일이 종료일보다 늦을 수 없습니다.');
        return;
    }
    var content = quillReport.root.innerHTML;
    if (!content || content === '<p><br></p>') {
        alert('보고 내용을 입력해 주세요.');
        return;
    }
    document.getElementById('hiddenContent').value = content;
    document.getElementById('reportWriteForm').submit();
}

/**
 * 보고서 수정 폼 유효성 검사 후 제출
 * quillReport 인스턴스는 JSP 인라인에서 전역으로 선언되어야 합니다.
 */
function rpSubmitEdit() {
    var subject = document.getElementById('subject').value.trim();
    if (!subject) {
        alert('제목을 입력해 주세요.');
        document.getElementById('subject').focus();
        return;
    }
    var periodStart = document.getElementById('periodStart').value;
    var periodEnd   = document.getElementById('periodEnd').value;
    if (!periodStart || !periodEnd) {
        alert('보고 기간을 입력해 주세요.');
        return;
    }
    if (periodStart > periodEnd) {
        alert('보고 기간 시작일이 종료일보다 늦을 수 없습니다.');
        return;
    }
    var content = quillReport.root.innerHTML;
    if (!content || content === '<p><br></p>') {
        alert('보고 내용을 입력해 주세요.');
        return;
    }
    document.getElementById('hiddenContent').value = content;
    document.getElementById('reportEditForm').submit();
}
