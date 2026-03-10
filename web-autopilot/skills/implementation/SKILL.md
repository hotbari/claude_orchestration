---
name: implementation
description: Code implementation - Backend (FastAPI) then Frontend (Next.js + shadcn/ui)
version: 2.0.0
---

# Implementation Phase

## 개요

Backend (API 계약) → Frontend (API 사용) → Integration 순차 구현

---

## 전제 조건 & 입출력

**State:** `phases.architecture === "completed"`
**입력:** design-analysis.md, prd.md, api-spec.md, db-schema.md, architecture.md
**출력:** `projects/{service}-backend/`, `projects/{service}-frontend/`

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| executor-high | opus | Backend 구현 + Testing |
| designer-high | opus | Frontend 구현 (Figma 충실도 준수) |

**Frontend 중요:** `references/figma-fidelity-rules.md` 필수 준수

---

## Phase 4.1: Backend 구현

### 1. 환경 설정
```bash
cd projects/{service}-backend
cp .env.example .env
# DATABASE_URL, SECRET_KEY, CORS_ORIGINS 설정
pip install -r requirements.txt
```

### 2. executor-high 위임
```
Implement FastAPI backend:

1. SQLAlchemy 2.0 models (db-schema.md)
2. Alembic migrations → alembic upgrade head
3. Pydantic schemas (api-spec.md)
4. Repository layer (DB access)
5. Service layer (business logic)
6. API endpoints (dependency injection, HTTPException)
7. Unit tests (pytest, 80%+ coverage)

Output: projects/{service}-backend/
```

### 3. 검증 체크리스트
```bash
# 필수 통과
alembic upgrade head          # Migration 실행
uvicorn app.main:app --reload # 서버 시작 (http://localhost:8000)
curl http://localhost:8000/docs # Swagger 확인
mypy app/                     # 타입 체크
pytest tests/ -v              # 테스트 실행
```

**통과 조건:**
- [ ] Alembic migration 성공
- [ ] Uvicorn 시작 (에러 없음)
- [ ] `/docs` Swagger UI 접근 가능
- [ ] 모든 API 엔드포인트가 api-spec.md와 일치
- [ ] mypy 타입 체크 통과
- [ ] pytest 모든 테스트 통과 (80%+ coverage)

---

## Phase 4.2: Frontend 구현

### 1. 환경 설정
```bash
npx create-next-app@latest projects/{service}-frontend \
  --typescript --tailwind --eslint --app
cd projects/{service}-frontend
npx shadcn-ui@latest init
npx shadcn-ui@latest add button input card dialog form select
cp .env.local.example .env.local
# NEXT_PUBLIC_API_URL=http://localhost:8000 설정
npm install
```

### 2. designer-high 위임
```
Implement Next.js frontend per Figma/docs:

CRITICAL: references/figma-fidelity-rules.md
- Figma layout/text/colors/spacing/icons 정확 보존
- shadcn/ui만 사용, 커스텀 스타일 최소화
- 위치/크기 정확도 우선

1. Design tokens (lib/design-tokens.ts)
2. API client (lib/api/client.ts - axios, interceptors)
3. API services (lib/api/[resource].ts)
4. UI components (components/ui/ - shadcn)
5. Feature components (components/features/)
6. Pages (app/ - App Router)
7. Responsive (Mobile/Tablet/Desktop)

Figma 없는 경우: design-analysis.md 기반 + shadcn defaults
Output: projects/{service}-frontend/
```

### 3. 검증 체크리스트
```bash
# 필수 통과
npm run build                 # Production 빌드
tsc --noEmit                  # 타입 체크
npm run lint                  # ESLint
npm run dev                   # Dev 서버 (http://localhost:3000)
```

**통과 조건:**
- [ ] npm build 성공 (에러 없음)
- [ ] tsc 타입 체크 통과
- [ ] ESLint 통과 (0 warnings)
- [ ] 모든 페이지 렌더링 확인
- [ ] API 연동 테스트 (Backend 연결)
- [ ] Figma 시각 비교 (90%+ 일치)
- [ ] 반응형 확인 (Mobile/Tablet/Desktop)

---

## 최종 검증

### Integration Testing
```bash
# Backend 실행 (Terminal 1)
cd projects/{service}-backend
uvicorn app.main:app --reload

# Frontend 실행 (Terminal 2)
cd projects/{service}-frontend
npm run dev

# E2E 테스트 (선택)
npm run test:e2e
```

### 완료 체크리스트
- [ ] Backend: 모든 API 동작, 테스트 통과
- [ ] Frontend: 빌드 성공, Figma 일치, API 연동
- [ ] E2E: 주요 사용자 플로우 동작 확인
- [ ] 문서: README.md 업데이트 (설치/실행 방법)

**State 업데이트:**
```bash
# .omc/state/phases.json
{"phases":{"implementation":"completed"},"currentPhase":"qa"}
```

---

## 오류 처리

| 오류 유형 | 증상 | 조치 | Agent |
|----------|------|------|-------|
| **Build** ||||
| TypeScript 오류 | tsc fails | 타입 정의 수정 | executor-high |
| Import 오류 | Module not found | 경로/패키지 확인 | build-fixer |
| **Runtime** ||||
| API 연결 실패 | CORS/Network error | CORS 설정, URL 확인 | architect-medium |
| DB 연결 실패 | Connection refused | DATABASE_URL 검증 | executor |
| Migration 실패 | Alembic error | 스키마 롤백 후 재생성 | executor-high |
| **환경** ||||
| 의존성 충돌 | Version mismatch | 재설치 (pip/npm) | build-fixer |
| 포트 충돌 | Address in use | 포트 변경/프로세스 종료 | - |

---

## 참조

**References:** `figma-fidelity-rules.md` (CRITICAL), `shadcn-setup.md`, `fastapi-patterns.md`

---

## 요약

**Backend:** SQLAlchemy+Alembic → FastAPI+Pydantic → Pytest (3-layer clean)
**Frontend:** Next.js+TS+Tailwind → shadcn/ui (Figma 충실) → API 통합
**검증:** Build+Type check+Tests 필수, E2E 권장

**다음:** QA Phase
