<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>피드백 상세보기</title>
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
            <h2>관리자 피드백 상세보기</h2>
        </div>

        <!-- 원본 보고서 참조 카드 -->
        <div class="rp-ref-card">
            <div class="rp-ref-header">
                <h6><i class="bi bi-file-earmark-text"></i> 원본 보고서 (참조)</h6>
                <a href="${pageContext.request.contextPath}/report/detail?filenum=${feedbackDto.parent}"
                   class="rp-btn rp-btn-secondary rp-btn-sm">
                    <i class="bi bi-box-arrow-up-right"></i> 원본 보고서 보기
                </a>
            </div>
            <div class="rp-ref-body">
                <div class="rp-ref-item">
                    <strong>보고서 제목</strong> ${feedbackDto.refSubject}
                </div>
                <div class="rp-ref-item">
                    <strong>보고자</strong> ${feedbackDto.refWriterName}
                    <c:if test="${not empty feedbackDto.refDeptName}"> (${feedbackDto.refDeptName})</c:if>
                </div>
                <div class="rp-ref-item">
                    <strong>보고 기간</strong> ${feedbackDto.refPeriodStart} ~ ${feedbackDto.refPeriodEnd}
                </div>
            </div>
        </div>

        <!-- 피드백 상세 카드 -->
        <div class="rp-section-card feedback">
            <div class="rp-section-header">
                <h5>
                    <i class="bi bi-chat-left-dots-fill"></i>
                    피드백 내용
                </h5>
                <span class="rp-result-badge rp-badge-feedback">
                    <span class="rp-dot"></span> 관리자 피드백
                </span>
            </div>
            <div class="rp-section-body">

                <!-- 피드백 제목 -->
                <div class="rp-detail-title">${feedbackDto.subject}</div>

                <!-- 메타 정보 -->
                <table class="rp-meta-table">
                    <tbody>
                        <tr>
                            <th>작성자 (관리자)</th>
                            <td>${feedbackDto.writerName}
                                <c:if test="${not empty feedbackDto.deptName}">
                                    (${feedbackDto.deptName})
                                </c:if>
                            </td>
                            <th>작성일</th>
                            <td>${feedbackDto.regdate}</td>
                        </tr>
                        <tr>
                            <th>대상 직원</th>
                            <td>${feedbackDto.refWriterName} (${feedbackDto.refDeptName})</td>
                            <th>조회수</th>
                            <td>${feedbackDto.hitcount}</td>
                        </tr>
                        <%-- 인사평가: 관리자(51 이상)만 표시, 일반 사원(51 미만)에게는 숨김 --%>
                        <c:if test="${userLevel >= 51}">
                        <tr>
                            <th>인사평가</th>
                            <td colspan="3">
                                <c:choose>
                                    <c:when test="${feedbackDto.evaluation == 'POSITIVE'}">
                                        <span class="rp-eval-badge rp-eval-positive">긍정 (우수)</span>
                                    </c:when>
                                    <c:when test="${feedbackDto.evaluation == 'NORMAL'}">
                                        <span class="rp-eval-badge rp-eval-normal">평범 (보통)</span>
                                    </c:when>
                                    <c:when test="${feedbackDto.evaluation == 'NEGATIVE'}">
                                        <span class="rp-eval-badge rp-eval-negative">부정 (미흡)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:#94a3b8;">-</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        </c:if>
                    </tbody>
                </table>

                <!-- 본문 (Quill readOnly) -->
                <div class="rp-detail-body">
                    <div id="viewer"></div>
                </div>

                <!-- 첨부파일 -->
                <c:if test="${not empty feedbackDto.fileList}">
                <div class="rp-attach-area" style="margin-top:14px;">
                    <div class="rp-attach-label">
                        <i class="bi bi-paperclip"></i> 첨부파일
                    </div>
                    <ul class="rp-attach-list">
                        <c:forEach var="f" items="${feedbackDto.fileList}">
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
                </c:if>

                <!-- 하단 액션 -->
                <div class="rp-detail-actions">
                    <div class="rp-actions-left">
                        <a href="${pageContext.request.contextPath}/report/list?tab=feedback"
                           class="rp-btn rp-btn-secondary">
                            <i class="bi bi-list-ul"></i> 목록
                        </a>
                        <a href="${pageContext.request.contextPath}/report/detail?filenum=${feedbackDto.parent}"
                           class="rp-btn rp-btn-secondary">
                            <i class="bi bi-file-earmark-text"></i> 원본 보고서
                        </a>
                    </div>
                    <div class="rp-actions-right">
                        <%-- 수정/삭제: 피드백 작성자 본인 또는 99 관리자 --%>
                        <c:if test="${sessionEmpId == feedbackDto.empId or userLevel >= 99}">
                        <a href="${pageContext.request.contextPath}/report/feedback/edit?filenum=${feedbackDto.filenum}"
                           class="rp-btn rp-btn-secondary">
                            <i class="bi bi-pencil"></i> 수정
                        </a>
                        <button type="button" class="rp-btn rp-btn-danger"
                                onclick="rpConfirmFeedbackDelete(${feedbackDto.filenum}, _ctxPath)">
                            <i class="bi bi-trash3"></i> 삭제
                        </button>
                        </c:if>
                    </div>
                </div>

            </div>
        </div>

    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/feedbackDetail.js"></script>
<script>
/* Quill 뷰어 초기화 (JSP EL 값 주입이 필요하므로 인라인 유지) */
var viewer = new Quill('#viewer', { theme: 'snow', readOnly: true, modules: { toolbar: false } });
viewer.root.innerHTML = '<c:out value="${feedbackDto.content}" escapeXml="false"/>';

/* contextPath를 변수로 넘겨 외부 함수에서 사용 */
var _ctxPath = '${pageContext.request.contextPath}';
</script>
</body>
</html>
