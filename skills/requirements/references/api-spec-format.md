# API 사양 형식

## 개요

API 사양은 클라이언트와 서버 간의 계약을 정의하며, 엔드포인트, 요청/응답 형식, 인증 및 오류 처리를 문서화합니다. 이 형식은 API 개발자와 소비자 모두에게 일관성, 명확성 및 구현 용이성을 보장합니다.

**목적:**
- API 소비자에게 명확한 문서 제공
- 자동화된 코드 생성 지원
- API 테스트 및 유효성 검사 지원
- 프론트엔드-백엔드 계약 합의 촉진
- API 버전 관리 및 진화 지원

## 형식

이 사양은 명확성과 개발자 경험을 위한 추가 규칙과 함께 **OpenAPI 3.0** 호환 구조를 따릅니다.

## 구조

### 완전한 템플릿

```markdown
# API Specification - {서비스 이름}

Version: {version}
Last Updated: {date}

## 개요

API의 목적과 기능에 대한 간략한 설명.

## Base URL

- **Development**: `http://localhost:{port}`
- **Staging**: `https://staging-api.{service}.com`
- **Production**: `https://api.{service}.com`

## 인증

**방법**: [JWT Bearer Token | OAuth2 | API Key | Session Cookie | None]

**세부정보**:
- JWT: `Authorization: Bearer {token}` 헤더 포함
- API Key: `X-API-Key: {key}` 헤더 포함
- OAuth2: OAuth2 플로우를 따른 다음 액세스 토큰 사용
- Session: CSRF 보호가 있는 쿠키 기반 인증

**토큰 만료**: [예: 액세스 토큰 1시간, 갱신 토큰 7일]

**예시**:
```http
GET /api/v1/users/me
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 공통 응답 형식

### 성공 응답

```json
{
  "success": true,
  "data": {
    // Resource data
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "version": "1.0"
  }
}
```

### 목록 응답 (페이지네이션 포함)

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 150,
      "total_pages": 8
    }
  }
}
```

### 오류 응답

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

## 표준 오류 코드

| HTTP 상태 | 오류 코드 | 설명 |
|-------------|------------|-------------|
| 400 | BAD_REQUEST | 잘못된 요청 형식 또는 매개변수 |
| 401 | UNAUTHORIZED | 인증 누락 또는 잘못됨 |
| 403 | FORBIDDEN | 권한 부족 |
| 404 | NOT_FOUND | 리소스를 찾을 수 없음 |
| 409 | CONFLICT | 리소스 충돌 (예: 중복) |
| 422 | VALIDATION_ERROR | 유효성 검사 실패 |
| 429 | RATE_LIMIT_EXCEEDED | 너무 많은 요청 |
| 500 | INTERNAL_ERROR | 서버 오류 |
| 503 | SERVICE_UNAVAILABLE | 서비스 일시적으로 사용 불가 |

## 엔드포인트

### {리소스 이름} (예: Users, Tasks, Products)

---

#### GET /api/v1/{resource}

{리소스} 목록 가져오기.

**인증**: 필수

**쿼리 매개변수**:

| 매개변수 | 타입 | 필수 | 기본값 | 설명 |
|-----------|------|----------|---------|-------------|
| page | integer | No | 1 | 페이지 번호 (1-indexed) |
| per_page | integer | No | 20 | 페이지당 항목 수 (최대 100) |
| sort | string | No | created_at | 정렬 필드 |
| order | string | No | desc | 정렬 순서 (asc, desc) |
| filter[{field}] | mixed | No | - | 필드별 필터 |
| search | string | No | - | 검색 쿼리 |

**요청 예시**:
```http
GET /api/v1/tasks?page=1&per_page=20&sort=created_at&order=desc&filter[status]=active
```

**응답**: `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid-1234",
      "title": "Task title",
      "status": "active",
      "created_at": "2024-01-15T10:00:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 45,
      "total_pages": 3
    }
  }
}
```

**오류 응답**:
- `401 Unauthorized`: 인증 토큰 누락 또는 잘못됨
- `429 Too Many Requests`: 속도 제한 초과

---

#### GET /api/v1/{resource}/{id}

ID로 단일 {리소스} 가져오기.

**인증**: 필수

**경로 매개변수**:

| 매개변수 | 타입 | 필수 | 설명 |
|-----------|------|----------|-------------|
| id | string/uuid | Yes | 리소스 ID |

**요청 예시**:
```http
GET /api/v1/tasks/uuid-1234
```

**응답**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid-1234",
    "title": "Task title",
    "description": "Task description",
    "status": "active",
    "priority": "high",
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T12:00:00Z"
  }
}
```

**오류 응답**:
- `401 Unauthorized`: 인증 토큰 누락 또는 잘못됨
- `404 Not Found`: 리소스를 찾을 수 없음

---

#### POST /api/v1/{resource}

새 {리소스} 생성.

**인증**: 필수

**요청 본문**:

| 필드 | 타입 | 필수 | 유효성 검사 | 설명 |
|-------|------|----------|------------|-------------|
| title | string | Yes | min:3, max:255 | 리소스 제목 |
| description | string | No | max:1000 | 리소스 설명 |
| status | string | No | enum: [active, pending] | 리소스 상태 |
| priority | string | No | enum: [low, medium, high] | 우선순위 레벨 |

**요청 예시**:
```http
POST /api/v1/tasks
Content-Type: application/json

{
  "title": "New task",
  "description": "Task description",
  "status": "active",
  "priority": "high"
}
```

**응답**: `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "uuid-5678",
    "title": "New task",
    "description": "Task description",
    "status": "active",
    "priority": "high",
    "created_at": "2024-01-15T14:00:00Z",
    "updated_at": "2024-01-15T14:00:00Z"
  }
}
```

**오류 응답**:
- `400 Bad Request`: 잘못된 요청 형식
- `401 Unauthorized`: 인증 토큰 누락 또는 잘못됨
- `422 Validation Error`: 유효성 검사 실패

---

#### PUT /api/v1/{resource}/{id}

기존 {리소스} 업데이트 (전체 업데이트).

**인증**: 필수

**경로 매개변수**:

| 매개변수 | 타입 | 필수 | 설명 |
|-----------|------|----------|-------------|
| id | string/uuid | Yes | 리소스 ID |

**요청 본문**: POST와 동일 (모든 필수 필드를 제공해야 함)

**요청 예시**:
```http
PUT /api/v1/tasks/uuid-1234
Content-Type: application/json

{
  "title": "Updated task",
  "description": "Updated description",
  "status": "completed",
  "priority": "medium"
}
```

**응답**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid-1234",
    "title": "Updated task",
    "description": "Updated description",
    "status": "completed",
    "priority": "medium",
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T15:00:00Z"
  }
}
```

**오류 응답**:
- `400 Bad Request`: 잘못된 요청 형식
- `401 Unauthorized`: 인증 토큰 누락 또는 잘못됨
- `404 Not Found`: 리소스를 찾을 수 없음
- `422 Validation Error`: 유효성 검사 실패

---

#### PATCH /api/v1/{resource}/{id}

기존 {리소스} 부분 업데이트.

**인증**: 필수

**경로 매개변수**:

| 매개변수 | 타입 | 필수 | 설명 |
|-----------|------|----------|-------------|
| id | string/uuid | Yes | 리소스 ID |

**요청 본문**: 업데이트 가능한 필드의 임의 하위 집합

**요청 예시**:
```http
PATCH /api/v1/tasks/uuid-1234
Content-Type: application/json

{
  "status": "completed"
}
```

**응답**: `200 OK` (PUT와 동일)

**오류 응답**: PUT와 동일

---

#### DELETE /api/v1/{resource}/{id}

{리소스} 삭제.

**인증**: 필수

**경로 매개변수**:

| 매개변수 | 타입 | 필수 | 설명 |
|-----------|------|----------|-------------|
| id | string/uuid | Yes | 리소스 ID |

**요청 예시**:
```http
DELETE /api/v1/tasks/uuid-1234
```

**응답**: `200 OK`
```json
{
  "success": true,
  "message": "Resource deleted successfully"
}
```

**대안**: `204 No Content` (빈 응답 본문)

**오류 응답**:
- `401 Unauthorized`: 인증 토큰 누락 또는 잘못됨
- `404 Not Found`: 리소스를 찾을 수 없음
- `409 Conflict`: 리소스를 삭제할 수 없음 (예: 종속성이 있음)

---

## 모범 사례

### 1. RESTful 규칙

- 리소스 이름에 명사 사용: `/users`, `/tasks`, `/products`
- HTTP 메서드를 의미론적으로 사용:
  - `GET`: 리소스 검색
  - `POST`: 새 리소스 생성
  - `PUT`: 전체 업데이트 (교체)
  - `PATCH`: 부분 업데이트
  - `DELETE`: 리소스 제거
- 컬렉션에 복수 명사 사용: `/tasks`, `/task` 아님
- 관계에 중첩 리소스 사용: `/users/{id}/tasks`

### 2. 버전 관리

- URL에 버전 포함: `/api/v1/`, `/api/v2/`
- 주요 버전 내에서 하위 호환성 유지
- 중요한 변경사항을 명확하게 문서화
- 버전 간 마이그레이션 가이드 제공

### 3. 일관된 오류 형식

항상 동일한 구조로 오류 반환:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": []  // Optional field-specific errors
  }
}
```

### 4. 목록에 대한 페이지네이션

항상 목록 엔드포인트를 페이지네이션:
- 기본 페이지 크기: 20-50 항목
- 최대 페이지 크기: 100 항목
- 응답에 페이지네이션 메타데이터 포함

### 5. 필터링 및 정렬

- 쿼리 매개변수 사용: `?filter[status]=active&sort=created_at&order=desc`
- 각 리소스에 대한 공통 필터 지원
- 사용 가능한 필터 및 정렬 가능한 필드 문서화

### 6. 속도 제한

- 엔드포인트/사용자당 속도 제한 구현
- 속도 제한 헤더 반환:
  - `X-RateLimit-Limit`: 창당 최대 요청 수
  - `X-RateLimit-Remaining`: 남은 요청 수
  - `X-RateLimit-Reset`: 제한이 재설정되는 Unix 타임스탬프
- 초과 시 `429 Too Many Requests` 반환

### 7. CORS 지원

브라우저 기반 클라이언트의 경우:
- CORS 헤더를 적절하게 구성
- 프리플라이트 OPTIONS 요청 지원
- 허용된 출처 문서화

### 8. 타임스탬프

- ISO 8601 형식 사용: `2024-01-15T14:30:00Z`
- 항상 UTC 시간대 사용
- `created_at`과 `updated_at` 모두 포함

### 9. 멱등성

- GET, PUT, DELETE는 멱등성이 있어야 함
- POST 요청에 대한 멱등성 키 지원:
  - 헤더: `Idempotency-Key: {unique-key}`
  - 중복 작업 방지

### 10. 문서화

- 모든 엔드포인트에 대한 예시 포함
- 모든 가능한 오류 응답 문서화
- cURL 예시 제공
- 샘플 페이로드 포함

## 예시: Tasks에 대한 완전한 CRUD API

### GET /api/v1/tasks

필터링 및 페이지네이션으로 모든 작업 나열.

**쿼리 매개변수**:
- `page` (integer): 페이지 번호, 기본값 1
- `per_page` (integer): 페이지당 항목 수, 기본값 20, 최대 100
- `filter[status]` (string): 상태별 필터 (active, completed, archived)
- `filter[priority]` (string): 우선순위별 필터 (low, medium, high)
- `search` (string): 제목 및 설명에서 검색
- `sort` (string): 정렬 필드 (created_at, updated_at, title, priority), 기본값 created_at
- `order` (string): 정렬 순서 (asc, desc), 기본값 desc

**응답**: `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "task-001",
      "title": "Implement API authentication",
      "description": "Add JWT-based authentication to all endpoints",
      "status": "active",
      "priority": "high",
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    },
    {
      "id": "task-002",
      "title": "Write API documentation",
      "description": "Document all endpoints with examples",
      "status": "completed",
      "priority": "medium",
      "created_at": "2024-01-14T09:00:00Z",
      "updated_at": "2024-01-15T16:00:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 45,
      "total_pages": 3
    }
  }
}
```

### GET /api/v1/tasks/{id}

ID로 단일 작업 가져오기.

**응답**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "task-001",
    "title": "Implement API authentication",
    "description": "Add JWT-based authentication to all endpoints",
    "status": "active",
    "priority": "high",
    "tags": ["backend", "security"],
    "assignee": {
      "id": "user-123",
      "name": "John Doe"
    },
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T10:00:00Z"
  }
}
```

### POST /api/v1/tasks

새 작업 생성.

**요청 본문**:
```json
{
  "title": "Implement rate limiting",
  "description": "Add rate limiting middleware to protect against abuse",
  "status": "active",
  "priority": "high",
  "tags": ["backend", "security"]
}
```

**응답**: `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "task-003",
    "title": "Implement rate limiting",
    "description": "Add rate limiting middleware to protect against abuse",
    "status": "active",
    "priority": "high",
    "tags": ["backend", "security"],
    "created_at": "2024-01-15T17:00:00Z",
    "updated_at": "2024-01-15T17:00:00Z"
  }
}
```

### PATCH /api/v1/tasks/{id}

작업 상태 업데이트.

**요청 본문**:
```json
{
  "status": "completed"
}
```

**응답**: `200 OK` (전체 리소스 표현)

### DELETE /api/v1/tasks/{id}

작업 삭제.

**응답**: `200 OK`
```json
{
  "success": true,
  "message": "Task deleted successfully"
}
```

## 추가 고려사항

### 대량 작업

효율성을 위해 대량 작업 지원:

```
POST /api/v1/tasks/bulk
{
  "operations": [
    { "action": "create", "data": {...} },
    { "action": "update", "id": "task-001", "data": {...} },
    { "action": "delete", "id": "task-002" }
  ]
}
```

### 웹훅

지원되는 경우 웹훅 엔드포인트 문서화:
- 이벤트 유형
- 페이로드 형식
- 재시도 정책
- 서명 확인

### 파일 업로드

파일 업로드 엔드포인트의 경우:
- `multipart/form-data` 사용
- 최대 파일 크기 문서화
- 진행률 추적 지원
- 파일 메타데이터 반환

### 장기 실행 작업

비동기 작업의 경우:
- 즉시 `202 Accepted` 반환
- 상태 엔드포인트 제공: `GET /api/v1/jobs/{id}`
- 완료를 위한 폴링 또는 웹훅 지원

---

**총 라인 수**: ~390
