<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<!-- 기본 정보 -->
<div class="form-section">
    <div class="form-section-header">
        <div class="form-section-title">
            <span class="material-symbols-outlined">info</span>
            기본 정보
        </div>
    </div>
    <div class="form-section-body">
        <div class="info-grid">
            <div class="form-field">
                <label>문서번호</label>
                <input type="text" value="자동으로 생성됩니다" readonly>
            </div>
            <div class="form-field">
                <label>작성일</label>
                <input type="text" :value="todayDate" readonly>
            </div>
            <div class="form-field">
                <label>작성자</label>
                <sec:authentication property="principal.member.deptName" var="deptName"/>
                <sec:authentication property="principal.member.name" var="memberName"/>
                <sec:authentication property="principal.member.gradeName" var="gradeName"/>
                <input type="text" value="${deptName} | ${memberName} ${gradeName}" readonly>
            </div>
        </div>
    </div>
</div>