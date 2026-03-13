(function () {
    'use strict';

    /* ── 상태 변수 ──────────────────────────── */
    let notiList    = [];       // 알림 목록 캐시
    let panelOpen   = false;    // 패널 열림 여부
    let eventSource = null;     // SSE 연결 객체

    /* ── DOM 참조 ───────────────────────────── */
    const $notiBtn        = $('#notiBtn');
    const $notiPanel      = $('#notiPanel');
    const $notiList       = $('#notiList');
    const $notiBadge      = $('#notiBadge');
    const $notiReadAllBtn = $('#notiReadAllBtn');

    /* ── 알림 타입별 아이콘 / 색상 ──────────── */
    const NOTI_META = {
        APPROVAL : { icon: 'fas fa-file-signature', color: '#106eea' },
        PROJECT  : { icon: 'fas fa-project-diagram', color: '#28a745' },
        AUTH     : { icon: 'fas fa-user-shield',    color: '#fd7e14' },
        FEEDBACK : { icon: 'fas fa-comment-dots',   color: '#6f42c1' },
        CHAT     : { icon: 'fas fa-comment',        color: '#17a2b8' },
    };

    /* ════════════════════════════════════════
       SSE 연결
       ════════════════════════════════════════ */
    function connectSse() {
        if (eventSource) eventSource.close();

        eventSource = new EventSource('/api/notifications/stream');

        /* 알림 이벤트 수신 */
        eventSource.addEventListener('notification', function (e) {
            try {
                const dto = JSON.parse(e.data);
                notiList.unshift(dto);      // 목록 앞에 추가
                renderList();
                updateBadge();
                showToast(dto);             // 토스트 알림 출력
            } catch (err) {
                console.error('[SSE] 파싱 오류', err);
            }
        });

        eventSource.onerror = function () {
            /* 연결 끊김 시 5초 후 재연결 */
            eventSource.close();
            setTimeout(connectSse, 5000);
        };
    }

    /* ════════════════════════════════════════
       알림 목록 서버 조회 (패널 열릴 때)
       ════════════════════════════════════════ */
    function fetchList() {
        $.ajax({
            url    : '/api/notifications',
            method : 'GET',
            headers: { AJAX: 'true' },
            success: function (data) {
                notiList = data || [];
                renderList();
                updateBadge();
            },
            error: function () {
                console.error('[Notification] 목록 조회 실패');
            }
        });
    }

    /* ════════════════════════════════════════
       목록 렌더링
       ════════════════════════════════════════ */
    function renderList() {
        $notiList.empty();

        if (notiList.length === 0) {
            $notiList.append('<li class="noti-empty">알림이 없습니다.</li>');
            return;
        }

        notiList.forEach(function (item) {
            const meta    = NOTI_META[item.notiType] || { icon: 'fas fa-bell', color: '#333' };
            const unread  = item.isRead === 'N' ? 'noti-item--unread' : '';
            const canMove = item.moveType !== 'NONE' && item.targetUrl;

            const $li = $('<li>')
                .addClass('noti-item ' + unread)
                .attr('data-noti-id',   item.notiId)
                .attr('data-move-type', item.moveType)
                .attr('data-target-url', item.targetUrl || '')
                .attr('data-can-move',  canMove ? 'true' : 'false');

            $li.html(
                '<div class="noti-icon-wrap" style="color:' + meta.color + '">' +
                    '<i class="' + meta.icon + '"></i>' +
                '</div>' +
                '<div class="noti-content">' +
                    '<div class="noti-title">'   + escapeHtml(item.title)           + '</div>' +
                    '<div class="noti-message">' + escapeHtml(item.message || '')   + '</div>' +
                    '<div class="noti-date">'    + (item.regDate || '')             + '</div>' +
                '</div>' +
                (canMove ? '<div class="noti-arrow"><i class="fas fa-chevron-right"></i></div>' : '')
            );

            $notiList.append($li);
        });
    }

    /* ════════════════════════════════════════
       뱃지 업데이트
       ════════════════════════════════════════ */
    function updateBadge() {
        const unreadCnt = notiList.filter(function (n) { return n.isRead === 'N'; }).length;
        if (unreadCnt > 0) {
            $notiBadge.text(unreadCnt > 99 ? '99+' : unreadCnt).show();
        } else {
            $notiBadge.hide();
        }
    }

    /* ════════════════════════════════════════
       토스트 알림 (우측 하단)
       ════════════════════════════════════════ */
    function showToast(dto) {
        const meta = NOTI_META[dto.notiType] || { icon: 'fas fa-bell', color: '#333' };
        const $toast = $(
            '<div class="noti-toast">' +
                '<div class="noti-toast-icon" style="color:' + meta.color + '">' +
                    '<i class="' + meta.icon + '"></i>' +
                '</div>' +
                '<div class="noti-toast-body">' +
                    '<div class="noti-toast-title">' + escapeHtml(dto.title)           + '</div>' +
                    '<div class="noti-toast-msg">'   + escapeHtml(dto.message || '')   + '</div>' +
                '</div>' +
                '<button class="noti-toast-close" type="button"><i class="fas fa-times"></i></button>' +
            '</div>'
        );

        $('body').append($toast);
        setTimeout(function () { $toast.addClass('noti-toast--show'); }, 50);

        /* 4초 후 자동 닫힘 */
        const timer = setTimeout(function () { closeToast($toast); }, 4000);

        $toast.find('.noti-toast-close').on('click', function () {
            clearTimeout(timer);
            closeToast($toast);
        });
    }

    function closeToast($toast) {
        $toast.removeClass('noti-toast--show');
        setTimeout(function () { $toast.remove(); }, 300);
    }

    /* ════════════════════════════════════════
       알림 클릭 → 읽음 처리 + 화면 이동
       ════════════════════════════════════════ */
    $notiList.on('click', '.noti-item', function () {
        const $item     = $(this);
        const notiId    = $item.data('noti-id');
        const moveType  = $item.data('move-type');
        const targetUrl = $item.data('target-url');
        const canMove   = $item.data('can-move') === true || $item.data('can-move') === 'true';

        /* 읽음 처리 */
        if ($item.hasClass('noti-item--unread')) {
            $.ajax({
                url    : '/api/notifications/' + notiId + '/read',
                method : 'PATCH',
                headers: { AJAX: 'true' },
                success: function () {
                    $item.removeClass('noti-item--unread');
                    const found = notiList.find(function (n) { return n.notiId === notiId; });
                    if (found) found.isRead = 'Y';
                    updateBadge();
                }
            });
        }

        /* 화면 이동 */
        if (!canMove || !targetUrl) return;

        closePanel();

        if (moveType === 'VUE') {
            location.href = targetUrl;
        } else if (moveType === 'PAGE') {
            location.href = targetUrl;
        }
    });

    /* ════════════════════════════════════════
       모두 읽음
       ════════════════════════════════════════ */
    $notiReadAllBtn.on('click', function (e) {
        e.stopPropagation();
        $.ajax({
            url    : '/api/notifications/read-all',
            method : 'PATCH',
            headers: { AJAX: 'true' },
            success: function () {
                notiList.forEach(function (n) { n.isRead = 'Y'; });
                renderList();
                updateBadge();
            }
        });
    });

    /* ════════════════════════════════════════
       패널 토글
       ════════════════════════════════════════ */
    $notiBtn.on('click', function (e) {
        e.stopPropagation();
        panelOpen ? closePanel() : openPanel();
    });

    function openPanel() {
        fetchList();
        $notiPanel.addClass('noti-panel--open');
        panelOpen = true;
    }

    function closePanel() {
        $notiPanel.removeClass('noti-panel--open');
        panelOpen = false;
    }

    /* 패널 외부 클릭 시 닫힘 */
    $(document).on('click', function (e) {
        if (panelOpen && !$('#notiWrap').is(e.target) && $('#notiWrap').has(e.target).length === 0) {
            closePanel();
        }
    });

    /* ════════════════════════════════════════
       페이지 로드 시 읽지 않은 알림 수 조회
       → JSP 페이지 이동 후에도 뱃지 즉시 표시
       ════════════════════════════════════════ */
    function loadUnreadBadge() {
        $.ajax({
            url    : '/api/notifications/unread',
            method : 'GET',
            headers: { AJAX: 'true' },
            success: function (data) {
                const count = data.count || 0;
                if (count > 0) {
                    $notiBadge.text(count > 99 ? '99+' : count).show();
                } else {
                    $notiBadge.hide();
                }
            },
            error: function () {
                console.error('[Notification] 뱃지 조회 실패');
            }
        });
    }

    /* ════════════════════════════════════════
       유틸
       ════════════════════════════════════════ */
    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, '&amp;')
                  .replace(/</g, '&lt;')
                  .replace(/>/g, '&gt;')
                  .replace(/"/g, '&quot;');
    }

    /* ── 초기 실행 ──────────────────────────── */
    connectSse();
    loadUnreadBadge();

}());