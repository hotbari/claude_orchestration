# REST API 설계 원칙

## 개요

이 문서는 REST API 설계의 핵심 원칙과 패턴을 정리합니다. Spec-Writer 에이전트가 Stage 4 (API 설계)에서 엔드포인트 구조, 페이지네이션, 버저닝, 에러 포맷 등을 결정할 때 참조합니다.

---

## 1. URL 설계 규칙

### 리소스 네이밍
```
✅ /api/v1/users           (복수 명사)
✅ /api/v1/blog-posts      (케밥 케이스)
✅ /api/v1/users/{id}/posts (중첩 리소스)
❌ /api/v1/getUsers         (동사 사용 금지)
❌ /api/v1/user             (단수 금지)
❌ /api/v1/blogPosts        (카멜 케이스 금지)
```

### HTTP 메서드 매핑
| 메서드 | 용도 | 멱등성 | 안전성 |
|--------|------|--------|--------|
| GET | 리소스 조회 | Yes | Yes |
| POST | 리소스 생성 | No | No |
| PUT | 전체 업데이트 (교체) | Yes | No |
| PATCH | 부분 업데이트 | No* | No |
| DELETE | 리소스 삭제 | Yes | No |

### 중첩 깊이 제한
```
✅ /users/{id}/posts                   (1단계)
✅ /users/{id}/posts/{postId}/comments (2단계)
❌ /users/{id}/posts/{postId}/comments/{commentId}/likes (3단계 이상 → 플랫하게)
✅ /comments/{commentId}/likes          (플랫 대안)
```

---

## 2. 페이지네이션

### Offset 기반 (기본 추천)

```
GET /api/v1/posts?page=2&per_page=20
```

**응답:**
```json
{
  "data": [...],
  "meta": {
    "pagination": {
      "page": 2,
      "per_page": 20,
      "total": 150,
      "total_pages": 8
    }
  }
}
```

**장점:** 구현 간단, 임의 페이지 접근 가능
**단점:** 대규모 데이터셋에서 성능 저하 (`OFFSET` 쿼리 비용)

**적합:** 대부분의 서비스, 총 100K 행 이하

---

### Cursor 기반

```
GET /api/v1/posts?cursor=eyJpZCI6MTAwfQ&limit=20
```

**응답:**
```json
{
  "data": [...],
  "meta": {
    "next_cursor": "eyJpZCI6MTIwfQ",
    "has_more": true
  }
}
```

**장점:** 대규모 데이터셋에서 일정한 성능, 실시간 데이터에 적합
**단점:** 임의 페이지 접근 불가, 구현 복잡

**적합:** 무한 스크롤, 피드, 실시간 데이터, 대규모 데이터

---

### 페이지네이션 선택 기준

| 기준 | Offset | Cursor |
|------|--------|--------|
| 데이터 크기 < 100K | ✅ | ✅ |
| 데이터 크기 > 100K | ❌ | ✅ |
| 임의 페이지 접근 | ✅ | ❌ |
| 무한 스크롤 | ❌ | ✅ |
| 실시간 데이터 | ❌ | ✅ |
| 구현 난이도 | 낮음 | 중간 |

---

## 3. API 버저닝

### URL 경로 (기본 추천)
```
/api/v1/users
/api/v2/users
```
**장점:** 명확, 디버깅 용이, 캐싱 친화
**업계 사례:** Stripe, GitHub, Twitter

### 헤더 기반
```
Accept: application/vnd.api+json;version=2
```
**장점:** 클린 URL
**단점:** 디버깅 어려움, 캐싱 복잡

### 추천
대부분의 프로젝트에서 **URL 경로 방식** 사용. 초기에는 `/api/v1`으로 시작하고, 호환성 깨는 변경 시에만 버전 증가.

---

## 4. 에러 응답 포맷

### 표준 에러 구조
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "요청 데이터가 유효하지 않습니다",
    "details": [
      {
        "field": "email",
        "message": "유효한 이메일 형식이 아닙니다",
        "value": "invalid-email"
      },
      {
        "field": "password",
        "message": "최소 8자 이상이어야 합니다"
      }
    ]
  }
}
```

### 표준 에러 코드

| HTTP | 코드 | 의미 | 사용 시점 |
|------|------|------|----------|
| 400 | BAD_REQUEST | 잘못된 요청 | 형식 오류, 파싱 실패 |
| 401 | UNAUTHORIZED | 인증 필요 | 토큰 없음/만료 |
| 403 | FORBIDDEN | 권한 없음 | 인증됨 but 권한 부족 |
| 404 | NOT_FOUND | 리소스 없음 | 존재하지 않는 리소스 |
| 409 | CONFLICT | 충돌 | 중복 생성 시도 |
| 422 | VALIDATION_ERROR | 검증 실패 | 필드 값 유효하지 않음 |
| 429 | RATE_LIMITED | 요청 초과 | Rate limit 초과 |
| 500 | INTERNAL_ERROR | 서버 오류 | 예상치 못한 오류 |

---

## 5. 인증 헤더

### JWT Bearer Token
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### API Key
```http
X-API-Key: sk_live_abc123def456
```

### 인증 불필요 엔드포인트
공개 엔드포인트는 명시적으로 표시:
```
GET  /api/v1/posts          (Public)
GET  /api/v1/posts/:slug    (Public)
POST /api/v1/auth/register  (Public)
POST /api/v1/auth/login     (Public)
```

---

## 6. 필터링 & 정렬

### 필터링
```
GET /api/v1/posts?filter[status]=published&filter[author_id]=123
GET /api/v1/products?min_price=10&max_price=100&category=electronics
```

### 정렬
```
GET /api/v1/posts?sort=created_at&order=desc
GET /api/v1/posts?sort=-created_at  (축약: - 접두사 = desc)
```

### 검색
```
GET /api/v1/posts?search=react+hooks
GET /api/v1/posts?q=react+hooks     (축약)
```

---

## 7. Rate Limiting

### 표준 한도

| 엔드포인트 유형 | 한도 | 윈도우 |
|----------------|------|--------|
| 인증 (로그인) | 5 req | 15분 |
| 인증된 API | 100 req | 1분 |
| 공개 읽기 | 30 req | 1분 |
| 파일 업로드 | 10 req | 1시간 |
| 검색 | 20 req | 1분 |

### 응답 헤더
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704067200
Retry-After: 30
```

---

## 8. 응답 포맷 규칙

### 날짜/시간
- ISO 8601 형식: `2024-01-15T10:30:00Z`
- 항상 UTC
- `created_at`, `updated_at` 항상 포함

### ID 형식
- UUID v4 권장: `550e8400-e29b-41d4-a716-446655440000`
- 또는 접두사 ID: `usr_1234567890`, `post_abc123` (Stripe 방식)

### Null 처리
```json
{
  "avatar": null,        ✅ 명시적 null
  "avatar": "",          ❌ 빈 문자열 사용 금지
}
```

### Boolean 네이밍
```json
{
  "is_published": true,  ✅ is_ 접두사
  "has_comments": false,  ✅ has_ 접두사
  "can_edit": true       ✅ can_ 접두사
}
```

---

## 9. 공통 엔드포인트 패턴

### 상태 변경 (Publish/Unpublish)
```
POST /api/v1/posts/{id}/publish
POST /api/v1/posts/{id}/unpublish
POST /api/v1/users/{id}/activate
POST /api/v1/users/{id}/deactivate
```

### 대량 작업
```
POST /api/v1/posts/bulk
{
  "action": "delete",
  "ids": ["post_1", "post_2", "post_3"]
}
```

### 파일 업로드
```
POST /api/v1/images/upload
Content-Type: multipart/form-data
```

### 헬스 체크
```
GET /api/v1/health
→ { "status": "ok", "version": "1.0.0", "uptime": "72h" }
```
