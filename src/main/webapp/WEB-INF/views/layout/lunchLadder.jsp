<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>점심 내기 게임 고고!!</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/lunchLadder.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
    <div class="gz-wrap">

        <div class="gz-header">
            <h4><i class="fas fa-gamepad"></i>점심내기 한판?</h4>
            <p class="gz-desc">오늘은 누가 걸릴지 두둥!!</p>
        </div>

        <div class="game-grid">

            <div class="game-card" onclick="openModal('ladder')">
                <div class="game-icon ladder-icon">
                    <i class="fas fa-grip-lines"></i>
                </div>
                <div class="game-info">
                    <div class="game-name">사다리 타기</div>
                    <div class="game-desc">누가 점심 값을 내었는가?</div>
                </div>
                <div class="game-badge">2 - 8명 가능</div>
            </div>

            <div class="game-card" onclick="openModal('roulette')">
                <div class="game-icon roulette-icon">
                    <i class="fas fa-circle-notch"></i>
                </div>
                <div class="game-info">
                    <div class="game-name">돌려 돌려 돌림판</div>
                    <div class="game-desc">누가 커피를 쏘았는가?</div>
                </div>
                <div class="game-badge">2 - 8명 가능</div>
            </div>

            <div class="game-card" onclick="openModal('luckydraw')">
                <div class="game-icon lucky-icon">
                    <i class="fas fa-ticket-alt"></i>
                </div>
                <div class="game-info">
                    <div class="game-name">카드 뽑기</div>
                    <div class="game-desc">누가 회식비를 내었는가?</div>
                </div>
                <div class="game-badge">2 - 8명 가능</div>
            </div>

        </div>
    </div>
</main>

<%@ include file="/WEB-INF/views/layout/lunchLadderGames.jsp" %>

<script>
function openModal(type) {
    document.getElementById('modal-' + type).style.display = 'flex';
}
</script>

</body>
</html>
