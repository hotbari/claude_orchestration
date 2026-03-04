---
name: completion
description: Final documentation and state cleanup - README creation, state deletion
version: 1.0.0
dependencies:
  - qa (must be "completed")
  - architect final approval (must be "approved")
outputs:
  - Backend README.md
  - Frontend README.md
  - State file deleted
---

# Completion Phase

## 개요

web-autopilot의 최종 단계입니다. 백엔드 및 프론트엔드 프로젝트 모두에 대한 포괄적인 README 파일을 생성한 다음 state 파일을 정리합니다.

**목적**: 문서화로 프로젝트를 마무리하고 임시 state 정리

## 전제 조건

**State 요구사항**:
```javascript
state.phases.qa === "completed"
state.ralphLoop.lastReviewResult === "approved"
```

**파일 의존성**:
- Backend 프로젝트 구조 완료
- Frontend 프로젝트 구조 완료
- 모든 테스트 통과
- Architect 승인 받음

## 입력

| 입력 | 소스 | 설명 |
|------|------|------|
| Service name | `state.prd.serviceName` | 디렉토리용 프로젝트 이름 |
| Backend path | `projects/{serviceName}-backend/` | Backend 프로젝트 위치 |
| Frontend path | `projects/{serviceName}-frontend/` | Frontend 프로젝트 위치 |
| Technology choices | `state.architecture.*` | 사용된 기술 스택 |
| API endpoints | Backend implementation | 사용 가능한 API 라우트 |
| Component structure | Frontend implementation | 컴포넌트 조직 |

## 출력

| 출력 | 경로 | 설명 |
|------|------|------|
| Backend README | `projects/{service}-backend/README.md` | Backend 문서 |
| Frontend README | `projects/{service}-frontend/README.md` | Frontend 문서 |
| State deleted | `.omc/state/web-autopilot-state.json` | 제거됨 (정리) |

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| `writer` | haiku | README 문서 생성 |

## 단계별 프로세스

### Step 1: 의존성 확인

**전제 조건 검증**:
```javascript
const state = loadState();

if (state.phases.qa !== "completed") {
  throw new Error("QA phase not complete - cannot proceed to completion");
}

if (state.ralphLoop?.lastReviewResult !== "approved") {
  throw new Error("Architect approval required before completion");
}
```

**중요**: 두 조건이 모두 충족되지 않으면 진행하지 않음

### Step 2: Backend README 생성

**writer agent에 위임**:

```javascript
Task({
  subagent_type: "oh-my-claudecode:writer",
  model: "haiku",
  prompt: `Create comprehensive README.md for backend project.

Project Details:
- Service Name: ${state.prd.serviceName}
- Location: projects/${state.prd.serviceName}-backend/
- Framework: FastAPI (Python)
- Database: PostgreSQL
- Architecture: Clean 3-layer (API/Services/Repositories)

Required Sections:
1. Project Overview
2. Technology Stack
3. Installation Instructions
4. Environment Configuration
5. Running the Application
6. API Documentation
7. Testing
8. Project Structure

Write to: projects/${state.prd.serviceName}-backend/README.md`
});
```

**Backend README 템플릿**:
- Project Overview + Tech Stack (Python 3.10+, FastAPI, PostgreSQL, SQLAlchemy, Alembic, Pydantic, pytest)
- Installation: 전제 조건, venv 설정, pip install, database 생성, migrations
- Environment Configuration: DATABASE_URL, SECRET_KEY, DEBUG가 포함된 .env 템플릿
- Running: Development (`uvicorn app.main:app --reload`) 및 Production 모드
- API Documentation: `/docs` (Swagger) 및 `/redoc` 링크
- Testing: `pytest`, coverage 명령, test 구조 (unit/integration)
- Project Structure: Clean 3-layer architecture (api/services/repositories/models/schemas/core)
- Architecture 설명: API Layer (routes), Business Logic (services), Data Access (repositories)
- 이점: 관심사 분리, 테스트 가능성, 확장성
- Development: Alembic을 사용한 database migrations (autogenerate, upgrade, downgrade)
- Troubleshooting: Database 연결, import 오류
- License 플레이스홀더

### Step 3: Frontend README 생성

**writer agent에 위임**:

```javascript
Task({
  subagent_type: "oh-my-claudecode:writer",
  model: "haiku",
  prompt: `Create comprehensive README.md for frontend project.

Project Details:
- Service Name: ${state.prd.serviceName}
- Location: projects/${state.prd.serviceName}-frontend/
- Framework: Next.js 14
- UI Library: shadcn/ui
- Design: Figma conversion

Required Sections:
1. Project Overview
2. Technology Stack
3. Installation Instructions
4. Environment Configuration
5. Running the Application
6. Component Architecture
7. Design Tokens
8. Testing
9. Figma Design Reference

Write to: projects/${state.prd.serviceName}-frontend/README.md`
});
```

**Frontend README 템플릿**:
- Project Overview + Tech Stack (Next.js 14, React 18, TypeScript, Tailwind CSS, shadcn/ui, Radix UI, React Query, Jest, Playwright)
- Installation: 전제 조건 (Node.js 18+), npm/pnpm install
- Environment Configuration: NEXT_PUBLIC_API_URL이 포함된 .env.local
- Running: Development (`npm run dev`), Production build, Type checking, Linting
- Component Architecture: 디렉토리 구조 (app/components/lib/hooks)
- Component Organization: ui/ (shadcn/ui base), common/ (재사용 가능), features/ (기능 특정)
- Design Tokens: Figma의 colors/spacing/typography를 위한 `lib/design-tokens.ts`
- Testing: Jest unit tests, Playwright E2E, coverage 명령
- Figma Design Reference: 100% 충실도 매핑 (colors, typography, spacing, components)
- Development Workflow: shadcn CLI를 통한 컴포넌트 추가, React Query를 통한 API 통합
- Troubleshooting: Module not found, type errors, styles not applying
- Browser Support: 주요 브라우저의 최신 2개 버전
- License 플레이스홀더

### Step 4: State 정리

**중요 작업**: state 파일 삭제 (IMPLEMENTATION_PLAN.md line 549-553)

```javascript
const stateManager = require('../../../utils/state-manager.js');
const fs = require('fs');
const path = require('path');

// Mark completion phase as done BEFORE deletion
state.phases.completion = "completed";
state.completedAt = new Date().toISOString();
stateManager.saveState(state);

// Now delete the state file
const statePath = path.join(process.cwd(), '.omc/state/web-autopilot-state.json');
if (fs.existsSync(statePath)) {
  fs.unlinkSync(statePath);
  console.log('State file cleaned up successfully');
} else {
  console.log('State file already deleted or not found');
}
```

**중요 사항**:
- `active: false`로 설정하지 말고 파일을 완전히 삭제
- 워크플로우 완료를 나타내기 위해 state 파일 제거해야 함
- 파일이 존재하지 않으면 허용됨 (멱등 작업)

**삭제 확인**:
```bash
# Should return "file not found"
ls .omc/state/web-autopilot-state.json
```

### Step 5: 최종 요약

**사용자에게 출력**:

```
✅ Web Autopilot Complete!

📦 Projects Created:
- Backend: projects/{serviceName}-backend/
- Frontend: projects/{serviceName}-frontend/

📚 Documentation:
- Backend README: projects/{serviceName}-backend/README.md
- Frontend README: projects/{serviceName}-frontend/README.md

🚀 Quick Start:

Backend:
  cd projects/{serviceName}-backend
  python -m venv venv
  source venv/bin/activate  # Windows: venv\Scripts\activate
  pip install -r requirements.txt
  cp .env.example .env  # Configure database
  alembic upgrade head
  uvicorn app.main:app --reload

Frontend:
  cd projects/{serviceName}-frontend
  npm install
  cp .env.example .env.local  # Configure API URL
  npm run dev

📖 Next Steps:
1. Configure environment variables
2. Review README files for detailed instructions
3. Customize design tokens if needed
4. Deploy to production

🧹 State file cleaned up successfully
```

## 검증 체크리스트

phase 완료 표시 전:

- [ ] Backend README.md가 존재하고 완전함
- [ ] Frontend README.md가 존재하고 완전함
- [ ] 설치 지침이 명확함
- [ ] 환경 설정 문서화됨
- [ ] 실행 지침 제공됨
- [ ] API/컴포넌트 문서 포함됨
- [ ] 프로젝트 구조 설명됨
- [ ] 테스팅 지침 제공됨
- [ ] State 파일 삭제됨 (`.omc/state/web-autopilot-state.json`)
- [ ] `state.phases.completion === "completed"` (삭제 전)

## 오류 처리

### State 파일 없음

**시나리오**: 정리 중 state 파일이 존재하지 않음

**조치**:
- 정보 메시지 로그
- 계속 진행 (허용되는 상태)
- 오류 발생시키지 않음

**이유**: 멱등 작업 - 파일이 수동으로 삭제되었거나 생성되지 않았을 수 있음

### README 작성 실패

**시나리오**: README 파일을 작성할 수 없음

**가능한 원인**:
- 디렉토리가 존재하지 않음
- 권한 거부됨
- 디스크 가득 찼음

**복구**:
1. 프로젝트 디렉토리 존재 확인
2. 쓰기 권한 확인
3. 실패한 파일에 대해 writer agent 재실행
4. 지속되면 사용자에게 수동 생성 요청

### Writer Agent 불완전

**시나리오**: README에 필수 섹션 누락

**감지**:
- 주요 헤더 확인
- 최소 콘텐츠 길이 확인

**복구**:
```javascript
Task({
  subagent_type: "oh-my-claudecode:writer",
  model: "haiku",
  prompt: `The README is incomplete. Please add these missing sections:
  ${missingSections.join('\n')}

  Append to: ${readmePath}`
});
```

## 참조

### 관련 파일
- `IMPLEMENTATION_PLAN.md` lines 536-556 - Completion phase 명세
- `IMPLEMENTATION_PLAN.md` lines 560-659 - Backend 아키텍처 세부사항
- `utils/state-manager.js` - State 관리 유틸리티

### 템플릿 구조
표준 오픈소스 README 규칙 기반:
- 명확한 프로젝트 개요
- 상세한 설치 단계
- 환경 구성
- 사용 예시
- 아키텍처 설명
- 테스팅 가이드
- 문제 해결 섹션

### 설계 원칙
- **완전성**: 신규 개발자를 위한 모든 필요 정보
- **명확성**: 단계별 지침
- **예시**: 구체적인 코드 스니펫
- **보안**: 비밀 정보 및 프로덕션에 대한 경고
- **접근성**: 초보자가 따라하기 쉬움

## 참고사항

**Completion Phase 철학**:
- "졸업식" - 프로젝트 완료됨
- 문서화는 프로젝트가 독립적으로 존재할 수 있도록 보장
- State 정리는 autopilot 워크플로우의 깔끔한 종료를 신호

**README 품질**:
- 신규 개발자가 30분 이내에 설정할 수 있어야 함
- 일반적인 문제에 대한 문제 해결 포함
- 대화형 API 문서에 링크
- 아키텍처 결정 설명

**State 정리 근거**:
- 향후 실행에서 오래된 state 방지
- 다음 autopilot 세션을 위한 깨끗한 시작
- 사용자에게 명확한 완료 신호

**롤백 없음**:
- Completion phase는 최종적
- 문제 발견 시 수정하고 재문서화
- completion을 "실행 취소"하려고 시도하지 않음

---

**Phase 소요 시간**: 5-10분 (문서 생성)

**성공 기준**: README 완료, state 삭제, 사용자가 지침을 따라 두 프로젝트 모두 실행 가능
