<%@ page contentType="text/html; charset=UTF-8"%>

<div class="form-section" v-if="store.selectedFormCode === 'FM005'">
    <div class="form-section-header">
        <div class="form-section-title">
            <span class="material-symbols-outlined">edit_note</span>
            세부 정보
        </div>
    </div>
    <div class="form-section-body">
        <div class="form-field">
            <label>신청서 목적 <span style="font-size:10px;color:#9aa0b4;">ⓘ</span></label>
            <input type="text" placeholder="신청서 목적을 입력하세요." v-model="store.detailData.generalPurpose">
        </div>
        <div class="form-field" style="margin-top:10px;">
            <label>상세 설명</label>
            <div id="general-editor" style="min-height:200px;"></div>
        </div>
    </div>
</div>