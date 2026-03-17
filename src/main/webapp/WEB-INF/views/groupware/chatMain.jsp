<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>사원 채팅</title>

<%-- 공통 리소스 (폰트, Bootstrap, Bootstrap Icons, Font Awesome, core.css, forms.css 등) --%>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>

<%-- 사이드바 전용 CSS --%>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>

<%-- 채팅 전용 CSS --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/chat.css" type="text/css">
</head>
<body>

<%-- 사이드바 --%>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<%-- 메인 콘텐츠 영역 (사이드바 오른쪽) --%>
<div class="emp-content">

    <%-- 상단 헤더 네비게이션 --%>
    <header>
        <jsp:include page="/WEB-INF/views/layout/header.jsp"/>
    </header>

    <%-- Vue 앱 마운트 포인트 --%>
    <div id="vue-app">
        <jsp:include page="/WEB-INF/views/groupware/chatList.jsp"/>
    </div>

</div><%-- /emp-content --%>

<%-- Vue 3 CDN --%>
<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<%--
    Import Map
    TODO: API 연동 완료 후 http, paginate 다시 추가
--%>
<script type="importmap">
{
    "imports": {
        "chatStore" : "${pageContext.request.contextPath}/dist/util/store/chatStore.js"
    }
}
</script>

<%-- Vue 앱 초기화 --%>
<script type="module">
    import { createApp, onMounted } from 'vue';
    import { createPinia }          from 'pinia';
    import { useChatStore }         from 'chatStore';

    const app = createApp({
        setup() {
            const store = useChatStore();

            <%--
                TODO: API 연동 시 아래 세션 주입 주석 해제
                store.sessionEmpId  = '${sessionScope.member.empId}';
                store.sessionName   = '${sessionScope.member.name}';
                store.sessionAvatar = '${sessionScope.member.avatar}';
            --%>

            onMounted(() => {
                store.loadProjects();   // 가데이터 로드 (TODO: API 연동 시 그대로 유지)
                store.loadUserList();   // 가데이터 로드 (TODO: API 연동 시 그대로 유지)
            });

            return { store };
        }
    });

    const pinia = createPinia();
    app.use(pinia);
    app.mount('#vue-app');
</script>

<%-- 공통 푸터 리소스 --%>
<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>
