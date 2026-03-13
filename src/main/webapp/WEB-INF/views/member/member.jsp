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
	<!-- Page Title -->
	<div class="page-title">
		<div class="container align-items-center" data-aos="fade-up">
			<h1>회원가입</h1>
			<div class="page-title-underline-accent"></div>
		</div>
	</div>

	<!-- Page Content -->
	<div class="section">
		<div class="container" data-aos="fade-up" data-aos-delay="100">
			<div class="row justify-content-center">
				<div class="col-md-10 bg-white box-shadow my-4 p-5">
					<form name="memberForm" method="post" enctype="multipart/form-data">
						<div class="d-flex align-items-start align-items-sm-center gap-3 pb-4 border-bottom">
							<img src="${pageContext.request.contextPath}/dist/images/user.png" class="img-avatar d-block w-px-100 h-px-100 rounded">
							<div class="ms-3">
								<label for="selectFile" class="btn-accent me-2 mb-4" tabindex="0" title="사진 업로드">
									<span class="d-none d-sm-block">사진 업로드</span>
									<i class="bi bi-upload d-block d-sm-none"></i>
									<input type="file" name="selectFile" id="selectFile" hidden="" accept="image/png, image/jpg, image/jpeg">
								</label>
								<button type="button" class="btn-photo-init btn-default mb-4" title="초기화">
									<span class="d-none d-sm-block">초기화</span>
									<i class="bi bi-arrow-counterclockwise d-block d-sm-none"></i>
								</button>
								<div>Allowed JPG, GIF or PNG. Max size of 800K</div>
							</div>
						</div>

						<div class="row g-3 pt-4">
							<div class="col-md-12 wrap-empId">
								<label for="empId" class="form-label font-roboto">사원번호</label>
								<div class="row g-3">
									<div class="col-md-6">
										<input class="form-control" type="text" id="empId" name="empId" value="${dto.empId}"
											${mode=="update" ? "readonly ":""} autofocus>
									</div>
									<div class="col-md-6">
										<c:if test="${mode=='account'}">
											<button type="button" class="btn-default" onclick="userIdCheck();">사원번호중복검사</button>
										</c:if>
									</div>
								</div>
								<c:if test="${mode=='account'}">
									<small class="form-control-plaintext help-block">사원번호를 입력하세요. (최대 11자)</small>
								</c:if>
							</div>

							<div class="col-md-12">
								<div class="row g-3">
									<div class="col-md-6">
										<label for="password" class="form-label font-roboto">패스워드</label>
										<input class="form-control" type="password" id="password" name="password" autocomplete="off" >
										<small class="form-control-plaintext">패스워드는 5~10자이며 하나 이상의 숫자나 특수문자를 포함 합니다.</small>
									</div>
									<div class="col-md-6">
										<label for="password2" class="form-label font-roboto">패스워드확인</label>
										<input class="form-control" type="password" id="password2" name="password2" autocomplete="off">
										<small class="form-control-plaintext">패스워드를 한번 더 입력해주세요.</small>
									</div>
								</div>
							</div>

							<div class="col-md-6">
								<label for="fullName" class="form-label font-roboto">이름</label>
								<input class="form-control" type="text" id="fullName" name="name" value="${dto.name}"
									${mode=="update" ? "readonly ":""}>
							</div>
							<div class="col-md-6">
								<label for="birth" class="form-label font-roboto">생년월일</label>
								<input class="form-control" type="date" id="birth" name="birth" value="${dto.birth}"
									${mode=="update" ? "readonly ":""}>
							</div>

							<div class="col-md-6">
								<label for="email" class="form-label font-roboto">이메일</label>
								<input class="form-control" type="text" id="email" name="email" value="${dto.email}">
							</div>

							<div class="col-md-6">
								<label for="tel" class="form-label font-roboto">전화번호</label>
								<input class="form-control" type="text" id="tel" name="tel" value="${dto.tel}">
							</div>
							<div class="col-md-6">
								<label for="btn-zip" class="form-label font-roboto">우편번호</label>
								<div class="row g-3">
									<div class="col-8">
										<input class="form-control" type="text" name="zip" id="zip" value="${dto.zip}" readonly tabindex="-1">
									</div>
									<div class="col-4">
										<button type="button" class="btn-default" id="btn-zip" onclick="daumPostcode();">우편번호찾기</button>
									</div>
								</div>
							</div>

							<div class="col-md-6">
								<label class="form-label font-roboto">기본주소</label>
								<input class="form-control" type="text" name="addr1" id="addr1" value="${dto.addr1}" readonly tabindex="-1">
							</div>
							<div class="col-md-6">
								<label for="addr2" class="form-label font-roboto">상세주소</label>
								<input class="form-control" type="text" name="addr2" id="addr2" value="${dto.addr2}">
							</div>

							<c:if test="${mode=='account'}">
								<div class="col-md-12">
									<label for="agree" class="form-label font-roboto">약관 동의</label>
									<div class="form-check">
										<input class="form-check-input" type="checkbox" name="agree" id="agree"
												checked
												onchange="form.sendButton.disabled = !checked">
										<label for="agree" class="form-check-label">
											<a href="#" class="text-primary border-link-right">이용약관</a>에 동의합니다.
										</label>
									</div>
								</div>
							</c:if>

							<div class="col-md-12 text-center">
								<button type="button" name="sendButton" class="btn-accent btn-lg" onclick="memberOk();"> ${mode=="update"?"정보수정":"회원가입"} <i class="bi bi-check2"></i></button>
								<button type="button" class="btn-default btn-lg" onclick="location.href='${pageContext.request.contextPath}/';"> ${mode=="update"?"수정취소":"가입취소"} <i class="bi bi-x"></i></button>
								<input type="hidden" name="empIdValid" id="empIdValid" value="false">
								<c:if test="${mode == 'update'}">
									<input type="hidden" name="profilePhoto" value="${dto.profilePhoto}">
								</c:if>
							</div>
						</div>

					</form>
				</div>
			</div>

		</div>
	</div>
</main>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', ev => {
	let img = '${dto.profilePhoto}';

	const avatarEL = document.querySelector('.img-avatar');
	const inputEL = document.querySelector('form[name=memberForm] input[name=selectFile]');
	const btnEL = document.querySelector('form[name=memberForm] .btn-photo-init');

	let avatar;
	if( img ) {
		avatar = '${pageContext.request.contextPath}/uploads/member/' + img;
		avatarEL.src = avatar;
	}

	const maxSize = 800 * 1024;
	inputEL.addEventListener('change', ev => {
		let file = ev.target.files[0];
		if(! file) {
			if( img ) {
				avatar = '${pageContext.request.contextPath}/uploads/member/' + img;
			} else {
				avatar = '${pageContext.request.contextPath}/dist/images/user.png';
			}
			avatarEL.src = avatar;

			return;
		}

		if(file.size > maxSize || ! file.type.match('image.*')) {
			inputEL.focus();
			return;
		}

		var reader = new FileReader();
		reader.onload = function(e) {
			avatarEL.src = e.target.result;
		}
		reader.readAsDataURL(file);
	});

	btnEL.addEventListener('click', ev => {
		if( img ) {
			if(! confirm('등록된 이미지를 삭제하시겠습니까 ? ')) {
				return false;
			}

			avatar = '${pageContext.request.contextPath}/uploads/member/' + img;

			// 등록 이미지 삭제
			const url = '${pageContext.request.contextPath}/member/deleteProfile';
			const headers = {'Content-Type': 'application/x-www-form-urlencoded', 'AJAX': true};
			const params = 'profilePhoto=' + img;

			const options = {
				method: 'delete',
				headers: headers,
				body: params,
			};

			fetch(url, options)
				.then(res => res.json())
				.then(data => {
					let state = data.state;

					if(state === 'true') {
						img = '';
						avatar = '${pageContext.request.contextPath}/dist/images/user.png';

						document.querySelector('form input[name=profilePhoto]').value = '';
					}

					inputEL.value = '';
					avatarEL.src = avatar;
				})
				.catch(err => console.log("error:", err));

		} else {
			avatar = '${pageContext.request.contextPath}/dist/images/user.png';
			inputEL.value = '';
			avatarEL.src = avatar;
		}
	});
});

function isValidDateString(dateString) {
	try {
		const date = new Date(dateString);
		const [year, month, day] = dateString.split("-").map(Number);

		return date instanceof Date && !isNaN(date) && date.getDate() === day;
	} catch(e) {
		return false;
	}
}

function memberOk() {
	const f = document.memberForm;
	let str, p;

	str = f.empId.value.trim();
	if( !str || str.length > 11 ) {
		alert('사원번호를 입력하세요. (최대 11자)');
		f.empId.focus();
		return;
	}

	let mode = '${mode}';
	if( mode === 'account' && f.empIdValid.value === 'false' ) {
		str = '사원번호 중복 검사가 실행되지 않았습니다.';
		document.querySelector('.wrap-empId .help-block').textContent = str;
		f.empId.focus();
		return;
	}

	p =/^(?=.*[a-z])(?=.*[!@#$%^*+=-]|.*[0-9]).{5,10}$/i;
	str = f.password.value;
	if( ! p.test(str) ) {
		alert('패스워드를 다시 입력 하세요. ');
		f.password.focus();
		return;
	}

	if( str !== f.password2.value ) {
        alert('패스워드가 일치하지 않습니다. ');
        f.password.focus();
        return;
	}

	p = /^[가-힣]{2,5}$/;
    str = f.name.value;
    if( ! p.test(str) ) {
        alert('이름을 다시 입력하세요. ');
        f.name.focus();
        return;
    }

    str = f.birth.value;
    if( ! isValidDateString(str) ) {
        alert('생년월일를 입력하세요. ');
        f.birth.focus();
        return;
    }

    p = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    str = f.email.value;
    if( ! p.test(str) ) {
        alert('이메일을 입력하세요. ');
        f.email.focus();
        return;
    }

    p = /^(010)-?\d{4}-?\d{4}$/;
    str = f.tel.value;
    if( ! p.test(str) ) {
        alert('전화번호를 입력하세요. ');
        f.tel.focus();
        return;
    }

    f.action = '${pageContext.request.contextPath}/member/${mode}';
    f.submit();
}

function userIdCheck() {
	// 사원번호 중복 검사
	let empId = document.getElementById('empId').value.trim();

	if(!empId || empId.length > 11) {
		let str = '사원번호를 입력하세요. (최대 11자)';
		document.getElementById('empId').closest('.wrap-empId').querySelector('.help-block').textContent = str;
		document.getElementById('empId').focus();
		return;
	}

	const url = '${pageContext.request.contextPath}/member/userIdCheck';
	const params = 'empId=' + empId;

	const fn = function(data) {
		let passed = data.passed;

		const empIdInput = document.getElementById('empId');
		const wrapEmpId = empIdInput.closest('.wrap-empId');
		const helpBlock = wrapEmpId.querySelector('.help-block');
		const empIdValid = document.getElementById('empIdValid');

		if (passed === 'true') {
			let str = '<span style="color:blue; font-weight: bold;">' + empId + '</span> 사원번호는 사용가능 합니다.';
			helpBlock.innerHTML = str;
			empIdValid.value = 'true';
		} else {
			let str = '<span style="color:red; font-weight: bold;">' + empId + '</span> 사원번호는 사용할수 없습니다.';
			helpBlock.innerHTML = str;
			empIdInput.value = '';
			empIdValid.value = 'false';
			empIdInput.focus();
		}
	};

	const headers = {'Content-Type': 'application/x-www-form-urlencoded'};
	const options = {
			method: 'post',
			headers: headers,
			body: params,
	};

	fetch(url, options)
		.then(res => res.json())
		.then(data => fn(data))
		.catch(err => console.log("error:", err));
}
</script>

<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
    function daumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                let fullAddr = '';
                let extraAddr = '';

                if (data.userSelectedType === 'R') {
                    fullAddr = data.roadAddress;

                } else {
                    fullAddr = data.jibunAddress;
                }

                if(data.userSelectedType === 'R'){
                    if(data.bname !== ''){
                        extraAddr += data.bname;
                    }
                    if(data.buildingName !== ''){
                        extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                    }
                    fullAddr += (extraAddr !== '' ? ' ('+ extraAddr +')' : '');
                }

                document.getElementById('zip').value = data.zonecode;
                document.getElementById('addr1').value = fullAddr;

                document.getElementById('addr2').focus();
            }
        }).open();
    }
</script>

<footer>
	<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
</footer>

<jsp:include page="/WEB-INF/views/layout/footerResources.jsp"/>

</body>
</html>
