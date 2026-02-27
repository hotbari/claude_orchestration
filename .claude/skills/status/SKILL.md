---
name: status
description: 현재 파이프라인 진행 상태를 확인합니다.
argument-hint: [프로젝트명]
---

# /status — 파이프라인 상태 확인

각 Phase의 산출물 존재 여부를 확인하여 현재 진행 상태를 보고합니다.

## 인자 파싱

`$ARGUMENTS`에서 프로젝트명을 파싱합니다.
- 예: `/status bookstore_order`
- 프로젝트 경로: `projects/{프로젝트명}/`
- 인자가 없으면 `projects/` 하위의 모든 프로젝트를 나열합니다.

## 지시사항

### 프로젝트명이 주어진 경우

다음 파일들의 존재 여부를 확인하고 상태를 보고합니다:

| Phase | 산출물 | 경로 |
|-------|--------|------|
| Phase 1 | requirements.md | `projects/{프로젝트명}/docs/specs/requirements.md` |
| Phase 2 | technical-spec.md | `projects/{프로젝트명}/docs/specs/technical-spec.md` |
| Phase 2 | api-spec.md | `projects/{프로젝트명}/docs/api/api-spec.md` |
| Phase 3a | 백엔드 테스트 | `projects/{프로젝트명}/backend/tests/**` |
| Phase 3a | 백엔드 소스 | `projects/{프로젝트명}/backend/src/**` |
| Phase 3b | 프론트엔드 테스트 | `projects/{프로젝트명}/frontend/tests/**` |
| Phase 3b | 프론트엔드 소스 | `projects/{프로젝트명}/frontend/src/**` |
| Phase 4 | review-report.md | `projects/{프로젝트명}/docs/reviews/review-report.md` |
| Phase 4 | REVIEW_FAILED 없음 | Read로 마커 확인 |
| Phase 5 | docker-compose.yml | `projects/{프로젝트명}/docker-compose.yml` |
| Phase 5 | README.md | `projects/{프로젝트명}/README.md` |

### 프로젝트명이 없는 경우

`projects/` 하위 디렉토리를 나열하고, 각각의 최종 Phase 상태를 간략히 표시합니다.

### 보고 포맷

```
📊 파이프라인 상태: projects/{프로젝트명}/

Phase 1  (Research):   ✅ 완료 / ❌ 미완료
Phase 2  (Architect):  ✅ 완료 / ❌ 미완료 / ⚠️ 부분 완료
Phase 3a (Backend):    ✅ 완료 / ❌ 미완료
Phase 3b (Frontend):   ✅ 완료 / ❌ 미완료
Phase 4  (Review):     ✅ 통과 / ❌ 미완료 / 🔴 FAILED
Phase 5  (Integrate):  ✅ 완료 / ❌ 미완료

🚀 Docker:
   cd projects/{프로젝트명} && docker compose up --build

➡️ 다음 단계: /[추천 명령어] {프로젝트명} [설명]
```

### 다음 단계 추천

- 모든 Phase 미완료: `/pipeline {프로젝트명} [기능]` 또는 `/research {프로젝트명} [기능]`
- Phase 1만 완료: `/architect {프로젝트명}`
- Phase 2까지 완료: `/tdd-develop {프로젝트명}` (또는 `/tdd-backend`, `/tdd-frontend` 개별 실행)
- Phase 3a만 완료: `/tdd-frontend {프로젝트명}`
- Phase 3b만 완료: `/tdd-backend {프로젝트명}`
- Phase 3까지 완료: `/review {프로젝트명}`
- Phase 4 FAILED (백엔드): `/tdd-backend {프로젝트명}` (Critical 수정 후 재시도)
- Phase 4 FAILED (프론트엔드): `/tdd-frontend {프로젝트명}` (Critical 수정 후 재시도)
- Phase 4 통과: `/integrate {프로젝트명}`
- Phase 5 완료: `cd projects/{프로젝트명} && docker compose up --build`
