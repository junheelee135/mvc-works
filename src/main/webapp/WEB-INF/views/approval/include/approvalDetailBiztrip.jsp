<%@ page contentType="text/html; charset=UTF-8"%>

<div class="form-section" v-if="store.selectedFormCode === 'FM002'">
    <div class="form-section-header">
        <div class="form-section-title">
            <span class="material-symbols-outlined">edit_note</span>
            세부 정보
        </div>
    </div>
    <div class="form-section-body">
        <div class="detail-grid-2">
            <div class="form-field">
                <label>출장 목적 <span style="font-size:10px;color:#9aa0b4;">ⓘ</span></label>
                <input type="text" placeholder="출장 목적을 입력하세요." v-model="store.detailData.biztripPurpose">
            </div>
            <div class="form-field">
                <label>출장 동행 <span style="font-size:10px;color:#9aa0b4;">ⓘ</span></label>
				<select v-model="store.detailData.biztripCompanion">
      				<option value="">선택</option>
				</select>
            </div>
            <div class="form-field">
                <label>출장 시작일</label>
                <input type="date" v-model="store.detailData.biztripStartDate">
            </div>
            <div class="form-field">
                <label>출장 종료일</label>
                <input type="date" v-model="store.detailData.biztripEndDate">
            </div>
        </div>
        <div class="form-field">
            <label>상세 설명</label>
              <textarea rows="5" placeholder="출장 장소, 참석자, 내용 등을 입력하세요." v-model="store.detailData.description"></textarea>
        </div>
    </div>
</div>