<%@ page contentType="text/html; charset=UTF-8"%>

<!-- 오른쪽 테이블 -->
<div class="table-panel">
    <table class="approval-table">
        <thead>
            <tr>
                <th class="cb-col">
                    <input type="checkbox" id="chkAll" title="전체선택">
                </th>
                <th>
                    <span class="th-inner">
                        작성일
                        <span class="material-symbols-outlined">unfold_more</span>
                    </span>
                </th>
                <th>결재 분류</th>
                <th>제목</th>
                <th>
                    <span class="th-inner">
                        작성자
                        <span class="material-symbols-outlined">unfold_more</span>
                    </span>
                </th>
                <th>결재 상태</th>
            </tr>
        </thead>
        <tbody>
            <!-- 데이터 없음 -->
            <tr v-if="store.list.length === 0">
                <td colspan="6" style="text-align:center; padding:40px; color:#9aa0b4;">
                    조회된 문서가 없습니다.
                </td>
            </tr>
            <!-- 데이터 목록 -->
            <tr v-for="item in store.list" :key="item.docId"
                @click="goDoc(item)"
                :class="{ 'row-unread': (store.filterType === 'ref' || store.filterType === 'unreadRef') && item.readYn === 'N' }"
                style="cursor:pointer;">
                <td class="cb-col" @click.stop><input type="checkbox" name="chk" :value="item.docId"></td>
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

    <!-- 페이지네이션 -->
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