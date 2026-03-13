import { defineStore } from 'pinia';
import http from 'http';

export const useCommonCodeStore = defineStore('commonCode', {
    state: () => ({
        codes: {}
    }),

    actions: {
        async fetchCodes(codeGroup) {
            // 이미 로딩된 그룹이면 캐시 반환
            if (this.codes[codeGroup]) return this.codes[codeGroup];

            try {
                const res = await http.get('/common/code/' + codeGroup);
                const list = (res.data.list || []).map(item => ({
                    code: item.CODE || item.code,
                    name: item.CODENAME || item.codeName
                }));
                this.codes[codeGroup] = list;
                return list;
            } catch (e) {
                console.error('공통코드 로딩 실패 [' + codeGroup + ']:', e);
                return [];
            }
        },

        // 특정 그룹 코드 목록 가져오기
        getCodes(codeGroup) {
            return this.codes[codeGroup] || [];
        }
    }
});