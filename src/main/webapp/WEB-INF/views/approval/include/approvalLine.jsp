<%@ page contentType="text/html; charset=UTF-8"%>

<!-- 결재선 정보 -->
<div class="form-section">
    <div class="form-section-header">
        <div class="form-section-title">
            <span class="material-symbols-outlined">group</span>
            결재선 정보
        </div>
        <div style="display:flex; gap:6px;">
            <button class="btn-add-line btn-tpl-load" @click="openTemplateLoad">
                <span class="material-symbols-outlined" style="font-size:15px">folder_open</span>
                불러오기
            </button>
            <button class="btn-add-line btn-tpl-save" @click="saveTemplate">
                <span class="material-symbols-outlined" style="font-size:15px">save</span>
                저장하기
            </button>
            <button class="btn-add-line" @click="approverModalVisible = true">
                <span class="material-symbols-outlined" style="font-size:15px">person_add</span>
                결재자 추가
            </button>
        </div>
    </div>
    <div class="form-section-body">
        <div class="line-list">
            <div v-if="store.approvers.length === 0" class="line-empty">
                <span class="material-symbols-outlined">how_to_reg</span>
                결재자를 추가해 주세요.
            </div>
            <div v-for="(p, idx) in store.approvers" :key="p.empId"
                 class="line-item" draggable="true"
                 :class="{ dragging: drag.fromIdx === idx, 'drag-over': drag.overIdx === idx }"
                 @dragstart="onDragStart(idx, $event)"
                 @dragover.prevent="onDragOver(idx)"
                 @drop.prevent="onDrop(idx)"
                 @dragend="onDragEnd">
                <span class="drag-handle">&#9776;</span>
                <span class="line-seq">{{ idx + 1 }}</span>
                <span class="line-name">{{ p.name }}</span>
                <span class="line-dept">{{ p.dept }}</span>
                <span class="line-grade">{{ p.grade }}</span>
                <button class="btn-line-remove" @click.stop="store.removeApprover(idx)">
                    <span class="material-symbols-outlined" style="font-size:14px">close</span>
                </button>
            </div>
        </div>
        <div v-if="store.approvers.length > 0" class="line-hint">
            <span class="material-symbols-outlined" style="font-size:13px">info</span>
            드래그하여 결재 순서를 변경할 수 있습니다.
        </div>
    </div>
    <!-- 템플릿 불러오기 모달 -->
    <div class="modal-overlay" v-if="templateLoadModalVisible">
        <div class="modal-box tpl-load-box">
            <div class="modal-header">
                <div class="modal-breadcrumb">결재선 템플릿 &gt; <span>불러오기</span></div>
                <div class="modal-header-btns">
                    <button title="닫기" @click="templateLoadModalVisible = false">
                        <span class="material-symbols-outlined" style="font-size:18px">close</span>
                    </button>
                </div>
            </div>
            <div class="modal-body">
                <div class="modal-section-title">
                    <span class="material-symbols-outlined">folder_open</span>
                    내 결재선 템플릿
                </div>
                <div class="tpl-list">
                    <div v-if="templateList.length === 0" class="tpl-empty">
                        <span class="material-symbols-outlined">inbox</span>
                        저장된 템플릿이 없습니다.
                    </div>
                    <div v-for="tpl in templateList" :key="tpl.tempId"
                         class="tpl-item" @click="onLoadTemplate(tpl.tempId)">
                        <div class="tpl-item-info">
                            <span class="material-symbols-outlined tpl-icon">description</span>
                            <span class="tpl-name">{{ tpl.tempName }}</span>
                        </div>
                        <div class="tpl-item-actions">
                            <span class="tpl-date">{{ tpl.regDate }}</span>
                            <button class="btn-tpl-delete" @click.stop="onDeleteTemplate(tpl.tempId)" title="삭제">
                                <span class="material-symbols-outlined" style="font-size:16px">delete</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-close-modal" @click="templateLoadModalVisible = false">닫기</button>
            </div>
        </div>
    </div>
</div>