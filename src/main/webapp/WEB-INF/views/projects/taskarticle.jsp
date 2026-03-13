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

<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/projecttask.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css" type="text/css">

<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&icon_names=arrow_forward_ios" />
    
    <style>
        :root {
            --tt-primary-blue: #0061ff;
            --tt-primary-amber: #f59e0b;
            --tt-primary-red: #ef4444;
            --tt-primary-green: #10b981;
            --tt-primary-sky: #0ea5e9;
            --tt-border-color: #eaecf0;
            --tt-text-main: #1d2939;
            --tt-text-muted: #667085;
            --tt-sidebar-width: 280px;
            --tt-cell-size: 50px;
            --tt-header-height: 50px;
        }

        #main-container-tt {
            padding: 24px;
            background-color: #f8fafc;
        }

        .tt-toolbar {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 8px;
            margin-bottom: 24px;
        }

        .tt-search-group {
            display: flex;
            align-items: center;
            border: 1px solid var(--tt-border-color);
            border-radius: 8px;
            padding: 0 12px;
            background: #fff;
            width: 260px;
        }

        .tt-search-group input {
            border: none;
            padding: 8px 0;
            font-size: 0.9rem;
            outline: none;
            width: 100%;
        }

        .tt-search-group i {
            color: var(--tt-text-muted);
            margin-right: 8px;
        }

        .tt-btn-search {
            background-color: #344054;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 600;
        }

        .tt-btn-icon {
            width: 38px;
            height: 38px;
            border-radius: 8px;
            border: none;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }

        .tt-btn-add { background-color: var(--tt-primary-blue); }
        .tt-btn-edit { background-color: var(--tt-primary-amber); }
        .tt-btn-delete { background-color: var(--tt-primary-red); }
        .tt-btn-refresh {
            background-color: #fff;
            border: 1px solid var(--tt-border-color);
            color: var(--tt-text-muted);
        }

        .tt-wrapper {
            display: flex;
            border: 1px solid var(--tt-border-color);
            border-radius: 8px;
            overflow: hidden;
            background: #fff;
            max-height: 600px;
        }

        .tt-sidebar {
            width: var(--tt-sidebar-width);
            flex-shrink: 0;
            border-right: 2px solid var(--tt-border-color);
            background: #fff;
            position: sticky;
            left: 0;
            z-index: 20;
        }

        .tt-header {
            height: var(--tt-header-height);
            background-color: #f9fafb;
            border-bottom: 2px solid var(--tt-border-color);
            display: flex;
            align-items: center;
            padding: 0 16px;
            font-weight: 700;
            font-size: 0.75rem;
            color: var(--tt-text-muted);
            text-transform: uppercase;
            position: sticky;
            top: 0;
            z-index: 30;
        }

        .tt-item {
            height: 50px;
            display: flex;
            align-items: center;
            padding: 0 16px;
            border-bottom: 1px solid var(--tt-border-color);
            font-size: 0.85rem;
            font-weight: 600;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            background: #fff;
        }

        .tt-item i {
            margin-right: 10px;
            color: var(--tt-primary-blue);
        }

        .tt-grid-area {
            flex-grow: 1;
            overflow: auto;
            position: relative;
        }

        .tt-grid-container {
            display: grid;
            grid-template-columns: repeat(31, var(--tt-cell-size));
        }

        .tt-grid-header-cell {
            height: var(--tt-header-height);
            background-color: #f9fafb;
            border-right: 1px solid var(--tt-border-color);
            border-bottom: 2px solid var(--tt-border-color);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.75rem;
            color: var(--tt-text-muted);
            position: sticky;
            top: 0;
            z-index: 10;
        }

        .tt-grid-cell {
            width: var(--tt-cell-size);
            height: 50px;
            border-right: 1px solid var(--tt-border-color);
            border-bottom: 1px solid var(--tt-border-color);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background 0.1s;
        }

        .tt-grid-cell:hover { background-color: #f1f5f9; }

        .tt-status-box {
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-size: 0.55rem;
            font-weight: 800;
            color: #fff;
            line-height: 1;
        }

        .tt-status-dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background: #fff;
            margin-bottom: 3px;
        }

        .bg-done { background-color: var(--tt-primary-green); }
        .bg-inprogress { background-color: var(--tt-primary-blue); }
        .bg-hold { background-color: var(--tt-primary-amber); }
        .bg-working { background-color: var(--tt-primary-sky); }
        .bg-delayed { background-color: var(--tt-primary-red); }
        .is-weekend { background-color: #f8fafc; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

    <main id="main-content">
        <div id="main-container-tt">
            <div class="tt-toolbar">
                <div class="tt-search-group">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="업무 검색...">
                </div>
                <button class="tt-btn-search">Search</button>
                <button class="tt-btn-icon tt-btn-add"><i class="fas fa-plus"></i></button>
                <button class="tt-btn-icon tt-btn-edit"><i class="fas fa-pencil-alt"></i></button>
                <button class="tt-btn-icon tt-btn-delete"><i class="fas fa-trash-alt"></i></button>
                <button class="tt-btn-icon tt-btn-refresh"><i class="fas fa-sync-alt"></i></button>
            </div>

            <div class="tt-wrapper shadow-sm">
                <div class="tt-sidebar">
                    <div class="tt-header">나의 업무 리스트</div>
                    <div class="tt-item"><i class="fas fa-clipboard-list"></i> 요구사항 정의서 작성</div>
                    <div class="tt-item"><i class="fas fa-palette"></i> 메인 UI 디자인 시안</div>
                    <div class="tt-item"><i class="fas fa-code"></i> 로그인 API 연동</div>
                    <div class="tt-item"><i class="fas fa-server"></i> DB 스키마 설계</div>
                    <div class="tt-item"><i class="fas fa-vial"></i> 단위 테스트 수행</div>
                    <div class="tt-item"><i class="fas fa-rocket"></i> 베타 버전 배포</div>
                </div>

                <div class="tt-grid-area">
                    <div class="tt-grid-container">
                        <script>
                            for (let i = 1; i <= 31; i++) {
                                const isWeekend = (i % 7 === 6 || i % 7 === 0) ? 'is-weekend' : '';
                                document.write(`<div class="tt-grid-header-cell ${isWeekend}">${i}</div>`);
                            }
                        </script>

                        <div class="tt-grid-cell"><div class="tt-status-box bg-done"><div class="tt-status-dot"></div>DONE</div></div>
                        <div class="tt-grid-cell"><div class="tt-status-box bg-done"><div class="tt-status-dot"></div>DONE</div></div>
                        <div class="tt-grid-cell"><div class="tt-status-box bg-inprogress"><div class="tt-status-dot"></div>IN PROGRESS</div></div>
                        <script>for (let i = 4; i <= 31; i++) document.write('<div class="tt-grid-cell"></div>');</script>

                        <div class="tt-grid-cell"></div>
                        <div class="tt-grid-cell"><div class="tt-status-box bg-hold"><div class="tt-status-dot"></div>HOLD</div></div>
                        <div class="tt-grid-cell"><div class="tt-status-box bg-working"><div class="tt-status-dot"></div>WORKING</div></div>
                        <script>for (let i = 4; i <= 31; i++) document.write('<div class="tt-grid-cell"></div>');</script>

                        <div class="tt-grid-cell"><div class="tt-status-box bg-delayed"><div class="tt-status-dot"></div>DELAYED</div></div>
                        <script>for (let i = 2; i <= 31; i++) document.write('<div class="tt-grid-cell"></div>');</script>

                        <script>
                            for (let r = 0; r < 3; r++) {
                                for (let i = 1; i <= 31; i++) document.write('<div class="tt-grid-cell"></div>');
                            }
                        </script>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>