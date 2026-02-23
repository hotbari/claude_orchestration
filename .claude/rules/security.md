# 보안 규칙

> 적용 경로: src/**

## FastAPI 백엔드

### 입력 검증
- 모든 요청 데이터는 Pydantic 모델로 검증
- 문자열 필드에 `max_length` 설정 필수
- 숫자 필드에 `ge`, `le` 범위 제한 설정
- `Field()` validator로 커스텀 검증 규칙 추가
- 경로 파라미터도 타입 검증 적용

### SQL Injection 방지
- SQLAlchemy ORM 사용 시 항상 파라미터 바인딩
- Raw SQL 사용 금지 (불가피한 경우 `text()` 바인딩)
- 사용자 입력을 직접 쿼리 문자열에 삽입하지 않음
```python
# GOOD
db.query(User).filter(User.id == user_id)

# BAD - 절대 금지
db.execute(f"SELECT * FROM users WHERE id = {user_id}")
```

### 인증/인가
- JWT 토큰 기반 인증 사용
- 비밀번호는 bcrypt/argon2로 해시 처리
- 토큰 만료 시간 설정 필수 (access: 30분, refresh: 7일)
- 민감한 엔드포인트에 `Depends()` 인증 미들웨어 적용
- RBAC(역할 기반 접근 제어) 적용

### API 보안
- CORS 설정에 와일드카드(`*`) 사용 금지 (프로덕션)
- Rate limiting 적용 (slowapi 또는 미들웨어)
- 응답에 민감 정보 노출 금지 (비밀번호 해시, 내부 에러 등)
- HTTPS 필수 (프로덕션)

### 환경 설정
- 시크릿 값은 환경 변수 또는 `.env` 파일로 관리
- `.env` 파일은 `.gitignore`에 포함
- `pydantic-settings`의 `BaseSettings` 사용

## React 프론트엔드

### XSS 방지
- `dangerouslySetInnerHTML` 사용 금지
- 사용자 입력은 항상 이스케이프 처리
- URL에 사용자 입력 삽입 시 `encodeURIComponent()` 사용
- 서드파티 HTML 렌더링 필요 시 DOMPurify 사용

### 인증 토큰 관리
- JWT는 `httpOnly` 쿠키 저장 권장
- localStorage 저장 시 XSS 취약점 주의
- 토큰 갱신 로직 구현 (자동 refresh)

### 민감 정보
- API 키, 시크릿을 프론트엔드 코드에 포함하지 않음
- 환경 변수는 빌드 타임에만 주입 (`VITE_` 접두사)
