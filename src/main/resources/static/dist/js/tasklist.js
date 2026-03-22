// 날짜를 YYYY-MM-DD 문자열로 변환
function toDateStr(d) {
    return d.getFullYear() + '-' +
        String(d.getMonth() + 1).padStart(2, '0') + '-' +
        String(d.getDate()).padStart(2, '0');
}

// 단계 색상 전역 관리
const stageColors = [
    { bg: '#eff4ff', color: '#4e73df', bar: '#a8d8ea' },
    { bg: '#f0fdf4', color: '#16a34a', bar: '#b5ead7' },
    { bg: '#fdf4ff', color: '#9333ea', bar: '#aa96da' },
    { bg: '#fff7ed', color: '#ea580c', bar: '#ffdac1' },
    { bg: '#fef2f2', color: '#dc2626', bar: '#fcbad3' },
    { bg: '#f0f9ff', color: '#0284c7', bar: '#ffe5d9' },
    { bg: '#fafaf9', color: '#57534e', bar: '#ffffd2' },
];

const stageMap = {};
let stageIdx = 0;

function applyStageColors() {
    document.querySelectorAll('.stage-badge').forEach(badge => {
        const stageId = badge.dataset.stage;
        if (!stageMap[stageId]) {
            stageMap[stageId] = stageColors[stageIdx % stageColors.length];
            stageIdx++;
        }
        const c = stageMap[stageId];
        badge.style.backgroundColor = c.bg;
        badge.style.color = c.color;
    });
}

// 간트 차트 렌더링 함수
function renderGanttChart() {
    const grid = document.getElementById('ganttGrid');
    grid.innerHTML = '';

    const rows = document.querySelectorAll('#taskTableBody tr[data-task-id]');

    const projectStart = new Date(document.getElementById('hiddenProjectStart').value.replace(/\//g, '-'));
    const projectEnd = new Date(document.getElementById('hiddenProjectEnd').value.replace(/\//g, '-'));
    const totalDays = Math.round((projectEnd - projectStart) / (1000 * 60 * 60 * 24)) + 1;
    const projectEndStr = toDateStr(projectEnd);

    const displayDays = Math.max(31, totalDays);
    const allDates = [];
    const cur = new Date(projectStart);
    for (let i = 0; i < displayDays; i++) {
        allDates.push(new Date(cur));
        cur.setDate(cur.getDate() + 1);
    }

    if (totalDays <= 62) {
        const CELL_W = 35;
        const WEEKEND_W = 10;

        // 헤더 렌더링
        allDates.forEach(d => {
            const isWeekend = d.getDay() === 0 || d.getDay() === 6;
            const isExtra = toDateStr(d) > projectEndStr;
            const cell = document.createElement('div');
            if (isExtra) {
                cell.className = 'grid-header-cell';
                cell.style.background = '#fafafa';
                cell.style.color = '#d0d0d0';
            } else {
                cell.className = 'grid-header-cell' + (isWeekend ? ' is-weekend' : '');
            }
            if (!isWeekend) {
                cell.textContent = (d.getMonth() + 1) + '/' + d.getDate();
            }
            grid.appendChild(cell);
        });

        if (rows.length === 0) {
            allDates.forEach(d => {
                const isWeekend = d.getDay() === 0 || d.getDay() === 6;
                const isExtra = toDateStr(d) > projectEndStr;
                const cell = document.createElement('div');
                if (isExtra) {
                    cell.className = 'grid-cell';
                    cell.style.background = '#fafafa';
                    cell.style.pointerEvents = 'none';
                } else {
                    cell.className = 'grid-cell' + (isWeekend ? ' is-weekend-cell' : '');
                }
                grid.appendChild(cell);
            });
        } else {
            rows.forEach(function (row) {
                const taskStartStr = row.dataset.start || null;
                const taskEndStr = row.dataset.end || null;
                const badge = row.querySelector('.stage-badge');
                const stageId = badge ? badge.dataset.stage : null;
                const barColor = stageId && stageMap[stageId] ? stageMap[stageId].bar : '#4e73df';

                allDates.forEach((cellDate, colIdx) => {
                    const isWeekend = cellDate.getDay() === 0 || cellDate.getDay() === 6;
                    const isExtra = toDateStr(cellDate) > projectEndStr;
                    const cell = document.createElement('div');
                    if (isExtra) {
                        cell.className = 'grid-cell';
                        cell.style.background = '#fafafa';
                        cell.style.pointerEvents = 'none';
                    } else {
                        cell.className = 'grid-cell' + (isWeekend ? ' is-weekend-cell' : '');
                    }

                    if (!isExtra && taskStartStr && taskEndStr && toDateStr(cellDate) === taskStartStr) {
                        let barWidth = 0;
                        for (let i = colIdx; i < allDates.length; i++) {
                            const d = allDates[i];
                            if (toDateStr(d) <= taskEndStr && toDateStr(d) <= projectEndStr) {
                                const isWe = d.getDay() === 0 || d.getDay() === 6;
                                barWidth += isWe ? WEEKEND_W : CELL_W;
                            } else break;
                        }
                        const bar = document.createElement('div');
                        bar.className = 'task-bar';
                        bar.style.width = (barWidth - 4) + 'px';
                        bar.style.left = '2px';
						
						const progress = parseFloat(row.dataset.progress) || 0;
						const progressWidth = Math.round(progress) + '%';
						bar.style.background = `linear-gradient(to right, ${barColor} ${progressWidth}, ${barColor}88 ${progressWidth})`;
						
                        bar.style.borderRadius = '4px';
                        bar.style.cursor = 'pointer';
                        bar.addEventListener('click', () => {
                            const taskId = row.dataset.taskId;
                            const taskTitle = row.querySelector('.task-name').textContent.trim();
                            const startStr = row.dataset.start;
                            const endStr = row.dataset.end;
                            const empTaskId = row.dataset.empTaskId || '';
                            const empId = row.dataset.empId || '';
                            const stgTitle = row.dataset.stgTitle || '';
                            openTaskDailyModal(taskId, taskTitle, startStr, endStr, empId, stgTitle, projectTitle, empTaskId);
                        });
                        cell.appendChild(bar);
                    }
                    grid.appendChild(cell);
                });
            });
        }

        grid.style.gridTemplateColumns = allDates.map(d => {
            const isWeekend = d.getDay() === 0 || d.getDay() === 6;
            return (isWeekend ? WEEKEND_W : CELL_W) + 'px';
        }).join(' ');

    } else {
        const CELL_W = 80;
        const WEEKEND_W = 20;

        const columns = [];
        let i = 0;

        while (i < allDates.length) {
            const d = allDates[i];
            const day = d.getDay();

            if (day === 6) {
                const sat = d;
                const nextDate = allDates[i + 1];
                if (nextDate && nextDate.getDay() === 0) {
                    columns.push({ type: 'weekend', dates: [sat, nextDate] });
                    i += 2;
                } else {
                    columns.push({ type: 'weekend', dates: [sat] });
                    i++;
                }
            } else if (day === 0) {
                columns.push({ type: 'weekend', dates: [d] });
                i++;
            } else {
                const weekdays = [];
                while (i < allDates.length && allDates[i].getDay() !== 0 && allDates[i].getDay() !== 6) {
                    weekdays.push(allDates[i]);
                    i++;
                }
                if (weekdays.length > 0) {
                    const first = weekdays[0];
                    const last = weekdays[weekdays.length - 1];
                    const label = (first.getMonth() + 1) + '/' + first.getDate() + '\n~\n' + (last.getMonth() + 1) + '/' + last.getDate();
                    columns.push({ type: 'weekday', dates: weekdays, label });
                }
            }
        }

        // 헤더 렌더링
        columns.forEach(col => {
            const isExtra = col.dates.length > 0 && toDateStr(col.dates[0]) > projectEndStr;
            const cell = document.createElement('div');
            if (isExtra) {
                cell.className = 'grid-header-cell';
                cell.style.background = '#fafafa';
                cell.style.color = '#d0d0d0';
            } else {
                cell.className = 'grid-header-cell' + (col.type === 'weekend' ? ' is-weekend' : '');
            }
            if (!isExtra && col.type === 'weekday') {
                cell.style.whiteSpace = 'pre-line';
                cell.style.fontSize = '10px';
                cell.style.lineHeight = '1.2';
                cell.style.textAlign = 'center';
                cell.textContent = col.label;
            }
            grid.appendChild(cell);
        });

        if (rows.length === 0) {
            columns.forEach(col => {
                const isExtra = col.dates.length > 0 && toDateStr(col.dates[0]) > projectEndStr;
                const cell = document.createElement('div');
                if (isExtra) {
                    cell.className = 'grid-cell';
                    cell.style.background = '#fafafa';
                    cell.style.pointerEvents = 'none';
                } else {
                    cell.className = 'grid-cell' + (col.type === 'weekend' ? ' is-weekend-cell' : '');
                }
                grid.appendChild(cell);
            });
        } else {
            rows.forEach(function (row) {
                const taskStartStr = row.dataset.start || null;
                const taskEndStr = row.dataset.end || null;
                const badge = row.querySelector('.stage-badge');
                const stageId = badge ? badge.dataset.stage : null;
                const barColor = stageId && stageMap[stageId] ? stageMap[stageId].bar : '#aa96da';

                let startColIdx = -1;
                if (taskStartStr && taskEndStr) {
                    for (let ci = 0; ci < columns.length; ci++) {
                        for (const cd of columns[ci].dates) {
                            if (toDateStr(cd) === taskStartStr) {
                                startColIdx = ci;
                                break;
                            }
                        }
                        if (startColIdx !== -1) break;
                        if (columns[ci].type === 'weekday') {
                            const first = columns[ci].dates[0];
                            const last = columns[ci].dates[columns[ci].dates.length - 1];
                            if (taskStartStr >= toDateStr(first) && taskStartStr <= toDateStr(last)) {
                                startColIdx = ci;
                                break;
                            }
                        }
                    }
                }

                columns.forEach((col, colIdx) => {
                    const isExtra = col.dates.length > 0 && toDateStr(col.dates[0]) > projectEndStr;
                    const cell = document.createElement('div');
                    if (isExtra) {
                        cell.className = 'grid-cell';
                        cell.style.background = '#fafafa';
                        cell.style.pointerEvents = 'none';
                    } else {
                        cell.className = 'grid-cell' + (col.type === 'weekend' ? ' is-weekend-cell' : '');
                    }

                    if (!isExtra && taskStartStr && taskEndStr && colIdx === startColIdx) {
                        let barWidth = 0;
                        for (let ci = startColIdx; ci < columns.length; ci++) {
                            const c = columns[ci];
                            if (c.dates.length === 0) break;
                            const colFirstDate = toDateStr(c.dates[0]);
                            if (colFirstDate > taskEndStr) break;
                            if (colFirstDate > projectEndStr) break;
                            barWidth += c.type === 'weekend' ? WEEKEND_W : CELL_W;
                        }
                        if (barWidth > 0) {
                            const bar = document.createElement('div');
                            bar.className = 'task-bar';
                            bar.style.width = (barWidth - 4) + 'px';
                            bar.style.left = '2px';
							
							const progress = parseFloat(row.dataset.progress) || 0;
							const progressWidth = Math.round(progress) + '%';
							bar.style.background = `linear-gradient(to right, ${barColor} ${progressWidth}, ${barColor}88 ${progressWidth})`;
							
                            bar.style.borderRadius = '4px';
                            bar.style.cursor = 'pointer';
                            bar.addEventListener('click', () => {
                                const taskId = row.dataset.taskId;
                                const taskTitle = row.querySelector('.task-name').textContent.trim();
                                const startStr = row.dataset.start;
                                const endStr = row.dataset.end;
                                const empTaskId = row.dataset.empTaskId || '';
                                const empId = row.dataset.empId || '';
                                const stgTitle = row.dataset.stgTitle || '';
                                openTaskDailyModal(taskId, taskTitle, startStr, endStr, empId, stgTitle, projectTitle, empTaskId);
                            });
                            cell.appendChild(bar);
                        }
                    }
                    grid.appendChild(cell);
                });
            });
        }

        grid.style.gridTemplateColumns = columns.map(col =>
            (col.type === 'weekend' ? WEEKEND_W : CELL_W) + 'px'
        ).join(' ');
    }
}


// SweetAlert2 유틸
const toast = (msg) => {
    Swal.fire({
        html: `<div style="font-size:0.95rem; font-weight:500; text-align:center; display:flex; align-items:center; justify-content:center; min-height:40px;">${msg}</div>`,
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


// 모달 열기 / 닫기
function openTaskModal() {
    document.getElementById('taskModal').style.display = 'flex';
}

function closeTaskModal() {
    document.getElementById('taskModal').style.display = 'none';
}

function closeTaskDailyModal() {
    document.getElementById('taskDailyModal').style.display = 'none';
}


// 이벤트 바인딩
document.addEventListener('DOMContentLoaded', function () {

	projectTitle = document.getElementById('hiddenProjectTitle')?.value || '';
    applyStageColors();
    renderGanttChart();

    document.getElementById('taskModal').addEventListener('click', function (e) {
        if (e.target === this) closeTaskModal();
    });

    document.querySelectorAll('.status-cell').forEach(select => {
        updateStatusStyle(select);
    });

    document.getElementById('modalStageId').addEventListener('change', function () {
        const directRow = document.getElementById('directStageRow');
        directRow.style.display = this.value === 'direct' ? 'flex' : 'none';
        if (this.value !== 'direct') {
            document.getElementById('modalDirectStage').value = '';
        }
    });

    document.getElementById('dailyReason').addEventListener('input', function () {
        this.style.border = '1px solid #d0d5dd';
        document.getElementById('reasonRequired').style.display = 'none';
        document.getElementById('reasonOptional').style.display = 'inline';
    });
});


// 태스크 등록
function submitTask() {
	const projectStatus = document.getElementById('hiddenProjectStatus').value;
	if (projectStatus === '6') {
	    toast('중단된 프로젝트는 task를 추가할 수 없습니다.');
	    return;
	}
	
    let stageId = document.getElementById('modalStageId').value;
    const directStage = document.getElementById('modalDirectStage').value.trim();
    const taskTitle = document.getElementById('modalTaskTitle').value.trim();
    const startDate = document.getElementById('modalStartDate').value;
    const endDate = document.getElementById('modalEndDate').value;
    const taskDesc = document.getElementById('modalTaskDesc').value.trim();
    const empId = document.getElementById('modalMember').value;
    const projectId = document.getElementById('hiddenProjectId').value;
    const isDirect = stageId === 'direct';
    const projectStart = document.getElementById('hiddenProjectStart').value.replace(/\//g, '-');
    const projectEnd = document.getElementById('hiddenProjectEnd').value.replace(/\//g, '-');

    if (!stageId) { toast('단계를 선택해주세요.'); return; }
    if (stageId === 'direct' && !directStage) { toast('단계명을 입력해주세요.'); return; }
	if (!empId) { toast('담당자를 선택해주세요.'); return; }
    if (!taskTitle) { toast('Task명을 입력해주세요.'); return; }
    if (!startDate) { toast('시작일을 입력해주세요.'); return; }
    if (!endDate) { toast('종료일을 입력해주세요.'); return; }
    if (startDate < projectStart) { toast('시작일은 프로젝트 시작일(' + projectStart + ') 이후여야 합니다.'); return; }
    if (endDate > projectEnd) { toast('종료일은 프로젝트 종료일(' + projectEnd + ') 이전이어야 합니다.'); return; }

    if (stageId === 'direct') stageId = null;

    fetch(contextPath + '/projects/task/insert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            projectId: projectId,
            stageId: isDirect ? null : stageId,
            stgTitle: isDirect ? directStage : null,
            empId: empId,
            taskTitle: taskTitle,
            taskStartDate: startDate,
            taskEndDate: endDate,
            taskDescription: taskDesc
        })
    })
    .then(res => {
        if (res.ok) {
            toast('Task가 생성되었습니다.');
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

let editMode = false;
let currentTaskEmpId = '';
let currentTaskId = '';
let currentEmpTaskId = '';
let currentLogMap = {};
let projectTitle = '';

function toggleEditMode() {
	
	const projectStatus = document.getElementById('hiddenProjectStatus').value;
	if (projectStatus === '6') {
	    toast('중단된 프로젝트는 편집할 수 없습니다.');
	    return;
	}
	
    const isManager = document.getElementById('hiddenIsManager').value === 'true';
    if (!isManager) {
        toast('매니저만 편집할 수 있습니다.');
        return;
    }

    editMode = !editMode;
    const btn = document.getElementById('editBtn');

    if (editMode) {
        btn.innerHTML = '<i class="fas fa-check"></i>';
        btn.style.background = '#28a745';
        toast('편집 모드가 활성화되었습니다.');
    } else {
        btn.innerHTML = '<i class="fas fa-pencil-alt"></i>';
        btn.style.background = '';
        toast('편집이 완료되었습니다.');
    }
}

function updateTask(taskId, type) {
    const projectStatus = document.getElementById('hiddenProjectStatus').value;
    if (projectStatus === '6') {
        toast('중단된 프로젝트는 수정할 수 없습니다.');
        return;
    }
	
    if (!editMode) {
        toast('편집 모드를 활성화해주세요.');

        const row = document.querySelector(`tr[data-task-id="${taskId}"]`);
        if (type === 'startDate') {
            row.querySelectorAll('.cell-date')[0].value = row.dataset.start;
        } else if (type === 'endDate') {
            row.querySelectorAll('.cell-date')[1].value = row.dataset.end;
        } else if (type === 'status') {
            const statusSelect = row.querySelector('.status-cell');
            statusSelect.value = statusSelect.dataset.status;
        } else if (type === 'assignee') {
            const assigneeSelect = row.querySelector('.cell-assignee');
            assigneeSelect.value = assigneeSelect.dataset.empId;
        }
        return;
    }

    const row = document.querySelector(`tr[data-task-id="${taskId}"]`);
	const dates = row.querySelectorAll('.cell-date');
	const startDate = dates[0]._flatpickr && dates[0]._flatpickr.selectedDates[0]
	    ? dates[0]._flatpickr.formatDate(dates[0]._flatpickr.selectedDates[0], 'Y-m-d')
	    : dates[0].value;
	const endDate = dates[1]._flatpickr && dates[1]._flatpickr.selectedDates[0]
	    ? dates[1]._flatpickr.formatDate(dates[1]._flatpickr.selectedDates[0], 'Y-m-d')
	    : dates[1].value;
    const empId = row.querySelector('.cell-assignee').value;
    const statusSelect = row.querySelector('.status-cell');
    const today = new Date().toISOString().split('T')[0];

    const projectStart = document.getElementById('hiddenProjectStart').value.replace(/\//g, '-');
    const projectEnd = document.getElementById('hiddenProjectEnd').value.replace(/\//g, '-');

    if (type === 'startDate' || type === 'endDate') {
        if (startDate < projectStart) {
            toast('시작일은 프로젝트 시작일(' + projectStart + ') 이후여야 합니다.');
            dates[0].value = row.dataset.start;
            return;
        }
        if (endDate > projectEnd) {
            toast('종료일은 프로젝트 종료일(' + projectEnd + ') 이전이어야 합니다.');
            dates[1].value = row.dataset.end;
            return;
        }
    }

    let taskStatus = statusSelect.value;
    if (type === 'startDate' || type === 'endDate') {
        if (startDate && endDate) {
            if (endDate < today) {
                taskStatus = '4';
            } else if (startDate <= today && endDate >= today) {
                taskStatus = '2';
            } else {
                taskStatus = '1';
            }
            statusSelect.value = taskStatus;
            updateStatusStyle(statusSelect);
        }
    }

    fetch(contextPath + '/projects/task/update', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify([{
            taskId,
            taskStartDate: startDate,
            taskEndDate: endDate,
            taskStatus: taskStatus,
            empId: empId,
            projectId: document.getElementById('hiddenProjectId').value
        }])
    })
    .then(res => {
        if (!res.ok) {
            toast('저장 실패.');
        } else {
			
			if (startDate) row.dataset.start = startDate;
			if (endDate) row.dataset.end = endDate;

			const taskNameTd = row.querySelector('.task-name');
			if (taskNameTd) {
			    const onclick = taskNameTd.getAttribute('onclick');
			    if (onclick) {  // ← null 체크 추가
			        let updated = onclick.replace(
			            /openTaskDailyModal\('([^']*)',\s*'([^']*)',\s*'([^']*)',\s*'([^']*)'/,
			            `openTaskDailyModal('$1', '$2', '${startDate}', '${endDate}'`
			        );
			        updated = updated.replace(
			            /openTaskDailyModal\('([^']*)',\s*'([^']*)',\s*'([^']*)',\s*'([^']*)',\s*'([^']*)'/,
			            `openTaskDailyModal('$1', '$2', '$3', '$4', '${empId}'`
			        );
			        taskNameTd.setAttribute('onclick', updated);
			    }
			}

            applyStageColors();
            renderGanttChart();
        }
    })
    .catch(err => console.error(err));
}

function updateStatusStyle(select) {
    select.dataset.status = select.value;
    const colors = {
        '1': '#1d2939',
        '2': '#0d6efd',
        '3': '#fd7e14',
        '4': '#198754',
        '5': '#dc3545',
        '6': '#adb5bd'
    };
    select.style.color = colors[select.value] || '#1d2939';
}

function openTaskDailyModal(taskId, title, startStr, endStr, assigneeEmpId, stgTitle, projectTitle, empTaskId) {
	if (!startStr || !endStr) {
	    toast('시작일과 종료일을 먼저 입력해주세요.');
	    return;
	}
    currentTaskId = taskId;
    currentTaskEmpId = assigneeEmpId;
    currentEmpTaskId = empTaskId;

    document.getElementById('dailyModalProjectTitle').textContent = projectTitle || '프로젝트';
    const stageEl = document.getElementById('dailyModalStage');
    if (stgTitle) {
        stageEl.textContent = stgTitle;
        stageEl.style.display = '';
    } else {
        stageEl.textContent = '';
        stageEl.style.display = 'none';
    }
    document.getElementById('dailyModalTitle').textContent = title;
    document.getElementById('dailyModalPeriod').textContent = startStr + ' ~ ' + endStr;

    const grid = document.getElementById('dailyGrid');
    grid.innerHTML = '';

    const start = new Date(startStr);
    const end = new Date(endStr);

    const totalDays = Math.round((end - start) / (1000 * 60 * 60 * 24)) + 1;
    const isLong = totalDays > 62;

    const CELL_W = isLong ? 15 : 40;
    const WEEKEND_W = isLong ? 5 : 40;

    function toStr(d) {
        return d.getFullYear() + '-' +
            String(d.getMonth()+1).padStart(2,'0') + '-' +
            String(d.getDate()).padStart(2,'0');
    }

    const allDates = [];
    const cur = new Date(start);
    while (cur <= end) {
        allDates.push(new Date(cur));
        cur.setDate(cur.getDate() + 1);
    }

    grid.style.gridTemplateColumns = allDates.map(d => {
        const isWe = d.getDay() === 0 || d.getDay() === 6;
        return (isWe ? WEEKEND_W : CELL_W) + 'px';
    }).join(' ');

    allDates.forEach(d => {
        const isWe = d.getDay() === 0 || d.getDay() === 6;
        const cell = document.createElement('div');
        cell.style.cssText = `
            border:1px solid #eaecf0;
            height:40px; background:${isWe ? '#e8e8e8' : '#f9fafb'};
            display:flex; align-items:center; justify-content:center;
            font-weight:700; font-size:0.72rem; color:#667085;
        `;
        if (!isLong || !isWe) {
            cell.textContent = (d.getMonth()+1) + '/' + d.getDate();
        }
        grid.appendChild(cell);
    });

	const statusStyle = {
	    'F': { bg: '#f0fdf4', color: '#22c55e', text: '완료' },
	    'I': { bg: '#eff6ff', color: '#3b82f6', text: '진행' },
	    'S': { bg: '#fef2f2', color: '#f87171', text: '중단' }
	};

	fetch(contextPath + '/projects/task/dailylist?empTaskId=' + empTaskId)
	    .then(res => res.json())
	    .then(logs => {
	        const logMap = {};
	        logs.forEach(log => {
	            logMap[log.logDate] = { status: log.logStatus, reason: log.logReason };
	        });

			currentLogMap = logMap;

	        const tooltipEl = document.getElementById('dailyTooltipText');

	        allDates.forEach(d => {
	            const isWe = d.getDay() === 0 || d.getDay() === 6;
	            const dateStr = toStr(d);
	            const logData = logMap[dateStr];
	            const st = logData ? statusStyle[logData.status] : null;
	            const reason = logData ? logData.reason : null;

	            const cell = document.createElement('div');
	            cell.style.cssText = `
	                border:1px solid #eaecf0; height:60px;
	                background:${isWe ? '#f9fafb' : '#fff'};
	                display:flex; flex-direction:column; align-items:center; justify-content:center;
	                cursor:${isWe ? 'default' : 'pointer'}; transition:all 0.2s;
	                gap: 4px;
	            `;

	            if (st) {
	                const dot = document.createElement('div');
	                dot.style.cssText = `
	                    width: 10px; height: 10px; border-radius: 50%;
	                    background: ${st.color}; box-shadow: 0 0 4px ${st.color}44;
	                `;
	                const text = document.createElement('span');
	                text.textContent = st.text;
	                text.style.cssText = `
	                    font-size: 0.65rem; font-weight: 700; color: ${st.color};
	                `;
	                cell.appendChild(dot);
	                cell.appendChild(text);
	                cell.style.background = isWe ? '#f2f4f7' : '#fcfdfd';
	            }

	            if (!isWe) {
	                cell.addEventListener('mouseenter', () => {
	                    cell.style.background = '#f0f4ff';
	                    if (st && reason) {
	                        tooltipEl.textContent = `${st.text} - ${reason}`;
	                    } else if (st) {
	                        tooltipEl.textContent = `${st.text}`;
	                    } else {
	                        tooltipEl.textContent = `해당 날짜는 진행 상태가 등록되지 않았습니다.`;
	                    }
	                });
	                cell.addEventListener('mouseleave', () => {
	                    cell.style.background = st ? '#fcfdfd' : '#fff';
	                    tooltipEl.textContent = '해당 날짜의 진행 상태와 사유를 확인하세요.';
	                });
	                cell.addEventListener('click', () => openDailyCheckModal(dateStr));
	            }
	            grid.appendChild(cell);
	        });
	    })
	    .catch(err => {
	        console.error('dailylist 조회 실패:', err);
	        allDates.forEach(d => {
	            const isWe = d.getDay() === 0 || d.getDay() === 6;
	            const cell = document.createElement('div');
	            cell.style.cssText = `
	                border:1px solid #eaecf0; height:60px;
	                background:${isWe ? '#f0f0f0' : '#fff'};
	                display:flex; align-items:center; justify-content:center;
	                cursor:${isWe ? 'default' : 'pointer'};
	            `;
	            if (!isWe) cell.addEventListener('click', () => openDailyCheckModal(toStr(d)));
	            grid.appendChild(cell);
	        });
	    });

    document.getElementById('taskDailyModal').style.display = 'flex';
}

function closeTaskDailyModal() {
    document.getElementById('taskDailyModal').style.display = 'none';
}

let selectedDailyType = null;

function openDailyCheckModal(dateStr) {

	const projectStatus = document.getElementById('hiddenProjectStatus').value;
	if (projectStatus === '6') {
	    toast('중단된 프로젝트는 데일리 체크를 할 수 없습니다.');
	    return;
	}

    const loginEmpId = document.getElementById('hiddenLoginEmpId').value;
    if (loginEmpId !== currentTaskEmpId) {
        toast('담당자만 체크할 수 있습니다.');
        return;
    }

	const logData = currentLogMap ? currentLogMap[dateStr] : null;
	    if (logData) {
	        if (logData.status === 'F' || logData.status === 'S') {
	            toast('완료 또는 중단된 날짜는 수정할 수 없습니다.');
	            return;
	        }
	        if (logData.status === 'I') {
	            Swal.fire({
	                text: '진행에서 완료로 수정하게 되면 수정이 불가합니다. 수정하시겠습니까?',
	                icon: 'question',
	                showCancelButton: true,
					confirmButtonColor: '#4e73df',
					cancelButtonColor: '#fff',
	                confirmButtonText: '수정',
	                cancelButtonText: '취소',
	                width: '320px',
	            }).then(result => {
	                if (result.isConfirmed) openDailyCheckModalInner(dateStr);
	            });
	            return;
	        }
	    }
	    openDailyCheckModalInner(dateStr);
	}

	function openDailyCheckModalInner(dateStr) {
	    selectedDailyType = null;
	    document.getElementById('checkDate').textContent = dateStr;
	    document.getElementById('dailyReason').value = '';
	    document.getElementById('dailyReason').style.border = '1px solid #d0d5dd';
	    document.getElementById('reasonRequired').style.display = 'none';
	    document.getElementById('reasonOptional').style.display = 'inline';
	    document.querySelectorAll('.daily-check-btn').forEach(b => b.classList.remove('selected'));
	    document.getElementById('taskDailyCheckModal').style.display = 'flex';
	}

function selectDailyType(type, btn) {
    selectedDailyType = type;
    document.querySelectorAll('.daily-check-btn').forEach(b => b.classList.remove('selected'));
    btn.classList.add('selected');

    const reasonLabel = document.getElementById('reasonRequired');
    const reasonOptional = document.getElementById('reasonOptional');
    const reasonTextarea = document.getElementById('dailyReason');

    if (type === 'progress' || type === 'stop') {
        reasonLabel.style.display = 'inline';
        reasonOptional.style.display = 'none';
        reasonTextarea.style.border = '1px solid #f59e0b';
        reasonTextarea.style.background = '#fffbeb';
        reasonTextarea.placeholder = '사유를 입력해주세요. (필수)';
        reasonTextarea.focus();
    } else {
        reasonLabel.style.display = 'none';
        reasonOptional.style.display = 'inline';
        reasonTextarea.style.border = '1px solid #d0d5dd';
        reasonTextarea.style.background = '#fff';
        reasonTextarea.placeholder = '사유를 입력해주세요. (선택)';
    }
}

function submitDailyCheck() {
    if (!selectedDailyType) {
        toast('오늘 Task 진행 상태와 사유 선택해주세요.');
        return;
    }

    const reason = document.getElementById('dailyReason').value.trim();
    if ((selectedDailyType === 'progress' || selectedDailyType === 'stop') && !reason) {
        document.getElementById('reasonRequired').style.display = 'inline';
        document.getElementById('reasonOptional').style.display = 'none';
        document.getElementById('dailyReason').style.border = '1px solid #dc2626';
        document.getElementById('dailyReason').focus();
        toast('사유를 입력해주세요.');
        return;
    }

	if (selectedDailyType === 'done' || selectedDailyType === 'stop') {
	        const typeText = selectedDailyType === 'done' ? '완료' : '중단';
	        Swal.fire({
	            text: `${typeText}로 기록하면 수정할 수 없습니다. 저장하시겠습니까?`,
	            icon: 'warning',
	            showCancelButton: true,
	            confirmButtonColor: '#4e73df',
	            cancelButtonColor: '#fff',
	            confirmButtonText: '저장',
	            cancelButtonText: '취소',
	            width: '320px',
	        }).then(result => {
	            if (result.isConfirmed) submitDailyCheckRequest();
	        });
	        return;
	    }

	    submitDailyCheckRequest();
	}

	function submitDailyCheckRequest() {
	    const dateStr = document.getElementById('checkDate').textContent;
	    const reason = document.getElementById('dailyReason').value.trim();

	    fetch(contextPath + '/projects/task/dailyinsert', {
	        method: 'POST',
	        headers: { 'Content-Type': 'application/json' },
	        body: JSON.stringify({
	            empTaskId: currentEmpTaskId,
	            taskId: currentTaskId,
	            projectId: document.getElementById('hiddenProjectId').value,
	            logDate: dateStr,
	            logStatus: selectedDailyType === 'done' ? 'F' : selectedDailyType === 'progress' ? 'I' : 'S',
	            logReason: reason
	        })
	    })
	    .then(res => {
	        if (res.ok) {
	            const msg = selectedDailyType === 'done' ? '완료' : selectedDailyType === 'progress' ? '진행' : '중단';
	            toast(msg + '으로 기록되었습니다.');
	            setTimeout(() => {
	                closeDailyCheckModal();
	                closeTaskDailyModal();
	                location.reload();
	            }, 1500);
	        } else {
	            toast('저장 실패. 다시 시도해주세요.');
	        }
	    })
	    .catch(err => {
	        console.error(err);
	        toast('서버 오류가 발생했습니다.');
	    });
	}

function closeDailyCheckModal() {
    document.getElementById('taskDailyCheckModal').style.display = 'none';
    document.getElementById('dailyReason').value = '';
    document.getElementById('dailyReason').style.border = '1px solid #d0d5dd';
    document.getElementById('reasonRequired').style.display = 'none';
    document.getElementById('reasonOptional').style.display = 'inline';
    document.querySelectorAll('.daily-check-btn').forEach(b => b.classList.remove('selected'));
    selectedDailyType = null;
}