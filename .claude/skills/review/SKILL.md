---
name: review
description: 엔터프라이즈급 코드 리뷰 및 보안 감사. TDD 개발(Phase 3) 완료 후 사용합니다.
argument-hint: [프로젝트명]
---

# /review — 코드 리뷰 스킬

구현된 코드를 5가지 차원에서 검증하고 상세한 리뷰 리포트를 작성합니다.

## 인자 파싱

`$ARGUMENTS`에서 프로젝트명을 파싱합니다.
- 예: `/review bookstore_order`
- 프로젝트 경로: `projects/{프로젝트명}/`

## 사전 조건

- `projects/{프로젝트명}/backend/src/` 또는 `frontend/src/`에 구현 코드가 존재해야 합니다.
- `projects/{프로젝트명}/backend/tests/` 또는 `frontend/tests/`에 테스트 코드가 존재해야 합니다.
- 파일이 없으면 사용자에게 `/tdd-develop`를 먼저 실행하도록 안내합니다.

## 지시사항

1. 사전 조건 확인.
2. Task 도구로 `reviewer` 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose"
   - `model`: "sonnet"
   - 프롬프트에 다음을 포함:
     - 프로젝트 경로: `projects/{프로젝트명}/`
     - 모든 스펙 문서 읽기 지시
     - 5차원 리뷰 수행 지시
     - 테스트 실행 지시:
       - `cd projects/{프로젝트명}/backend && pytest`
       - `cd projects/{프로젝트명}/frontend && npx vitest run`
     - `.claude/agents/reviewer.md`의 절차를 따를 것
     - `projects/{프로젝트명}/docs/reviews/review-report.md` 출력 지시
     - Critical 발견 시 `REVIEW_FAILED` 마커 포함 지시

3. 서브에이전트 완료 후:
   - `projects/{프로젝트명}/docs/reviews/review-report.md` 존재 확인
   - `REVIEW_FAILED` 마커 여부 확인
   - 사용자에게 리뷰 결과 요약 보고

## 산출물

- `projects/{프로젝트명}/docs/reviews/review-report.md`
