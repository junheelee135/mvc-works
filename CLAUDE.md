# CLAUDE.md - 결재 시스템 프로젝트 지침

## 대화 컨텍스트 자동 업데이트 (필수)

**매 대화 세션이 끝나기 전에** 반드시 `C:\spring2\work\memo\대화_컨텍스트.md` 파일을 업데이트할 것.

### 업데이트 규칙
1. 사용자가 대화를 끝내려 할 때 (예: "수고했어", "오늘 여기까지", "끝", "고마워" 등) 자동으로 업데이트
2. 새로운 구현이 완료되었을 때 해당 내용 반영
3. 설계 변경이 있었을 때 즉시 반영

### 업데이트 내용
- 현재 단계(진행 상황) 갱신
- 새로 생성된 파일 목록 추가
- 확정된 설계 변경사항 반영
- 다음 작업 내용 갱신
- 최종 업데이트 날짜 갱신

### 업데이트 금지 항목
- 기존 확정된 요구사항을 임의로 수정하지 않을 것
- 추측성 내용을 넣지 않을 것 (대화에서 확정된 내용만)

---

## 보안 규칙 (필수)

- `.gitignore`에 등록된 파일은 **절대 읽지 않는다**
- `application.yml` — **절대 읽지 않는다** (DB 접속정보, 비밀번호 등)
- 민감 정보 (DB 접속정보, API 키, 비밀번호)는 절대 읽지 않음

---

## 프로젝트 컨텍스트 로딩

매 대화 시작 시 아래 지시로 컨텍스트 로딩:
> "C:\spring2\work\memo 안에 대화 내용이 있어 읽고 참조해 (결재시스템_설계문서_v2.html 제외)"

---

## 개발 환경 요약

- **프로젝트 경로**: `C:\spring2\work\mvc-works`
- **패키지**: `com.mvc.app`
- **백엔드**: Spring Boot 3.5.11, Java 21, Oracle 21c, MyBatis + JPA(보조)
- **프론트엔드**: JSP + Vue 3 CDN + Pinia + Axios + Bootstrap 5
- **인증**: Spring Security (필수)
- **서버 포트**: 9090

## 아키텍처 패턴

- Controller: `@RestController` + `ResponseEntity<?>`
- View 진입: 별도 `ViewController`(또는 `ApprovalController`)에서 JSP 반환
- API prefix: `/api/...`
- Store: Pinia (Vue 3 상태관리 + API 호출)
- Mapper: `@Mapper` 인터페이스 + MyBatis XML
