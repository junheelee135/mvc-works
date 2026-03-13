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

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projectlist.css" type="text/css">
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

        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div class="stat-icon bg-primaryblue bg-opacity-10 text-primary"><i class="fas fa-list-check"></i></div>
                        <span class="stat-trend bg-success bg-opacity-10 text-success">+12%</span>
                    </div>
                    <div class="stat-label">Total Projects</div>
                    <div class="stat-value">128</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="fas fa-clock"></i></div>
                        <span class="stat-trend bg-light text-muted">Stable</span>
                    </div>
                    <div class="stat-label">Active Projects</div>
                    <div class="stat-value">45</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="fas fa-check-circle"></i></div>
                        <span class="stat-trend bg-success bg-opacity-10 text-success">+5</span>
                    </div>
                    <div class="stat-label">Finished</div>
                    <div class="stat-value">73</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-start">
                        <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="fas fa-exclamation-triangle"></i></div>
                        <span class="stat-trend bg-danger bg-opacity-10 text-danger">+2</span>
                    </div>
                    <div class="stat-label">Delayed</div>
                    <div class="stat-value">10</div>
                </div>
            </div>
        </div>

        <div class="project-container">
            <div class="table-header">
                <h5 class="mb-0 fw-bold">Project List</h5>
                <div class="d-flex gap-2 align-items-center">

                    <%-- 검색폼 --%>
					<form method="get" action="${pageContext.request.contextPath}/projects/list" class="d-flex gap-2 align-items-center">
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
					        onclick="location.href='${pageContext.request.contextPath}/projects/list'">↺</button>
					</form>

                    <%-- 상태 필터 --%>
                    <div class="dropdown">
                        <button id="myFilterBtn" class="btn btn-filter ${not empty status ? 'active' : ''}" type="button">
                            <i class="fas fa-filter"></i>
                        </button>
                        <ul id="myFilterMenu" class="dropdown-menu">
                            <li><h6 class="dropdown-header fw-bold">Status</h6></li>
                            <li><a class="dropdown-item"><span class="status-badge badge-inprogress"><span class="status-dot"></span>진행중</span></a></li>
                            <li><a class="dropdown-item"><span class="status-badge badge-pending"><span class="status-dot"></span>승인대기</span></a></li>
                            <li><a class="dropdown-item"><span class="status-badge badge-stop"><span class="status-dot"></span>중단</span></a></li>
                            <li><a class="dropdown-item"><span class="status-badge badge-finished"><span class="status-dot"></span>종료</span></a></li>
                            <li><a class="dropdown-item"><span class="status-badge badge-delayed"><span class="status-dot"></span>지연</span></a></li>
                            <li><a class="dropdown-item"><span class="status-badge badge-ready"><span class="status-dot"></span>시작전</span></a></li>
                        </ul>
                    </div>

                    <button type="button" class="btn btn-create"
                        onclick="location.href='${pageContext.request.contextPath}/projects/create';">+</button>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th width="40">No</th>
                            <th>프로젝트</th>
                            <th>매니저</th>
                            <th>시작일</th>
                            <th>종료일</th>
                            <th>잔여/전체일</th>
                            <th>진척도</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${list}" varStatus="status">
                        <tr>
							<td>${dataCount - ((page-1) * size) - status.index}</td>
						        <td class="fw-medium">
						            <a href="${pageContext.request.contextPath}/projects/article?projectId=${p.projectId}" class="project-title-link">
						                ${p.title}
						            </a>
                            	</td>
                            <td><span class="member-badge">${p.managerName}</span></td>
                            <td>${p.startDate}</td>
                            <td>${p.endDate}</td>
                            <td>${p.remainDays}</td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="progress-container flex-grow-1" style="min-width: 100px;">
                                        <div class="progress-bar" style="width: ${p.progress}%;"></div>
                                    </div>
                                    <span class="progress-text">${p.progress}%</span>
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.status == '1'}"><span class="status-badge badge-ready"><span class="status-dot"></span>시작전</span></c:when>
                                    <c:when test="${p.status == '2'}"><span class="status-badge badge-inprogress"><span class="status-dot"></span>진행중</span></c:when>
                                    <c:when test="${p.status == '3'}"><span class="status-badge badge-pending"><span class="status-dot"></span>승인대기</span></c:when>
                                    <c:when test="${p.status == '4'}"><span class="status-badge badge-finished"><span class="status-dot"></span>종료</span></c:when>
                                    <c:when test="${p.status == '5'}"><span class="status-badge badge-delayed"><span class="status-dot"></span>지연</span></c:when>
                                    <c:when test="${p.status == '6'}"><span class="status-badge badge-stop"><span class="status-dot"></span>중단</span></c:when>
                                </c:choose>
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


<script src="${pageContext.request.contextPath}/dist/js/projectlist.js"></script>

</body>
</html>