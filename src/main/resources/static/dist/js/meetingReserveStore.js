import { defineStore } from 'pinia';
import http from 'http';

export const useMeetingReserveStore = defineStore('meetingReserve', {

    state: () => ({
        reserveList: [],
        monthEvents: [],
        stats: { today: 0, week: 0, month: 0 },
        selectedDate: '',
        rooms: [],
        form: {
            roomId: '',
            reserveDate: '',
            startTime: '09:00',
            endTime: '10:00',
            title: '',
            memo: '',
            attendees: ''
        }
    }),

    actions: {
        // 날짜별 예약 목록
        async fetchByDate(date) {
            try {
                this.selectedDate = date;
                const res = await http.get('/meeting/reserve', { params: { date } });
                this.reserveList = res.data.list || [];
            } catch (e) {
                console.error('예약 목록 조회 실패:', e);
            }
        },

        // 월별 캘린더 이벤트
        async fetchMonthEvents(yearMonth) {
            try {
                const res = await http.get('/meeting/reserve/month', { params: { yearMonth } });
                this.monthEvents = res.data.list || [];
            } catch (e) {
                console.error('월별 이벤트 조회 실패:', e);
            }
        },

        // 통계
        async fetchStats() {
            try {
                const res = await http.get('/meeting/reserve/stats');
                this.stats = res.data;
            } catch (e) {
                console.error('통계 조회 실패:', e);
            }
        },

        // 사용중인 회의실 목록
        async fetchRooms() {
            try {
                const res = await http.get('/meeting/reserve/rooms');
                this.rooms = res.data.list || [];
            } catch (e) {
                console.error('회의실 목록 조회 실패:', e);
            }
        },

        // 예약 등록
        async saveReserve() {
            await http.post('/meeting/reserve', this.form);
            // 등록 후 목록 + 캘린더 + 통계 갱신
            await this.fetchByDate(this.selectedDate);
            const ym = this.selectedDate.substring(0, 7);
            await this.fetchMonthEvents(ym);
            await this.fetchStats();
        },

        // 예약 취소
        async cancelReserve(reserveId) {
            await http.delete('/meeting/reserve/' + reserveId);
            await this.fetchByDate(this.selectedDate);
            const ym = this.selectedDate.substring(0, 7);
            await this.fetchMonthEvents(ym);
            await this.fetchStats();
        },

        // 폼 초기화
        resetForm(date) {
            this.form = {
                roomId: this.rooms.length > 0 ? this.rooms[0].roomId : '',
                reserveDate: date || this.selectedDate,
                startTime: '09:00',
                endTime: '10:00',
                title: '',
                memo: '',
                attendees: ''
            };
        }
    }
});
