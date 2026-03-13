package com.mvc.app.aop.common;

/**
 * 활동 로그 action_type 상수
 *  activity_log.action_type 컬럼에 저장되는 값
 */
public final class ActionType {

    private ActionType() {}

    public static final String INSERT       = "INSERT";          // 직원 단건 등록
    public static final String UPDATE       = "UPDATE";          // 직원 단건 수정
    public static final String BULK_UPDATE  = "BULK_UPDATE";     // 직원 벌크 수정
    public static final String DELETE       = "DELETE";          // 직원 선택 삭제
    public static final String BULK_DELETE  = "BULK_DELETE";	 // 직원 벌크 삭제
    public static final String EXCEL_IMPORT = "EXCEL_IMPORT";    // 엑셀 업로드 일괄 등록
}