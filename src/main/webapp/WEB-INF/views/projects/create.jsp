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

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projectcreate.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css" type="text/css">

<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=arrow_forward_ios"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

    <main id="content">
        <div class="full-width-stepper shadow-sm">
            <div class="stepper-nav">
                <div class="step-item active" data-step="1">Project 타입</div>
                <div class="step-item" data-step="2">Project 설정</div>
                <div class="step-item" data-step="3">Project 팀 구성</div>
                <div class="step-item" data-step="4">Project 단계 설정</div>
            </div>
        </div>

        <div class="step-content-area">
            <div class="inner-container">

                <div class="step-content active " id="step-panel-1">
                    <jsp:include page="/WEB-INF/views/projects/step1.jsp"/>
                </div>

                <div class="step-content" id="step-panel-2">
                    <jsp:include page="/WEB-INF/views/projects/step2.jsp"/>
                </div>

                <div class="step-content" id="step-panel-3">
                    <jsp:include page="/WEB-INF/views/projects/step3.jsp"/>
                </div>

                <div class="step-content" id="step-panel-4">
                    <jsp:include page="/WEB-INF/views/projects/step4.jsp"/>
                </div>

				<div class="form-footer">
				    <button type="button" class="btn btn-prev" id="btnPrev">
				        <
				    </button>
				    <button type="button" class="btn btn-next" id="btnNext">
				        >
				    </button>
				    <button type="button" class="btn btn-primary px-4" id="btnComplete" style="display:none;">
				        완료
				    </button>
				</div>

            </div>
        </div>
        <input type="hidden" id="myEmpId" value="${empId}">
        <input type="hidden" id="myName" value="${empName}">
        <input type="hidden" id="myDept" value="${empDept}">
        <input type="hidden" id="myGrade" value="${empGrade}">
    </main>

<script src="${pageContext.request.contextPath}/dist/js/projectEnter.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/projectCreate.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/projectCreatestep2.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/projectCreatestep4.js"></script>


</body>
</html>
