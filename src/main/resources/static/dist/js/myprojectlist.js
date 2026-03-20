document.addEventListener('DOMContentLoaded', function() {
    const filterBtn   = document.getElementById('myFilterBtn');
    const filterMenu  = document.getElementById('myFilterMenu');
    const filterItems = filterMenu.querySelectorAll('.dropdown-item');

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

    // ── 필터 클릭 → form submit ────────────────────────────────────────
    filterItems.forEach(item => {
        item.addEventListener('click', function(e) {
            e.preventDefault();
            const statusText = this.querySelector('.status-badge').innerText.trim();
            const statusMap = {
                '진행중': '2',
                '중단':   '6',
                '종료':   '4',
                '지연':   '5',
                '시작전': '1'
            };
            const statusCode = statusMap[statusText] || '';
            const form = document.querySelector('.search-box').closest('form');
            let statusInput = form.querySelector('input[name="status"]');
            if (!statusInput) {
                statusInput      = document.createElement('input');
                statusInput.type = 'hidden';
                statusInput.name = 'status';
                form.appendChild(statusInput);
            }
            const current = form.querySelector('input[name="status"]')?.value || '';
            if (current === statusCode) {
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

    // ── 조직도 모달 로드 ──────────────────────────────────────────────
    const editMemberSearchModal = document.getElementById('editMemberSearchModal');
    if (editMemberSearchModal) {
        editMemberSearchModal.addEventListener('show.bs.modal', () => {
            const deptTreeEl = document.getElementById('editDeptTree');
            if (deptTreeEl.children.length > 0) return;
            fetch('/api/approval/org/dept')
                .then(res => res.json())
                .then(res => {
                    deptTreeEl.innerHTML = '';
                    editRenderDeptTree(res.tree || [], deptTreeEl, 0);
                });
        });
    }
});

// ══════════════════════════════════════════════════════════════════════════
// 전역 함수
// ══════════════════════════════════════════════════════════════════════════

// ── 편집 모드 토글 ────────────────────────────────────────────────────────
let editMode = false;

function toggleEditMode() {
    editMode = !editMode;
    const editBtn = document.getElementById('editModeBtn');

    if (editMode) {
        editBtn.classList.add('active');
        editBtn.style.background = '#28a745';
        editBtn.innerHTML = '<i class="fas fa-check"></i>';
        toast('편집 모드가 활성화되었습니다.', 'success');
    } else {
        editBtn.classList.remove('active');
        editBtn.style.background = '';
        editBtn.innerHTML = '<i class="fas fa-pen"></i>';
        toast('편집 모드가 비활성화되었습니다.');
    }
}

// ── 수정 모달 열기 ────────────────────────────────────────────────────────
function openEditModal(row) {
    if (row.dataset.role !== 'M') {
        toast('매니저만 수정할 수 있습니다.');
        return;
    }

    const projectId     = row.dataset.projectId;
    const projectTitle  = row.dataset.projectTitle;
    const projectStatus = row.dataset.projectStatus;

    document.getElementById('editProjectId').value        = projectId;
    document.getElementById('editModalTitle').textContent = projectTitle + ' 수정';

    const forceStopBtn = document.getElementById('forceStopBtn');
    if (projectStatus === '6') {
        forceStopBtn.disabled    = true;
        forceStopBtn.textContent = '이미 중단됨';
    } else {
        forceStopBtn.disabled    = false;
        forceStopBtn.textContent = '강제 중단';
    }

    loadCurrentMembers(projectId);

    document.getElementById('selectedMemberList').innerHTML =
        '<p class="text-muted mb-0" id="noMemberText">선택된 멤버가 없습니다.</p>';
    document.getElementById('hiddenInputContainer').innerHTML = '';
    document.getElementById('newMemberArea').style.display   = 'none';

    bootstrap.Modal.getOrCreateInstance(document.getElementById('projectEditModal')).show();
}

// ── 현재 구성원 로드 ──────────────────────────────────────────────────────
function loadCurrentMembers(projectId) {
    fetch(`/projects/members?projectId=${projectId}`)
        .then(res => res.json())
        .then(list => {
            const container = document.getElementById('currentMemberBadges');
            container.innerHTML = '';
            list.forEach(member => {
                const badge           = document.createElement('span');
                badge.className       = 'badge bg-secondary d-flex align-items-center gap-1 p-2';
                badge.dataset.empId   = member.empId;
                badge.dataset.role    = member.role;
                badge.innerHTML =
                    `<span>${member.name}</span>
                     <span class="fw-normal opacity-75" style="font-size:0.75rem">${member.role}</span>
                     <i class="fas fa-exchange-alt ms-1" style="cursor:pointer"
                        onclick="selectReplaceTarget('${member.empId}','${member.name}','${member.role}')"></i>`;
                container.appendChild(badge);
            });
        });
}

// ── 교체 대상 선택 ────────────────────────────────────────────────────────
let replaceTargetEmpId = null;
let replaceTargetRole  = null;

function selectReplaceTarget(empId, name, role) {
    replaceTargetEmpId = empId;
    replaceTargetRole  = role;

    document.getElementById('newMemberArea').style.display = '';

    document.querySelectorAll('#currentMemberBadges .badge').forEach(b => {
        b.classList.toggle('bg-danger',    b.dataset.empId === empId);
        b.classList.toggle('bg-secondary', b.dataset.empId !== empId);
    });

    bootstrap.Modal.getOrCreateInstance(document.getElementById('editMemberSearchModal')).show();
}

// ── 강제 중단 ────────────────────────────────────────────────────────────
function forceStopProject() {
    const projectId = document.getElementById('editProjectId').value;
    
    // ✅ 수정 모달 먼저 닫기
    bootstrap.Modal.getInstance(document.getElementById('projectEditModal')).hide();
    
    // ✅ 모달 닫힌 후 확인 팝업
    setTimeout(() => {
        Swal.fire({
            title: '강제 중단',
            html: '<div style="font-size:0.95rem">프로젝트와 모든 task가 중단됩니다.<br>계속하시겠습니까?</div>',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            confirmButtonText: '중단',
            cancelButtonText: '취소'
        }).then(result => {
            if (!result.isConfirmed) return;
            fetch('/projects/forceStop?projectId=' + projectId, { method: 'POST' })
                .then(res => {
                    if (res.ok) {
                        toast('프로젝트가 중단되었습니다.', 'success');
                        setTimeout(() => location.reload(), 1000);
                    } else {
                        toast('중단 처리 중 오류가 발생했습니다.');
                    }
                });
        });
    }, 400);
}

// ── 구성원 변경 저장 ──────────────────────────────────────────────────────
function saveMemberChange() {
    const projectId = document.getElementById('editProjectId').value;
    const newEmpId  = document.querySelector('#hiddenInputContainer input[name="memberIds"]')?.value;

    if (!replaceTargetEmpId || !newEmpId) {
        toast('교체할 구성원과 새 구성원을 선택하세요.');
        return;
    }
    if (replaceTargetEmpId === newEmpId) {
        toast('같은 구성원입니다.');
        return;
    }

    fetch('/projects/member/change', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            projectId: projectId,
            oldEmpId:  replaceTargetEmpId,
            newEmpId:  newEmpId,
            role:      replaceTargetRole
        })
    }).then(res => {
        if (res.ok) {
            bootstrap.Modal.getInstance(document.getElementById('projectEditModal')).hide();
            toast('구성원이 변경되었습니다.', 'success');
            setTimeout(() => location.reload(), 800);
        } else {
            toast('구성원 변경 중 오류가 발생했습니다.');
        }
    });
}

// ── 토스트 알림 ───────────────────────────────────────────────────────────
function toast(msg, icon = 'warning') {
    Swal.fire({
        title: '알림',
        html: `<div style="font-size:0.95rem;font-weight:500;margin-top:10px;">${msg}</div>`,
        showConfirmButton: false,
        timer: 1500,
        icon: icon,
        iconColor: '#4e73df',
        width: '320px',
        padding: '1rem',
        customClass: { container: 'swal-over-modal' }
    });
}

// ── 조직도 렌더링 ─────────────────────────────────────────────────────────
function editRenderDeptTree(nodes, parentEl, depth) {
    nodes.forEach(dept => {
        const hasChildren = dept.children && dept.children.length > 0;
        const li          = document.createElement('li');
        const row         = document.createElement('div');
        row.className        = 'dept-item';
        row.dataset.deptCode = dept.deptCode;
        row.dataset.deptName = dept.deptName;

        const toggle      = document.createElement('span');
        toggle.className  = 'dept-toggle';
        toggle.innerHTML  = hasChildren ? '&#9654;' : '&nbsp;';
        row.appendChild(toggle);

        const icon        = document.createElement('i');
        icon.className    = depth === 0 ? 'fas fa-building text-secondary' : 'fas fa-folder text-warning';
        icon.style.fontSize = '0.8rem';
        row.appendChild(icon);

        const label       = document.createElement('span');
        label.textContent = dept.deptName;
        row.appendChild(label);
        li.appendChild(row);

        if (hasChildren) {
            const childUl     = document.createElement('ul');
            childUl.className = 'list-unstyled mb-0 dept-children';
            editRenderDeptTree(dept.children, childUl, depth + 1);
            li.appendChild(childUl);
            toggle.addEventListener('click', (e) => {
                e.stopPropagation();
                const isOpen = childUl.classList.toggle('open');
                toggle.classList.toggle('open', isOpen);
            });
        }

        row.addEventListener('click', () => {
            document.querySelectorAll('#editDeptTree .dept-item.active').forEach(el => el.classList.remove('active'));
            row.classList.add('active');
            const codes = editCollectDeptCodes(dept);
            editLoadDeptMembers(codes, dept.deptName, hasChildren);
        });
        row._deptNode = dept;
        parentEl.appendChild(li);
    });
}

function editCollectDeptCodes(node) {
    const codes = [node.deptCode];
    if (node.children && node.children.length > 0) {
        node.children.forEach(child => codes.push(...editCollectDeptCodes(child)));
    }
    return codes;
}

function editLoadDeptMembers(deptCodes, deptName, hasChildren) {
    document.getElementById('editSelectedDeptName').textContent = deptName + ' (조회 중...)';
    document.getElementById('editModalMemberList').innerHTML    =
        '<p class="text-muted p-2"><i class="fas fa-spinner fa-spin me-1"></i>불러오는 중...</p>';

    const codes = Array.isArray(deptCodes) ? deptCodes : [deptCodes];
    Promise.all(
        codes.map(code =>
            fetch('/api/approval/org/emp?deptCode=' + encodeURIComponent(code))
                .then(r => r.json()).then(r => r.list || []).catch(() => [])
        )
    ).then(results => {
        const seen   = new Set();
        const merged = results.flat().filter(emp => {
            const id = emp.EMPID || emp.empId || '';
            if (seen.has(id)) return false;
            seen.add(id);
            return true;
        });
        const label = hasChildren ? deptName + ' 전체' : deptName;
        document.getElementById('editSelectedDeptName').textContent = label + ' (' + merged.length + '명)';
        editRenderMemberList(merged);
    });
}

function editSearchMembers() {
    const keyword = document.getElementById('editMemberSearchKeyword').value.trim();
    if (!keyword) { alert('검색어를 입력하세요.'); return; }
    document.getElementById('editSelectedDeptName').textContent = '"' + keyword + '" 검색 중...';
    fetch('/api/approval/org/emp/search?keyword=' + encodeURIComponent(keyword))
        .then(res => res.json())
        .then(res => {
            document.getElementById('editSelectedDeptName').textContent =
                '"' + keyword + '" 검색 결과 (' + (res.list ? res.list.length : 0) + '건)';
            editRenderMemberList(res.list);
        });
}

function editRenderMemberList(list) {
    const container = document.getElementById('editModalMemberList');
    if (!list || list.length === 0) {
        container.innerHTML = '<p class="text-muted p-2">소속 사원이 없습니다.</p>';
        return;
    }
    container.innerHTML = '';
    list.forEach(emp => {
        const empId = String(emp.EMPID || emp.empId || '');
        const name  = emp.NAME  || emp.name  || '';
        const dept  = emp.DEPT  || emp.dept  || '';
        const grade = emp.GRADE || emp.grade || '';

        const col   = document.createElement('div');
        col.className = 'col';
        const card  = document.createElement('div');
        card.className     = 'member-card';
        card.dataset.empId = empId;
        card.dataset.name  = name;
        card.dataset.dept  = dept;
        card.dataset.grade = grade;
        card.innerHTML =
            '<div class="emp-name">' + name + '</div>' +
            '<div class="emp-meta"><span>' + dept + '</span><span class="sep">|</span><span>' + grade + '</span></div>';

        card.addEventListener('click', function() {
            // 단일 선택
            document.querySelectorAll('#editModalMemberList .member-card').forEach(c => c.classList.remove('added'));
            this.classList.add('added');

            const container   = document.getElementById('hiddenInputContainer');
            container.innerHTML = '';
            const input       = document.createElement('input');
            input.type        = 'hidden';
            input.name        = 'memberIds';
            input.value       = empId;
            container.appendChild(input);

            document.getElementById('selectedMemberList').innerHTML = '';
            const badge       = document.createElement('span');
            badge.className   = 'badge bg-primary d-flex align-items-center gap-1 p-2';
            badge.innerHTML   = `<span>${name}</span>
                <span class="fw-normal opacity-75" style="font-size:0.75rem">${dept} / ${grade}</span>`;
            document.getElementById('selectedMemberList').appendChild(badge);
        });

        col.appendChild(card);
        container.appendChild(col);
    });
}

function editConfirmSelection() {
    bootstrap.Modal.getInstance(document.getElementById('editMemberSearchModal')).hide();
}