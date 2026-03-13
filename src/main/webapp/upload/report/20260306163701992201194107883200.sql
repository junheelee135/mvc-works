-- 실행 : 범위 설정 후 <Ctrl> + <F9>
-- DB 목록 확인
SHOW DATABASES;

-- DB 생성
CREATE DATABASE mydb;

-- DB삭제
-- DROP DATABASE mydb;

-- 데이터베이스 선택
USE mydb;

--현재 데이터베이스 확인
SELECT DATABASE();

-- 테이블 목록 확인
SHOW TABLES;

-- 테이블 만들기
CREATE TABLE bbs(
	num INT UNSIGNED NOT NULL AUTO_INCREMENT,
	NAME VARCHAR(30) NOT NULL,
	pwd VARCHAR(255) NOT NULL,
	SUBJECT VARCHAR(255) NOT NULL,
	content TEXT NOT NULL,
	reg_date DATETIME DEFAULT CURRENT_TIMESTAMP,
	hitCount INT DEFAULT 0,
	ipAddr VARCHAR(255) NOT NULL,
	PRIMARY KEY(num)
);

-- DROP TABLE 테이블 삭제

--현재 컬럼 목록 확인
DESC bbs;

SELECT * FROM bbs

