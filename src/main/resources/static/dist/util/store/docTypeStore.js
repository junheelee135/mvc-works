import { defineStore } from 'pinia';
import http from 'http';

export const useDocTypeStore = defineStore('docType', {
    state: () => ({
        list: [],
        loading: false,
		
		form: {
		    docTypeId: null,
		    typeName: '',
		    typeCode: '',
		    description: '',
		    sortOrder: 0,
		    useYn: 'Y',
		    formCode: '',
		    notice: ''
		},		
		
        formMode: 'ADD'
    }),

    actions: {
		async fetchList() {
		    this.loading = true;
		    try {
		        const res = await http.get('/approval/doctype');
		        this.list = res.data.list;
		    } catch (error) {
		        console.error('목록 조회 실패:', error);
		    } finally {
		        this.loading = false;
		    }
		    this.fetchFormCodes();
		},

		async fetchFormCodes() {
		    try {
		        const res = await http.get('/common/code/FORMCODE');
		        this.formCodes = (res.data.list || []).map(item => ({
		            code: item.CODE || item.code,
		            name: item.CODENAME || item.codeName
		        }));
		    } catch (e) {
		        console.error('양식코드 조회 실패:', e);
		    }
		},
				
		openAddForm() {
		    this.form = { docTypeId: null, typeName: '', typeCode: '', description: '', sortOrder: 0, useYn: 'Y', formCode: '', notice: '' };
		    this.formMode = 'ADD';
		},	
		
		openEditForm(item) {
		    this.form = {
		        docTypeId: item.docTypeId,
		        typeName: item.typeName,
		        typeCode: item.typeCode,
		        description: item.description || '',
		        sortOrder: item.sortOrder,
		        useYn: item.useYn,
		        formCode: item.formCode || '',
		        notice: item.notice || ''
		    };
		    this.formMode = 'EDIT';
		},

        async saveForm() {
            if (!this.form.typeName.trim()) {
                alert('유형명을 입력하세요.');
                return false;
            }

            try {
                if (this.formMode === 'ADD') {
                    await http.post('/approval/doctype', this.form);
                    alert('등록되었습니다.');
                } else {
                    await http.put('/approval/doctype/' + this.form.docTypeId, this.form);
                    alert('수정되었습니다.');
                }

                this.fetchList();
                return true;
            } catch (error) {
                console.error('저장 실패:', error);
                alert('저장 중 오류가 발생했습니다.');
                return false;
            }
        },

        async deleteDocType(docTypeId) {
            if (!confirm('삭제하시겠습니까?')) return;

            try {
                await http.delete('/approval/doctype/' + docTypeId);
                alert('삭제되었습니다.');
                this.fetchList();
            } catch (error) {
                console.error('삭제 실패:', error);
                alert('삭제 중 오류가 발생했습니다.');
            }
        },

        async toggleUseYn(item) {
            try {
                const updated = {
                    docTypeId: item.docTypeId,
                    typeName: item.typeName,
                    description: item.description,
                    sortOrder: item.sortOrder,
                    useYn: item.useYn === 'Y' ? 'N' : 'Y'
                };
                await http.put('/approval/doctype/' + item.docTypeId, updated);
                this.fetchList();
            } catch (error) {
                console.error('사용여부 변경 실패:', error);
                alert('변경 중 오류가 발생했습니다.');
            }
        }
    }
});
