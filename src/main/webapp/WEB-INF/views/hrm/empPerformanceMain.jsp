<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<%-- contextPath 메타 태그: Store의 goToReport()에서 사용 --%>
<meta name="contextPath" content="${pageContext.request.contextPath}">
<title>직원 성과 관리</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/empPerformance.css" type="text/css">
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<div class="ep-content">

    <header>
        <jsp:include page="/WEB-INF/views/layout/header.jsp"/>
    </header>

    <div id="vue-app" v-cloak>
        <jsp:include page="/WEB-INF/views/hrm/empPerformanceList.jsp"/>
    </div>
</div>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
    "imports": {
        "http"                : "${pageContext.request.contextPath}/dist/util/http.js",
        "paginate"            : "${pageContext.request.contextPath}/dist/util/paginate.js",
        "empPerformanceStore" : "${pageContext.request.contextPath}/dist/util/store/empPerformanceStore.js"
    }
}
</script>

<script type="module">
    import { createApp, onMounted } from 'vue';
    import { createPinia }              from 'pinia';
    import { useEmpPerformanceStore }   from 'empPerformanceStore';

    const app = createApp({
        setup() {
            const store = useEmpPerformanceStore();

            // JSP EL로 세션값 주입
            store.sessionEmpId  = '${sessionScope.member.empId}';
            store.sessionName   = '${sessionScope.member.name}';
            store.sessionLevel  = Number('${sessionScope.member.userLevel}');

            onMounted(async () => {
                // 참여 프로젝트 옵션, 재직상태 공통코드, 목록 동시 로드
                await Promise.all([
                    store.fetchMyProjects(),
                    store.fetchEmpStatusCodes(),
                    store.fetchList()
                ]);
            });

            return { store };
        }
    });

    const pinia = createPinia();
    app.use(pinia);
    app.mount('#vue-app');
</script>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>
