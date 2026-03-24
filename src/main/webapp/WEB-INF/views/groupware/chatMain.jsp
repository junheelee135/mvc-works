<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>직원 채팅</title>

<%-- 공통 리소스 --%>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>

<%-- 사이드바 --%>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>

<%-- 채팅 --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/chat.css" type="text/css">

<%-- SockJS --%>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@stomp/stompjs@6.1.2/bundles/stomp.umd.min.js"></script>
</head>
<body>

<%-- 사이드바 --%>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<%-- 메인 콘텐츠 영역 --%>
<div class="emp-content">

    <%-- 상단 헤더 네비게이션 --%>
    <header>
        <jsp:include page="/WEB-INF/views/layout/header.jsp"/>
    </header>
    
    <div id="vue-app">
        <jsp:include page="/WEB-INF/views/groupware/chatList.jsp"/>
    </div>

</div><%-- /emp-content --%>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
    "imports": {
        "axios"     : "${pageContext.request.contextPath}/dist/util/axios.min.js",
        "http"      : "${pageContext.request.contextPath}/dist/util/http.js",
        "paginate"  : "${pageContext.request.contextPath}/dist/util/paginate.js",
        "chatStore" : "${pageContext.request.contextPath}/dist/util/store/chatStore.js"
    }
}
</script>

<script type="module">
    import { createApp, onMounted, onUnmounted } from 'vue';
    import { createPinia }                        from 'pinia';
    import { useChatStore }                       from 'chatStore';
	
	const pinia = createPinia();

    const app = createApp({
        setup() {
            const store = useChatStore();

            store.sessionEmpId  = '${sessionScope.member.empId}';
            store.sessionName   = '${sessionScope.member.name}';
            store.sessionAvatar = '${sessionScope.member.avatar}';

            onMounted(async () => {
                store.connectWebSocket();

                await store.loadProjects();
                await store.loadUserList();

                const userListEl = document.querySelector('.chat-user-list');
                if (userListEl) {
                    userListEl.addEventListener('scroll', () => {
                        const { scrollTop, scrollHeight, clientHeight } = userListEl;
                        if (scrollHeight - scrollTop - clientHeight < 80) {
                            store.loadMoreUsers();
                        }
                    });
                }

                const msgListEl = document.querySelector('.chat-messages');
                if (msgListEl) {
                    msgListEl.addEventListener('scroll', async () => {
                        if (msgListEl.scrollTop < 60 && store.msgHasMore && !store.msgLoading) {
                            const prevScrollHeight = msgListEl.scrollHeight;
                            await store.loadMessages(true);
                            msgListEl.scrollTop = msgListEl.scrollHeight - prevScrollHeight;
                        }
                    });
                }
            });

            onUnmounted(() => {
                store._closeCurrentRoom();
                if (store.stompClient) {
                    store.stompClient.deactivate(); // 6.x API
                }
            });

            return { store };
        }
    });

    app.use(pinia);
    app.mount('#vue-app');
</script>

<%-- 푸터 --%>
<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>
