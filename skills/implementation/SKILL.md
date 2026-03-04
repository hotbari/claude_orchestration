---
name: implementation
description: Code implementation - Backend (FastAPI) then Frontend (Next.js + shadcn/ui)
version: 1.0.0
---

# Implementation Phase

## 개요

Phase 4는 완전한 웹 서비스 코드베이스를 구현합니다. API 계약을 수립하기 위해 Backend를 먼저 구현하고, Frontend가 해당 API를 사용합니다.

**하위 단계:** 4.1 Backend (FastAPI), 4.2 Frontend (Next.js + shadcn/ui)
**실행 순서:** 순차적 (Backend가 Frontend보다 먼저 완료되어야 함)

---

## 전제 조건

- **State**: `phases.architecture === "completed"`
- **필수 문서**: design-analysis.md, prd.md, api-spec.md, db-schema.md, architecture.md

---

## 입력

| 문서 | 경로 |
|------|------|
| Design Analysis | `.omc/web-projects/{service}/docs/design-analysis.md` |
| PRD | `.omc/web-projects/{service}/docs/prd.md` |
| API Spec | `.omc/web-projects/{service}/docs/api-spec.md` |
| DB Schema | `.omc/web-projects/{service}/docs/db-schema.md` |
| Architecture | `.omc/web-projects/{service}/docs/architecture.md` |

## 출력

| 출력 | 경로 |
|------|------|
| Backend code | `projects/{service}-backend/` |
| Frontend code | `projects/{service}-frontend/` |

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| `executor-high` | opus | Backend 구현 |
| `designer-high` | opus | Frontend 구현 |

---

## Phase 4.1: Backend 구현

### Step 1: 프로젝트 초기화

디렉토리 구조 생성 (`scripts/init-fastapi.py` 사용 가능):
```
projects/{service}-backend/
  app/
    api/v1/endpoints/, dependencies.py
    services/, repositories/, models/, schemas/
    core/ (config.py, security.py, database.py)
  alembic/, tests/, requirements.txt, .env.example
```

### Step 2: Database 모델

`executor-high`에 위임:
```
Implement SQLAlchemy models per db-schema.md
- SQLAlchemy 2.0 declarative base
- Type annotations, relationships, indexes
Output: projects/{service}-backend/app/models/
```

### Step 3: Alembic 마이그레이션

```bash
alembic init alembic
alembic revision --autogenerate -m "Initial migration"
```

### Step 4: Pydantic 스키마

`executor-high`에 위임:
```
Implement Pydantic schemas per api-spec.md
- Create/Update/Response schemas for each entity
- Field validation (EmailStr, constr, etc.)
Output: projects/{service}-backend/app/schemas/
```

### Step 5: API 엔드포인트

`executor-high`에 위임:
```
Implement FastAPI endpoints per api-spec.md
- One file per resource
- Dependency injection for services
- Pydantic validation, proper HTTP status codes
- OpenAPI documentation

Error Handling:
- Custom exceptions (UserNotFoundError, etc.)
- Global exception handlers returning JSONResponse
Output: projects/{service}-backend/app/api/v1/endpoints/
```

### Step 6: Service 레이어

`executor-high`에 위임:
```
Implement business logic layer
- Separate from API layer
- Repository pattern for data access
- Transaction management
Output: projects/{service}-backend/app/services/
```

### Step 7: Repository 레이어

`executor-high`에 위임:
```
Implement data access layer
- CRUD operations, async SQLAlchemy
- Query builders, pagination helpers
Output: projects/{service}-backend/app/repositories/
```

### Step 8: 환경 구성

`.env.example` 생성:
```
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### Step 9: Backend 검증

```bash
# Build check
pip install -r requirements.txt
uvicorn app.main:app --reload  # Must start without errors

# Type check
mypy app/ --ignore-missing-imports  # Must pass
```

api-spec.md의 모든 엔드포인트가 구현되었는지 확인

---

## Phase 4.2: Frontend 구현

### Step 1: 프로젝트 초기화

```bash
npx create-next-app@latest projects/{service}-frontend \
  --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
```

또는 `scripts/init-nextjs.sh {service-name}` 사용

### Step 2: shadcn/ui 설정

```bash
cd projects/{service}-frontend
npx shadcn-ui@latest init  # Style: Default, CSS variables: Yes

# Install base components
npx shadcn-ui@latest add button input card dialog form dropdown-menu toast
```

### Step 3: Design Token

design-analysis.md에서 추출:

**`lib/design-tokens.ts` 생성:**
```typescript
export const colors = { primary: '#...', secondary: '#...', /* from Figma */ };
export const spacing = { xs: '4px', sm: '8px', md: '16px', lg: '24px', xl: '32px' };
export const typography = { fontFamily: { sans: 'Inter, sans-serif' }, /* ... */ };
```

Figma 팔레트에서 CSS 변수로 **`globals.css` 업데이트**

### Step 4: 컴포넌트 구현 (Bottom-Up)

**Phase A: UI 컴포넌트** (`components/ui/`)

`designer-high`에 위임:
```
Customize shadcn/ui to match Figma design
- Button variants, Input focus states, Card shadows
- Preserve Radix UI accessibility
Refs: design-analysis.md, design-tokens.ts
```

**Phase B: Common 컴포넌트** (`components/common/`)

`designer-high`에 위임:
```
Implement service-wide components:
- Header, Footer, Navigation, Sidebar
- LoadingSpinner, ErrorBoundary

Requirements:
- TypeScript props interfaces
- Responsive (mobile-first)
- MUST match Figma text exactly (no translation)
```

**Phase C: Feature 컴포넌트** (`components/features/`)

`designer-high`에 위임:
```
Implement feature-specific components from design-analysis.md
- Compose from common components
- Handle loading/error states
- CONTENT FIDELITY: Text must match Figma exactly
```

### Step 5: 페이지 구현

**Phase D: 페이지** (`app/`)

`designer-high`에 위임:
```
Implement Next.js pages per Figma screens
- App Router structure (page.tsx, layout.tsx)
- Server/Client component separation
- FIGMA FIDELITY: Layout, spacing, colors must match
- CONTENT FIDELITY: All text verbatim from Figma
Refs: design-analysis.md, figma-designs/
```

### Step 6: API 통합

`designer-high`에 위임:
```
Implement API layer per api-spec.md
Output: lib/api/, types/

Requirements:
- TypeScript types matching API responses
- Fetch wrapper with error handling
- Environment-based API URL

State Management (if needed):
- Zustand for global state
```

### Step 7: 반응형 디자인

브레이크포인트 확인: Mobile (<640px), Tablet (640-1024px), Desktop (>1024px)

반응형 레이아웃 확인/수정을 위해 `designer-high`에 위임

### Step 8: Frontend 검증

```bash
npm run build    # Must succeed
tsc --noEmit     # Must pass
```

**체크리스트:**
- [ ] Build 성공
- [ ] Type check 통과
- [ ] Figma 충실도 (시각적 비교)
- [ ] shadcn/ui 적절히 사용됨
- [ ] Common 컴포넌트 재사용됨
- [ ] 텍스트가 Figma와 정확히 일치
- [ ] 모든 브레이크포인트에서 반응형

---

## 최종 검증

### Backend
- [ ] `uvicorn app.main:app` 시작됨
- [ ] `mypy app/` 통과
- [ ] 모든 API 엔드포인트 구현됨

### Frontend
- [ ] `npm run build` 성공
- [ ] `tsc --noEmit` 통과
- [ ] Figma 충실도 검증됨
- [ ] 콘텐츠가 Figma와 일치

### State 업데이트
```javascript
state.phases.implementation = 'completed';
state.currentPhase = 'qa';
writeState(state);
```

---

## 오류 처리

### Build 실패

`build-fixer` (sonnet)에 위임:
```
Fix {Backend|Frontend} build error:
Error: {error_output}
Project: projects/{service}-{backend|frontend}/
```

### Type 오류

`executor-high` (backend) 또는 `designer-high` (frontend)에 위임:
```
Fix TypeScript errors:
Errors: {type_errors}
File: {file_path}
```

### 의존성 누락

```bash
# Backend
pip install {package} && echo "{package}=={version}" >> requirements.txt

# Frontend
npm install {package}
```

---

## 참조

- `references/shadcn-setup.md` - shadcn/ui 초기화
- `references/component-patterns.md` - 컴포넌트 패턴
- `references/api-integration.md` - API 통합 가이드

---

## 요약

1. **Backend First**: Clean Architecture (api/services/repositories), SQLAlchemy + Alembic, FastAPI + Pydantic
2. **Frontend Second**: Next.js + TypeScript + Tailwind, shadcn/ui (Figma 커스터마이징), Bottom-up 컴포넌트
3. **검증**: Build + Type check 통과 필수

**다음 Phase**: QA (테스팅 및 architect 검토)
