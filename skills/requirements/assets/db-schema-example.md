# Database Schema - 간단한 블로그 플랫폼

## 개요

이 문서는 간단한 블로그 플랫폼의 데이터베이스 스키마를 정의합니다.

- **Database**: PostgreSQL 15+
- **ORM**: SQLAlchemy 2.0+
- **ID 전략**: UUID v4 (보안, 분산 생성 가능)
- **삭제 전략**: Soft delete (사용자, 게시물), Hard delete (세션, 토큰)
- **타임존**: UTC (TIMESTAMPTZ)

---

## ER 다이어그램 (텍스트)

```
users (1) ──→ (N) posts
users (1) ──→ (N) refresh_tokens
posts (1) ──→ (N) uploads
users (1) ──→ (N) uploads
```

---

## 테이블 정의

### users

사용자 계정 정보를 저장합니다.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK, DEFAULT gen_random_uuid() | 사용자 고유 ID |
| email | VARCHAR(255) | UNIQUE, NOT NULL | 로그인 이메일 |
| password_hash | VARCHAR(255) | NOT NULL | bcrypt 해시 (cost 12) |
| name | VARCHAR(100) | NOT NULL | 표시 이름 |
| blog_name | VARCHAR(100) | | 블로그 제목 |
| avatar_url | TEXT | | 프로필 이미지 URL |
| bio | VARCHAR(500) | | 자기소개 |
| email_verified_at | TIMESTAMPTZ | | 이메일 인증 완료 시각 |
| is_active | BOOLEAN | DEFAULT true | 계정 활성 상태 |
| role | VARCHAR(20) | DEFAULT 'user' | 역할 (user, admin) |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 가입 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 마지막 수정 시각 |
| deleted_at | TIMESTAMPTZ | | 삭제 시각 (soft delete) |

**결정 근거:**
- `email` UNIQUE: 중복 가입 방지
- `password_hash` VARCHAR(255): bcrypt 출력 60자이지만 향후 Argon2id 전환 대비
- `role` VARCHAR vs ENUM: VARCHAR가 마이그레이션 없이 역할 추가 가능
- Soft delete: 사용자 데이터 복구 및 법적 보존 요구 대응

---

### posts

블로그 게시물을 저장합니다.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK, DEFAULT gen_random_uuid() | 게시물 고유 ID |
| author_id | UUID | FK → users(id), NOT NULL | 작성자 |
| title | VARCHAR(255) | NOT NULL | 게시물 제목 |
| slug | VARCHAR(255) | UNIQUE, NOT NULL | URL slug |
| content | TEXT | NOT NULL | Markdown 본문 |
| content_html | TEXT | | 렌더링된 HTML (캐시) |
| excerpt | VARCHAR(500) | | 요약 (자동 생성 가능) |
| cover_image_url | TEXT | | 커버 이미지 URL |
| meta_description | VARCHAR(160) | | SEO 메타 설명 |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'draft' | draft, published |
| published_at | TIMESTAMPTZ | | 게시 시각 |
| reading_time | INTEGER | | 예상 읽기 시간 (분) |
| view_count | INTEGER | DEFAULT 0 | 조회수 |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 생성 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 수정 시각 |
| deleted_at | TIMESTAMPTZ | | 삭제 시각 (soft delete) |

**결정 근거:**
- `slug` UNIQUE: SEO 친화 URL, 중복 방지
- `content_html`: 매 요청마다 Markdown→HTML 변환 방지 (캐시)
- `status` VARCHAR: ENUM 대신 유연성 (향후 'archived', 'scheduled' 등 추가)
- `view_count` 비정규화: 매번 COUNT 쿼리 방지
- `reading_time` 비정규화: 저장 시 한 번만 계산

---

### refresh_tokens

JWT Refresh Token을 관리합니다.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK, DEFAULT gen_random_uuid() | 토큰 ID |
| user_id | UUID | FK → users(id) ON DELETE CASCADE, NOT NULL | 소유 사용자 |
| token_hash | VARCHAR(255) | UNIQUE, NOT NULL | 토큰 해시 (SHA-256) |
| expires_at | TIMESTAMPTZ | NOT NULL | 만료 시각 |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 발급 시각 |
| revoked_at | TIMESTAMPTZ | | 폐기 시각 |

**결정 근거:**
- `token_hash`: 원본 토큰 저장 금지 (유출 대비)
- ON DELETE CASCADE: 사용자 삭제 시 모든 토큰 자동 삭제
- Hard delete 대상이나 `revoked_at`으로 즉시 폐기 추적

---

### uploads

업로드된 파일(이미지)을 관리합니다.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK, DEFAULT gen_random_uuid() | 파일 ID |
| user_id | UUID | FK → users(id), NOT NULL | 업로드한 사용자 |
| post_id | UUID | FK → posts(id) ON DELETE SET NULL | 연관 게시물 (선택) |
| filename | VARCHAR(255) | NOT NULL | 원본 파일명 |
| storage_key | TEXT | NOT NULL | 스토리지 경로/키 |
| url | TEXT | NOT NULL | 공개 접근 URL |
| mime_type | VARCHAR(100) | NOT NULL | MIME 타입 |
| size_bytes | BIGINT | NOT NULL | 파일 크기 (bytes) |
| width | INTEGER | | 이미지 너비 (px) |
| height | INTEGER | | 이미지 높이 (px) |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 업로드 시각 |

**결정 근거:**
- `post_id` ON DELETE SET NULL: 게시물 삭제 시 파일은 보존 (나중에 재사용 가능)
- `storage_key`: 스토리지 서비스 변경 시 URL만 갱신하면 됨

---

## 인덱스

| Table | Column(s) | Type | Purpose |
|-------|-----------|------|---------|
| users | email | UNIQUE | 로그인 조회, 중복 방지 |
| users | deleted_at | PARTIAL (WHERE NULL) | 활성 사용자만 조회 |
| posts | author_id | BTREE | 작성자별 게시물 조회 |
| posts | slug | UNIQUE | URL 라우팅 |
| posts | status, published_at DESC | COMPOSITE | 공개 게시물 목록 |
| posts | status, created_at DESC | COMPOSITE | 대시보드 목록 |
| posts | deleted_at | PARTIAL (WHERE NULL) | 활성 게시물만 조회 |
| refresh_tokens | token_hash | UNIQUE | 토큰 검증 |
| refresh_tokens | user_id | BTREE | 사용자별 토큰 조회 |
| refresh_tokens | expires_at | BTREE | 만료 토큰 정리 |
| uploads | user_id | BTREE | 사용자별 파일 조회 |
| uploads | post_id | BTREE | 게시물별 파일 조회 |

---

## 트리거

### updated_at 자동 갱신

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- users
CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- posts
CREATE TRIGGER trg_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## 마이그레이션 순서

1. `users` 테이블 생성 (의존성 없음)
2. `posts` 테이블 생성 (users FK)
3. `refresh_tokens` 테이블 생성 (users FK)
4. `uploads` 테이블 생성 (users, posts FK)
5. 인덱스 생성
6. 트리거 생성
