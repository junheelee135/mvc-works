<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>


<input type="hidden" name="projectType" id="projectType" value="T">
<input type="hidden" name="pmoType" id="pmoType" value="S">
<div class="mb-5">
    <h2 class="section-title">Project type</h2>
    <p class="section-desc">먼저 프로젝트의 타입을 선택해 주세요.</p>

    <div class="select-card" onclick="selectOnlyOne(event.currentTarget, 'projectType', 'I')">
        <div class="icon-box"><i class="fas fa-user"></i></div>
        <div class="card-content">
            <div class="title">Personal Project</div>
            <div class="desc">개인적인 업무 관리 및 트래킹을 위한 프로젝트입니다.</div>
        </div>
        <i class="fas fa-check-circle check-mark"></i>
    </div>

    <div class="select-card" onclick="selectOnlyOne(event.currentTarget, 'projectType', 'T')">
        <div class="icon-box"><i class="fas fa-users"></i></div>
        <div class="card-content">
            <div class="title">Team Project</div>
            <div class="desc">팀원들과 협업하고 역할을 분담하는 프로젝트입니다.</div>
        </div>
        <i class="fas fa-check-circle check-mark"></i>
    </div>
</div>

<div class="mb-5">
    <h2 class="section-title">Project manage</h2>
    <p class="section-desc">프로젝트를 관리할 수 있는 권한을 설정합니다.</p>

    <div class="select-card" onclick="selectOnlyOne(event.currentTarget, 'pmoType', 'S')">
        <div class="icon-box"><i class="fas fa-user-shield"></i></div>
        <div class="card-content">
            <div class="title">Select Specific Managers</div>
            <div class="desc">지정된 관리자만 프로젝트 설정 권한을 가집니다.</div>
        </div>
        <i class="fas fa-check-circle check-mark"></i>
    </div>
</div>

<script type="text/javascript">
function selectOnlyOne(element, inputId, value) {
    // 비활성화된 카드는 클릭 무시
    if (element.classList.contains('disabled')) return;

    const parentSection = element.parentElement;
    parentSection.querySelectorAll('.select-card').forEach(card => {
        card.classList.remove('selected');
    });
    element.classList.add('selected');
    document.getElementById(inputId).value = value;

    // projectType 변경 시 pmoType 카드 비활성/활성 처리
    if (inputId === 'projectType') {
        const pmoSection = document.querySelectorAll('#step-panel-1 .mb-5');
        // mb-5 섹션 중 두 번째가 pmoType 섹션
        const pmoCards = pmoSection.length >= 2
            ? pmoSection[1].querySelectorAll('.select-card')
            : [];

        if (value === 'I') {
            // 개인 프로젝트: pmoType 카드 비활성화 + 선택 해제 + 값 초기화
            pmoCards.forEach(card => {
                card.classList.add('disabled');
                card.classList.remove('selected');
            });
            document.getElementById('pmoType').value = '';
        } else {
            // 팀 프로젝트: pmoType 카드 다시 활성화
            pmoCards.forEach(card => card.classList.remove('disabled'));
        }
    }
}
</script>