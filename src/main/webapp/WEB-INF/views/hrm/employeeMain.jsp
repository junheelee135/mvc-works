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
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/skeleton.css" type="text/css">
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<div class="emp-content">

    <header>
        <jsp:include page="/WEB-INF/views/layout/header.jsp"/>
    </header>
    
    <div id="vue-skeleton" aria-hidden="true">
        <div class="skeleton-block skeleton-filter"></div>
        <div class="skeleton-toolbar">
            <div class="skeleton-block skeleton-text-sm"></div>
            <div class="skeleton-btn-group">
                <div class="skeleton-block skeleton-btn"></div>
                <div class="skeleton-block skeleton-btn"></div>
                <div class="skeleton-block skeleton-btn"></div>
                <div class="skeleton-block skeleton-btn"></div>
            </div>
        </div>
        <div class="skeleton-block skeleton-table-head"></div>
        <div class="skeleton-block skeleton-row"></div>
        <div class="skeleton-block skeleton-row"></div>
        <div class="skeleton-block skeleton-row"></div>
        <div class="skeleton-block skeleton-row"></div>
        <div class="skeleton-block skeleton-row"></div>
        <div class="skeleton-block skeleton-row"></div>
    </div>
    
    <div id="vue-app" v-cloak>
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

	const pinia = createPinia();
	const app = createApp({
		setup() {
			const store = useHrmStore();

			store.sessionName = '${sessionScope.member.name}';

			onMounted(() => {
				store.initialize();
				const skeleton = document.getElementById('vue-skeleton');
				if (skeleton) skeleton.remove();
			});

			return { store };
		}
	});
	app.use(pinia);
	app.mount('#vue-app');
</script>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>
