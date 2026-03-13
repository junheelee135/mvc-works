<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주간보고서 작성</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/report.css" type="text/css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css">
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<div class="rp-content">
    <header>
        <jsp:include page="/WEB-INF/views/layout/header.jsp"/>
    </header>

    <div class="rp-main">

        <div class="rp-page-title">
            <i class="bi bi-pencil-square rp-title-icon"></i>
            <h2>주간보고서 작성</h2>
        </div>

        <c:if test="${param.error == '1'}">
        <div class="rp-alert rp-alert-danger">
            <i class="bi bi-exclamation-triangle"></i> 저장 중 오류가 발생했습니다. 다시 시도해 주세요.
        </div>
        </c:if>

        <div class="rp-section-card">
            <div class="rp-section-header">
                <h5><i class="bi bi-pencil-square"></i> 보고서 작성</h5>
                <span style="font-size:0.78rem; color:#94a3b8;">
                    <i class="bi bi-info-circle"></i>&nbsp;
                    <span style="color:#dc3545;">*</span> 표시는 필수 입력 항목입니다.
                </span>
            </div>
            <div class="rp-section-body">

                <form id="reportWriteForm"
                      action="${pageContext.request.contextPath}/report/write"
                      method="post" enctype="multipart/form-data">

                    <table class="rp-form-table">
                        <colgroup>
                            <col style="width:120px;">
                            <col>
                            <col style="width:120px;">
                            <col>
                        </colgroup>
                        <tbody>
                            <tr>
                                <th>제목<span class="rp-required">*</span></th>
                                <td colspan="3">
                                    <input type="text" name="subject" id="subject"
                                           placeholder="보고서 제목을 입력하세요"
                                           maxlength="255" required style="max-width:100%;">
                                </td>
                            </tr>
                            <tr>
                                <th>작성자</th>
                                <td>
                                    <input type="text" value="${sessionScope.member.name}" readonly>
                                </td>
                                <th>사원번호</th>
                                <td>
                                    <input type="text" value="${sessionScope.member.empId}" readonly>
                                </td>
                            </tr>
                            <tr>
                                <th>보고 기간<span class="rp-required">*</span></th>
                                <td colspan="3">
                                    <div style="display:flex; align-items:center; gap:8px;">
                                        <input type="date" name="periodStart" id="periodStart"
                                               style="width:160px;" required>
                                        <span style="color:#94a3b8; font-size:0.85rem;">~</span>
                                        <input type="date" name="periodEnd" id="periodEnd"
                                               style="width:160px;" required>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    <!-- Quill 에디터 -->
                    <div class="rp-editor-wrap">
                        <div class="rp-editor-label">
                            <i class="bi bi-align-start"></i>
                            보고 내용<span class="rp-required">*</span>
                        </div>
                        <div id="editor-report"></div>
                        <input type="hidden" name="content" id="hiddenContent">
                    </div>

                    <!-- 파일 첨부 -->
                    <div class="rp-attach-area">
                        <div class="rp-attach-label">
                            <i class="bi bi-paperclip"></i> 파일 첨부
                        </div>
                        <input type="file" name="files" id="fileInput" multiple
                               style="font-size:0.85rem;" onchange="rpCheckFileCount(this)">
                        <div class="rp-attach-hint">
                            <i class="bi bi-info-circle"></i>
                            파일은 최대 10MB, 최대 5개까지 첨부 가능합니다.
                        </div>
                    </div>

                    <!-- 하단 버튼 -->
                    <div class="rp-form-actions">
                        <a href="${pageContext.request.contextPath}/report/list"
                           class="rp-btn rp-btn-secondary">
                            <i class="bi bi-x-lg"></i> 취소
                        </a>
                        <button type="button" class="rp-btn rp-btn-primary"
                                onclick="rpSubmitWrite()">
                            <i class="bi bi-check-lg"></i> 등록
                        </button>
                    </div>

                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
<script src="https://cdn.jsdelivr.net/npm/quill-resize-module@2.0.4/dist/resize.js"></script>
<script src="${pageContext.request.contextPath}/dist/posts/qeditor.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/reportForm.js"></script>
<script>
/* Quill 에디터 초기화 (전역 변수로 reportForm.js에서 참조) */
var quillReport = new Quill('#editor-report', {
    theme: 'snow',
    modules: {
        toolbar: [
            [{ 'header': [1, 2, 3, false] }],
            ['bold', 'italic', 'underline', 'strike'],
            [{ 'color': [] }, { 'background': [] }],
            [{ 'list': 'ordered' }, { 'list': 'bullet' }],
            [{ 'align': [] }],
            ['link', 'image'],
            ['clean']
        ],
        resize: {}
    },
    placeholder: '이번 주 업무 내용을 작성해 주세요.\n(주요 업무 / 진행 현황 / 다음 주 계획 / 이슈 사항 등)'
});
</script>
</body>
</html>
