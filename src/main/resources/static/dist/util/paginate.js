export function getPagination(currentPage, totalPage, blockSize = 10) {
    // 현재 페이지가 속한 블록의 시작과 끝 계산
	const currentBlock = Math.ceil(currentPage / blockSize);
	let startPage = (currentBlock - 1) * blockSize + 1;
	let endPage = startPage + blockSize - 1;

	if (endPage > totalPage) endPage = totalPage;

    // 페이지 번호 배열 생성
	const pages = [];
	for (let i = startPage; i <= endPage; i++) {
		pages.push(i);
	}

    // 이동 버튼 활성화 여부 및 대상 페이지 계산
	return {
		pages,
		
		currentPage,
		totalPage,
		
		// 1페이지로 이동
		firstPage: 1,
		
		// 이전 블록의 끝 페이지로 이동 (예: 11~20 -> 10)
        prevBlockPage: startPage > 1 ? startPage - 1 : null,
		// 10페이지 전
		// prevBlockPage: currentPage - blockSize < 1 ? 1 : currentPage - blockSize,
		
		// 다음 블록의 시작 페이지로 이동 (예: 1~10 -> 11)
		nextBlockPage: endPage < totalPage ? endPage + 1 : null,
		// 10페이지 다음
		// nextBlockPage: currentPage + blockSize > totalPage ? totalPage : currentPage + blockSize,
		
		// 마지막 페이지로 이동
		lastPage: totalPage,
		
		// 버튼 노출 여부
		showPrev: startPage > 1,
		showNext: endPage < totalPage
	};
}
