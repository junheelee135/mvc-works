-- =====================================================
-- 주간보고서 DDL (Oracle)
-- report 테이블: period_start, period_end 컬럼 추가
-- reportfile 테이블: savefilename → VARCHAR2(500) 수정
-- =====================================================

-- 시퀀스
CREATE SEQUENCE report_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE reportfile_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- 보고서 테이블
CREATE TABLE report (
    filenum       NUMBER(19)    NOT NULL,
    subject       VARCHAR2(255) NULL,
    content       CLOB          NULL,
    groupnum      NUMBER        NULL,
    depth         NUMBER(9,0)   DEFAULT 0 NULL,  -- 0:보고서, 1:피드백
    orderno       NUMBER(9,0)   DEFAULT 0 NULL,
    parent        NUMBER        DEFAULT 0 NULL,   -- 피드백인 경우 원본 보고서 filenum
    hitcount      NUMBER        DEFAULT 0 NULL,
    regdate       DATE          DEFAULT SYSDATE NULL,
    updatedate    DATE          NULL,
    period_start  DATE          NULL,             -- 보고 기간 시작
    period_end    DATE          NULL,             -- 보고 기간 종료
    empId         VARCHAR2(11)  NOT NULL
);

ALTER TABLE report ADD CONSTRAINT PK_REPORT PRIMARY KEY (filenum);

ALTER TABLE report ADD CONSTRAINT FK_employee1_TO_report_1
    FOREIGN KEY (empId) REFERENCES employee1 (empId);

-- 보고서 첨부파일 테이블
-- savefilename: VARCHAR2(500)으로 수정 (파일명 문자열 저장)
-- filesize: NUMBER → NUMBER(19) (bytes 단위, 최대 10MB = 약 10,000,000)
CREATE TABLE reportfile (
    filenum        NUMBER(19)    NOT NULL,
    savefilename   VARCHAR2(500) NULL,           -- 서버 저장 파일명 (VARCHAR2로 수정)
    originalfilename VARCHAR2(500) NULL,
    filesize       NUMBER(19)    NULL,           -- 파일 크기(bytes)
    filenum2       NUMBER(19)    NOT NULL        -- report.filenum 참조
);

ALTER TABLE reportfile ADD CONSTRAINT PK_REPORTFILE PRIMARY KEY (filenum);

ALTER TABLE reportfile ADD CONSTRAINT FK_report_TO_reportfile_1
    FOREIGN KEY (filenum2) REFERENCES report (filenum);
