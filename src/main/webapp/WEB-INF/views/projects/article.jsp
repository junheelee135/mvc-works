<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projectarticle.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css" type="text/css">

<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=arrow_forward_ios" />
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>



	<main id="main-content">
	    <div aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item text-muted">Projects</li>
                <li class="breadcrumb-item text-muted">Home</li>
                <li class="breadcrumb-item active fw-bold">Projects List</li>
            </ol>
        </div>
        <div class="card-header-project">
            <h1 class="project-title">${dto.title}</h1>

            <div class="team-section">
                <div class="team-label">
                    <i class="fas fa-code"></i>Team Member
                </div>
				<div class="member-list">
				    <c:forEach var="m" items="${members}">
				            <div class="member-chip">
				                <div class="member-avatar-text" data-empid="${m.EMPID}">
				                    ${fn:substring(m.NAME, 0, 1)}
				                </div>
				                <span class="member-name text-dark">
				                ${m.NAME}
				                <c:if test="${m.ROLE eq 'M'}"></c:if>
				                </span>
				            </div>
				    </c:forEach>
				</div>
            </div>
        </div>

        <div class="card-progress">
            <div class="progress-header">
                <div class="progress-label">Projects 진척률
                	
                </div>
                <div class="progress-stats text-muted">16(진행완)/25(전체task) Tasks Completed <span class="text-dark">(${dto.progress}%)</span></div>
            </div>
		    <div class="progress" style="cursor: pointer;" onclick="location.href='${pageContext.request.contextPath}/projects/ganttarticle'">
		        <div class="progress-bar" role="progressbar" 
		             style="width: ${dto.progress}%;" 
		             aria-valuenow="${dto.progress}" aria-valuemin="0" aria-valuemax="100">
		            ${dto.progress}%
		        </div>
		    </div>
		</div>

        <div class="bottom-grid">
            <div class="card-details">
                <div class="details-title text-primary">
                    <i class="fas fa-info-circle"></i> Project Details
                </div>

				<div class="info-group">
				    <span class="info-label">Project Manager</span>
				    <div class="manager-info">
				        <c:forEach var="m" items="${members}">
				            <c:if test="${m.ROLE eq 'M'}"> <%-- ROLE이 M인 사람만 출력 --%>
				                <div class="member-avatar-text" data-empid="${m.EMPID}">
				                    ${fn:substring(m.NAME, 0, 1)}
				                </div>
				                <div>
				                    <div class="manager-name">${m.NAME}</div>
				                </div>
				            </c:if>
				        </c:forEach>
				    </div>
				</div>

                <div class="info-group mb-0">
                    <span class="info-label">Project 설명</span>
                    <p class="description-text">
                        ${dto.description}
                    </p>
                </div>
            </div>

            <div class="action-grid">
                <div class="action-card">
                    <div class="action-icon"><i class="far fa-calendar-alt"></i></div>
                    <span class="action-label">Start Date</span>
                    <span class="action-value">${dto.startDate}</span>
                </div>
                <div class="action-card">
                    <div class="action-icon text-warning"><i class="far fa-calendar-check"></i></div>
                    <span class="action-label">End Date</span>
                    <span class="action-value">${dto.endDate}</span>
                </div>
                <div class="action-card">
                    <div class="action-icon text-success"><i class="fas fa-calendar-day"></i></div>
                    <span class="action-label">Schedule</span>
                    <span class="action-value">Go to Calendar</span>
                </div>
                <div class="action-card" onclick="location.href='${pageContext.request.contextPath}/projects/list'">
                    <div class="action-icon text-dark"><i class="fas fa-tasks"></i></div>
                    <span class="action-label">Workflow</span>
                    <span class="action-value">Go to list</span>
                </div>
            </div>
        </div>
    </main>


<script type="text/javascript">
document.querySelectorAll('.member-avatar-text').forEach(el => {
    const empId = el.dataset.empid || '';
    const colors = ['#4f86c6','#e07b54','#6abf69','#9b6db5','#e5a823','#3ab0b0','#d95f7f'];
    const idx = empId.split('').reduce((acc, c) => acc + c.charCodeAt(0), 0) % colors.length;
    el.style.background = colors[idx];
    el.style.color = '#fff';
    el.style.display = 'flex';
    el.style.alignItems = 'center';
    el.style.justifyContent = 'center';
    el.style.fontWeight = '700';
});
</script>

</body>
</html>
