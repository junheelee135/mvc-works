import { defineStore } from 'pinia';
import { ref } from 'vue';
import http from 'http';

export const useCommonCodeStore = defineStore('commonCode', () => {

    const codes = ref({});

    async function fetchCodes(codeGroup) {

        if (codes.value[codeGroup]) return codes.value[codeGroup];

        try {
            const res = await http.get('/common/code/' + codeGroup);
            const list = (res.data.list || []).map(item => ({
                code: item.CODE || item.code,
                name: item.CODENAME || item.codeName
            }));
            codes.value[codeGroup] = list;
            return list;
        } catch (e) {
            console.error('공통코드 로딩 실패 [' + codeGroup + ']:', e);
            return [];
        }
    }

    function getCodes(codeGroup) {
        return codes.value[codeGroup] || [];
    }

    return { codes, fetchCodes, getCodes };
});