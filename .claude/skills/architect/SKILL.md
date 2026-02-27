---
name: architect
description: 시스템 아키텍처 및 API 설계. 요구사항 분석(Phase 1) 완료 후 사용합니다.
argument-hint: [프로젝트명]
---

# /architect — 아키텍처 설계 스킬

요구사항 문서를 바탕으로 기술 설계와 API 명세를 작성합니다.

## 인자 파싱

`$ARGUMENTS`에서 프로젝트명을 파싱합니다.
- 예: `/architect bookstore_order`
- 프로젝트 경로: `projects/{프로젝트명}/`

## 사전 조건

- `projects/{프로젝트명}/docs/specs/requirements.md`가 존재해야 합니다 (Phase 1 완료).
- 파일이 없으면 사용자에게 `/research`를 먼저 실행하도록 안내합니다.

## 지시사항

1. `projects/{프로젝트명}/docs/specs/requirements.md` 존재 여부를 확인합니다.
2. Task 도구로 `architect` 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose"
   - `model`: "sonnet"
   - 프롬프트에 다음을 포함:
     - `projects/{프로젝트명}/docs/specs/requirements.md` 읽기 지시
     - 프로젝트 경로 기준으로 기술 스펙 문서 작성 지시
     - Docker Compose 기반 구조 설계 포함
     - API 명세 작성 지시
     - 템플릿 참조
     - `.claude/agents/architect.md`의 절차를 따를 것

3. 서브에이전트 완료 후:
   - `projects/{프로젝트명}/docs/specs/technical-spec.md` 존재 확인
   - `projects/{프로젝트명}/docs/api/api-spec.md` 존재 확인
   - 사용자에게 설계 요약 보고

## 산출물

- `projects/{프로젝트명}/docs/specs/technical-spec.md`
- `projects/{프로젝트명}/docs/api/api-spec.md`
