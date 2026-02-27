# API 명세서

> 작성일: YYYY-MM-DD
> 대상: [기능/서비스명]
> 기반 문서: docs/specs/requirements.md, docs/specs/technical-spec.md

## 1. 기본 정보

### 1.1 Base URL
```
개발: http://localhost:8000/api/v1
프로덕션: https://[domain]/api/v1
```

### 1.2 인증
```
Authorization: Bearer <access_token>
```
- 인증이 필요한 엔드포인트에 🔒 표시
- 공개 엔드포인트에 🔓 표시

### 1.3 공통 헤더
| 헤더 | 값 | 필수 |
|------|-----|------|
| Content-Type | application/json | ✅ |
| Authorization | Bearer {token} | 🔒 엔드포인트만 |

## 2. 엔드포인트

### 2.1 [리소스 그룹: 예) 사용자]

#### 🔓 POST `/api/v1/[리소스]` — [동작 설명]

**설명**: [상세 설명]

**요청 (Request)**
```json
{
  "field1": "string (필수, 최대 100자)",
  "field2": "integer (필수, 1 이상)"
}
```

**Pydantic 스키마**
```python
class [Resource]Create(BaseModel):
    field1: str = Field(max_length=100)
    field2: int = Field(ge=1)
```

**응답 (Response)**

| 상태 코드 | 설명 |
|-----------|------|
| 201 Created | 성공 |
| 422 Unprocessable Entity | 입력 검증 실패 |
| 409 Conflict | 리소스 충돌 |

```json
// 201 Created
{
  "id": 1,
  "field1": "값",
  "field2": 42,
  "created_at": "2024-01-01T00:00:00Z"
}
```

---

#### 🔒 GET `/api/v1/[리소스]` — 목록 조회

**설명**: [리소스] 목록을 페이지네이션하여 조회합니다.

**쿼리 파라미터**
| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|--------|------|
| skip | int | 0 | 시작 위치 |
| limit | int | 20 | 페이지 크기 (최대 100) |
| sort_by | str | created_at | 정렬 기준 |
| order | str | desc | 정렬 방향 (asc/desc) |

**응답 (Response)**
```json
// 200 OK
{
  "items": [
    {
      "id": 1,
      "field1": "값",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 100,
  "skip": 0,
  "limit": 20
}
```

---

#### 🔒 GET `/api/v1/[리소스]/{id}` — 단건 조회

**경로 파라미터**
| 파라미터 | 타입 | 설명 |
|---------|------|------|
| id | int | 리소스 ID |

**응답 (Response)**

| 상태 코드 | 설명 |
|-----------|------|
| 200 OK | 성공 |
| 404 Not Found | 리소스 없음 |

---

#### 🔒 PUT `/api/v1/[리소스]/{id}` — 수정

[요청/응답 스키마]

---

#### 🔒 DELETE `/api/v1/[리소스]/{id}` — 삭제

**응답 (Response)**

| 상태 코드 | 설명 |
|-----------|------|
| 204 No Content | 성공 |
| 404 Not Found | 리소스 없음 |
| 403 Forbidden | 권한 없음 |

---

### 2.2 [인증 (선택)]

#### 🔓 POST `/api/v1/auth/register` — 회원 가입
#### 🔓 POST `/api/v1/auth/login` — 로그인
#### 🔒 POST `/api/v1/auth/logout` — 로그아웃
#### 🔓 POST `/api/v1/auth/refresh` — 토큰 갱신

## 3. Pydantic 스키마 정의

### 3.1 요청 스키마
```python
class [Resource]Create(BaseModel):
    """[리소스] 생성 요청"""
    field1: str = Field(min_length=1, max_length=100, description="[설명]")
    field2: int = Field(ge=0, description="[설명]")

class [Resource]Update(BaseModel):
    """[리소스] 수정 요청"""
    field1: str | None = Field(default=None, max_length=100)
    field2: int | None = Field(default=None, ge=0)
```

### 3.2 응답 스키마
```python
class [Resource]Response(BaseModel):
    """[리소스] 응답"""
    id: int
    field1: str
    field2: int
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class PaginatedResponse(BaseModel, Generic[T]):
    """페이지네이션 응답"""
    items: list[T]
    total: int
    skip: int
    limit: int
```

## 4. 공통 에러 포맷

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "사용자 친화적 에러 메시지",
    "details": [
      {
        "field": "email",
        "message": "유효한 이메일 형식이 아닙니다."
      }
    ]
  }
}
```

### 에러 코드 목록
| 코드 | HTTP 상태 | 설명 |
|------|-----------|------|
| VALIDATION_ERROR | 422 | 입력 검증 실패 |
| NOT_FOUND | 404 | 리소스 없음 |
| UNAUTHORIZED | 401 | 인증 필요 |
| FORBIDDEN | 403 | 권한 부족 |
| CONFLICT | 409 | 리소스 충돌 (중복 등) |
| INTERNAL_ERROR | 500 | 서버 내부 에러 |
