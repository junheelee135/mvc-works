 <%@ page contentType="text/html; charset=UTF-8"%>

<div class="form-section" v-if="store.selectedFormCode === 'FM003'">
    <div class="form-section-header">
        <div class="form-section-title">
            <span class="material-symbols-outlined">edit_note</span>
            세부 정보
        </div>
    </div>
    <div class="form-section-body">
        <div class="detail-grid-3">
            <div class="form-field">
                <label>지출 목적 <span style="font-size:10px;color:#9aa0b4;">ⓘ</span></label>
                  <input type="text" placeholder="지출 목적을 입력하세요." v-model="store.detailData.expensePurpose">
            </div>
            <div class="form-field">
                <label>결제 방법</label>
                <input type="text" placeholder="법인카드, 계좌이체 등" v-model="store.detailData.expensePayMethod">
            </div>
            <div class="form-field">
                <label>요청 기한</label>
                <input type="date" v-model="store.detailData.expenseDueDate">
            </div>
        </div>

        <!-- 세부 항목 -->
        <div class="expense-section">
            <div class="expense-header">
                <label>세부 항목</label>
                <div>
                    <button class="btn-expense-add" @click="store.addExpenseRow()">
                        <span class="material-symbols-outlined" style="font-size:14px">add</span>
                    </button>
                    <button class="btn-expense-remove" @click="store.removeExpenseRow()">
                        <span class="material-symbols-outlined" style="font-size:14px">remove</span>
                    </button>
                </div>
            </div>
            <table class="expense-table">
                <thead>
                    <tr>
                        <th style="width:50px">순번</th>
                        <th style="width:120px">관련일자</th>
                        <th>내용</th>
                        <th style="width:120px">지출처</th>
                        <th style="width:110px">금액(원)</th>
                        <th>비고</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(row, idx) in store.expenseRows" :key="idx">
                        <td class="text-center">{{ idx + 1 }}</td>
                        <td><input type="date" v-model="row.date"></td>
                        <td><input type="text" v-model="row.content" placeholder="내용"></td>
                        <td><input type="text" v-model="row.vendor" placeholder="지출처"></td>
                        <td><input type="number" v-model.number="row.amount" placeholder="0"></td>
                        <td><input type="text" v-model="row.remark" placeholder="비고"></td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="4" class="text-right"><strong>합 계</strong></td>
                        <td class="text-right"><strong>{{ store.expenseTotal.toLocaleString() }}원</strong></td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
        </div>

        <div class="form-field" style="margin-top:10px;">
            <label>상세 설명</label>
            <textarea rows="5" placeholder="상세 내용을 입력하세요." v-model="store.detailData.description"></textarea>
        </div>
    </div>
</div>