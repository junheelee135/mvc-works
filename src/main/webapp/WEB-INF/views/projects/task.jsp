<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projectgantt.css" type="text/css">
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
            <li class="breadcrumb-item active fw-bold">Projects gantt</li>
        </ol>
    </div>

    <div class="project-container">
        <div class="table-header">
            <h5 class="mb-0 fw-bold">Project gantt</h5>
            <div class="d-flex gap-2 align-items-center">
                <%-- 검색폼 --%>
                <form method="get" action="${pageContext.request.contextPath}/projects/gantt" class="d-flex gap-2 align-items-center">
                    <div class="search-box">
                        <select name="schType">
                            <option value="title" ${schType == 'title' ? 'selected' : ''}>프로젝트명</option>
                            <option value="manager" ${schType == 'manager' ? 'selected' : ''}>매니저</option>
                            <option value="startDate" ${schType == 'startDate' ? 'selected' : ''}>시작일</option>
                            <option value="endDate" ${schType == 'endDate' ? 'selected' : ''}>종료일</option>
                            <option value="status" ${schType == 'status' ? 'selected' : ''}>상태</option>
                        </select>
                        <input type="text" name="kwd" placeholder="검색어를 입력하세요.." value="${kwd}">
                        <i class="fas fa-search"></i>
                    </div>
                    <button type="submit" class="btn btn-primary">검색</button>
                    <button type="button" class="btn btn-secondary"
                        onclick="location.href='${pageContext.request.contextPath}/projects/gantt'">↺</button>
                </form>
            </div>
        </div>

        <div class="table-wrapper">
            <table class="project-table">
                <thead>
                    <tr>
                        <th width="60">No</th>
                        <th>프로젝트</th>
                        <th>매니저</th>
                        <th>시작일</th>
                        <th>종료일</th>
                        <th>잔여/전체일</th>
                        <th>진척도</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${list}" varStatus="status">
                    <tr>
                        <td class="text-center">${dataCount - ((page-1) * size) - status.index}</td>
                        <td class="project-name">
                            <a href="${pageContext.request.contextPath}/projects/task?projectId=${p.projectId}" class="project-title-link">
                                ${p.title}
                            </a>
                        </td>
                        <td><span class="member-badge" style="margin-left: 2px;">${p.managerName}</span></td>
                        <td>${p.startDate}</td>
                        <td>${p.endDate}</td>
                        <td>${p.remainDays}</td>
                        <td>
						    <div class="d-flex align-items-center gap-2">
						        <div class="progress-container flex-grow-1" style="min-width: 100px;">
						            <c:set var="progressClass" value="range-low"/>
						            <c:if test="${p.progress == 0}"><c:set var="progressClass" value=""/></c:if>
						            <c:if test="${p.progress > 30}"><c:set var="progressClass" value="range-mid"/></c:if>
						            <c:if test="${p.progress > 70}"><c:set var="progressClass" value="range-high"/></c:if>
						            <c:if test="${p.progress == 100}"><c:set var="progressClass" value="range-complete"/></c:if>
						            <div class="progress-bar ${progressClass}" style="width: ${p.progress}%;"></div>
						        </div>
						        <span class="progress-text">${p.progress}%</span>
						    </div>
						</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty list}">
                    <tr>
                        <td colspan="8" class="text-center text-muted py-4">등록된 프로젝트가 없습니다.</td>
                    </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <%-- 페이징 --%>
        <div class="d-flex justify-content-center py-4 border-top">
            ${dataCount == 0 ? "등록된 게시글이 없습니다" : paging}
        </div>

    </div>
</main>

</body>
</html>
