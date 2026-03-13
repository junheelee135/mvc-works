<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MVC</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/paginate.css"
	type="text/css">
<style>
.main-content {
	margin-left: 220px;
	min-height: 100vh;
	background: #f8f9fc;
	padding: 40px;
}

.action-footer {
	margin-top: 30px;
	display: flex;
	justify-content: flex-end;
	gap: 12px;
}

.btn-save {
	background: var(--primary-blue);
	color: #fff;
	padding: 10px 26px;
	border-radius: 10px;
	border: none;
	font-weight: 600;
	cursor: pointer;
}

.btn-save:hover {
	opacity: 0.9;
}

.btn-cancel {
	background: #f3f4f6;
	color: #374151;
	padding: 10px 26px;
	border-radius: 10px;
	border: none;
	font-weight: 500;
	cursor: pointer;
}

.btn-cancel:hover {
	background: #e5e7eb;
}
</style>
</head>
<body>
	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<main>
		<div class="section bg-light">
			<div class="container">

				<div class="row justify-content-center" data-aos="fade-up"
					data-aos-delay="200">
					<div class="col-md-5">
						<div class="bg-white box-shadow my-5 p-5">
							<h3 class="text-center pt-3">패스워드 재확인</h3>

							<form name="pwdForm" action="" method="post" class="row g-3 mb-2">
								<div class="col-12">
									<p class="form-control-plaintext text-center">정보보호를 위해
										패스워드를 다시 한 번 입력해주세요.</p>
								</div>

								<div class="col-12">
									<input type="text" name="login_id"
										class="form-control form-control-lg" placeholder="아이디"
										value="<sec:authentication property='principal.username'/>"
										readonly>

								</div>
								<div class="col-12">
									<input type="password" name="password"
										class="form-control form-control-lg" autocomplete="off"
										placeholder="패스워드">
								</div>
								<div class="col-12 text-center">
									<input type="hidden" name="mode" value="${mode}">
									<button type="button" class="btn-accent btn-lg w-100"
										onclick="sendOk();">
										확인 <i class="bi bi-check2"></i>
									</button>
								</div>
							</form>

							<div>
								<p class="form-control-plaintext text-center text-danger">${message}</p>
							</div>

						</div>

					</div>
				</div>

			</div>
		</div>
	</main>
	
<script type="text/javascript">
function sendOk() {
	const f = document.pwdForm;

	if(! f.password.value.trim()) {
		alert('패스워드를 입력하세요. ');
		f.password.focus();
		return;
	}

	f.action = '${pageContext.request.contextPath}/member/pwd';
	f.submit();
}
</script>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
  AOS.init();
</script>

</body>
</html>