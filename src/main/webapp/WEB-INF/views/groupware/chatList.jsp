<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<%--
    chatList.jsp
    위치: /WEB-INF/views/groupware/chatList.jsp
    역할: 채팅 전체 UI (직원 목록 패널 + 채팅방 영역)
    Vue 템플릿으로 동작 — chatStore.js(Pinia)와 연동
--%>

<div class="chat-layout">

    <!-- ============================================================
         왼쪽: 직원 목록 패널
         ============================================================ -->
    <div class="chat-user-panel">

        <!-- 참여 프로젝트 필터 -->
        <div class="chat-filter-area">
            <div class="chat-filter-title">참여 프로젝트</div>
            <select class="chat-project-select"
                    v-model="store.selectedProject"
                    @change="store.filterByProject()">
                <option value="">전체 직원</option>
                <option v-for="proj in store.projects"
                        :key="proj.projectId"
                        :value="proj.projectId">
                    {{ proj.projectName }}
                </option>
            </select>
        </div>

        <!-- 이름/사원번호 검색 -->
        <div class="chat-search-wrap">
            <div class="chat-search-inner">
                <i class="bi bi-search"></i>
                <input type="text"
                       class="chat-search-input"
                       placeholder="이름 또는 사원번호 검색"
                       v-model="store.searchKeyword"
                       @input="store.filterUsers()">
            </div>
        </div>

        <!-- 직원 목록 -->
        <div class="chat-user-list">

            <!-- 로딩 -->
            <div v-if="store.loading" class="chat-list-loading">
                <i class="bi bi-arrow-repeat chat-spin"></i> 불러오는 중...
            </div>

            <!-- 목록 없음 -->
            <div v-else-if="store.filteredUsers.length === 0" class="chat-list-empty">
                <i class="bi bi-person-x"></i>
                <span>검색 결과가 없습니다.</span>
            </div>

            <!-- 직원 항목 -->
            <div v-else
                 v-for="user in store.filteredUsers"
                 :key="user.empId"
                 class="chat-user-item"
                 :class="{ active: store.activeEmpId === user.empId }"
                 @click="store.openChat(user)">

                <!-- 아바타 + 온라인 상태 -->
                <div class="chat-avatar">
                    <div class="chat-avatar-img"
                         :class="store.getAvatarColor(user.empId)">
                        {{ user.name.charAt(0) }}
                    </div>
                    <span class="status-dot"
                          :class="store.getStatusDotClass(user.onlineStatus)"></span>
                </div>

                <!-- 직원 정보 -->
                <div class="chat-user-info">
                    <div class="chat-user-name">{{ user.name }}</div>
                    <div class="chat-user-meta">
                        <span class="chat-user-empid">{{ user.empId }}</span>
                        <span class="meta-dot"></span>
                        <span class="chat-user-dept">{{ user.deptName }}</span>
                        <span class="meta-dot"></span>
                        <span class="chat-user-rank">{{ user.gradeName }}</span>
                    </div>
                    <div class="chat-user-preview">
                        <span class="chat-user-last-msg">{{ user.lastMessage || '대화를 시작해보세요.' }}</span>
                    </div>
                </div>

                <!-- 시간 + 미읽음 배지 + 재직상태 -->
                <div class="chat-user-right">
                    <span class="chat-user-time">{{ store.formatListTime(user.lastMessageTime) }}</span>
                    <span v-if="user.unreadCount > 0" class="chat-unread-badge">
                        {{ user.unreadCount > 99 ? '99+' : user.unreadCount }}
                    </span>
                    <span class="emp-status-badge"
                          :class="store.getEmpStatusClass(user.empStatusCode)">
                        {{ user.empStatusName }}
                    </span>
                </div>

            </div>
        </div><!-- /chat-user-list -->

    </div><!-- /chat-user-panel -->


    <!-- ============================================================
         오른쪽: 채팅방 영역
         ============================================================ -->
    <div class="chat-room-area">

        <!-- 채팅방 미선택 상태 -->
        <div v-if="!store.activeEmpId" class="chat-no-room">
            <div class="no-room-icon"><i class="bi bi-chat-dots"></i></div>
            <div class="no-room-title">대화할 직원을 선택하세요</div>
            <div class="no-room-desc">왼쪽 목록에서 직원을 클릭하면<br>채팅방이 열립니다.</div>
        </div>

        <!-- 채팅방 활성화 상태 -->
        <template v-else>

            <!-- 채팅방 헤더 -->
            <div class="chat-room-header">
                <div class="chat-avatar">
                    <div class="chat-avatar-img"
                         :class="store.getAvatarColor(store.activeUser.empId)"
                         style="width:38px; height:38px; font-size:0.85rem;">
                        {{ store.activeUser.name.charAt(0) }}
                    </div>
                    <span class="status-dot"
                          :class="store.getStatusDotClass(store.activeUser.onlineStatus)"></span>
                </div>
                <div class="chat-room-user-info">
                    <div class="chat-room-name">{{ store.activeUser.name }}</div>
                    <div class="chat-room-status-text">
                        <span class="status-dot-sm"
                              :class="store.getStatusDotClass(store.activeUser.onlineStatus)"></span>
                        <span>{{ store.getStatusLabel(store.activeUser.onlineStatus) }}</span>
                        <span class="chat-room-divider">·</span>
                        <span>{{ store.activeUser.deptName }} · {{ store.activeUser.gradeName }}</span>
                    </div>
                </div>
                <div class="chat-room-actions">
                    <button class="chat-room-btn" title="메시지 검색">
                        <i class="bi bi-search"></i>
                    </button>
                    <button class="chat-room-btn" title="더보기">
                        <i class="bi bi-three-dots-vertical"></i>
                    </button>
                </div>
            </div>

            <!-- 메시지 목록 -->
            <div class="chat-messages" ref="chatMessagesRef">

                <template v-for="(item, idx) in store.messageGroups" :key="idx">

                    <!-- 날짜 구분선 -->
                    <div v-if="item.type === 'date'" class="chat-date-divider">
                        <span>{{ item.label }}</span>
                    </div>

                    <!-- 미읽음 구분선 -->
                    <div v-else-if="item.type === 'unread'" class="unread-divider">
                        <span>읽지 않은 메시지 {{ store.unreadCount }}개</span>
                    </div>

                    <!-- 일반 메시지 -->
                    <div v-else-if="item.type === 'message'"
                         class="msg-row"
                         :class="{ mine: item.isMine }">

                        <!-- 아바타: 상대방만, 연속 메시지는 숨김 -->
                        <div class="msg-avatar"
                             :class="[
                                 item.isMine ? '' : store.getAvatarColor(item.empId),
                                 { hidden: item.isMine || item.hiddenAvatar }
                             ]">
                            <template v-if="!item.isMine && !item.hiddenAvatar">
                                {{ item.senderName.charAt(0) }}
                            </template>
                        </div>

                        <div class="msg-content-wrap">

                            <!-- 발신자 이름: 상대방 + 첫 메시지만 -->
                            <div v-if="!item.isMine && !item.hiddenAvatar"
                                 class="msg-sender-name">
                                {{ item.senderName }}
                            </div>

                            <!-- 파일 메시지 -->
                            <div v-if="item.msgType === 'FILE'" class="msg-file">
                                <i :class="store.getFileIcon(item.fileExt) + ' msg-file-icon'"
                                   :style="store.getFileIconColor(item.fileExt, item.isMine)"></i>
                                <div class="msg-file-info">
                                    <div class="msg-file-name">{{ item.fileName }}</div>
                                    <div class="msg-file-size"
                                         :style="item.isMine ? 'color:rgba(255,255,255,0.75)' : ''">
                                        {{ store.formatFileSize(item.fileSize) }} · {{ item.fileExt.toUpperCase() }}
                                    </div>
                                </div>
                                <i class="bi bi-download"
                                   :style="item.isMine ? 'color:rgba(255,255,255,0.75)' : 'color:#94a3b8'"
                                   style="font-size:0.9rem;"></i>
                            </div>

                            <!-- 텍스트 메시지 -->
                            <div v-else class="msg-bubble" v-html="store.formatMsgText(item.content)"></div>

                            <!-- 메타: 읽음 + 시간 -->
                            <div class="msg-meta">
                                <span v-if="item.isMine"
                                      class="read-status"
                                      :class="item.isRead ? 'read' : 'unread'"
                                      :title="item.isRead ? '읽음' : '미읽음'">
                                    <i :class="item.isRead ? 'bi bi-check2-all' : 'bi bi-check2'"></i>
                                </span>
                                <span class="msg-time">{{ store.formatMsgTime(item.sentAt) }}</span>
                            </div>

                        </div>
                    </div>

                </template>

            </div><!-- /chat-messages -->

            <!-- 입력 영역 -->
            <div class="chat-input-area">
                <div class="chat-input-inner"
                     :class="{ focused: store.inputFocused }">
                    <textarea
                        class="chat-textarea"
                        ref="chatInputRef"
                        v-model="store.inputText"
                        placeholder="메시지를 입력하세요... (Shift+Enter: 줄바꿈)"
                        rows="1"
                        @keydown="store.handleKeydown($event)"
                        @input="store.autoResize($event.target)"
                        @focus="store.inputFocused = true"
                        @blur="store.inputFocused = false"
                    ></textarea>
                    <div class="chat-input-btns">
                        <button class="chat-file-btn"
                                title="파일 전송"
                                @click="store.triggerFileInput()">
                            <i class="bi bi-paperclip"></i>
                        </button>
                        <button class="chat-send-btn"
                                title="전송 (Enter)"
                                :disabled="!store.inputText.trim()"
                                @click="store.sendMessage()">
                            <i class="bi bi-send-fill"></i>
                        </button>
                    </div>
                </div>
                <div class="chat-input-hint">
                    Enter: 전송 &nbsp;·&nbsp; Shift+Enter: 줄바꿈
                </div>
                <%-- 파일 input (숨김) --%>
                <input type="file"
                       id="chatFileInput"
                       style="display:none"
                       multiple
                       @change="store.handleFileSelect($event)">
            </div>

        </template><%-- /채팅방 활성화 --%>

    </div><%-- /chat-room-area --%>

</div><%-- /chat-layout --%>
