---
name: architecture
description: System architecture design - frontend/backend structure, dependencies, auth strategy
version: 1.0.0
---

# Architecture Phase

## 개요

요구사항 문서를 기반으로 완전한 시스템 아키텍처를 설계합니다. 이 단계는 구현 단계를 안내하는 포괄적인 `architecture.md`를 생성합니다.

**핵심 결과물**: 프론트엔드 컴포넌트 구조, 백엔드 레이어 분리, 인증 전략 및 모든 의존성을 다루는 상세한 아키텍처 문서

---

## 전제 조건

### State 요구사항
```javascript
state.phases.requirements === "completed"
```

### 필수 문서
| 문서 | 경로 | 필수 내용 |
|------|------|----------|
| PRD | `.omc/web-projects/{service}/docs/prd.md` | 핵심 기능, 사용자 플로우 |
| API Spec | `.omc/web-projects/{service}/docs/api-spec.md` | 모든 엔드포인트, request/response |
| DB Schema | `.omc/web-projects/{service}/docs/db-schema.md` | 테이블, 관계 |
| Tech Stack | `.omc/web-projects/{service}/docs/tech-stack.md` | 프레임워크 버전 |

---

## 입력

Requirements phase의 모든 출력:
- `prd.md` - 기능 요구사항 및 사용자 플로우
- `api-spec.md` - API 엔드포인트 명세
- `db-schema.md` - Database 스키마 디자인
- `tech-stack.md` - 버전이 포함된 기술 스택

---

## 출력

| 출력 | 경로 | 설명 |
|------|------|------|
| architecture.md | `.omc/web-projects/{service}/docs/architecture.md` | 완전한 시스템 아키텍처 |

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| architect | opus | 시스템 아키텍처 설계 및 자체 검토 |

---

## 단계별 프로세스

### Step 1: 의존성 확인

시작하기 전 검증:

```javascript
// Check phase dependency
const state = readState();
if (state.phases.requirements !== 'completed') {
  throw new Error('requirements phase must complete first');
}

// Check required documents exist
const paths = getProjectPaths(state.serviceName);
const required = ['prd', 'apiSpec', 'dbSchema', 'techStack'];
for (const doc of required) {
  if (!fs.existsSync(paths.documents[doc])) {
    throw new Error(`Missing required document: ${doc}`);
  }
}
```

### Step 2: 시스템 아키텍처 설계

opus 모델로 `architect` agent에 위임

**Task 프롬프트:**

```
Design system architecture for {serviceName} service.

Read these documents:
- PRD: {prd.md path}
- API Spec: {apiSpec.md path}
- DB Schema: {dbSchema.md path}
- Tech Stack: {techStack.md path}

Design the following architecture components:

## 1. Frontend Architecture (Next.js)

### App Router Structure
- Define page routes based on PRD user flows
- Layout hierarchy (root, nested layouts)
- Loading and error boundaries

### Component Architecture
Organize into three tiers:

**components/ui/** (shadcn/ui basics)
- Button, Input, Card, Dialog, Form
- Select, Checkbox, Radio
- Toast, Alert, Badge
- Install via: npx shadcn@latest add {component}

**components/common/** (service-wide reusable)
- Header, Footer, Navigation
- Sidebar, Breadcrumb
- PageContainer, Section
- Props design for reusability

**components/features/** (feature-specific)
- Based on PRD features (LoginForm, ProductCard, etc.)
- Compose from ui/ and common/
- Feature-isolated state and logic

### Design Token System
Create lib/design-tokens.ts with:
- Color palette (from design-analysis)
- Typography scale
- Spacing system
- Border radius
- Shadow definitions

### shadcn/ui Theming Strategy
- Customize globals.css CSS variables
- Map design tokens to Tailwind config
- Dark mode support (if required)

## 2. Backend Architecture (FastAPI)

### Clean 3-Layer Structure

**api/** - API Layer
```
api/
  v1/
    endpoints/
      {resource}.py  # Routes per resource
    router.py        # Combine all routers
  dependencies.py    # Shared dependencies (auth, db session)
```

**services/** - Business Logic Layer
```
services/
  {resource}_service.py  # Business logic per domain
```

**repositories/** - Data Access Layer
```
repositories/
  {resource}_repository.py  # DB operations per model
```

**models/** - SQLAlchemy Models
```
models/
  {entity}.py  # One file per entity
  __init__.py  # Export all models
```

**schemas/** - Pydantic Schemas
```
schemas/
  {entity}.py  # Create, Update, Response schemas
```

**core/** - Core Utilities
```
core/
  config.py    # Environment variables, settings
  security.py  # Auth helpers, password hashing
  database.py  # DB session, engine setup
```

## 3. Authentication/Authorization Strategy

Based on PRD requirements, select ONE:

| Service Type | Recommended Auth | Implementation |
|--------------|------------------|----------------|
| Blog/Portfolio | JWT | core/security.py + api/dependencies.py |
| Social Network | OAuth2 | OAuth providers (Google, GitHub) |
| Admin System | Session | Session middleware + cookies |
| Public API | API Key + JWT | Multiple auth schemes |
| No Auth | None | Skip auth layer |

Document the chosen strategy with:
- Token format and expiration
- Refresh token handling (if applicable)
- Protected route patterns
- Role-based access (if applicable)

## 4. Error Handling Strategy

### Backend
- Custom exception classes per domain
- Global exception handler
- Consistent error response format:
  ```json
  {"detail": "message", "code": "ERROR_CODE"}
  ```

### Frontend
- Error boundary components
- API error handling hook
- Toast notifications for user feedback

## 5. Database Migration Strategy

Use Alembic with autogenerate:
```bash
alembic revision --autogenerate -m "message"
alembic upgrade head
```

Define migration workflow:
1. Model changes
2. Generate migration
3. Review migration file
4. Apply migration

## 6. Environment Variables

### Backend (.env.example)
```
DATABASE_URL=postgresql://user:pass@localhost:5432/db
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### Frontend (.env.local.example)
```
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
```

## 7. Dependencies

### Frontend (package.json)
- next: 14+
- react: 18+
- typescript: 5+
- tailwindcss: 3+
- @radix-ui/* (via shadcn)
- zustand (state management)
- zod (validation)

### Backend (requirements.txt)
- fastapi
- uvicorn[standard]
- sqlalchemy[asyncio]
- pydantic
- pydantic-settings
- alembic
- python-jose[cryptography] (JWT)
- passlib[bcrypt] (password hashing)
- asyncpg (PostgreSQL async)

Output: {architecture.md path}
```

### Step 3: 자체 검토

Architect가 다음 기준으로 아키텍처 검증:

**실현 가능성 검사:**
- [ ] 이 아키텍처로 모든 PRD 기능 구현 가능
- [ ] API 명세 엔드포인트가 백엔드 라우트에 매핑됨
- [ ] DB 스키마가 모델 정의와 일치
- [ ] 기술 스택 버전이 호환됨

**확장성 검사:**
- [ ] 컴포넌트 구조가 성장을 지원
- [ ] Services 레이어가 비즈니스 로직 확장을 허용
- [ ] API 버전 관리 전략 정의됨

**보안 검사:**
- [ ] 서비스 유형에 적합한 인증 전략
- [ ] 환경 변수에 민감한 설정
- [ ] 하드코딩된 자격 증명 없음
- [ ] CORS 구성 정의됨

검사 실패 시 architect가 수정하고 재검증

### Step 4: Architecture 문서 저장

자체 검토 통과 후:

1. 출력 경로에 `architecture.md` 작성
2. state 업데이트:
   ```javascript
   state.phases.architecture = 'completed';
   state.currentPhase = 'architecture';
   writeState(state);
   ```

---

## Architecture 문서 구조

출력 `architecture.md`는 다음 구조를 따라야 함:

```markdown
# System Architecture: {Service Name}

## 1. Overview
Brief architecture summary

## 2. Frontend Architecture
### 2.1 App Router Structure
### 2.2 Component Architecture
### 2.3 Design Token System
### 2.4 State Management

## 3. Backend Architecture
### 3.1 Project Structure
### 3.2 API Layer
### 3.3 Service Layer
### 3.4 Repository Layer
### 3.5 Models and Schemas

## 4. Authentication & Authorization
### 4.1 Strategy
### 4.2 Implementation Details
### 4.3 Protected Routes

## 5. Error Handling
### 5.1 Backend Exceptions
### 5.2 Frontend Error Boundaries

## 6. Database
### 6.1 Migration Strategy
### 6.2 Connection Configuration

## 7. Environment Configuration
### 7.1 Backend Environment Variables
### 7.2 Frontend Environment Variables

## 8. Dependencies
### 8.1 Frontend Dependencies
### 8.2 Backend Dependencies

## 9. Architect Review
- Feasibility: PASSED
- Scalability: PASSED
- Security: PASSED
```

---

## 검증

phase 완료 표시 전 모든 검사 완료:

- [ ] `architecture.md`가 출력 경로에 존재
- [ ] Frontend 컴포넌트 아키텍처 정의됨 (ui/, common/, features/)
- [ ] Backend 3-레이어 구조 정의됨 (api/, services/, repositories/)
- [ ] Design token 시스템 명시됨
- [ ] 인증 전략 선택 및 문서화됨
- [ ] 오류 처리 전략 정의됨
- [ ] 환경 변수 문서화됨
- [ ] 모든 의존성이 버전과 함께 나열됨
- [ ] Architect 자체 검토 통과 (3개 검사 모두)
- [ ] `state.phases.architecture === "completed"`

---

## 오류 처리

| 오류 | 처리 |
|------|------|
| 필수 문서 누락 | 중지, 사용자에게 누락된 문서 알림 |
| Requirements phase 미완료 | 중지, 사용자에게 requirements를 먼저 완료하도록 알림 |
| Architect 검토 실패 | 아키텍처 수정, 재검토 (최대 3회 시도) |
| 호환되지 않는 기술 스택 | 사용자에게 알림, 호환 가능한 대안 제안 |

**실패 시:**
```javascript
updatePhaseError('architecture', error);
console.log('Architecture phase failed. To retry: /web-autopilot:architecture');
```

---

## 참조

- `references/nextjs-patterns.md` - Next.js App Router 모범 사례
- `references/fastapi-patterns.md` - FastAPI clean architecture 패턴
- `references/security-checklist.md` - 보안 요구사항 및 체크리스트
