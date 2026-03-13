import { defineStore } from 'pinia';
import http from 'http';

export const useApprovalListStore = defineStore('approvalList', {
    state: () => ({
        list: [],
        totalCount: 0,
        filterType: '',
        keyword: '',
        startDate: '',
        endDate: '',
        pageNo: 1,
        pageSize: 20,
        loading: false,
        pendingCount: 0,
        unreadCount: 0
    }),

    getters: {
        totalPages: (state) => {
            return Math.ceil(state.totalCount / state.pageSize) || 1;
        }
    },

    actions: {
        async fetchList() {
            this.loading = true;
            try {
                const params = new URLSearchParams();
                if (this.keyword) params.append('keyword', this.keyword);
                if (this.startDate) params.append('startDate', this.startDate);
                if (this.endDate) params.append('endDate', this.endDate);
                params.append('pageNo', this.pageNo);
                params.append('pageSize', this.pageSize);

				const urlMap = {
				    draft: '/approval/doc',
				    sent:  '/approval/doc/sent',
				    inbox: '/approval/doc/inbox',
				    pendingInbox: '/approval/doc/inbox/pending',
				    ref: '/approval/doc/ref',
				    unreadRef: '/approval/doc/ref/unread',
				    all: '/approval/doc/all',
				};
				const url = urlMap[this.filterType] || '/approval/doc';
				
				const res = await http.get(url + '?' + params.toString());
                this.list = res.data.list || [];
                this.totalCount = res.data.totalCount || 0;
            } catch (e) {
                console.error('목록 조회 실패:', e);
            } finally {
                this.loading = false;
            }
        },

        search() {
            this.pageNo = 1;
            this.fetchList();
        },

        changePage(page) {
            if (page < 1 || page > this.totalPages) return;
            this.pageNo = page;
            this.fetchList();
        },

        changePageSize(size) {
            this.pageSize = size;
            this.pageNo = 1;
            this.fetchList();
        },

        async fetchBadgeCounts() {
            try {
                const res = await http.get('/approval/doc/badge-counts');
                this.pendingCount = res.data.pendingCount || 0;
                this.unreadCount = res.data.unreadCount || 0;
            } catch (e) {
                console.error('뱃지 카운트 조회 실패:', e);
            }
        }
    }
});