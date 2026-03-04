# 보안 체크리스트

## 개요

이 문서는 웹 서비스의 보안 요구사항을 OWASP Top 10 기반으로 정리합니다. Spec-Writer 에이전트가 Stage 6 (비기능 요구사항)에서 보안 타겟을 제시할 때 참조합니다.

---

## 1. OWASP Top 10 (2021) 대응

### A01: Broken Access Control (접근 제어 취약점)

**요구사항:**
- [ ] 모든 API 엔드포인트에 인증/인가 검증
- [ ] 리소스 소유권 검증 (자신의 데이터만 접근)
- [ ] RBAC (Role-Based Access Control) 구현
- [ ] CORS 적절히 설정 (허용 출처 명시)
- [ ] 디렉토리 리스팅 비활성화
- [ ] JWT 클레임에 역할/권한 포함

**구현 패턴:**
```python
# FastAPI 예시
@app.get("/posts/{post_id}")
async def get_post(post_id: str, current_user: User = Depends(get_current_user)):
    post = await get_post_by_id(post_id)
    if post.author_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Forbidden")
```

---

### A02: Cryptographic Failures (암호화 취약점)

**요구사항:**
- [ ] HTTPS 전용 (TLS 1.2+)
- [ ] 비밀번호: bcrypt (cost factor 12) 또는 Argon2id
- [ ] 민감 데이터 암호화 저장 (AES-256)
- [ ] API 키/시크릿 환경 변수로 관리 (코드에 하드코딩 금지)
- [ ] 쿠키: `Secure`, `HttpOnly`, `SameSite` 플래그

**bcrypt 비용 팩터 가이드:**
| 환경 | Cost Factor | 해싱 시간 |
|------|------------|----------|
| 개발 | 10 | ~100ms |
| 프로덕션 (권장) | 12 | ~300ms |
| 높은 보안 | 14 | ~1s |

---

### A03: Injection (인젝션)

**요구사항:**
- [ ] SQL: 파라미터화된 쿼리만 사용 (ORM 권장)
- [ ] XSS: 모든 사용자 입력 이스케이프/새니타이징
- [ ] NoSQL 인젝션 방지 (MongoDB 사용 시)
- [ ] OS 명령 인젝션 방지 (subprocess 사용 금지)
- [ ] LDAP 인젝션 방지 (해당 시)

**구현:**
```python
# ✅ 파라미터화된 쿼리 (SQLAlchemy)
user = session.query(User).filter(User.email == email).first()

# ❌ 문자열 연결 (SQL Injection 취약)
cursor.execute(f"SELECT * FROM users WHERE email = '{email}'")
```

---

### A04: Insecure Design (불안전한 설계)

**요구사항:**
- [ ] Rate Limiting 구현 (로그인, API, 업로드)
- [ ] 계정 잠금 (로그인 5회 실패 시 15분 잠금)
- [ ] 비밀번호 정책 (8자+, 대소문자+숫자)
- [ ] CAPTCHA (필요 시)
- [ ] 민감 작업 재인증 (비밀번호 변경, 계정 삭제)

---

### A05: Security Misconfiguration (보안 설정 오류)

**요구사항:**
- [ ] 프로덕션에서 디버그 모드 비활성화
- [ ] 기본 계정/비밀번호 변경
- [ ] 불필요한 HTTP 메서드 차단
- [ ] 서버 정보 헤더 제거 (`X-Powered-By` 등)
- [ ] HSTS 헤더 설정
- [ ] Content-Security-Policy 헤더

**보안 헤더:**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
```

---

### A06: Vulnerable Components (취약 컴포넌트)

**요구사항:**
- [ ] 의존성 정기 업데이트
- [ ] 취약점 스캐닝 (npm audit, pip-audit)
- [ ] 최소 권한 원칙 (필요한 패키지만)
- [ ] lockfile 사용 (package-lock.json, poetry.lock)

---

### A07: Authentication Failures (인증 취약점)

**요구사항:**
- [ ] 비밀번호 최소 8자, 복잡성 요구
- [ ] 비밀번호 유출 DB 확인 (Have I Been Pwned API)
- [ ] 로그인 실패 시 일반적 메시지 ("이메일 또는 비밀번호가 올바르지 않습니다")
- [ ] 세션/토큰 만료 구현
- [ ] 비밀번호 변경 시 모든 세션 무효화
- [ ] MFA (Multi-Factor Authentication) 지원 (선택)

---

### A08: Data Integrity Failures (데이터 무결성)

**요구사항:**
- [ ] 의존성 무결성 검증 (서브리소스 무결성)
- [ ] CI/CD 파이프라인 보안
- [ ] 서명된 업데이트/배포

---

### A09: Logging & Monitoring (로깅 부재)

**요구사항:**
- [ ] 인증 이벤트 로깅 (로그인 성공/실패)
- [ ] 접근 제어 실패 로깅
- [ ] 민감 작업 감사 로그
- [ ] 로그에 민감 정보 포함 금지 (비밀번호, 토큰)
- [ ] 실시간 모니터링/알림 (이상 트래픽)

---

### A10: SSRF (Server-Side Request Forgery)

**요구사항:**
- [ ] 사용자 입력 URL 검증 (내부 네트워크 접근 차단)
- [ ] 화이트리스트 기반 외부 요청
- [ ] DNS rebinding 방지

---

## 2. 인증 전략별 보안 요구사항

### JWT

| 요구사항 | 중요도 | 설명 |
|---------|--------|------|
| 짧은 Access Token 수명 | 필수 | 15분 ~ 1시간 |
| Refresh Token 로테이션 | 필수 | 사용 시 새 토큰 발급 |
| 토큰 블랙리스트 | 권장 | 로그아웃/비밀번호 변경 시 |
| httpOnly 쿠키 저장 | 권장 | XSS로부터 보호 |
| JWS 알고리즘 고정 | 필수 | HS256 또는 RS256, `none` 차단 |

### OAuth2

| 요구사항 | 중요도 |
|---------|--------|
| PKCE (Proof Key for Code Exchange) | 필수 (SPA) |
| State 파라미터 검증 | 필수 |
| Redirect URI 화이트리스트 | 필수 |
| Scope 최소화 | 권장 |

### Session

| 요구사항 | 중요도 |
|---------|--------|
| CSRF 토큰 | 필수 |
| 세션 고정 방지 (로그인 시 새 세션 ID) | 필수 |
| httpOnly + Secure + SameSite 쿠키 | 필수 |
| 세션 타임아웃 | 필수 |
| 동시 세션 제한 | 권장 |

---

## 3. 데이터 보호

### 개인정보 처리

| 데이터 유형 | 저장 방법 | 접근 제어 |
|------------|----------|----------|
| 비밀번호 | bcrypt 해시 | 절대 복호화/노출 금지 |
| 이메일 | 평문 (검색 필요) | 본인 + 관리자만 |
| 전화번호 | 암호화 | 본인 + 관리자만 |
| 결제 정보 | PCI DSS 준수 외부 서비스 | 토큰화만 저장 |
| 주소 | 암호화 | 본인만 |

### GDPR/개인정보보호법 고려사항

- [ ] 데이터 수집 동의 메커니즘
- [ ] 데이터 열람 요청 처리 (Right to Access)
- [ ] 데이터 삭제 요청 처리 (Right to Erasure)
- [ ] 데이터 이동 요청 처리 (Data Portability)
- [ ] 개인정보 처리방침 제공

---

## 4. API 보안

### 입력 검증

```python
# Pydantic 검증 예시
class CreateUserRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    name: str = Field(min_length=2, max_length=50, pattern=r'^[a-zA-Z\s가-힣]+$')
```

### 출력 필터링

```python
# 민감 필드 제외
class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    # password_hash 제외
    # refresh_token 제외
```

### 파일 업로드 보안

- [ ] 파일 타입 서버 사이드 검증 (MIME type + magic bytes)
- [ ] 파일 크기 제한 (5MB 기본)
- [ ] 파일명 재생성 (원본 파일명 사용 금지)
- [ ] 업로드 경로 격리 (웹 루트 외부)
- [ ] 이미지 리프로세싱 (메타데이터 제거)

---

## 5. 서비스 유형별 보안 수준

| 서비스 유형 | 최소 보안 수준 | 추가 요구사항 |
|------------|--------------|-------------|
| 개인 블로그 | 기본 (HTTPS, XSS 방지, 입력 검증) | - |
| SaaS | 표준 (기본 + RBAC, Rate Limiting, 감사 로그) | SOC 2 고려 |
| 이커머스 | 높음 (표준 + PCI DSS, 결제 보안) | PCI DSS 준수 |
| 금융 | 최고 (높음 + MFA, 암호화, 컴플라이언스) | 금융 규제 준수 |
| 의료 | 최고 (높음 + HIPAA) | HIPAA 준수 |
