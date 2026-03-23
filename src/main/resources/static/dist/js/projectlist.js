document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.querySelector('.search-box input');
    const filterBtn = document.getElementById('myFilterBtn');
    const filterMenu = document.getElementById('myFilterMenu');
    const filterItems = filterMenu.querySelectorAll('.dropdown-item');

    // ── 실시간 검색 → 서버 요청 (디바운스 400ms) ──────────────────────────
    let searchTimer = null;
    searchInput.addEventListener('input', function() {
        clearTimeout(searchTimer);
        searchTimer = setTimeout(() => {
            const kwd = searchInput.value.trim();
            const schType = document.querySelector('select[name="schType"]').value;
            const form = document.querySelector('.search-box').closest('form');
            const statusInput = form.querySelector('input[name="status"]');
            const status = statusInput ? statusInput.value : '';

            const url = new URL(form.action || window.location.href);
            url.searchParams.set('kwd', kwd);
            url.searchParams.set('schType', schType);
            url.searchParams.set('status', status);
            url.searchParams.set('page', '1');

            window.location.href = url.toString();
        }, 400);
    });

    // ── 필터 드롭다운 열기/닫기 ──────────────────────────────────────────
    if (filterBtn && filterMenu) {
        filterBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            filterMenu.classList.toggle('show');
        });

        document.addEventListener('click', function(e) {
            if (!filterBtn.contains(e.target) && !filterMenu.contains(e.target)) {
                filterMenu.classList.remove('show');
            }
        });
    }

    // ── 필터 클릭 → form submit ──────────────────────────────────────────
    filterItems.forEach(item => {
        item.addEventListener('click', function(e) {
            e.preventDefault();

            const statusText = this.querySelector('.status-badge').innerText.trim();

            const statusMap = {
                '진행중': '2',
                '승인대기': '3',
                '중단': '6',
                '종료': '4',
                '지연': '5',
                '시작전': '1'
            };

            const statusCode = statusMap[statusText] || '';
            const form = document.querySelector('.search-box').closest('form');

            let statusInput = form.querySelector('input[name="status"]');
            if (!statusInput) {
                statusInput = document.createElement('input');
                statusInput.type = 'hidden';
                statusInput.name = 'status';
                form.appendChild(statusInput);
            }

            // 같은 거 누르면 해제 (토글)
            const currentStatus = form.querySelector('input[name="status"]')?.value || '';
            if (currentStatus === statusCode) {
                statusInput.value = '';
                filterBtn.classList.remove('active');
            } else {
                statusInput.value = statusCode;
                filterBtn.classList.add('active');
            }

            filterMenu.classList.remove('show');
            form.submit();
        });
    });

});
