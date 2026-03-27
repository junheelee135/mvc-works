(function () {
    const container = document.getElementById('phaseContainer');
	
	// 1. 단순 경고용 (alert 대체)
	    const toast = (msg) => {
			Swal.fire({
				title: '알림',
				html: `<div style="font-size: 0.95rem; font-weight: 500; margin-top: 10px;">${msg}</div>`,
				// position: 'top',
				showConfirmButton: false,
				timer: 5000,
				timerProgressBar: false,
				text: msg,
				iconColor: '#4e73df',
				width: '320px',
				padding: '1rem',
				confirmButtonColor: '#4f86c6',
				confirmButtonText: '확인'
	        });
	    };

	    // 2. 선택 확인용 (confirm 대체)
	    const ask = (msg, callback) => {
	        Swal.fire({
	            text: msg,
	            icon: 'question',
	            showCancelButton: true,
	            confirmButtonColor: '#4e73df',
	            cancelButtonColor: '#888888',
	            confirmButtonText: '확인',
	            cancelButtonText: '취소',
	            width: '320px',
	            padding: '1.2rem'
	        }).then((result) => {
	            if (result.isConfirmed) callback();
	        });
	    };
		
    // 기본 5단계 데이터 (초기화용)
    const DEFAULT_PHASES = [
        '요구사항 분석 및 기획',
        '설계 (UI/UX, 시스템)',
        '개발 및 구현',
        '테스트(단위 / 통합)',
        '배포(배포 / 유지보수)'
    ];

    /* 세부 계획 item 생성 */
    function createSubItem(value) {
        const newItem = document.createElement('div');
        newItem.className = 'sub-plan-item';

        const input = document.createElement('input');
        input.type = 'text';
        input.className = 'sub-plan-input';
        input.placeholder = '세부 계획을 입력하세요';
        if (value) input.value = value;

        const delBtn = document.createElement('button');
        delBtn.className = 'btn-sub-delete';
        delBtn.title = '삭제';
        delBtn.innerHTML = '<i class="fas fa-times"></i>';

        newItem.appendChild(input);
        newItem.appendChild(delBtn);
        return newItem;
    }

    /* 단계 카드 생성 (신규 추가용) */
    function createPhaseCard(count, titleValue) {
        const card = document.createElement('div');
        card.className = 'phase-card';

        const header = document.createElement('div');
        header.className = 'phase-header';

        const titleWrap = document.createElement('div');
        titleWrap.className = 'phase-title';
        titleWrap.style.cssText = 'display:flex;align-items:center;gap:8px;flex:1';

        const numSpan = document.createElement('span');
        numSpan.className = 'phase-number';
        numSpan.textContent = count;

        const titleInput = document.createElement('input');
        titleInput.type = 'text';
        titleInput.className = 'phase-title-input';
        titleInput.placeholder = '단계 이름을 입력하세요';
        if (titleValue) titleInput.value = titleValue;

        titleWrap.appendChild(numSpan);
        titleWrap.appendChild(titleInput);

        const delBtn = document.createElement('button');
        delBtn.className = 'btn-delete';
        delBtn.title = '삭제';
        delBtn.innerHTML = '<i class="fas fa-minus"></i>';

        header.appendChild(titleWrap);
        header.appendChild(delBtn);

        const subList = document.createElement('div');
        subList.className = 'sub-plan-list';

        const footer = document.createElement('div');
        footer.className = 'phase-footer';

        const addSubBtn = document.createElement('button');
        addSubBtn.className = 'btn-add-sub';
        addSubBtn.innerHTML = '<i class="fas fa-plus me-1"></i>';

        const doneBtn = document.createElement('button');
        doneBtn.className = 'btn-phase-done';
        doneBtn.title = '완료';
        doneBtn.innerHTML = '<i class="fas fa-check"></i>';

        footer.appendChild(addSubBtn);
        footer.appendChild(doneBtn);
        card.appendChild(header);
        card.appendChild(subList);
        card.appendChild(footer);

        return card;
    }

    /* 단계 번호 재정렬 */
    function reorderPhaseNumbers() {
        container.querySelectorAll('.phase-number').forEach(function(el, i) {
            el.textContent = i + 1;
        });
    }

    /* 완료 상태에 따라 +/- 버튼 잠금/해제 */
    function toggleCardLock(card, lock) {
        // 단계 삭제(-) 버튼
        const delBtn = card.querySelector('.btn-delete');
        if (delBtn) {
            delBtn.disabled = lock;
            delBtn.style.opacity = lock ? '0.3' : '';
            delBtn.style.cursor  = lock ? 'not-allowed' : '';
        }
        // 세부계획 추가(+) 버튼
        const addSubBtn = card.querySelector('.btn-add-sub');
        if (addSubBtn) {
            addSubBtn.disabled = lock;
            addSubBtn.style.opacity = lock ? '0.3' : '';
            addSubBtn.style.cursor  = lock ? 'not-allowed' : '';
        }
        // 세부계획 삭제(x) 버튼
        card.querySelectorAll('.btn-sub-delete').forEach(function(btn) {
            btn.disabled = lock;
            btn.style.opacity = lock ? '0.3' : '';
            btn.style.cursor  = lock ? 'not-allowed' : '';
        });
    }

    /* 엔터 키 이벤트 위임 */
    container.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        e.preventDefault();
        e.stopImmediatePropagation();

        if (e.target.classList.contains('sub-plan-input')) {
            const currentItem = e.target.closest('.sub-plan-item');
            const newItem = createSubItem('');
            currentItem.after(newItem);
            newItem.querySelector('input').focus();
            return;
        }

        if (e.target.classList.contains('phase-title-input')) {
            const card = e.target.closest('.phase-card');
            const list = card.querySelector('.sub-plan-list');
            const newItem = createSubItem('');
            list.appendChild(newItem);
            newItem.querySelector('input').focus();
            return;
        }
    });

    /* 클릭 이벤트 위임 */
    container.addEventListener('click', function (e) {

        // 세부 계획 추가 버튼
        if (e.target.closest('.btn-add-sub')) {
            const btn = e.target.closest('.btn-add-sub');
            if (btn.disabled) return;
            const list = btn.closest('.phase-footer').previousElementSibling;
            const newItem = createSubItem('');
            list.appendChild(newItem);
            newItem.querySelector('input').focus();
            return;
        }

        // 세부 계획 삭제 버튼
        if (e.target.closest('.btn-sub-delete')) {
            const btn = e.target.closest('.btn-sub-delete');
            if (btn.disabled) return;
            btn.closest('.sub-plan-item').remove();
            return;
        }

        // 단계 완료(체크) 버튼
        if (e.target.closest('.btn-phase-done')) {
            const btn  = e.target.closest('.btn-phase-done');
            const card = btn.closest('.phase-card');
            const isDone = btn.classList.contains('done');

            // 체크 시: 세부 계획이 하나도 없으면 막기
            if (!isDone) {
                const subInputs = card.querySelectorAll('.sub-plan-input');
                const hasContent = [...subInputs].some(inp => inp.value.trim() !== '');
                if (!hasContent) {
                    toast('세부 계획을 최소 1개 이상 입력해야 완료할 수 있습니다.');
                    return;
                }
            }

            btn.classList.toggle('done');
            card.classList.toggle('done-card');

            // 완료 시 input 비활성화 + +/- 버튼 잠금
            // 취소 시 input 활성화 + +/- 버튼 해제
            const nowDone = btn.classList.contains('done');
            card.querySelectorAll('.sub-plan-input').forEach(function(input) {
                input.disabled = nowDone;
            });
            toggleCardLock(card, nowDone);
            return;
        }

        // 단계 카드 삭제 버튼
        if (e.target.closest('.btn-delete')) {
            const btn = e.target.closest('.btn-delete');
            if (btn.disabled) return;
            btn.closest('.phase-card').remove();
            reorderPhaseNumbers();
            return;
        }
    });

    /* 단계 추가 버튼 */
    document.getElementById('btnAddPhase').addEventListener('click', function () {
        const count = container.querySelectorAll('.phase-card').length + 1;
        const card  = createPhaseCard(count, '');
        container.appendChild(card);
        card.querySelector('.phase-title-input').focus();
    });

    /* 초기화 버튼 */
	document.getElementById('btnResetPhase').addEventListener('click', function () {
	        ask('단계를 기본값으로 초기화하시겠습니까?\n입력한 내용이 모두 삭제됩니다.', function() {
	            container.innerHTML = '';
	            DEFAULT_PHASES.forEach(function(title, i) {
	                const card = createPhaseCard(i + 1, title);
	                const titleWrap = card.querySelector('.phase-title');
	                if (titleWrap) {
	                    titleWrap.style.cssText = '';
	                    titleWrap.innerHTML = '<span class="phase-number">' + (i + 1) + '</span> ' + title;
	                }
	                container.appendChild(card);
	            });
	        });
	    }); 

	})();
