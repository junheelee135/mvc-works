// ═══════════════════════════════════════════
// SweetAlert2 유틸
// ═══════════════════════════════════════════
const toast = (msg) => {
    Swal.fire({
        html: `<div style="font-size:0.95rem; font-weight:500; margin-top:10px;">${msg}</div>`,
        showConfirmButton: false,
        timer: 1500,
        timerProgressBar: false,
        iconColor: '#4e73df',
        width: '320px',
        padding: '1rem'
    });
};

const ask = (msg, callback) => {
    Swal.fire({
        text: msg,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#4e73df',
        cancelButtonColor: '#f8f9fc',
        confirmButtonText: '확인',
        cancelButtonText: '취소',
        width: '320px',
        padding: '1.2rem'
    }).then((result) => {
        if (result.isConfirmed) callback();
    });
};

// ═══════════════════════════════════════════
// 간트 차트 렌더링
// ═══════════════════════════════════════════
(function () {
    const grid = document.getElementById('ganttGrid');
    const rows = document.querySelectorAll('#taskTableBody tr[data-task-id]');
    const CELL_W = 35;
    const today = new Date();
    const year  = today.getFullYear();
    const month = today.getMonth(); // 0-based
    const daysInMonth = new Date(year, month + 1, 0).getDate();

    // 헤더 날짜 생성
    for (let i = 1; i <= daysInMonth; i++) {
        const d = new Date(year, month, i);
        const isWeekend = (d.getDay() === 0 || d.getDay() === 6);
        const cell = document.createElement('div');
        cell.className = 'grid-header-cell' + (isWeekend ? ' is-weekend' : '');
        cell.textContent = i;
        grid.appendChild(cell);
    }

    // 태스크가 없으면 빈 행만 채움
    if (rows.length === 0) {
        for (let i = 1; i <= daysInMonth; i++) {
            const cell = document.createElement('div');
            cell.className = 'grid-cell';
            grid.appendChild(cell);
        }
        return;
    }

    // 태스크별 간트 바 생성
    rows.forEach(function (row, idx) {
        const startStr = row.dataset.start;
        const endStr   = row.dataset.end;
        const startDate = startStr ? new Date(startStr) : null;
        const endDate   = endStr   ? new Date(endStr)   : null;

        // 기간(DUR) 계산
        if (startDate && endDate) {
            const dur = Math.round((endDate - startDate) / (1000 * 60 * 60 * 24)) + 1;
            const durCell = document.getElementById('dur-' + idx);
            if (durCell) durCell.textContent = dur + 'd';
        }

        // 그리드 셀 생성
        for (let day = 1; day <= daysInMonth; day++) {
            const cell = document.createElement('div');
            cell.className = 'grid-cell';

            if (startDate && endDate) {
                const cellDate  = new Date(year, month, day);
                const taskStart = new Date(year, startDate.getMonth(), startDate.getDate());
                const taskEnd   = new Date(year, endDate.getMonth(), endDate.getDate());

                if (cellDate.getTime() === taskStart.getTime()) {
                    const barDays = Math.round((taskEnd - taskStart) / (1000 * 60 * 60 * 24)) + 1;
                    const bar = document.createElement('div');
                    bar.className = 'task-bar';
                    bar.style.width = (CELL_W * barDays - 4) + 'px';
                    bar.style.left  = '2px';
                    cell.appendChild(bar);
                }
            }
            grid.appendChild(cell);
        }
    });

    grid.style.gridTemplateColumns = 'repeat(' + daysInMonth + ', ' + CELL_W + 'px)';
})();

// ═══════════════════════════════════════════
// 모달 열기 / 닫기
// ═══════════════════════════════════════════
function openTaskModal() {
    document.getElementById('taskModal').style.display = 'flex';
}

function closeTaskModal() {
    document.getElementById('taskModal').style.display = 'none';
    document.getElementById('modalStageId').value      = '';
    document.getElementById('modalDirectStage').value  = '';
    document.getElementById('directStageRow').style.display = 'none';
    document.getElementById('modalTaskTitle').value    = '';
    document.getElementById('modalMember').value       = '';
    document.getElementById('modalStartDate').value    = '';
    document.getElementById('modalEndDate').value      = '';
    document.getElementById('modalTaskDesc').value     = '';
}

// ═══════════════════════════════════════════
// 이벤트 바인딩
// ═══════════════════════════════════════════
document.addEventListener('DOMContentLoaded', function () {

    // 오버레이 클릭 시 닫기
    document.getElementById('taskModal').addEventListener('click', function (e) {
        if (e.target === this) closeTaskModal();
    });

    // 단계 직접입력 토글
    document.getElementById('modalStageId').addEventListener('change', function () {
        const directRow = document.getElementById('directStageRow');
        directRow.style.display = this.value === 'direct' ? 'flex' : 'none';
        if (this.value !== 'direct') {
            document.getElementById('modalDirectStage').value = '';
        }
    });
});

// ═══════════════════════════════════════════
// 태스크 등록
// ═══════════════════════════════════════════
function submitTask() {
    let stageId       = document.getElementById('modalStageId').value;
    const directStage = document.getElementById('modalDirectStage').value.trim();
    const taskTitle   = document.getElementById('modalTaskTitle').value.trim();
    const startDate   = document.getElementById('modalStartDate').value;
    const endDate     = document.getElementById('modalEndDate').value;
    const taskDesc    = document.getElementById('modalTaskDesc').value.trim();
    const empId       = document.getElementById('modalMember').value;
    const projectId   = document.getElementById('hiddenProjectId').value;

    // 유효성 검사
    if (!stageId)                             { toast('단계를 선택해주세요.'); return; }
    if (stageId === 'direct' && !directStage) { toast('단계명을 입력해주세요.'); return; }
    if (!empId)                               { toast('담당자를 선택해주세요.'); return; }
    if (!taskTitle)                           { toast('태스크명을 입력해주세요.'); return; }
    if (!startDate)                           { toast('시작일을 입력해주세요.'); return; }
    if (!endDate)                             { toast('종료일을 입력해주세요.'); return; }
    if (endDate < startDate)                  { toast('종료일은 시작일보다 빠를 수 없습니다.'); return; }

    if (stageId === 'direct') stageId = null;

    fetch(contextPath + '/projects/task/insert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            projectId:       projectId,
            stageId:         stageId,
            stgTitle:        stageId === null ? directStage : null,
            empId:           empId,
            taskTitle:       taskTitle,
            taskStartDate:   startDate,
            taskEndDate:     endDate,
            taskDescription: taskDesc
        })
    })
    .then(res => {
        if (res.ok) {
            toast('태스크가 생성되었습니다.');
            setTimeout(() => {
                closeTaskModal();
                location.reload();
            }, 1500);
        } else {
            toast('생성 실패. 다시 시도해주세요.');
        }
    })
    .catch(err => {
        console.error(err);
        toast('서버 오류가 발생했습니다.');
    });
}
