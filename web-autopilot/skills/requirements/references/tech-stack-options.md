# 기술 스택 옵션 비교

## 개요

이 문서는 웹 서비스 구축에 사용되는 주요 프레임워크와 도구를 계층별로 비교합니다. Spec-Writer 에이전트가 Stage 2 (기술 스택 결정)에서 옵션을 제시할 때 참조합니다.

---

## 1. 프론트엔드 프레임워크

### Next.js 14+ (기본 추천)

| 항목 | 값 |
|------|-----|
| 언어 | TypeScript/JavaScript |
| 렌더링 | SSR, SSG, ISR, CSR (하이브리드) |
| 라우팅 | App Router (파일 시스템 기반) |
| 번들러 | Turbopack (dev), Webpack (prod) |
| 커뮤니티 | npm 주간 다운로드 ~6M, GitHub Stars ~120K |
| 학습 곡선 | 중간 (React 경험 필요) |

**장점:**
- Vercel 최적화 배포 (제로 설정)
- React Server Components로 번들 크기 최소화
- SEO 친화 (SSR/SSG)
- 이미지 최적화, 폰트 최적화 내장
- API Routes로 간단한 백엔드 가능

**단점:**
- Vercel 종속 우려 (self-host 가능하지만 최적화 감소)
- App Router 학습 곡선
- 빌드 시간이 긴 편 (대규모 프로젝트)

**적합한 서비스:** SEO 필요한 서비스, 콘텐츠 중심 사이트, 대시보드, 이커머스

**사용 기업:** TikTok, Notion, Hulu, Nike, Twitch

---

### Vite + React

| 항목 | 값 |
|------|-----|
| 언어 | TypeScript/JavaScript |
| 렌더링 | CSR (SPA) |
| 라우팅 | React Router (코드 기반) |
| 번들러 | Vite (esbuild + Rollup) |
| 커뮤니티 | npm 주간 다운로드 ~12M (Vite), GitHub Stars ~65K |
| 학습 곡선 | 낮음 |

**장점:**
- 극히 빠른 개발 서버 (HMR < 50ms)
- 설정 최소화
- 가벼운 번들 크기
- 프레임워크 무관 (React, Vue, Svelte 지원)

**단점:**
- SSR 미지원 (별도 설정 필요)
- SEO에 불리 (CSR)
- API Routes 없음 (별도 백엔드 필수)

**적합한 서비스:** 관리자 대시보드, 내부 도구, SPA, SEO 불필요한 앱

---

### Nuxt 3 (Vue)

| 항목 | 값 |
|------|-----|
| 언어 | TypeScript/JavaScript |
| 렌더링 | SSR, SSG, SPA (하이브리드) |
| 라우팅 | 파일 시스템 기반 |
| 번들러 | Vite (Nitro 서버) |
| 커뮤니티 | npm 주간 다운로드 ~500K, GitHub Stars ~50K |

**적합한 서비스:** Vue 생태계 선호 시, Next.js 대안

---

## 2. CSS/UI 프레임워크

### Tailwind CSS + shadcn/ui (기본 추천)

| 항목 | 값 |
|------|-----|
| 타입 | Utility-first CSS + 컴포넌트 라이브러리 |
| 번들 크기 | ~10KB (purged) |
| 커스터마이징 | 완전한 커스터마이징 가능 |
| 접근성 | Radix UI 기반 (WCAG 2.1 AA) |

**장점:**
- shadcn/ui: 복사-붙여넣기 방식, 완전한 소유권
- Radix UI 기반 접근성 내장
- 일관된 디자인 시스템
- Figma 디자인 토큰과 매핑 용이

**적합:** 커스텀 디자인이 필요한 모든 프로젝트

### Material UI (MUI)

| 항목 | 값 |
|------|-----|
| 번들 크기 | ~80KB (tree-shaken) |
| 컴포넌트 수 | 60+ |
| 테마 | Material Design 3 |

**적합:** 빠른 프로토타이핑, Material Design 선호 시

### Ant Design

| 항목 | 값 |
|------|-----|
| 번들 크기 | ~100KB (tree-shaken) |
| 컴포넌트 수 | 70+ |
| 특화 | 엔터프라이즈 / 데이터 테이블 |

**적합:** 관리자 대시보드, 데이터 중심 앱, 중국 시장

---

## 3. 백엔드 프레임워크

### FastAPI (기본 추천)

| 항목 | 값 |
|------|-----|
| 언어 | Python 3.10+ |
| 성능 | ~9,000 req/s (TechEmpower) |
| 타입 시스템 | Pydantic (자동 검증) |
| 문서화 | 자동 Swagger UI + ReDoc |
| 비동기 | 네이티브 async/await |

**장점:**
- 자동 API 문서 생성 (OpenAPI 3.0)
- Pydantic으로 요청/응답 자동 검증
- 타입 힌트 기반 개발 경험
- 비동기 지원 우수
- Python 생태계 (ML/AI 통합 용이)

**단점:**
- Node.js 대비 약간 느린 I/O
- Python 패키지 관리 복잡성 (venv, poetry)

**사용 기업:** Microsoft, Netflix, Uber

---

### Express.js

| 항목 | 값 |
|------|-----|
| 언어 | JavaScript/TypeScript |
| 성능 | ~5,000 req/s |
| 생태계 | npm 최대 규모 |
| 미들웨어 | 방대한 미들웨어 생태계 |

**장점:**
- 프론트엔드와 동일 언어 (JavaScript/TypeScript)
- 가장 큰 패키지 생태계
- 유연한 미들웨어 구조
- 낮은 학습 곡선

**단점:**
- 타입 안전성 약함 (TypeScript 추가 필요)
- 자동 문서 생성 없음 (Swagger 별도 설정)
- 구조화되지 않은 자유도 → 일관성 부족 가능

**적합한 서비스:** JavaScript 풀스택, 빠른 프로토타이핑, 실시간 앱 (Socket.io)

---

### NestJS

| 항목 | 값 |
|------|-----|
| 언어 | TypeScript |
| 성능 | ~5,000 req/s (Express 기반) |
| 아키텍처 | Angular 스타일 (DI, 모듈, 데코레이터) |
| ORM | TypeORM, Prisma 지원 |

**장점:**
- 강력한 구조화 (엔터프라이즈급)
- TypeScript 네이티브
- 자동 Swagger 문서
- 마이크로서비스 지원

**적합한 서비스:** 대규모 엔터프라이즈 앱, TypeScript 풀스택

---

## 4. ORM / 데이터베이스 도구

### SQLAlchemy 2.0+ (기본 추천)

| 항목 | 값 |
|------|-----|
| 언어 | Python |
| 패턴 | Active Record + Data Mapper |
| 비동기 | asyncio 지원 |
| 마이그레이션 | Alembic |

**장점:** 성숙한 생태계, 유연한 쿼리 빌더, 비동기 지원

### Prisma

| 항목 | 값 |
|------|-----|
| 언어 | TypeScript/JavaScript |
| 패턴 | 스키마 우선 (schema.prisma) |
| 타입 안전 | 완전한 TypeScript 타입 자동 생성 |
| 마이그레이션 | prisma migrate |

**장점:** 최고의 DX, 타입 안전 쿼리, 자동 마이그레이션

### Drizzle ORM

| 항목 | 값 |
|------|-----|
| 언어 | TypeScript |
| 패턴 | SQL-like TypeScript API |
| 번들 크기 | ~7.4KB |

**장점:** 가벼움, SQL에 가까운 API, 타입 안전

---

## 5. 데이터베이스

### PostgreSQL 15+ (기본 추천)

| 항목 | 값 |
|------|-----|
| 타입 | 관계형 (RDBMS) |
| JSON 지원 | JSONB (인덱싱 가능) |
| 전문 검색 | tsvector + tsquery |
| 확장성 | 파티셔닝, 복제, 논리적 복제 |

**적합:** 대부분의 웹 서비스 (기본 선택)

### MySQL 8.0+

**적합:** 읽기 위주 워크로드, 레거시 시스템 호환

### MongoDB

**적합:** 스키마가 유동적인 서비스, 문서 중심 데이터, 프로토타이핑

### Redis

**용도:** 캐싱, 세션 저장, Rate Limiting, 실시간 리더보드
**PostgreSQL과 함께 사용 권장**

---

## 6. 상태 관리 (프론트엔드)

### Zustand (기본 추천)

| 항목 | 값 |
|------|-----|
| 번들 크기 | ~1KB |
| API | 훅 기반, 보일러플레이트 최소 |
| 미들웨어 | persist, devtools, immer |

**적합:** 대부분의 React 앱

### TanStack Query (서버 상태)

| 항목 | 값 |
|------|-----|
| 용도 | 서버 상태 관리 (캐싱, 동기화) |
| 번들 크기 | ~13KB |

**적합:** API 중심 앱 (Zustand와 함께 사용)

### Redux Toolkit

**적합:** 복잡한 클라이언트 상태, 대규모 팀

---

## 7. 서비스 유형별 추천 스택

### SPA + REST API (일반 웹 서비스)
```
Frontend: Next.js 14+ / TypeScript / Tailwind + shadcn/ui / Zustand
Backend:  FastAPI / Python 3.11+ / SQLAlchemy 2.0 / Pydantic 2.0
Database: PostgreSQL 15+ / Redis (캐싱)
```

### 관리자 대시보드
```
Frontend: Vite + React / Ant Design or shadcn/ui
Backend:  FastAPI or Express / SQLAlchemy or Prisma
Database: PostgreSQL
```

### 실시간 앱 (채팅, 협업)
```
Frontend: Next.js / Socket.io-client / Zustand
Backend:  FastAPI (WebSocket) or NestJS (Socket.io)
Database: PostgreSQL + Redis (pub/sub)
```

### 콘텐츠 중심 (블로그, CMS)
```
Frontend: Next.js (SSG/ISR) / Tailwind / MDX
Backend:  FastAPI / SQLAlchemy
Database: PostgreSQL
```

### 이커머스
```
Frontend: Next.js (SSR) / shadcn/ui / TanStack Query
Backend:  FastAPI / SQLAlchemy / Stripe SDK
Database: PostgreSQL + Redis
```
