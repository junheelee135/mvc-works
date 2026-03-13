import { defineStore } from 'pinia';
import http from 'http';

export const useApprovalCreateStore = defineStore('approvalCreate', {
    state: () => ({
        editMode: false,
        editDocId: null,
        editDocStatus: null,
        // 문서유형
        docTypeList: [],
        selectedDocTypeId: null,
        selectedDocTypeName: '',
        formVisible: false,
		selectedFormCode: '',
		selectedNotice: '',
		expenseRows: [{ date: '', content: '', vendor: '', amount: 0, remark: '' }],

        // 결재선 / 참조자 / 첨부파일
        approvers: [],
        references: [],
		attachedFiles: [],

		title: '',
		detailData: {
		// FM001 휴가
		leaveType: '',
		leaveStartDate: '',
		leaveStartDayType: '종일',
		leaveEndDate: '',
		leaveEndDayType: '종일',
		leaveTotalDays: 0,
		// FM002 출장
		biztripPurpose: '',
		biztripCompanion: '',
		biztripStartDate: '',
		biztripEndDate: '',
		// FM003 지출
		expensePurpose: '',
		expensePayMethod: '',
		expenseDueDate: '',
		// FM004 청구
		claimPurpose: '',
		claimAccountInfo: '',
		// FM005 일반
		generalPurpose: '',
		// 공통
		description: ''
		}		
    }),

	getters: {
	    expenseTotal: (state) => {
	        return state.expenseRows.reduce((sum, row) => sum + (row.amount || 0), 0);
	    }
	},
		
    actions: {
        // ── 문서유형 ──
        async fetchDocTypes() {
            try {
                const res = await http.get('/approval/doctype');
                this.docTypeList = (res.data.list || []).filter(i => i.useYn === 'Y');
            } catch (e) {
                console.error('문서유형 로딩 실패:', e);
            }
        },

		async loadDraft(docId) {
		    try {
		        const res = await http.get('/approval/doc/' + docId);
		        const doc = res.data;

		        this.editMode = true;
		        this.editDocId = doc.docId;
		        this.editDocStatus = doc.docStatus;
		        this.title = doc.title;
		        this.selectedDocTypeId = doc.docTypeId;

		        const docType = this.docTypeList.find(d => d.docTypeId === doc.docTypeId);
		        if (docType) {
		            this.selectedDocTypeName = docType.typeName;
		            this.selectedFormCode = docType.formCode;
		            this.selectedNotice = docType.notice || '';
		        } else {
		            this.selectedDocTypeName = doc.typeName || '';
		            this.selectedFormCode = doc.formCode || '';
		        }
		        this.formVisible = true;

		        // detailData 파싱
		        if (doc.detailData) {
		            try {
		                const parsed = JSON.parse(doc.detailData);
		                Object.keys(parsed).forEach(key => {
		                    if (key === 'expenseRows') {
		                        this.expenseRows = parsed.expenseRows || [];
		                    } else if (key !== 'formCode') {
		                        this.detailData[key] = parsed[key];
		                    }
		                });
		            } catch(e) { console.warn('detailData 파싱 실패:', e); }
		        }

		        // 결재선 복원
		        if (doc.lines && doc.lines.length > 0) {
		            this.approvers = doc.lines.map(l => ({
		                empId: l.apprEmpId, name: l.apprEmpName,
		                deptCode: l.apprDeptCode, dept: l.apprDeptName,
		                gradeCode: l.apprGradeCode, grade: l.apprGradeName
		            }));
		        }

		        // 참조자 복원
		        if (doc.refs && doc.refs.length > 0) {
		            this.references = doc.refs.map(r => ({
		                empId: r.refEmpId, name: r.refEmpName,
		                deptCode: r.refDeptCode, dept: r.refDeptName,
		                gradeCode: r.refGradeCode, grade: r.refGradeName
		            }));
		        }
		    } catch (e) {
		        console.error('임시저장 문서 로딩 실패:', e);
		        alert('문서를 불러오지 못했습니다.');
		    }
		},

		selectDocType(id, name) {
		    this.selectedDocTypeId = id;
		    this.selectedDocTypeName = name;
		    const doc = this.docTypeList.find(d => d.docTypeId === id);
		    this.selectedFormCode = doc ? doc.formCode : '';
		    this.selectedNotice = doc ? doc.notice : '';
		    this.formVisible = true;
		},

        // ── 결재자 ──
        addApprover(emp) {
            if (!this.approvers.some(p => p.empId === emp.empId)) {
                this.approvers.push({ ...emp });
            }
        },

        removeApprover(idx) {
            this.approvers.splice(idx, 1);
        },

        reorderApprover(fromIdx, toIdx) {
            if (fromIdx === toIdx) return;
            const [moved] = this.approvers.splice(fromIdx, 1);
            this.approvers.splice(toIdx, 0, moved);
        },

        // ── 참조자 ──
        addReference(emp) {
            if (!this.references.some(p => p.empId === emp.empId)) {
                this.references.push({ ...emp });
            }
        },

        removeReference(idx) {
            this.references.splice(idx, 1);
        },

		// ── 첨부파일 ──
		addFiles(fileList) {
		    Array.from(fileList).forEach(file => {
		        if (this.attachedFiles.length >= 10) {
		            alert('첨부파일은 최대 10개까지 가능합니다.');
		            return;
		        }
		        if (file.size > 50 * 1024 * 1024) {
		            alert(file.name + ': 파일 크기가 50MB를 초과합니다.');
		            return;
		        }
		        if (this.attachedFiles.some(f => f.name === file.name && f.size === file.size)) {
		            return;
		        }
		        this.attachedFiles.push(file);
		    });
		},
				
		removeFile(idx) {
		    this.attachedFiles.splice(idx, 1);
		},

		formatFileSize(bytes) {
		    if (bytes < 1024) return bytes + 'B';
		    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + 'KB';
		    return (bytes / (1024 * 1024)).toFixed(2) + 'MB';
		},	
			
		addExpenseRow() {
		    this.expenseRows.push({ date: '', content: '', vendor: '', amount: 0, remark: '' });
		},
		
		removeExpenseRow() {
		    if (this.expenseRows.length > 1) this.expenseRows.pop();
		},
						
		async saveTemplate(tempName) {
		    if (this.approvers.length === 0) {
		        alert('결재자를 먼저 추가해 주세요.');
		        return false;
		    }

		    try {
		        const data = {
		            tempName: tempName,
		            lines: this.approvers.map(p => ({
		                apprEmpId: p.empId,
		                apprEmpName: p.name,
		                apprDeptCode: p.deptCode || '',
		                apprDeptName: p.dept || '',
		                apprGradeCode: p.gradeCode || '',
		                apprGradeName: p.grade || ''
		            }))
		        };

		        await http.post('/approval/template', data);
		        alert('템플릿이 저장되었습니다.');
		        return true;
		    } catch (e) {
		        console.error('템플릿 저장 실패:', e);
		        alert('템플릿 저장 중 오류가 발생했습니다.');
		        return false;
		    }
		},
		
		// ── 템플릿 목록 조회 ──
		async fetchTemplates() {
		    try {
		        const res = await http.get('/approval/template');
		        return res.data.list || [];
		    } catch (e) {
		        console.error('템플릿 목록 조회 실패:', e);
		        return [];
		     }
		},

		// ── 템플릿 불러오기 (결재선에 적용) ──
		async loadTemplate(tempId) {
		    try {
		        const res = await http.get('/approval/template/' + tempId);
		        const lines = res.data.lines || [];

		        this.approvers = lines.map(l => ({
		            empId: l.apprEmpId,
		            name: l.apprEmpName,
		            deptCode: l.apprDeptCode,
		            dept: l.apprDeptName,
		            gradeCode: l.apprGradeCode,
		            grade: l.apprGradeName
		        }));

		        return true;
		    } catch (e) {
		        console.error('템플릿 불러오기 실패:', e);
		        alert('템플릿 불러오기 중 오류가 발생했습니다.');
		        return false;
		    }
		},

		// ── 템플릿 삭제 ──
		async deleteTemplate(tempId) {
		    try {
		        await http.delete('/approval/template/' + tempId);
		        return true;
		    } catch (e) {
		        console.error('템플릿 삭제 실패:', e);
		        alert('템플릿 삭제 중 오류가 발생했습니다.');
		        return false;
		    }
		},
		
		async saveDraft() {
		    if (!this.selectedDocTypeId) {
		        alert('문서유형을 선택해 주세요.');
		        return false;
		    }
		    if (!this.title.trim()) {
		        alert('제목을 입력해 주세요.');
		        return false;
		    }

		    try {
		        // 세부양식 데이터 구성
				const detail = { formCode: this.selectedFormCode };

				if (this.selectedFormCode === 'FM001') {
				    detail.leaveType = this.detailData.leaveType;
				    detail.leaveStartDate = this.detailData.leaveStartDate;
				    detail.leaveStartDayType = this.detailData.leaveStartDayType;
				    detail.leaveEndDate = this.detailData.leaveEndDate;
				    detail.leaveEndDayType = this.detailData.leaveEndDayType;
				    detail.leaveTotalDays = this.detailData.leaveTotalDays;
				    detail.description = this.detailData.description;
				} else if (this.selectedFormCode === 'FM002') {
				    detail.biztripPurpose = this.detailData.biztripPurpose;
				    detail.biztripCompanion = this.detailData.biztripCompanion;
				    detail.biztripStartDate = this.detailData.biztripStartDate;
				    detail.biztripEndDate = this.detailData.biztripEndDate;
				    detail.description = this.detailData.description;
				} else if (this.selectedFormCode === 'FM003') {
				    detail.expensePurpose = this.detailData.expensePurpose;
				    detail.expensePayMethod = this.detailData.expensePayMethod;
				    detail.expenseDueDate = this.detailData.expenseDueDate;
				    detail.expenseRows = this.expenseRows;
				    detail.description = this.detailData.description;
				} else if (this.selectedFormCode === 'FM004') {
				    detail.claimPurpose = this.detailData.claimPurpose;
				    detail.claimAccountInfo = this.detailData.claimAccountInfo;
				    detail.expenseRows = this.expenseRows;
				    detail.description = this.detailData.description;
				} else if (this.selectedFormCode === 'FM005') {
				    detail.generalPurpose = this.detailData.generalPurpose;
				    const editorEl = document.querySelector('#general-editor .ql-editor');
				    detail.description = editorEl ? editorEl.innerHTML : '';
				}

		        const data = {
		            docTypeId: this.selectedDocTypeId,
		            title: this.title,
		            detailData: JSON.stringify(detail),
		            lines: this.approvers.map((p, idx) => ({
		                apprEmpId: p.empId,
		                apprEmpName: p.name,
		                apprDeptCode: p.deptCode || '',
		                apprDeptName: p.dept || '',
		                apprGradeCode: p.gradeCode || '',
		                apprGradeName: p.grade || ''
		            })),
					refs: this.references.map(r => ({
					    refEmpId: r.empId,
					    refEmpName: r.name,
					    refDeptCode: r.deptCode || '',
					    refDeptName: r.dept || '',
					    refGradeCode: r.gradeCode || '',
					    refGradeName: r.grade || ''
					}))
					
		        };

				if (this.editMode) data.oldDocId = this.editDocId;

				const formData = new FormData();
				formData.append('data', new Blob([JSON.stringify(data)], { type: 'application/json' }));

				this.attachedFiles.forEach(file => {
				    formData.append('files', file);
				});

				await http.post('/approval/doc', formData, {
				    headers: { 'Content-Type': 'multipart/form-data' }
				});

		        alert('임시저장되었습니다.');
				const ctx = document.querySelector('meta[name="ctx"]').content;
				location.href = ctx + '/approval/list';
				return true;
		    } catch (e) {
		        console.error('임시저장 실패:', e);
		        alert('임시저장 중 오류가 발생했습니다.');
		        return false;
		    }
		},
		async submitDoc() {
		    if (!this.selectedDocTypeId) {
		        alert('문서유형을 선택해 주세요.');
		        return false;
		    }
		    if (!this.title.trim()) {
		        alert('제목을 입력해 주세요.');
		        return false;
		    }
		    if (this.approvers.length === 0) {
		        alert('결재자를 1명 이상 추가해 주세요.');
		        return false;
		    }
		    if (!confirm('결재를 상신하시겠습니까?')) return false;

		    try {
		        const detail = { formCode: this.selectedFormCode };

		        if (this.selectedFormCode === 'FM001') {
		            detail.leaveType = this.detailData.leaveType;
		            detail.leaveStartDate = this.detailData.leaveStartDate;
		            detail.leaveStartDayType = this.detailData.leaveStartDayType;
		            detail.leaveEndDate = this.detailData.leaveEndDate;
		            detail.leaveEndDayType = this.detailData.leaveEndDayType;
		            detail.leaveTotalDays = this.detailData.leaveTotalDays;
		            detail.description = this.detailData.description;
		        } else if (this.selectedFormCode === 'FM002') {
		            detail.biztripPurpose = this.detailData.biztripPurpose;
		            detail.biztripCompanion = this.detailData.biztripCompanion;
		            detail.biztripStartDate = this.detailData.biztripStartDate;
		            detail.biztripEndDate = this.detailData.biztripEndDate;
		            detail.description = this.detailData.description;
		        } else if (this.selectedFormCode === 'FM003') {
		            detail.expensePurpose = this.detailData.expensePurpose;
		            detail.expensePayMethod = this.detailData.expensePayMethod;
		            detail.expenseDueDate = this.detailData.expenseDueDate;
		            detail.expenseRows = this.expenseRows;
		            detail.description = this.detailData.description;
		        } else if (this.selectedFormCode === 'FM004') {
		            detail.claimPurpose = this.detailData.claimPurpose;
		            detail.claimAccountInfo = this.detailData.claimAccountInfo;
		            detail.expenseRows = this.expenseRows;
		            detail.description = this.detailData.description;
		        } else if (this.selectedFormCode === 'FM005') {
		            detail.generalPurpose = this.detailData.generalPurpose;
		            const editorEl = document.querySelector('#general-editor .ql-editor');
		            detail.description = editorEl ? editorEl.innerHTML : '';
		        }

		        const data = {
		            docTypeId: this.selectedDocTypeId,
		            docStatus: 'PENDING',
		            title: this.title,
		            detailData: JSON.stringify(detail),
		            lines: this.approvers.map((p, idx) => ({
		                apprEmpId: p.empId,
		                apprEmpName: p.name,
		                apprDeptCode: p.deptCode || '',
		                apprDeptName: p.dept || '',
		                apprGradeCode: p.gradeCode || '',
		                apprGradeName: p.grade || ''
		            })),
		            refs: this.references.map(r => ({
		                refEmpId: r.empId,
		                refEmpName: r.name,
		                refDeptCode: r.deptCode || '',
		                refDeptName: r.dept || '',
		                refGradeCode: r.gradeCode || '',
		                refGradeName: r.grade || ''
		            }))
		        };

		        if (this.editMode) {
		            data.oldDocId = this.editDocId;
		            if (this.editDocStatus === 'REJECTED') {
		                data.versionIncrement = 1;
		            }
		        }

		        const formData = new FormData();
		        formData.append('data', new Blob([JSON.stringify(data)], { type: 'application/json' }));
		        this.attachedFiles.forEach(file => {
		            formData.append('files', file);
		        });

		        await http.post('/approval/doc', formData, {
		            headers: { 'Content-Type': 'multipart/form-data' }
		        });

		        alert('결재가 상신되었습니다.');
		        const ctx = document.querySelector('meta[name="ctx"]').content;
		        location.href = ctx + '/approval/list';
		        return true;
		    } catch (e) {
		        console.error('상신 실패:', e);
		        alert('상신 중 오류가 발생했습니다.');
		        return false;
		    }
		}		
    }
});
