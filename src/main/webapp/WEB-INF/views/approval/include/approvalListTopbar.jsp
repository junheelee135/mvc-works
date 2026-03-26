<%@ page contentType="text/html; charset=UTF-8"%>

<div class="approval-topbar">
    <button class="btn-new-approval" @click="goCreate">
        <span class="material-symbols-outlined">edit_square</span>
        새 결재 작성
    </button>

    <div class="topbar-controls">
        <button class="btn-refresh" title="새로고침" @click="store.search()">
            <span class="material-symbols-outlined">refresh</span>
        </button>

        <select v-model.number="store.pageSize" @change="store.changePageSize(store.pageSize)">
            <option :value="10">10개</option>
            <option :value="20">20개</option>
            <option :value="50">50개</option>
        </select>

        <input type="date" v-model="store.startDate">
        <input type="date" v-model="store.endDate">

        <input type="text" placeholder="제목 검색" v-model="store.keyword"
               @keyup.enter="store.search()">

        <button class="btn-search" @click="store.search()">
            <span class="material-symbols-outlined">search</span>
            검색
        </button>
    </div>

</div>
