import { defineStore } from 'pinia';

/**
 * chatStore.js
 * 위치: /dist/js/store/chatStore.js
 * 역할: 채팅 전역 상태 관리 (Pinia)
 *
 * ※ 현재는 API 미연동 상태 — 가데이터로 UI 확인용
 *    API 연동 시 TODO 주석 부분을 교체할 것
 */
export const useChatStore = defineStore('chat', {

    state: () => ({
        /* ── 세션 정보 (chatMain.jsp에서 JSP EL로 주입) ── */
        sessionEmpId:  'admin',   // TODO: '${sessionScope.member.empId}'
        sessionName:   'admin',    // TODO: '${sessionScope.member.name}'
        sessionAvatar: '',

        /* ── 직원 목록 ── */
        allUsers:      [],
        filteredUsers: [],

        /* ── 프로젝트 필터 ── */
        projects:        [],
        selectedProject: '',

        /* ── 검색 키워드 ── */
        searchKeyword: '',

        /* ── 현재 열린 채팅 상대 ── */
        activeEmpId: null,
        activeUser:  null,

        /* ── 메시지 ── */
        messages:      [],
        messageGroups: [],
        unreadCount:   0,

        /* ── 입력창 ── */
        inputText:    '',
        inputFocused: false,

        /* ── 로딩 ── */
        loading:    false,
        msgLoading: false,
    }),

    actions: {

        /* ──────────────────────────────────────────────────
         * 프로젝트 목록 로드
         * TODO: API 연동 시 아래 가데이터 블록을 교체
         *   const res = await http.get('/chat/projects');
         *   this.projects = res.data || [];
         * ────────────────────────────────────────────────── */
        loadProjects() {
            this.projects = [
                { projectId: 'p1', projectName: 'Duralux ERP 고도화' },
                { projectId: 'p2', projectName: '인사관리 시스템 개발' },
                { projectId: 'p3', projectName: '결재 워크플로우 개선' },
                { projectId: 'p4', projectName: '모바일 앱 연동' },
            ];
        },

        /* ──────────────────────────────────────────────────
         * 직원 목록 로드
         * TODO: API 연동 시 아래 가데이터 블록을 교체
         *   const res = await http.get('/chat/users', { params: { projectId, keyword } });
         *   this.allUsers = res.data || [];
         *   this.filteredUsers = [...this.allUsers];
         * ────────────────────────────────────────────────── */
        loadUserList() {
            this.allUsers = [
                {
                    empId: 'EMP001', name: '김민준',
                    deptName: '개발팀', gradeName: '대리',
                    empStatusCode: 'ACTIVE', empStatusName: '재직',
                    onlineStatus: 'online',
                    lastMessage: '알겠습니다. 확인 후 처리하겠습니다.',
                    lastMessageTime: new Date().toISOString(),
                    unreadCount: 3,
                    projectIds: ['p1', 'p2'],
                },
                {
                    empId: 'EMP002', name: '이서연',
                    deptName: '기획팀', gradeName: '과장',
                    empStatusCode: 'ACTIVE', empStatusName: '재직',
                    onlineStatus: 'online',
                    lastMessage: '네, 내일까지 보내드릴게요!',
                    lastMessageTime: new Date(Date.now() - 86400000).toISOString(),
                    unreadCount: 0,
                    projectIds: ['p1'],
                },
                {
                    empId: 'EMP003', name: '박지훈',
                    deptName: '인사팀', gradeName: '사원',
                    empStatusCode: 'ACTIVE', empStatusName: '재직',
                    onlineStatus: 'away',
                    lastMessage: '📎 보고서_최종.xlsx',
                    lastMessageTime: new Date(Date.now() - 86400000 * 2).toISOString(),
                    unreadCount: 1,
                    projectIds: ['p2'],
                },
                {
                    empId: 'EMP004', name: '최수아',
                    deptName: '영업팀', gradeName: '차장',
                    empStatusCode: 'LEAVE', empStatusName: '휴직',
                    onlineStatus: 'offline',
                    lastMessage: '회의 일정 확인 부탁드립니다.',
                    lastMessageTime: new Date(Date.now() - 86400000 * 5).toISOString(),
                    unreadCount: 0,
                    projectIds: ['p1', 'p3'],
                },
                {
                    empId: 'EMP005', name: '정하은',
                    deptName: '개발팀', gradeName: '주임',
                    empStatusCode: 'ACTIVE', empStatusName: '재직',
                    onlineStatus: 'online',
                    lastMessage: '버그 수정 완료했습니다 🎉',
                    lastMessageTime: new Date(Date.now() - 86400000 * 4).toISOString(),
                    unreadCount: 0,
                    projectIds: ['p2', 'p4'],
                },
                {
                    empId: 'EMP006', name: '강도현',
                    deptName: '회계팀', gradeName: '부장',
                    empStatusCode: 'RESIGNED', empStatusName: '퇴직',
                    onlineStatus: 'offline',
                    lastMessage: '검토해 보겠습니다.',
                    lastMessageTime: new Date(Date.now() - 86400000 * 7).toISOString(),
                    unreadCount: 0,
                    projectIds: ['p3'],
                },
                {
                    empId: 'EMP007', name: '오유진',
                    deptName: '디자인팀', gradeName: '대리',
                    empStatusCode: 'ACTIVE', empStatusName: '재직',
                    onlineStatus: 'away',
                    lastMessage: '시안 첨부해 드렸어요.',
                    lastMessageTime: new Date(Date.now() - 86400000 * 9).toISOString(),
                    unreadCount: 0,
                    projectIds: ['p4'],
                },
            ];
            this.filteredUsers = [...this.allUsers];
        },

        /* ── 프로젝트 필터 변경 ── */
        filterByProject() {
            this._applyFilter();
        },

        /* ── 이름/사원번호 검색 ── */
        filterUsers() {
            this._applyFilter();
        },

        /* 내부: 프로젝트 + 키워드 필터 적용 */
        _applyFilter() {
            const kw   = this.searchKeyword.trim().toLowerCase();
            const proj = this.selectedProject;

            this.filteredUsers = this.allUsers.filter(user => {
                const matchProj = !proj || (user.projectIds || []).includes(proj);
                const matchKw   = !kw
                    || user.name.toLowerCase().includes(kw)
                    || user.empId.toLowerCase().includes(kw);
                return matchProj && matchKw;
            });
        },

        /* ──────────────────────────────────────────────────
         * 채팅방 열기
         * ────────────────────────────────────────────────── */
        openChat(user) {
            this.activeEmpId = user.empId;
            this.activeUser  = user;

            // 미읽음 배지 초기화
            const target = this.allUsers.find(u => u.empId === user.empId);
            if (target) target.unreadCount = 0;
            this._applyFilter();

            // 메시지 로드 (가데이터)
            this.loadMessages(user.empId);
        },

        /* ──────────────────────────────────────────────────
         * 메시지 로드
         * TODO: API 연동 시 아래 가데이터 블록을 교체
         *   const res = await http.get('/chat/messages', { params: { targetEmpId } });
         *   this.messages = res.data || [];
         *   this._buildMessageGroups();
         * ────────────────────────────────────────────────── */
        loadMessages(targetEmpId) {
            const yesterday = new Date(Date.now() - 86400000).toISOString().substring(0, 10);
            const today     = new Date().toISOString().substring(0, 10);

            // 가데이터: 어제 메시지
            const baseMessages = [
                {
                    msgId: 1, empId: targetEmpId, senderName: this.activeUser?.name || '상대방',
                    msgType: 'TEXT', content: '안녕하세요! 오늘 오후에 시간 되시나요?',
                    sentAt: yesterday + 'T09:14:00', isRead: true,
                },
                {
                    msgId: 2, empId: this.sessionEmpId, senderName: this.sessionName,
                    msgType: 'TEXT', content: '네, 오후 2시 이후에 괜찮습니다!',
                    sentAt: yesterday + 'T09:16:00', isRead: true,
                },
                {
                    msgId: 3, empId: targetEmpId, senderName: this.activeUser?.name || '상대방',
                    msgType: 'TEXT', content: '좋아요! 그럼 2시 30분에 회의실 예약해 두겠습니다.',
                    sentAt: yesterday + 'T09:17:00', isRead: true,
                },
                // 오늘 메시지
                {
                    msgId: 4, empId: targetEmpId, senderName: this.activeUser?.name || '상대방',
                    msgType: 'FILE', content: '',
                    fileName: '2025_Q1_업무보고.xlsx', fileSize: 250880, fileExt: 'xlsx', fileUrl: '',
                    sentAt: today + 'T13:42:00', isRead: true,
                },
                {
                    msgId: 5, empId: this.sessionEmpId, senderName: this.sessionName,
                    msgType: 'TEXT', content: '파일 잘 받았습니다. 검토 후 피드백 드릴게요!',
                    sentAt: today + 'T13:45:00', isRead: true,
                },
                // 미읽음 메시지 (상대방이 보낸 것, isRead: false)
                {
                    msgId: 6, empId: targetEmpId, senderName: this.activeUser?.name || '상대방',
                    msgType: 'TEXT', content: '그리고 말씀드린 기능 구현 쪽은 이번 주 내로 마무리할 수 있을 것 같습니다.',
                    sentAt: today + 'T14:01:00', isRead: false,
                },
                {
                    msgId: 7, empId: targetEmpId, senderName: this.activeUser?.name || '상대방',
                    msgType: 'TEXT', content: '혹시 추가 요구사항 있으시면 말씀해 주세요!',
                    sentAt: today + 'T14:02:00', isRead: false,
                },
                {
                    msgId: 8, empId: targetEmpId, senderName: this.activeUser?.name || '상대방',
                    msgType: 'TEXT', content: '알겠습니다. 확인 후 처리하겠습니다.',
                    sentAt: today + 'T14:23:00', isRead: false,
                },
                // 내가 보낸 파일 (미읽음)
                {
                    msgId: 9, empId: this.sessionEmpId, senderName: this.sessionName,
                    msgType: 'FILE', content: '',
                    fileName: '요구사항_명세서_v2.pdf', fileSize: 1258291, fileExt: 'pdf', fileUrl: '',
                    sentAt: today + 'T14:25:00', isRead: false,
                },
            ];

            this.messages = baseMessages;
            this._buildMessageGroups();
        },

        /* ──────────────────────────────────────────────────
         * 메시지 전송 (텍스트) — 가데이터 모드: 로컬에만 추가
         * TODO: API 연동 시 http.post('/chat/messages', ...) 로 교체
         * ────────────────────────────────────────────────── */
        sendMessage() {
            const text = this.inputText.trim();
            if (!text || !this.activeEmpId) return;

            this.messages.push({
                msgId:      Date.now(),
                empId:      this.sessionEmpId,
                senderName: this.sessionName,
                msgType:    'TEXT',
                content:    text,
                sentAt:     new Date().toISOString(),
                isRead:     false,
            });

            this._buildMessageGroups();
            this.inputText = '';
        },

        /* ──────────────────────────────────────────────────
         * 파일 전송 — 가데이터 모드: 로컬에만 추가
         * TODO: API 연동 시 http.post('/chat/messages/file', form) 로 교체
         * ────────────────────────────────────────────────── */
        triggerFileInput() {
            document.getElementById('chatFileInput')?.click();
        },

        handleFileSelect(event) {
            const files = Array.from(event.target.files);
            if (!files.length || !this.activeEmpId) return;

            files.forEach(file => {
                const ext = file.name.split('.').pop().toLowerCase();
                this.messages.push({
                    msgId:      Date.now() + Math.random(),
                    empId:      this.sessionEmpId,
                    senderName: this.sessionName,
                    msgType:    'FILE',
                    content:    '',
                    fileName:   file.name,
                    fileSize:   file.size,
                    fileExt:    ext,
                    fileUrl:    '',
                    sentAt:     new Date().toISOString(),
                    isRead:     false,
                });
            });

            this._buildMessageGroups();
            event.target.value = '';
        },

        /* ──────────────────────────────────────────────────
         * 입력창 동작
         * ────────────────────────────────────────────────── */
        handleKeydown(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                this.sendMessage();
            }
        },

        autoResize(el) {
            el.style.height = 'auto';
            el.style.height = Math.min(el.scrollHeight, 120) + 'px';
        },

        /* ──────────────────────────────────────────────────
         * 메시지 그룹 빌드 (날짜구분선·시스템·미읽음구분선 삽입)
         * ────────────────────────────────────────────────── */
        _buildMessageGroups() {
            const result = [];
            let lastDate       = null;
            let insertedUnread = false;
            let unreadStart    = -1;
            this.unreadCount   = 0;

            // 미읽음 첫 번째 위치 탐색 (상대방이 보낸 것 중 isRead === false)
            for (let i = 0; i < this.messages.length; i++) {
                const msg = this.messages[i];
                if (msg.empId !== this.sessionEmpId && !msg.isRead) {
                    unreadStart = i;
                    break;
                }
            }

            // 미읽음 개수
            if (unreadStart !== -1) {
                this.unreadCount = this.messages.slice(unreadStart)
                    .filter(m => m.empId !== this.sessionEmpId && !m.isRead).length;
            }

            this.messages.forEach((msg, idx) => {
                const dateStr = msg.sentAt ? msg.sentAt.substring(0, 10) : '';

                // 날짜 구분선
                if (dateStr && dateStr !== lastDate) {
                    lastDate = dateStr;
                    result.push({ type: 'date', label: this._formatDateLabel(dateStr) });
                }

                // 미읽음 구분선
                if (!insertedUnread && idx === unreadStart) {
                    result.push({ type: 'unread' });
                    insertedUnread = true;
                }

                // 연속 메시지 여부
                const prevMsg      = this.messages[idx - 1];
                const isMine       = msg.empId === this.sessionEmpId;
                const hiddenAvatar = prevMsg
                    && prevMsg.empId === msg.empId
                    && prevMsg.sentAt?.substring(0, 10) === dateStr;

                result.push({ type: 'message', ...msg, isMine, hiddenAvatar });
            });

            this.messageGroups = result;
        },

        /* ──────────────────────────────────────────────────
         * 유틸 메서드
         * ────────────────────────────────────────────────── */

        getAvatarColor(empId) {
            const colors = [
                'avatar-color-1', 'avatar-color-2', 'avatar-color-3',
                'avatar-color-4', 'avatar-color-5', 'avatar-color-6',
                'avatar-color-7', 'avatar-color-8',
            ];
            if (!empId) return colors[0];
            const num = empId.replace(/\D/g, '') || '0';
            return colors[parseInt(num, 10) % colors.length];
        },

        getStatusDotClass(status) {
            const map = { online: 'status-online', away: 'status-away', offline: 'status-offline' };
            return map[status] || 'status-offline';
        },

        getStatusLabel(status) {
            const map = { online: '온라인', away: '자리비움', offline: '오프라인' };
            return map[status] || '오프라인';
        },

        getEmpStatusClass(code) {
            const map = { ACTIVE: 'status-active', LEAVE: 'status-leave', RESIGNED: 'status-resigned' };
            return map[code] || '';
        },

        formatListTime(isoStr) {
            if (!isoStr) return '';
            const date       = new Date(isoStr);
            const now        = new Date();
            const isToday    = date.toDateString() === now.toDateString();
            const isThisYear = date.getFullYear() === now.getFullYear();
            if (isToday)    return date.getHours().toString().padStart(2,'0') + ':' + date.getMinutes().toString().padStart(2,'0');
            if (isThisYear) return (date.getMonth() + 1) + '/' + date.getDate();
            return date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate();
        },

        formatMsgTime(isoStr) {
            if (!isoStr) return '';
            const date = new Date(isoStr);
            return date.getHours().toString().padStart(2,'0') + ':' + date.getMinutes().toString().padStart(2,'0');
        },

        _formatDateLabel(dateStr) {
            const date = new Date(dateStr);
            const now  = new Date();
            if (date.toDateString() === now.toDateString()) return '오늘';
            const days = ['일','월','화','수','목','금','토'];
            return date.getFullYear() + '년 ' + (date.getMonth()+1) + '월 ' + date.getDate() + '일 ' + days[date.getDay()] + '요일';
        },

        formatMsgText(text) {
            if (!text) return '';
            return text
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/\n/g, '<br>');
        },

        getFileIcon(ext) {
            const map = {
                pdf: 'bi bi-file-earmark-pdf',
                xlsx: 'bi bi-file-earmark-excel', xls: 'bi bi-file-earmark-excel',
                docx: 'bi bi-file-earmark-word',  doc: 'bi bi-file-earmark-word',
                pptx: 'bi bi-file-earmark-ppt',   ppt: 'bi bi-file-earmark-ppt',
                zip:  'bi bi-file-earmark-zip',
                png:  'bi bi-file-earmark-image',  jpg: 'bi bi-file-earmark-image',
                jpeg: 'bi bi-file-earmark-image',  gif: 'bi bi-file-earmark-image',
            };
            return map[ext] || 'bi bi-file-earmark';
        },

        getFileIconColor(ext, isMine) {
            if (isMine) return 'color:#ffffff';
            const map = {
                pdf: 'color:#e53e3e', xlsx: 'color:#1d6f42', xls: 'color:#1d6f42',
                docx: 'color:#2b5797', doc: 'color:#2b5797',
                pptx: 'color:#d24726', ppt: 'color:#d24726',
            };
            return map[ext] || 'color:#64748b';
        },

        formatFileSize(bytes) {
            if (!bytes) return '';
            if (bytes < 1024)        return bytes + ' B';
            if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(0) + ' KB';
            return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
        },
    },
});
