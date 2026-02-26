# Web Service Autopilot - Implementation Plan

## Overview

새로운 skill `web-autopilot`을 구현하여 Figma 디자인부터 완성된 웹서비스까지 자동화된 개발 파이프라인 구축.

**핵심 철학**:
- 검증 후 리팩토링 사이클 (Ralph 패턴)을 통한 안정적인 서비스 완성
- **단계별 확인 진행**: 각 phase 완료 후 사용자 확인
- **유연한 복구**: 실패 시 특정 phase부터 재실행

## Design Decisions

### 1. Orchestration 단위 분할: Phase별 독립 Skills

**결정**: Option B - Phase별 독립 skills 채택

**이유**:
- 단계별 확인하며 진행 (사용자가 각 phase 결과 검토)
- 실패 시 특정 phase만 재실행 가능
- 디버깅과 개발 편의성

**구조**:
```
.claude/plugins/web-autopilot/skills/
  ├── design-analysis/
  │   └── SKILL.md
  ├── requirements/
  │   └── SKILL.md
  ├── architecture/
  │   └── SKILL.md
  ├── implementation/
  │   └── SKILL.md
  ├── qa/
  │   └── SKILL.md
  └── completion/
      └── SKILL.md
```

**사용 흐름**:
```bash
/web-autopilot:design-analysis project-brief.md
→ 결과 확인
→ 사용자: 좋아, 다음 단계 진행

/web-autopilot:requirements
→ 결과 확인
→ 사용자: 다음

/web-autopilot:architecture
→ 결과 확인
→ 사용자: API 설계 수정 필요. 다시

/web-autopilot:architecture
→ 수정된 결과 확인
→ 사용자: 좋아, 다음

... (계속)
```

### 2. SKILL.md 작성 원칙: Progressive Disclosure

**핵심 개념**: 점진적 공개 - 최소한의 정보로 시작, 필요할 때만 상세 정보 참조

**파일 구조**:
```
.claude/plugins/web-autopilot/
  ├── COMMON.md                    # 공통 컨벤션 (모든 phase가 따르는 규칙)
  └── skills/
      ├── design-analysis/
      │   ├── SKILL.md             # 핵심 가이드 (500줄 이하)
      │   ├── references/          # 상세 문서 (필요시 참조)
      │   │   ├── figma-api.md
      │   │   ├── design-tokens-guide.md
      │   │   └── component-mapping.md
      │   ├── scripts/             # 실행 가능한 유틸리티
      │   │   └── fetch-figma.js
      │   └── assets/              # 템플릿, 샘플 데이터
      │       ├── design-analysis-template.md
      │       └── sample-output.md
      ├── requirements/
      │   ├── SKILL.md
      │   ├── references/
      │   │   ├── prd-template.md
      │   │   ├── api-spec-format.md
      │   │   └── interview-questions.md
      │   └── assets/
      │       └── prd-example.md
      ... (각 phase 동일 구조)
```

**SKILL.md 구성**:
1. **Name & Description** (명확한 역할)
2. **Inputs/Outputs** (간결하게)
3. **Agents** (누구에게 위임)
4. **Step-by-step Guide** (쪼개진 작업 단위)
5. **Verification** (검증 기준)
6. **References** (상세 문서 링크만)

**Agent 동작**:
- SKILL.md 먼저 읽음 (핵심만)
- 필요하면 references/ 읽음
- 필요하면 scripts/ 실행
- 필요하면 assets/ 로드

### 3. 명시 vs 컨벤션 전략

**Phase마다 다른 것** → SKILL.md에 명시:
- Phase 고유 작업
- 사용할 agent
- 입출력 문서
- Step-by-step 가이드

**모든 Phase가 동일한 것** → COMMON.md에 컨벤션:
- State 읽기/쓰기 프로토콜
- 파일 경로 규칙
- Agent 호출 형식
- 에러 핸들링 패턴
- 검증 표준

**Orchestrator 역할**: 명시적 안내
```markdown
When user calls: /web-autopilot:requirements

Orchestrator does:
1. Read COMMON.md
2. Read skills/requirements/SKILL.md
3. Pass both to agent with instruction:
   "Follow COMMON.md conventions, execute SKILL.md tasks"
4. Agent checks state: phases.design-analysis === "completed"
5. If not, error and stop
6. If yes, proceed with requirements phase
```

**Phase 의존성 체크** (State 기반):
```javascript
// COMMON.md에 명시된 체크 로직
const state = readState();
const dependencies = {
  "requirements": "design-analysis",
  "architecture": "requirements",
  "implementation": "architecture",
  "qa": "implementation",
  "completion": "qa"
};

const requiredPhase = dependencies[currentPhase];
if (requiredPhase && state.phases[requiredPhase] !== "completed") {
  throw Error(`${requiredPhase} phase must complete first`);
}
```

---

## System Architecture

### Tech Stack (Default)
- **Frontend**: Next.js + TypeScript + Tailwind CSS + shadcn/ui
- **Backend**: FastAPI
- **Database**: PostgreSQL
- **추가 스택**: `tech-stack.md` 파일로 전달 (버전 명시 포함)

**UI 라이브러리 철학:**
- **shadcn/ui** 사용 (Radix UI 기반, 접근성 보장)
- **Figma 디자인 충실도**: 레이아웃, 위치, 색상, 간격 등 픽셀 단위로 정확하게 구현
- **공통 컴포넌트 재사용**: 서비스 전체에서 일관된 UI/UX 유지

### Project Structure
```
projects/
  {service-name}-frontend/
    ├── components/
    │   ├── ui/            # shadcn/ui 기본 컴포넌트 (Button, Input, Card...)
    │   ├── common/        # 서비스 공통 컴포넌트 (Header, Footer, Navigation...)
    │   └── features/      # 기능별 특화 컴포넌트 (LoginForm, ProductCard...)
    ├── app/               # Next.js App Router
    ├── lib/
    │   └── design-tokens.ts  # Figma에서 추출한 디자인 토큰
    ├── styles/
    │   └── globals.css    # shadcn/ui 테마 커스터마이징
    └── package.json

  {service-name}-backend/
    ├── api/
    ├── models/
    ├── tests/
    └── requirements.txt (FastAPI)
```

### Document Artifacts
```
.omc/web-projects/{service-name}/
  ├── docs/
  │   ├── design-analysis.md     # Figma 디자인 분석 결과
  │   ├── prd.md                 # 핵심 요구사항
  │   ├── api-spec.md            # API 엔드포인트 명세
  │   ├── db-schema.md           # DB 테이블 스키마
  │   ├── tech-stack.md          # 기술 스택 (버전 포함)
  │   └── architecture.md        # 시스템 아키텍처
  └── figma-designs/             # Figma MCP로 가져온 디자인 이미지
      ├── screen-01.png
      ├── screen-02.png
      └── components.png
```

### State Management
- `.omc/state/web-autopilot-state.json` - 파이프라인 진행 상태
- Ralph 패턴 활용으로 QA 사이클 자동 반복

---

## Pipeline Phases

### Phase 0: Initialization
**목적**: 입력 파일 읽기 및 초기 설정

**Agents**: None (orchestrator 직접 처리)

**작업**:
1. Skill 실행 시 지정된 파일 읽기 (Figma 링크, 프로젝트 정보 포함)
2. `tech-stack.md` 파일 존재 여부 확인
3. 프로젝트 폴더 구조 초기화
4. State 파일 생성

**산출물**:
- `.omc/state/web-autopilot-state.json`
- `projects/{service-name}-frontend/`, `projects/{service-name}-backend/` 폴더

---

### Phase 1: Design Analysis
**목적**: Figma 디자인 분석 및 UI/UX 이해

**Agents**:
- `vision` (Sonnet) - 디자인 이미지 분석
- `designer` (Sonnet) - UI/UX 전문가 관점

**작업**:
1. Figma MCP 툴로 디자인 파일 가져오기:
   - 입력 파일에서 Figma URL 파싱 (예: `https://figma.com/file/{fileKey}/...`)
   - Figma MCP 서버의 사용 가능한 툴 확인 (예: `mcp__figma__get_file`, `mcp__figma__get_images`)
   - MCP 툴 호출하여 디자인 데이터 및 이미지 fetch
   - **에러 처리**: Figma 링크가 유효하지 않거나 접근 불가 시 사용자에게 알림
   - 가져온 디자인 이미지를 임시 폴더에 저장 (`.omc/web-projects/{service-name}/figma-designs/`)
2. Vision 에이전트가 화면별 분석:
   - Figma 이미지를 Read 툴로 읽어서 시각적 분석
   - 레이아웃 구조 (그리드, 플렉스박스 패턴, 정확한 간격/여백)
   - 컴포넌트 목록 (버튼, 입력 폼, 카드 등)
   - **디자인 토큰 추출** (구현에 필요한 정확한 값):
     - 색상 팔레트: Primary, Secondary, Background, Text 등 HEX/RGB 값
     - 타이포그래피: 폰트 패밀리, 크기, 행간, 굵기
     - 간격 시스템: 여백, 패딩 (4px, 8px, 16px 등)
     - 경계선: Border radius, 두께, 색상
     - 그림자: Box shadow 값
   - 인터랙션 패턴 (호버, 클릭, 애니메이션)
3. Designer 에이전트가 구현 관점 분석:
   - **재사용 가능한 컴포넌트 식별** (공통 컴포넌트 후보):
     - UI 기본: 버튼, 입력, 카드, 모달 등
     - 서비스 공통: 헤더, 푸터, 네비게이션, 사이드바
     - 기능별: 로그인 폼, 상품 카드, 유저 프로필 등
   - shadcn/ui 매핑: 어떤 shadcn/ui 컴포넌트를 사용할지 결정
   - 반응형 레이아웃 전략 (모바일/태블릿/데스크톱 breakpoints)
   - 상태 관리 필요성 (전역 상태 vs 로컬 상태)

**산출물**:
- `.omc/web-projects/{service-name}/docs/design-analysis.md`

**검증**: 컴포넌트 목록과 화면 플로우가 명확히 정의되었는가?

---

### Phase 2: Requirements Definition
**목적**: 사용자와 대화를 통해 기능 요구사항 확정

**Agents**:
- `analyst` (Opus) - 요구사항 도출 및 분석
- `architect-low` (Haiku) - 기술 스택 검증

**작업**:
1. Analyst가 디자인 분석 기반 요구사항 초안 작성
2. 사용자와 대화 (AskUserQuestion 활용):
   - 핵심 기능 확인
   - 사용자 플로우 검증
   - 비기능 요구사항 (성능, 보안 등)
3. API 엔드포인트 초안 작성
4. DB 스키마 초안 작성
5. Tech stack 파일 읽고 검증 (버전 호환성)

**산출물**:
- `.omc/web-projects/{service-name}/docs/prd.md`
- `.omc/web-projects/{service-name}/docs/api-spec.md`
- `.omc/web-projects/{service-name}/docs/db-schema.md`
- `.omc/web-projects/{service-name}/docs/tech-stack.md`

**검증**: API 명세와 DB 스키마가 PRD의 모든 기능을 커버하는가?

---

### Phase 3: Architecture Design
**목적**: 시스템 아키텍처 설계

**Agents**:
- `architect` (Opus) - 아키텍처 설계 전문가

**작업**:
1. 요구사항 문서 분석
2. 시스템 아키텍처 설계:
   - **Frontend 아키텍처**:
     - App Router 구조 (Next.js 13+)
     - **컴포넌트 아키텍처**:
       - `components/ui/`: shadcn/ui 기본 컴포넌트 (Button, Input, Card, Dialog 등)
       - `components/common/`: 서비스 공통 컴포넌트 (Header, Footer, Navigation, Sidebar 등)
       - `components/features/`: 기능별 컴포넌트 (LoginForm, ProductList, UserProfile 등)
     - 디자인 토큰 시스템 (`lib/design-tokens.ts`): Figma에서 추출한 색상, 간격, 타이포그래피
     - shadcn/ui 테마 커스터마이징 전략
   - Backend API 구조 및 레이어 분리
   - DB 마이그레이션 전략
   - 인증/인가 방식
   - 에러 핸들링 전략
3. 의존성 목록 작성:
   - Frontend: next, react, typescript, tailwindcss, shadcn/ui 컴포넌트들
   - Backend: fastapi, sqlalchemy, pydantic, alembic
4. 환경 변수 정의 (.env template)

**산출물**:
- `.omc/web-projects/{service-name}/docs/architecture.md`

**검증**: Architect 자체 검토 (실현 가능성, 확장성, 보안)

---

### Phase 4: Implementation
**목적**: 코드 구현 (Backend → Frontend 순차)

#### Phase 4.1: Backend Implementation

**Agents**:
- `executor-high` (Opus) - FastAPI 백엔드 구현

**작업**:
1. 프로젝트 초기화 (FastAPI 보일러플레이트)
2. DB 모델 구현 (SQLAlchemy)
3. API 엔드포인트 구현:
   - 각 엔드포인트별 비즈니스 로직
   - 입력 검증 (Pydantic)
   - 에러 핸들링
4. DB 마이그레이션 스크립트 (Alembic)
5. 환경 설정 파일 (.env.example)

**산출물**: `projects/{service-name}-backend/` 전체 구현

**검증**:
- Build 성공 (uvicorn 실행 가능)
- Type check 통과 (mypy)
- API spec과 일치하는가?

#### Phase 4.2: Frontend Implementation

**Agents**:
- `designer-high` (Opus) - Next.js 프론트엔드 구현

**작업**:
1. 프로젝트 초기화 (Next.js + TypeScript + Tailwind CSS)
2. **shadcn/ui 설정**:
   - `npx shadcn-ui@latest init` 실행
   - 필요한 기본 컴포넌트 설치 (Button, Input, Card, Dialog, Form 등)
   - Tailwind 테마 커스터마이징 (Figma 색상 팔레트 반영)
3. **디자인 토큰 추출 및 적용**:
   - Figma design-analysis.md에서 색상, 간격, 타이포그래피 추출
   - `lib/design-tokens.ts`에 정의
   - `globals.css`에 CSS 변수로 적용
4. **컴포넌트 구현** (공통 컴포넌트 우선):
   - **Phase A: UI 기본 컴포넌트** (`components/ui/`)
     - shadcn/ui 컴포넌트를 Figma 디자인에 맞게 커스터마이징
   - **Phase B: 서비스 공통 컴포넌트** (`components/common/`)
     - Header, Footer, Navigation, Sidebar 등
     - 재사용 가능하도록 props 설계
   - **Phase C: 기능별 컴포넌트** (`components/features/`)
     - LoginForm, ProductCard, UserProfile 등
     - 공통 컴포넌트 조합하여 구성
5. **페이지 구현** (App Router):
   - Figma 화면별 페이지 구현
   - **Figma 충실도 검증**: 레이아웃, 위치, 간격, 색상이 Figma와 정확히 일치하는가?
6. API 통합:
   - API spec 기반 타입 정의
   - fetch/axios로 백엔드 연동
7. 상태 관리 (Context API / Zustand)
8. 반응형 디자인 (Figma 디자인의 모바일/태블릿/데스크톱 버전)

**산출물**: `projects/{service-name}-frontend/` 전체 구현

**검증**:
- Build 성공 (next build)
- Type check 통과 (tsc)
- **Figma 충실도**: 레이아웃, 색상, 간격이 Figma 디자인과 픽셀 단위로 일치
- shadcn/ui 컴포넌트가 올바르게 사용되었는가?
- 공통 컴포넌트가 재사용되고 있는가?

---

### Phase 5: QA & Refactoring Loop (Ralph Pattern)
**목적**: 검증 → 리팩토링 사이클 반복, Architect 승인까지

**핵심**: Ralph 패턴 - "완료"를 주장하기 전에 반드시 검증 통과

#### Phase 5.1: Unit Testing

**Agents**:
- `tdd-guide` (Sonnet) - 단위 테스트 작성 가이드
- `executor` (Sonnet) - 테스트 구현

**작업**:
1. Backend unit tests (pytest):
   - 각 API 엔드포인트 테스트
   - DB 모델 테스트
   - 비즈니스 로직 테스트
2. Frontend unit tests (Jest + React Testing Library):
   - 컴포넌트 테스트
   - 유틸 함수 테스트

**검증**: 모든 unit tests 통과

**실패 시**: Executor가 수정 후 재실행

---

#### Phase 5.2: E2E Testing

**Agents**:
- `qa-tester-high` (Opus) - E2E 테스트 설계 및 실행

**작업**:
1. E2E 테스트 시나리오 작성 (PRD 기반)
2. Backend E2E tests:
   - API 통합 테스트
   - DB 트랜잭션 테스트
3. Frontend E2E tests (Playwright/Cypress):
   - 사용자 플로우 테스트
   - 크로스 브라우저 테스트

**검증**: 모든 E2E tests 통과

**실패 시**: Executor가 수정 후 재실행

---

#### Phase 5.3: Build & Type Check

**Agents**:
- `build-fixer` (Sonnet) - 빌드 에러 수정

**작업**:
1. Backend build:
   - uvicorn 실행 확인
   - mypy type check
2. Frontend build:
   - next build 성공
   - tsc --noEmit

**검증**: 모든 빌드 성공, 타입 에러 없음

**실패 시**: Build-fixer가 수정 후 재실행

---

#### Phase 5.4: Architect Code Review

**Agents**:
- `architect` (Opus) - 코드 품질 및 아키텍처 검토

**작업**:
1. 코드 리뷰:
   - 아키텍처 준수 여부
   - 코드 품질 (가독성, 유지보수성)
   - 베스트 프랙티스 준수
   - 보안 취약점 확인
2. 개선 제안 목록 작성

**산출물**:
- Review 통과 → Phase 5.6으로
- Review 실패 → 개선 제안 목록 → Phase 5.5로

---

#### Phase 5.5: Refactoring

**Agents**:
- `executor-high` (Opus) - 리팩토링 수행

**작업**:
1. Architect 개선 제안 반영:
   - 코드 구조 개선
   - 중복 제거
   - 성능 최적화
   - 보안 강화

**산출물**: 리팩토링된 코드

**다음**: Phase 5.1로 돌아가서 재검증 (Ralph Loop)

---

#### Phase 5.6: Final Verification & Launch Test

**Agents**:
- `architect` (Opus) - 최종 승인
- `security-reviewer` (Opus) - 보안 검토
- `qa-tester-high` (Opus) - 실제 실행 확인

**작업**:
1. Architect 최종 승인 확인
2. Security review:
   - OWASP Top 10 체크
   - 인증/인가 검증
   - SQL Injection, XSS 등 취약점 확인
3. 실제 실행 테스트:
   - Backend 서버 실행 (uvicorn)
   - Frontend 서버 실행 (next dev)
   - API 실제 호출 테스트
   - DB 연결 확인

**검증**:
- ✅ All unit tests passed
- ✅ All E2E tests passed
- ✅ Build successful (no errors)
- ✅ Architect approval received
- ✅ Security review passed
- ✅ Services running successfully

**승인**: Architect가 "APPROVED" 시 Phase 6으로

**거부**: "REJECTED" 시 Phase 5.5로 돌아가서 재작업

---

### Phase 6: Completion & Documentation
**목적**: 최종 문서 정리 및 상태 클린업

**Agents**:
- `writer` (Haiku) - README 및 문서 작성

**작업**:
1. README.md 작성:
   - 프로젝트 개요
   - 설치 방법
   - 실행 방법
   - API 문서 링크
2. 환경 설정 가이드 (.env.example 설명)
3. State 파일 정리 (삭제, active: false 설정하지 말고)

**산출물**:
- `projects/{service-name}-frontend/README.md`
- `projects/{service-name}-backend/README.md`

**완료 조건**: 모든 문서 작성 완료, state 파일 삭제

---

## Backend Domain - Deep Design

### Architecture Decisions

#### 1. Project Structure: Clean Architecture (3-Layer)

```
app/
├── api/                    # API Layer (FastAPI routes)
│   ├── v1/
│   │   ├── endpoints/
│   │   │   ├── users.py
│   │   │   ├── auth.py
│   │   │   └── products.py
│   │   └── router.py
│   └── dependencies.py
├── services/               # Business Logic Layer
│   ├── user_service.py
│   ├── auth_service.py
│   └── product_service.py
├── repositories/           # Data Access Layer
│   ├── user_repository.py
│   └── product_repository.py
├── models/                 # SQLAlchemy Models
│   ├── user.py
│   └── product.py
├── schemas/                # Pydantic Schemas
│   ├── user.py
│   └── product.py
└── core/                   # Core utilities
    ├── config.py
    ├── security.py
    └── database.py
```

**장점**:
- ✅ 명확한 책임 분리
- ✅ 테스트 용이성 (각 레이어 독립 테스트)
- ✅ 확장성 (비즈니스 로직 변경 시 API 영향 없음)

#### 2. Authentication Strategy: Flexible

**결정**: Requirements phase에서 사용자와 대화하며 결정

서비스 타입별 추천:
- **블로그, 포트폴리오**: JWT (간단)
- **소셜 네트워크**: OAuth2 (Google, GitHub)
- **내부 관리 시스템**: Session (보안 중요)
- **공개 API**: API Key + JWT
- **인증 불필요**: 없음 (공개 서비스)

**Implementation**:
- `requirements/SKILL.md`에서 analyst가 사용자에게 질문
- 답변에 따라 `prd.md`에 명시
- `architecture/SKILL.md`에서 선택된 방식의 구조 설계

#### 3. Database Migration: Agent 판단

**기본 전략**: Alembic autogenerate 사용

```bash
# Model 변경 후 자동 감지
alembic revision --autogenerate -m "Add user table"
alembic upgrade head
```

**장점**:
- ✅ 빠름
- ✅ 실수 적음

복잡한 마이그레이션 필요 시 agent가 판단하여 수동 작성.

#### 4. Error Handling: Custom Exception + Handler

```python
# services/user_service.py
class UserNotFoundError(Exception):
    pass

async def get(user_id: int):
    user = await repo.get(user_id)
    if not user:
        raise UserNotFoundError(f"User {user_id} not found")
    return user

# api/exception_handlers.py
@app.exception_handler(UserNotFoundError)
async def user_not_found_handler(request, exc):
    return JSONResponse(
        status_code=404,
        content={"detail": str(exc)}
    )
```

**장점**:
- ✅ 비즈니스 로직 독립적
- ✅ 재사용성 높음
- ✅ 테스트 용이

#### 5. Validation: Pydantic Everywhere

```python
# schemas/user.py
class UserCreate(BaseModel):
    email: EmailStr
    password: constr(min_length=8)

# api/endpoints/users.py
@router.post("/users")
async def create_user(user: UserCreate):  # Auto-validation
    ...
```

**장점**:
- ✅ Type safety
- ✅ Auto documentation (OpenAPI)
- ✅ 명확한 에러 메시지

---

## Frontend Domain - Deep Design

### Architecture Decisions

#### 1. Component Implementation 순서: Bottom-Up

```
Phase A: UI 기본 컴포넌트 (components/ui/)
  → shadcn/ui 설치 및 Figma 스타일 적용

Phase B: 서비스 공통 컴포넌트 (components/common/)
  → Header, Footer, Navigation 등

Phase C: 기능별 컴포넌트 (components/features/)
  → LoginForm, ProductCard 등

Phase D: 페이지 (app/)
  → 컴포넌트 조합
```

**이유**:
- 재사용 컴포넌트 먼저 구축
- 일관성 보장
- design-analysis.md에 컴포넌트 목록 있음

#### 2. Figma 충실도: Adaptive with Content Fidelity

**시각적 구현** (유연):
- ✅ Tailwind spacing 사용 (4px, 8px, 16px 등)
- ✅ shadcn/ui 기본 스타일 활용
- ✅ 합리적 근사 허용

**콘텐츠 구현** (엄격):
- ❌ **절대 변경 금지**:
  - 텍스트 내용 (한글 → 영어 X)
  - 브랜드 로고
  - 버튼 레이블 ("전송" ≠ "보내기")
  - 메뉴 이름
  - 제목, 설명문
- ✅ **반드시**:
  - Figma 텍스트 그대로 복사
  - 이미지는 placeholder 명확히 표시
  - 전체 페이지 통일성 유지

**검증**:
- Vision agent: Figma에서 모든 텍스트 추출 → design-analysis.md에 기록
- Designer-high: 텍스트 그대로 사용
- 최종 검증: 모든 텍스트가 Figma와 일치하는지 체크

#### 3. State Management: Zustand

```typescript
import { create } from 'zustand'

interface AuthState {
  user: User | null
  login: (user: User) => void
  logout: () => void
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  login: (user) => set({ user }),
  logout: () => set({ user: null }),
}))
```

**이유**: 가볍고 현대적, 보일러플레이트 적음

#### 4. API Integration: Phase D (페이지 구현 시)

- UI 먼저 완성 → API 연결
- Mock 데이터로 개발
- 독립적 개발 가능

#### 5. Responsive: Mobile-First

```tsx
<div className="flex flex-col md:flex-row lg:grid lg:grid-cols-3">
```

**이유**: 현대 표준, 모바일 우선

#### 6. Accessibility: shadcn/ui 기본

- Radix UI 내장 (ARIA 속성 자동)
- 추가 체크 불필요 (효율성)

---

## Critical Files

### State Schema
```json
{
  "active": true,
  "serviceName": "example-service",
  "currentPhase": "phase-4-implementation",
  "phases": {
    "design-analysis": "completed",
    "requirements": "completed",
    "architecture": "completed",
    "implementation": "in_progress",
    "qa-refactoring": "pending"
  },
  "ralphLoop": {
    "iterationCount": 0,
    "maxIterations": 5,
    "lastReviewResult": "pending"
  },
  "documents": {
    "designAnalysis": ".omc/web-projects/example-service/docs/design-analysis.md",
    "prd": ".omc/web-projects/example-service/docs/prd.md",
    "apiSpec": ".omc/web-projects/example-service/docs/api-spec.md",
    "dbSchema": ".omc/web-projects/example-service/docs/db-schema.md",
    "architecture": ".omc/web-projects/example-service/docs/architecture.md"
  }
}
```

---

## Verification Protocol

### Evidence-Based Completion

모든 phase는 **신선한 증거**로 완료를 증명해야 함:

| Phase | Required Evidence |
|-------|-------------------|
| Design Analysis | `design-analysis.md` 파일 존재, 컴포넌트 목록 포함 |
| Requirements | API spec + DB schema가 PRD 기능 커버 |
| Architecture | Architect 자체 검토 통과 |
| Implementation | Build 성공 + Type check 통과 |
| QA & Refactoring | All tests passed + Architect APPROVED |

### Ralph Pattern Integration

Phase 5 (QA & Refactoring)는 **Ralph 패턴** 적용:
- Architect 승인까지 자동 반복
- 최대 반복 횟수: 5회 (무한 루프 방지)
- 각 반복마다 state 업데이트

---

## Implementation Strategy

### 1. Skill File Structure
```
.claude/plugins/web-autopilot/
  ├── COMMON.md                    # 공통 컨벤션
  ├── IMPLEMENTATION_PLAN.md       # 이 파일
  ├── skills/
  │   ├── design-analysis/
  │   │   ├── SKILL.md
  │   │   ├── references/
  │   │   ├── assets/
  │   │   └── scripts/
  │   ├── requirements/
  │   ├── architecture/
  │   ├── implementation/
  │   ├── qa/
  │   └── completion/
  └── utils/
      └── state-manager.js
```

### 2. Reuse OMC Patterns
- **Autopilot 5-phase structure** 차용
- **Ralph persistence loop** 재사용 (Phase 5)
- **Worker preamble** 패턴 (sub-agent 방지)
- **State cleanup on completion** (파일 삭제)

### 3. Agent Delegation Rules
```typescript
Task({
  subagent_type: "oh-my-claudecode:vision",
  model: "sonnet",
  prompt: "Analyze Figma design from: [figma-url]"
})

Task({
  subagent_type: "oh-my-claudecode:executor-high",
  model: "opus",
  prompt: "Implement FastAPI backend based on: api-spec.md"
})
```

### 4. Parallel Execution 최소화

안정성을 위해 **순차 실행** 우선:
- Backend 먼저 → API 확정 → Frontend 구현
- Phase 5 QA는 순차 (unit → e2e → build → review)

병렬 실행은 독립적인 작업만:
- 같은 phase 내에서 backend/frontend tests 동시 실행 가능

---

## Success Criteria

### Must-Have (Phase 6 완료 전)
- ✅ All unit tests passing
- ✅ All E2E tests passing
- ✅ Build successful (no TypeScript errors)
- ✅ Architect code review APPROVED
- ✅ Security review PASSED
- ✅ Backend server running (uvicorn)
- ✅ Frontend server running (next dev)
- ✅ API calls working (실제 호출 성공)

### Nice-to-Have (선택적)
- 성능 테스트 (load testing)
- 접근성 테스트 (a11y)
- 배포 스크립트 (Docker, CI/CD)

---

## Final Directory Structure

```
.claude/plugins/web-autopilot/
  ├── COMMON.md                           # 공통 컨벤션
  ├── IMPLEMENTATION_PLAN.md              # 이 문서
  ├── skills/
  │   ├── design-analysis/
  │   │   ├── SKILL.md
  │   │   ├── references/
  │   │   │   ├── figma-api.md
  │   │   │   ├── design-tokens-guide.md
  │   │   │   ├── component-mapping.md
  │   │   │   └── error-handling.md
  │   │   ├── scripts/
  │   │   │   └── fetch-figma.js
  │   │   └── assets/
  │   │       ├── design-analysis-template.md
  │   │       └── sample-output.md
  │   │
  │   ├── requirements/
  │   │   ├── SKILL.md
  │   │   ├── references/
  │   │   │   ├── prd-template.md
  │   │   │   ├── api-spec-format.md
  │   │   │   ├── db-schema-guide.md
  │   │   │   └── interview-questions.md
  │   │   └── assets/
  │   │       ├── prd-example.md
  │   │       └── api-spec-example.md
  │   │
  │   ├── architecture/
  │   │   ├── SKILL.md
  │   │   ├── references/
  │   │   │   ├── nextjs-patterns.md
  │   │   │   ├── fastapi-patterns.md
  │   │   │   └── security-checklist.md
  │   │   └── assets/
  │   │       └── architecture-template.md
  │   │
  │   ├── implementation/
  │   │   ├── SKILL.md
  │   │   ├── references/
  │   │   │   ├── shadcn-setup.md
  │   │   │   ├── component-patterns.md
  │   │   │   └── api-integration.md
  │   │   ├── scripts/
  │   │   │   ├── init-nextjs.sh
  │   │   │   └── init-fastapi.py
  │   │   └── assets/
  │   │       └── boilerplate-templates/
  │   │
  │   ├── qa/
  │   │   ├── SKILL.md
  │   │   ├── references/
  │   │   │   ├── testing-strategy.md
  │   │   │   ├── verification-checklist.md
  │   │   │   └── ralph-loop-guide.md
  │   │   └── scripts/
  │   │       ├── run-tests.sh
  │   │       └── check-types.sh
  │   │
  │   └── completion/
  │       ├── SKILL.md
  │       ├── references/
  │       │   └── readme-template.md
  │       └── assets/
  │           └── readme-examples/
  │
  └── utils/
      └── state-manager.js

.omc/
  ├── state/
  │   └── web-autopilot-state.json
  └── web-projects/
      └── {service-name}/
          ├── docs/
          │   ├── design-analysis.md
          │   ├── prd.md
          │   ├── api-spec.md
          │   ├── db-schema.md
          │   └── architecture.md
          ├── figma-designs/
          └── assets/
```

---

## Implementation Phases

### Phase 1: Core Setup (Foundation)
**Goal**: Foundation ready

1. **Create COMMON.md**
   - Standard phase protocol
   - File path conventions
   - State schema
   - Phase dependencies
   - Agent delegation pattern
   - Error handling

2. **Create directory structure**
   - 6 phase directories with subdirectories

---

### Phase 2: MVP Skills (Critical Path)
**Goal**: design-analysis → requirements working

**Priority 1**:
1. `design-analysis/SKILL.md`
   - Figma fetch + Vision analysis + Designer perspective

2. `requirements/SKILL.md`
   - Analyst interview + User questions

**Test MVP**:
```bash
/web-autopilot:design-analysis project-brief.md
/web-autopilot:requirements
```

---

### Phase 3: Implementation Skills
**Goal**: Backend + Frontend working

3. `architecture/SKILL.md`
4. `implementation/SKILL.md` (Backend)
5. `implementation/SKILL.md` (Frontend)

**Test**:
```bash
/web-autopilot:architecture
/web-autopilot:backend
/web-autopilot:frontend
```

---

### Phase 4: QA & Completion
**Goal**: Quality assurance + Documentation

6. `qa/SKILL.md` (Ralph Loop)
7. `completion/SKILL.md`

---

### Phase 5: References & Assets
**Goal**: Support documentation complete

**Priority 1 References** (MVP):
- design-tokens-guide.md
- prd-template.md
- api-spec-format.md
- fastapi-boilerplate.md
- nextjs-setup.md
- jwt-auth.md

---

### Phase 6: End-to-End Validation
**Goal**: Full pipeline works

**Test Scenario**:
1. Real Figma design URL + project-brief.md
2. Execute all phases
3. Verify complete working system

---

## Design Philosophy

### Core Principles

1. **Progressive Disclosure**
   - SKILL.md: 핵심만 (500줄 이하)
   - references/: 상세 문서
   - assets/: 템플릿
   - scripts/: 실행 코드

2. **Trust Agents**
   - 팀장처럼 가이드만
   - 세부 구현은 agent에게
   - 과한 통제 지양

3. **Content Fidelity First**
   - Figma 텍스트 절대 변경 금지
   - 통일성 > 픽셀 완벽
   - 브랜드 일관성 유지

4. **Verification-Driven**
   - 검증 후 리팩토링
   - 증거 기반 완료
   - State로 진행 추적

5. **Flexibility by Design**
   - Auth: 사용자와 결정
   - Tech stack: 커스터마이징
   - Migration: Agent 판단

6. **Iterative & Incremental**
   - MVP 먼저
   - 단계별 검증
   - End-to-end 테스트

---

## Next Steps

### Immediate Actions

1. Clean and setup directories
2. Write COMMON.md
3. Write design-analysis/SKILL.md
4. Write requirements/SKILL.md
5. Test MVP

### Subsequent Phases

6. Write architecture/SKILL.md
7. Write implementation/SKILL.md
8. Write qa/SKILL.md
9. Write completion/SKILL.md
10. Fill references/
11. Create assets/
12. End-to-end validation

---

## Key Learnings

### What We Designed

1. **Orchestration**: Phase별 독립 skills
2. **Backend**: Clean Architecture (3-Layer)
3. **Frontend**: Bottom-up, Content fidelity
4. **Integration**: Backend → Frontend → QA

### What Makes This Different

- **Not monolithic**: Phase별 독립
- **Not prescriptive**: Agent 신뢰
- **Progressive disclosure**: 필요할 때만
- **Content-first**: 정확성 우선
- **Evidence-based**: 검증 기반
