<%@ page contentType="text/html; charset=UTF-8"%>

<!-- 상단 액션 바 -->
<div class="approval-topbar">
    <!-- 새 결재 작성 -->
    <button class="btn-new-approval" @click="goCreate">
        <span class="material-symbols-outlined">edit_square</span>
        새 결재 작성
    </button>

    <!-- 컨트롤 -->
    <div class="topbar-controls">
        <!-- 새로고침 -->
        <button class="btn-refresh" title="새로고침" @click="store.search()">
            <span class="material-symbols-outlined">refresh</span>
        </button>

        <!-- 페이지 크기 -->
        <select v-model.number="store.pageSize" @change="store.changePageSize(store.pageSize)">
            <option :value="10">10개</option>
            <option :value="20">20개</option>
            <option :value="50">50개</option>
        </select>

        <!-- 날짜 범위 -->
        <input type="date" v-model="store.startDate">
        <input type="date" v-model="store.endDate">

        <!-- 검색어 -->
        <input type="text" placeholder="제목 검색" v-model="store.keyword"
               @keyup.enter="store.search()">

        <!-- 검색 버튼 -->
        <button class="btn-search" @click="store.search()">
            <span class="material-symbols-outlined">search</span>
            검색
        </button>
    </div>

    <!-- 옵션 버튼 -->
    <button class="btn-options">
        <span class="material-symbols-outlined">tune</span>
        옵션
    </button>
</div>