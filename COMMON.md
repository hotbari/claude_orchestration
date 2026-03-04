# Web Autopilot - 공통 규약

이 문서는 모든 web-autopilot phase에서 사용되는 공유 프로토콜, 규약 및 패턴을 정의합니다.

---

## 목차

1. [Phase 프로토콜](#1-phase-프로토콜)
2. [파일 경로 규약](#2-파일-경로-규약)
3. [State 관리](#3-state-관리)
4. [Agent 위임 패턴](#4-agent-위임-패턴)
5. [오류 처리](#5-오류-처리)
6. [검증 표준](#6-검증-표준)
7. [Phase 의존성 맵](#7-phase-의존성-맵)

---

## 1. Phase 프로토콜

### 1.1 Phase 생명주기

모든 phase는 다음 생명주기를 따릅니다:

```
1. COMMON.md + Phase SKILL.md 읽기
2. Phase 의존성 검증 (state 확인)
3. Phase 작업 실행
4. 산출물 생성
5. State 업데이트
6. 완료 검증
7. 사용자 확인 대기
```

### 1.2 State 읽기/쓰기 작업

**JavaScript State 접근 패턴:**

```javascript
const fs = require('fs');
const path = require('path');

// State 파일 위치
const STATE_PATH = '.omc/state/web-autopilot-state.json';

// State 읽기
function readState() {
  if (!fs.existsSync(STATE_PATH)) {
    throw new Error(`State file not found: ${STATE_PATH}`);
  }
  const content = fs.readFileSync(STATE_PATH, 'utf8');
  return JSON.parse(content);
}

// State 쓰기
function writeState(state) {
  const dir = path.dirname(STATE_PATH);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.writeFileSync(STATE_PATH, JSON.stringify(state, null, 2), 'utf8');
}

// 특정 phase 상태 업데이트
function updatePhaseStatus(phaseName, status) {
  const state = readState();
  state.phases[phaseName] = status;
  state.currentPhase = phaseName;
  writeState(state);
}

// Phase 오류로 업데이트
function updatePhaseError(phaseName, error) {
  const state = readState();
  state.phases[phaseName] = 'failed';
  state.lastError = {
    phase: phaseName,
    message: error.message,
    timestamp: new Date().toISOString()
  };
  writeState(state);
}
```

### 1.3 Phase 상태 값

| 상태 | 의미 | 다음 동작 |
|--------|---------|-------------|
| `pending` | 시작되지 않음 | 의존성이 충족되면 시작 가능 |
| `in_progress` | 현재 실행 중 | 실행 계속 |
| `completed` | 성공적으로 완료 | 다음 phase 시작 가능 |
| `failed` | 오류 발생 | 오류 검토, phase 재시도 |

### 1.4 Phase 의존성 확인

**모든 phase 시작 전 확인:**

```javascript
// Phase 의존성 맵 (섹션 7에 정의)
const PHASE_DEPENDENCIES = {
  'design-analysis': null,
  'requirements': 'design-analysis',
  'architecture': 'requirements',
  'implementation': 'architecture',
  'qa': 'implementation',
  'completion': 'qa'
};

function checkPhaseDependency(currentPhase) {
  const state = readState();
  const requiredPhase = PHASE_DEPENDENCIES[currentPhase];

  if (requiredPhase && state.phases[requiredPhase] !== 'completed') {
    throw new Error(
      `Cannot start ${currentPhase}: ` +
      `${requiredPhase} phase must complete first ` +
      `(current status: ${state.phases[requiredPhase]})`
    );
  }

  return true;
}
```

---

## 2. 파일 경로 규약

### 2.1 표준 경로

모든 phase는 반드시 다음 표준화된 경로를 사용해야 합니다:

| 산출물 | 경로 패턴 | 예시 |
|----------|--------------|---------|
| **State 파일** | `.omc/state/web-autopilot-state.json` | `.omc/state/web-autopilot-state.json` |
| **프로젝트 문서** | `.omc/web-projects/{service-name}/docs/` | `.omc/web-projects/todo-app/docs/` |
| **Figma 이미지** | `.omc/web-projects/{service-name}/figma-designs/` | `.omc/web-projects/todo-app/figma-designs/` |
| **프론트엔드 프로젝트** | `projects/{service-name}-frontend/` | `projects/todo-app-frontend/` |
| **백엔드 프로젝트** | `projects/{service-name}-backend/` | `projects/todo-app-backend/` |

### 2.2 문서 산출물

| 문서 | 경로 | 소유 Phase |
|----------|------|-------------|
| Design Analysis | `.omc/web-projects/{service}/docs/design-analysis.md` | design-analysis |
| PRD | `.omc/web-projects/{service}/docs/prd.md` | requirements |
| API Spec | `.omc/web-projects/{service}/docs/api-spec.md` | requirements |
| DB Schema | `.omc/web-projects/{service}/docs/db-schema.md` | requirements |
| Tech Stack | `.omc/web-projects/{service}/docs/tech-stack.md` | requirements |
| Architecture | `.omc/web-projects/{service}/docs/architecture.md` | architecture |

### 2.3 경로 해석 헬퍼

```javascript
function getProjectPaths(serviceName) {
  return {
    state: '.omc/state/web-autopilot-state.json',
    docs: `.omc/web-projects/${serviceName}/docs/`,
    figma: `.omc/web-projects/${serviceName}/figma-designs/`,
    frontend: `projects/${serviceName}-frontend/`,
    backend: `projects/${serviceName}-backend/`,
    documents: {
      designAnalysis: `.omc/web-projects/${serviceName}/docs/design-analysis.md`,
      prd: `.omc/web-projects/${serviceName}/docs/prd.md`,
      apiSpec: `.omc/web-projects/${serviceName}/docs/api-spec.md`,
      dbSchema: `.omc/web-projects/${serviceName}/docs/db-schema.md`,
      techStack: `.omc/web-projects/${serviceName}/docs/tech-stack.md`,
      architecture: `.omc/web-projects/${serviceName}/docs/architecture.md`
    }
  };
}
```

---

## 3. State 관리

### 3.1 State 스키마

```json
{
  "active": true,
  "serviceName": "example-service",
  "currentPhase": "implementation",
  "phases": {
    "design-analysis": "completed",
    "requirements": "completed",
    "architecture": "completed",
    "implementation": "in_progress",
    "qa": "pending",
    "completion": "pending"
  },
  "ralphLoop": {
    "iterationCount": 0,
    "maxIterations": 5,
    "lastReviewResult": "pending"
  },
  "documents": {
    "designAnalysis": ".omc/web-projects/example/docs/design-analysis.md",
    "prd": ".omc/web-projects/example/docs/prd.md",
    "apiSpec": ".omc/web-projects/example/docs/api-spec.md",
    "dbSchema": ".omc/web-projects/example/docs/db-schema.md",
    "techStack": ".omc/web-projects/example/docs/tech-stack.md",
    "architecture": ".omc/web-projects/example/docs/architecture.md"
  },
  "figmaUrl": "https://figma.com/file/...",
  "techStack": {
    "frontend": {
      "framework": "Next.js 14+",
      "language": "TypeScript",
      "styling": "Tailwind CSS + shadcn/ui"
    },
    "backend": {
      "framework": "FastAPI",
      "language": "Python 3.10+",
      "orm": "SQLAlchemy"
    },
    "database": "PostgreSQL"
  },
  "lastError": null
}
```

### 3.2 State 초기화

**새로운 web-autopilot 세션 시작 시:**

```javascript
function initializeState(serviceName, figmaUrl) {
  const state = {
    active: true,
    serviceName: serviceName,
    currentPhase: 'design-analysis',
    phases: {
      'design-analysis': 'pending',
      'requirements': 'pending',
      'architecture': 'pending',
      'implementation': 'pending',
      'qa': 'pending',
      'completion': 'pending'
    },
    ralphLoop: {
      iterationCount: 0,
      maxIterations: 5,
      lastReviewResult: 'pending'
    },
    documents: getProjectPaths(serviceName).documents,
    figmaUrl: figmaUrl,
    techStack: null,
    lastError: null
  };

  writeState(state);
  return state;
}
```

### 3.3 State 정리

**Completion phase 성공 시:**

```javascript
function cleanupState() {
  const STATE_PATH = '.omc/state/web-autopilot-state.json';
  if (fs.existsSync(STATE_PATH)) {
    fs.unlinkSync(STATE_PATH);
  }
}
```

---

## 4. Agent 위임 패턴

### 4.1 표준 Task() 호출 형식

**기본 패턴:**

```javascript
Task({
  subagent_type: "oh-my-claudecode:{agent-name}",
  model: "{haiku|sonnet|opus}",
  prompt: "{clear instruction with context}"
})
```

**실제 예시:**

```javascript
// Vision agent를 사용한 디자인 분석
Task({
  subagent_type: "oh-my-claudecode:vision",
  model: "sonnet",
  prompt: `Analyze the Figma design images in: .omc/web-projects/todo-app/figma-designs/

Extract:
1. Layout structure (grid, spacing)
2. Component list (buttons, forms, cards)
3. Design tokens (colors, typography, spacing values)
4. Interaction patterns

Output to: .omc/web-projects/todo-app/docs/design-analysis.md`
})

// 백엔드 구현
Task({
  subagent_type: "oh-my-claudecode:executor-high",
  model: "opus",
  prompt: `Implement FastAPI backend for todo-app service.

References:
- API Spec: .omc/web-projects/todo-app/docs/api-spec.md
- DB Schema: .omc/web-projects/todo-app/docs/db-schema.md
- Architecture: .omc/web-projects/todo-app/docs/architecture.md

Output to: projects/todo-app-backend/

Requirements:
- Clean Architecture (3-layer)
- SQLAlchemy ORM
- Pydantic validation
- Alembic migrations`
})
```

### 4.2 모델 티어 선택

| 작업 복잡도 | 모델 | 사용 사례 |
|-----------------|-------|----------|
| **단순** | `haiku` | 빠른 조회, 단순 작성, 문서화 |
| **표준** | `sonnet` | 기능 구현, 테스트, 디자인 작업 |
| **복잡** | `opus` | 아키텍처, 심층 디버깅, 중요한 결정 |

**Agent별 기본 모델:**

| Agent | 기본 모델 | 재정의 시점 |
|-------|---------------|---------------|
| vision | sonnet | N/A (시각적 분석) |
| designer | sonnet | 복잡한 UI → opus |
| designer-high | opus | 항상 opus |
| analyst | opus | 항상 opus |
| architect | opus | 항상 opus |
| architect-low | haiku | 빠른 검증만 |
| executor | sonnet | 복잡한 리팩토링 → opus |
| executor-high | opus | 항상 opus |
| tdd-guide | sonnet | 드물게 재정의 |
| qa-tester-high | opus | 항상 opus |
| build-fixer | sonnet | 단순 수정 → haiku |
| security-reviewer | opus | 항상 opus |
| writer | haiku | 항상 haiku |

### 4.3 프롬프트 템플릿 구조

**표준 프롬프트 구조:**

```
[동작 동사] [대상] for [서비스 이름]

References:
- [문서 1]: [경로]
- [문서 2]: [경로]

Output to: [대상 경로]

Requirements:
- [요구사항 1]
- [요구사항 2]
- [요구사항 3]

Constraints:
- [제약사항 1]
- [제약사항 2]
```

---

## 5. 오류 처리

### 5.1 Phase 수준 오류 캡처

**오류 발생 시:**

```javascript
function handlePhaseError(phaseName, error) {
  console.error(`Error in ${phaseName} phase:`, error);

  // State 업데이트
  updatePhaseError(phaseName, error);

  // Phase별 오류 로그에 기록
  const errorLog = {
    phase: phaseName,
    timestamp: new Date().toISOString(),
    error: error.message,
    stack: error.stack
  };

  const logPath = `.omc/web-projects/${state.serviceName}/logs/${phaseName}-errors.json`;
  appendToLog(logPath, errorLog);

  // 사용자에게 알림
  console.log(`\n❌ ${phaseName} phase failed. Error details saved to state.`);
  console.log(`   To retry: /web-autopilot:${phaseName}`);
}
```

### 5.2 일반적인 오류 시나리오

| 오류 유형 | 처리 전략 |
|------------|-------------------|
| **Figma URL 무효** | 사용자에게 알림, 유효한 URL 요청, 진행하지 않음 |
| **MCP 서버 사용 불가** | Figma MCP 설치 확인, 설정 가이드 제공 |
| **의존성 phase 미완료** | 명확한 메시지로 오류, 필요한 phase 상태 표시 |
| **빌드 실패** | 오류 캡처, build-fixer agent에 위임 |
| **테스트 실패** | 오류 캡처, 수정을 위해 Ralph loop 진입 |
| **Architect 거부** | 피드백 캡처, 리팩토링을 위해 executor에 위임 |

### 5.3 재시도 프로토콜

**사용자가 시작한 재시도:**

```bash
# 외부 문제 해결 후 (Figma 접근 등)
/web-autopilot:design-analysis

# Agent는 다음을 수행:
# 1. State가 존재하는지 확인
# 2. 마지막 오류 읽기
# 3. 마지막 체크포인트에서 재시도
# 4. 성공 시 오류 지우기
```

---

## 6. 검증 표준

### 6.1 Phase별 증거 요구사항

| Phase | 필요한 증거 | 검증 방법 |
|-------|-------------------|---------------|
| **design-analysis** | `design-analysis.md` 존재, 컴포넌트 목록 + 디자인 토큰 포함 | 파일 존재, 섹션 보유: Layout, Components, Design Tokens |
| **requirements** | PRD/API spec/DB schema 존재, 모든 PRD 기능이 API 엔드포인트 보유 | PRD 기능과 API spec 교차 확인 |
| **architecture** | `architecture.md` 존재, architect 자체 검토 통과 | 파일 존재, 포함: Frontend arch, Backend arch, Dependencies |
| **implementation** | 빌드 성공, 타입 체크 통과, 오류 없음 | `next build`, `tsc --noEmit`, `uvicorn` 실행 |
| **qa** | 모든 테스트 통과, architect APPROVED, 보안 통과 | `pytest`, E2E 테스트, Architect 검토 결과 |
| **completion** | README 존재, state 정리 완료 | README 존재, state 파일 삭제됨 |

### 6.2 Ralph Loop 프로토콜

**QA phase에서만 사용. 최대 5회 반복.**

```javascript
function ralphLoop(serviceName) {
  const state = readState();
  const maxIterations = state.ralphLoop.maxIterations;
  let iteration = state.ralphLoop.iterationCount;

  while (iteration < maxIterations) {
    iteration++;
    console.log(`\n🔄 Ralph Loop Iteration ${iteration}/${maxIterations}`);

    // 1단계: 테스트 실행
    const testResult = runAllTests(serviceName);

    // 2단계: Architect 검토
    if (testResult.passed) {
      const reviewResult = requestArchitectReview(serviceName);

      if (reviewResult.status === 'APPROVED') {
        // 성공!
        state.ralphLoop.lastReviewResult = 'APPROVED';
        state.ralphLoop.iterationCount = iteration;
        writeState(state);
        return { success: true, iterations: iteration };
      } else {
        // 리팩토링 필요
        console.log(`📋 Architect feedback: ${reviewResult.feedback}`);
        performRefactoring(serviceName, reviewResult.feedback);
      }
    } else {
      // 테스트 실패 수정
      console.log(`❌ Tests failed: ${testResult.failures}`);
      fixTestFailures(serviceName, testResult.failures);
    }

    // 반복 횟수 업데이트
    state.ralphLoop.iterationCount = iteration;
    writeState(state);
  }

  // 최대 반복 횟수 도달
  throw new Error(
    `Ralph loop reached max iterations (${maxIterations}). ` +
    `Manual intervention required.`
  );
}
```

### 6.3 검증 체크리스트 템플릿

**각 phase는 다음을 검증해야 합니다:**

```markdown
## Verification Checklist

- [ ] Phase 의존성 충족 (이전 phase 완료)
- [ ] 모든 필수 문서 생성
- [ ] 문서 내용 완료 (모든 섹션 작성)
- [ ] 플레이스홀더 값 없음
- [ ] State 올바르게 업데이트
- [ ] 증거 캡처 (빌드 출력, 테스트 결과 등)
- [ ] 사용자 확인 준비 완료
```

---

## 7. Phase 의존성 맵

### 7.1 전체 의존성 그래프

```
design-analysis (의존성 없음)
    ↓
requirements (요구: design-analysis)
    ↓
architecture (요구: requirements)
    ↓
implementation (요구: architecture)
    ↓
qa (요구: implementation)
    ↓
completion (요구: qa)
```

### 7.2 의존성 로직

```javascript
const PHASE_DEPENDENCIES = {
  'design-analysis': null,  // 항상 시작 가능
  'requirements': 'design-analysis',
  'architecture': 'requirements',
  'implementation': 'architecture',
  'qa': 'implementation',
  'completion': 'qa'
};

// 역방향 조회: 이 phase에 의존하는 phase는?
const PHASE_DEPENDENTS = {
  'design-analysis': ['requirements'],
  'requirements': ['architecture'],
  'architecture': ['implementation'],
  'implementation': ['qa'],
  'qa': ['completion'],
  'completion': []
};
```

### 7.3 Phase 재실행 규칙

**Phase가 재실행되면 (재시도), 다운스트림 phase는 리셋되어야 합니다:**

```javascript
function resetDependentPhases(phaseName) {
  const state = readState();
  const dependents = PHASE_DEPENDENTS[phaseName];

  dependents.forEach(depPhase => {
    if (state.phases[depPhase] !== 'pending') {
      console.log(`⚠️  Resetting ${depPhase} phase (upstream change)`);
      state.phases[depPhase] = 'pending';
    }
  });

  writeState(state);
}
```

---

## 8. Agent 통신 프로토콜

### 8.1 Agent 간 정보 전달

**Agent는 문서 산출물을 통해 통신하며, state를 통해서는 하지 않습니다.**

**올바른 패턴:**

```javascript
// Phase 1 agent가 작성:
// .omc/web-projects/todo-app/docs/design-analysis.md

// Phase 2 agent가 읽기:
const designAnalysis = fs.readFileSync(
  '.omc/web-projects/todo-app/docs/design-analysis.md',
  'utf8'
);
```

**잘못된 패턴 (하지 말 것):**

```javascript
// ❌ State에 큰 데이터를 저장하지 마세요
state.designAnalysisContent = "...huge markdown...";
```

### 8.2 State vs. 문서

| 데이터 유형 | 저장 위치 | 이유 |
|-----------|----------|--------|
| **Phase 상태** | State | 경량, 조정용 |
| **서비스 이름** | State | 모든 phase에 필요 |
| **현재 phase** | State | 조정용 |
| **오류 메시지** | State | 최근 오류만 |
| **디자인 분석** | 문서 | 큰 내용 |
| **PRD, API spec** | 문서 | 큰 내용 |
| **아키텍처 문서** | 문서 | 큰 내용 |
| **코드** | 프로젝트 디렉토리 | state/docs에 없음 |

---

## 9. 기술 스택 설정

### 9.1 기본 스택

`tech-stack.md`가 제공되지 않으면 기본값 사용:

```json
{
  "frontend": {
    "framework": "Next.js 14+",
    "language": "TypeScript",
    "styling": "Tailwind CSS",
    "ui": "shadcn/ui",
    "stateManagement": "Zustand",
    "testing": "Jest + React Testing Library + Playwright"
  },
  "backend": {
    "framework": "FastAPI",
    "language": "Python 3.10+",
    "orm": "SQLAlchemy",
    "migration": "Alembic",
    "validation": "Pydantic",
    "testing": "pytest"
  },
  "database": {
    "type": "PostgreSQL",
    "version": "15+"
  }
}
```

### 9.2 사용자 정의 스택 처리

**`tech-stack.md`가 제공되면:**

1. Requirements phase에서 파일 읽기
2. 호환성 검증
3. 사용자 정의 스택으로 state 업데이트
4. 모든 다운스트림 phase는 사용자 정의 스택 사용

**tech-stack.md 형식:**

```markdown
# Tech Stack

## Frontend
- Framework: Next.js 14
- Language: TypeScript 5.0
- Styling: Tailwind CSS 3.4
- UI: shadcn/ui

## Backend
- Framework: FastAPI 0.110
- Language: Python 3.11
- ORM: SQLAlchemy 2.0

## Database
- Type: PostgreSQL
- Version: 15
```

---

## 10. 중요 제약사항

### 10.1 콘텐츠 충실성 규칙

**절대 규칙 (절대 위반하지 말 것):**

1. **텍스트 콘텐츠**: Figma와 정확히 일치해야 함
   - ❌ 절대 번역하지 마세요 (한글 → 영어)
   - ❌ 절대 의역하지 마세요 ("전송" ≠ "보내기")
   - ✅ Figma 텍스트를 정확히 복사-붙여넣기

2. **브랜드 요소**: 정확히 보존해야 함
   - 로고
   - 브랜드 이름
   - 제품 이름
   - 태그라인

3. **비주얼 디자인**: 합리적으로 적용
   - ✅ Tailwind spacing 사용 (4px, 8px, 16px)
   - ✅ shadcn/ui 컴포넌트 사용
   - ✅ 합리적인 근사치 허용

### 10.2 구현 제약사항

**순서 제약사항:**

- 백엔드는 반드시 프론트엔드 전에 완료되어야 함
- 유닛 테스트는 반드시 E2E 테스트 전에 통과되어야 함
- 빌드는 반드시 Architect 검토 전에 성공해야 함

**병렬화 규칙:**

- ❌ 백엔드 + 프론트엔드 병렬화 불가 (순차적)
- ✅ 백엔드 테스트 + 프론트엔드 테스트 병렬화 가능 (동일 phase)
- ✅ 여러 유닛 테스트 파일 병렬화 가능

---

## 11. 디버깅 및 로깅

### 11.1 표준 로그 위치

```
.omc/web-projects/{service-name}/logs/
  ├── design-analysis-errors.json
  ├── requirements-errors.json
  ├── architecture-errors.json
  ├── implementation-errors.json
  ├── qa-errors.json
  └── completion-errors.json
```

### 11.2 로그 항목 형식

```json
{
  "timestamp": "2025-01-15T10:30:00.000Z",
  "phase": "implementation",
  "error": "TypeError: Cannot read property 'id' of undefined",
  "context": {
    "agent": "executor-high",
    "model": "opus",
    "task": "Backend API implementation"
  },
  "stack": "..."
}
```

---

## 12. 사용자 상호작용 프로토콜

### 12.1 확인 지점

**다음 phase로 진행하기 전에 사용자가 확인해야 합니다:**

```bash
# Phase 완료 후
✅ design-analysis phase complete.

Generated artifacts:
- .omc/web-projects/todo-app/docs/design-analysis.md
- .omc/web-projects/todo-app/figma-designs/ (5 images)

Next phase: requirements

👉 Review the design analysis, then say:
   - "continue" or "next" to proceed to requirements phase
   - "/web-autopilot:requirements" to start manually
```

### 12.2 Phase 재실행

**사용자는 실패한 phase를 재시도할 수 있습니다:**

```bash
# Phase 실패 시
❌ requirements phase failed.
   Error: API spec incomplete

👉 To retry:
   /web-autopilot:requirements
```

---

## 요약

이 COMMON.md는 모든 web-autopilot phase의 공유 기반을 정의합니다:

✅ **State 관리** - 읽기/쓰기 패턴, 스키마, 생명주기
✅ **파일 경로** - 모든 산출물에 대한 표준화된 위치
✅ **Agent 위임** - 모델 선택, 프롬프트 템플릿
✅ **오류 처리** - 캡처, 재시도, 사용자 알림
✅ **검증** - 증거 요구사항, Ralph loop
✅ **Phase 의존성** - 순차 실행 규칙

**각 phase SKILL.md는 다음을 수행해야 합니다:**
1. 공유 규약을 위해 COMMON.md 읽기
2. Phase별 작업만 정의
3. 여기에 정의된 모든 표준 준수
4. 적절한 agent에 위임
5. State를 올바르게 업데이트
6. 명확한 완료 증거 제공
