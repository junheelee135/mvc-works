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
        async fetchByDate(date) {
            try {
                this.selectedDate = date;
                const res = await http.get('/meeting/reserve', { params: { date } });
                this.reserveList = res.data.list || [];
            } catch (e) {
                console.error('예약 목록 조회 실패:', e);
            }
        },

        async fetchMonthEvents(yearMonth) {
            try {
                const res = await http.get('/meeting/reserve/month', { params: { yearMonth } });
                this.monthEvents = res.data.list || [];
            } catch (e) {
                console.error('월별 이벤트 조회 실패:', e);
            }
        },

        async fetchStats() {
            try {
                const res = await http.get('/meeting/reserve/stats');
                this.stats = res.data;
            } catch (e) {
                console.error('통계 조회 실패:', e);
            }
        },

        async fetchRooms() {
            try {
                const res = await http.get('/meeting/reserve/rooms');
                this.rooms = res.data.list || [];
            } catch (e) {
                console.error('회의실 목록 조회 실패:', e);
            }
        },

        async saveReserve() {
            await http.post('/meeting/reserve', this.form);
            await this.fetchByDate(this.selectedDate);
            const ym = this.selectedDate.substring(0, 7);
            await this.fetchMonthEvents(ym);
            await this.fetchStats();
        },

        async cancelReserve(reserveId) {
            await http.delete('/meeting/reserve/' + reserveId);
            await this.fetchByDate(this.selectedDate);
            const ym = this.selectedDate.substring(0, 7);
            await this.fetchMonthEvents(ym);
            await this.fetchStats();
        },

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
