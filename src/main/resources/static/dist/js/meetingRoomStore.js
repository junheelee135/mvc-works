import { defineStore } from 'pinia';
import http from 'http';

export const useMeetingRoomStore = defineStore('meetingRoom', {

    state: () => ({
        list: [],
        currentRoom: null,
        formMode: '',
        form: {
            roomName: '',
            location: '',
            capacity: 0,
            sortOrder: 0,
            useYn: 'Y',
            equipCodes: []
        }
    }),

    actions: {
        async fetchList() {
            const res = await http.get('/meeting/room');
            this.list = res.data.list || [];
        },

        async fetchRoom(roomId) {
            const res = await http.get('/meeting/room/' + roomId);
            this.currentRoom = res.data;
            return res.data;
        },

        openAddForm() {
            this.formMode = 'ADD';
            this.form = {
                roomName: '',
                location: '',
                capacity: 0,
                sortOrder: 0,
                useYn: 'Y',
                equipCodes: []
            };
        },

        openEditForm(room) {
            this.formMode = 'EDIT';
            this.currentRoom = room;
            this.form = {
                roomName: room.roomName,
                location: room.location,
                capacity: room.capacity,
                sortOrder: room.sortOrder,
                useYn: room.useYn,
                equipCodes: room.equipCodes ? [...room.equipCodes] : []
            };
        },

        async saveRoom(photoFiles) {
            try {
                const formData = new FormData();

                const blob = new Blob([JSON.stringify(this.form)], { type: 'application/json' });
                formData.append('data', blob);

                if (photoFiles && photoFiles.length > 0) {
                    for (const file of photoFiles) {
                        formData.append('photos', file);
                    }
                }

                const cfg = { headers: { 'Content-Type': 'multipart/form-data' } };

                if (this.formMode === 'ADD') {
                    await http.post('/meeting/room', formData, cfg);
                } else {
                    await http.put('/meeting/room/' + this.currentRoom.roomId, formData, cfg);
                }

                this.formMode = '';
                await this.fetchList();
            } catch (e) {
                console.error('회의실 저장 실패:', e);
                alert('회의실 저장 중 오류가 발생했습니다.');
            }
        },

        async saveSortOrders() {
            try {
                const payload = this.list.map((item, i) => ({
                    roomId: item.roomId,
                    sortOrder: i + 1
                }));
                await http.put('/meeting/room/sort', payload);
            } catch (e) {
                console.error('순서 변경 실패:', e);
                await this.fetchList();
            }
        },

        async deleteRoom(roomId) {
            await http.delete('/meeting/room/' + roomId);
            await this.fetchList();
        }
    }
});
