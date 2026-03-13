<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Spring</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/board.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css" type="text/css">
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<main>
	<!-- Page Title -->
	<div class="page-title">
		<div class="container align-items-center" data-aos="fade-up">
			<h1>자유 게시판</h1>
			<div class="page-title-underline-accent"></div>
		</div>
	</div>
    
	<!-- Page Content -->    
	<div class="section">
		<div class="container" data-aos="fade-up" data-aos-delay="100">
			<div class="row justify-content-center">
				<div class="col-md-10 board-section my-4 p-5">
				
					<div class="row py-1 mb-2">
						<div class="col-md-6 align-self-center">
							<span class="small-title">글목록</span> <span class="dataCount">${dataCount}개(${page}/${total_page} 페이지)</span>
						</div>	
						<div class="col-md-6 align-self-center text-end">
						</div>
					</div>				
				
					<table class="table table-hover board-list">
						<thead>
							<tr>
								<th class="num">번호</th>
								<th class="subject">제목</th>
								<th class="name">글쓴이</th>
								<th class="date">작성일</th>
								<th class="hit">조회수</th>
								<th class="file">첨부</th>
							</tr>
						</thead>
						<tbody>
							<c:forEach var="dto" items="${list}" varStatus="status">
								<tr>
									<td>${dataCount - (page-1) * size - status.index}</td>
									<td class="left">
										<div class="text-wrap">
											<a href="${articleUrl}&num=${dto.num}" class="text-reset"><c:out value="${dto.subject}"/></a>
										</div>
										<c:if test="${dto.replyCount!=0}">(${dto.replyCount})</c:if>
									</td>
									<td>${dto.name}</td>
									<td>${dto.reg_date}</td>
									<td>${dto.hitCount}</td>
									<td>
										<c:if test="${not empty dto.saveFilename}">
											<a href="${pageContext.request.contextPath}/bbs/download?num=${dto.num}" class="text-reset"><i class="bi bi-file-arrow-down"></i></a>
										</c:if>
									</td>
								</tr>
							</c:forEach>
						</tbody>					
					</table>
				
					<div class="page-navigation">
						${dataCount == 0 ? "등록된 게시글이 없습니다" : paging}
					</div>

					<div class="row mt-3">
						<div class="col-md-3">
							<button type="button" class="btn-default" onclick="location.href='${pageContext.request.contextPath}/bbs/list';" title="새로고침"><i class="bi bi-arrow-clockwise"></i></button>
						</div>
						<div class="col-md-6 text-center">
							<form name="searchForm" class="form-search">
								<select name="schType">
									<option value="all" ${schType=="all"?"selected":""}>제목+내용</option>
									<option value="name" ${schType=="name"?"selected":""}>글쓴이</option>
									<option value="reg_date" ${schType=="reg_date"?"selected":""}>작성일</option>
									<option value="subject" ${schType=="subject"?"selected":""}>제목</option>
									<option value="content" ${schType=="content"?"selected":""}>내용</option>
								</select>
								<input type="text" name="kwd" value="${kwd}">
								<button type="button" class="btn-default" onclick="searchList();"><i class="bi bi-search"></i></button>
							</form>
						</div>
						<div class="col-md-3 text-end">
							<button type="button" class="btn-accent btn-md" onclick="location.href='${pageContext.request.contextPath}/bbs/write';">글쓰기</button>
						</div>
					</div>
				
				</div>
			</div>
		</div>
	</div>
</main>

<script type="text/javascript">
// 검색 키워드 입력란에서 엔터를 누른 경우 서버 전송 막기 
document.addEventListener('DOMContentLoaded', () => {
	const inputEL = document.querySelector('form input[name=kwd]');
	
	inputEL.addEventListener('keydown', ev => {
		if(ev.key === 'Enter') {
			ev.preventDefault();
	    	
			searchList();
		}
	});
});

function searchList() {
	const f = document.searchForm;
	if(! f.kwd.value.trim()) {
		return;
	}
	
	// form 요소는 FormData를 이용하여 URLSearchParams 으로 변환
	const formData = new FormData(f);
	const params = new URLSearchParams(formData).toString();
	
	const url = '${pageContext.request.contextPath}/bbs/list?' + params;
	location.href = url;
}
</script>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>