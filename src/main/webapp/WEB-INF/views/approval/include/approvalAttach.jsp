<%@ page contentType="text/html; charset=UTF-8"%>

<!-- 공통 첨부파일 -->
<div class="form-section" v-if="store.formVisible">
    <div class="form-section-header">
        <div class="form-section-title">
            <span class="material-symbols-outlined">attach_file</span>
            첨부파일
        </div>
    </div>
    <div class="form-section-body">
        <div class="attach-row">
            <div class="form-field">
                <label>파일 선택 <span style="font-size:10px;color:#9aa0b4;">ⓘ 최대 10개, 개당 50MB</span></label>
                <div class="attach-input-wrap">
                    <label class="btn-file-select" for="attach-file-input">파일 선택</label>
                    <span class="file-name-display">{{ (store.existingFiles.length + store.attachedFiles.length) > 0 ? (store.existingFiles.length + store.attachedFiles.length) + '개 파일 선택됨' : '선택된 파일 없음' }}</span>
                    <input type="file" id="attach-file-input" style="display:none" multiple
                           accept=".jpg,.jpeg,.png,.gif,.hwp,.docx,.xlsx,.pptx"
                           @change="store.addFiles($event.target.files); $event.target.value = ''">
                </div>
            </div>
            <div class="form-field">
                <label>첨부된 파일</label>
                <div class="attach-file-list" v-if="store.existingFiles.length > 0 || store.attachedFiles.length > 0">
                    <div class="attach-file-item" v-for="(file, idx) in store.existingFiles" :key="'ex-' + file.fileId">
                        <span class="material-symbols-outlined" style="font-size:16px;color:#6c63ff;">description</span>
                        <span class="attach-file-name">{{ file.oriFilename }}</span>
                        <span class="attach-file-size">({{ store.formatFileSize(file.fileSize) }})</span>
                        <button class="attach-file-remove" @click="store.removeExistingFile(idx)">
                            <span class="material-symbols-outlined" style="font-size:16px;">close</span>
                        </button>
                    </div>
                    <div class="attach-file-item" v-for="(file, idx) in store.attachedFiles" :key="'new-' + idx">
                        <span class="material-symbols-outlined" style="font-size:16px;color:#6c63ff;">description</span>
                        <span class="attach-file-name">{{ file.name }}</span>
                        <span class="attach-file-size">({{ store.formatFileSize(file.size) }})</span>
                        <button class="attach-file-remove" @click="store.removeFile(idx)">
                            <span class="material-symbols-outlined" style="font-size:16px;">close</span>
                        </button>
                    </div>
                </div>
                <div class="attach-preview" v-else>첨부된 파일이 없습니다.</div>
            </div>
        </div>
    </div>
</div>