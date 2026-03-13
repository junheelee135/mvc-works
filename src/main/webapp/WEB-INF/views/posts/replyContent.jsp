<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
					
	<div class="reply-form">
		<div class="form-header">
			<span class="small-title">댓글</span><span> - 타인을 비방하거나 개인정보를 유출하는 글의 게시를 삼가해 주세요.</span>
		</div>
		
		<div class="mb-2">
			<textarea class="form-control" name="content"></textarea>
		</div>
		<div class="text-end">
			<button type="button" class="btn-default btn-md btnSendReply">댓글 등록</button>
		</div>
	</div>
	
	<div id="listReply">
		<div class="reply-info">
			<span class="reply-count"></span>
			<span class="reply-page"></span>
		</div>
		<div class="list-content" data-pageNo="0" data-totalPage="0"></div>
		<div class="list-footer">
			<div class="page-navigation"></div>
		</div>
	</div>

	<!-- 댓글 -->
	<script type="text/javascript" src="${pageContext.request.contextPath}/dist/js/util-async.js"></script>
	<script src="${pageContext.request.contextPath}/dist/posts/renderReply.js"></script>
	<script src="${pageContext.request.contextPath}/dist/posts/replyContent.js"></script>
