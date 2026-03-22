// 공통 날짜 처리 - flatpickr 적용
// task.jsp, projectEnter.jsp 등 날짜 input이 있는 모든 페이지에서 사용

document.addEventListener('DOMContentLoaded', function () {
    initDatePickers();
});

function initDatePickers() {
    document.querySelectorAll('input[type=date]').forEach(function (input) {
        if (input._flatpickr) return;

        const currentValue = input.value;

		flatpickr(input, {
		    locale: 'ko',
		    dateFormat: 'Y-m-d',
		    defaultDate: currentValue || null,
		    disableMobile: true,
		    allowInput: false,

		    // 프로젝트 시작일/종료일 범위 + 주말 비활성화
			disable: [
			    function (date) {
			        if (date.getDay() === 0 || date.getDay() === 6) return true;

			        const projectStartEl = document.getElementById('hiddenProjectStart');
			        const projectEndEl = document.getElementById('hiddenProjectEnd');

			        if (projectStartEl && projectEndEl) {
			            const projectStart = new Date(projectStartEl.value.replace(/\//g, '-'));
			            const projectEnd = new Date(projectEndEl.value.replace(/\//g, '-'));
			            // 시간 제거하고 날짜만 비교
			            projectStart.setHours(0, 0, 0, 0);
			            projectEnd.setHours(0, 0, 0, 0);
			            date.setHours(0, 0, 0, 0);
			            if (date < projectStart || date > projectEnd) return true;
			        }

			        return false;
			    }
			],

            onReady: function (selectedDates, dateStr, instance) {
                setDefaultMonth(instance);
            },
            onOpen: function (selectedDates, dateStr, instance) {
                setDefaultMonth(instance);
            },

			onChange: function (selectedDates, dateStr, instance) {
			    const nativeInput = instance.input;
			    nativeInput.value = dateStr;

			    // data-task-id, data-type으로 updateTask 직접 호출
			    const taskId = nativeInput.getAttribute('data-task-id');
			    const type = nativeInput.getAttribute('data-type');
			    if (taskId && type) {
			        updateTask(taskId, type);
			    } else {
			        const event = new Event('change', { bubbles: true });
			        nativeInput.dispatchEvent(event);
			    }
			}
        });

        if (currentValue) {
            input._flatpickr.setDate(currentValue, false);
        }
    });
}

// 이전 task 종료일 기준으로 달력 시작 월 설정
function setDefaultMonth(instance) {
    const input = instance.input;

    if (instance.selectedDates.length > 0) return;

    const row = input.closest('tr');
    if (!row) return;

    // flatpickr가 type을 text로 바꾸므로 .cell-date 클래스로 찾기
    const prevRow = row.previousElementSibling;
    if (prevRow) {
        const prevEndInput = prevRow.querySelectorAll('.cell-date')[1];
        if (prevEndInput && prevEndInput._flatpickr && prevEndInput._flatpickr.selectedDates.length > 0) {
            const prevEndDate = prevEndInput._flatpickr.selectedDates[0];
            instance.changeYear(prevEndDate.getFullYear());
            instance.changeMonth(prevEndDate.getMonth() - instance.currentMonth, true);
            return;
        }
    }

    // 같은 행 내에서 다른 날짜 참조
    const dates = row.querySelectorAll('.cell-date');
    dates.forEach(function (d) {
        if (d !== input && d._flatpickr && d._flatpickr.selectedDates.length > 0) {
            const refDate = d._flatpickr.selectedDates[0];
            instance.changeYear(refDate.getFullYear());
            instance.changeMonth(refDate.getMonth() - instance.currentMonth, true);
        }
    });
}

// 동적으로 추가된 input에도 flatpickr 적용 (MutationObserver)
const observer = new MutationObserver(function () {
    initDatePickers();
});

observer.observe(document.body, { childList: true, subtree: true });