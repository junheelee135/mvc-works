// ── 공통 토스트 알림 ──────────────────────────────────────────────────────
function toast (msg, icon = 'warning'){
		Swal.fire({
			title: '알림',
			html: `<div style="font-size: 0.95rem; font-weight: 500; margin-top: 10px;">${msg}</div>`,
			position: 'top',
			showConfirmButton: false,
			timer: 700,
			timerProgressBar: false,
			icon: icon,
			iconColor: '#4e73df',
			width: '320px', // 전체 너비 조절 (기본보다 작게)
			padding: '1rem', // 내부 여백 조절
			confirmButtonColor: '#4f86c6', // 프로젝트 메인 컬러에 맞춤
			confirmButtonText: '확인',
			customClass: { container: 'swal-over-modal' }
		});
	}

	function renderDeptTree(nodes, parentEl, depth) {
	    nodes.forEach(dept => {
	        const hasChildren = dept.children && dept.children.length > 0;
	        const li = document.createElement('li');

	        // 노드 행
	        const row = document.createElement('div');
	        row.className = 'dept-item';
	        row.dataset.deptCode = dept.deptCode;
	        row.dataset.deptName = dept.deptName;

	        // 펼침 아이콘 (자식 있을 때만)
	        const toggle = document.createElement('span');
	        toggle.className = 'dept-toggle';
	        toggle.innerHTML = hasChildren ? '&#9654;' : '&nbsp;';
	        row.appendChild(toggle);

	        // 폴더 아이콘
	        const icon = document.createElement('i');
	        icon.className = depth === 0
	            ? 'fas fa-building text-secondary'
	            : 'fas fa-folder text-warning';
	        icon.style.fontSize = '0.8rem';
	        row.appendChild(icon);

	        // 부서명
	        const label = document.createElement('span');
	        label.textContent = dept.deptName;
	        row.appendChild(label);

	        li.appendChild(row);

	        // 자식 트리
	        let childUl = null;
	        if (hasChildren) {
	            childUl = document.createElement('ul');
	            childUl.className = 'list-unstyled mb-0 dept-children';
	            renderDeptTree(dept.children, childUl, depth + 1);
	            li.appendChild(childUl);

	            // 펼침/접힘 토글
	            toggle.addEventListener('click', (e) => {
	                e.stopPropagation();
	                const isOpen = childUl.classList.toggle('open');
	                toggle.classList.toggle('open', isOpen);
	            });
	        }

	        // 부서 선택 → 사원 로드 (하위 부서 포함)
	        row.addEventListener('click', () => {
	            document.querySelectorAll('.dept-item.active').forEach(el => el.classList.remove('active'));
	            row.classList.add('active');
	            // 자식 포함 여부: 자식 있으면 하위 전체, 없으면 해당 부서만
	            const codes = collectDeptCodes(dept);
	            loadDeptMembers(codes, dept.deptName, hasChildren);
	        });
	        // 트리 노드에 dept 원본 저장 (하위 코드 수집용)
	        row._deptNode = dept;

	        parentEl.appendChild(li);
	    });
	}

	// 1. 모달 열릴 때 조직도 로드
	document.getElementById('memberSearchModal').addEventListener('show.bs.modal', () => {
	    const deptTreeEl = document.getElementById('deptTree');
	    if (deptTreeEl.children.length > 0) return; // 이미 로드됨

	    fetch('/api/approval/org/dept')
	        .then(res => res.json())
	        .then(res => {
	            deptTreeEl.innerHTML = '';
	            renderDeptTree(res.tree || [], deptTreeEl, 0);
	        })
	        .catch(err => console.error('부서 로드 실패:', err));
	});

	// 트리 노드에서 deptCode를 재귀적으로 수집
	function collectDeptCodes(node) {
	    const codes = [node.deptCode];
	    if (node.children && node.children.length > 0) {
	        node.children.forEach(child => codes.push(...collectDeptCodes(child)));
	    }
	    return codes;
	}

	// 2. 부서 클릭 시 사원 목록 로드 (하위 부서 포함 병렬 조회)
	function loadDeptMembers(deptCodes, deptName, hasChildren) {
	    document.getElementById('selectedDeptName').textContent = deptName + ' (조회 중...)';
	    document.getElementById('modalMemberList').innerHTML =
	        '<p class="text-muted p-2"><i class="fas fa-spinner fa-spin me-1"></i>불러오는 중...</p>';

	    const codes = Array.isArray(deptCodes) ? deptCodes : [deptCodes];

	    // 각 부서별 fetch를 병렬로 실행 후 합산
	    Promise.all(
	        codes.map(code =>
	            fetch('/api/approval/org/emp?deptCode=' + encodeURIComponent(code))
	                .then(r => r.json())
	                .then(r => r.list || [])
	                .catch(() => [])
	        )
	    ).then(results => {
	        // 중복 제거 (empId 기준)
	        const seen = new Set();
	        const merged = results.flat().filter(emp => {
	            const id = emp.EMPID || emp.empId || '';
	            if (seen.has(id)) return false;
	            seen.add(id);
	            return true;
	        });
	        const label = hasChildren ? deptName + ' 전체' : deptName;
	        document.getElementById('selectedDeptName').textContent =
	            label + ' (' + merged.length + '명)';
	        renderMemberList(merged);
	    });
	}

	// 3. 사원 검색
	function searchMembers() {
	    const keyword = document.getElementById('memberSearchKeyword').value.trim();
	    if (!keyword) { alert('검색어를 입력하세요.'); return; }

	    document.getElementById('selectedDeptName').textContent = '"' + keyword + '" 검색 중...';
	    document.querySelectorAll('.dept-item.active').forEach(el => el.classList.remove('active'));

	    fetch('/api/approval/org/emp/search?keyword=' + encodeURIComponent(keyword))
	        .then(res => res.json())
	        .then(res => {
	            document.getElementById('selectedDeptName').textContent =
	                '"' + keyword + '" 검색 결과 (' + (res.list ? res.list.length : 0) + '건)';
	            renderMemberList(res.list);
	        })
	        .catch(err => console.error('검색 실패:', err));
	}

	// 4. 사원 카드 렌더링 (부서 / 직급 표시)
	function renderMemberList(list) {
	    const container = document.getElementById('modalMemberList');

	    if (!list || list.length === 0) {
	        container.innerHTML = '<p class="text-muted p-2">소속 사원이 없습니다.</p>';
	        return;
	    }

	    container.innerHTML = '';

	    list.forEach(emp => {
	        // Oracle + MyBatis resultType="map" 키는 항상 대문자
	        const empId = String(emp.EMPID || emp.empId || '');
	        const name  = emp.NAME  || emp.name  || '';
	        const dept  = emp.DEPT  || emp.dept  || '';
	        const grade = emp.GRADE || emp.grade || '';
	        const isAdded = !!document.getElementById('badge_' + empId);

	        const col  = document.createElement('div');
	        col.className = 'col';

	        const card = document.createElement('div');
	        card.className = 'member-card' + (isAdded ? ' added' : '');
	        // data-* 속성 사용 → 이름에 따옴표/특수문자 있어도 안전
	        card.dataset.empId = empId;
	        card.dataset.name  = name;
	        card.dataset.dept  = dept;
	        card.dataset.grade = grade;

	        card.innerHTML =
	            '<div class="emp-name">' + name + '</div>' +
	            '<div class="emp-meta">' +
	                '<span>' + dept + '</span>' +
	                '<span class="sep">|</span>' +
	                '<span>' + grade + '</span>' +
	            '</div>';

	        card.addEventListener('click', function() {
	            const clickedEmpId = this.dataset.empId;
	            // added 상태면 제거(토글), 아니면 추가
	            if (this.classList.contains('added')) {
	                removeBadge(clickedEmpId);
	            } else {
	                addMemberBadge({
	                    empId: clickedEmpId,
	                    name:  this.dataset.name,
	                    dept:  this.dataset.dept,
	                    grade: this.dataset.grade
	                });
	            }
	        });
	        // added 상태에서도 클릭 가능하도록 pointer-events 강제 설정
	        card.style.pointerEvents = 'auto';
	        card.style.cursor = 'pointer';

	        col.appendChild(card);
	        container.appendChild(col);
	    });
	}

	// 5. 멤버 뱃지 추가
	function addMemberBadge(emp) {
	    const empId = emp.empId || emp.EMPID || '';
	    const name  = emp.name  || emp.NAME  || '';
	    const dept  = emp.dept  || emp.DEPT  || '';
	    const grade = emp.grade || emp.GRADE || '';

	    if (!empId) return;
		
		if (!window.__memberDataMap) window.__memberDataMap = {};
		window.__memberDataMap[empId] = { name, dept, grade };

	    // 이미 추가된 멤버 재클릭 시 → 토글 제거
	    if (document.getElementById('badge_' + empId)) {
	        removeBadge(empId);
	        return;
	    }

	    // 총 인원 초과 체크 + toast 알림
	    const maxInput     = document.querySelector('#step-panel-2 input[type="number"]');
	    const maxCount     = maxInput ? parseInt(maxInput.value) || 0 : 0;
	    const currentCount = document.querySelectorAll('#hiddenInputContainer input[name="memberIds"]').length;
	    if (maxCount > 0 && currentCount >= maxCount) {
	        toast('총 인원(' + maxCount + '명)을 초과하여 추가할 수 없습니다.');
	        return;
	    }

	    document.getElementById('noMemberText').style.display = 'none';

	    const badge = document.createElement('span');
	    badge.className = 'badge bg-primary d-flex align-items-center gap-1 p-2';
	    badge.id = 'badge_' + empId;

	    // 이름
	    const nameSpan = document.createElement('span');
	    nameSpan.textContent = name;
	    badge.appendChild(nameSpan);

	    // 부서/직급 (연한 텍스트)
	    const metaSpan = document.createElement('span');
	    metaSpan.className = 'fw-normal opacity-75';
	    metaSpan.style.fontSize = '0.75rem';
	    metaSpan.textContent = dept + ' / ' + grade;
	    badge.appendChild(metaSpan);

	    // 삭제 버튼
	    const delIcon = document.createElement('i');
	    delIcon.className = 'fas fa-times ms-1';
	    delIcon.style.cursor = 'pointer';
	    delIcon.addEventListener('click', function(e) {
	        e.stopPropagation();
	        removeBadge(empId);
	    });
	    badge.appendChild(delIcon);

	    document.getElementById('selectedMemberList').appendChild(badge);

	    const input = document.createElement('input');
	    input.type  = 'hidden';
	    input.name  = 'memberIds';
	    input.value = empId;
	    input.id    = 'hidden_' + empId;
	    document.getElementById('hiddenInputContainer').appendChild(input);

	    // 카드를 added 상태로 갱신
	    renderMemberListRefresh();
	}

	// 6. 뱃지 제거
	function removeBadge(empId) {
	    const badge  = document.getElementById('badge_'  + empId);
	    const hidden = document.getElementById('hidden_' + empId);
	    if (badge)  badge.remove();
	    if (hidden) hidden.remove();

	    if (document.getElementById('selectedMemberList').querySelectorAll('.badge').length === 0) {
	        document.getElementById('noMemberText').style.display = '';
	    }
	    renderMemberListRefresh();
	}

	// 7. 현재 표시 중인 카드의 added 상태 갱신
	function renderMemberListRefresh() {
	    document.querySelectorAll('#modalMemberList .member-card').forEach(card => {
	        const empId = card.dataset.empId;
	        if (!empId) return;
	        if (document.getElementById('badge_' + empId)) {
	            card.classList.add('added');
	        } else {
	            card.classList.remove('added');
	        }
	    });
	}

	// 8. 선택 완료
	function confirmSelection() {
	    bootstrap.Modal.getInstance(document.getElementById('memberSearchModal')).hide();
	}
	
	// 생성자 자동 추가
	document.addEventListener('DOMContentLoaded', function() {
	    const myEmpId = document.getElementById('myEmpId').value;
	    const myName  = document.getElementById('myName').value;
	    const myDept  = document.getElementById('myDept').value;
	    const myGrade = document.getElementById('myGrade').value;
	    if (myEmpId) {
	        addMemberBadge({ empId: myEmpId, name: myName, dept: myDept, grade: myGrade });
	    }
	});
