<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>직원관리</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/employeeList.css" type="text/css">
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<div class="emp-content">

    <header>
        <jsp:include page="/WEB-INF/views/layout/header.jsp"/>
    </header>
    
    <div id="vue-app">
        <jsp:include page="/WEB-INF/views/hrm/employeeList.jsp"/>
    </div>
</div>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
	"imports": {
		"http"     : "/dist/util/http.js",
		"paginate" : "/dist/util/paginate.js",
		"hrmStore" : "/dist/util/store/hrmStore.js"
	}
}
</script>

<script type="module">
	import { createApp, onMounted } from 'vue';
	import { createPinia }          from 'pinia';
	import { useHrmStore }          from 'hrmStore';

	const app = createApp({
		setup() {
			const store = useHrmStore();

			// 세션 정보 주입 (main.jsp 패턴과 동일)
			store.sessionName = '${sessionScope.member.name}';

			onMounted(() => {
				store.loadCodes();   // 부서·직급·재직상태 공통코드 조회
				store.fetchList();
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
