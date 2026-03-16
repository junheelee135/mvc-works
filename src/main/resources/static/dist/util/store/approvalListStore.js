import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import http from 'http';

export const useApprovalListStore = defineStore('approvalList', () => {

    // state
    const list = ref([]);
    const totalCount = ref(0);
    const filterType = ref('');
    const keyword = ref('');
    const startDate = ref('');
    const endDate = ref('');
    const pageNo = ref(1);
    const pageSize = ref(20);
    const loading = ref(false);
    const pendingCount = ref(0);
    const unreadCount = ref(0);
    const sortField = ref('regDate');
    const sortOrder = ref('desc');
    const statusFilter = ref('');

    // getters
    const totalPages = computed(() =>
        Math.ceil(totalCount.value / pageSize.value) || 1
    );

    // actions
    async function fetchList() {
        loading.value = true;
        try {
            const params = new URLSearchParams();
            if (keyword.value) params.append('keyword', keyword.value);
            if (startDate.value) params.append('startDate', startDate.value);
            if (endDate.value) params.append('endDate', endDate.value);
            params.append('pageNo', pageNo.value);
            params.append('pageSize', pageSize.value);
            if (sortField.value) params.append('sortField', sortField.value);
            if (sortOrder.value) params.append('sortOrder', sortOrder.value);
            if (statusFilter.value) params.append('statusFilter', statusFilter.value);

            const urlMap = {
                draft: '/approval/doc',
                sent:  '/approval/doc/sent',
                inbox: '/approval/doc/inbox',
                pendingInbox: '/approval/doc/inbox/pending',
                ref: '/approval/doc/ref',
                unreadRef: '/approval/doc/ref/unread',
                all: '/approval/doc/all',
            };
            const url = urlMap[filterType.value] || '/approval/doc';

            const res = await http.get(url + '?' + params.toString());
            list.value = res.data.list || [];
            totalCount.value = res.data.totalCount || 0;
        } catch (e) {
            console.error('목록 조회 실패:', e);
        } finally {
            loading.value = false;
        }
    }

    function search() {
        pageNo.value = 1;
        fetchList();
    }

    function changePage(page) {
        if (page < 1 || page > totalPages.value) return;
        pageNo.value = page;
        fetchList();
    }

    function changePageSize(size) {
        pageSize.value = size;
        pageNo.value = 1;
        fetchList();
    }

    function toggleSort(field) {
        if (sortField.value === field) {
            sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc';
        } else {
            sortField.value = field;
            sortOrder.value = 'desc';
        }
        pageNo.value = 1;
        fetchList();
    }

    async function fetchBadgeCounts() {
        try {
            const res = await http.get('/approval/doc/badge-counts');
            pendingCount.value = res.data.pendingCount || 0;
            unreadCount.value = res.data.unreadCount || 0;
        } catch (e) {
            console.error('뱃지 카운트 조회 실패:', e);
        }
    }

    return {
        list, totalCount, filterType, keyword,
        startDate, endDate, pageNo, pageSize,
        loading, pendingCount, unreadCount,
        sortField, sortOrder, statusFilter,
        totalPages,
        fetchList, search, changePage,
        changePageSize, toggleSort, fetchBadgeCounts
    };
});