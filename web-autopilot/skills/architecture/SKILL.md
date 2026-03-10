---
name: architecture
description: System architecture design - frontend/backend structure, dependencies, auth strategy
version: 1.0.0
---

# Architecture Phase

## 개요

요구사항 문서를 기반으로 완전한 시스템 아키텍처를 설계합니다.

**핵심 결과물:** 프론트엔드 컴포넌트 구조, 백엔드 레이어 분리, 인증 전략, 모든 의존성을 다루는 architecture.md

---

## 전제 조건 & 입출력

**State 요구:** `phases.requirements === "completed"`

**필수 입력:** prd.md, api-spec.md, db-schema.md, tech-stack.md

**출력:** architecture.md

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| architect | opus | 시스템 아키텍처 설계 및 자체 검토 |

---

## 단계별 프로세스

### Step 1: 의존성 확인

```javascript
// State & documents 검증
if (state.phases.requirements !== 'completed') throw Error('requirements first');
checkDocumentsExist(['prd', 'apiSpec', 'dbSchema', 'techStack']);
```

---

### Step 2: 시스템 아키텍처 설계

**architect agent (opus) 위임 프롬프트:**

```
Design system architecture for {serviceName}.

Read: prd.md, api-spec.md, db-schema.md, tech-stack.md

Design components:

## 1. Frontend Architecture (Next.js)

### App Router Structure
- Page routes (PRD user flows 기반)
- Layout hierarchy
- Loading/error boundaries

### Component Architecture (3-tier)
- **components/ui/** - shadcn/ui (Button, Input, Card, Dialog, Form)
- **components/common/** - 서비스 전역 (Header, Footer, Navigation, Sidebar)
- **components/features/** - 기능별 (PRD features 기반)

### Design Token System (lib/design-tokens.ts)
- Color palette, Typography, Spacing, Border radius, Shadows

### shadcn/ui Theming
- globals.css CSS variables customization
- Tailwind config 매핑

## 2. Backend Architecture (FastAPI)

### Clean 3-Layer
- **api/** - v1/endpoints/{resource}.py, dependencies.py
- **services/** - {resource}_service.py (비즈니스 로직)
- **repositories/** - {resource}_repository.py (DB 접근)
- **models/** - SQLAlchemy models
- **schemas/** - Pydantic schemas (Create/Update/Response)
- **core/** - config.py, security.py, database.py

## 3. Authentication Strategy

서비스 유형 기반 선택 (JWT/OAuth2/Session/API Key/None)
- Token format/expiration
- Refresh token handling
- Protected routes
- Role-based access

## 4. Error Handling

### Backend
- Custom exceptions, Global handler
- Format: {"detail": "msg", "code": "CODE"}

### Frontend
- Error boundaries, API error hook, Toast notifications

## 5. Database Migration (Alembic)
```bash
alembic revision --autogenerate -m "msg"
alembic upgrade head
```

## 6. Environment Variables

### Backend (.env.example)
DATABASE_URL, SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES

### Frontend (.env.local.example)
NEXT_PUBLIC_API_URL

## 7. Dependencies

### Frontend
next 14+, react 18+, typescript 5+, tailwindcss 3+, @radix-ui, zustand, zod

### Backend
fastapi, uvicorn, sqlalchemy[asyncio], pydantic, alembic, python-jose, passlib, asyncpg

Output: {architecture.md path}
```


---

### Step 4: Architecture 문서 저장

```javascript
writeFile(paths.documents.architecture, content);
state.phases.architecture = 'completed';
state.currentPhase = 'architecture';
writeState(state);
```

---

## Architecture 문서 구조

```markdown
# System Architecture: {Service Name}

## 1. Overview
## 2. Frontend Architecture
  2.1 App Router, 2.2 Components, 2.3 Design Tokens, 2.4 State
## 3. Backend Architecture
  3.1 Structure, 3.2 API, 3.3 Service, 3.4 Repository, 3.5 Models/Schemas
## 4. Authentication & Authorization
## 5. Error Handling
## 6. Database (Migration, Connection)
## 7. Environment Configuration
## 8. Dependencies
## 9. Architect Review (Feasibility/Scalability/Security: PASSED)
```


---

## 참조

**References:** nextjs-patterns.md, fastapi-patterns.md, security-checklist.md

