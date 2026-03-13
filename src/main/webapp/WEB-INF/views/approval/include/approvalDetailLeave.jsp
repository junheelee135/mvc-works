<%@ page contentType="text/html; charset=UTF-8"%>

<div class="form-section" v-if="store.selectedFormCode === 'FM001'">
    <div class="form-section-header">
        <div class="form-section-title">
            <span class="material-symbols-outlined">edit_note</span>
            세부 정보
        </div>
    </div>
    <div class="form-section-body">
        <div class="detail-grid">
            <div class="form-field">
                <label>휴가 종류</label>
                <select v-model="store.detailData.leaveType">
      				<option value="">선택</option>
      				<option v-for="lv in codeStore.getCodes('LEAVETYPE')"
              				:key="lv.code"
              				:value="lv.code">
          					{{ lv.name }}
     				</option>
  				</select>
            </div>
            <div class="form-field">
                <label>휴가 시작일</label>
                <div class="detail-grid-input">
                      <input type="date" v-model="store.detailData.leaveStartDate">
  					  	<select v-model="store.detailData.leaveStartDayType">
      						<option>종일</option><option>오전</option><option>오후</option>
					  	</select>
                </div>
            </div>
            <div class="form-field">
                <label>휴가 종료일</label>
                <div class="detail-grid-input">
                      <input type="date" v-model="store.detailData.leaveEndDate">
                       <select v-model="store.detailData.leaveEndDayType">
                           <option>종일</option><option>오전</option><option>오후</option>
                       </select>
                </div>
            </div>
            <div class="form-field">
                <label>총 휴가일 수</label>
                <div class="detail-grid-input">
                    <input type="number" placeholder="0" v-model.number="store.detailData.leaveTotalDays">
                    <span style="font-size:13px;color:#667085;white-space:nowrap;">일</span>
                </div>
            </div>
        </div>
        <div class="form-field">
            <label>상세 설명</label>
            <textarea rows="4" placeholder="상세 내용을 입력해주세요." v-model="store.detailData.description"></textarea>
        </div>
    </div>
</div>