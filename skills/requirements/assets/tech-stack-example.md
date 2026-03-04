# Tech Stack - 간단한 블로그 플랫폼

## 개요

이 문서는 간단한 블로그 플랫폼의 기술 스택을 정의합니다. 각 선택에 대한 근거와 대안을 포함합니다.

---

## Frontend

### 코어 프레임워크

| 기술 | 버전 | 선택 근거 |
|------|------|----------|
| **Next.js** | 14+ (App Router) | SSR/SSG로 SEO 최적화, Vercel 배포 최적화 |
| **TypeScript** | 5.0+ | 타입 안전성, IDE 지원, 리팩토링 용이 |
| **React** | 18+ | Next.js 기본, Server Components 지원 |

**대안 검토:**
- Vite + React: SSR 불필요 시 더 빠른 DX, 하지만 블로그는 SEO 필수 → Next.js 선택

### 스타일링 & UI

| 기술 | 버전 | 선택 근거 |
|------|------|----------|
| **Tailwind CSS** | 3.4+ | 유틸리티 우선, 빌드 시 미사용 CSS 제거, 디자인 토큰 매핑 용이 |
| **shadcn/ui** | latest | Radix UI 기반 접근성, 복사-붙여넣기 방식 완전 커스터마이징 |

### 상태 관리

| 기술 | 버전 | 선택 근거 |
|------|------|----------|
| **Zustand** | 4.x | ~1KB, 보일러플레이트 최소, 인증 상태 등 클라이언트 상태용 |
| **TanStack Query** | 5.x | 서버 상태 관리 (게시물 목록, 사용자 정보), 캐싱/재검증 자동화 |

### 편집기

| 기술 | 버전 | 선택 근거 |
|------|------|----------|
| **CodeMirror 6** | 6.x | 경량 Markdown 편집기, 실시간 미리보기, 모바일 지원 |

**대안 검토:**
- Tiptap: 리치 텍스트에 강점이지만 Markdown 특화가 아님
- SimpleMDE: 더 단순하지만 커스터마이징 한계

### 폼 & 검증

| 기술 | 버전 | 선택 근거 |
|------|------|----------|
| **React Hook Form** | 7.x | 비제어 컴포넌트, 최소 리렌더링 |
| **Zod** | 3.x | 타입 안전 스키마 검증, Pydantic과 스키마 공유 가능 |

### 테스팅

| 기술 | 용도 |
|------|------|
| **Jest** | 유닛 테스트 |
| **React Testing Library** | 컴포넌트 테스트 |
| **Playwright** | E2E 테스트 |

---

## Backend

### 코어 프레임워크

| 기술 | 버전 | 선택 근거 |
|------|------|----------|
| **FastAPI** | 0.110+ | 자동 OpenAPI 문서, Pydantic 검증, 비동기 지원, ~9000 req/s |
| **Python** | 3.11+ | 타입 힌트, 성능 향상 (3.11에서 10-60% 개선) |
| **Uvicorn** | 0.27+ | ASGI 서버, 프로덕션 성능 |

**대안 검토:**
- Express.js: JavaScript 풀스택 가능하지만 타입 검증/문서 자동화 부족 → FastAPI 선택
- NestJS: TypeScript 풀스택, 하지만 학습 곡선 높고 오버엔지니어링 가능

### ORM & 데이터

| 기술 | 버전 | 선택 근거 |
|------|------|----------|
| **SQLAlchemy** | 2.0+ | 성숙한 Python ORM, 비동기 지원, 복잡한 쿼리 |
| **Alembic** | 1.13+ | SQLAlchemy 네이티브 마이그레이션, 자동 생성 |
| **Pydantic** | 2.0+ | 요청/응답 검증, JSON 직렬화, FastAPI 통합 |
| **asyncpg** | 0.29+ | PostgreSQL 비동기 드라이버, 최고 성능 |

### 인증

| 기술 | 선택 근거 |
|------|----------|
| **python-jose** | JWT 생성/검증 |
| **passlib[bcrypt]** | 비밀번호 해싱 (bcrypt cost 12) |

### 테스팅

| 기술 | 용도 |
|------|------|
| **pytest** | 유닛/통합 테스트 |
| **pytest-asyncio** | 비동기 테스트 |
| **httpx** | API 테스트 클라이언트 |

---

## Database

| 기술 | 버전 | 선택 근거 |
|------|------|----------|
| **PostgreSQL** | 15+ | 신뢰성, JSONB 지원, 전문 검색, 무료 |

**대안 검토:**
- MySQL: 읽기 성능은 비슷하지만 JSONB, 고급 인덱싱에서 PostgreSQL 우위
- SQLite: 개발용으로 가능하지만 동시성 제한

---

## Infrastructure (권장)

| 기술 | 용도 | 선택 근거 |
|------|------|----------|
| **Vercel** | 프론트엔드 배포 | Next.js 최적화, 자동 CDN |
| **Railway / Render** | 백엔드 배포 | 간편한 Python 앱 배포 |
| **Neon / Supabase** | PostgreSQL | 서버리스 PostgreSQL, 무료 티어 |
| **Cloudflare R2** | 이미지 저장 | S3 호환, 무료 이그레스 |

---

## Development Tools

| 기술 | 용도 |
|------|------|
| **ESLint + Prettier** | 코드 포맷팅/린팅 |
| **Ruff** | Python 린팅 (Flake8 대체, 100x 빠름) |
| **Husky + lint-staged** | 커밋 전 자동 검사 |
| **GitHub Actions** | CI/CD |

---

## 의존성 요약

### Frontend (package.json 주요 항목)
```json
{
  "next": "^14.0",
  "react": "^18.0",
  "typescript": "^5.0",
  "tailwindcss": "^3.4",
  "zustand": "^4.0",
  "@tanstack/react-query": "^5.0",
  "zod": "^3.0",
  "react-hook-form": "^7.0"
}
```

### Backend (requirements.txt 주요 항목)
```
fastapi>=0.110
uvicorn>=0.27
sqlalchemy>=2.0
alembic>=1.13
pydantic>=2.0
asyncpg>=0.29
python-jose>=3.3
passlib[bcrypt]>=1.7
pytest>=8.0
httpx>=0.27
ruff>=0.3
```
