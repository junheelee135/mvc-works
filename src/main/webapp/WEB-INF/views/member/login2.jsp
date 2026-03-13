<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>mvc-works</title>
<jsp:include page="/WEB-INF/views/layout/headerResources.jsp" />
<link rel="stylesheet"
    href="${pageContext.request.contextPath}/dist/css/login-full.css"
    type="text/css">
</head>
<body>

<main class="full-main">

    <!-- 배경 블롭 -->
    <div class="full-main-bg">
        <div class="large-circle-1"></div>
        <div class="small-circle-1"></div>
        <div class="large-circle-2"></div>
        <div class="small-circle-2"></div>
    </div>

    <div class="card-container">
        <div class="card-wrapper">
            <div class="card-inner">

                <!-- 브랜드 헤더 -->
                <div class="card-header">
                    <div class="brand-info">
                        <span class="brand-name">mvc-works</span>
                        <span class="brand-sub">통합 ERP 시스템</span>
                    </div>
                </div>

                <!-- 폼 헤더 -->
                <div class="login-form-header">
                    <h3>로그인</h3>
                    <div class="form-sub">계정 정보를 입력해 주세요.</div>
                </div>

                <!-- 로그인 폼 -->
                <form name="loginForm" action="" method="post">

                    <div class="field-group">
                        <label class="field-label">사원번호</label>
                        <input type="text" name="empId" class="form-control"
                            placeholder="사원번호를 입력하세요">
                    </div>

                    <div class="field-group">
                        <label class="field-label">패스워드</label>
                        <input type="password" name="password" class="form-control"
                            autocomplete="off" placeholder="패스워드를 입력하세요">
                    </div>

                    <div style="display:flex; align-items:center; gap:8px; margin:4px 0 18px;">
                        <input type="checkbox" id="rememberMeModel"
                            style="width:16px; height:16px; cursor:pointer; accent-color:#1a6ab8; flex-shrink:0;">
                        <label for="rememberMeModel"
                            style="font-size:13px; font-weight:600; color:#4a86b0; cursor:pointer; user-select:none; margin:0;">
                            아이디 저장
                        </label>
                    </div>

                    <button type="button" class="btn-accent mb-3"
                        onclick="sendLogin();">Login</button>

                    <p class="form-control-plaintext text-center text-danger p-0 mb-1">
                        <small>${message}</small>
                    </p>
                    <p class="form-control-plaintext text-center mb-0">
                        <a href="#" class="border-link-right">패스워드를 잊으셨나요 ?</a>
                    </p>

                </form>

                <!-- 하단 정보 -->
                <div class="card-footer-info">
                    <span>mvc-works ERP</span>
                    <span>·</span>
                    <span class="ver">v2.0.1</span>
                </div>

            </div>
        </div>
    </div>
</main>

<script type="text/javascript">
    // 페이지 로드 시 저장된 사원번호 불러오기
    window.addEventListener('DOMContentLoaded', function () {
        const savedId  = localStorage.getItem('savedEmpId');
        const remember = document.getElementById('rememberMeModel');
        const empInput = document.loginForm.empId;

        if (savedId) {
            empInput.value  = savedId;
            remember.checked = true;
        }
    });

    function sendLogin() {
        const f        = document.loginForm;
        const remember = document.getElementById('rememberMeModel');

        if (!f.empId.value.trim())    { f.empId.focus();    return; }
        if (!f.password.value.trim()) { f.password.focus(); return; }

        // 체크 여부에 따라 저장 or 삭제
        if (remember.checked) {
            localStorage.setItem('savedEmpId', f.empId.value.trim());
        } else {
            localStorage.removeItem('savedEmpId');
        }

        f.action = '${pageContext.request.contextPath}/member/login';
        f.submit();
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.6/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
