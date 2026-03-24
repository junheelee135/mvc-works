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
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projecttask.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css" type="text/css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

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

.daily-btn-wrap:hover::after {
	content: attr(data-tooltip);
	position: absolute;
	bottom: 100%;
	left: 50%;
	transform: translateX(-50%);
	background: #333;
	color: #fff;
	padding: 5px 10px;
	border-radius: 4px;
	font-size: 12px;
	white-space: nowrap;
	z-index: 10;
	margin-bottom: 5px;
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
						<c:when test="${projectId == 0 || empty projectId}">전체 내 태스크</c:when>
						<c:otherwise>${projectTitle}</c:otherwise>
					</c:choose>
				</h5>

				<div class="d-flex gap-2 align-items-center">
					<%-- 검색 및 프로젝트 필터 폼 --%>
					<form method="get" action="${pageContext.request.contextPath}/projects/myTask" class="d-flex gap-2 align-items-center">
						<div class="search-box" style="padding: 0 10px; background: #fff; width: 220px;">
							<select name="projectId" onchange="this.form.submit()" style="border: none; outline: none; font-size: 0.85rem; width: 100%; height: 38px;">
								<option value="0">전체 프로젝트 보기</option>
								<c:forEach var="p" items="${myProjects}">
									<option value="${p.projectId}" ${projectId == p.projectId ? 'selected' : ''}>${p.title}</option>
								</c:forEach>
							</select>
						</div>

						<div class="search-box">
							<select name="schType">
								<option value="taskTitle" ${schType == 'taskTitle' ? 'selected' : ''}>태스크명</option>
								<option value="stgTitle" ${schType == 'stgTitle' ? 'selected' : ''}>단계명</option>
							</select> 
							<input type="text" name="kwd" placeholder="Task 검색..." value="${kwd}"> 
							<i class="fas fa-search"></i>
						</div>
						<button type="submit" class="btn btn-primary">검색</button>
						<button type="button" class="btn btn-secondary" onclick="location.href='${pageContext.request.contextPath}/projects/myTask'">↺</button>
					</form>

					<%-- 버튼 영역: 특정 프로젝트 선택 시에만 '추가' 노출 가능하도록 설정 --%>
					<div class="d-flex gap-2 ms-2">
						<c:if test="${projectId != 0 && isManager}">
							<button type="button" class="btn-icon btn-add" onclick="openTaskModal()" title="새 태스크 추가">
								<i class="fas fa-plus"></i>
							</button>
						</c:if>
						<button type="button" class="btn-icon btn-edit" id="editBtn" title="편집 모드">
							<i class="fas fa-pencil-alt"></i>
						</button>
					</div>
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
								<th width="60" class="text-center">권한</th>
							</tr>
						</thead>
						<tbody id="taskTableBody">
							<c:choose>
								<c:when test="${not empty list}">
									<c:forEach var="t" items="${list}" varStatus="status">
										<c:set var="isPM" value="${t.role == 'M'}" />
										<tr data-task-id="${t.taskId}" 
											data-emp-task-id="${t.empTaskId}"
											data-start="${t.taskStartDate}"
											data-end="${t.taskEndDate}"
											onclick="openDailyCheck('${t.empTaskId}', '${t.taskTitle}', '${t.taskStartDate}', '${t.taskEndDate}', '${t.title}')"
											style="cursor: pointer;">
											<td class="text-center">${status.count}</td>
											<td class="text-muted" style="font-size: 0.85rem;">${t.title}</td>
											<td class="fw-bold">
												<div class="d-flex align-items-center">
													<c:if test="${not empty t.stgTitle}">
														<span class="stage-badge me-2">${t.stgTitle}</span>
													</c:if>
													${t.taskTitle}
													<c:if test="${isPM}"><span class="manager-badge">PM</span></c:if>
												</div>
											</td>
											<td class="text-center" onclick="event.stopPropagation();">
												<input type="date" class="cell-date" value="${t.taskStartDate}" 
													${isPM ? '' : 'disabled'}
													onchange="updateTask('${t.taskId}', 'startDate', this.value)">
											</td>
											<td class="text-center" onclick="event.stopPropagation();">
												<input type="date" class="cell-date" value="${t.taskEndDate}" 
													${isPM ? '' : 'disabled'}
													onchange="updateTask('${t.taskId}', 'endDate', this.value)">
											</td>
											<td onclick="event.stopPropagation();">
												<select class="cell-select status-cell" data-status="${t.taskStatus}"
													onchange="updateTask('${t.taskId}', 'status', this.value); updateStatusStyle(this)">
													<option value="1" ${t.taskStatus == '1' ? 'selected' : ''}>시작전</option>
													<option value="2" ${t.taskStatus == '2' ? 'selected' : ''}>진행</option>
													<option value="3" ${t.taskStatus == '3' ? 'selected' : ''}>승인대기</option>
													<option value="4" ${t.taskStatus == '4' ? 'selected' : ''}>종료</option>
													<option value="5" ${t.taskStatus == '5' ? 'selected' : ''}>지연</option>
													<option value="6" ${t.taskStatus == '6' ? 'selected' : ''}>중단</option>
												</select>
											</td>
											<td class="text-center">
												<c:choose>
													<c:when test="${isPM}"><i class="fas fa-user-shield text-primary" title="관리자"></i></c:when>
													<c:otherwise><i class="fas fa-user text-muted" title="담당자"></i></c:otherwise>
												</c:choose>
											</td>
										</tr>
									</c:forEach>
								</c:when>
								<c:otherwise>
									<tr>
										<td colspan="7" class="text-center text-muted py-5">조회된 태스크가 없습니다.</td>
									</tr>
								</c:otherwise>
							</c:choose>
						</tbody>
					</table>
				</div>
			</div>

			<div class="d-flex justify-content-center py-4 border-top">
				${taskDataCount == 0 ? "" : paging}
			</div>
		</div>
	</main>

	<div id="taskModal" class="modal-overlay" style="display: none;">
		<div class="modal-box">
			<div class="modal-header">
				<h2 class="modal-title">새 Task 생성</h2>
				<button class="modal-close" onclick="closeTaskModal()">&times;</button>
			</div>
			<div class="modal-body">
				<div class="form-row">
					<div class="form-group full">
						<label>단계 선택 <span class="required">*</span></label>
						<select id="modalStageId">
							<option value="">프로젝트 단계 설정</option>
							<c:forEach var="s" items="${stages}">
								<option value="${s.stageId}">${s.stgTitle}</option>
							</c:forEach>
							<option value="direct">직접 입력</option>
						</select>
					</div>
				</div>
				<div class="form-row" id="directStageRow" style="display: none;">
					<div class="form-group full">
						<label>단계명 직접 입력</label> 
						<input type="text" id="modalDirectStage" placeholder="단계명을 입력하세요">
					</div>
				</div>
				<div class="form-row">
					<div class="form-group full">
						<label>태스크명 <span class="required">*</span></label> 
						<input type="text" id="modalTaskTitle" placeholder="Task 명을 입력하세요">
					</div>
				</div>
				<div class="form-row">
					<div class="form-group full">
						<label>담당자 <span class="required">*</span></label>
						<select id="modalMember">
							<option value="">담당자 선택</option>
							<c:forEach var="m" items="${members}">
								<option value="${m.empId}">${m.name}(${m.role == 'M' ? '매니저' : m.role == 'D' ? '디자이너' : '개발자'})</option>
							</c:forEach>
						</select>
					</div>
				</div>
				<div class="form-row">
					<div class="form-group">
						<label>시작일 <span class="required">*</span></label> 
						<input type="date" id="modalStartDate">
					</div>
					<div class="form-group">
						<label>종료일 <span class="required">*</span></label> 
						<input type="date" id="modalEndDate">
					</div>
				</div>
				<div class="form-row">
					<div class="form-group full">
						<label>설명</label> 
						<input type="text" id="modalTaskDesc" placeholder="Task 설명을 입력하세요">
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button class="btn-cancel" onclick="closeTaskModal()">취소</button>
				<button class="btn-submit" onclick="submitTask()">생성</button>
			</div>
		</div>
	</div>

	<div id="taskDailyCheckModal" class="modal-overlay" style="display: none;">
		<div class="modal-box" style="width: 420px;">
			<div class="modal-header">
				<h2 class="modal-title">태스크 진행 현황</h2>
				<button class="modal-close" onclick="closeDailyCheckModal()">&times;</button>
			</div>
			<div class="modal-body" style="gap: 12px;">
				<div style="text-align: center; margin-bottom: 12px;">
					<p style="font-size: 1rem; font-weight: 600; margin-bottom: 4px;">오늘의 작업 상황을 공유해주세요!</p>
					<div id="checkDate" style="font-size: 0.82rem; color: #4e73df; font-weight: 600;"></div>
				</div>
				<div style="display: flex; justify-content: center; gap: 12px; margin-bottom: 16px;">
					<div class="daily-btn-wrap" data-tooltip="작업 완료">
						<button class="btn-submit daily-check-btn" style="background: #12b76a;" onclick="selectDailyType('done', this)">
							<i class="fas fa-check me-1"></i>완료
						</button>
					</div>
					<div class="daily-btn-wrap" data-tooltip="진행 중 (사유 필수)">
						<button class="btn-submit daily-check-btn" style="background: #f59e0b;" onclick="selectDailyType('progress', this)">
							<i class="fas fa-clock me-1"></i>진행
						</button>
					</div>
					<div class="daily-btn-wrap" data-tooltip="중단 (사유 필수)">
						<button class="btn-submit daily-check-btn" style="background: #dc2626;" onclick="selectDailyType('stop', this)">
							<i class="fas fa-pause me-1"></i>중단
						</button>
					</div>
				</div>
				<div style="display: flex; flex-direction: column; gap: 4px;">
					<label style="font-size: 0.8rem; font-weight: 600;">사유 <span id="reasonRequired" style="color: #dc2626; display: none;">*필수</span></label>
					<textarea id="dailyReason" rows="3" placeholder="사유를 입력해주세요." style="width: 100%; padding: 8px; border: 1px solid #d0d5dd; border-radius: 8px; resize: none;"></textarea>
				</div>
			</div>
			<div class="modal-footer" style="justify-content: center;">
				<button class="btn-cancel" onclick="closeDailyCheckModal()">취소</button>
				<button class="btn-submit" style="background: #4e73df;" onclick="submitDailyCheck()">저장</button>
			</div>
		</div>
	</div>

	<div id="taskDailyModal" class="modal-overlay" style="display: none;">
		<div class="modal-box" style="width: 700px;">
			<div class="modal-header">
				<div id="dailyModalProjectTitle" style="font-size: 1.1rem; font-weight: 800;">-</div>
				<button class="modal-close" onclick="closeTaskDailyModal()">&times;</button>
			</div>
			<div class="modal-body">
				<div style="padding: 10px;">
					<span id="dailyModalStage" class="stage-badge"></span>
					<div id="dailyModalTitle" style="font-size: 1.1rem; font-weight: 700; margin-top: 5px;">-</div>
					<div id="dailyModalPeriod" style="color: #666; font-size: 0.9rem;">-</div>
				</div>
				<div id="dailyGrid" style="display: grid; padding: 15px; overflow-x: auto;"></div>
				<div id="dailyTooltipText" class="daily-tooltip-box" style="margin-top: 10px; padding: 10px; background: #f8f9fa; border-radius: 5px; font-size: 0.85rem;">
					날짜를 클릭하여 상세 사유를 확인하세요.
				</div>
			</div>
			<div class="modal-footer">
				<button class="btn-cancel" onclick="closeTaskDailyModal()">닫기</button>
			</div>
		</div>
	</div>

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