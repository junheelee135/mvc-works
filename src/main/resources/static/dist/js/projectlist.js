document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.querySelector('.search-box input');
    const filterBtn = document.getElementById('myFilterBtn');
    const filterMenu = document.getElementById('myFilterMenu');
    const filterItems = filterMenu.querySelectorAll('.dropdown-item');
    const tableRows = document.querySelectorAll('tbody tr');

    let currentStatus = "";


    function applyFilters() {
        const searchTerm = searchInput.value.toLowerCase().trim();

        tableRows.forEach(row => {
            const projectName = row.cells[1].textContent.toLowerCase();
            const rowStatusClean = row.cells[7].textContent.replace(/\s/g, "").trim();
            const selectedStatusClean = currentStatus.replace(/\s/g, "").trim();

            const matchesSearch = projectName.includes(searchTerm);
            const matchesStatus = (currentStatus === "") || rowStatusClean.includes(selectedStatusClean);

            if (matchesSearch && matchesStatus) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }


    searchInput.addEventListener('input', applyFilters);

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

	filterItems.forEach(item => {
	    item.addEventListener('click', function(e) {
	        e.preventDefault();

	        const statusText = this.querySelector('.status-badge').innerText.trim();

	        // 상태 텍스트 → status 코드 매핑
	        const statusMap = {
	            '진행중': '2',
	            '승인대기': '3',
	            '중단': '6',
	            '종료': '4',
	            '지연': '5',
	            '시작전': '1'
	        };

	        const statusCode = statusMap[statusText] || '';

	        // 현재 폼에 status 값 추가해서 서버로 제출
	        const form = document.querySelector('.search-box').closest('form');
	        
	        let statusInput = form.querySelector('input[name="status"]');
	        if (!statusInput) {
	            statusInput = document.createElement('input');
	            statusInput.type = 'hidden';
	            statusInput.name = 'status';
	            form.appendChild(statusInput);
	        }
	        statusInput.value = statusCode;
	        form.submit();

	        filterMenu.classList.remove('show');
	        filterBtn.style.color = "#4e73df";
	    });
	});

});