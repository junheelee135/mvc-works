<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Project Task</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/projecttask.css"
	type="text/css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/paginate.css"
	type="text/css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
.flatpickr-calendar {
	display: none;
}

.flatpickr-calendar.open {
	display: block;
}

.flatpickr-prev-month svg, .flatpickr-next-month svg {
	display: none;
}

.flatpickr-prev-month::after {
	content: '<';
}

.flatpickr-next-month::after {
	content: '>';
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
				<li class="breadcrumb-item text-muted">Home</li>
				<li class="breadcrumb-item active fw-bold">Projects Task</li>
			</ol>
		</div>

		<div class="task-container">
			<div class="table-header">
				<h5 class="mb-0 fw-bold">${projectTitle}</h5>
				<div class="d-flex gap-2 align-items-center">

					<%-- 검색폼 --%>
					<form method="get"
						action="${pageContext.request.contextPath}/projects/task"
						class="d-flex gap-2 align-items-center">
						<input type="hidden" name="projectId" value="${projectId}">
						<div class="search-box">
							<select name="schType">
								<option value="taskTitle"
									${schType == 'taskTitle' ? 'selected' : ''}>태스크명</option>
								<option value="stgTitle"
									${schType == 'stgTitle' ? 'selected' : ''}>단계명</option>
								<option value="taskStartDate"
									${schType == 'taskStartDate' ? 'selected' : ''}>시작일</option>
								<option value="taskEndDate"
									${schType == 'taskEndDate' ? 'selected' : ''}>종료일</option>
								<option value="taskCreater"
									${schType == 'taskCreater' ? 'selected' : ''}>생성자</option>
								<option value="member" ${schType == 'member' ? 'selected' : ''}>담당자</option>
							</select> <input type="text" name="kwd" placeholder="Task 검색..."
								value="${kwd}"> <i class="fas fa-search"></i>
						</div>
						<button type="submit" class="btn btn-primary">검색</button>
						<button type="button" class="btn btn-secondary"
							onclick="location.href='${pageContext.request.contextPath}/projects/task?projectId=${projectId}'">↺</button>
					</form>

					<c:if test="${isManager}">
						<button type="button" class="btn-icon btn-add"
							onclick="openTaskModal()">
							<i class="fas fa-plus"></i>
						</button>
						<button type="button" class="btn-icon btn-edit" id="editBtn"
							title="편집">
							<i class="fas fa-pencil-alt"></i>
						</button>
					</c:if>


				</div>
			</div>

			<div class="table-wrapper">

				<%-- 왼쪽 태스크 리스트 --%>
				<div class="task-list-side">
					<table class="task-table">
						<thead>
							<tr>
								<th width="45">NO</th>
								<th>TASK 제목</th>
								<th width="110" class="text-center">시작일</th>
								<th width="110" class="text-center">종료일</th>
								<th width="100" class="text-center">상태</th>
								<th width="150" class="text-center">담당자</th>
							</tr>
						</thead>
						<tbody id="taskTableBody">
						<tbody id="taskTableBody">
							<c:choose>
								<c:when test="${not empty list}">
									<c:forEach var="t" items="${list}" varStatus="status">
										<tr data-task-id="${t.taskId}" data-start="${t.taskStartDate}"
											data-end="${t.taskEndDate}" data-emp-task-id="${t.empTaskId}"
											data-emp-id="${t.empId}" data-stg-title="${t.stgTitle}"
											data-progress="${t.taskProgress}">
											<td class="text-center">${status.count}</td>
											<td class="fw-bold task-name" style="cursor: default;">
												<c:if test="${not empty t.stgTitle}">
													<span class="stage-badge" data-stage="${t.stageId}">${t.stgTitle}</span>
												</c:if> ${t.taskTitle}
											</td>
											<td class="text-center"><input type="date"
												class="cell-date" value="${t.taskStartDate}"
												${isManager ? '' : 'disabled'} data-task-id="${t.taskId}"
												data-type="startDate"></td>
											<td class="text-center"><input type="date"
												class="cell-date" value="${t.taskEndDate}"
												${isManager ? '' : 'disabled'} data-task-id="${t.taskId}"
												data-type="endDate"></td>
											<td><select class="cell-select status-cell"
												data-status="${t.taskStatus}"
												${isManager ? '' : 'disabled title="편집 권한이 없습니다."'}
												onchange="updateTask('${t.taskId}', 'status', this.value); updateStatusStyle(this)">
													<option value="1" ${t.taskStatus == '1' ? 'selected' : ''}>시작전</option>
													<option value="2" ${t.taskStatus == '2' ? 'selected' : ''}>진행</option>
													<option value="3" ${t.taskStatus == '3' ? 'selected' : ''}>승인대기</option>
													<option value="4" ${t.taskStatus == '4' ? 'selected' : ''}>종료</option>
													<option value="5" ${t.taskStatus == '5' ? 'selected' : ''}>지연</option>
													<option value="6" ${t.taskStatus == '6' ? 'selected' : ''}>중단</option>
											</select></td>

											<td><select class="cell-select cell-assignee"
												data-emp-id="${t.empId}"
												${isManager ? '' : 'disabled title="편집 권한이 없습니다."'}
												onchange="updateTask('${t.taskId}', 'assignee', this.value)">
													<option value="">담당자</option>
													<c:forEach var="m" items="${members}">
														<option value="${m.empId}"
															${m.name == t.name ? 'selected' : ''}>${m.name}
															(${m.role == 'M' ? '매니저' : m.role == 'D' ? '디자이너' : '개발자'})
														</option>
													</c:forEach>
											</select></td>
										</tr>
									</c:forEach>
								</c:when>
								<c:otherwise>
									<tr>
										<td colspan="6" class="text-center text-muted py-4">등록된
											태스크가 없습니다.</td>
									</tr>
								</c:otherwise>
							</c:choose>
						</tbody>
					</table>
				</div>

				<%-- 오른쪽 간트 차트 --%>
				<div class="chart-area">
					<div class="grid-container" id="ganttGrid"></div>
				</div>

			</div>
			<%-- 페이징 --%>
			<div class="d-flex justify-content-center py-4 border-top">
				${dataCount == 0 ? "등록된 Task가 없습니다" : paging}</div>
		</div>
	</main>

	<!-- 생성 모달 -->
	<div id="taskModal" class="modal-overlay" style="display: none;">
		<div class="modal-box">
			<div class="modal-header">
				<h2 class="modal-title">새 Task 생성</h2>
				<button class="modal-close" onclick="closeTaskModal()">&times;</button>
			</div>
			<div class="modal-body">

				<%-- 단계 선택 --%>
				<div class="form-row">
					<div class="form-group full">
						<label>단계 선택 <span class="required">*</span></label> <select
							id="modalStageId">
							<option value="">프로젝트 단계 설정</option>
							<c:forEach var="s" items="${stages}">
								<option value="${s.stageId}">${s.stgTitle}</option>
							</c:forEach>
							<option value="direct">직접 입력</option>
						</select>
					</div>
				</div>

				<%-- 단계 직접입력 (직접 입력 선택 시 노출) --%>
				<div class="form-row" id="directStageRow" style="display: none;">
					<div class="form-group full">
						<label>단계명 직접 입력</label> <input type="text" id="modalDirectStage"
							placeholder="단계명을 입력하세요">
					</div>
				</div>

				<%-- 태스크명 --%>
				<div class="form-row">
					<div class="form-group full">
						<label>태스크명 <span class="required">*</span></label> <input
							type="text" id="modalTaskTitle" placeholder="Task 명을 입력하세요">
					</div>
				</div>

				<%-- 담당자 --%>
				<div class="form-row">
					<div class="form-group full">
						<label>담당자 <span class="required">*</span></label> <select
							id="modalMember">
							<option value="">담당자 선택</option>
							<c:forEach var="m" items="${members}">
								<option value="${m.empId}">${m.name}(${m.role == 'M' ? '매니저' : m.role == 'D' ? '디자이너' : '개발자'})
								</option>
							</c:forEach>
						</select>
					</div>
				</div>

				<%-- 시작일 / 종료일 --%>
				<div class="form-row">
					<div class="form-group">
						<label>시작일 <span class="required">*</span></label> <input
							type="date" id="modalStartDate">
					</div>
					<div class="form-group">
						<label>종료일 <span class="required">*</span></label> <input
							type="date" id="modalEndDate">
					</div>
				</div>

				<%-- 설명 --%>
				<div class="form-row">
					<div class="form-group full">
						<label>설명</label> <input type="text" id="modalTaskDesc"
							placeholder="Task 설명을 입력하세요">
					</div>
				</div>

			</div>
			<div class="modal-footer">
				<button class="btn-cancel" onclick="closeTaskModal()">취소</button>
				<button class="btn-submit" onclick="submitTask()">생성</button>
			</div>
		</div>
	</div>

	<!-- 날짜별 진행 현황 모달 -->
	<div id="taskDailyModal" class="modal-overlay" style="display: none;">
		<div class="modal-box" style="width: 700px;">
			<div class="modal-header">
				<div style="display: flex; flex-direction: column; gap: 2px;">
					<%-- 1줄: 프로젝트 제목 크게 --%>
					<div style="font-size: 1.2rem; font-weight: 800; color: #1d2939;"
						id="dailyModalProjectTitle">-</div>
				</div>
				<button class="modal-close" onclick="closeTaskDailyModal()">&times;</button>
			</div>

			<div class="modal-body" style="gap: 6px;">
				<%-- 태스크 정보 --%>
				<div style="padding: 12px 14px;">
					<%-- 1줄: 단계 + Task 제목 --%>
					<div
						style="display: flex; align-items: center; gap: 8px; margin-bottom: 15px;">
						<span
							style="font-size: 0.95rem; font-weight: 700; border-radius: 20px; background: #eff4ff; color: #4e73df; white-space: nowrap;"
							id="dailyModalStage"></span>
					</div>
					<div
						style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
						<span
							style="font-size: 0.92rem; font-weight: 600; color: var(--text-muted);">제목
							: </span> <span
							style="font-size: 1.05rem; font-weight: 700; color: #1d2939; flex: 1;"
							id="dailyModalTitle">-</span>
					</div>
					<%-- 2줄: Task 기간 --%>
					<div
						style="display: flex; align-items: center; gap: 6px; margin-bottom: 6px;">
						<span
							style="font-size: 0.95rem; font-weight: 600; color: var(--text-muted);">기간
							: </span> <span
							style="font-size: 1.05rem; font-weight: 600; color: #344054;"
							id="dailyModalPeriod">-</span>
					</div>
				</div>

				<%-- 날짜별 표 --%>
				<div
					style="overflow-x: auto; padding: 12px 14px; align-items: center; border-radius: 8px;">
					<span
						style="font-size: 0.95rem; font-weight: 700; color: #1d2939; flex: 1;">Task
						진행표</span>
					<div id="dailyGrid"
						style="display: grid; padding-top: 10px; min-width: max-content;"></div>
				</div>

				<%-- 툴팁 표시 영역 --%>
				<div id="dailyTooltipText" class="daily-tooltip-box">해당 날짜의 진행
					상태와 사유를 확인하세요.</div>

			</div>


			<div class="modal-footer">
				<button class="btn-cancel" onclick="closeTaskDailyModal()">닫기</button>
			</div>
		</div>
	</div>



	<!-- 날짜 클릭 확인 모달 -->
	<div id="taskDailyCheckModal" class="modal-overlay"
		style="display: none;">
		<div class="modal-box" style="width: 420px;">
			<div class="modal-header">
				<h2 class="modal-title">태스크 진행 현황</h2>
				<button class="modal-close" onclick="closeDailyCheckModal()">&times;</button>
			</div>
			<div class="modal-body" style="gap: 12px;">
				<%-- 날짜 가운데 정렬 --%>
				<div style="text-align: center; margin-bottom: 12px;">
					<p style="font-size: 1rem; font-weight: 600; margin-bottom: 4px;">오늘도
						열심히 작업하셨나요?</p>
					<p style="font-size: 1rem; font-weight: 600; margin-bottom: 4px;">오늘의
						작업 상황을 공유해주세요!</p>
					<div id="checkDate"
						style="font-size: 0.82rem; color: var(--primary-blue); font-weight: 600;"></div>
				</div>

				<%-- 버튼 (툴팁 포함) --%>
				<div
					style="display: flex; justify-content: center; gap: 12px; margin-bottom: 16px; position: relative;">
					<div class="daily-btn-wrap" data-tooltip="오늘 작업량을 모두 처리했을 때">
						<button class="btn-submit daily-check-btn"
							style="background: #12b76a;"
							onclick="selectDailyType('done', this)">
							<i class="fas fa-check me-1"></i>완료
						</button>
					</div>
					<div class="daily-btn-wrap"
						data-tooltip="오늘 작업량을 다 처리하지 못했을 때 (사유 필수)">
						<button class="btn-submit daily-check-btn"
							style="background: #f59e0b;"
							onclick="selectDailyType('progress', this)">
							<i class="fas fa-clock me-1"></i>진행
						</button>
					</div>
					<div class="daily-btn-wrap" data-tooltip="태스크 작업이 중단되었을 때 (사유 필수)">
						<button class="btn-submit daily-check-btn"
							style="background: #dc2626;"
							onclick="selectDailyType('stop', this)">
							<i class="fas fa-pause me-1"></i>중단
						</button>
					</div>
				</div>

				<%-- 사유 입력란 --%>
				<div style="display: flex; flex-direction: column; gap: 4px;">
					<label style="font-size: 0.8rem; font-weight: 600; color: #344054;">
						사유 <span id="reasonRequired"
						style="color: #dc2626; display: none;">*필수</span> <span
						id="reasonOptional" style="color: #aaa; font-weight: 400;">(선택)</span>
					</label>
					<textarea id="dailyReason" rows="3" placeholder="사유를 입력해주세요."
						style="width: 100%; padding: 8px 10px; border: 1px solid #d0d5dd; border-radius: 8px; font-size: 0.85rem; resize: none; outline: none; box-sizing: border-box;"></textarea>
				</div>
			</div>
			<div class="modal-footer" style="justify-content: center; gap: 12px;">
				<button class="btn-cancel" onclick="closeDailyCheckModal()">취소</button>
				<button class="btn-submit" style="background: #4e73df;"
					onclick="submitDailyCheck()">저장</button>
			</div>
		</div>
	</div>

	<%-- JS 변수 전달 --%>
	<input type="hidden" id="hiddenProjectId" value="${projectId}">
	<input type="hidden" id="hiddenIsManager" value="${isManager}">
	<input type="hidden" id="hiddenProjectStart" value="${projectStart}">
	<input type="hidden" id="hiddenProjectEnd" value="${projectEnd}">
	<input type="hidden" id="hiddenLoginEmpId" value="${loginEmpId}">
	<input type="hidden" id="hiddenProjectTitle" value="${projectTitle}">
	<input type="hidden" id="hiddenProjectStatus" value="${projectStatus}">

	<script>
		const contextPath = '${pageContext.request.contextPath}';
	</script>

	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.js"></script>
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/l10n/ko.js"></script>

	<%-- 외부 스크립트 --%>
	<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
	<script src="${pageContext.request.contextPath}/dist/js/tasklist.js"></script>
	<script
		src="${pageContext.request.contextPath}/dist/js/projectEnter.js"></script>
	<script src="${pageContext.request.contextPath}/dist/js/projectdate.js"></script>

</body>
</html>
