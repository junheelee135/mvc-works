<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>대시보드</title>

<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/core.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/editProfile.css">
</head>

<body>

	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<div class="dashboard">

		<div class="top-row">
			<div class="card profile-card">
				<div class="profile-top">
					<c:choose>
						<c:when test="${empty dto.profilePhoto}">
							<img
								src="${pageContext.request.contextPath}/dist/images/avatar.png"
								class="profile-avatar">
						</c:when>
						<c:otherwise>
							<img
								src="${pageContext.request.contextPath}/uploads/member/${dto.profilePhoto}"
								class="profile-avatar"
								onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/dist/images/avatar.png';">
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
						<span class="info-label">오늘</span> <span class="info-value"><fmt:formatDate
								value="${today}" pattern="yyyy.MM.dd" /></span>
					</div>
					<div class="profile-info-item">
						<span class="info-label">진행 프로젝트</span> <span class="info-value">${projectCount}개</span>
					</div>
				</div>
			</div>

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
									<input type="checkbox"> <span class="todo-project">[${t.PROJECTNAME}]</span>
									<span class="todo-title">${t.TITLE}</span>
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

	<div class="middle-row">
		<div class="card approval-card">
			<div class="card-title">결재 현황</div>
			<div class="approval-grid">
				<div class="approval-box"
					onclick="location.href='${pageContext.request.contextPath}/approval/list?type=pendingInbox'">
					<div class="approval-icon">
						<span class="material-symbols-outlined">send</span>
						<c:if test="${pendingCount > 0}">
							<span class="badge-count">${pendingCount}</span>
						</c:if>
					</div>
					<div class="box-label">미결재</div>
				</div>
				<div class="approval-box"
					onclick="location.href='${pageContext.request.contextPath}/approval/list?type=unreadRef'">
					<div class="approval-icon">
						<span class="material-symbols-outlined">move_to_inbox</span>
						<c:if test="${unreadCount > 0}">
							<span class="badge-count">${unreadCount}</span>
						</c:if>
					</div>
					<div class="box-label">미확인</div>
				</div>
				<div class="approval-box"
					onclick="location.href='${pageContext.request.contextPath}/approval/list?type=all'">
					<span class="material-symbols-outlined">inbox</span>
					<div class="box-label">전체</div>
				</div>
			</div>
		</div>

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

	<div class="card notice-card">
		<div class="card-title">공지사항</div>

		<c:choose>
			<c:when test="${empty noticeList}">
				<div class="notice-empty">등록된 공지사항이 없습니다.</div>
			</c:when>

			<c:otherwise>
				<div class="notice-slider">
					<div class="notice-track">
						<c:forEach var="n" items="${noticeList}" varStatus="s">
							<c:if test="${s.index % 2 == 0}">
								<div class="notice-slide">
							</c:if>

							<div class="notice-item">
								<div class="notice-subject">${n.subject}</div>
								<div class="notice-date">${n.regDate}</div>
							</div>

							<c:if test="${s.index % 2 == 1 || s.last}">
					</div>
					</c:if>
					</c:forEach>
				</div>
	</div>
	</c:otherwise>
	</c:choose>

	</div>
	</div>


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




	<script>
	/* // 할 일: 검정색 점 + 제목 표시
	<c:forEach var="t" items="${todoList}">
            { 
                title: "• ${t.TITLE}", 
                start: "${t.DEADLINE}", 
                backgroundColor: 'transparent', 
                borderColor: 'transparent', 
                textColor: '#000000', 
                classNames: ['todo-item-text'] 
            },
            </c:forEach>
	*/
let calendar; 

document.addEventListener('DOMContentLoaded', function() {
    let calendarEl = document.getElementById('calendar');
    let titleEl = document.getElementById('calendar-title');

    setTimeout(function() {
        calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: false,
            displayEventTime: false,
            height: 'auto', 
            
            dayMaxEvents: 3,        // 한 칸에 최대 3개까지만 보여줌, 그 이상은 '+n more' 링크로 변환
            moreLinkClick: 'popover', // '+n more'를 클릭했을 때 팝오버(창)로 나머지 일정 표시
            handleWindowResize: true, 
            fixedWeekCount: false, 
            eventDisplay: 'block', 
            
            dayCellDidMount: function(arg) {
                if (arg.date.getDay() === 0) {
                    arg.el.querySelector('.fc-daygrid-day-number').style.color = '#ff4d4d';
                } else if (arg.date.getDay() === 6) {
                    arg.el.querySelector('.fc-daygrid-day-number').style.color = '#3b82f6';
                }
            },
            
            datesSet: function(info) {
                titleEl.innerText = info.view.title;
            },
            
            events: [
                <c:forEach var="p" items="${projectList}">
                { 
                    title: "${p.title}", 
                    start: "${p.startDate}", 
                    end: "${p.endDate}", 
                    allDay: true,
                    backgroundColor: getProjectColor("${p.title}"), 
                    borderColor: getProjectColor("${p.title}"), 
                    textColor: '#000000' 
                },
                </c:forEach>
            ]
        });
        
        // render() 호출은 설정이 완료된 후 수행해야 합니다.
        calendar.render();
        
    }, 100); 
});

const palette = ['#dbeafe', '#ddd6fe', '#fce7f3', '#fef3c7', '#d1fae5', '#ffe4e6'];
function getProjectColor(name) {
    let index = 0;
    for (let i = 0; i < name.length; i++) index += name.charCodeAt(i);
    return palette[index % palette.length];
}
    </script>

	<script>
	function moveTrack(trackSelector, index) { 
		const track = document.querySelector(trackSelector); 
			track.style.transform =	"translateX(-" + (index * 100) + "%)"; } 
			let slideIndex = 0; 
	
	function slideNext(){ 
		const slides = document.querySelectorAll(".project-slide"); 
	
		if(slideIndex < slides.length - 1) 
			moveTrack(".project-track", ++slideIndex); }
	
	function slidePrev(){ 
		if(slideIndex > 0) moveTrack(".project-track", --slideIndex); } 
	
	let todoIndex = 0; 
	
	function todoNext(){ 
		const slides = document.querySelectorAll(".todo-slide"); 
		if(todoIndex < slides.length - 1) moveTrack(".todo-track", ++todoIndex); } 
	
	function todoPrev(){
		if(todoIndex > 0) 
			moveTrack(".todo-track", --todoIndex); }
	</script>

</body>
</html>