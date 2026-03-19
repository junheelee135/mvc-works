<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>정보 수정</title>

<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<jsp:include page="/WEB-INF/views/layout/sidebarResources.jsp" />

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/core.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/dist/css/editProfile.css">
</head>

<body>
	<jsp:include page="/WEB-INF/views/layout/header.jsp" />
	<jsp:include page="/WEB-INF/views/layout/sidebar.jsp" />

	<main class="d-flex justify-content-center align-items-center py-5">

		<form method="post" enctype="multipart/form-data"
			action="${pageContext.request.contextPath}/member/update"
			onsubmit="return sendOk();">

			<div class="profile-card">

				<h4 class="mb-4 fw-bold">${dto.name}</h4>

				<!-- 프로필 영역 -->
				<div class="d-flex align-items-center gap-4 mb-2">

					<c:choose>
						<c:when test="${empty dto.profilePhoto}">
							<img
								src="${pageContext.request.contextPath}/dist/images/avatar.png"
								class="large-avatar">
						</c:when>
						<c:otherwise>
							<img
								src="${pageContext.request.contextPath}/uploads/member/${dto.profilePhoto}"
								class="large-avatar"
								onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/dist/images/avatar.png';">
						</c:otherwise>
					</c:choose>

					<div class="d-flex flex-column gap-2">
						<div class="input-file-wrapper">
							<label class="input-file-label">파일 선택</label> <input type="file"
								name="selectFile" class="form-control mb-2">
						</div>
						<button type="button" class="btn btn-cancel"
							onclick="deleteProfilePhoto()">Remove</button>
					</div>

				</div>

				<hr class="divider">

				<!-- 개인정보 -->
				<div>
					<div class="section-title">개인 정보</div>

					<div class="row g-4">

						<div class="col-md-6">
							<label class="form-label">사원번호</label> <input type="text"
								class="form-control" value="${dto.empId}" disabled>
						</div>
						<div class="col-md-6">
							<label class="form-label">생년월일</label> <input type="text"
								class="form-control" value="${dto.birth}" disabled>
						</div>

						<div class="col-md-6">
							<label class="form-label">부서</label> <input type="text"
								class="form-control" value="${dto.deptName}" disabled>
						</div>

						<div class="col-md-6">
							<label class="form-label">직급</label> <input type="text"
								class="form-control" value="${dto.gradeName}" disabled>
						</div>

						<div class="col-md-6">
							<label class="form-label">휴대폰</label> <input type="text"
								class="form-control" name="tel" value="${dto.tel}">
						</div>

						<div class="col-md-6">
							<label class="form-label">이메일</label> <input type="email"
								class="form-control" name="email" value="${dto.email}">
						</div>

						<div class="col-md-6">
							<label for="btn-zip" class="form-label">우편번호</label>
							<div class="row g-3">
								<div class="col-8">
									<input class="form-control" type="text" name="zip" id="zip"
										value="${dto.zip}" readonly tabindex="-1">
								</div>
								<div class="col-4">
									<button type="button" class="btn btn-cancel" id="btn-zip"
										onclick="daumPostcode();">찾기</button>
								</div>
							</div>
						</div>

						<div class="col-md-6">
							<label class="form-label">기본주소</label> <input
								class="form-control" type="text" name="addr1" id="addr1"
								value="${dto.addr1}" readonly tabindex="-1">
						</div>

						<div class="col-md-6">
							<label for="addr2" class="form-label">상세주소</label> <input
								class="form-control" type="text" name="addr2" id="addr2"
								value="${dto.addr2}">
						</div>
					</div>
				</div>

				<hr class="divider">

				<!-- 비밀번호 -->
				<div class="row g-4">
					<div class="col-md-6">
						<label class="form-label">새 비밀번호</label> <input type="password"
							class="form-control" name="newPwd" placeholder="Min 8 characters">
					</div>
					<div class="col-md-6">
						<label class="form-label">새 비밀번호 확인</label> <input type="password"
							class="form-control" name="confirmPwd">
					</div>
				</div>

				<input type="hidden" name="empId" value="${dto.empId}"> <input
					type="hidden" name="profilePhoto" value="${dto.profilePhoto}">
				<input type="hidden" name="name" value="${dto.name}">

				<div class="action-footer">
					<input type="hidden" name="deleteProfile" value="">
					<button type="submit" class="btn-save">변경하기</button>
				</div>

			</div>
		</form>
	</main>

	<script
		src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

	<script>
document.querySelector("input[name='selectFile']").addEventListener("change", function(e) {
    const file = e.target.files[0];
    if(!file) return;
    const reader = new FileReader();
    reader.onload = function(event) {
        document.querySelector(".large-avatar").src = event.target.result;
    };
    reader.readAsDataURL(file);
});

function deleteProfilePhoto(){
    if(!confirm("프로필 사진을 삭제하시겠습니까?")) return;
    const formData = new FormData();
    formData.append("profilePhoto", "Y");
    fetch("${pageContext.request.contextPath}/member/deleteProfile", {
        method:"POST",
        body:formData
    }).then(res=>res.json()).then(data=>{
        if(data.state === "true"){
            document.querySelector(".large-avatar").src="${pageContext.request.contextPath}/dist/images/avatar.png";
        }
    });
}

function sendOk() {
    const newPwd = document.querySelector("input[name='newPwd']").value;
    const confirmPwd = document.querySelector("input[name='confirmPwd']").value;
    if(newPwd || confirmPwd){
        if(newPwd !== confirmPwd){ alert("비밀번호가 일치하지 않습니다."); return false; }
        if(newPwd.length < 8){ alert("비밀번호는 8자 이상 입력하세요."); return false; }
    }
    return true;
}

function daumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            let fullAddr = data.userSelectedType === 'R' ? data.roadAddress : data.jibunAddress;
            let extraAddr = '';
            if(data.userSelectedType === 'R'){
                if(data.bname !== '') extraAddr += data.bname;
                if(data.buildingName !== '') extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                fullAddr += (extraAddr !== '' ? ' ('+ extraAddr +')' : '');
            }
            document.getElementById('zip').value = data.zonecode;
            document.getElementById('addr1').value = fullAddr;
            document.getElementById('addr2').focus();
        }
    }).open();
}
</script>

</body>
</html>