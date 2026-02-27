---
name: tdd-frontend
description: React 프론트엔드를 TDD로 구현. 아키텍처 설계(Phase 2) 완료 후 사용합니다.
argument-hint: [프로젝트명] [구현할 컴포넌트 또는 페이지]
---

# /tdd-frontend — 프론트엔드 TDD 개발 스킬

기술 스펙과 API 명세를 바탕으로 React 프론트엔드를 TDD로 구현합니다.

## 인자 파싱

`$ARGUMENTS`에서 첫 번째 단어를 프로젝트명으로, 나머지를 구현 범위로 파싱합니다.
- 예: `/tdd-frontend bookstore_order 주문 페이지`
- 프로젝트 경로: `projects/{프로젝트명}/`

## 사전 조건

- `projects/{프로젝트명}/docs/specs/technical-spec.md`가 존재해야 합니다.
- `projects/{프로젝트명}/docs/api/api-spec.md`가 존재해야 합니다.
- 파일이 없으면 `/architect {프로젝트명}`을 먼저 실행하도록 안내합니다.

## 지시사항

1. 사전 조건 파일 존재 여부를 확인합니다.
2. Task 도구로 `frontend-developer` 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose"
   - `model`: "sonnet"
   - 프롬프트에 다음을 포함:
     - 프로젝트 경로: `projects/{프로젝트명}/`
     - `docs/specs/technical-spec.md` 읽기 지시
     - `docs/api/api-spec.md` 읽기 지시 (API 인터페이스 참조)
     - 범위 지정: `$ARGUMENTS` 나머지 부분 (있는 경우)
     - **frontend만 담당**, backend 건드리지 않을 것
     - TDD 사이클 준수
     - `.claude/agents/frontend-developer.md`의 절차를 따를 것
     - `.claude/skills/tdd-develop/templates/test-template.md` 참조
     - `.claude/skills/tdd-frontend/templates/design-system.md` 읽기 지시 (디자인 시스템 명세)
     - `.claude/skills/tdd-frontend/templates/color-palettes.md` 읽기 지시 (컬러 팔레트)
     - `.claude/skills/tdd-frontend/templates/component-tests.md` 참조 (UI 컴포넌트 테스트 패턴)
     - `projects/{프로젝트명}/design-config.json` 읽기 지시 (존재 시, 팔레트/레이아웃/Figma 설정)
     - Figma MCP 도구 사용 지시: `design-config.json`에 `figmaUrl`이 있으면 MCP로 Figma 디자인을 실시간 조회하여 스타일 반영
     - design-system.md의 "전 화면 사이즈 통일 규격" 기본 레이아웃 적용
     - ContentContainer(1280px) 모든 페이지 필수
     - design-config.json에 커스텀 값 없으면 기본값 적용 (Header 64px, Sidebar 260px, min-w 1440px)
     - Figma MCP로 각 컴포넌트/페이지의 시각적 세부사항을 추출하여 코드에 반영
     - Figma 디자인과 생성 코드의 시각적 결과물이 동일하도록 구현

3. 서브에이전트 완료 후:
   - `projects/{프로젝트명}/frontend/tests/` 테스트 파일 존재 확인
   - `projects/{프로젝트명}/frontend/src/` 소스 파일 존재 확인
   - 테스트 실행 결과 확인
   - 사용자에게 프론트엔드 구현 요약 보고

## 산출물

- `projects/{프로젝트명}/frontend/tests/**`
- `projects/{프로젝트명}/frontend/src/**`
- `projects/{프로젝트명}/frontend/package.json`
- `projects/{프로젝트명}/frontend/nginx.conf`
