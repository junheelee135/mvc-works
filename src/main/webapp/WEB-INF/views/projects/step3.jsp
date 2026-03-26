<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<div class="mb-5">
    <h2 class="fw-bold fs-3">Project 팀 구성</h2>
    <p class="text-muted">Project 팀원들의 역할을 설정하세요.</p>
</div>

<div class="card-custom">
    <div class="section-title"><i class="fas fa-user-tag me-2"></i>Team Project Member</div>

    <div class="member-list" id="step3MemberList">
        <p class="text-muted">선택된 멤버가 없습니다. 이전 단계에서 멤버를 추가하세요.</p>
    </div>
</div>


<script type="text/javascript">
document.addEventListener('click', function (e) {
    // 드롭다운 항목 선택
    const item = e.target.closest('.dropdown-menu li');
    if (item) {
        const dropdown    = item.closest('.custom-dropdown');
        const displayArea = dropdown.querySelector('.selected-value');
        const hiddenInput = dropdown.querySelector('.role-input');

        if (hiddenInput && item.getAttribute('data-code') === 'M') {
            const empId     = hiddenInput.dataset.empId;
            const dataMap   = window.__memberDataMap || {};
            const gradeCode = (dataMap[empId] || {}).gradeCode || '';
            const gradeName = (dataMap[empId] || {}).grade || '';
            if (window.getRankNum && window.getRankNum(gradeCode) < 5) {
                const name = (dataMap[empId] || {}).name || empId;
                window.toast(name + '님은 ' + gradeName + ' 직급으로 매니저를 맡을 수 없습니다.(매니저 차장 이상부터 가능)');
                return;
            }
        }
        
        displayArea.innerHTML = '<span class="status-dot"></span>' + item.getAttribute('data-label');
        displayArea.className = 'selected-value ' + item.getAttribute('data-class');

        // hidden input에 역할 코드 저장 (M / D / P / S)
        if (hiddenInput) {
            hiddenInput.value = item.getAttribute('data-code');
        }

        dropdown.querySelector('.dropdown-menu').style.display = 'none';
        return;
    }

    // 드롭다운 열기/닫기
    const selectedBtn = e.target.closest('.selected-value');
    if (selectedBtn) {
        const menu   = selectedBtn.nextElementSibling;
        const isOpen = menu.style.display === 'block';
        document.querySelectorAll('.dropdown-menu').forEach(m => m.style.display = 'none');
        menu.style.display = isOpen ? 'none' : 'block';
        e.stopPropagation();
    } else {
        document.querySelectorAll('.dropdown-menu').forEach(m => m.style.display = 'none');
    }
});
</script>
