<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>예약 현황</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/meetingroom.css?v=12" type="text/css">
<meta name="ctx" content="${pageContext.request.contextPath}">
<meta name="empId" content="${sessionScope.member.empId}">
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
                    <span class="material-symbols-outlined">calendar_month</span>
                    예약 현황
                </h4>
            </div>
            <button class="btn-add-type" @click="openReserveModal">
                <span class="material-symbols-outlined">add</span>
                예약하기
            </button>
        </div>

        <!-- 날짜 네비 + 통계 -->
        <div class="reserve-toolbar">
            <div class="date-nav">
                <button class="date-nav-btn" @click="changeDate(-1)">
                    <span class="material-symbols-outlined">chevron_left</span>
                </button>
                <div class="date-display" @click="$refs.datePicker.showPicker()">
                    <span class="material-symbols-outlined">calendar_today</span>
                    {{ formatDateKr(store.selectedDate) }}
                </div>
                <input type="date" ref="datePicker" class="date-hidden-input"
                       :value="store.selectedDate" @change="onDatePick">
                <button class="date-nav-btn" @click="changeDate(1)">
                    <span class="material-symbols-outlined">chevron_right</span>
                </button>
                <button class="btn-today" @click="goToday">오늘</button>
            </div>
            <div class="toolbar-right">
                <button :class="['btn-my-filter', { active: showMyOnly }]" @click="showMyOnly = !showMyOnly">
                    <span class="material-symbols-outlined">person</span>
                    내 예약만
                </button>
                <div class="toolbar-stats">
                    <span class="toolbar-stat">오늘 <strong>{{ store.stats.today }}</strong></span>
                    <span class="toolbar-stat">이번주 <strong>{{ store.stats.week }}</strong></span>
                    <span class="toolbar-stat">이번달 <strong>{{ store.stats.month }}</strong></span>
                </div>
            </div>
        </div>

        <!-- 시간표 (전체 너비) -->
        <div class="timetable-panel">
                <div class="schedule-header">
                    <h5>
                        <span class="material-symbols-outlined">event_note</span>
                        {{ formatDateKr(store.selectedDate) }}
                    </h5>
                    <span class="schedule-count">{{ store.reserveList.length }}건</span>
                </div>

                <div v-if="store.rooms.length === 0" class="schedule-empty">
                    <span class="material-symbols-outlined">meeting_room</span>
                    <p>등록된 회의실이 없습니다.</p>
                </div>

                <div v-else class="timetable-wrap">
                    <table class="timetable">
                        <thead>
                            <tr>
                                <th class="tt-time-th">시간</th>
                                <th v-for="room in store.rooms" :key="room.roomId"
                                    class="tt-room-th" @click="openRoomDetail(room)">
                                    <span class="tt-color-dot" :style="{ background: getRoomColor(room.roomId) }"></span>
                                    <span class="tt-room-name">{{ room.roomName }}</span>
                                    <span class="material-symbols-outlined tt-info-icon">info</span>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="row in timetableRows" :key="row.time" :class="{ 'tt-hour-row': row.time.endsWith(':00') }">
                                <td class="tt-time-td">
                                    <span v-if="row.time.endsWith(':00')">{{ row.time }}</span>
                                </td>
                                <td v-for="room in store.rooms" :key="room.roomId"
                                    :class="['tt-cell', 'tt-' + row.cells[room.roomId].type, { 'tt-dimmed': isCellDimmed(row.cells[room.roomId]) }]"
                                    :style="row.cells[room.roomId].type !== 'free' ? { borderLeftColor: getRoomColor(room.roomId), backgroundColor: getRoomColor(room.roomId) + '15' } : {}"
                                    @click="onCellClick(row.cells[room.roomId], room.roomId, row.time)">
                                    <div v-if="row.cells[room.roomId].type === 'start'" class="tt-event">
                                        <div class="tt-event-title">{{ row.cells[room.roomId].title }}</div>
                                        <div class="tt-event-meta">{{ row.cells[room.roomId].empName }}</div>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

        <!-- 예약 등록 모달 -->
        <div class="modal fade" id="reserveModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="material-symbols-outlined">edit_calendar</span>
                            회의실 예약
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">

                        <div class="mb-3">
                            <label>회의실 <span style="color:#d93025;">*</span></label>
                            <select v-model="store.form.roomId">
                                <option value="">선택하세요</option>
                                <option v-for="room in store.rooms" :key="room.roomId"
                                        :value="room.roomId">
                                    {{ room.roomName }} ({{ room.location }}, {{ room.capacity }}명)
                                </option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label>날짜 <span style="color:#d93025;">*</span></label>
                            <input type="date" v-model="store.form.reserveDate">
                        </div>

                        <div style="display:flex; gap:16px;" class="mb-3">
                            <div style="flex:1;">
                                <label>시작시간 <span style="color:#d93025;">*</span></label>
                                <select v-model="store.form.startTime">
                                    <option v-for="t in timeOptions" :key="'s'+t" :value="t">{{ t }}</option>
                                </select>
                            </div>
                            <div style="flex:1;">
                                <label>종료시간 <span style="color:#d93025;">*</span></label>
                                <select v-model="store.form.endTime">
                                    <option v-for="t in timeOptions" :key="'e'+t" :value="t">{{ t }}</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label>회의 제목 <span style="color:#d93025;">*</span></label>
                            <input type="text" v-model="store.form.title" placeholder="예: 주간 기획회의">
                        </div>

                        <div class="mb-3">
                            <label>참석자</label>
                            <input type="text" v-model="store.form.attendees" placeholder="예: 홍길동, 김철수">
                        </div>

                        <div class="mb-3">
                            <label>메모</label>
                            <input type="text" v-model="store.form.memo" placeholder="기타 전달사항">
                        </div>

                    </div>
                    <div class="modal-footer">
                        <button class="btn-modal-cancel" data-bs-dismiss="modal">취소</button>
                        <button class="btn-modal-save" @click="saveReserve">예약</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 회의실 상세 모달 -->
        <div class="modal fade" id="roomDetailModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="material-symbols-outlined">meeting_room</span>
                            {{ selectedRoom.roomName }}
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="room-detail-grid">
                            <div class="room-detail-item">
                                <span class="material-symbols-outlined">location_on</span>
                                <div>
                                    <div class="detail-label">위치</div>
                                    <div class="detail-value">{{ selectedRoom.location || '-' }}</div>
                                </div>
                            </div>
                            <div class="room-detail-item">
                                <span class="material-symbols-outlined">group</span>
                                <div>
                                    <div class="detail-label">수용인원</div>
                                    <div class="detail-value">{{ selectedRoom.capacity }}명</div>
                                </div>
                            </div>
                        </div>
                        <div class="room-detail-section" v-if="selectedRoom.equipCodes && selectedRoom.equipCodes.length">
                            <div class="detail-label" style="margin-bottom:8px;">비품</div>
                            <div class="room-detail-equips">
                                <span class="equip-tag" v-for="eq in selectedRoom.equipCodes" :key="eq">
                                    {{ getEquipName(eq) }}
                                </span>
                            </div>
                        </div>
                        <div class="room-detail-section" v-if="selectedRoom.photos && selectedRoom.photos.length">
                            <div class="detail-label" style="margin-bottom:8px;">사진</div>
                            <div class="room-detail-photos">
                                <img v-for="p in selectedRoom.photos" :key="p.photoId"
                                     :src="ctx + '/uploads/meeting/' + p.saveFilename"
                                     alt="회의실 사진">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn-modal-cancel" data-bs-dismiss="modal">닫기</button>
                        <button class="btn-modal-save" @click="reserveFromDetail">이 회의실 예약</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 예약 상세 모달 -->
        <div class="modal fade" id="reserveDetailModal" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <span class="material-symbols-outlined">event</span>
                            예약 상세
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="reserve-detail-title">{{ selectedReserve.title }}</div>

                        <div class="reserve-detail-info">
                            <div class="reserve-detail-row">
                                <span class="material-symbols-outlined">meeting_room</span>
                                <span>{{ selectedReserve.roomName }}</span>
                            </div>
                            <div class="reserve-detail-row">
                                <span class="material-symbols-outlined">schedule</span>
                                <span>{{ selectedReserve.reserveDate }} {{ selectedReserve.startTime }} ~ {{ selectedReserve.endTime }}</span>
                            </div>
                            <div class="reserve-detail-row">
                                <span class="material-symbols-outlined">person</span>
                                <span>{{ selectedReserve.reserveEmpName }} ({{ selectedReserve.reserveDeptName }})</span>
                            </div>
                            <div class="reserve-detail-row" v-if="selectedReserve.attendees">
                                <span class="material-symbols-outlined">group</span>
                                <span>{{ selectedReserve.attendees }}</span>
                            </div>
                            <div class="reserve-detail-row" v-if="selectedReserve.memo">
                                <span class="material-symbols-outlined">description</span>
                                <span>{{ selectedReserve.memo }}</span>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn-modal-cancel" data-bs-dismiss="modal">닫기</button>
                        <button v-if="selectedReserve.reserveEmpId === empId"
                                class="btn-modal-danger" @click="cancelFromDetail">
                            예약 취소
                        </button>
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
        "meetingReserveStore": "/dist/js/meetingReserveStore.js?v=2",
        "commonCodeStore": "/dist/util/store/commonCodeStore.js"
    }
}
</script>

<script type="module">
    import { createApp, ref, computed, onMounted } from 'vue';
    import { createPinia } from 'pinia';
    import { useMeetingReserveStore } from 'meetingReserveStore';
    import { useCommonCodeStore } from 'commonCodeStore';

    const app = createApp({
        setup() {
            const store = useMeetingReserveStore();
            const codeStore = useCommonCodeStore();
            const empId = document.querySelector('meta[name="empId"]').content;
            const datePicker = ref(null);

            const ctx = document.querySelector('meta[name="ctx"]').content;
            const selectedRoom = ref({});
            const selectedReserve = ref({});
            const showMyOnly = ref(false);
            let modalInstance = null;
            let roomDetailModalInstance = null;
            let reserveDetailModalInstance = null;

            // ── 30분 단위 시간 옵션 생성 ──
            const timeOptions = [];
            for (let h = 7; h <= 21; h++) {
                const hh = String(h).padStart(2, '0');
                timeOptions.push(hh + ':00');
                timeOptions.push(hh + ':30');
            }
            timeOptions.push('22:00');

            // ── 날짜 포맷 (한국어) ──
            const formatDateKr = (dateStr) => {
                if (!dateStr) return '';
                const d = new Date(dateStr + 'T00:00:00');
                const days = ['일', '월', '화', '수', '목', '금', '토'];
                const m = d.getMonth() + 1;
                const dd = d.getDate();
                const day = days[d.getDay()];
                return m + '월 ' + dd + '일 (' + day + ')';
            };

            // ── 비품 코드→이름 변환 ──
            const equipList = computed(() => codeStore.getCodes('EQUIPMENT'));
            const getEquipName = (code) => {
                const found = equipList.value.find(e => e.code === code);
                return found ? found.name : code;
            };

            // ── 회의실별 색상 ──
            const roomColors = [
                '#4e73df', '#1a9660', '#e67e22', '#9b59b6',
                '#e74c3c', '#3498db', '#2ecc71', '#f39c12'
            ];
            const getRoomColor = (roomId) => {
                const idx = store.rooms.findIndex(r => r.roomId === roomId);
                return roomColors[idx >= 0 ? idx % roomColors.length : 0];
            };

            // ── 30분 단위 시간 슬롯 배열 ──
            const timeSlots = [];
            for (let h = 9; h <= 21; h++) {
                timeSlots.push(String(h).padStart(2, '0') + ':00');
                timeSlots.push(String(h).padStart(2, '0') + ':30');
            }

            // ── 컬럼식 시간표 데이터 (computed) ──
            const timetableRows = computed(() => {
                return timeSlots.map(time => {
                    const cells = {};
                    store.rooms.forEach(room => {
                        const reserve = store.reserveList.find(r =>
                            r.roomId === room.roomId && r.startTime <= time && r.endTime > time
                        );
                        if (!reserve) {
                            cells[room.roomId] = { type: 'free' };
                        } else if (reserve.startTime === time) {
                            cells[room.roomId] = {
                                type: 'start',
                                title: reserve.title,
                                empName: reserve.reserveEmpName,
                                reserveId: reserve.reserveId,
                                reserveEmpId: reserve.reserveEmpId
                            };
                        } else {
                            cells[room.roomId] = { type: 'cont', reserveId: reserve.reserveId, reserveEmpId: reserve.reserveEmpId };
                        }
                    });
                    return { time, cells };
                });
            });

            // ── 내 예약만 보기 필터: 다른 사람 예약 흐리게 ──
            const isCellDimmed = (cell) => {
                if (!showMyOnly.value) return false;
                if (cell.type === 'free') return false;
                return cell.reserveEmpId !== empId;
            };

            // ── 빈 시간 클릭 시 종료시간 계산 ──
            const getNextFreeEnd = (roomId, startTime) => {
                const idx = timeSlots.indexOf(startTime);
                if (idx < 0) return startTime;
                for (let i = idx; i < timeSlots.length; i++) {
                    const row = timetableRows.value[i];
                    if (row && row.cells[roomId] && row.cells[roomId].type !== 'free') {
                        return timeSlots[i];
                    }
                }
                return '22:00';
            };

            // ── 날짜 변경 (prev/next) ──
            const changeDate = (delta) => {
                const d = new Date(store.selectedDate + 'T00:00:00');
                d.setDate(d.getDate() + delta);
                const newDate = d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
                store.fetchByDate(newDate);
                store.fetchStats();
            };

            // ── 오늘 버튼 ──
            const goToday = () => {
                const now = new Date();
                const todayStr = now.getFullYear() + '-' + String(now.getMonth()+1).padStart(2,'0') + '-' + String(now.getDate()).padStart(2,'0');
                store.fetchByDate(todayStr);
                store.fetchStats();
            };

            // ── 날짜 직접 선택 (datepicker) ──
            const onDatePick = (e) => {
                const val = e.target.value;
                if (val) {
                    store.fetchByDate(val);
                    store.fetchStats();
                }
            };

            // ── 모달 제어 ──
            const showModal = () => {
                const el = document.getElementById('reserveModal');
                modalInstance = new bootstrap.Modal(el);
                modalInstance.show();
            };
            const hideModal = () => {
                if (modalInstance) modalInstance.hide();
            };

            // ── 회의실 상세 팝업 ──
            const openRoomDetail = (room) => {
                selectedRoom.value = room;
                const el = document.getElementById('roomDetailModal');
                roomDetailModalInstance = new bootstrap.Modal(el);
                roomDetailModalInstance.show();
            };

            // ── 상세 팝업에서 바로 예약 ──
            const reserveFromDetail = () => {
                if (roomDetailModalInstance) roomDetailModalInstance.hide();
                store.resetForm(store.selectedDate);
                store.form.roomId = selectedRoom.value.roomId;
                showModal();
            };

            // ── 예약 모달 열기 ──
            const openReserveModal = () => {
                store.resetForm(store.selectedDate);
                showModal();
            };

            // ── 빈 시간 클릭 → 해당 룸/시간으로 예약 모달 ──
            const openReserveAt = (roomId, start, end) => {
                store.resetForm(store.selectedDate);
                store.form.roomId = roomId;
                store.form.startTime = start;
                // 종료시간: 빈 슬롯이 길면 시작+1시간으로 제한
                const startH = parseInt(start.split(':')[0]);
                const startM = parseInt(start.split(':')[1]);
                let defEnd = String(startH + 1).padStart(2,'0') + ':' + String(startM).padStart(2,'0');
                if (defEnd > end) defEnd = end;
                store.form.endTime = defEnd;
                showModal();
            };

            // ── 셀 클릭 핸들러 (빈칸→예약모달, 예약→상세모달) ──
            const onCellClick = (cell, roomId, time) => {
                if (cell.type === 'free') {
                    openReserveAt(roomId, time, getNextFreeEnd(roomId, time));
                } else if (cell.type === 'start' || cell.type === 'cont') {
                    openReserveDetail(cell.reserveId);
                }
            };

            // ── 예약 상세 팝업 ──
            const openReserveDetail = (reserveId) => {
                const reserve = store.reserveList.find(r => r.reserveId === reserveId);
                if (!reserve) return;
                selectedReserve.value = { ...reserve };
                const el = document.getElementById('reserveDetailModal');
                reserveDetailModalInstance = new bootstrap.Modal(el);
                reserveDetailModalInstance.show();
            };

            // ── 상세 모달에서 예약 취소 ──
            const cancelFromDetail = async () => {
                const item = selectedReserve.value;
                if (!confirm('"' + item.title + '" 예약을 취소하시겠습니까?')) return;
                try {
                    await store.cancelReserve(item.reserveId);
                    if (reserveDetailModalInstance) reserveDetailModalInstance.hide();
                } catch (e) {
                    alert('취소 실패');
                }
            };

            // ── 예약 저장 ──
            const saveReserve = async () => {
                if (!store.form.roomId) { alert('회의실을 선택하세요.'); return; }
                if (!store.form.reserveDate) { alert('날짜를 선택하세요.'); return; }
                if (!store.form.title.trim()) { alert('회의 제목을 입력하세요.'); return; }
                if (store.form.startTime >= store.form.endTime) {
                    alert('종료시간은 시작시간보다 이후여야 합니다.');
                    return;
                }
                try {
                    await store.saveReserve();
                    hideModal();

                } catch (e) {
                    alert(e.response?.data?.message || '예약 실패');
                }
            };

            // ── 예약 취소 ──
            const confirmCancel = async (item) => {
                if (!confirm('"' + item.title + '" 예약을 취소하시겠습니까?')) return;
                try {
                    await store.cancelReserve(item.reserveId);

                } catch (e) {
                    alert('취소 실패');
                }
            };

            // ── 초기 로딩 ──
            onMounted(async () => {
                const today = new Date();
                const todayStr = today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2,'0') + '-' + String(today.getDate()).padStart(2,'0');
                store.selectedDate = todayStr;

                await Promise.all([
                    codeStore.fetchCodes('EQUIPMENT'),
                    store.fetchRooms(),
                    store.fetchByDate(todayStr),
                    store.fetchStats()
                ]);
            });

            return {
                store, empId, ctx, timeOptions, timetableRows, datePicker, selectedRoom, selectedReserve, showMyOnly,
                formatDateKr, getRoomColor, getEquipName, getNextFreeEnd, isCellDimmed,
                changeDate, goToday, onDatePick,
                openRoomDetail, reserveFromDetail,
                openReserveModal, openReserveAt, onCellClick, openReserveDetail, cancelFromDetail,
                saveReserve, confirmCancel
            };
        }
    });

    app.use(createPinia());
    app.mount('#vue-app');
</script>

</body>
</html>
