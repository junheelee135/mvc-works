<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회의실 관리</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/meetingroom.css?v=3" type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
<style>[v-cloak] { display: none; }</style>
</head>
<body>

<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>

<main id="main-content">
    <div id="vue-app" v-cloak>

        <!-- 상단 헤더 -->
        <div class="room-header">
            <div>
                <h4>
                    <span class="material-symbols-outlined">meeting_room</span>
                    회의실 관리
                </h4>
                <p>회의실을 등록하고 관리합니다.</p>
            </div>
            <button class="btn-add-type" @click="openAdd">
                <span class="material-symbols-outlined">add</span>
                회의실 추가
            </button>
        </div>

        <!-- 통계 카드 -->
        <div class="stat-row">
            <div class="stat-item">
                <div class="stat-num total">{{ store.list.length }}</div>
                <div class="stat-label">전체 회의실</div>
            </div>
            <div class="stat-item">
                <div class="stat-num active">{{ store.list.filter(r => r.useYn === 'Y').length }}</div>
                <div class="stat-label">사용중</div>
            </div>
            <div class="stat-item">
                <div class="stat-num inactive">{{ store.list.filter(r => r.useYn === 'N').length }}</div>
                <div class="stat-label">미사용</div>
            </div>
        </div>

        <!-- 카드 목록 -->
        <div class="room-card-grid">

            <div v-if="store.list.length === 0" class="empty-msg">
                등록된 회의실이 없습니다.
            </div>

            <div class="room-card" v-for="room in store.list" :key="room.roomId">
                <!-- 사진 영역 -->
                <div class="room-card-img">
                    <img v-if="room.photos && room.photos.length > 0"
                         :src="ctx + '/uploads/meeting/' + room.photos[0].saveFilename"
                         alt="회의실 사진">
                    <div v-else class="no-photo">
                        <span class="material-symbols-outlined">meeting_room</span>
                    </div>
                </div>

                <!-- 정보 영역 -->
                <div class="room-card-body">
                    <h5>{{ room.roomName }}</h5>
                    <p class="room-info">
                        <span class="material-symbols-outlined">location_on</span>
                        {{ room.location || '-' }}
                    </p>
                    <p class="room-info">
                        <span class="material-symbols-outlined">group</span>
                        {{ room.capacity }}명
                    </p>

                    <!-- 비품 뱃지 -->
                    <div class="equip-badges" v-if="room.equipCodes && room.equipCodes.length > 0">
                        <span class="badge"
                              v-for="eq in room.equipCodes" :key="eq">
                            {{ getEquipName(eq) }}
                        </span>
                    </div>

                    <!-- 사용여부 -->
                    <span class="use-badge" :class="room.useYn === 'Y' ? 'on' : 'off'">
                        {{ room.useYn === 'Y' ? '사용중' : '미사용' }}
                    </span>
                </div>

                <!-- 버튼 영역 -->
                <div class="room-card-footer">
                    <button class="btn-edit" @click="openEdit(room)">수정</button>
                    <button class="btn-del" @click="confirmDelete(room)">삭제</button>
                </div>
            </div>
        </div>

        <!-- 등록/수정 모달 -->
        <div class="modal fade" id="roomModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="material-symbols-outlined">{{ store.formMode === 'ADD' ? 'add_circle' : 'edit' }}</span>
                            {{ store.formMode === 'ADD' ? '회의실 등록' : '회의실 수정' }}
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">

                        <div class="mb-3">
                            <label>회의실명 <span style="color:#d93025;">*</span></label>
                            <input type="text" v-model="store.form.roomName" placeholder="예: 대회의실 A">
                        </div>

                        <div class="mb-3">
                            <label>위치</label>
                            <input type="text" v-model="store.form.location" placeholder="예: 본사 3층">
                        </div>

                        <div style="display:flex; gap:16px;" class="mb-3">
                            <div style="flex:1;">
                                <label>수용인원</label>
                                <input type="number" v-model.number="store.form.capacity" min="0">
                            </div>
                            <div style="flex:1;">
                                <label>정렬순서</label>
                                <input type="number" v-model.number="store.form.sortOrder" min="0">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label>사용여부</label>
                            <div style="display:flex; gap:16px; margin-top:6px;">
                                <label style="display:flex; align-items:center; gap:6px; font-size:13px; font-weight:400; cursor:pointer;">
                                    <input type="radio" v-model="store.form.useYn" value="Y" style="accent-color:#4e73df;"> 사용
                                </label>
                                <label style="display:flex; align-items:center; gap:6px; font-size:13px; font-weight:400; cursor:pointer;">
                                    <input type="radio" v-model="store.form.useYn" value="N" style="accent-color:#4e73df;"> 미사용
                                </label>
                            </div>
                        </div>

                        <!-- 비품 체크박스 -->
                        <div class="mb-3">
                            <label>비품</label>
                            <div class="equip-check-group">
                                <div class="form-check form-check-inline"
                                     v-for="eq in equipList" :key="eq.code">
                                    <input class="form-check-input" type="checkbox"
                                           :id="'eq_' + eq.code"
                                           :value="eq.code"
                                           v-model="store.form.equipCodes"
                                           style="accent-color:#4e73df;">
                                    <label class="form-check-label" :for="'eq_' + eq.code"
                                           style="font-weight:400;">
                                        {{ eq.name }}
                                    </label>
                                </div>
                            </div>
                        </div>

                        <!-- 사진 첨부 -->
                        <div class="mb-3 file-input-wrap">
                            <label>사진</label>
                            <input type="file" ref="photoInput"
                                   multiple accept="image/*" @change="onFileChange">
                            <small>여러 장 선택 가능</small>
                        </div>

                    </div>
                    <div class="modal-footer">
                        <button class="btn-modal-cancel" data-bs-dismiss="modal">취소</button>
                        <button class="btn-modal-save" @click="save">저장</button>
                    </div>
                </div>
            </div>
        </div>

    </div>
</main>

<jsp:include page="/WEB-INF/views/vue/vue_cdn.jsp"/>

<script type="importmap">
{
    "imports": {
        "http": "/dist/util/http.js?v=2",
        "meetingRoomStore": "/dist/js/meetingRoomStore.js?v=2",
        "commonCodeStore": "/dist/util/store/commonCodeStore.js"
    }
}
</script>

<script type="module">
    import { createApp, ref, computed, onMounted } from 'vue';
    import { createPinia } from 'pinia';
    import { useMeetingRoomStore } from 'meetingRoomStore';
    import { useCommonCodeStore } from 'commonCodeStore';

    const app = createApp({
        setup() {
            const store = useMeetingRoomStore();
            const codeStore = useCommonCodeStore();
            const ctx = document.querySelector('meta[name="ctx"]').content;

            // ── 사진 파일 참조 ──
            const photoInput = ref(null);
            let selectedFiles = [];

            const onFileChange = (e) => {
                selectedFiles = Array.from(e.target.files);
            };

            // ── 비품 코드 목록 (공통코드 EQUIPMENT) ──
            const equipList = computed(() => codeStore.getCodes('EQUIPMENT'));

            // 비품코드 → 비품명 변환
            const getEquipName = (code) => {
                const found = equipList.value.find(e => e.code === code);
                return found ? found.name : code;
            };

            // ── 모달 제어 ──
            let modalInstance = null;

            const showModal = () => {
                const el = document.getElementById('roomModal');
                modalInstance = new bootstrap.Modal(el);
                modalInstance.show();
            };
            const hideModal = () => {
                if (modalInstance) modalInstance.hide();
            };

            // ── 등록 폼 열기 ──
            const openAdd = () => {
                store.openAddForm();
                selectedFiles = [];
                if (photoInput.value) photoInput.value.value = '';
                showModal();
            };

            // ── 수정 폼 열기 ──
            const openEdit = (room) => {
                store.openEditForm(room);
                selectedFiles = [];
                if (photoInput.value) photoInput.value.value = '';
                showModal();
            };

            // ── 저장 ──
            const save = async () => {
                if (!store.form.roomName.trim()) {
                    alert('회의실명을 입력하세요.');
                    return;
                }
                try {
                    await store.saveRoom(selectedFiles);
                    hideModal();
                } catch (e) {
                    alert('저장 실패: ' + (e.response?.data?.message || e.message));
                }
            };

            // ── 삭제 ──
            const confirmDelete = async (room) => {
                if (!confirm(room.roomName + ' 회의실을 삭제하시겠습니까?')) return;
                try {
                    await store.deleteRoom(room.roomId);
                } catch (e) {
                    alert('삭제 실패');
                }
            };

            // ── 초기 로딩 ──
            onMounted(async () => {
                await codeStore.fetchCodes('EQUIPMENT');
                await store.fetchList();
            });

            return {
                store, ctx, equipList,
                photoInput, onFileChange,
                getEquipName, openAdd, openEdit, save, confirmDelete
            };
        }
    });

    app.use(createPinia());
    app.mount('#vue-app');
</script>

</body>
</html>
