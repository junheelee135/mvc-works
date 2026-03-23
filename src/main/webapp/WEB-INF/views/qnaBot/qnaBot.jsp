<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>QnA Bot</title>

<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/qnabot.css">

</head>

<body>

	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<div class="emp-content">

		<header>
			<jsp:include page="/WEB-INF/views/layout/header.jsp" />
		</header>

		<div class="card m-3">

			<div class="card-header">
				<h5>QnA Bot</h5>
			</div>

			<div class="chat-box" id="chatBox">
				<div class="message assistant">
					<div class="message-content">${sessionScope.member.name} ${sessionScope.member.gradeName}님 무엇을 도와드릴까요?</div>
				</div>
			</div>

			<div class="card-footer">
				<form id="chatForm" class="d-flex gap-2">
					<input type="text" id="messageInput" class="form-control"
						placeholder="문의사항을 입력하세요..." autocomplete="off">

					<button class="btn-send" type="submit" id="sendButton">전송
					</button>
				</form>
			</div>

		</div>
	</div>

	<script>
const chatBox = document.getElementById('chatBox');
const chatForm = document.getElementById('chatForm');
const messageInput = document.getElementById('messageInput');
const sendButton = document.getElementById('sendButton');

function addMessage(text, sender) {
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message', sender);

    const content = document.createElement('div');
    content.classList.add('message-content');
    content.innerHTML = escapeHtml(text);

    messageDiv.appendChild(content);
    chatBox.appendChild(messageDiv);

    smoothScroll();
    return content;
}

function smoothScroll(){
    chatBox.scrollTo({
        top: chatBox.scrollHeight,
        behavior: 'smooth'
    });
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

chatForm.addEventListener('submit', e => {
    e.preventDefault();
    sendMessage();
});

messageInput.addEventListener("keydown", e => {
    if(e.key === "Enter"){
        e.preventDefault();
        sendMessage();
    }
});

async function sendMessage() {

    const question = messageInput.value.trim();
    if (!question) return;

    addMessage(question, 'user');

    messageInput.value = '';
    sendButton.disabled = true;

    const botContent = addMessage('', 'assistant');

    try {
        const response = await fetch(
            '${pageContext.request.contextPath}/api/question?question=' 
            + encodeURIComponent(question)
        );

        const reader = response.body.getReader();
        const decoder = new TextDecoder();

        while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            botContent.innerHTML += decoder.decode(value);
            smoothScroll();
        }

    } catch (e) {
        botContent.innerHTML = "오류가 발생했습니다.";
    } finally {
        sendButton.disabled = false;
        messageInput.focus();
    }
}
</script>

	<jsp:include page="/WEB-INF/views/layout/footerResources.jsp" />

</body>
</html>