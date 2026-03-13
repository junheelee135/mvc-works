/* ============================================================
   reportDetail.js
   보고서 상세보기 전용 스크립트
   경로: /dist/js/reportDetail.js
   ============================================================ */

/**
 * 보고서 삭제 확인 후 이동
 * @param {number} filenum      - 삭제할 보고서 filenum
 * @param {string} contextPath  - Spring contextPath (JSP에서 전달)
 */
function rpConfirmDelete(filenum, contextPath) {
    if (confirm('이 보고서를 삭제하시겠습니까?\n삭제 후 복구가 불가능합니다.')) {
        location.href = contextPath + '/report/delete?filenum=' + filenum;
    }
}

/**
 * 첨부파일 드롭다운 열기/닫기 토글
 * @param {HTMLElement} btn - 토글 버튼 요소
 */
function rpToggleAttach(btn) {
    var dropdown = btn.nextElementSibling;
    var isOpen   = dropdown.style.display !== 'none';
    dropdown.style.display = isOpen ? 'none' : 'block';
}

/* 외부 클릭 시 드롭다운 닫기 */
document.addEventListener('click', function (e) {
    var wrap = e.target.closest('.rp-attach-dropdown-wrap');
    if (!wrap) {
        document.querySelectorAll('.rp-attach-dropdown').forEach(function (d) {
            d.style.display = 'none';
        });
    }
});
