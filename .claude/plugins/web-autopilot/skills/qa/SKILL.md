---
name: qa
description: QA & Refactoring Loop (Ralph Pattern) - test, review, refactor until architect APPROVED
version: 1.0.0
---

# QA & Refactoring Phase

## 개요

**Ralph Pattern** 구현: architect 승인까지 검증-리팩토링 사이클 (최대 5회 반복)

**철학:** 검증 없이 "완료"라고 주장하지 않음. Architect 승인이 유일한 종료 조건

---

## 전제 조건

| 요구사항 | 상태 | 비고 |
|----------|------|------|
| State | `phases.implementation === "completed"` | 필수 |
| Backend/Frontend | 필수 | 코드가 존재해야 함 |

---

## 입력

| 입력 | 소스 | 필수 |
|------|------|------|
| Backend code | `projects/{service}-backend/` | Yes |
| Frontend code | `projects/{service}-frontend/` | Yes |
| PRD | `docs/PRD.md` | Yes |
| Architecture | `docs/architecture.md` | Yes |

---

## 출력

| 출력 | 경로 |
|------|------|
| Unit tests (backend) | `backend/tests/` |
| Unit tests (frontend) | `frontend/__tests__/` |
| E2E tests | `frontend/e2e/` |
| Review report | `docs/review-report.md` |
| Security report | `docs/security-report.md` |

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| tdd-guide | sonnet | Unit test 전략 |
| executor | sonnet | 테스트 구현, 수정 |
| qa-tester-high | opus | E2E 테스팅 |
| build-fixer | sonnet | Build 오류 해결 |
| architect | opus | 코드 리뷰, 승인 |
| security-reviewer | opus | 보안 감사 |
| executor-high | opus | 리팩토링 |

---

## Ralph Loop 프로토콜

**최대 반복:** 5
**종료:** Architect APPROVED 또는 최대 도달

```javascript
state.ralphLoop = {
  iterationCount: 0,
  maxIterations: 5,
  lastReviewResult: "pending" | "approved" | "rejected"
}
```

---

## 단계별 프로세스

### Step 0: 의존성 확인

1. `phases.implementation === 'completed'` 검증
2. backend/frontend 파일 존재 확인
3. `stateManager.updatePhase('qa', 'in_progress')`

### Step 1: Ralph Loop 초기화

1. `stateManager.updateRalphIteration(0)`
2. `stateManager.updateReviewResult('pending')`
3. 생성: `backend/tests/`, `frontend/__tests__/`, `frontend/e2e/`

---

## LOOP START

### Step 2: 반복 증가

```javascript
stateManager.updateRalphIteration(iteration + 1);
```

### Step 3: Phase 5.1 - Unit 테스팅

**Backend (tdd-guide + executor):**
- API 엔드포인트, DB 모델, services에 대한 pytest 테스트
- 파일: `conftest.py`, `test_api_*.py`, `test_models.py`

**Frontend (tdd-guide + executor):**
- 컴포넌트, utils, hooks에 대한 Jest + RTL
- 파일: `__tests__/components/*.test.tsx`

**실행:** `pytest -v` 및 `npm test -- --coverage`

**실패 시:** executor가 수정, 재실행 (최대 3회 시도)

### Step 4: Phase 5.2 - E2E 테스팅

**qa-tester-high:** Playwright E2E 테스트
- PRD의 사용자 플로우
- API 통합 테스트
- 크로스 브라우저 (Chrome, Firefox, webkit)

**실행:** `npx playwright test`

**실패 시:** executor가 수정, 재실행

### Step 5: Phase 5.3 - Build & Type Check

**build-fixer:**
- Backend: `uvicorn` 시작, `mypy` 통과
- Frontend: `next build` 성공, `tsc --noEmit` 통과

**실패 시:** build-fixer가 해결

### Step 6: Phase 5.4 - Architect 코드 리뷰

**architect:** 종합 리뷰
- 아키텍처 준수
- 코드 품질 (가독성, DRY)
- 모범 사례 (오류 처리, 검증)
- 보안 (비밀 정보 없음, 주입 방지)
- 성능 (N+1 쿼리 없음)

**출력:** APPROVED 또는 REJECTED + 피드백

작성 위치: `docs/review-report.md`

**APPROVED:** Step 8로 이동
**REJECTED:** Step 7로 이동

### Step 7: Phase 5.5 - 리팩토링

**executor-high:** Architect 피드백 적용
- 필수 수정
- 코드 구조 개선
- 보안 수정

**Loop 확인:**
```javascript
if (iteration >= 5) {
  // Escalate to user
  return { status: 'MAX_ITERATIONS' };
}
// GOTO Step 2
```

---

## LOOP END

---

### Step 8: Phase 5.6 - 최종 검증

**architect APPROVED인 경우에만**

#### 8.1 보안 리뷰 (security-reviewer)

OWASP Top 10 검사:
- Injection, Auth, XSS, CSRF
- 비밀 정보 관리
- API 보안

작성 위치: `docs/security-report.md`

**실패:** Step 7로 복귀

#### 8.2 실행 테스트 (qa-tester-high)

1. Backend 시작: `uvicorn app.main:app`
2. Frontend 시작: `npm run dev`
3. 검증: API 응답, frontend 로드, DB 연결
4. Smoke test: 사용자 플로우 하나 완료

#### 8.3 최종 체크리스트

- [ ] Unit 테스트 통과
- [ ] E2E 테스트 통과
- [ ] Build 성공
- [ ] Architect APPROVED
- [ ] Security PASSED
- [ ] Services 실행 중

**모두 통과:** `stateManager.updatePhase('qa', 'completed')`

### Step 9: 완료 보고

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
- [ ] Services 검증됨
- [ ] `state.phases.qa === "completed"`

---

## 오류 처리

### 최대 반복 도달
- Loop 중지, 사용자에게 알림
- 최신 피드백 제공
- 요청: 수동 계속, 중단 또는 오버라이드

### Test 환경 실패
- 포트 확인 (8000, 3000)
- build-fixer에 위임
- 해결 불가능하면 사용자에게 알림

### 중요 보안 문제
- 사용자에게 즉시 플래그
- 계속 진행하려면 명시적 승인 필요

---

## 참조

- `references/testing-strategy.md`
- `references/verification-checklist.md`
- `references/ralph-loop-guide.md`
- `references/security-checklist.md`

---

## 요약

1. **초기화** - Loop 재설정, test 디렉토리 생성
2. **Loop** (최대 5회):
   - Unit 테스트 (pytest + Jest)
   - E2E 테스트 (Playwright)
   - Build 확인
   - Architect 리뷰
   - 거부되면 리팩토링
3. **최종** - 보안 감사 + 실행 테스트
4. **완료** - Architect APPROVED

**성공:** Architect APPROVED, 모든 테스트 통과, 보안 클리어, services 실행 중
