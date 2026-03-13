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
      <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="#" class="text-decoration-none text-muted">Projects</a>
                    </li>
                    <li class="breadcrumb-item active fw-bold text-primary">ERP 시스템 고도화</li>
                </ol>
            </nav>
    
    
            <div class="toolbar">
                <div class="search-group">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="태스크 검색...">
                </div>
                <button class="btn-icon btn-refresh"><i class="fas fa-sync-alt"></i></button>
                <button class="btn-icon btn-add"><i class="fas fa-plus"></i></button>
                <button class="btn-icon btn-edit"><i class="fas fa-pencil-alt"></i></button>
                <button class="btn-icon btn-delete"><i class="fas fa-trash-alt"></i></button>
            </div>

        <div class="gantt-main">
            <div class="task-sidebar">
                <div class="task-list-header">태스크 목록</div>
                <div class="task-item"><i class="fas fa-clipboard-list"></i> 요구사항 분석</div>
                <div class="task-item"><i class="fas fa-pen-nib"></i> UI/UX 디자인</div>
                <div class="task-item"><i class="fas fa-code"></i> 프론트엔드 개발</div>
                <div class="task-item"><i class="fas fa-server"></i> 백엔드 시스템 설계</div>
                <div class="task-item"><i class="fas fa-vial"></i> QA 및 테스트</div>
                <div class="task-item"><i class="fas fa-rocket"></i> 최종 배포</div>
            </div>

			<div class="timeline-container">
			    <div class="grid-row grid-header">
			        <script>
			            const days = 31;
			            for (let i = 1; i <= days; i++) {
			                const weekendClass = (i % 7 === 6 || i % 7 === 0) ? 'is-weekend' : '';
			                document.write(`<div class="grid-cell ${weekendClass}">${i}</div>`);
			            }
			        </script>
			    </div>
			
			    <script>
			        const rows = 6;
			        const tasks = [
			            { start: 0, width: 5, name: "요구사항 분석", icon: "fa-clipboard-list" },
			            { start: 4, width: 6, name: "UI/UX 디자인", icon: "fa-pen-nib" },
			            { start: 9, width: 10, name: "프론트엔드 개발", icon: "fa-code" },
			            { start: 8, width: 12, name: "백엔드 시스템 설계", icon: "fa-server" },
			            { start: 20, width: 7, name: "QA 및 테스트", icon: "fa-vial" },
			            { start: 26, width: 4, name: "최종 배포", icon: "fa-rocket" }
			        ];
			
			        const cellWidth = 40; // CSS의 --cell-width와 반드시 일치
			
			        for (let r = 0; r < rows; r++) {
			            document.write('<div class="grid-row">');
			            
			            // 배경 칸 그리기
			            for (let c = 1; c <= days; c++) {
			                const weekendClass = (c % 7 === 6 || c % 7 === 0) ? 'is-weekend' : '';
			                document.write(`<div class="grid-cell ${weekendClass}"></div>`);
			            }
			            
			            // 막대기 그리기 (위치 계산 수정)
			            const task = tasks[r];
			            // 막대가 칸의 보더와 겹치지 않게 미세 조정 (+1px)
			            const leftPos = (task.start * cellWidth); 
			            const barWidth = (task.width * cellWidth); 
			            
			            document.write(`
			                <div class="gantt-bar" style="left: ${leftPos}px; width: ${barWidth}px;">
			                    <i class="fas ${task.icon}"></i> ${task.name}
			                </div>
			            `);
			            document.write('</div>');
			        }
			    </script>
			</div>
			

            </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>
