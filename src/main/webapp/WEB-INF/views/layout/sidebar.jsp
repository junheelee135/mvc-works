<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<%-- sidebar 전용 참조 --%>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/main-sidebar.css">

<aside id="sidebar">
	<a href="${pageContext.request.contextPath}/home" class="sidebar-brand">
		<img src="${pageContext.request.contextPath}/dist/images/logo.png"
		alt="MVC" class="sidebar-logo">
	</a> 
	
	<a href="${pageContext.request.contextPath}/home" class="nav-link"><i
		class="fas fa-th-large"></i> 대시보드</a> <a
		href="${pageContext.request.contextPath}/projects/list"
		class="nav-link"><i class="bi bi-folder"></i> 전사 프로젝트</a>

	<%-- 예약 관리 토글 메뉴 --%>
	<a href="#" class="nav-link nav-toggle" id="meetingToggle"> <i
		class="fas fa-door-open"></i> 예약관리 <i
		class="fas fa-chevron-down toggle-icon" id="meetingArrow"></i>
	</a>
	<ul class="sub-menu" id="meetingSubMenu">
		<li><a href="${pageContext.request.contextPath}/meeting/room">회의실
				관리</a></li>
		<li><a href="${pageContext.request.contextPath}/meeting/reserve">예약
				현황</a></li>
	</ul>

	<hr />

	<%-- 그룹웨어 토글 메뉴 --%>
	<a href="#" class="nav-link nav-toggle" id="groupToggle"> <i
		class="fas fa-file-invoice"></i> 그룹웨어 <i
		class="fas fa-chevron-down toggle-icon" id="groupArrow"></i>
	</a>
	<ul class="sub-menu" id="groupSubMenu">
		<li><a href="${pageContext.request.contextPath}/report/list">주간보고서</a></li>
		<li><a href="${pageContext.request.contextPath}/chat">채팅 - 구현
				중</a></li>
	</ul>

	<%-- 인사관리 토글 메뉴 --%>
	<a href="#" class="nav-link nav-toggle" id="hrmToggle"> <i
		class="fas fa-file-signature"></i> 인사관리 <i
		class="fas fa-chevron-down toggle-icon" id="hrmArrow"></i>
	</a>
	<ul class="sub-menu" id="hrmSubMenu">
		<li><a href="${pageContext.request.contextPath}/hrm">직원 정보통합
				관리</a></li>
		<li><a href="${pageContext.request.contextPath}/">직원 조직 관리 -
				미구현</a></li>
		<li><a href="${pageContext.request.contextPath}/hrm/performance">직원
				성과 관리 - 구현 중</a></li>
		<li><a href="${pageContext.request.contextPath}/activity-log">인사관리
				기록</a></li>
	</ul>

	<%-- 결재관리 토글 메뉴 --%>
	<a href="#" class="nav-link nav-toggle" id="approvalToggle"> <i
		class="fa-solid fa-clipboard"></i> 결재관리 <i
		class="fas fa-chevron-down toggle-icon" id="approvalArrow"></i>
	</a>
	<ul class="sub-menu" id="approvalSubMenu">
		<li><a href="${pageContext.request.contextPath}/approval/notice">결재
				공지 사항</a></li>
		<li><a
			href="${pageContext.request.contextPath}/approval/manage/doctype">문서유형
				관리</a></li>
		<li><a href="${pageContext.request.contextPath}/approval/create">결재
				상신</a></li>
		<li><a href="${pageContext.request.contextPath}/approval/list">결재
				리스트</a></li>
		<li><a href="${pageContext.request.contextPath}/approval/absence">부재
				등록</a></li>
	</ul>

	<%-- 프로젝트관리 토글 메뉴 --%>
	<a href="#" class="nav-link nav-toggle" id="projectToggle"><i
		class="fa-solid fa-chart-gantt"></i>프로젝트관리 <i
		class="fas fa-chevron-down toggle-icon" id="projectArrow"></i> </i> </a>
	<ul class="sub-menu" id="projectSubMenu">
		<li><a href="${pageContext.request.contextPath}/projects/create">프로젝트
				생성</a></li>
		<li><a
			href="${pageContext.request.contextPath}/projects/projectNotice">프로젝트
				공지사항</a></li>
		<li><a
			href="${pageContext.request.contextPath}/projects/myProjectList">프로젝트
				리스트</a></li>
		<li><a href="${pageContext.request.contextPath}/projects/gantt">프로젝트
				태스크 관리</a></li>
	</ul>

	<hr />
	<a href="${pageContext.request.contextPath}/groupware/notice"
		class="nav-link"> <i class="fas fa-bullhorn"></i> 공지사항
	</a> <a href="${pageContext.request.contextPath}/qnaBot" class="nav-link">
		<i class="fa-solid fa-question"></i> 질문봇
	</a> <a href="${pageContext.request.contextPath}/layout/lunchLadder"
		class="nav-link"> <i class="fa-solid fa-gamepad"></i> 쉬어가기
	</a>

</aside>

<%-- sidebar 전용 Js --%>
<script src="${pageContext.request.contextPath}/dist/js/main-sidebar.js"></script>

