# 데이터베이스 설계 패턴 가이드

## 개요

이 문서는 웹 서비스의 데이터베이스 설계에서 반복적으로 등장하는 패턴과 결정 포인트를 정리합니다. Spec-Writer 에이전트가 Stage 5 (데이터 모델링)에서 스키마를 설계하고 근거를 제시할 때 참조합니다.

---

## 1. ID 전략

### UUID v4 (기본 추천)

```sql
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
```

**장점:**
- 클라이언트 사이드 생성 가능 (오프라인 지원)
- 열거 공격 방지 (순차 ID는 `/users/1`, `/users/2` 추측 가능)
- 분산 시스템에서 충돌 없음
- 마이그레이션/병합 시 충돌 없음

**단점:**
- 저장 크기: 16 bytes (vs INTEGER 4 bytes)
- 인덱스 성능: B-tree에서 순차 삽입 대비 약간 느림
- 읽기 어려움: `550e8400-e29b-41d4-a716-446655440000`

**업계 사례:** Stripe, GitHub, Notion, Slack

---

### Auto-increment Integer

```sql
id SERIAL PRIMARY KEY
-- 또는
id BIGSERIAL PRIMARY KEY
```

**장점:**
- 저장 효율: 4 bytes (INT) 또는 8 bytes (BIGINT)
- 인덱스 성능 최고 (순차 삽입)
- 읽기 쉬움, 디버깅 용이

**단점:**
- 열거 공격 취약 (공개 API에서)
- 분산 시스템에서 충돌 가능
- 데이터 규모 노출 (ID 값으로 레코드 수 추측)

**적합:** 내부 시스템, 비공개 API, 성능 최우선

---

### 접두사 ID (Stripe 방식)

```
usr_1234567890abcdef
post_abcdef1234567890
```

**장점:**
- 사람이 읽기 쉬움 (타입 즉시 식별)
- UUID의 보안성 + 가독성
- 로그에서 디버깅 용이

**구현:** `{prefix}_{nanoid 또는 uuid 앞 16자}`

---

### 추천

| 서비스 유형 | ID 전략 | 근거 |
|------------|---------|------|
| 공개 API | UUID | 보안, 분산 |
| 내부 도구 | Auto-increment | 성능, 단순 |
| SaaS | 접두사 ID | 가독성 + 보안 |

---

## 2. 타임스탬프 패턴

### 필수 컬럼

```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

**규칙:**
- 항상 `TIMESTAMPTZ` 사용 (타임존 포함)
- `TIMESTAMP` (타임존 없음) 사용 금지
- UTC로 저장, 클라이언트에서 로컬 변환
- `updated_at`은 트리거로 자동 갱신

### 자동 갱신 트리거

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON {table_name}
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

---

## 3. Soft Delete vs Hard Delete

### Soft Delete

```sql
deleted_at TIMESTAMPTZ DEFAULT NULL
```

```sql
-- 삭제
UPDATE users SET deleted_at = NOW() WHERE id = ?;

-- 조회 (삭제된 항목 제외)
SELECT * FROM users WHERE deleted_at IS NULL;
```

**장점:**
- 데이터 복구 가능
- 감사 추적 (audit trail)
- 외래 키 무결성 유지
- 법적/규정 요구사항 충족 (GDPR 데이터 보존)

**단점:**
- 모든 쿼리에 `WHERE deleted_at IS NULL` 필요
- 저장 공간 증가
- UNIQUE 제약조건 복잡해짐

**적합:** 사용자 데이터, 결제 기록, 감사가 필요한 데이터

### Hard Delete

```sql
DELETE FROM posts WHERE id = ?;
```

**적합:** 임시 데이터, 캐시, 세션, 로그

### 추천

| 데이터 유형 | 전략 | 근거 |
|------------|------|------|
| 사용자 계정 | Soft delete | 복구, 법적 요구 |
| 게시물/콘텐츠 | Soft delete | 실수 복구 |
| 댓글 | Soft delete | 맥락 보존 |
| 세션/토큰 | Hard delete | 임시 데이터 |
| 로그 | TTL 삭제 | 자동 정리 |

---

## 4. 관계 패턴

### 1:N (One-to-Many)

```sql
-- users (1) → posts (N)
CREATE TABLE posts (
  id UUID PRIMARY KEY,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  ...
);

CREATE INDEX idx_posts_author_id ON posts(author_id);
```

### N:M (Many-to-Many)

```sql
-- posts ↔ tags
CREATE TABLE post_tags (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);
```

### 자기 참조 (Self-referencing)

```sql
-- 댓글 트리
CREATE TABLE comments (
  id UUID PRIMARY KEY,
  parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  ...
);
```

### ON DELETE 전략

| 옵션 | 동작 | 사용 시점 |
|------|------|----------|
| CASCADE | 부모 삭제 시 자식도 삭제 | 게시물 → 댓글 |
| SET NULL | 부모 삭제 시 FK를 NULL로 | 사용자 → 게시물 (게시물 보존) |
| RESTRICT | 자식 있으면 삭제 차단 | 카테고리 → 게시물 |

---

## 5. 인덱싱 전략

### 필수 인덱스

```sql
-- PK는 자동 인덱스
-- FK 컬럼에 인덱스 (JOIN 성능)
CREATE INDEX idx_posts_author_id ON posts(author_id);

-- 자주 검색/필터하는 컬럼
CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- UNIQUE 제약 = 자동 UNIQUE 인덱스
ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email);
```

### 복합 인덱스

```sql
-- 자주 함께 필터되는 컬럼
CREATE INDEX idx_posts_author_status ON posts(author_id, status);

-- 정렬과 함께
CREATE INDEX idx_posts_status_created ON posts(status, created_at DESC);
```

### 부분 인덱스

```sql
-- 활성 레코드만 인덱싱 (soft delete와 함께)
CREATE INDEX idx_posts_active ON posts(created_at DESC) WHERE deleted_at IS NULL;

-- 게시된 게시물만
CREATE INDEX idx_posts_published ON posts(published_at DESC) WHERE status = 'published';
```

### 전문 검색 인덱스

```sql
-- PostgreSQL GIN 인덱스
ALTER TABLE posts ADD COLUMN search_vector tsvector;
CREATE INDEX idx_posts_search ON posts USING GIN(search_vector);

UPDATE posts SET search_vector =
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(content, '')), 'B');
```

### 인덱스 주의사항
- 쓰기가 많은 테이블: 인덱스 최소화 (INSERT/UPDATE 성능 저하)
- 카디널리티 낮은 컬럼: 인덱스 비효율 (예: boolean `is_active`)
- 복합 인덱스 순서: 선택도 높은 컬럼 먼저

---

## 6. 네이밍 규칙

### 테이블
- 복수형, snake_case: `users`, `blog_posts`, `post_tags`
- 조인 테이블: `{table1}_{table2}` (알파벳순)

### 컬럼
- snake_case: `created_at`, `author_id`, `is_published`
- FK: `{referenced_table_singular}_id` → `author_id`, `post_id`
- Boolean: `is_`, `has_`, `can_` 접두사
- 타임스탬프: `_at` 접미사: `created_at`, `deleted_at`, `published_at`

### 인덱스
- `idx_{table}_{columns}`: `idx_posts_author_id`
- UNIQUE: `uq_{table}_{columns}`: `uq_users_email`

### 제약조건
- PK: `pk_{table}`: `pk_users`
- FK: `fk_{table}_{ref_table}`: `fk_posts_users`
- CHECK: `ck_{table}_{column}`: `ck_users_email_format`

---

## 7. JSON 컬럼 활용

### 적합한 경우
```sql
-- 스키마가 유동적인 메타데이터
metadata JSONB DEFAULT '{}',
-- 설정값
preferences JSONB DEFAULT '{}',
-- 외부 API 응답 캐싱
api_response JSONB
```

### 부적합한 경우
- 자주 쿼리/필터하는 데이터 → 정규 컬럼으로
- 관계가 있는 데이터 → 별도 테이블로
- 인덱싱이 필요한 중첩 데이터 → 정규화

### JSONB 인덱스
```sql
CREATE INDEX idx_users_metadata ON users USING GIN(metadata);
-- 특정 키 인덱스
CREATE INDEX idx_users_metadata_role ON users((metadata->>'role'));
```

---

## 8. 공통 테이블 패턴

### 사용자 (Users)

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  avatar_url TEXT,
  email_verified_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  role VARCHAR(20) DEFAULT 'user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT uq_users_email UNIQUE (email)
);
```

### Refresh Token

```sql
CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  revoked_at TIMESTAMPTZ,
  CONSTRAINT uq_refresh_tokens_hash UNIQUE (token_hash)
);
```

### 파일 업로드

```sql
CREATE TABLE uploads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  filename VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100) NOT NULL,
  size_bytes BIGINT NOT NULL,
  storage_path TEXT NOT NULL,
  url TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 9. N+1 쿼리 방지

### 문제
```python
# ❌ N+1: 게시물마다 작성자 쿼리
posts = db.query(Post).all()
for post in posts:
    author = db.query(User).get(post.author_id)  # N번 추가 쿼리
```

### 해결
```python
# ✅ Eager Loading (JOIN)
posts = db.query(Post).options(joinedload(Post.author)).all()

# ✅ Batch Loading
posts = db.query(Post).all()
author_ids = [p.author_id for p in posts]
authors = db.query(User).filter(User.id.in_(author_ids)).all()
```

### 설계 시 플래그
API 응답에 중첩 객체가 있으면 N+1 위험:
```json
{
  "posts": [
    {
      "title": "...",
      "author": { "name": "..." }  ← JOIN 필요
    }
  ]
}
```

---

## 10. 비정규화 결정

### 비정규화 적합 사례

| 시나리오 | 비정규화 방법 | 근거 |
|---------|-------------|------|
| 게시물 목록에 작성자 이름 | `posts.author_name` | 목록 조회마다 JOIN 방지 |
| 댓글 수 | `posts.comment_count` | COUNT 쿼리 방지 |
| 카테고리 경로 | `posts.category_path` | 재귀 쿼리 방지 |

### 비정규화 시 주의
- 데이터 정합성 유지 방법 결정 (트리거 vs 애플리케이션 코드)
- 갱신 빈도 대비 조회 빈도 비교
- 정합성 깨졌을 때 복구 방법 준비
