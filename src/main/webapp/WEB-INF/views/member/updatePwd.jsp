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
</head>
<body>

<header>
	<jsp:include page="/WEB-INF/views/layout/header.jsp"/>
</header>

<main>
	<div class="section bg-light">
		<div class="container">

			<div class="row justify-content-center" data-aos="fade-up" data-aos-delay="200">
				<div class="col-md-5">
					<div class="bg-white box-shadow my-5 p-5">
						<h3 class="text-center pt-3">패스워드 변경</h3>
	                    
						<form name="pwdForm" action="" method="post" class="row g-3 mb-2">
							<div class="col-12">
								<p class="form-control-plaintext text-center">
									안전한 사용을 위하여 기존 패스워드를 변경하세요.
								</p>
							</div>
	                        	                    
							<div class="col-12">
								<input type="text" name="login_id" class="form-control form-control-lg" placeholder="아이디"
									value="<sec:authentication property='principal.username'/>"  readonly>

							</div>
							<div class="col-12">
								<input type="password" name="password" class="form-control form-control-lg" 
									autocomplete="off" placeholder="패스워드">
							</div>
							<div class="col-12">
								<input type="password" name="password2" class="form-control form-control-lg" 
									autocomplete="off" placeholder="패스워드 확인">
							</div>
							<div class="col-12">
								<small class="form-control-plaintext">※ 5~10자 이내의 하나 이상의 숫자나 특수문자가 포함되어야 합니다.</small>
							</div>
							<div class="col-12 text-center">
								<button type="button" class="btn-accent btn-lg" onclick="sendOk();">변경완료 <i class="bi bi-check2"></i></button>
								<button type="button" class="btn-default btn-lg" onclick="location.href='${pageContext.request.contextPath}/';">다음에 변경 <i class="bi bi-x"></i></button>
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

	if(!/^(?=.*[a-z])(?=.*[!@#$%^*+=-]|.*[0-9]).{5,10}$/i.test(f.password.value)) { 
		alert('패스워드는 5~10자이며 하나 이상의 숫자나 특수문자가 포함되어야 합니다.');
		f.password.focus();
		return;
	}

	if(f.password.value !== f.password2.value) {
		alert('패스워드가 일치하지 않습니다.');
		f.password.focus();
		return;
	}

	f.action = '${pageContext.request.contextPath}/member/updatePwd';
	f.submit();
}
</script>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>