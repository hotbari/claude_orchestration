---
name: qa
description: QA & Refactoring Loop (Ralph Pattern) - test, review, refactor until architect APPROVED
version: 1.0.0
---

# QA & Refactoring Phase

## 개요

**Ralph Pattern:** architect 승인까지 검증-리팩토링 사이클 (최대 5회)

**철학:** 검증 없이 "완료" 금지. Architect 승인이 유일한 종료 조건

---

## 전제 조건 & 입출력

**State:** `phases.implementation === "completed"`

**출력:**
- `backend/tests/`, `frontend/__tests__/`, `frontend/e2e/`
- `docs/review-report.md`, `docs/security-report.md`

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| tdd-guide | sonnet | Unit test 전략 |
| executor | sonnet | 테스트 구현/수정 |
| qa-tester-high | opus | E2E 테스팅 |
| build-fixer | sonnet | Build 오류 |
| architect | opus | 코드 리뷰/승인 |
| security-reviewer | opus | 보안 감사 |
| executor-high | opus | 리팩토링 |

---

## Ralph Loop

**최대:** 5회
**종료:** Architect APPROVED 또는 최대 도달

```javascript
state.ralphLoop = {
  iterationCount: 0,
  maxIterations: 5,
  lastReviewResult: "pending" | "approved" | "rejected"
}
```

---

## 프로세스

### Step 0: 초기화

1. `phases.implementation === 'completed'` 검증
2. `updateRalphIteration(0)`, `updateReviewResult('pending')`
3. test 디렉토리 생성

---

## LOOP (최대 5회)

### Step 1: 반복 증가
```javascript
updateRalphIteration(iteration + 1);
```

### Step 2: Unit 테스팅

**Backend (tdd-guide + executor):**
- pytest: API, DB, services
- `pytest -v`

**Frontend (tdd-guide + executor):**
- Jest+RTL: 컴포넌트, utils, hooks
- `npm test -- --coverage`

**실패:** executor 수정 (최대 3회)

<!-- 생략: Test fixtures, Coverage 목표 -->

---

### Step 3: E2E 테스팅

**qa-tester-high:** Playwright E2E
- PRD 플로우, API 통합, 크로스 브라우저
- `npx playwright test`

---

### Step 4: Build & Type Check

**build-fixer:**
- Backend: `uvicorn`, `mypy`
- Frontend: `next build`, `tsc --noEmit`

---

### Step 5: Architect 리뷰

**architect (opus):**
- 아키텍처 준수, 코드 품질, 모범 사례, 보안, 성능
- 출력: `docs/review-report.md`
- **APPROVED** → Step 7 (최종 검증)
- **REJECTED** → Step 6 (리팩토링)

<!-- 생략: Review criteria -->

---

### Step 6: 리팩토링

**executor-high (opus):**
- Architect 피드백 적용
- 필수 수정, 구조 개선, 보안 수정

**Loop 확인:**
```javascript
if (iteration >= 5) return { status: 'MAX_ITERATIONS' };
// GOTO Step 1
```

---

## LOOP END

---

### Step 7: 최종 검증

**Architect APPROVED인 경우**

**7.1 보안 리뷰 (security-reviewer):**
- OWASP Top 10, 비밀 관리, API 보안
- 출력: `docs/security-report.md`
- 실패 → Step 6

**7.2 실행 테스트 (qa-tester-high):**
- Backend: `uvicorn app.main:app`
- Frontend: `npm run dev`
- 검증: API 응답, frontend 로드, DB 연결
- Smoke test: 플로우 하나 완료

**7.3 최종 체크리스트:**
- [ ] Unit 통과
- [ ] E2E 통과
- [ ] Build 성공
- [ ] Architect APPROVED
- [ ] Security PASSED
- [ ] Services 실행 중

**모두 통과:** `updatePhase('qa', 'completed')`

---

### Step 8: 완료 보고

```
QA Phase Complete.
Iterations: {n}, Result: APPROVED
Next: /web-autopilot:completion
```

---

## 검증 체크리스트

- [ ] `state.ralphLoop.lastReviewResult === "approved"`
- [ ] 모든 테스트 통과
- [ ] Build 성공
- [ ] Security 통과
- [ ] Services 검증
- [ ] `state.phases.qa === "completed"`

---

## 오류 처리

| 오류 | 조치 |
|------|------|
| 최대 반복 | Loop 중지, 사용자 알림 |
| Test 환경 실패 | 포트 확인, build-fixer |
| 보안 문제 | 즉시 플래그, 승인 필요 |

---

**요약:** 초기화 → Loop (Unit/E2E/Build/Architect/리팩토링) → 최종 (보안/실행) → 완료

**성공:** Architect APPROVED, 테스트 통과, 보안 클리어, services 실행 중
