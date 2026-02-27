---
name: tdd-backend
description: FastAPI 백엔드를 TDD로 구현. 아키텍처 설계(Phase 2) 완료 후 사용합니다.
argument-hint: [프로젝트명] [구현할 엔드포인트 또는 기능]
---

# /tdd-backend — 백엔드 TDD 개발 스킬

기술 스펙과 API 명세를 바탕으로 FastAPI 백엔드를 TDD(Red-Green-Refactor)로 구현합니다.

## 인자 파싱

`$ARGUMENTS`에서 첫 번째 단어를 프로젝트명으로, 나머지를 구현 범위로 파싱합니다.
- 예: `/tdd-backend bookstore_order 주문 API`
- 프로젝트 경로: `projects/{프로젝트명}/`

## 사전 조건

- `projects/{프로젝트명}/docs/specs/technical-spec.md`가 존재해야 합니다.
- `projects/{프로젝트명}/docs/api/api-spec.md`가 존재해야 합니다.
- 파일이 없으면 `/architect {프로젝트명}`을 먼저 실행하도록 안내합니다.

## 지시사항

1. 사전 조건 파일 존재 여부를 확인합니다.
2. Task 도구로 `backend-developer` 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose"
   - 프롬프트에 다음을 포함:
     - 프로젝트 경로: `projects/{프로젝트명}/`
     - `docs/specs/technical-spec.md` 읽기 지시
     - `docs/api/api-spec.md` 읽기 지시
     - 범위 지정: `$ARGUMENTS` 나머지 부분 (있는 경우)
     - **backend만 담당**, frontend 건드리지 않을 것
     - TDD 사이클(Red → Green → Refactor) 엄격 준수
     - `.claude/agents/backend-developer.md`의 절차를 따를 것
     - `.claude/skills/tdd-develop/templates/test-template.md` 참조

3. 서브에이전트 완료 후:
   - `projects/{프로젝트명}/backend/tests/` 테스트 파일 존재 확인
   - `projects/{프로젝트명}/backend/src/` 소스 파일 존재 확인
   - 테스트 실행 결과 확인
   - 사용자에게 백엔드 구현 요약 보고

## 산출물

- `projects/{프로젝트명}/backend/tests/**`
- `projects/{프로젝트명}/backend/src/**`
- `projects/{프로젝트명}/backend/requirements.txt`
