<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<div class="mb-5">
    <h2 class="fw-bold fs-3">Project details</h2>
    <p class="text-muted">프로젝트의 상세 정보를 입력해 주세요.</p>
</div>


				<div class="form-section">
		        	<div class="row g-4">
		        		<div class="col-md-6" >
		        			<label class="form-label">총 인원 구성</label>
		       					<div class="input-group">
		                            <input type="number" class="form-control" placeholder="0" min="0">
		                            <span class="input-group-text bg-light border-start-0 text-muted">명</span>
		                        </div>
		                    </div>
		        		<div class="col-md-4"></div> 					
		        	</div>
				</div>


				<div class="form-section">
				    <div class="d-flex align-items-center justify-content-between mb-3">
				        <label class="form-label mb-0">팀 멤버 상세 구성</label>
				        <button type="button" class="btn btn-sm btn-outline-primary" id="btnOpenMemberModal">
				        	<i class="fas fa-plus"></i>
				       </button>
				     </div>
				     
				     <div id="selectedMemberList" class="d-flex flex-wrap gap-2 p-3 border rounded bg-light">
						<p class="text-muted mb-0" id="noMemberText">선택된 멤버가 없습니다.</p>
				     </div>
				</div>

				<div id="hiddenInputContainer"></div>

				<div class="form-section">
				    <div class="col-md-6">
				        <label class="form-label">Project 시작일</label>
				        <input type="date" name="startDate" class="form-control">
				    </div>
				</div>
				
				<div class="form-section">
				    <div class="mb-4">
				        <label class="form-label">Project 제목</label>
				        <input type="text" name="title" class="form-control" placeholder="프로젝트 제목을 입력하세요.">
				    </div>
				    <div>
				        <label class="form-label">프로젝트 상세 설명</label>
				        <textarea name="description" class="form-control" rows="6" placeholder="상세 내용을 입력하세요"></textarea>
				    </div>
				</div>

				<div class="form-section">
				    <div class="col-md-6">
				        <label class="form-label">프로젝트 종료일</label>
				        <input type="date" name="endDate" class="form-control">
				    </div>
				</div>
				
				<div class="modal fade" id="memberSearchModal" tabindex="-1" aria-hidden="true">
				    <div class="modal-dialog modal-xl modal-dialog-centered">
				        <div class="modal-content">
				            <div class="modal-header">
				                <h5 class="modal-title fw-bold">Project 멤버</h5>
				                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
				            </div>
				            <div class="modal-body p-0">
				                <div class="p-3 border-bottom bg-light">
				                    <div class="input-group">
				                        <input type="text" id="memberSearchKeyword" class="form-control" placeholder="이름, 부서, 직급으로 검색...">
				                        <button class="btn btn-primary" type="button" onclick="searchMembers()">
				                            <i class="fas fa-search"></i> 검색
				                        </button>
				                    </div>
				                </div>
				                
				                <div class="d-flex" style="height: 450px;">
				                    <div class="border-end p-3" style="width: 35%; min-width: 220px; overflow-y: auto;">
				                        <h6 class="fw-bold mb-3">조직도</h6>
				                        <ul class="list-unstyled shadow-none mb-0" id="deptTree"></ul>
				                    </div>
				                   
				                    <div class="p-3 flex-grow-1" style="overflow-y: auto;">
				                        <h6 class="fw-bold mb-3" id="selectedDeptName">부서를 선택하세요</h6>
				                        <div id="modalMemberList" class="row row-cols-2 row-cols-md-3 g-2"></div>
				                    </div>
				                </div>
				            </div>
				            <div class="modal-footer">
				                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
				                <button type="button" class="btn btn-primary" onclick="confirmSelection()">선택 완료</button>
				            </div>
				        </div>
				    </div>
				</div>
				
<script type="text/javascript">
	document.getElementById('btnOpenMemberModal').addEventListener('click', function() {
	    const projectType = document.getElementById('projectType').value;
	    if (projectType !== 'I') {
	        const maxInput = document.querySelector('#step-panel-2 input[type="number"]');
	        const maxCount = maxInput ? parseInt(maxInput.value) || 0 : 0;
	        if (maxCount === 0) {
	            toast('총 인원을 먼저 입력해 주세요.');
	            return;
	        }
	    }
	    // 통과하면 모달 열기
	    new bootstrap.Modal(document.getElementById('memberSearchModal')).show();
});
</script>
				
