<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>대시보드</title>

<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />

<link rel="stylesheet" href="<c:url value='/dist/css/core.css' />">
<link rel="stylesheet"
	href="<c:url value='/dist/css/editProfile.css' />">
</head>

<body>

	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<div class="dashboard">

		<!-- ================= 상단 ================= -->
		<div class="top-row">

			<!-- 프로필 -->
			<div class="card profile-card">
				<div class="profile-top">
					<c:choose>
						<c:when test="${empty dto.profilePhoto}">
							<img src="<c:url value='/dist/images/avatar.png' />"
								class="profile-avatar">
						</c:when>
						<c:otherwise>
							<img src="<c:url value='/uploads/member/${dto.profilePhoto}' />"
								class="profile-avatar"
								onerror="this.src='<c:url value='/dist/images/avatar.png' />';">
						</c:otherwise>
					</c:choose>

					<div>
						<div class="profile-name">${sessionScope.member.name}</div>
						<div class="profile-grade">${sessionScope.member.deptName}
							${sessionScope.member.gradeName}</div>
					</div>
				</div>

				<div class="profile-info">
					<div class="profile-info-item">
						<span class="info-label">오늘</span> <span class="info-value">
							<fmt:formatDate value="${today}" pattern="yyyy.MM.dd" />
						</span>
					</div>
					<div class="profile-info-item">
						<span class="info-label">진행 프로젝트</span> <span class="info-value">${projectCount}개</span>
					</div>
				</div>
			</div>

			<!-- 할일 -->
			<div class="card todo-card">
				<div class="project-header">
					<div class="card-title">내 할일</div>
					<div class="project-nav-wrap">
						<button class="project-nav" onclick="todoPrev()">‹</button>
						<button class="project-nav" onclick="todoNext()">›</button>
					</div>
				</div>

				<div class="todo-slider">
					<div class="todo-track">

						<c:forEach var="t" items="${todoList}" varStatus="s">

							<c:if test="${s.index % 6 == 0}">
								<div class="todo-slide">
									<div class="todo-grid">
							</c:if>

							<div class="todo-item">
								<div class="todo-left">
									<span class="todo-project">[${t.PROJECTNAME}]</span> <span
										class="todo-title">${t.TITLE}</span>
								</div>
								<span class="todo-date">${t.DEADLINE}</span>
							</div>

							<c:if test="${s.index % 6 == 5 || s.last}">
					</div>
				</div>
				</c:if>

				</c:forEach>

			</div>
		</div>
	</div>

	</div>

	<!-- ================= 중단 ================= -->
	<div class="middle-row">

		<!-- 결재 -->
		<div class="card approval-card">
			<div class="card-title">결재 현황</div>
			<div class="approval-grid">

				<div class="approval-box"
					onclick="location.href='<c:url value='/approval/list?type=pendingInbox' />'">
					<div class="approval-icon">
						<span class="material-symbols-outlined">send</span>
						<c:if test="${pendingCount > 0}">
							<span class="badge-count">${pendingCount}</span>
						</c:if>
					</div>
					<div class="box-label">미결재</div>
				</div>

				<div class="approval-box"
					onclick="location.href='<c:url value='/approval/list?type=unreadRef' />'">
					<div class="approval-icon">
						<span class="material-symbols-outlined">move_to_inbox</span>
						<c:if test="${unreadCount > 0}">
							<span class="badge-count">${unreadCount}</span>
						</c:if>
					</div>
					<div class="box-label">미확인</div>
				</div>

				<div class="approval-box"
					onclick="location.href='<c:url value='/approval/list?type=all' />'">
					<span class="material-symbols-outlined">inbox</span>
					<div class="box-label">전체</div>
				</div>

			</div>
		</div>

		<!-- 프로젝트 -->
		<div class="card project-card">
			<div class="project-header">
				<div class="card-title">프로젝트 진행률</div>
				<div class="project-nav-wrap">
					<button class="project-nav" onclick="slidePrev()">‹</button>
					<button class="project-nav" onclick="slideNext()">›</button>
				</div>
			</div>

			<div class="project-slider">
				<div class="project-track">

					<c:forEach var="p" items="${projectList}" varStatus="s">

						<c:if test="${s.index % 2 == 0}">
							<div class="project-slide">
						</c:if>

						<div class="project-item">
							<div class="project-top">
								<span>${p.title}</span> <span>${p.progress}%</span>
							</div>
							<div class="progress-bg">
								<div class="progress-fill" style="width:${p.progress}%"></div>
							</div>
						</div>

						<c:if test="${s.index % 2 == 1 || s.last}">
				</div>
				</c:if>

				</c:forEach>

			</div>
		</div>
	</div>

	<!-- 공지 -->
	<div class="card notice-card">
		<div class="card-title">공지사항</div>

		<c:choose>
			<c:when test="${empty noticeList}">
				<div class="notice-empty">등록된 공지사항이 없습니다.</div>
			</c:when>
			<c:otherwise>
				<c:forEach var="n" items="${noticeList}" varStatus="s">
					<c:if test="${s.index < 3}">
						<div class="notice-item"
							onclick="location.href='<c:url value='/projectNotice/detail?noticenum=${n.noticenum}' />'">

							<div class="notice-subject">${n.subject}</div>
							<div class="notice-date">${n.regdate}</div>

						</div>
					</c:if>
				</c:forEach>
			</c:otherwise>
		</c:choose>
	</div>

	</div>

	<!-- ================= 캘린더 ================= -->
	<div class="card calendar-card">
		<div class="calendar-header">
			<div class="card-title">일정</div>
			<div id="calendar-title"></div>
			<div class="project-nav-wrap">
				<button class="project-nav" onclick="calendar.prev()">‹</button>
				<button class="project-nav" onclick="calendar.next()">›</button>
			</div>
		</div>

		<div id="calendar"></div>
	</div>

	</div>

	<!-- JS -->
	<script>
    // 슬라이더 공용 함수
    function moveTrack(trackSelector, index) {
        const track = document.querySelector(trackSelector);
        track.style.transform = "translateX(-" + (index * 100) + "%)";
    }

    let slideIndex = 0;
    function slideNext() { const slides = document.querySelectorAll(".project-slide"); if(slideIndex < slides.length-1) moveTrack(".project-track", ++slideIndex); }
    function slidePrev() { if(slideIndex > 0) moveTrack(".project-track", --slideIndex); }

    let todoIndex = 0;
    function todoNext() { const slides = document.querySelectorAll(".todo-slide"); if(todoIndex < slides.length-1) moveTrack(".todo-track", ++todoIndex); }
    function todoPrev() { if(todoIndex > 0) moveTrack(".todo-track", --todoIndex); }

    // 캘린더
    document.addEventListener('DOMContentLoaded', function() {
        const calendarEl = document.getElementById('calendar');
        const titleEl = document.getElementById('calendar-title');

        const palette = ['#dbeafe','#ddd6fe','#fce7f3','#fef3c7','#d1fae5','#ffe4e6'];
        function getProjectColor(name) {
            let index = 0; for(let i=0;i<name.length;i++) index += name.charCodeAt(i);
            return palette[index % palette.length];
        }

        const events = [
            <c:forEach var="p" items="${projectList}" varStatus="s">
            {
                title: "${p.title}",
                start: "${p.startDate}",
                end: "${p.endDate}",
                allDay: true,
                backgroundColor: getProjectColor("${p.title}"),
                borderColor: getProjectColor("${p.title}"),
                textColor: "#000"
            }<c:if test="${!s.last}">,</c:if>
            </c:forEach>
        ];

        calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: false,
            displayEventTime: false,
            height: 'auto',
            dayMaxEvents: 3,
            moreLinkClick: 'popover',
            handleWindowResize: true,
            fixedWeekCount: false,
            eventDisplay: 'block',
            dayCellDidMount: function(arg) {
                if(arg.date.getDay()===0) arg.el.querySelector('.fc-daygrid-day-number').style.color='#ff4d4d';
                else if(arg.date.getDay()===6) arg.el.querySelector('.fc-daygrid-day-number').style.color='#3b82f6';
            },
            datesSet: function(info){ titleEl.innerText = info.view.title; },
            events: events
        });

        calendar.render();
    });
    </script>
</body>
</html>