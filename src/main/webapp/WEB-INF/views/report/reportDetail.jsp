<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>주간보고서 상세</title>
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
            <i class="bi bi-file-earmark-text rp-title-icon"></i>
            <h2>보고서 상세보기</h2>
        </div>

        <div class="rp-section-card">
            <div class="rp-section-header">
                <h5>
                    <i class="bi bi-file-earmark-text"></i>
                    보고서 내용
                </h5>
                <c:choose>
                    <c:when test="${dto.feedbackCount > 0}">
                        <span class="rp-result-badge rp-badge-done">
                            <span class="rp-dot"></span> 피드백 완료
                        </span>
                    </c:when>
                    <c:otherwise>
                        <span class="rp-badge rp-badge-pending">피드백 미작성</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="rp-section-body">

                <!-- 제목 + 첨부파일 -->
                <div class="rp-detail-title-row">
                    <div class="rp-detail-title">${dto.subject}</div>
                    <c:if test="${not empty dto.fileList}">
                    <div class="rp-attach-dropdown-wrap">
                        <button type="button" class="rp-attach-toggle" onclick="rpToggleAttach(this)"
                                title="첨부파일 ${fn:length(dto.fileList)}개">
                            <i class="bi bi-paperclip"></i>
                            <span class="rp-attach-count">${fn:length(dto.fileList)}</span>
                        </button>
                        <div class="rp-attach-dropdown" style="display:none;">
                            <div class="rp-attach-dropdown-title">
                                <i class="bi bi-paperclip"></i> 첨부파일
                            </div>
                            <ul class="rp-attach-dropdown-list">
                                <c:forEach var="f" items="${dto.fileList}">
                                <li>
                                    <i class="bi bi-file-earmark"></i>
                                    <a href="${pageContext.request.contextPath}/report/file/download?filenum=${f.filenum}">
                                        ${f.originalfilename}
                                    </a>
                                    <span class="rp-attach-size">
                                        (<fmt:formatNumber value="${f.filesize / 1024}" maxFractionDigits="1"/> KB)
                                    </span>
                                </li>
                                </c:forEach>
                            </ul>
                        </div>
                    </div>
                    </c:if>
                </div>

                <!-- 메타 정보 -->
                <table class="rp-meta-table">
                    <tbody>
                        <tr>
                            <th>작성자</th>
                            <td>${dto.writerName}</td>
                            <th>부서/직급</th>
                            <td>${dto.deptName} / ${dto.gradeName}</td>
                        </tr>
                        <tr>
                            <th>사원번호</th>
                            <td>${dto.empId}</td>
                            <th>작성일</th>
                            <td>${dto.regdate}</td>
                        </tr>
                        <tr>
                            <th>보고 기간</th>
                            <td colspan="3">
                                <c:if test="${not empty dto.periodStart and not empty dto.periodEnd}">
                                    <fmt:parseDate value="${dto.periodStart}" pattern="yyyy-MM-dd" var="ps"/>
                                    <fmt:parseDate value="${dto.periodEnd}"   pattern="yyyy-MM-dd" var="pe"/>
                                    <fmt:formatDate value="${ps}" pattern="yyyy년 M월 d일 (EEE)" type="date" dateStyle="full"/>
                                    ~
                                    <fmt:formatDate value="${pe}" pattern="yyyy년 M월 d일 (EEE)" type="date" dateStyle="full"/>
                                </c:if>
                            </td>
                        </tr>
                        <tr>
                            <th>조회수</th>
                            <td>${dto.hitcount}</td>
                            <th>최종 수정일</th>
                            <td>${not empty dto.updatedate ? dto.updatedate : dto.regdate}</td>
                        </tr>
                    </tbody>
                </table>

                <!-- 본문 (Quill readOnly) -->
                <div class="rp-detail-body">
                    <div id="viewer"></div>
                </div>

                <!-- 관리자 피드백 인라인 -->
                <c:if test="${dto.feedbackCount > 0 and not empty inlineFeedback}">
                <div class="rp-feedback-inline">
                    <div class="rp-feedback-inline-header">
                        <h6>
                            <i class="bi bi-chat-left-dots-fill"></i>
                            관리자 피드백
                        </h6>
                        <a href="${pageContext.request.contextPath}/report/feedback/detail?filenum=${inlineFeedback.filenum}"
                           class="rp-btn rp-btn-secondary rp-btn-sm">
                            <i class="bi bi-box-arrow-up-right"></i> 전체보기
                        </a>
                    </div>
                    <div class="rp-feedback-inline-body">
                        <div id="inlineViewer"></div>
                    </div>
                    <div class="rp-feedback-inline-footer">
                        <div class="rp-feedback-footer-left">
                            <span><i class="bi bi-person" style="margin-right:3px;"></i>${inlineFeedback.writerName}</span>
                            <span><i class="bi bi-clock"  style="margin-right:3px;"></i>${inlineFeedback.regdate}</span>
                        </div>
                        <c:if test="${not empty inlineFeedback.fileList}">
                        <div class="rp-feedback-footer-files">
                            <c:forEach var="ff" items="${inlineFeedback.fileList}">
                            <a href="${pageContext.request.contextPath}/report/file/download?filenum=${ff.filenum}"
                               class="rp-feedback-file-link" title="${ff.originalfilename}">
                                <i class="bi bi-file-earmark-arrow-down"></i>
                                ${ff.originalfilename}
                            </a>
                            </c:forEach>
                        </div>
                        </c:if>
                    </div>
                </div>
                </c:if>

                <!-- 하단 액션 버튼 -->
                <div class="rp-detail-actions">
                    <div class="rp-actions-left">
                        <a href="${pageContext.request.contextPath}/report/list"
                           class="rp-btn rp-btn-secondary">
                            <i class="bi bi-list-ul"></i> 목록
                        </a>
                    </div>
                    <div class="rp-actions-right">
                        <%-- 피드백 남기기: levelCode 51 이상만 노출 --%>
                        <c:if test="${userLevel >= 51}">
                        <a href="${pageContext.request.contextPath}/report/feedback/write?refFilenum=${dto.filenum}"
                           class="rp-btn rp-btn-success">
                            <i class="bi bi-chat-left-dots"></i> 피드백 남기기
                        </a>
                        </c:if>
                        <%-- 수정/삭제: 본인 또는 99 관리자 --%>
                        <c:if test="${sessionEmpId == dto.empId or userLevel >= 99}">
                        <a href="${pageContext.request.contextPath}/report/edit?filenum=${dto.filenum}"
                           class="rp-btn rp-btn-secondary">
                            <i class="bi bi-pencil"></i> 수정
                        </a>
                        <button type="button" class="rp-btn rp-btn-danger"
                                onclick="rpConfirmDelete(${dto.filenum}, _ctxPath)">
                            <i class="bi bi-trash3"></i> 삭제
                        </button>
                        </c:if>
                    </div>
                </div>

            </div><%-- /rp-section-body --%>
        </div><%-- /rp-section-card --%>

    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/reportDetail.js"></script>
<script>
/* Quill 뷰어 초기화 (JSP EL 주입이 필요하므로 인라인 유지) */
var viewer = new Quill('#viewer', { theme: 'snow', readOnly: true, modules: { toolbar: false } });
viewer.root.innerHTML = '<c:out value="${dto.content}" escapeXml="false"/>';

/* 인라인 피드백 뷰어 */
<c:if test="${dto.feedbackCount > 0 and not empty inlineFeedback}">
var inlineViewer = new Quill('#inlineViewer', { theme: 'snow', readOnly: true, modules: { toolbar: false } });
inlineViewer.root.innerHTML = '<c:out value="${inlineFeedback.content}" escapeXml="false"/>';
</c:if>

/* contextPath를 변수로 넘겨 외부 함수에서 사용 */
var _ctxPath = '${pageContext.request.contextPath}';
</script>

</body>
</html>
