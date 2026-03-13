/* ============================================================
   reportList.js
   보고서 목록(탭) 전용 스크립트
   경로: /dist/js/reportList.js
   ============================================================ */

/**
 * 탭 전환
 * @param {string} activeTabId     - 활성화할 탭 버튼 id
 * @param {string} activeContentId - 활성화할 탭 콘텐츠 id
 */
function rpSwitchTab(activeTabId, activeContentId) {
    document.querySelectorAll('.rp-tab-item').forEach(function (btn) {
        btn.classList.remove('active');
    });
    document.querySelectorAll('.rp-tab-content').forEach(function (content) {
        content.classList.remove('active');
    });
    document.getElementById(activeTabId).classList.add('active');
    document.getElementById(activeContentId).classList.add('active');
}

/**
 * 검색 폼 초기화 후 재조회
 * @param {string} formId - 초기화할 폼 id
 */
function rpResetForm(formId) {
    var form   = document.getElementById(formId);
    var inputs = form.querySelectorAll('input:not([type="hidden"]), select');
    inputs.forEach(function (el) { el.value = ''; });
    form.submit();
}
