<%@ page contentType="text/html; charset=UTF-8"%>

<div class="filter-panel">

    <div class="filter-section">
        <div class="filter-label">Approval Action</div>
        <a class="filter-link" :class="{ active: store.filterType === 'pendingInbox' }" href="#"
           @click.prevent="store.filterType = 'pendingInbox'; store.search()">
            <span class="material-symbols-outlined">mail</span>
            미결재 문서
            <span class="badge-count" v-if="store.pendingCount > 0">{{ store.pendingCount }}</span>
        </a>
        <a class="filter-link" :class="{ active: store.filterType === 'unreadRef' }" href="#"
           @click.prevent="store.filterType = 'unreadRef'; store.search()">
            <span class="material-symbols-outlined">mark_email_unread</span>
            미확인 문서
            <span class="badge-count" v-if="store.unreadCount > 0">{{ store.unreadCount }}</span>
        </a>
    </div>

    <div class="filter-section">
        <div class="filter-label">Approval List</div>
       <a class="filter-link" :class="{ active: store.filterType === 'all' }" href="#" @click.prevent="store.filterType = 'all'; store.search()">
            <span class="material-symbols-outlined">inbox</span>
            전체 결재함
        </a>
        <a class="filter-link" :class="{ active: store.filterType === 'sent' }" href="#" @click.prevent="store.filterType = 'sent'; store.search()">
            <span class="material-symbols-outlined">send</span>
            보낸 결재함
        </a>
        <a class="filter-link" :class="{ active: store.filterType === 'inbox' }" href="#" @click.prevent="store.filterType = 'inbox'; store.search()">
            <span class="material-symbols-outlined">move_to_inbox</span>
            받은 결재함
        </a>
        <a class="filter-link" :class="{ active: store.filterType === 'ref' }" href="#" @click.prevent="store.filterType = 'ref'; store.search()">
            <span class="material-symbols-outlined">bookmarks</span>
            참조 결재함
        </a>
        <a class="filter-link" :class="{ active: store.filterType === 'draft' }" href="#" @click.prevent="store.filterType = 'draft'; store.search()">
            <span class="material-symbols-outlined">edit_note</span>
            임시 저장함
        </a>
    </div>

</div>
