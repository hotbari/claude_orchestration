---
name: integrate
description: 최종 통합, Docker 설정, 문서화, 배포 준비. 코드 리뷰(Phase 4) 통과 후 사용합니다.
argument-hint: [프로젝트명]
---

# /integrate — 최종 통합 스킬

리뷰 피드백을 반영하고, Docker Compose 환경을 구성하며, 배포 가능한 상태로 만듭니다.

## 인자 파싱

`$ARGUMENTS`에서 프로젝트명을 파싱합니다.
- 예: `/integrate bookstore_order`
- 프로젝트 경로: `projects/{프로젝트명}/`

## 사전 조건

- `projects/{프로젝트명}/docs/reviews/review-report.md`가 존재해야 합니다 (Phase 4 완료).
- 리포트에 `REVIEW_FAILED` 마커가 없어야 합니다.
- 조건 미충족 시 사용자에게 `/review`를 먼저 실행하도록 안내합니다.

## 지시사항

1. 사전 조건 확인.
2. Task 도구로 `integrator` 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose"
   - 프롬프트에 다음을 포함:
     - 프로젝트 경로: `projects/{프로젝트명}/`
     - 리뷰 리포트 읽기 지시
     - Warning/Suggestion 피드백 반영 지시
     - Docker 환경 구성 지시:
       - `projects/{프로젝트명}/docker-compose.yml`
       - `projects/{프로젝트명}/Dockerfile.api`
       - `projects/{프로젝트명}/Dockerfile.frontend`
     - README.md 생성/업데이트 지시 (docker compose 실행 가이드 포함)
     - `.env.example` 생성 지시
     - 최종 통합 테스트 실행 지시
     - `.claude/agents/integrator.md`의 절차를 따를 것

3. 서브에이전트 완료 후:
   - 전체 테스트 통과 확인
   - `projects/{프로젝트명}/docker-compose.yml` 존재 확인
   - `projects/{프로젝트명}/README.md` 존재 확인
   - 사용자에게 통합 완료 보고 + `docker compose up --build` 실행 안내

## 산출물

- `projects/{프로젝트명}/docker-compose.yml`
- `projects/{프로젝트명}/Dockerfile.api`
- `projects/{프로젝트명}/Dockerfile.frontend`
- `projects/{프로젝트명}/README.md`
- `projects/{프로젝트명}/.env.example`
