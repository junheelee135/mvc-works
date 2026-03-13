<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<%-- 현재 로그인 사용자 권한 --%>
<c:set var="userLevel"    value="${userLevel}"/>
<c:set var="sessionEmpId" value="${sessionEmpId}"/>

<!-- 페이지 타이틀 -->
<div class="rp-page-title">
    <i class="bi bi-file-earmark-text rp-title-icon"></i>
    <h2>주간보고서</h2>
</div>

<!-- 탭 네비게이션 -->
<div class="rp-tab-nav">
    <button class="rp-tab-item <c:if test="${activeTab != 'feedback'}">active</c:if>"
            id="tabReport"
            onclick="rpSwitchTab('tabReport','tabContentReport')">
        <i class="bi bi-file-earmark-text"></i> 직원 보고서
    </button>
    <%-- 피드백 탭: 일반 사원은 자기 보고서에 달린 피드백만 조회 가능하므로 탭 자체는 노출 --%>
    <button class="rp-tab-item <c:if test="${activeTab == 'feedback'}">active</c:if>"
            id="tabFeedback"
            onclick="rpSwitchTab('tabFeedback','tabContentFeedback')">
        <i class="bi bi-chat-left-dots"></i> 관리자 피드백
    </button>
</div>

<%-- ===================================================
     직원 보고서 탭
=================================================== --%>
<div id="tabContentReport" class="rp-tab-content <c:if test="${activeTab != 'feedback'}">active</c:if>">

    <!-- 검색 필터 -->
    <form id="reportSearchForm" action="${pageContext.request.contextPath}/report/list" method="get">
        <input type="hidden" name="tab" value="report">
        <div class="rp-filter-card">
            <div class="rp-filter-row">
                <%-- 관리자·피드백 작성자만 작성자 검색 노출 --%>
                <c:if test="${userLevel >= 51}">
                <div class="rp-filter-group">
                    <label>작성자</label>
                    <input type="text" name="writerName" value="${writerName}" placeholder="이름 입력">
                </div>
                </c:if>
                <div class="rp-filter-group">
                    <label>보고 기간(시작)</label>
                    <input type="date" name="periodStart" value="${periodStart}">
                </div>
                <div class="rp-filter-group">
                    <label>보고 기간(종료)</label>
                    <input type="date" name="periodEnd" value="${periodEnd}">
                </div>
                <c:if test="${userLevel >= 51}">
                <div class="rp-filter-group">
                    <label>피드백 여부</label>
                    <select name="feedbackYn">
                        <option value="">전체</option>
                        <option value="Y" <c:if test="${feedbackYn == 'Y'}">selected</c:if>>완료</option>
                        <option value="N" <c:if test="${feedbackYn == 'N'}">selected</c:if>>미작성</option>
                    </select>
                </div>
                </c:if>
                <div class="rp-filter-group">
                    <label>제목 검색</label>
                    <input type="text" name="subject" value="${subject}" placeholder="제목 입력">
                </div>
                <div class="rp-filter-btns">
                    <button type="submit" class="rp-btn rp-btn-primary">
                        <i class="bi bi-search"></i> 검색
                    </button>
                    <button type="button" class="rp-btn rp-btn-secondary" onclick="rpResetForm('reportSearchForm')">
                        <i class="bi bi-arrow-counterclockwise"></i> 초기화
                    </button>
                </div>
            </div>
        </div>
    </form>

    <!-- 툴바 -->
    <div class="rp-toolbar">
        <div class="rp-toolbar-left">
            전체 <strong class="mx-1">${reportTotal}</strong>건
        </div>
        <div class="rp-toolbar-right">
            <%-- 일반 사원(51 미만)만 보고서 작성 가능 --%>
            <c:if test="${userLevel < 51}">
            <a href="${pageContext.request.contextPath}/report/write" class="rp-btn rp-btn-primary">
                <i class="bi bi-pencil-square"></i> 보고서 작성
            </a>
            </c:if>
        </div>
    </div>

    <!-- 테이블 -->
    <div class="rp-table-card">
        <div style="overflow-x:auto;">
            <table class="rp-table">
                <thead>
                    <tr>
                        <th style="width:55px;">번호</th>
                        <th>제목</th>
                        <c:if test="${userLevel >= 51}">
                        <th style="width:100px;">작성자</th>
                        </c:if>
                        <th style="width:130px;">보고 기간</th>
                        <th style="width:105px;">작성일</th>
                        <c:if test="${userLevel >= 51}">
                        <th style="width:85px;">피드백</th>
                        </c:if>
                        <th style="width:70px;">조회수</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                    <c:when test="${empty reportList}">
                        <tr>
                            <td colspan="7" class="td-center" style="padding:30px; color:#94a3b8;">
                                조회된 보고서가 없습니다.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="rpt" items="${reportList}" varStatus="vs">
                        <tr>
                            <td class="td-center">${reportTotal - ((page-1)*10) - vs.index}</td>
                            <td class="td-subject">
                                <a href="${pageContext.request.contextPath}/report/detail?filenum=${rpt.filenum}">
                                    ${rpt.subject}
                                </a>
                            </td>
                            <c:if test="${userLevel >= 51}">
                            <td class="td-center">${rpt.writerName}</td>
                            </c:if>
                            <td class="td-center">
                                <c:if test="${not empty rpt.periodStart and not empty rpt.periodEnd}">
                                    <fmt:parseDate value="${rpt.periodStart}" pattern="yyyy-MM-dd" var="ps"/>
                                    <fmt:parseDate value="${rpt.periodEnd}"   pattern="yyyy-MM-dd" var="pe"/>
                                    <fmt:formatDate value="${ps}" pattern="MM/dd"/> ~
                                    <fmt:formatDate value="${pe}" pattern="MM/dd"/>
                                </c:if>
                            </td>
                            <td class="td-center">${rpt.regdate}</td>
                            <c:if test="${userLevel >= 51}">
                            <td class="td-center">
                                <c:choose>
                                    <c:when test="${rpt.feedbackCount > 0}">
                                        <span class="rp-result-badge rp-badge-done">
                                            <span class="rp-dot"></span> 완료
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="rp-badge rp-badge-pending">미작성</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            </c:if>
                            <td class="td-center">${rpt.hitcount}</td>
                        </tr>
                    </c:forEach>
                    </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <!-- 페이지네이션 -->
        <div class="rp-pagination">
            <div>총 <strong>${reportTotal}</strong>건 / ${reportTotalPage} 페이지</div>
            <div class="rp-pagination-pages">
                <%-- 이전 블록 --%>
                <c:set var="reportBlock"     value="${(page-1)/10}"/>
                <c:set var="reportBlockStart" value="${reportBlock * 10 + 1}"/>
                <c:set var="reportBlockEnd"   value="${reportBlockStart + 9}"/>
                <c:if test="${reportBlockEnd > reportTotalPage}">
                    <c:set var="reportBlockEnd" value="${reportTotalPage}"/>
                </c:if>

                <c:choose>
                    <c:when test="${reportBlockStart > 1}">
                        <a class="rp-page-btn" href="?tab=report&page=1&writerName=${writerName}&subject=${subject}&periodStart=${periodStart}&periodEnd=${periodEnd}&feedbackYn=${feedbackYn}">
                            <i class="bi bi-chevron-double-left"></i></a>
                        <a class="rp-page-btn" href="?tab=report&page=${reportBlockStart-1}&writerName=${writerName}&subject=${subject}&periodStart=${periodStart}&periodEnd=${periodEnd}&feedbackYn=${feedbackYn}">
                            <i class="bi bi-chevron-left"></i></a>
                    </c:when>
                    <c:otherwise>
                        <a class="rp-page-btn disabled"><i class="bi bi-chevron-double-left"></i></a>
                        <a class="rp-page-btn disabled"><i class="bi bi-chevron-left"></i></a>
                    </c:otherwise>
                </c:choose>

                <c:forEach begin="${reportBlockStart}" end="${reportBlockEnd}" var="p">
                    <a class="rp-page-btn <c:if test="${p == page}">active</c:if>"
                       href="?tab=report&page=${p}&writerName=${writerName}&subject=${subject}&periodStart=${periodStart}&periodEnd=${periodEnd}&feedbackYn=${feedbackYn}">
                        ${p}
                    </a>
                </c:forEach>

                <c:choose>
                    <c:when test="${reportBlockEnd < reportTotalPage}">
                        <a class="rp-page-btn" href="?tab=report&page=${reportBlockEnd+1}&writerName=${writerName}&subject=${subject}&periodStart=${periodStart}&periodEnd=${periodEnd}&feedbackYn=${feedbackYn}">
                            <i class="bi bi-chevron-right"></i></a>
                        <a class="rp-page-btn" href="?tab=report&page=${reportTotalPage}&writerName=${writerName}&subject=${subject}&periodStart=${periodStart}&periodEnd=${periodEnd}&feedbackYn=${feedbackYn}">
                            <i class="bi bi-chevron-double-right"></i></a>
                    </c:when>
                    <c:otherwise>
                        <a class="rp-page-btn disabled"><i class="bi bi-chevron-right"></i></a>
                        <a class="rp-page-btn disabled"><i class="bi bi-chevron-double-right"></i></a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

</div><%-- /tabContentReport --%>

<%-- ===================================================
     관리자 피드백 탭
=================================================== --%>
<div id="tabContentFeedback" class="rp-tab-content <c:if test="${activeTab == 'feedback'}">active</c:if>">

    <!-- 검색 필터 -->
    <form id="feedbackSearchForm" action="${pageContext.request.contextPath}/report/list" method="get">
        <input type="hidden" name="tab" value="feedback">
        <div class="rp-filter-card">
            <div class="rp-filter-row">
                <%-- 관리자·피드백 작성자만 대상 직원 검색 노출 --%>
                <c:if test="${userLevel >= 51}">
                <div class="rp-filter-group">
                    <label>대상 직원</label>
                    <input type="text" name="targetName" value="${targetName}" placeholder="이름 입력">
                </div>
                </c:if>
                <div class="rp-filter-group">
                    <label>작성일(시작)</label>
                    <input type="date" name="startDate" value="${startDate}">
                </div>
                <div class="rp-filter-group">
                    <label>작성일(종료)</label>
                    <input type="date" name="endDate" value="${endDate}">
                </div>
                <div class="rp-filter-group">
                    <label>제목 검색</label>
                    <input type="text" name="subject" value="${subject}" placeholder="제목 입력">
                </div>
                <div class="rp-filter-btns">
                    <button type="submit" class="rp-btn rp-btn-primary">
                        <i class="bi bi-search"></i> 검색
                    </button>
                    <button type="button" class="rp-btn rp-btn-secondary" onclick="rpResetForm('feedbackSearchForm')">
                        <i class="bi bi-arrow-counterclockwise"></i> 초기화
                    </button>
                </div>
            </div>
        </div>
    </form>

    <!-- 툴바 -->
    <div class="rp-toolbar">
        <div class="rp-toolbar-left">
            전체 <strong class="mx-1">${feedbackTotal}</strong>건
        </div>
        <div class="rp-toolbar-right"></div>
    </div>

    <!-- 테이블 -->
    <div class="rp-table-card">
        <div style="overflow-x:auto;">
            <table class="rp-table">
                <thead>
                    <tr>
                        <th style="width:55px;">번호</th>
                        <th>원본 보고서 제목</th>
                        <th>피드백 제목</th>
                        <c:if test="${userLevel >= 51}">
                        <th style="width:100px;">작성자</th>
                        </c:if>
                        <th style="width:105px;">작성일</th>
                        <th style="width:70px;">조회수</th>
                        <th style="width:60px;">상세</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                    <c:when test="${empty feedbackList}">
                        <tr>
                            <td colspan="7" class="td-center" style="padding:30px; color:#94a3b8;">
                                조회된 피드백이 없습니다.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                    <c:forEach var="fb" items="${feedbackList}" varStatus="vs">
                        <tr>
                            <td class="td-center">${feedbackTotal - ((fbPage-1)*10) - vs.index}</td>
                            <td style="color:#64748b; font-size:0.8rem;">${fb.refSubject}</td>
                            <td class="td-subject">
                                <a href="${pageContext.request.contextPath}/report/feedback/detail?filenum=${fb.filenum}">
                                    ${fb.subject}
                                </a>
                            </td>
                            <c:if test="${userLevel >= 51}">
                            <td class="td-center">${fb.writerName}</td>
                            </c:if>
                            <td class="td-center">${fb.regdate}</td>
                            <td class="td-center">${fb.hitcount}</td>
                            <td class="td-center">
                                <button class="rp-btn-icon"
                                        onclick="location.href='${pageContext.request.contextPath}/report/feedback/detail?filenum=${fb.filenum}'"
                                        title="상세보기">
                                    <i class="bi bi-eye"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <!-- 피드백 페이지네이션 -->
        <div class="rp-pagination">
            <div>총 <strong>${feedbackTotal}</strong>건 / ${feedbackTotalPage} 페이지</div>
            <div class="rp-pagination-pages">
                <c:set var="fbBlock"      value="${(fbPage-1)/10}"/>
                <c:set var="fbBlockStart" value="${fbBlock * 10 + 1}"/>
                <c:set var="fbBlockEnd"   value="${fbBlockStart + 9}"/>
                <c:if test="${fbBlockEnd > feedbackTotalPage}">
                    <c:set var="fbBlockEnd" value="${feedbackTotalPage}"/>
                </c:if>

                <c:choose>
                    <c:when test="${fbBlockStart > 1}">
                        <a class="rp-page-btn" href="?tab=feedback&fbPage=1&targetName=${targetName}&startDate=${startDate}&endDate=${endDate}&subject=${subject}">
                            <i class="bi bi-chevron-double-left"></i></a>
                        <a class="rp-page-btn" href="?tab=feedback&fbPage=${fbBlockStart-1}&targetName=${targetName}&startDate=${startDate}&endDate=${endDate}&subject=${subject}">
                            <i class="bi bi-chevron-left"></i></a>
                    </c:when>
                    <c:otherwise>
                        <a class="rp-page-btn disabled"><i class="bi bi-chevron-double-left"></i></a>
                        <a class="rp-page-btn disabled"><i class="bi bi-chevron-left"></i></a>
                    </c:otherwise>
                </c:choose>

                <c:forEach begin="${fbBlockStart}" end="${fbBlockEnd}" var="p">
                    <a class="rp-page-btn <c:if test="${p == fbPage}">active</c:if>"
                       href="?tab=feedback&fbPage=${p}&targetName=${targetName}&startDate=${startDate}&endDate=${endDate}&subject=${subject}">
                        ${p}
                    </a>
                </c:forEach>

                <c:choose>
                    <c:when test="${fbBlockEnd < feedbackTotalPage}">
                        <a class="rp-page-btn" href="?tab=feedback&fbPage=${fbBlockEnd+1}&targetName=${targetName}&startDate=${startDate}&endDate=${endDate}&subject=${subject}">
                            <i class="bi bi-chevron-right"></i></a>
                        <a class="rp-page-btn" href="?tab=feedback&fbPage=${feedbackTotalPage}&targetName=${targetName}&startDate=${startDate}&endDate=${endDate}&subject=${subject}">
                            <i class="bi bi-chevron-double-right"></i></a>
                    </c:when>
                    <c:otherwise>
                        <a class="rp-page-btn disabled"><i class="bi bi-chevron-right"></i></a>
                        <a class="rp-page-btn disabled"><i class="bi bi-chevron-double-right"></i></a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

</div><%-- /tabContentFeedback --%>

<script src="${pageContext.request.contextPath}/dist/js/reportList.js"></script>
