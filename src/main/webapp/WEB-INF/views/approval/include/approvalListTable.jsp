<%@ page contentType="text/html; charset=UTF-8"%>

<div class="table-panel">
    <table class="approval-table">
        <thead>
            <tr>
				<th class="cb-col">No.</th>
                <th @click="toggleSort('regDate')"
                    :class="{ 'sort-active': store.sortField === 'regDate' }">
                    <span class="th-inner">
                        작성일
                        <span class="material-symbols-outlined sort-icon">{{
                            store.sortField === 'regDate'
                                ? (store.sortOrder === 'asc' ? 'arrow_upward' : 'arrow_downward')
                                : 'unfold_more'
                        }}</span>
                    </span>
                </th>
                <th @click="toggleSort('typeName')"
                    :class="{ 'sort-active': store.sortField === 'typeName' }">
                    <span class="th-inner">
                        결재 분류
                        <span class="material-symbols-outlined sort-icon">{{
                            store.sortField === 'typeName'
                                ? (store.sortOrder === 'asc' ? 'arrow_upward' : 'arrow_downward')
                                : 'unfold_more'
                        }}</span>
                    </span>
                </th>
                <th @click="toggleSort('title')"
                    :class="{ 'sort-active': store.sortField === 'title' }">
                    <span class="th-inner">
                        제목
                        <span class="material-symbols-outlined sort-icon">{{
                            store.sortField === 'title'
                                ? (store.sortOrder === 'asc' ? 'arrow_upward' : 'arrow_downward')
                                : 'unfold_more'
                        }}</span>
                    </span>
                </th>
                <th @click="toggleSort('writerEmpName')"
                    :class="{ 'sort-active': store.sortField === 'writerEmpName' }">
                    <span class="th-inner">
                        작성자
                        <span class="material-symbols-outlined sort-icon">{{
                            store.sortField === 'writerEmpName'
                                ? (store.sortOrder === 'asc' ? 'arrow_upward' : 'arrow_downward')
                                : 'unfold_more'
                        }}</span>
                    </span>
                </th>
                <th>결재 상태</th>
            </tr>
        </thead>
        <tbody>
            <tr v-if="store.list.length === 0">
                <td colspan="6" style="text-align:center; padding:40px; color:#9aa0b4;">
                    조회된 문서가 없습니다.
                </td>
            </tr>
            <tr v-for="(item, index) in store.list" :key="item.docId"
                @click="goDoc(item)"
                :class="{ 'row-unread': (store.filterType === 'ref' || store.filterType === 'unreadRef') && item.readYn === 'N' }"
                style="cursor:pointer;">
                <td class="cb-col">{{ store.totalCount - ((store.pageNo - 1) * store.pageSize) - index}}</td>
                <td>{{ item.regDate }}</td>
                <td>{{ item.typeName }}</td>
                <td class="td-title">
                    {{ item.title }}
                    <span v-if="(store.filterType === 'ref' || store.filterType === 'unreadRef') && item.readYn === 'N'" class="read-badge unread">안읽음</span>
                    <span v-if="store.filterType === 'ref' && item.readYn === 'Y'" class="read-badge read">읽음</span>
                </td>
                <td>{{ item.writerEmpName }} {{ item.writerGradeName }}</td>
                <td>
                    <span class="status-badge"
                          :class="statusClass(item)">
                        {{ statusText(item) }}
                    </span>
                </td>
            </tr>
        </tbody>
    </table>

    <div class="table-pagination">
        <button class="page-btn" :disabled="store.pageNo <= 1"
                @click="store.changePage(1)">&laquo; 처음</button>
        <button class="page-btn" :disabled="store.pageNo <= 1"
                @click="store.changePage(store.pageNo - 1)">&lsaquo; 이전</button>
        <button class="page-btn"
                v-for="p in store.totalPages" :key="p"
                :class="{ active: p === store.pageNo }"
                @click="store.changePage(p)">{{ p }}</button>
        <button class="page-btn" :disabled="store.pageNo >= store.totalPages"
                @click="store.changePage(store.pageNo + 1)">다음 &rsaquo;</button>
        <button class="page-btn" :disabled="store.pageNo >= store.totalPages"
                @click="store.changePage(store.totalPages)">마지막 &raquo;</button>
    </div>
</div>
