import { defineStore } from 'pinia';
import http            from 'http';

/**
 * chatStore.js
 * 위치: /dist/js/store/chatStore.js
 * 역할: 채팅 전역 상태 관리 (Pinia) - API/WebSocket 연동 완성본
 */
export const useChatStore = defineStore('chat', {

    state: () => ({
        /* ── 세션 정보 (chatMain.jsp에서 JSP EL로 주입) ── */
        sessionEmpId:  '',
        sessionName:   '',
        sessionAvatar: '',

        /* ── 직원 목록 ── */
        allUsers:      [],
        filteredUsers: [],
        userLoading:   false,
        userHasMore:   true,
        userOffset:    0,
        userPageSize:  20,

        /* ── 프로젝트 필터 ── */
        projects:        [],
        selectedProject: '',

        /* ── 검색 키워드 ── */
        searchKeyword:  '',
        searchTimer:    null,   // debounce용

        /* ── 현재 열린 채팅 상대 ── */
        activeEmpId:  null,
        activeUser:   null,
        activeRoomId: null,

        /* ── 메시지 ── */
        messages:      [],
        messageGroups: [],
        unreadCount:   0,
        msgOffset:     0,
        msgPageSize:   20,
        msgHasMore:    true,
        msgLoading:    false,

        /* ── 입력창 ── */
        inputText:    '',
        inputFocused: false,

        /* ── 로딩 ── */
        loading: false,

        /* ── WebSocket (STOMP) ── */
        stompClient:      null,
        subscription:     null,     // 현재 채팅방 구독 객체
        wsConnected:      false,
    }),

    actions: {

        /* ──────────────────────────────────────────────────
         * 프로젝트 목록 로드
         * ────────────────────────────────────────────────── */
        async loadProjects() {
            try {
                const res = await http.get('/chat/projects');
                this.projects = res.data || [];
            } catch (e) {
                console.error('프로젝트 목록 조회 실패', e);
            }
        },

        /* ──────────────────────────────────────────────────
         * 직원 목록 로드 (초기 또는 필터 변경 시)
         * ────────────────────────────────────────────────── */
        async loadUserList(reset = true) {
            if (this.userLoading) return;

            if (reset) {
                this.userOffset    = 0;
                this.userHasMore   = true;
                this.allUsers      = [];
                this.filteredUsers = [];
            }

            if (!this.userHasMore) return;

            this.userLoading = true;
            try {
                const res = await http.get('/chat/users', {
                    params: {
                        projectId: this.selectedProject || '',
                        keyword:   this.searchKeyword   || '',
                        offset:    this.userOffset,
                        size:      this.userPageSize,
                    }
                });

                const list    = res.data.list    || [];
                const hasMore = res.data.hasMore ?? false;

                this.allUsers      = [...this.allUsers, ...list];
                this.filteredUsers = [...this.allUsers];
                this.userOffset   += list.length;
                this.userHasMore   = hasMore;

            } catch (e) {
                console.error('직원 목록 조회 실패', e);
            } finally {
                this.userLoading = false;
            }
        },

        /* ── 프로젝트 필터 변경 → 진행 중 채팅방 종료 후 목록 갱신 ── */
        async filterByProject() {
            this._closeCurrentRoom();
            await this.loadUserList(true);
        },

        /* ── 이름/사원번호 검색 (debounce 300ms) ── */
        filterUsers() {
            clearTimeout(this.searchTimer);
            this.searchTimer = setTimeout(async () => {
                this._closeCurrentRoom();
                await this.loadUserList(true);
            }, 300);
        },

        /* ── 무한스크롤: 다음 페이지 로드 ── */
        async loadMoreUsers() {
            if (!this.userHasMore || this.userLoading) return;
            await this.loadUserList(false);
        },

        /* ──────────────────────────────────────────────────
         * 채팅방 열기
         * ────────────────────────────────────────────────── */
        async openChat(user) {
            // 7: 진행 중 채팅방 종료 후 새 채팅방 입장
            this._closeCurrentRoom();

            this.activeEmpId = user.empId;
            this.activeUser  = user;
            this.messages    = [];
            this.msgOffset   = 0;
            this.msgHasMore  = true;

            try {
                // 채팅방 조회 또는 생성
                const res = await http.post('/chat/rooms', {
                    targetEmpId: user.empId
                });
                this.activeRoomId = res.data.roomId;

                // 최초 메시지 20건 조회
                await this.loadMessages(false);

                // 미읽음 배지 초기화
                const target = this.allUsers.find(u => u.empId === user.empId);
                if (target) target.unreadCount = 0;

                // WebSocket 채팅방 구독
                this._subscribeRoom(this.activeRoomId);

                // 입장 알림 전송
                this._sendWsFrame('/app/chat/enter', { roomId: this.activeRoomId });

                // 읽음 처리
                this._sendWsFrame('/app/chat/read', { roomId: this.activeRoomId });

            } catch (e) {
                console.error('채팅방 열기 실패', e);
                alert('채팅방을 열 수 없습니다.');
                this.activeEmpId  = null;
                this.activeUser   = null;
                this.activeRoomId = null;
            }
        },

        /* ──────────────────────────────────────────────────
         * 메시지 로드 (무한스크롤)
         * ────────────────────────────────────────────────── */
        async loadMessages(prepend = true) {
            if (!this.activeRoomId || this.msgLoading || !this.msgHasMore) return;

            this.msgLoading = true;
            try {
                const res = await http.get(
                    `/chat/rooms/${this.activeRoomId}/messages`,
                    { params: { offset: this.msgOffset, size: this.msgPageSize } }
                );

                const list    = res.data.list    || [];
                const hasMore = res.data.hasMore ?? false;

                if (prepend) {
                    // 상단 스크롤 시 과거 메시지 앞에 추가
                    this.messages  = [...list, ...this.messages];
                } else {
                    this.messages  = list;
                }

                this.msgOffset  += list.length;
                this.msgHasMore  = hasMore;
                this._buildMessageGroups();

            } catch (e) {
                console.error('메시지 조회 실패', e);
            } finally {
                this.msgLoading = false;
            }
        },

        /* ──────────────────────────────────────────────────
         * 텍스트 메시지 전송 (STOMP)
         * ────────────────────────────────────────────────── */
        sendMessage() {
            const text = this.inputText.trim();

            // 12: 빈 메시지 차단
            if (!text) return;
            // 13: 200자 길이 제한
            if (text.length > 200) {
                alert('메시지는 200자를 초과할 수 없습니다.');
                return;
            }
            if (!this.activeRoomId || !this.wsConnected) {
                alert('전송 실패: 연결이 끊어졌습니다.');
                return;
            }

            this._sendWsFrame('/app/chat/message', {
                roomId:  this.activeRoomId,
                content: text,
                msgType: 'TEXT',
            });

            this.inputText = '';
        },

        /* ──────────────────────────────────────────────────
         * 파일 업로드 전송 (REST API)
         * ────────────────────────────────────────────────── */
        triggerFileInput() {
            document.getElementById('chatFileInput')?.click();
        },

        async handleFileSelect(event) {
            const files = Array.from(event.target.files);
            if (!files.length || !this.activeRoomId) return;

            for (const file of files) {
                const form = new FormData();
                form.append('file', file);

                try {
                    const res = await http.post(
                        `/chat/rooms/${this.activeRoomId}/files`,
                        form
                    );
                    const saved = res.data;

                    // 21: 파일 업로드 성공 시 WebSocket으로 상대방에게 브로드캐스트
                    this._sendWsFrame('/app/chat/message', {
                        roomId:      this.activeRoomId,
                        msgType:     'FILE',
                        content:     saved.originalName,
                        messageId:   saved.messageId,
                        fileId:      saved.fileId,
                        originalName: saved.originalName,
                        fileSize:    saved.fileSize,
                        fileExt:     saved.fileExt,
                    });

                } catch (e) {
                    console.error('파일 업로드 실패', e);
                    alert('파일 오류: 업로드에 실패했습니다.');
                }
            }
            event.target.value = '';
        },

        /* ──────────────────────────────────────────────────
         * 파일 다운로드
         * ────────────────────────────────────────────────── */
        async downloadFile(fileId, fileName) {
            try {
                const res = await http.get(
                    `/chat/files/${fileId}/download`,
                    { responseType: 'blob' }
                );
                const url  = URL.createObjectURL(new Blob([res.data]));
                const link = document.createElement('a');
                link.href     = url;
                link.download = fileName;
                link.click();
                URL.revokeObjectURL(url);
            } catch (e) {
                console.error('파일 다운로드 실패', e);
                alert('파일 오류: 다운로드에 실패했습니다.');
            }
        },

        /* ──────────────────────────────────────────────────
         * WebSocket (STOMP) 연결
         * ────────────────────────────────────────────────── */
        connectWebSocket() {
            if (this.stompClient && this.wsConnected) return;

            // @stomp/stompjs 6.x : StompJs.Client 사용
            this.stompClient = new StompJs.Client({
                // SockJS를 transport로 사용
                webSocketFactory: () => new SockJS('/ws/chat'),

                // 재연결 간격 (ms)
                reconnectDelay: 5000,

                // 콘솔 디버그 출력 비활성화
                debug: () => {},

                onConnect: () => {
                    this.wsConnected = true;
                    console.log('[Chat] WebSocket 연결됨');
                },

                onDisconnect: () => {
                    this.wsConnected = false;
                    console.log('[Chat] WebSocket 연결 해제');
                },

                onStompError: (frame) => {
                    this.wsConnected = false;
                    console.error('[Chat] STOMP 오류:', frame);
                },
            });

            this.stompClient.activate();
        },

        /* ── 채팅방 구독 ── */
        _subscribeRoom(roomId) {
            if (!this.stompClient || !this.wsConnected) return;

            // 기존 구독 해제
            if (this.subscription) {
                this.subscription.unsubscribe();
                this.subscription = null;
            }

            // 9: 채팅방 재진입 시 새 구독(세션) 생성
            this.subscription = this.stompClient.subscribe(
                `/topic/chat/${roomId}`,
                (frame) => {
                    const msg = JSON.parse(frame.body);
                    this._handleWsMessage(msg);
                }
            );
        },

        /* ── WebSocket 수신 메시지 처리 ── */
        _handleWsMessage(msg) {
            switch (msg.type) {

                case 'CHAT':
                    // 11: 서버 timestamp 기준 순서 보장 (서버 sentAt 사용)
                    this.messages.push(msg);
                    this._buildMessageGroups();

                    // 14: 상대방이 채팅방에 있으면 즉시 읽음 처리
                    if (msg.senderId !== this.sessionEmpId) {
                        this._sendWsFrame('/app/chat/read', { roomId: this.activeRoomId });
                    }

                    // 직원 목록 마지막 메시지 갱신
                    this._updateUserLastMsg(msg);
                    break;

                case 'READ':
                    // 내가 보낸 메시지 읽음 상태 갱신
                    this.messages.forEach(m => {
                        if (m.senderId === this.sessionEmpId) m.isRead = 'Y';
                    });
                    this._buildMessageGroups();
                    break;

                case 'ENTER':
                    // 상대방 온라인 상태 갱신
                    if (msg.senderId !== this.sessionEmpId && this.activeUser) {
                        this.activeUser.onlineStatus = 'online';
                    }
                    break;

                case 'LEAVE':
                    if (msg.senderId !== this.sessionEmpId && this.activeUser) {
                        this.activeUser.onlineStatus = 'offline';
                    }
                    break;

                case 'ERROR':
                    alert('전송 실패: ' + (msg.content || '오류가 발생했습니다.'));
                    break;
            }
        },

        /* ── STOMP 프레임 전송 헬퍼 ── */
        _sendWsFrame(destination, body) {
            if (!this.stompClient || !this.wsConnected) return;
            this.stompClient.publish({
                destination,
                body: JSON.stringify(body),
            });
        },

        /* ── 채팅방 종료 (구독 해제 + 퇴장 알림) ── */
        _closeCurrentRoom() {
            if (this.activeRoomId) {
                this._sendWsFrame('/app/chat/leave', { roomId: this.activeRoomId });
            }
            if (this.subscription) {
                this.subscription.unsubscribe();
                this.subscription = null;
            }
            this.activeEmpId  = null;
            this.activeUser   = null;
            this.activeRoomId = null;
            this.messages     = [];
            this.messageGroups= [];
            this.msgOffset    = 0;
            this.msgHasMore   = true;
        },

        /* ── 직원 목록의 마지막 메시지 갱신 ── */
        _updateUserLastMsg(msg) {
            const targetId = msg.senderId === this.sessionEmpId
                ? this.activeEmpId
                : msg.senderId;

            const user = this.allUsers.find(u => u.empId === targetId);
            if (user) {
                user.lastMessage    = msg.msgType === 'FILE' ? msg.originalName : msg.content;
                user.lastMessageAt  = msg.sentAt;
                user.lastMessageType= msg.msgType;

                // 14: 내가 채팅방 밖에 있고 상대가 보낸 메시지면 미읽음 +1
                if (msg.senderId !== this.sessionEmpId &&
                    msg.senderId !== this.activeEmpId) {
                    user.unreadCount = (user.unreadCount || 0) + 1;
                }
            }
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
         * 메시지 그룹 빌드 (날짜 구분선 · 미읽음 구분선)
         * ────────────────────────────────────────────────── */
        _buildMessageGroups() {
            const result = [];
            let lastDate       = null;
            let insertedUnread = false;
            let unreadStart    = -1;
            this.unreadCount   = 0;

            // 미읽음 첫 번째 위치 탐색 (상대방이 보낸 것 중 isRead = 'N')
            for (let i = 0; i < this.messages.length; i++) {
                const msg = this.messages[i];
                if (msg.senderId !== this.sessionEmpId && msg.isRead === 'N') {
                    unreadStart = i;
                    break;
                }
            }

            if (unreadStart !== -1) {
                this.unreadCount = this.messages.slice(unreadStart)
                    .filter(m => m.senderId !== this.sessionEmpId && m.isRead === 'N').length;
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

                const prevMsg      = this.messages[idx - 1];
                const isMine       = msg.senderId === this.sessionEmpId;
                const hiddenAvatar = prevMsg
                    && prevMsg.senderId === msg.senderId
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
            const diffMs     = now - date;
            const diffDays   = diffMs / (1000 * 60 * 60 * 24);

            // 4-2: 날짜 포맷 규칙
            if (isToday) {
                return date.getHours().toString().padStart(2,'0') + ':' +
                       date.getMinutes().toString().padStart(2,'0');
            }
            if (diffDays < 365) {
                return (date.getMonth() + 1) + '/' + date.getDate();
            }
            return '1년 이상';
        },

        formatMsgTime(isoStr) {
            if (!isoStr) return '';
            const date = new Date(isoStr);
            return date.getHours().toString().padStart(2,'0') + ':' +
                   date.getMinutes().toString().padStart(2,'0');
        },

        _formatDateLabel(dateStr) {
            const date = new Date(dateStr);
            const now  = new Date();
            if (date.toDateString() === now.toDateString()) return '오늘';
            const days = ['일','월','화','수','목','금','토'];
            return date.getFullYear() + '년 ' + (date.getMonth()+1) + '월 ' +
                   date.getDate() + '일 ' + days[date.getDay()] + '요일';
        },

        // XSS 방지 처리
        formatMsgText(text) {
            if (!text) return '';
            return text
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#x27;')
                .replace(/\n/g, '<br>');
        },

        getFileIcon(ext) {
            const map = {
                pdf:  'bi bi-file-earmark-pdf',
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
                pdf:  'color:#e53e3e',
                xlsx: 'color:#1d6f42', xls: 'color:#1d6f42',
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