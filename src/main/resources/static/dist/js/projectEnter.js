document.addEventListener('keydown', function(e) {
    if (e.key !== 'Enter') return;
    const tag = e.target.tagName.toLowerCase();
    if (tag === 'input') {
        // step4 input은 제외 (자체 엔터 로직 있음)
        if (e.target.classList.contains('sub-plan-input') || 
            e.target.classList.contains('phase-title-input')) return;
        e.preventDefault();
        e.stopPropagation();
    }
});