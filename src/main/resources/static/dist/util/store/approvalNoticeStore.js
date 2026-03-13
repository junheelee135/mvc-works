import { defineStore } from 'pinia';
import http from 'http';
import { getPagination } from '/dist/util/paginate.js';

export const useApprovalNoticeStore = defineStore('approvalNotice', {
	state: () => ({
		viewMode: 'LIST',
		list: [],
		totalCount: 0,
		keyword: '',
		pageNo: 1,
		pageSize: 10,
		loading: false,
		
		doc: null,
		
		form : {
			noticeId: null,
			title: '',
			content: ''
		},
		attachedFiles: []
	}),
	
	getters: {
		totalPages: (state) => {
			return Math.ceil(state.totalCount / state.pageSize) || 1;
		},
		pagination() {
			return getPagination(this.pageNo, this.totalPages, 10);
		}
	},
	
	actions : {
		async fetchList() {
			this.loading = true;
			
			try {
				const params = new URLSearchParams();
				if(this.keyword) params.append('keyword', this.keyword);
				params.append('pageNo', this.pageNo);
				params.append('pageSize', this.pageSize);
				
				const res = await http.get('/approval/notice?' + params.toString())
				this.list = res.data.list || [];
				this.totalCount = res.data.totalCount				
			} catch(e) {
				console.error('목록 조회 실패', e);
			} finally {
				this.loading = false
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
		
		async fetchDoc(noticeId) {
		    try {
		        const res = await http.get('/approval/notice/' + noticeId);
		        this.doc = res.data;
		        this.viewMode = 'DETAIL';
		    } catch (e) {
		        console.error('상세 조회 실패:', e);
		        alert('게시글을 불러올 수 없습니다.');
		    }
		},
		
		openWriteForm() {
		    this.form = { noticeId: null, title: '', content: '' };
		    this.attachedFiles = [];
		    this.viewMode = 'WRITE';
		},
		
		openEditForm() {
		    this.form = {
		        noticeId: this.doc.noticeId,
		        title: this.doc.title,
		        content: this.doc.content
		    };
		    this.attachedFiles = [];    // ← 추가
		    this.viewMode = 'EDIT';
		},
		
		async saveForm() {
		    if (!this.form.title.trim()) {
		        alert('제목을 입력하세요.');
		        return;
		    }

		    try {
		        const fd = new FormData();
		        fd.append('data', new Blob([JSON.stringify(this.form)], { type: 'application/json' }));
		        this.attachedFiles.forEach(f => fd.append('files', f));

		        if (this.viewMode === 'WRITE') {
					await http.post('/approval/notice', fd, {
					    headers: { 'Content-Type': undefined }
					});
		            alert('등록되었습니다.');
		        } else {
					await http.post('/approval/notice/' + this.form.noticeId, fd, {
					      headers: { 'Content-Type': undefined }
					  });
		            alert('수정되었습니다.');
		        }
		        this.attachedFiles = [];
		        this.viewMode = 'LIST';
		        this.fetchList();
		    } catch (e) {
		        console.error('저장 실패:', e);
		        alert('저장 중 오류가 발생했습니다.');
		    }
		},
		
		async deleteNotice(noticeId) {
		    if (!confirm('삭제하시겠습니까?')) return;

		    try {
		        await http.delete('/approval/notice/' + noticeId);
		        alert('삭제되었습니다.');
		        this.viewMode = 'LIST';
		        this.fetchList();
		    } catch (e) {
		        console.error('삭제 실패:', e);
		        alert('삭제 중 오류가 발생했습니다.');
		    }
		},

		addFiles(fileList) {
		    for (const f of fileList) {
		        this.attachedFiles.push(f);
		    }
		},

		removeFile(index) {
		    this.attachedFiles.splice(index, 1);
		},

		formatFileSize(bytes) {
		    if (bytes < 1024) return bytes + ' B';
		    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
		    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
		},		

		async deleteExistingFile(fileId) {
		    if (!confirm('이 파일을 삭제하시겠습니까?')) return;
		    try {
		        await http.post('/approval/notice/file/' + fileId + '/delete');
		        // doc.files에서 제거 (화면 즉시 반영)
		        this.doc.files = this.doc.files.filter(f => f.fileId !== fileId);
		    } catch (e) {
		        alert('파일 삭제 실패');
		    }
		},
						
		goList() {
		    this.viewMode = 'LIST';
		    this.fetchList();
		}
	}	
})