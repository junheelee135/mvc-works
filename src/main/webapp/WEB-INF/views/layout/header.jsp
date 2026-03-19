<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<nav class="navbar-custom">
    <div class="navbar-left">
        <div class="notice-ticker" id="noticeTicker">
            <span class="ticker-badge">공지</span>
            <div class="ticker-wrap">
                <span class="ticker-text" id="tickerText">공지사항을 불러오는 중...</span>
            </div>
        </div>
    </div>
    <div class="navbar-right">
        <span>${sessionScope.member.name} ${sessionScope.member.gradeName}님 환영합니다.</span>

        <%-- 알림 버튼 + 토글 드롭다운 --%>
        <div class="noti-wrap" id="notiWrap">
            <button class="nav-icon-btn position-relative" id="notiBtn" type="button">
                <i class="far fa-bell"></i>
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger navbar-badge"
                      id="notiBadge" style="display:none;">0</span>
            </button>

            <%-- 알림 드롭다운 패널 --%>
            <div class="noti-panel" id="notiPanel">
                <div class="noti-panel-header">
                    <span class="noti-panel-title"><i class="far fa-bell me-1"></i> 알림</span>
                    <button class="noti-read-all-btn" id="notiReadAllBtn" type="button">모두 읽음</button>
                </div>
                <ul class="noti-list" id="notiList">
                    <li class="noti-empty">알림이 없습니다.</li>
                </ul>
            </div>
        </div>

        <%-- 로그인 상태 --%>
        <sec:authorize access="isAuthenticated()">
            <%-- 로그아웃 버튼 --%>
            <a href="${pageContext.request.contextPath}/member/logout" class="nav-icon-btn" title="로그아웃">
                <i class="fas fa-sign-out-alt"></i>
            </a>

            <%-- 아바타 + 드롭다운 메뉴 --%>
            <sec:authentication property="principal.member.avatar" var="avatar"/>
            <div class="dropdown">
                <c:choose>
                    <c:when test="${not empty avatar}">
                        <img src="${pageContext.request.contextPath}/uploads/member/${avatar}"
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/dist/images/avatar.png';"
                             class="navbar-avatar dropdown-toggle" data-bs-toggle="dropdown"
                             aria-expanded="false" title="내 메뉴">
                    </c:when>
                    <c:otherwise>
                        <img src="${pageContext.request.contextPath}/dist/images/avatar.png"
                             class="navbar-avatar dropdown-toggle" data-bs-toggle="dropdown"
                             aria-expanded="false" title="내 메뉴">
                    </c:otherwise>
                </c:choose>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li><a href="${pageContext.request.contextPath}/" class="dropdown-item"><i class="fas fa-images me-2"></i>사진첩</a></li>
                    <li><a href="${pageContext.request.contextPath}/" class="dropdown-item"><i class="fas fa-calendar me-2"></i>일정관리</a></li>
                    <li><a href="${pageContext.request.contextPath}/" class="dropdown-item"><i class="fas fa-envelope me-2"></i>쪽지함</a></li>
                    <li><a href="${pageContext.request.contextPath}/" class="dropdown-item"><i class="fas fa-mail-bulk me-2"></i>메일</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a href="${pageContext.request.contextPath}/member/pwd" class="dropdown-item"><i class="fas fa-user-edit me-2"></i>정보수정</a></li>
                    <li><a href="${pageContext.request.contextPath}/member/logout" class="dropdown-item text-danger"><i class="fas fa-sign-out-alt me-2"></i>로그아웃</a></li>
                </ul>
            </div>
        </sec:authorize>
    </div>
</nav>

<script src="${pageContext.request.contextPath}/dist/js/notification.js"></script>

<script>
(function() {
    const ctx = '${pageContext.request.contextPath}';
    let notices = [];
    let currentIndex = 0;

    async function fetchNotices() {
        try {
            const res = await fetch(ctx + '/api/notice/list?pageNo=1&pageSize=20');
            const data = await res.json();
            console.log('[ticker] 공지 목록:', data.list);
            // isnotice=1 인 공지만 필터
            notices = (data.list || []).filter(n => n.isnotice === 1);
            console.log('[ticker] 필터된 공지:', notices);
            if (notices.length === 0) {
                document.getElementById('noticeTicker').style.display = 'none';
            } else {
                showTicker(true); // 첫 로드는 즉시 표시
            }
        } catch(e) {
            console.error('[ticker] 공지 불러오기 실패:', e);
            document.getElementById('noticeTicker').style.display = 'none';
        }
    }

    function showTicker(immediate) {
        const el = document.getElementById('tickerText');
        if (!el || notices.length === 0) return;

        const notice = notices[currentIndex];
        currentIndex = (currentIndex + 1) % notices.length;

        if (immediate) {
            el.textContent = notice.subject;
            el.onclick = () => { window.location.href = ctx + '/groupware/notice?num=' + notice.noticenum; };
            return;
        }

        // 1) 현재 텍스트를 위로 밀어 올림
        el.classList.add('ticker-slide-up');

        // 2) 올라간 뒤 → 텍스트 교체 + 아래에서 대기
        setTimeout(() => {
            el.textContent = notice.subject;
            el.onclick = () => { window.location.href = ctx + '/groupware/notice?num=' + notice.noticenum; };
            el.classList.remove('ticker-slide-up');
            el.classList.add('ticker-slide-ready');  // 아래에 즉시 배치 (transition: none)

            // 3) 다음 프레임에서 아래→제자리로 올라오는 애니메이션
            requestAnimationFrame(() => {
                requestAnimationFrame(() => {
                    el.classList.remove('ticker-slide-ready');
                    // transition 복원되면서 translateY(100%) → translateY(0) 애니메이션 실행
                });
            });
        }, 400);
    }

    // 페이지 로드 시 공지 불러오기
    fetchNotices();

    // 5초마다 다음 공지로 전환
    setInterval(() => {
        if (notices.length > 1) showTicker(false);
    }, 5000);
})();
</script>
