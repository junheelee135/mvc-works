<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/approvalnotice.css?v=13" type="text/css">
<link href="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.snow.css" rel="stylesheet">
<style>
[v-cloak] { display: none; }

.notice-view img { max-width: 100%; }

</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
<div id="vue-app" v-cloak>

    <div v-if="store.viewMode === 'LIST'">

        <div class="notice-header">
            <div>
                <h4>
                    <span class="material-symbols-outlined">campaign</span>
                    결재 공지사항
                </h4>
                <p>결재 시스템 관련 공지사항입니다.</p>
            </div>
            <button v-if="isAdmin" class="btn-write" @click="store.openWriteForm()">
                <span class="material-symbols-outlined">edit</span>
                글쓰기
            </button>
        </div>

        <div class="notice-search">
            <input type="text" v-model="store.keyword"
                   placeholder="제목 또는 작성자 검색"
                   @keyup.enter="store.search()">
            <button @click="store.search()">
                <span class="material-symbols-outlined">search</span>
            </button>
        </div>

        <div class="table-panel">
            <table class="notice-table">
                <thead>
                    <tr>
                        <th style="width:70px; text-align:center;">번호</th>
                        <th>제목</th>
                        <th style="width:120px; text-align:center;">작성자</th>
                        <th style="width:140px; text-align:center;">작성일</th>
                        <th style="width:80px; text-align:center;">조회수</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-if="store.list.length === 0">
                        <td colspan="5" style="text-align:center; padding:40px; color:#9aa0b4;">
                            등록된 공지사항이 없습니다.
                        </td>
                    </tr>
                    <tr v-for="item in store.list" :key="item.noticeId"
                        @click="store.fetchDoc(item.noticeId)"
                        style="cursor:pointer;">
                        <td style="text-align:center; color:#9aa0b4;">{{ item.noticeId }}</td>
                        <td class="td-title">{{ item.title }}</td>
                        <td style="text-align:center;">{{ item.writerName }}</td>
                        <td style="text-align:center; color:#9aa0b4; font-size:12px;">{{item.regDate }}</td>
                        <td style="text-align:center; color:#9aa0b4;">{{ item.hitCount }}</td>
                    </tr>
                </tbody>
            </table>

            <div class="table-pagination">
                <button class="page-btn" :disabled="store.pageNo <= 1"
                        @click="store.changePage(1)">&laquo; 처음</button>
                <button class="page-btn" v-if="store.pagination.showPrev"
                        @click="store.changePage(store.pagination.prevBlockPage)">&lsaquo; 이전</button>
                <button class="page-btn"
                        v-for="p in store.pagination.pages" :key="p"
                        :class="{ active: p === store.pageNo }"
                        @click="store.changePage(p)">{{ p }}</button>
                <button class="page-btn" v-if="store.pagination.showNext"
                        @click="store.changePage(store.pagination.nextBlockPage)">다음 &rsaquo;</button>
                <button class="page-btn" :disabled="store.pageNo >= store.totalPages"
                        @click="store.changePage(store.totalPages)">마지막 &raquo;</button>
            </div>
        </div>

      </div>

   <div v-if="store.viewMode === 'DETAIL' && store.doc">

       <div class="notice-view">

           <div class="view-title">{{ store.doc.title }}</div>
           <div class="view-info">
               <span>작성자: {{ store.doc.writerName }}</span>
               <span>작성일: {{ store.doc.regDate }}</span>
               <span v-if="store.doc.updateDate">수정일: {{ store.doc.updateDate }}</span>
               <span>조회수: {{ store.doc.hitCount }}</span>
           </div>

           <div class="view-content" v-html="store.doc.content"></div>

           <div class="detail-files" v-if="store.doc.files && store.doc.files.length > 0">
               <div class="detail-files-title">첨부파일</div>
               <a v-for="file in store.doc.files" :key="file.fileId"
                  :href="'/api/approval/notice/file/' + file.fileId + '/download'"
                  class="file-item">
                   <span class="material-symbols-outlined">attach_file</span>
                   {{ file.oriFilename }} ({{ store.formatFileSize(file.fileSize) }})
               </a>
           </div>

           <div class="view-footer">
               <button class="btn-list" @click="store.goList()">목록</button>
               <div v-if="isAdmin">
                   <button class="btn-edit" @click="store.openEditForm()">수정</button>
                   <button class="btn-del" @click="store.deleteNotice(store.doc.noticeId)">삭제</button>
               </div>
           </div>
       </div>

   </div>

   <div v-if="store.viewMode === 'WRITE' || store.viewMode === 'EDIT'">

       <div class="notice-form">
           <h4>{{ store.viewMode === 'WRITE' ? '공지사항 등록' : '공지사항 수정' }}</h4>

           <div class="form-group">
               <label>제목 <span style="color:#d93025;">*</span></label>
               <input type="text" v-model="store.form.title" placeholder="제목을 입력하세요">
           </div>

           <div class="form-group">
               <label>내용</label>
               <div id="quill-editor" style="height:300px;"></div>
           </div>

           <div class="attach-section">
               <div class="attach-section-title">
                   <span class="material-symbols-outlined">attach_file</span>
                   첨부파일
               </div>
               <div class="attach-row">
                   <div class="attach-field">
                       <div class="attach-field-label">파일 업로드 <span style="font-size:10px;color:#9aa0b4;">ⓘ 최대 10개, 개당 50MB</span></div>
                       <div class="attach-input-wrap">
                           <label class="btn-file-select" for="notice-file-input">파일 선택</label>
                           <span class="file-name-display">{{ store.attachedFiles.length > 0 ? store.attachedFiles.length + '개 파일 선택됨' : '선택된 파일 없음' }}</span>
                           <input type="file" id="notice-file-input" style="display:none" multiple
                                  @change="store.addFiles($event.target.files); $event.target.value = ''">
                       </div>
                   </div>
                   <div class="attach-field">
                       <div class="attach-field-label">첨부된 파일</div>
                       <div class="attach-file-list" v-if="store.attachedFiles.length > 0 || (store.viewMode === 'EDIT' && store.doc.files && store.doc.files.length > 0)">
                           <div class="attach-file-item" v-if="store.viewMode === 'EDIT'" v-for="file in store.doc.files" :key="file.fileId">
                               <span class="material-symbols-outlined" style="font-size:16px;color:#6c63ff;">description</span>
                               <span class="attach-file-name">{{ file.oriFilename }}</span>
                               <span class="attach-file-size">({{ store.formatFileSize(file.fileSize) }})</span>
                               <button class="attach-file-remove" @click="store.deleteExistingFile(file.fileId)">
                                   <span class="material-symbols-outlined" style="font-size:16px;">close</span>
                               </button>
                           </div>
                           <div class="attach-file-item" v-for="(file, idx) in store.attachedFiles" :key="'new'+idx">
                               <span class="material-symbols-outlined" style="font-size:16px;color:#6c63ff;">description</span>
                               <span class="attach-file-name">{{ file.name }}</span>
                               <span class="attach-file-size">({{ store.formatFileSize(file.size) }})</span>
                               <button class="attach-file-remove" @click="store.removeFile(idx)">
                                   <span class="material-symbols-outlined" style="font-size:16px;">close</span>
                               </button>
                           </div>
                       </div>
                       <div class="attach-preview" v-else>첨부된 파일이 없습니다.</div>
                   </div>
               </div>
           </div>

           <div class="form-footer">
               <button class="btn-cancel" @click="store.goList()">취소</button>
               <button class="btn-save" @click="handleSave">저장</button>
           </div>
       </div>

   </div>

</div>
</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

  <script type="importmap">
  {
      "imports": {
          "http": "/dist/util/http.js?v=2",
          "approvalNoticeStore": "/dist/util/store/approvalNoticeStore.js"
      }
  }
  </script>

<script type="module">
   import { createApp, onMounted, watch } from 'vue';
   import { createPinia } from 'pinia';
   import { useApprovalNoticeStore } from 'approvalNoticeStore';

   let quill = null;   // Quill 에디터 인스턴스 (전역 변수)

   const app = createApp({
       setup() {
           const store = useApprovalNoticeStore();

           // ADMIN이면 true
           const isAdmin = ${sessionScope.member.userLevel} === 99;

           // Quill 에디터 사용
           watch(() => store.viewMode, (newMode) => {
               if (newMode === 'WRITE' || newMode === 'EDIT') {
                   // Vue가 DOM을 그린 후 실행 (nextTick 역할)
                   setTimeout(() => {
                       const container = document.getElementById('quill-editor');
                       if (!container) return;

                       quill = new Quill('#quill-editor', {
                           theme: 'snow',
                           placeholder: '내용을 입력하세요...',
                           modules: {
                               toolbar: [
                                   [{ 'header': [1, 2, 3, false] }],
                                   ['bold', 'italic', 'underline'],
                                   [{ 'color': [] }, { 'background': [] }],
                                   [{ 'list': 'ordered' }, { 'list': 'bullet' }],
                                   ['link'],
                                   ['clean']
                               ]
                           }
                       });

                       if (newMode === 'EDIT' && store.form.content) {
                           quill.clipboard.dangerouslyPasteHTML(store.form.content);
                       }
                   }, 100);
               }
           });

           // 저장
           const handleSave = () => {
               if (quill) {
                   store.form.content = quill.root.innerHTML;
               }
               store.saveForm();
           };

           onMounted(() => {
               store.fetchList();
           });

           return { store, isAdmin, handleSave };
       }
   });

   app.use(createPinia());    // Pinia 플러그인 등록
   app.mount('#vue-app');     // #vue-app에 Vue 앱 연결
</script>

<script src="https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.js"></script>

</body>
</html>
