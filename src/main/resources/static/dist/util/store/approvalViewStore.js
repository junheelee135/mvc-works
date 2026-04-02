import { defineStore } from 'pinia';
import http from 'http';
import { useCommonCodeStore } from 'commonCodeStore';

export const useApprovalViewStore = defineStore('approvalView', {
    state: () => ({
        doc: null,
        loading: false,
        error: null,
        // 세부정보 - create 때와 동일한 구조로 파싱해서 채움
        selectedFormCode: '',
        detailData: {},
        expenseRows: [],
        // 대결 관련
        isDeputy: false,
        originalApproverName: ''
    }),

    actions: {
        async fetchDoc(docId) {
            this.loading = true;
            this.error   = null;
            try {
                const res = await http.get('/approval/doc/' + docId);
                this.doc  = res.data;

				// DB에서 가져온 formCode 사용
				this.selectedFormCode = this.doc.formCode || '';

                // detailData JSON 파싱
                if (this.doc.detailData) {
                    try {
                        const parsed = JSON.parse(this.doc.detailData);
                        this.detailData  = parsed.detailData  || parsed || {};
                        this.detailData.companions = this.detailData.companions || [];
                        this.expenseRows = parsed.expenseRows || [];
                    } catch(e) {
                        console.warn('detailData 파싱 실패:', e);
                        this.detailData  = {};
                        this.expenseRows = [];
                    }
                }

                // 대결 여부 확인
                try {
                    const depRes = await http.get('/approval/doc/' + docId + '/deputy-check');
                    this.isDeputy = depRes.data.isDeputy === true;
                    this.originalApproverName = depRes.data.originalApproverName || '';
                } catch (de) {
                    this.isDeputy = false;
                    this.originalApproverName = '';
                }

            } catch (e) {
                console.error('문서 조회 실패:', e);
                this.error = '문서를 불러오지 못했습니다.';
            } finally {
                this.loading = false;
            }
        },

        // 파일 크기 포맷
        formatSize(bytes) {
            if (!bytes) return '0 B';
            if (bytes < 1024)        return bytes + ' B';
            if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
            return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
        },

        // 상태 한글 변환 (목록과 동일한 로직)
        statusLabel(code, empId) {
            const codeStore = useCommonCodeStore();
            const lines = this.doc?.lines || [];
            const totalCount = lines.length;

            if (code === 'PENDING' && totalCount > 0) {
                const approvedCount = lines.filter(l => l.apprStatus === 'APPROVED').length;
                const progress = approvedCount + '/' + totalCount;
                if (empId) {
                    const myLine = lines.find(l => l.apprEmpId === empId);
                    if (myLine && myLine.apprStatus === 'APPROVED') {
                        return '승인완료 (' + progress + ')';
                    }
                }
                return (approvedCount > 0 ? '결재중' : '대기중') + ' (' + progress + ')';
            }
            if (code === 'REJECTED' && totalCount > 0) {
                const approvedCount = lines.filter(l => l.apprStatus === 'APPROVED').length;
                return '반려 (' + approvedCount + '/' + totalCount + ')';
            }
            if (code === 'ON_HOLD' && totalCount > 0) {
                const approvedCount = lines.filter(l => l.apprStatus === 'APPROVED').length;
                return '보류 (' + approvedCount + '/' + totalCount + ')';
            }
            const found = codeStore.getCodes('DOCSTATUS').find(c => c.code === code);
            return found ? found.name : code;
        },

        // 상태 뱃지 CSS 클래스 (목록과 동일한 로직)
        statusBadgeClass(code, empId) {
            const lines = this.doc?.lines || [];
            if (code === 'PENDING') {
                if (empId) {
                    const myLine = lines.find(l => l.apprEmpId === empId);
                    if (myLine && myLine.apprStatus === 'APPROVED') {
                        return 'status-MYAPPROVED';
                    }
                }
                const approvedCount = lines.filter(l => l.apprStatus === 'APPROVED').length;
                if (approvedCount > 0) return 'status-INPROGRESS';
            }
            return 'status-' + code;
        },

        // 결재선 상태 한글 변환 (공통코드 LINESTATUS)
        lineStatusLabel(code) {
            const codeStore = useCommonCodeStore();
            const found = codeStore.getCodes('LINESTATUS').find(c => c.code === code);
            return found ? found.name : code;
        },

        // 결재취소
        async cancelDoc(docId) {
            try {
                await http.post('/approval/doc/' + docId + '/cancel');
                alert('결재가 취소되었습니다.');
                return true;
            } catch (e) {
                const msg = e.response?.data?.msg || '취소 처리 중 오류가 발생했습니다.';
                alert(msg);
                return false;
            }
        },

		// 승인
		async approveDoc(docId, comment) {
		    try {
		        await http.post('/approval/doc/' + docId + '/approve', { comment });
		        alert('승인되었습니다.');
		        return true;
		    } catch (e) {
		        alert(e.response?.data?.msg || '승인 처리 실패');
		        return false;
		    }
		},

		// 반려
		async rejectDoc(docId, comment) {
		    try {
		        await http.post('/approval/doc/' + docId + '/reject', { comment });
		        alert('반려되었습니다.');
		        return true;
		    } catch (e) {
		        alert(e.response?.data?.msg || '반려 처리 실패');
		        return false;
		    }
		},

		// 보류
		async holdDoc(docId, comment) {
		    try {
		        await http.post('/approval/doc/' + docId + '/hold', { comment });
		        alert('보류 처리되었습니다.');
		        return true;
		    } catch (e) {
		        alert(e.response?.data?.msg || '보류 처리 실패');
		        return false;
		    }
		},

		// 임시저장 삭제
		async deleteDraft(docId) {
		    try {
		        await http.post('/approval/doc/' + docId + '/delete');
		        alert('문서가 삭제되었습니다.');
		        return true;
		    } catch (e) {
		        alert(e.response?.data?.msg || '삭제 처리 중 오류가 발생했습니다.');
		        return false;
		    }
		},

		// 참조자 코멘트
		async saveRefComment(docId, comment) {
		    try {
		        await http.post('/approval/doc/' + docId + '/ref-comment', { comment });
		        alert('의견이 등록되었습니다.');
		        return true;
		    } catch (e) {
		        alert(e.response?.data?.msg || '의견 등록 실패');
		        return false;
		    }
		}		
    },

    getters: {
        expenseTotal: (state) => {
            return (state.expenseRows || []).reduce((sum, r) => sum + (Number(r.amount) || 0), 0);
        },
        canCancel: (state) => {
            if (!state.doc) return false;
            if (state.doc.docStatus === 'PENDING' && state.doc.lines) {
                return state.doc.lines.every(l => l.apprStatus === 'WAIT');
            }
            return false;
        },
		// 현재 결재 순서인 결재자인지 (대결자 포함)
		isCurrentApprover: (state) => {
		    return (empId) => {
		        if (!state.doc) return false;
		        const lines = state.doc.lines || [];

		        // ON_HOLD: 보류 처리한 본인만 처리 가능
		        if (state.doc.docStatus === 'ON_HOLD') {
		            const holdLine = lines.find(l => l.apprStatus === 'HOLD');
		            if (!holdLine) return false;
		            if (holdLine.apprEmpId === empId) return true;
		            // 대결자가 보류했을 경우
		            if (holdLine.isDeputy === 'Y' && holdLine.deputyEmpId === empId) return true;
		            return false;
		        }

		        // PENDING: 기존 로직
		        if (state.doc.docStatus !== 'PENDING') return false;
		        const waitLines = lines.filter(l => l.apprStatus === 'WAIT');
		        if (waitLines.length === 0) return false;
		        const minStep = Math.min(...waitLines.map(l => l.stepOrder));
		        const current = waitLines.find(l => l.stepOrder === minStep);
		        if (current && current.apprEmpId === empId) return true;
		        // 대결자인 경우
		        if (state.isDeputy) return true;
		        return false;
		    };
		},

		// 재상신 가능 여부 (반려 문서 + 기안자 본인)
		canResubmit: (state) => {
		    return (empId) => {
		        if (!state.doc) return false;
		        return state.doc.docStatus === 'REJECTED' && state.doc.writerEmpId === empId;
		    };
		},

		// 참조자인지
		isReference: (state) => {
		    return (empId) => {
		        if (!state.doc) return false;
		        return (state.doc.refs || []).some(r => r.refEmpId === empId);
		    };
		}
    }
});