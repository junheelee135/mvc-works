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
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/paginate.css" type="text/css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/board.css" type="text/css">
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

					<div class="pb-2">
						<span class="small-title">상세정보</span>
					</div>
									
					<table class="table board-article">
						<thead>
							<tr>
								<td colspan="2" class="text-center">
									<c:out value="${dto.subject}"/>
								</td>
							</tr>
						</thead>

						<tbody>
							<tr>
								<td width="50%">
									작성자 : ${dto.name}
								</td>
								<td width="50%" class="text-end">
									작성일 : ${dto.reg_date} | 조회 ${dto.hitCount}
								</td>
							</tr>
							
							<tr>
								<td colspan="2" valign="top" height="200" class="article-content" style="border-bottom: none;">
									${dto.content}
								</td>
							</tr>

							<tr>
								<td colspan="2" class="text-center p-3" style="border-bottom: none;">
									<button type="button" class="btn-default btnSendBoardLike" title="좋아요"><i class="bi ${isUserLiked ? 'bi-heart-fill text-danger' : 'bi-heart' }"></i>&nbsp;&nbsp;<span id="boardLikeCount">${dto.boardLikeCount}</span></button>
								</td>
							</tr>

							<tr>
								<td colspan="2">
									<c:if test="${not empty dto.saveFilename}">
										<p class="border text-secondary my-1 p-2">
											<i class="bi bi-folder2-open"></i>
											<a href="${pageContext.request.contextPath}/bbs/download?num=${dto.num}">${dto.originalFilename}</a>
										</p>
									</c:if>
								</td>
							</tr>

							<tr>
								<td colspan="2">
									이전글 : 
									<c:if test="${not empty prevDto}">
										<a href="${pageContext.request.contextPath}/bbs/article?${query}&num=${prevDto.num}"><c:out value="${prevDto.subject}"/></a>
									</c:if>
								</td>
							</tr>
							<tr>
								<td colspan="2">
									다음글 : 
									<c:if test="${not empty nextDto}">
										<a href="${pageContext.request.contextPath}/bbs/article?${query}&num=${nextDto.num}"><c:out value="${nextDto.subject}"/></a>
									</c:if>
								</td>
							</tr>
						</tbody>
					</table>

					<div class="row mb-3">
						<sec:authentication property="principal.member.member_id" var="member_id"/>
						<c:set var="isStaff" value="false" />
						<sec:authorize access="hasAnyRole('ADMIN', 'EMP')">
							<c:set var="isStaff" value="true" />
						</sec:authorize>
						
						<div class="col-md-6 align-self-center">
							<c:choose>
								<c:when test="${member_id==dto.member_id}">
									<button type="button" class="btn-default" onclick="location.href='${pageContext.request.contextPath}/bbs/update?num=${dto.num}&page=${page}';">수정</button>
								</c:when>
								<c:otherwise>
									<button type="button" class="btn-default btnPostsReport" data-num="${dto.num}">신고</button>
								</c:otherwise>
							</c:choose>
							<c:choose>
								<c:when test="${member_id==dto.member_id || isStaff}">
									<button type="button" class="btn-default" onclick="deleteOk();">삭제</button>
								</c:when>
								<c:otherwise>
									<button type="button" class="btn-default" disabled>삭제</button>
								</c:otherwise>
							</c:choose>
						</div>
						<div class="col-md-6 align-self-center text-end">
							<button type="button" class="btn-default" onclick="location.href='${pageContext.request.contextPath}/bbs/list?${query}';">리스트</button>
						</div>
					</div>
					
				</div>
			</div>
		</div>
	</div>
</main>

<c:if test="${member_id==dto.member_id || isStaff}">
	<script type="text/javascript">
		function deleteOk() {
		    if(confirm('게시글을 삭제 하시 겠습니까 ? ')) {
			    let params = 'num=${dto.num}&${query}';
			    let url = '${pageContext.request.contextPath}/bbs/delete?' + params;
		    	location.href = url;
		    }
		}
	</script>
</c:if>

<script type="text/javascript">
// 게시글 공감 여부
document.addEventListener('DOMContentLoaded', () => {
	const btnEL =  document.querySelector('button.btnSendBoardLike');
		
	btnEL.addEventListener('click', function () {
		const $i = this.querySelector('i');
        const userLiked = $i.classList.contains('bi-heart-fill');
        
		const msg = userLiked ? '게시글 공감을 취소하시겠습니까 ? ' : '게시글에 공감하십니까 ?';
		if(! confirm( msg )) {
			return false;
		}
		
		const fn = function(data) {
			let state = data.state;
			
			if(state === 'true') {
				if(userLiked) {
					$i.classList.remove('bi-heart-fill', 'text-danger');
					$i.classList.add('bi-heart');
				} else {
					$i.classList.remove('bi-heart');
					$i.classList.add('bi-heart-fill', 'text-danger');
				}
				
				let count = data.boardLikeCount;
				document.getElementById('boardLikeCount').textContent = count;
			} else if(state === 'liked') {
				alert('게시글 공감은 한번만 가능합니다.');
			} else {
				alert('게시글 공감 여부 처리가 실패했습니다.');
			}
		};
		
		const url = '${pageContext.request.contextPath}/bbs/boardLike/${dto.num}';
		const method = userLiked ? 'DELETE' : 'POST';
		// let params = null;
		
		const headers = {'AJAX': true};
		const options = {
			method: method,
			headers: headers,
		};
	
		fetch(url, options)
			.then(res => {
				if (!res.ok) {
					if (res.status === 401) {
						alert('인증이 필요합니다. 다시 로그인해주세요.'); return;
					}
					
					throw new Error('HTTP error! status: ' + res.status);
				}
				
				return res.json()
			})
			.then(data => fn(data))
			.catch(err => console.log("error:", err));
	});
});
</script>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>