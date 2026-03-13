import { defineStore } from 'pinia';
import http from 'http';

export const useAbsenceStore = defineStore('absence', {
    state: () => ({
        // 목록
        list: [],
        total: 0,
        pageNo: 1,
        pageSize: 20,

        // 등록/수정 폼
        editMode: false,
        editDeputyRegId: null,
        form: {
            deputyEmpId: '',
            deputyName: '',
            startDate: '',
            endDate: '',
            reason: '',
            isActive: 'Y'
        }
    }),

    actions: {
        // ── 폼 초기화 ──
        resetForm() {
            this.editMode = false;
            this.editDeputyRegId = null;
            this.form = {
                deputyEmpId: '',
                deputyName: '',
                startDate: '',
                endDate: '',
                reason: '',
                isActive: 'Y'
            };
        },

        // ── 목록 조회 ──
        async fetchList() {
            try {
                const res = await http.get('/api/absence/list', {
                    params: {
                        pageNo: this.pageNo,
                        pageSize: this.pageSize
                    }
                });
                this.list = res.data.list || [];
                this.total = res.data.total || 0;
            } catch (e) {
                console.error('부재 목록 조회 실패:', e);
                alert('목록을 불러오지 못했습니다.');
            }
        },

        // ── 단건 조회 (수정 모드 진입) ──
        async loadDeputy(deputyRegId) {
            try {
                const res = await http.get('/api/absence/' + deputyRegId);
                const data = res.data;
                this.editMode = true;
                this.editDeputyRegId = deputyRegId;
                this.form = {
                    deputyEmpId: data.deputyEmpId,
                    deputyName:  data.deputyName,
                    startDate:   data.startDate,
                    endDate:     data.endDate,
                    reason:      data.reason || '',
                    isActive:    data.isActive
                };
            } catch (e) {
                console.error('부재 조회 실패:', e);
                alert('부재 정보를 불러오지 못했습니다.');
            }
        },

        // ── 등록 ──
        async registerDeputy() {
            if (!this.form.deputyEmpId) {
                alert('대결자를 선택해 주세요.');
                return false;
            }
            if (!this.form.startDate || !this.form.endDate) {
                alert('부재 시작일과 종료일을 입력해 주세요.');
                return false;
            }
            if (this.form.startDate > this.form.endDate) {
                alert('종료일은 시작일보다 빠를 수 없습니다.');
                return false;
            }

            try {
                await http.post('/api/absence', { ...this.form });
                alert('부재가 등록되었습니다.');
                this.resetForm();
                await this.fetchList();
                return true;
            } catch (e) {
                console.error('부재 등록 실패:', e);
                alert('부재 등록 중 오류가 발생했습니다.');
                return false;
            }
        },

        // ── 수정 ──
        async updateDeputy() {
            if (!this.form.deputyEmpId) {
                alert('대결자를 선택해 주세요.');
                return false;
            }
            if (!this.form.startDate || !this.form.endDate) {
                alert('부재 시작일과 종료일을 입력해 주세요.');
                return false;
            }
            if (this.form.startDate > this.form.endDate) {
                alert('종료일은 시작일보다 빠를 수 없습니다.');
                return false;
            }

            try {
                await http.put('/api/absence/' + this.editDeputyRegId, { ...this.form });
                alert('부재가 수정되었습니다.');
                this.resetForm();
                await this.fetchList();
                return true;
            } catch (e) {
                console.error('부재 수정 실패:', e);
                alert('부재 수정 중 오류가 발생했습니다.');
                return false;
            }
        },

        // ── 등록/수정 통합 저장 ──
        async save() {
            if (this.editMode) {
                return await this.updateDeputy();
            } else {
                return await this.registerDeputy();
            }
        }
    }
});