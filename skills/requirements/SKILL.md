---
name: requirements
description: Requirements gathering phase - user interview, PRD creation, API/DB specification
version: 1.0.0
phase: 2
depends_on: design-analysis
---

# Requirements Phase

## 개요

구조화된 사용자 인터뷰와 명세 생성을 통해 디자인 분석을 구체적인 제품 요구사항으로 변환합니다. 이 단계는 시각적 디자인 이해와 기술 구현을 연결합니다.

**핵심 책임:**
- 디자인 분석에서 요구사항 추출
- 기능 명확화를 위한 사용자 인터뷰
- PRD, API 명세, DB 스키마 생성
- 기술 스택 검증/문서화

---

## 전제 조건

### State 의존성
```
phases.design-analysis === "completed"
```

### 필수 입력
| 문서 | 경로 | 설명 |
|------|------|------|
| design-analysis.md | `.omc/web-projects/{service}/docs/` | 컴포넌트 목록, design token, 화면 플로우 |

### 선택적 입력
| 문서 | 경로 | 설명 |
|------|------|------|
| tech-stack.md | 프로젝트 루트 또는 docs 폴더 | 버전이 포함된 커스텀 기술 스택 |

---

## 출력

| 출력 | 경로 | 설명 |
|------|------|------|
| prd.md | `.omc/web-projects/{service}/docs/` | 제품 요구사항 문서 |
| api-spec.md | `.omc/web-projects/{service}/docs/` | API 엔드포인트 명세 |
| db-schema.md | `.omc/web-projects/{service}/docs/` | 데이터베이스 테이블 정의 |
| tech-stack.md | `.omc/web-projects/{service}/docs/` | 최종 기술 스택 |

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| analyst | opus | 요구사항 추출, PRD 초안 작성, 사용자 인터뷰 |
| architect-low | haiku | 기술 스택 검증 |

---

## 단계별 프로세스

### Step 1: Phase 의존성 검증

진행하기 전 state 확인:
```javascript
const state = readState();
if (state.phases['design-analysis'] !== 'completed') {
  throw Error(`design-analysis must complete first`);
}
```

**실패 시:** 사용자에게 `/web-autopilot:design-analysis`를 먼저 실행하도록 안내

---

### Step 2: Design Analysis 로드

`.omc/web-projects/{service}/docs/design-analysis.md` 읽기

**추출:**
- 컴포넌트 인벤토리
- 사용자 플로우가 포함된 화면/페이지 목록
- Design token 및 인터랙션 패턴
- 콘텐츠 구조 및 텍스트 레이블

---

### Step 3: 요구사항 추출 (Analyst Agent)

**위임 대상:** `analyst` (Opus)

**프롬프트:**
```
Analyze design-analysis.md for {service-name} and extract:

1. Feature List - Core features visible in designs
2. User Flows - Primary and secondary journeys
3. Data Requirements - Entities and relationships
4. API Requirements - CRUD operations, special endpoints

Output: Draft requirements document in markdown
```

---

### Step 4: 사용자 인터뷰 (AskUserQuestion)

**목적:** 요구사항 명확화 및 선호도 수집

#### 4.1 핵심 기능
```yaml
AskUserQuestion:
  type: "requirement"
  question: "I've identified these core features: [list]. Which are must-haves for MVP?"
  options: ["All correct", "Remove: [specify]", "Add: [specify]"]
```

#### 4.2 인증 전략
```yaml
AskUserQuestion:
  type: "preference"
  question: "What authentication approach do you need?"
  options:
    - "JWT tokens (simple, stateless)"
    - "OAuth2 (Google, GitHub, etc.)"
    - "Session-based (traditional, secure)"
    - "API Key + JWT (for public API)"
    - "No authentication needed"
```

**인증 권장사항:**
| 서비스 유형 | 권장 |
|------------|------|
| Blog, Portfolio | JWT |
| Social Network | OAuth2 |
| Internal Admin | Session |
| Public API | API Key + JWT |

#### 4.3 규모 요구사항
```yaml
AskUserQuestion:
  type: "constraint"
  question: "Performance and scale requirements?"
  options: ["Small (<100 users)", "Medium (100-10K)", "Large (10K+)", "Real-time needed"]
```

#### 4.4 Database
```yaml
AskUserQuestion:
  type: "preference"
  question: "Database requirements?"
  options: ["Use defaults (PostgreSQL)", "Need caching (Redis)", "Need full-text search"]
```

#### 4.5 통합
```yaml
AskUserQuestion:
  type: "requirement"
  question: "External integrations needed?"
  options: ["Email", "Payments (Stripe)", "File storage (S3)", "Analytics", "None"]
```

---

### Step 5: PRD 생성

**구조:**
```markdown
# PRD: {Service Name}

## 1. Overview
- Description, target users, value proposition

## 2. Functional Requirements
### 2.1 Features
| Feature | Priority | Description |
### 2.2 User Flows
### 2.3 Data Entities

## 3. Non-Functional Requirements
- Performance, security, scalability

## 4. Authentication
- Chosen strategy and implementation notes

## 5. Out of Scope
```

**참조:** `references/prd-template.md`

---

### Step 6: API 명세 생성

**구조:**
```markdown
# API Specification: {Service Name}

## Base URL
`/api/v1`

## Authentication
- Type: [JWT/OAuth2/Session/None]
- Header: `Authorization: Bearer {token}`

## Endpoints
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | /users | Create user | No |
| GET | /users/:id | Get user | Yes |

### POST /users
Request: { email, password, name }
Response (201): { id, email, name, createdAt }

## Error Responses
| Status | Description |
|--------|-------------|
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
```

**참조:** `references/api-spec-format.md`

---

### Step 7: Database 스키마 생성

**구조:**
```markdown
# Database Schema: {Service Name}

## Tables
### users
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | NOT NULL |
| created_at | TIMESTAMP | DEFAULT NOW() |

## Indexes
| Table | Column(s) | Type |
|-------|-----------|------|
| users | email | UNIQUE |

## Relationships
- users (1) -> posts (N)
```

**참조:** `references/db-schema-guide.md`

---

### Step 8: 기술 스택 검증

**`tech-stack.md`가 존재하면:**
버전 호환성 검증을 위해 `architect-low` (Haiku)에 위임

**tech-stack.md가 없으면 기본값 사용:**
```markdown
# Tech Stack: {Service Name}

## Frontend
- Next.js 14+, TypeScript 5.0+, Tailwind CSS 3.4+
- shadcn/ui, Zustand, Jest + Playwright

## Backend
- FastAPI 0.110+, Python 3.10+
- SQLAlchemy 2.0+, Pydantic 2.0+, Alembic, pytest

## Database
- PostgreSQL 15+, asyncpg
```

---

### Step 9: 출력 저장

```javascript
const paths = getProjectPaths(serviceName);
writeFile(paths.documents.prd, prdContent);
writeFile(paths.documents.apiSpec, apiSpecContent);
writeFile(paths.documents.dbSchema, dbSchemaContent);
writeFile(paths.documents.techStack, techStackContent);
```

---

### Step 10: State 업데이트

```javascript
updatePhaseStatus('requirements', 'completed');
const state = readState();
state.documents = {
  ...state.documents,
  prd: paths.documents.prd,
  apiSpec: paths.documents.apiSpec,
  dbSchema: paths.documents.dbSchema,
  techStack: paths.documents.techStack
};
writeState(state);
```

---

## 검증 체크리스트

- [ ] design-analysis phase 완료 (의존성 충족)
- [ ] design-analysis.md 읽고 분석됨
- [ ] 사용자 인터뷰 완료 (인증 전략 확인됨)
- [ ] prd.md 존재 (기능, 사용자 플로우, 데이터 엔티티, NFR 포함)
- [ ] api-spec.md 존재 (엔드포인트, 스키마, 오류 응답 포함)
- [ ] db-schema.md 존재 (테이블, 인덱스, 관계 포함)
- [ ] tech-stack.md 존재 (기본 또는 커스텀)
- [ ] API 명세가 모든 PRD 기능을 포함
- [ ] DB 스키마가 모든 API 작업을 지원
- [ ] State: `phases.requirements === "completed"`

---

## 오류 처리

| 오류 | 조치 |
|------|------|
| 의존성 미충족 | 사용자에게 design-analysis를 먼저 실행하도록 안내 |
| design-analysis.md 누락 | state 확인, 파일 존재 확인 |
| 인터뷰 타임아웃 | 기본값 사용, 가정 문서화 |
| 기술 스택 검증 실패 | 문제 보고, 해결되지 않으면 기본값 사용 |
| 불완전한 기능 매핑 | 매핑되지 않은 요소 나열, TBD로 표시 |

---

## 참조

- `references/prd-template.md` - 완전한 PRD 구조
- `references/api-spec-format.md` - OpenAPI 규칙
- `references/db-schema-guide.md` - Database 디자인 패턴
- `references/interview-questions.md` - 확장된 질문 은행

---

## 사용자 확인

완료 후:
```
Requirements phase complete.

Generated:
- .omc/web-projects/{service}/docs/prd.md
- .omc/web-projects/{service}/docs/api-spec.md
- .omc/web-projects/{service}/docs/db-schema.md
- .omc/web-projects/{service}/docs/tech-stack.md

Next: architecture

Say "continue" or run /web-autopilot:architecture
```
