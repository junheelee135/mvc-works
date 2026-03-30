<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Project Tasks</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/projecttask.css"
	type="text/css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/paginate.css"
	type="text/css">

<style>
/* 내 할 일 목록 전용 스타일 */
.manager-badge {
	background: #fee2e2;
	color: #ef4444;
	font-size: 0.7rem;
	padding: 2px 5px;
	border-radius: 4px;
	margin-left: 8px;
	font-weight: bold;
	border: 1px solid #fecaca;
}

.task-list-side.full-width {
	width: 100% !important;
	flex: 0 0 100% !important;
	border-right: none !important;
}

.daily-btn-wrap {
	position: relative;
	display: inline-block;
}
</style>
</head>
<body>
	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<main id="main-content">
		<div aria-label="breadcrumb">
			<ol class="breadcrumb">
				<li class="breadcrumb-item text-muted">Projects</li>
				<li class="breadcrumb-item active fw-bold">My Tasks</li>
			</ol>
		</div>

		<div class="task-container">
			<div class="table-header">
				<h5 class="mb-0 fw-bold">
					<c:choose>
						<c:when test="${projectId == 0 || empty projectId}">내 태스크</c:when>
						<c:otherwise>${projectTitle}</c:otherwise>
					</c:choose>
				</h5>

				<div class="d-flex gap-2 align-items-center">
					<%-- 검색 및 프로젝트 필터 폼 --%>
					<form method="get"
						action="${pageContext.request.contextPath}/projects/myTask"
						class="d-flex gap-2 align-items-center">
						<div class="search-box"
							style="padding: 0 10px; background: #fff; width: 220px;">
							<select name="projectId" onchange="this.form.submit()"
								style="border: none; outline: none; font-size: 0.85rem; width: 100%; height: 38px;">
								<option value="0">전체 프로젝트 보기</option>
								<c:forEach var="p" items="${myProjects}">
									<option value="${p.projectId}"
										${projectId == p.projectId ? 'selected' : ''}>${p.title}</option>
								</c:forEach>
							</select>
						</div>

						<div class="search-box">
							<select name="schType">
								<option value="taskTitle"
									${schType == 'taskTitle' ? 'selected' : ''}>태스크명</option>
								<option value="stgTitle"
									${schType == 'stgTitle' ? 'selected' : ''}>단계명</option>
							</select> <input type="text" name="kwd" placeholder="Task 검색..."
								value="${kwd}"> <i class="fas fa-search"></i>
						</div>
						<button type="submit" class="btn btn-primary">검색</button>
						<button type="button" class="btn btn-secondary"
							onclick="location.href='${pageContext.request.contextPath}/projects/myTask'">↺</button>
					</form>

					<div class="d-flex gap-2 ms-2"></div>
				</div>
			</div>

			<div class="table-wrapper">
				<div class="task-list-side full-width">
					<table class="task-table">
						<thead>
							<tr>
								<th width="45">NO</th>
								<th width="180">프로젝트</th>
								<th>TASK 정보</th>
								<th width="120" class="text-center">시작일</th>
								<th width="120" class="text-center">종료일</th>
								<th width="110" class="text-center">상태</th>
							</tr>
						</thead>
						<tbody id="taskTableBody">
							<c:choose>
								<c:when test="${not empty list}">
									<c:forEach var="t" items="${list}" varStatus="status">
										<c:set var="isPM" value="${t.role == 'M'}" />
										<tr data-task-id="${t.taskId}"
											data-emp-task-id="${t.empTaskId}"
											data-start="${t.taskStartDate}" data-end="${t.taskEndDate}"
											onclick="openDailyCheck('${t.empTaskId}', '${t.taskTitle}', '${t.taskStartDate}', '${t.taskEndDate}', '${t.title}')">
											<td class="text-center">${status.count}</td>
											<td class="text-muted" style="font-size: 0.85rem;">${t.title}</td>
											<td class="fw-bold">
												<div class="d-flex align-items-center">
													<c:if test="${not empty t.stgTitle}">
														<span class="stage-badge me-2">${t.stgTitle}</span>
													</c:if>
													${t.taskTitle}
													<c:if test="${isPM}">
														<span class="manager-badge">PM</span>
													</c:if>
												</div>
											</td>
											<td class="text-center" onclick="event.stopPropagation();">
												<input type="date" class="cell-date"
												value="${t.taskStartDate}" ${isPM ? '' : 'disabled'}
												onchange="updateTask('${t.taskId}', 'startDate', this.value)">
											</td>
											<td class="text-center" onclick="event.stopPropagation();">
												<input type="date" class="cell-date"
												value="${t.taskEndDate}" ${isPM ? '' : 'disabled'}
												onchange="updateTask('${t.taskId}', 'endDate', this.value)">
											</td>
											<td onclick="event.stopPropagation();">${t.taskStatus == '1' ? '시작전' :
										      t.taskStatus == '2' ? '진행' :
										      t.taskStatus == '3' ? '승인대기' :
										      t.taskStatus == '4' ? '종료' :
										      t.taskStatus == '5' ? '지연' :
										      t.taskStatus == '6' ? '중단' : ''}
											</td>
										</tr>
									</c:forEach>
								</c:when>
								<c:otherwise>
									<tr>
										<td colspan="7" class="text-center text-muted py-5">조회된
											태스크가 없습니다.</td>
									</tr>
								</c:otherwise>
							</c:choose>
						</tbody>
					</table>
				</div>
			</div>

			<div class="d-flex justify-content-center py-4 border-top">
				${taskDataCount == 0 ? "" : paging}</div>
		</div>
	</main>


	<%-- 스크립트 변수 및 외부 파일 연결 --%>
	<input type="hidden" id="hiddenLoginEmpId" value="${loginEmpId}">
	<input type="hidden" id="hiddenProjectId" value="${projectId}">
	<input type="hidden" id="hiddenIsManager" value="${isManager}">

	<script>
		const contextPath = '${pageContext.request.contextPath}';
	</script>
	<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
	<script src="${pageContext.request.contextPath}/dist/js/tasklist.js"></script>
	<%-- 프로젝트 생성 날짜 제한 등이 필요한 경우 추가 --%>
	<script src="${pageContext.request.contextPath}/dist/js/projectdate.js"></script>
</body>
</html>