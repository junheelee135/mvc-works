<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvallist.css?v=2" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css" type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
<style>[v-cloak] { display: none; }</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
    <div id="vue-app" v-cloak>

        <jsp:include page="/WEB-INF/views/approval/include/approvalListTopbar.jsp"/>

        <div class="approval-body">
            <jsp:include page="/WEB-INF/views/approval/include/approvalListFilter.jsp"/>
            <jsp:include page="/WEB-INF/views/approval/include/approvalListTable.jsp"/>
        </div>

    </div>
</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
    "imports": {
        "http": "/dist/util/http.js?v=2",
        "approvalListStore": "/dist/util/store/approvalListStore.js?v=2",
        "commonCodeStore": "/dist/util/store/commonCodeStore.js"
    }
}
</script>

<script type="module">
    import { createApp, onMounted } from 'vue';
    import { createPinia } from 'pinia';
    import { useApprovalListStore } from 'approvalListStore';
    import { useCommonCodeStore } from 'commonCodeStore';

    const app = createApp({
        setup() {
            const store = useApprovalListStore();
            const codeStore = useCommonCodeStore();
            const ctx = document.querySelector('meta[name="ctx"]').content;

            const goCreate = () => { location.href = ctx + '/approval/create'; };
            const goDoc = (item) => {
                location.href = item.docStatus === 'DRAFT'
                    ? ctx + '/approval/create?docId=' + item.docId
                    : ctx + '/approval/view?docId=' + item.docId;
            };

            const statusClass = (item) => {
                if (item.docStatus === 'PENDING' && item.myLineStatus === 'APPROVED') {
                    return 'status-MYAPPROVED';
                }
                if (item.docStatus === 'PENDING' && item.approvedCount > 0) {
                    return 'status-INPROGRESS';
                }
                return 'status-' + item.docStatus;
            };

            const statusText = (item) => {
                if (item.docStatus === 'PENDING' && item.totalLineCount > 0) {
                    const progress = item.approvedCount + '/' + item.totalLineCount;
                    if (item.myLineStatus === 'APPROVED') {
                        return '승인완료 (' + progress + ')';
                    }
                    return (item.approvedCount > 0 ? '결재중' : '대기중') + ' (' + progress + ')';
                }
                if (item.docStatus === 'REJECTED' && item.totalLineCount > 0) {
                    return '반려 (' + item.approvedCount + '/' + item.totalLineCount + ')';
                }
                const found = codeStore.getCodes('DOCSTATUS').find(c => c.code === item.docStatus);
                return found ? found.name : item.docStatus;
            };

    		onMounted(async () => {
      						await codeStore.fetchCodes('DOCSTATUS');
      						const params = new URLSearchParams(location.search);
      						store.filterType = params.get('type') || 'all';
      						store.fetchList();
      						store.fetchBadgeCounts();
      						});

            return { store, codeStore, ctx, goCreate, goDoc, statusClass, statusText };
        }
    });

    app.use(createPinia());
    app.mount('#vue-app');
</script>

</body>
</html>