<%@ page contentType="text/html; charset=UTF-8" isELIgnored="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<div class="section-header">
    <div>
        <h2 class="fw-bold fs-3">상세 단계 설정</h2>
        <p class="text-muted">각 단계별 세부 계획을 수립하세요.</p>
    </div>
    <div>
	    <button class="btn btn-sm btn-outline-secondary fw-bold px-3" id="btnResetPhase" title="초기화">↺</button>
	    <button class="btn btn-sm btn-outline-primary fw-bold px-3" id="btnAddPhase">+</button>
	</div>
</div>

<div class="phase-container" id="phaseContainer">

    <div class="phase-card">
        <div class="phase-header">
            <div class="phase-title"><span class="phase-number">1</span> 요구사항 분석 및 기획</div>
            <button class="btn-delete" title="삭제"><i class="fas fa-minus"></i></button>
        </div>
        <div class="sub-plan-list">
        </div>
        <div class="phase-footer">
            <button class="btn-add-sub"><i class="fas fa-plus me-1"></i></button>
            <button class="btn-phase-done" title="완료"><i class="fas fa-check"></i></button>
        </div>
    </div>

    <div class="phase-card">
        <div class="phase-header">
            <div class="phase-title"><span class="phase-number">2</span> 설계 (UI/UX, 시스템)</div>
            <button class="btn-delete" title="삭제"><i class="fas fa-minus"></i></button>
        </div>
        <div class="sub-plan-list"></div>
        <div class="phase-footer">
            <button class="btn-add-sub"><i class="fas fa-plus me-1"></i></button>
            <button class="btn-phase-done" title="완료"><i class="fas fa-check"></i></button>
        </div>
    </div>

    <div class="phase-card">
        <div class="phase-header">
            <div class="phase-title"><span class="phase-number">3</span> 개발 및 구현</div>
            <button class="btn-delete" title="삭제"><i class="fas fa-minus"></i></button>
        </div>
        <div class="sub-plan-list"></div>
        <div class="phase-footer">
            <button class="btn-add-sub"><i class="fas fa-plus me-1"></i></button>
            <button class="btn-phase-done" title="완료"><i class="fas fa-check"></i></button>
        </div>
    </div>

    <div class="phase-card">
        <div class="phase-header">
            <div class="phase-title"><span class="phase-number">4</span> 테스트(단위 / 통합)</div>
            <button class="btn-delete" title="삭제"><i class="fas fa-minus"></i></button>
        </div>
        <div class="sub-plan-list"></div>
        <div class="phase-footer">
            <button class="btn-add-sub"><i class="fas fa-plus me-1"></i></button>
            <button class="btn-phase-done" title="완료"><i class="fas fa-check"></i></button>
        </div>
    </div>

    <div class="phase-card">
        <div class="phase-header">
            <div class="phase-title"><span class="phase-number">5</span> 배포(배포 / 유지보수)</div>
            <button class="btn-delete" title="삭제"><i class="fas fa-minus"></i></button>
        </div>
        <div class="sub-plan-list"></div>
        <div class="phase-footer">
            <button class="btn-add-sub"><i class="fas fa-plus me-1"></i></button>
            <button class="btn-phase-done" title="완료"><i class="fas fa-check"></i></button>
        </div>
    </div>
</div>