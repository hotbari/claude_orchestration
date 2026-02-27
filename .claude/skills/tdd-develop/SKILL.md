---
name: tdd-develop
description: 백엔드+프론트엔드 TDD 구현을 병렬로 실행. /tdd-backend과 /tdd-frontend을 동시에 실행합니다.
argument-hint: [프로젝트명] [구현할 기능]
---

# /tdd-develop — TDD 개발 스킬 (백엔드 + 프론트엔드 병렬)

Backend Developer와 Frontend Developer를 **병렬로** 실행하여 양쪽을 동시에 구현합니다.
개별 실행이 필요하면 `/tdd-backend` 또는 `/tdd-frontend`을 직접 사용하세요.

## 인자 파싱

`$ARGUMENTS`에서 첫 번째 단어를 프로젝트명으로, 나머지를 구현 범위로 파싱합니다.
- 예: `/tdd-develop bookstore_order 주문 관리 기능`
- 프로젝트 경로: `projects/{프로젝트명}/`

## 사전 조건

- `projects/{프로젝트명}/docs/specs/technical-spec.md`가 존재해야 합니다.
- `projects/{프로젝트명}/docs/api/api-spec.md`가 존재해야 합니다.

## 지시사항

1. 사전 조건 파일 존재 여부를 확인합니다.

2. **두 서브에이전트를 병렬로 실행합니다** (Task 도구 2개를 동시 호출):

   **Task A — Backend Developer**:
   - `subagent_type`: "general-purpose"
   - 프로젝트 경로: `projects/{프로젝트명}/`
   - `docs/specs/technical-spec.md`, `docs/api/api-spec.md` 읽기
   - **backend만 담당** (frontend 건드리지 않을 것)
   - TDD 사이클 엄격 준수
   - `.claude/agents/backend-developer.md`의 절차를 따를 것
   - 산출물: `backend/tests/**`, `backend/src/**`, `backend/requirements.txt`

   **Task B — Frontend Developer**:
   - `subagent_type`: "general-purpose", `model`: "sonnet"
   - 프로젝트 경로: `projects/{프로젝트명}/`
   - `docs/specs/technical-spec.md`, `docs/api/api-spec.md` 읽기
   - **frontend만 담당** (backend 건드리지 않을 것)
   - TDD 사이클 준수
   - `.claude/agents/frontend-developer.md`의 절차를 따를 것
   - `.claude/skills/tdd-frontend/templates/design-system.md` 읽기 지시 (디자인 시스템 명세)
   - `.claude/skills/tdd-frontend/templates/color-palettes.md` 읽기 지시 (컬러 팔레트)
   - `.claude/skills/tdd-frontend/templates/component-tests.md` 참조 (UI 컴포넌트 테스트 패턴)
   - `projects/{프로젝트명}/design-config.json` 읽기 지시 (존재 시, 팔레트/레이아웃/Figma 설정)
   - Figma MCP 도구 사용 지시: `design-config.json`에 `figmaUrl`이 있으면 MCP로 Figma 디자인을 실시간 조회하여 스타일 반영
   - 산출물: `frontend/tests/**`, `frontend/src/**`, `frontend/package.json`

3. 두 서브에이전트 완료 후:
   - 백엔드 테스트 실행: `cd projects/{프로젝트명}/backend && pytest`
   - 프론트엔드 테스트 실행: `cd projects/{프로젝트명}/frontend && npx vitest run`
   - 사용자에게 양쪽 구현 요약 보고

## 산출물

- `projects/{프로젝트명}/backend/**` (테스트 + 소스)
- `projects/{프로젝트명}/frontend/**` (테스트 + 소스)
