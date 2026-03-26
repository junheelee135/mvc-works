<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>결재문서 PDF</title>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvalPdf.css?v=3" type="text/css">
<meta name="ctx"   content="${pageContext.request.contextPath}">
<meta name="docId" content="${param.docId}">
<style>[v-cloak] { display: none; }</style>
</head>
<body>

<div id="vue-app" v-cloak>

    <div class="pdf-toolbar">
        <button class="btn-pdf-download" @click="downloadPdf">
            <span class="material-symbols-outlined" style="font-size:15px">download</span>
            PDF 저장
        </button>
        <button class="btn-pdf-close" @click="closePdf">
            <span class="material-symbols-outlined" style="font-size:15px">close</span>
            닫기
        </button>
    </div>

    <div id="pdf-content" class="pdf-page" v-if="store.doc">
        <h1 class="pdf-title">{{ store.doc?.typeName }}</h1>

        <div class="stamp-box">
            <div class="stamp-card">
                <div class="stamp-card-header">작성자</div>
                <div class="stamp-card-body">
                    <span class="stamp stamp-draft">기안</span>
                </div>
                <div class="stamp-card-name">{{ store.doc.writerEmpName }} {{ store.doc.writerGradeName }}</div>
                <div class="stamp-card-date">{{ store.doc.submitDate }}</div>
            </div>
            <div class="stamp-card" v-for="line in store.doc.lines" :key="line.lineId">
                <div class="stamp-card-header">승인자{{ line.stepOrder }}</div>
                <div class="stamp-card-body">
                    <span v-if="line.apprStatus === 'APPROVED'" class="stamp stamp-approved">승인</span>
                    <span v-else-if="line.apprStatus === 'REJECTED'" class="stamp stamp-rejected">반려</span>
                    <span v-else-if="line.apprStatus === 'HOLD'" class="stamp stamp-hold">보류</span>
                    <span v-else class="stamp stamp-wait"></span>
                </div>
                <div class="stamp-card-name">{{ line.apprEmpName }} {{ line.apprGradeName }}</div>
                <div class="stamp-card-date">{{ line.apprDate || '' }}</div>
            </div>
        </div>

        <table class="info-table">
            <tr>
                <th>문서번호</th>
                <td>{{ store.doc.docId }}</td>
                <th>결재요청일</th>
                <td>{{ store.doc.submitDate }}</td>
            </tr>
            <tr>
                <th>부서명</th>
                <td>{{ store.doc.writerDeptName }}</td>
                <th>작성자</th>
                <td>{{ store.doc.writerEmpName }} {{ store.doc.writerGradeName }}</td>
            </tr>
            <tr>
                <th>제목</th>
                <td colspan="3">{{ store.doc.title }}</td>
            </tr>
        </table>

        <template v-if="store.selectedFormCode === 'FM001'">
            <table class="info-table">
                <tr>
                    <th>휴가 종류</th>
                    <td colspan="3">{{ leaveTypeName }}</td>
                </tr>
                <tr>
                    <th>시작일</th>
                    <td>{{ store.detailData.leaveStartDate }}</td>
                    <th>종료일</th>
                    <td>{{ store.detailData.leaveEndDate }}</td>
                </tr>
                <tr>
                    <th>총 휴가일수</th>
                    <td colspan="3">{{ store.detailData.leaveTotalDays }}일</td>
                </tr>
                <tr v-if="store.detailData.description">
                    <th>상세 설명</th>
                    <td colspan="3">{{ store.detailData.description }}</td>
                </tr>
            </table>
        </template>

        <template v-if="store.selectedFormCode === 'FM002'">
            <table class="info-table">
                <tr>
                    <th>출장 목적</th>
                    <td colspan="3">{{ store.detailData.biztripPurpose }}</td>
                </tr>
                <tr>
                    <th>시작일</th>
                    <td>{{ store.detailData.biztripStartDate }}</td>
                    <th>종료일</th>
                    <td>{{ store.detailData.biztripEndDate }}</td>
                </tr>
                <tr v-if="store.detailData.companions && store.detailData.companions.length > 0">
                    <th>동행자</th>
                    <td colspan="3">
                        <span v-for="(c, i) in store.detailData.companions" :key="c.empId">
                            {{ c.name }}({{ c.dept }}){{ i &lt; store.detailData.companions.length - 1 ? ', ' : '' }}
                        </span>
                    </td>
                </tr>
                <tr v-if="store.detailData.description">
                    <th>상세 설명</th>
                    <td colspan="3">{{ store.detailData.description }}</td>
                </tr>
            </table>
        </template>

        <template v-if="store.selectedFormCode === 'FM003'">
            <table class="info-table">
                <tr>
                    <th>지출 목적</th>
                    <td>{{ store.detailData.expensePurpose }}</td>
                    <th>결제 방법</th>
                    <td>{{ store.detailData.expensePayMethod }}</td>
                </tr>
                <tr>
                    <th>요청 기한</th>
                    <td colspan="3">{{ store.detailData.expenseDueDate }}</td>
                </tr>
            </table>
            <table class="expense-table">
                <thead>
                    <tr>
                        <th>일자</th>
                        <th>내용</th>
                        <th>거래처</th>
                        <th>금액</th>
                        <th>비고</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(row, i) in store.expenseRows" :key="i">
                        <td>{{ row.date }}</td>
                        <td>{{ row.content }}</td>
                        <td>{{ row.vendor }}</td>
                        <td class="text-right">{{ Number(row.amount || 0).toLocaleString() }}원</td>
                        <td>{{ row.remark }}</td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <th colspan="3" class="text-right">합계</th>
                        <td class="text-right total">{{ store.expenseTotal.toLocaleString() }}원</td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
            <table class="info-table" v-if="store.detailData.description" style="margin-top:12px;">
                <tr>
                    <th>상세 설명</th>
                    <td>{{ store.detailData.description }}</td>
                </tr>
            </table>
        </template>

        <template v-if="store.selectedFormCode === 'FM004'">
            <table class="info-table">
                <tr>
                    <th>지출 목적</th>
                    <td colspan="3">{{ store.detailData.claimPurpose }}</td>
                </tr>
                <tr>
                    <th>계좌 정보</th>
                    <td colspan="3">{{ store.detailData.claimAccountInfo }}</td>
                </tr>
            </table>
            <table class="expense-table">
                <thead>
                    <tr>
                        <th>일자</th>
                        <th>내용</th>
                        <th>거래처</th>
                        <th>금액</th>
                        <th>비고</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(row, i) in store.expenseRows" :key="i">
                        <td>{{ row.date }}</td>
                        <td>{{ row.content }}</td>
                        <td>{{ row.vendor }}</td>
                        <td class="text-right">{{ Number(row.amount || 0).toLocaleString() }}원</td>
                        <td>{{ row.remark }}</td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <th colspan="3" class="text-right">합계</th>
                        <td class="text-right total">{{ store.expenseTotal.toLocaleString() }}원</td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
            <table class="info-table" v-if="store.detailData.description" style="margin-top:12px;">
                <tr>
                    <th>상세 설명</th>
                    <td>{{ store.detailData.description }}</td>
                </tr>
            </table>
        </template>

        <template v-if="store.selectedFormCode === 'FM005'">
            <table class="info-table">
                <tr>
                    <th>신청 목적</th>
                    <td>{{ store.detailData.generalPurpose }}</td>
                </tr>
                <tr v-if="store.detailData.description">
                    <th>상세 내용</th>
                    <td><div v-html="store.detailData.description"></div></td>
                </tr>
            </table>
        </template>

        <p class="pdf-footer-text">
            위와 같은 사유로 결재를 요청드리니 검토 후 승인하여 주시기 바랍니다.
        </p>

    </div>

</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

<script type="importmap">
{
    "imports": {
        "vue": "https://unpkg.com/vue@3/dist/vue.esm-browser.js",
        "vue-demi": "https://unpkg.com/vue-demi/lib/index.mjs",
        "pinia": "https://unpkg.com/pinia@2/dist/pinia.esm-browser.js",
        "@vue/devtools-api": "https://unpkg.com/@vue/devtools-api@6/lib/esm/index.js",
        "axios": "https://unpkg.com/axios@1/dist/esm/axios.js",
        "http": "/dist/util/http.js?v=2",
        "approvalViewStore": "/dist/util/store/approvalViewStore.js?v=8",
        "commonCodeStore": "/dist/util/store/commonCodeStore.js"
    }
}
</script>

<script type="module">
   import { createApp, onMounted, computed } from 'vue';
   import { createPinia } from 'pinia';
   import { useApprovalViewStore } from 'approvalViewStore';
   import { useCommonCodeStore } from 'commonCodeStore';

   const app = createApp({
       setup() {
           const store = useApprovalViewStore();
           const codeStore = useCommonCodeStore();
           const ctx = document.querySelector('meta[name="ctx"]').content;
           const docId = document.querySelector('meta[name="docId"]').content;

           const leaveTypeName = computed(() => {
               const code = store.detailData?.leaveType;
               if (!code) return '';
               const found = codeStore.getCodes('LEAVETYPE').find(c => c.code === code);
               return found ? found.name : code;
           });

           const downloadPdf = () => {
               const element = document.getElementById('pdf-content');
               const opt = {
                   margin:      10,
                   filename:    store.doc.typeName + '_' + docId + '.pdf',
                   image:       { type: 'jpeg', quality: 0.98 },
                   html2canvas: { scale: 2 },
                   jsPDF:       { unit: 'mm', format: 'a4', orientation: 'portrait' }
               };
               html2pdf().set(opt).from(element).save();
           };

           onMounted(async () => {
               await codeStore.fetchCodes('DOCSTATUS');
               await codeStore.fetchCodes('LINESTATUS');
               if (docId) {
                   await store.fetchDoc(docId);
                   if (store.selectedFormCode === 'FM001') {
                       await codeStore.fetchCodes('LEAVETYPE');
                   }
               }
           });

           const closePdf = () => { window.close(); };

           return { store, codeStore, downloadPdf, leaveTypeName, closePdf };
       }
   });

   app.use(createPinia());
   app.mount('#vue-app');
</script>

</body>
</html>
