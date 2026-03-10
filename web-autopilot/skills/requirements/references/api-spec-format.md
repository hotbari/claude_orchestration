# API 사양 형식

## 개요

API 사양은 클라이언트-서버 계약을 정의하며 엔드포인트, 요청/응답 형식, 인증, 오류 처리를 문서화합니다.

**목적**: 명확한 문서, 자동 코드 생성, API 테스트, 프론트엔드-백엔드 계약, 버전 관리

**형식**: OpenAPI 3.0 호환 구조

---

## 템플릿 구조

```markdown
# API Specification - {서비스 이름}

Version: {version}
Last Updated: {date}

## 개요
API 목적 및 기능 설명.

## Base URL
- **Development**: `http://localhost:{port}`
- **Staging**: `https://staging-api.{service}.com`
- **Production**: `https://api.{service}.com`

## 인증

**방법**: [JWT Bearer | OAuth2 | API Key | Session | None]

**세부정보**:
- JWT: `Authorization: Bearer {token}`
- API Key: `X-API-Key: {key}`
- OAuth2: OAuth2 플로우 + 액세스 토큰
- Session: CSRF 보호 쿠키 인증

**토큰 만료**: [예: 액세스 1시간, 갱신 7일]

**예시**:
```http
GET /api/v1/users/me
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 공통 응답 형식

### 성공
```json
{
  "success": true,
  "data": { /* Resource */ },
  "meta": { "timestamp": "2024-01-15T10:30:00Z", "version": "1.0" }
}
```

### 목록 (페이지네이션)
```json
{
  "success": true,
  "data": [...],
  "meta": {
    "pagination": { "page": 1, "per_page": 20, "total": 150, "total_pages": 8 }
  }
}
```

### 오류
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [{ "field": "email", "message": "Invalid email format" }]
  }
}
```

## 표준 오류 코드

| HTTP | 오류 코드 | 설명 |
|------|----------|------|
| 400 | BAD_REQUEST | 잘못된 요청 |
| 401 | UNAUTHORIZED | 인증 누락/잘못됨 |
| 403 | FORBIDDEN | 권한 부족 |
| 404 | NOT_FOUND | 리소스 없음 |
| 409 | CONFLICT | 리소스 충돌 |
| 422 | VALIDATION_ERROR | 유효성 검사 실패 |
| 429 | RATE_LIMIT_EXCEEDED | 요청 초과 |
| 500 | INTERNAL_ERROR | 서버 오류 |
| 503 | SERVICE_UNAVAILABLE | 서비스 불가 |
```

---

## 엔드포인트 템플릿

### GET /api/v1/{resource}

**설명**: {리소스} 목록 가져오기.

**인증**: 필수

**쿼리 매개변수**:

| 매개변수 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| page | integer | No | 1 | 페이지 번호 |
| per_page | integer | No | 20 | 페이지당 항목 (최대 100) |
| sort | string | No | created_at | 정렬 필드 |
| order | string | No | desc | 정렬 순서 (asc/desc) |
| filter[{field}] | mixed | No | - | 필드별 필터 |
| search | string | No | - | 검색 쿼리 |

**요청**:
```http
GET /api/v1/tasks?page=1&per_page=20&sort=created_at&order=desc&filter[status]=active
```

**응답**: `200 OK`
```json
{
  "success": true,
  "data": [{ "id": "uuid-1", "title": "Task", "status": "active", "created_at": "2024-01-15T10:00:00Z" }],
  "meta": { "pagination": { "page": 1, "per_page": 20, "total": 45, "total_pages": 3 } }
}
```

**오류**:
- `401 Unauthorized`: 인증 누락/잘못됨
- `429 Too Many Requests`: 속도 제한 초과

---

### GET /api/v1/{resource}/{id}

**설명**: ID로 단일 {리소스} 가져오기.

**인증**: 필수

**경로 매개변수**:

| 매개변수 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| id | string/uuid | Yes | 리소스 ID |

**요청**:
```http
GET /api/v1/tasks/uuid-1234
```

**응답**: `200 OK`
```json
{
  "success": true,
  "data": { "id": "uuid-1234", "title": "Task", "description": "...", "status": "active", "created_at": "2024-01-15T10:00:00Z" }
}
```

**오류**:
- `401 Unauthorized`
- `404 Not Found`

---

### POST /api/v1/{resource}

**설명**: 새 {리소스} 생성.

**인증**: 필수

**요청 본문**:

| 필드 | 타입 | 필수 | 유효성 검사 | 설명 |
|------|------|------|------------|------|
| title | string | Yes | min:3, max:255 | 제목 |
| description | string | No | max:1000 | 설명 |
| status | string | No | enum: [active, pending] | 상태 |
| priority | string | No | enum: [low, medium, high] | 우선순위 |

**요청**:
```http
POST /api/v1/tasks
Content-Type: application/json

{ "title": "New task", "description": "...", "status": "active", "priority": "high" }
```

**응답**: `201 Created`
```json
{
  "success": true,
  "data": { "id": "uuid-5678", "title": "New task", "status": "active", "created_at": "2024-01-15T14:00:00Z" }
}
```

**오류**:
- `400 Bad Request`
- `401 Unauthorized`
- `422 Validation Error`

---

### PUT /api/v1/{resource}/{id}

**설명**: 기존 {리소스} 전체 업데이트.

**인증**: 필수

**요청 본문**: POST와 동일 (모든 필수 필드)

**응답**: `200 OK` (전체 리소스)

**오류**:
- `400 Bad Request`
- `401 Unauthorized`
- `404 Not Found`
- `422 Validation Error`

---

### PATCH /api/v1/{resource}/{id}

**설명**: 기존 {리소스} 부분 업데이트.

**인증**: 필수

**요청 본문**: 업데이트할 필드만

**요청**:
```http
PATCH /api/v1/tasks/uuid-1234
Content-Type: application/json

{ "status": "completed" }
```

**응답**: `200 OK` (전체 리소스)

**오류**: PUT와 동일

---

### DELETE /api/v1/{resource}/{id}

**설명**: {리소스} 삭제.

**인증**: 필수

**요청**:
```http
DELETE /api/v1/tasks/uuid-1234
```

**응답**: `200 OK`
```json
{ "success": true, "message": "Resource deleted successfully" }
```

**대안**: `204 No Content`

**오류**:
- `401 Unauthorized`
- `404 Not Found`
- `409 Conflict` (종속성 있음)

---

## 모범 사례

### 1. RESTful 규칙
- 리소스 이름에 명사 사용: `/users`, `/tasks`
- HTTP 메서드 의미론: GET (검색), POST (생성), PUT (전체 업데이트), PATCH (부분 업데이트), DELETE (삭제)
- 복수 명사: `/tasks` (O), `/task` (X)
- 중첩 리소스: `/users/{id}/tasks`

### 2. 버전 관리
- URL에 버전: `/api/v1/`, `/api/v2/`
- 주요 버전 내 하위 호환성 유지
- 중요 변경사항 문서화

### 3. 일관된 오류 형식
```json
{ "success": false, "error": { "code": "ERROR_CODE", "message": "...", "details": [] } }
```

### 4. 페이지네이션
- 기본: 20-50 항목
- 최대: 100 항목
- 메타데이터 포함

### 5. 필터링 및 정렬
- 쿼리 매개변수: `?filter[status]=active&sort=created_at&order=desc`
- 사용 가능한 필터 문서화

### 6. 속도 제한
- 엔드포인트/사용자당 제한
- 헤더: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- 초과 시: `429 Too Many Requests`

### 7. 타임스탬프
- ISO 8601: `2024-01-15T14:30:00Z`
- UTC 사용
- `created_at`, `updated_at` 포함

### 8. 멱등성
- GET, PUT, DELETE는 멱등
- POST는 `Idempotency-Key` 헤더 지원

---

## 추가 고려사항

### 대량 작업
```
POST /api/v1/tasks/bulk
{ "operations": [{ "action": "create", "data": {...} }, { "action": "update", "id": "...", "data": {...} }] }
```

### 웹훅
이벤트 유형, 페이로드 형식, 재시도 정책, 서명 확인 문서화

### 파일 업로드
- `multipart/form-data`
- 최대 파일 크기
- 진행률 추적

### 비동기 작업
- `202 Accepted` 반환
- 상태 엔드포인트: `GET /api/v1/jobs/{id}`
- 폴링 또는 웹훅
