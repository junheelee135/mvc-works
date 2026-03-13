<%@ page contentType="text/html; charset=UTF-8"%>

<!-- 참조자 정보 -->
<div class="form-section">
    <div class="form-section-header">
        <div class="form-section-title">
            <span class="material-symbols-outlined">person_add</span>
            참조자 정보
        </div>
        <button class="btn-add-line" @click="referenceModalVisible = true">
            <span class="material-symbols-outlined" style="font-size:15px">group_add</span>
            참조자 추가
        </button>
    </div>
    <div class="form-section-body">
        <div class="line-list ref-list">
            <div v-if="store.references.length === 0" class="line-empty">
                <span class="material-symbols-outlined">group</span>
                참조자를 추가해 주세요.
            </div>
            <div v-for="(p, idx) in store.references" :key="p.empId"
                 class="line-item ref-item">
                <span class="line-name">{{ p.name }}</span>
                <span class="line-dept">{{ p.dept }}</span>
                <span class="line-grade">{{ p.grade }}</span>
                <button class="btn-line-remove" @click="store.removeReference(idx)">
                    <span class="material-symbols-outlined" style="font-size:14px">close</span>
                </button>
            </div>
        </div>
    </div>
</div>