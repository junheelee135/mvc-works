<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>피드백 수정</title>
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
            <i class="bi bi-chat-left-dots rp-title-icon" style="color:#198754;"></i>
            <h2>관리자 피드백 수정</h2>
        </div>

        <c:if test="${param.error == '1'}">
        <div class="rp-alert rp-alert-danger">
            <i class="bi bi-exclamation-triangle"></i> 저장 중 오류가 발생했습니다. 다시 시도해 주세요.
        </div>
        </c:if>

        <!-- 원본 보고서 참조 카드 -->
        <div class="rp-ref-card">
            <div class="rp-ref-header">
                <h6><i class="bi bi-file-earmark-text"></i> 원본 보고서 (참조)</h6>
                <a href="${pageContext.request.contextPath}/report/detail?filenum=${refDto.filenum}"
                   class="rp-btn rp-btn-secondary rp-btn-sm" target="_blank">
                    <i class="bi bi-box-arrow-up-right"></i> 원본 보기
                </a>
            </div>
            <div class="rp-ref-body">
                <div class="rp-ref-item">
                    <strong>제목</strong> ${refDto.subject}
                </div>
                <div class="rp-ref-item">
                    <strong>작성자</strong> ${refDto.writerName}
                    <c:if test="${not empty refDto.deptName}"> (${refDto.deptName})</c:if>
                </div>
                <div class="rp-ref-item">
                    <strong>보고 기간</strong> ${refDto.periodStart} ~ ${refDto.periodEnd}
                </div>
            </div>
        </div>

        <!-- 피드백 수정 카드 -->
        <div class="rp-section-card">
            <div class="rp-section-header">
                <h5>
                    <i class="bi bi-chat-left-dots" style="color:#198754;"></i>
                    피드백 수정
                </h5>
                <span style="font-size:0.78rem; color:#94a3b8;">
                    <i class="bi bi-info-circle"></i>&nbsp;
                    <span style="color:#dc3545;">*</span> 표시는 필수 입력 항목입니다.
                </span>
            </div>
            <div class="rp-section-body">

                <form id="feedbackEditForm"
                      action="${pageContext.request.contextPath}/report/feedback/edit"
                      method="post" enctype="multipart/form-data">

                    <input type="hidden" name="filenum" value="${dto.filenum}">
                    <input type="hidden" name="parent"  value="${dto.parent}">

                    <table class="rp-form-table">
                        <colgroup>
                            <col style="width:120px;">
                            <col>
                            <col style="width:120px;">
                            <col>
                        </colgroup>
                        <tbody>
                            <tr>
                                <th>피드백 제목<span class="rp-required">*</span></th>
                                <td colspan="3">
                                    <input type="text" name="subject" id="feedbackSubject"
                                           value="${dto.subject}"
                                           placeholder="피드백 제목을 입력하세요"
                                           maxlength="255" required>
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
                                <th>대상 직원</th>
                                <td colspan="3">
                                    <input type="text"
                                           value="${refDto.writerName} (${refDto.empId}<c:if test="${not empty refDto.deptName}"> / ${refDto.deptName}</c:if>)"
                                           readonly>
                                </td>
                            </tr>
                            <tr>
                                <th>인사평가<span class="rp-required">*</span></th>
                                <td colspan="3">
                                    <select name="evaluation" id="evaluation" required
                                            style="width:200px;" onchange="rpUpdateEvalBadge(this.value)">
                                        <option value="">-- 평가 선택 --</option>
                                        <option value="POSITIVE" <c:if test="${dto.evaluation == 'POSITIVE'}">selected</c:if>>긍정 (우수)</option>
                                        <option value="NORMAL"   <c:if test="${dto.evaluation == 'NORMAL'}">selected</c:if>>평범 (보통)</option>
                                        <option value="NEGATIVE" <c:if test="${dto.evaluation == 'NEGATIVE'}">selected</c:if>>부정 (미흡)</option>
                                    </select>
                                    <span id="evalBadge" style="margin-left:10px;"></span>
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    <!-- Quill 에디터 -->
                    <div class="rp-editor-wrap feedback">
                        <div class="rp-editor-label">
                            <i class="bi bi-chat-left-dots"></i>
                            피드백 내용<span class="rp-required">*</span>
                        </div>
                        <div id="editor-feedback"></div>
                        <input type="hidden" name="content" id="hiddenFeedbackContent">
                    </div>

                    <!-- 기존 첨부파일 -->
                    <c:if test="${not empty dto.fileList}">
                    <div class="rp-attach-area">
                        <div class="rp-attach-label">
                            <i class="bi bi-paperclip"></i> 기존 첨부파일
                        </div>
                        <ul class="rp-attach-list">
                            <c:forEach var="f" items="${dto.fileList}">
                            <li id="file_${f.filenum}">
                                <i class="bi bi-file-earmark"></i>
                                <a href="${pageContext.request.contextPath}/report/file/download?filenum=${f.filenum}">
                                    ${f.originalfilename}
                                </a>
                                <span class="rp-attach-size">
                                    (<fmt:formatNumber value="${f.filesize / 1024}" maxFractionDigits="1"/> KB)
                                </span>
                                <button type="button" class="rp-btn rp-btn-danger rp-btn-sm"
                                        style="margin-left:8px;"
                                        onclick="rpRemoveFile(this, ${f.filenum})">
                                    <i class="bi bi-x"></i> 삭제
                                </button>
                                <input type="hidden" name="deleteFilenum" value="" class="del-fnum">
                            </li>
                            </c:forEach>
                        </ul>
                    </div>
                    </c:if>

                    <!-- 새 파일 추가 -->
                    <div class="rp-attach-area">
                        <div class="rp-attach-label">
                            <i class="bi bi-plus-circle"></i> 파일 추가 첨부
                        </div>
                        <input type="file" name="newFiles" multiple style="font-size:0.85rem;"
                               onchange="rpCheckFileCount(this)">
                        <div class="rp-attach-hint">
                            <i class="bi bi-info-circle"></i>
                            파일은 최대 10MB, 최대 5개까지 첨부 가능합니다.
                        </div>
                    </div>

                    <!-- 하단 버튼 -->
                    <div class="rp-form-actions">
                        <a href="${pageContext.request.contextPath}/report/feedback/detail?filenum=${dto.filenum}"
                           class="rp-btn rp-btn-secondary">
                            <i class="bi bi-x-lg"></i> 취소
                        </a>
                        <button type="button" class="rp-btn rp-btn-success"
                                onclick="rpSubmitFeedbackEdit()">
                            <i class="bi bi-check-lg"></i> 수정 완료
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
<script src="${pageContext.request.contextPath}/dist/js/feedbackForm.js"></script>
<script>
/* Quill 에디터 초기화 (전역 변수로 feedbackForm.js에서 참조) */
var quillFeedback = new Quill('#editor-feedback', {
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
    }
});

/* 기존 본문 세팅 (JSP EL 주입) */
quillFeedback.root.innerHTML = '<c:out value="${dto.content}" escapeXml="false"/>';

/* 기존 인사평가 배지 초기 표시 */
rpUpdateEvalBadge('${dto.evaluation}');
</script>
</body>
</html>
