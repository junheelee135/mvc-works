<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/projectlist.css"
	type="text/css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/paginate.css"
	type="text/css">
<link rel="stylesheet"
	href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=arrow_forward_ios" />

<style>
.swal-over-modal {
	z-index: 99999 !important;
}

.swal2-container {
	z-index: 99999 !important;
}
</style>

</head>
<body>
	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<main id="main-content">
		<div aria-label="breadcrumb">
			<ol class="breadcrumb">
				<li class="breadcrumb-item active fw-bold">Home / Projects /
					MyProjects</li>
			</ol>
		</div>

		<div class="row g-4 mb-4">
			<div class="col-md-3">
				<div class="stat-card">
					<div class="d-flex justify-content-between align-items-start">
						<div class="stat-icon bg-primaryblue bg-opacity-10 text-primary">
							<i class="fas fa-list-check"></i>
						</div>
					</div>
					<div class="stat-label">Total Projects</div>
					<div class="stat-value">${totalProjects}</div>
				</div>
			</div>
			<div class="col-md-3">
				<div class="stat-card">
					<div class="d-flex justify-content-between align-items-start">
						<div class="stat-icon bg-warning bg-opacity-10 text-warning">
							<i class="fas fa-clock"></i>
						</div>
					</div>
					<div class="stat-label">Active Projects</div>
					<div class="stat-value">${activeProjects}</div>
				</div>
			</div>
			<div class="col-md-3">
				<div class="stat-card">
					<div class="d-flex justify-content-between align-items-start">
						<div class="stat-icon bg-success bg-opacity-10 text-success">
							<i class="fas fa-check-circle"></i>
						</div>
					</div>
					<div class="stat-label">Finished</div>
					<div class="stat-value">${finishedProjects}</div>
				</div>
			</div>
			<div class="col-md-3">
				<div class="stat-card">
					<div class="d-flex justify-content-between align-items-start">
						<div class="stat-icon bg-danger bg-opacity-10 text-danger">
							<i class="fas fa-exclamation-triangle"></i>
						</div>
					</div>
					<div class="stat-label">Delayed</div>
					<div class="stat-value">${delayedProjects}</div>
				</div>
			</div>
		</div>

		<div class="project-container">
			<div class="table-header">
				<h5 class="mb-0 fw-bold">My Project List</h5>
				<div class="d-flex gap-2 align-items-center">

					<%-- 검색폼 --%>
					<form method="get"
						action="${pageContext.request.contextPath}/projects/myProjectList"
						class="d-flex gap-2 align-items-center">
						<input type="hidden" name="page" value="1"> <input
							type="hidden" name="status" value="${status}">
						<div class="search-box">
							<select name="schType">
								<option value="all" ${schType == 'all' ? 'selected' : ''}>전체</option>
								<option value="title" ${schType == 'title' ? 'selected' : ''}>프로젝트명</option>
								<option value="manager"
									${schType == 'manager' ? 'selected' : ''}>멤버</option>
								<option value="startDate"
									${schType == 'startDate' ? 'selected' : ''}>시작일</option>
								<option value="endDate"
									${schType == 'endDate' ? 'selected' : ''}>종료일</option>
							</select> <input type="text" name="kwd" placeholder="검색어를 입력하세요.."
								value="${kwd}"> <i class="fas fa-search"></i>
						</div>
						<button type="submit" class="btn btn-primary">검색</button>
						<button type="button" class="btn btn-secondary"
							onclick="location.href='${pageContext.request.contextPath}/projects/myProjectList'">↺</button>
					</form>

					<%-- 상태 필터 --%>
					<div class="dropdown">
						<button id="myFilterBtn"
							class="btn btn-filter ${not empty status ? 'active' : ''}"
							type="button">
							<i class="fas fa-filter"></i>
						</button>
						<ul id="myFilterMenu" class="dropdown-menu">
							<li><h6 class="dropdown-header fw-bold">Status</h6></li>
							<li><a class="dropdown-item"><span
									class="status-badge badge-inprogress"><span
										class="status-dot"></span>진행중</span></a></li>
							<li><a class="dropdown-item"><span
									class="status-badge badge-pending"><span
										class="status-dot"></span>승인대기</span></a></li>
							<li><a class="dropdown-item"><span
									class="status-badge badge-stop"><span class="status-dot"></span>중단</span></a></li>
							<li><a class="dropdown-item"><span
									class="status-badge badge-finished"><span
										class="status-dot"></span>종료</span></a></li>
							<li><a class="dropdown-item"><span
									class="status-badge badge-delayed"><span
										class="status-dot"></span>지연</span></a></li>
							<li><a class="dropdown-item"><span
									class="status-badge badge-ready"><span
										class="status-dot"></span>시작전</span></a></li>
						</ul>
					</div>

					<button type="button" class="btn-icon btn-edit" id="editModeBtn"
						onclick="toggleEditMode()">
						<i class="fas fa-pen"></i>
					</button>

					<button type="button" class="btn btn-create"
						onclick="location.href='${pageContext.request.contextPath}/projects/create';">+</button>
				</div>
			</div>

			<div class="table-responsive">
				<table class="table table-hover mb-0" id="myProjectTable">
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
							<tr class="project-row" data-project-id="${p.projectId}"
								data-project-title="${p.title}"
								data-project-status="${p.status}"
								data-project-type="${p.projectType}" data-role="${p.role}"
								data-start-date="${p.startDate}" data-end-date="${p.endDate}">

								<td>${dataCount - ((page-1) * size) - status.index}</td>
								<td class="fw-medium"><a
									href="${pageContext.request.contextPath}/projects/task?projectId=${p.projectId}"
									class="project-title-link">${p.title}</a></td>
								<td><span class="member-badge">${p.managerName}</span></td>
								<td>${p.startDate}</td>
								<td>${p.endDate}</td>
								<td>${p.remainDays}</td>
								<td>
									<div class="d-flex align-items-center gap-2">
										<div class="progress-container flex-grow-1"
											style="min-width: 100px;">
											<c:set var="progressClass" value="range-low" />
											<c:if test="${p.progress == 0}">
												<c:set var="progressClass" value="" />
											</c:if>
											<c:if test="${p.progress > 30}">
												<c:set var="progressClass" value="range-mid" />
											</c:if>
											<c:if test="${p.progress > 70}">
												<c:set var="progressClass" value="range-high" />
											</c:if>
											<c:if test="${p.progress == 100}">
												<c:set var="progressClass" value="range-complete" />
											</c:if>
											<div class="progress-bar ${progressClass}"
												style="width: ${p.progress}%;"></div>
										</div>
										<span class="progress-text">${p.progress}%</span>
									</div>
								</td>

								<td onclick="editMode && openEditModal(this.closest('tr'))">
									<c:choose>
										<c:when test="${p.status == '1'}">
											<span class="status-badge badge-ready"
												style="${p.role == 'M' ? 'cursor:pointer' : ''}"><span
												class="status-dot"></span>시작전</span>
										</c:when>
										<c:when test="${p.status == '2'}">
											<span class="status-badge badge-inprogress"
												style="${p.role == 'M' ? 'cursor:pointer' : ''}"><span
												class="status-dot"></span>진행중</span>
										</c:when>
										<c:when test="${p.status == '3'}">
											<span class="status-badge badge-pending"
												style="${p.role == 'M' ? 'cursor:pointer' : ''}"><span
												class="status-dot"></span>승인대기</span>
										</c:when>
										<c:when test="${p.status == '4'}">
											<span class="status-badge badge-finished"
												style="${p.role == 'M' ? 'cursor:pointer' : ''}"><span
												class="status-dot"></span>종료</span>
										</c:when>
										<c:when test="${p.status == '5'}">
											<span class="status-badge badge-delayed"
												style="${p.role == 'M' ? 'cursor:pointer' : ''}"><span
												class="status-dot"></span>지연</span>
										</c:when>
										<c:when test="${p.status == '6'}">
											<span class="status-badge badge-stop"
												style="${p.role == 'M' ? 'cursor:pointer' : ''}"><span
												class="status-dot"></span>중단</span>
										</c:when>
									</c:choose>
								</td>
							</tr>
						</c:forEach>
						<c:if test="${empty list}">
							<tr>
								<td colspan="8" class="text-center text-muted py-4">등록된
									프로젝트가 없습니다.</td>
							</tr>
						</c:if>
					</tbody>
				</table>
			</div>


            <%-- 페이징 --%>
            <div class="d-flex justify-content-center py-4 border-top">
                ${dataCount == 0 ? "" : paging}
            </div>
		</div>
	</main>


	<div class="modal fade" id="projectEditModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-lg modal-dialog-centered">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title fw-bold" id="editModalTitle">프로젝트 수정</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body">
					<input type="hidden" id="editProjectId">


					<div class="mb-4 p-3 border rounded bg-light">
						<div class="d-flex justify-content-between align-items-center">
							<div>
								<div class="fw-bold mb-1">프로젝트 강제 중단</div>
								<div class="text-muted small">프로젝트와 모든 task가 중단 처리됩니다.</div>
							</div>
							<button type="button" class="btn btn-danger" id="forceStopBtn"
								onclick="forceStopProject()">강제 중단</button>
						</div>
					</div>

					<%-- 날짜 수정 추가 --%>
					<div class="mb-4 p-3 border rounded">
						<div class="fw-bold mb-3">프로젝트 기간 수정</div>
						<div class="row g-3">
							<div class="col-md-6">
								<label class="form-label text-muted small">시작일</label> <input
									type="date" id="editStartDate" class="form-control">
							</div>
							<div class="col-md-6">
								<label class="form-label text-muted small">종료일</label> <input
									type="date" id="editEndDate" class="form-control">
							</div>
						</div>
					</div>


					<div class="mb-3 p-3 border rounded" id="memberChangeArea">
						<div
							class="d-flex justify-content-between align-items-center mb-3">
							<div class="fw-bold">구성원 변경</div>
						</div>
						<div class="mb-3">
							<div class="text-muted small mb-2">
								현재 구성원 (교체할 구성원의 <i class="fas fa-exchange-alt"></i> 클릭)
							</div>
							<div id="currentMemberBadges" class="d-flex flex-wrap gap-2"></div>
						</div>
						<div id="newMemberArea" style="display: none;">
							<div class="text-muted small mb-2">새 구성원</div>
							<div id="selectedMemberList"
								class="d-flex flex-wrap gap-2 p-3 border rounded bg-light">
								<p class="text-muted mb-0" id="noMemberText">선택된 멤버가 없습니다.</p>
							</div>
							<div id="hiddenInputContainer"></div>
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">닫기</button>
					<button type="button" class="btn btn-primary"
						onclick="saveMemberChange()">저장</button>
				</div>
			</div>
		</div>
	</div>


	<%-- ✅ 구성원 검색 모달 --%>
	<div class="modal fade" id="editMemberSearchModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-xl modal-dialog-centered">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title fw-bold">구성원 선택</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
				</div>
				<div class="modal-body p-0">
					<div class="p-3 border-bottom bg-light">
						<div class="input-group">
							<input type="text" id="editMemberSearchKeyword"
								class="form-control" placeholder="이름, 부서, 직급으로 검색...">
							<button class="btn btn-primary" type="button"
								onclick="editSearchMembers()">
								<i class="fas fa-search"></i> 검색
							</button>
						</div>
					</div>
					<div class="d-flex" style="height: 450px;">
						<div class="border-end p-3"
							style="width: 35%; min-width: 220px; overflow-y: auto;">
							<h6 class="fw-bold mb-3">조직도</h6>
							<ul class="list-unstyled shadow-none mb-0" id="editDeptTree"></ul>
						</div>
						<div class="p-3 flex-grow-1" style="overflow-y: auto;">
							<h6 class="fw-bold mb-3" id="editSelectedDeptName">부서를 선택하세요
							</h6>
							<div id="editModalMemberList"
								class="row row-cols-2 row-cols-md-3 g-2"></div>
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">닫기</button>
					<button type="button" class="btn btn-primary"
						onclick="editConfirmSelection()">선택 완료</button>
				</div>
			</div>
		</div>
	</div>


	<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
	<script
		src="${pageContext.request.contextPath}/dist/js/myprojectlist.js"></script>

</body>
</html>