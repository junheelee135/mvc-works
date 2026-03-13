/* 사이드바 토글 스크립트 - URL 기반 상태 유지 */
document.addEventListener('DOMContentLoaded', function () {

    // 현재 페이지 경로
    const currentPath = window.location.pathname;

    // 토글 메뉴 설정 목록
    const toggleMenus = [
        { toggleId: 'hrmToggle',      subMenuId: 'hrmSubMenu',      arrowId: 'hrmArrow'      },
        { toggleId: 'groupToggle',    subMenuId: 'groupSubMenu',    arrowId: 'groupArrow'    },
        { toggleId: 'approvalToggle', subMenuId: 'approvalSubMenu', arrowId: 'approvalArrow' },
        { toggleId: 'projectToggle',  subMenuId: 'projectSubMenu',  arrowId: 'projectArrow'  },
    ];

    toggleMenus.forEach(function (menu) {
        const toggle  = document.getElementById(menu.toggleId);
        const subMenu = document.getElementById(menu.subMenuId);
        const arrow   = document.getElementById(menu.arrowId);

        if (!toggle || !subMenu || !arrow) return;

        // ── 1. 현재 URL과 일치하는 하위 링크 찾기 ──────────────────────
        const links = subMenu.querySelectorAll('a[href]');
        let hasActiveLink = false;

        links.forEach(function (link) {
            // href 에서 contextPath 제거 후 pathname 부분만 비교
            const linkPath = new URL(link.href, location.origin).pathname;

            if (linkPath === currentPath) {
                link.classList.add('active');   // 하늘색 활성 표시
                hasActiveLink = true;
            }
        });

        // ── 2. 활성 링크가 있으면 토글 자동 열기 ──────────────────────
        if (hasActiveLink) {
            subMenu.style.display = 'block';
            arrow.classList.add('open');
        }

        // ── 3. 클릭 이벤트 (수동 토글) ─────────────────────────────────
        toggle.addEventListener('click', function (e) {
            e.preventDefault();

            const isOpen = subMenu.style.display === 'block';
            subMenu.style.display = isOpen ? 'none' : 'block';
            arrow.classList.toggle('open', !isOpen);
        });
    });
});