<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Project Task</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projecttask.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css" type="text/css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

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
            <h5 class="mb-0 fw-bold">Project Task</h5>
            <div class="d-flex gap-2 align-items-center">

                <%-- 검색폼 --%>
                <form method="get" action="${pageContext.request.contextPath}/projects/task" class="d-flex gap-2 align-items-center">
                    <input type="hidden" name="projectId" value="${projectId}">
                    <div class="search-box">
                        <select name="schType">
                            <option value="taskTitle"     ${schType == 'taskTitle'     ? 'selected' : ''}>태스크명</option>
                            <option value="stgTitle"      ${schType == 'stgTitle'      ? 'selected' : ''}>단계명</option>
                            <option value="taskStartDate" ${schType == 'taskStartDate' ? 'selected' : ''}>시작일</option>
                            <option value="taskEndDate"   ${schType == 'taskEndDate'   ? 'selected' : ''}>종료일</option>
                            <option value="taskCreater"   ${schType == 'taskCreater'   ? 'selected' : ''}>생성자</option>
                            <option value="member"        ${schType == 'member'        ? 'selected' : ''}>담당자</option>
                        </select>
                        <input type="text" name="kwd" placeholder="태스크 검색..." value="${kwd}">
                        <i class="fas fa-search"></i>
                    </div>
                    <button type="submit" class="btn btn-primary">검색</button>
                    <button type="button" class="btn btn-secondary"
                        onclick="location.href='${pageContext.request.contextPath}/projects/task'">↺</button>
                </form>

                <button type="button" class="btn-icon btn-add" onclick="openTaskModal()"><i class="fas fa-plus"></i></button>
                <button type="button" class="btn-icon btn-edit"><i class="fas fa-pencil-alt"></i></button>
                <button type="button" class="btn-icon btn-delete"><i class="fas fa-trash-alt"></i></button>
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
                            <th width="100" class="text-center">담당자</th>
                        </tr>
                    </thead>
                    <tbody id="taskTableBody">
                        <tbody id="taskTableBody">
						    <c:choose>
						        <c:when test="${not empty list}">
						            <c:forEach var="t" items="${list}" varStatus="status">
						            <tr data-task-id="${t.taskId}" data-start="${t.taskStartDate}" data-end="${t.taskEndDate}">
						                <td class="text-center">${status.count}</td>
						                <td class="fw-bold task-name"
						                    onclick="location.href='${pageContext.request.contextPath}/projects/taskarticle?taskId=${t.taskId}'">
						                    <c:if test="${not empty t.stgTitle}">
						                        <span class="stage-badge">${t.stgTitle}</span>
						                    </c:if>
						                    ${t.taskTitle}
						                </td>
						                <td class="text-center">
						                    <input type="date" class="cell-date" value="${t.taskStartDate}"
						                           onchange="updateTask('${t.taskId}', 'startDate', this.value)">
						                </td>
						                <td class="text-center">
						                    <input type="date" class="cell-date" value="${t.taskEndDate}"
						                           onchange="updateTask('${t.taskId}', 'endDate', this.value)">
						                </td>
						                <td>
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
						                
						             	<td>
						                    <select class="cell-select" onchange="updateTask('${t.taskId}', 'assignee', this.value)">
						                        <option value="">담당자</option>	                        						                        
											        <c:forEach var="m" items="${members}">
												        <option value="${m.EMPID}">
												            ${m.NAME} (${m.ROLE == 'M' ? '매니저' : m.ROLE == 'D' ? '디자이너' : '개발자'})
												        </option>
												    </c:forEach>
						                    </select>
						                </td>
						            </tr>
						            </c:forEach>
						        </c:when>
						        <c:otherwise>
						            <tr>
						                <td colspan="6" class="text-center text-muted py-4">등록된 태스크가 없습니다.</td>
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
                ${dataCount == 0 ? "등록된 게시글이 없습니다" : paging}
            </div>
    </div>
</main>

		<!-- 생성 모달 -->
		<div id="taskModal" class="modal-overlay" style="display:none;">
		    <div class="modal-box">
		        <div class="modal-header">
		            <h2 class="modal-title">새 태스크 생성</h2>
		            <button class="modal-close" onclick="closeTaskModal()">&times;</button>
		        </div>
		        <div class="modal-body">
		
		            <%-- 단계 선택 --%>
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
		
		            <%-- 단계 직접입력 (직접 입력 선택 시 노출) --%>
		            <div class="form-row" id="directStageRow" style="display:none;">
		                <div class="form-group full">
		                    <label>단계명 직접 입력</label>
		                    <input type="text" id="modalDirectStage" placeholder="단계명을 입력하세요">
		                </div>
		            </div>
		
		            <%-- 태스크명 --%>
		            <div class="form-row">
		                <div class="form-group full">
		                    <label>태스크명 <span class="required">*</span></label>
		                    <input type="text" id="modalTaskTitle" placeholder="태스크명을 입력하세요">
		                </div>
		            </div>
		
		            <%-- 담당자 --%>
		            <div class="form-row">
		                <div class="form-group full">
		                    <label>담당자 <span class="required">*</span></label>
							<select id="modalMember">
							    <option value="">담당자 선택</option>
							    <c:forEach var="m" items="${members}">
							        <option value="${m.EMPID}">
							            ${m.NAME} (${m.ROLE == 'M' ? '매니저' : m.ROLE == 'D' ? '디자이너' : '개발자'})
							        </option>
							    </c:forEach>
							</select>
		                </div>
		            </div>
		
		            <%-- 시작일 / 종료일 --%>
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
		
		            <%-- 설명 --%>
		            <div class="form-row">
		                <div class="form-group full">
		                    <label>설명</label>
		                    <input type="text" id="modalTaskDesc" placeholder="태스크 설명을 입력하세요">
		                </div>
		            </div>
		
		        </div>
		        <div class="modal-footer">
		            <button class="btn-cancel" onclick="closeTaskModal()">취소</button>
		            <button class="btn-submit" onclick="submitTask()">생성</button>
		        </div>
		    </div>
		</div>

<%-- JS 변수 전달 --%>
<input type="hidden" id="hiddenProjectId" value="${projectId}">
<script>
    const contextPath = '${pageContext.request.contextPath}';
</script>

<%-- 외부 스크립트 --%>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="${pageContext.request.contextPath}/dist/js/tasklist.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/projectEnter.js"></script>

</body>
</html>
