# Ralph Loop 가이드

## 개요

**Ralph 패턴 철학**: "검증 없이 완료를 주장하지 마십시오"

Ralph는 모든 품질 게이트가 통과될 때까지 멈추지 않고 지속적인 검증 사이클을 통해 작업이 정확함을 증명합니다.

**핵심 원칙**:
- 낙관적 완료 금지 ("작동할 것입니다" 금지)
- 증거 기반 진행 (신선한 검증 필요)
- 자동화된 지속성 (검증될 때까지 루프)
- 제한된 반복 (최대 5회, 그 다음 에스컬레이션)

## 프로토콜 (5단계: QA 및 리팩토링)

**핵심 요구사항**:
1. 완료를 위해 Architect 승인 필요
2. 최대 5회 반복 (무한 루프 방지)
3. 상태 추적: `.omc/state/autopilot-state.json`

참조: IMPLEMENTATION_PLAN.md 라인 817-820

---

## 루프 구조

```
START (iterationCount = 0)
  ↓
1. RUN TESTS (unit + E2E, record timestamps)
  ↓
2. BUILD VERIFICATION (npm run build, tsc, lsp_diagnostics_directory)
  ↓
3. ARCHITECT REVIEW (Task with architect agent, model=opus)
  ↓
  ┌─────────┐
  │ Result? │
  └─────────┘
      ↓
  ┌───┴────┐
APPROVED  REJECTED
  │          │
  EXIT       ↓
         4. REFACTOR & FIX (address feedback)
             ↓
         5. INCREMENT (iterationCount++, update state)
             ↓
         ┌───────┐
         │Count? │
         └───────┘
             ↓
         ┌───┴────┐
        <5      >=5
         │        │
    LOOP BACK  ESCALATE
               (user decides)
```

---

## 상태 관리

### 상태 파일 위치

`.omc/state/autopilot-state.json`

### Ralph 특정 상태 스키마

```javascript
{
  "sessionId": "uuid-v4",
  "currentPhase": "qa-refactoring",
  "startTime": "2026-02-26T10:00:00Z",

  "ralphLoop": {
    "iterationCount": 0,           // Current iteration (0-5)
    "maxIterations": 5,             // Hard limit
    "lastReviewResult": "pending",  // "pending" | "approved" | "rejected"
    "lastReviewTimestamp": "2026-02-26T10:15:00Z",
    "architectFeedback": [          // History of all feedback
      {
        "iteration": 1,
        "result": "rejected",
        "timestamp": "2026-02-26T10:15:00Z",
        "feedback": "Error handling in API routes insufficient",
        "issuesFound": 3
      }
    ]
  },

  "verification": {
    "lastBuildTime": "2026-02-26T10:10:00Z",
    "buildStatus": "success",
    "lastTestRun": "2026-02-26T10:12:00Z",
    "testsPassed": 42,
    "testsFailed": 0
  }
}
```

### 상태 업데이트 요구사항

**모든 반복은 반드시:**
1. `ralphLoop.iterationCount` 증가
2. `ralphLoop.lastReviewResult` 업데이트
3. `ralphLoop.architectFeedback`에 항목 추가
4. `verification.lastBuildTime` 및 `verification.lastTestRun` 업데이트

---

## 종료 조건

### 성공 종료
**조건**: Architect가 `APPROVED` 반환
**조치**: 상태를 `"approved"`로 업데이트, 5단계 완료 표시, 6단계로 진행

### 실패 종료 (최대 반복)
**조건**: `iterationCount >= 5` AND 승인되지 않음
**조치**: 상태를 `"max_iterations_exceeded"`로 설정, 사용자에게 에스컬레이션, 결정 대기

---

## 증거 요구사항

참조: IMPLEMENTATION_PLAN.md 라인 804-815

**신선도**: 증거는 5분 이내, 현재 반복에서, 최신 코드를 반영해야 함

| 확인 | 필요한 증거 | 신선도 |
|-------|------------------|-----------|
| Unit Tests | `npm test` PASS 출력 | <5분 |
| E2E Tests | `npm run test:e2e` PASS 출력 | <5분 |
| Build | `npm run build` exit 0 | <5분 |
| Type Check | `tsc --noEmit` 오류 없음 | <5분 |
| Architect | 명시적 `APPROVED` | 현재 반복 |

**금지된 주장** (신선한 증거 없이):
- "이제 작동할 것입니다" / "아마도 수정됨" / "좋아 보입니다" / "테스트가 통과할 것입니다"
- 실제 통과하는 테스트/빌드 출력을 **반드시** 보여야 함

---

## 에스컬레이션 프로토콜

### 에스컬레이션 시기

다음의 경우 사용자에게 에스컬레이션:
1. `ralphLoop.iterationCount >= 5` (최대 반복 도달)
2. 3회 연속 반복에서 동일한 architect 피드백 (루프에 갇힘)
3. architect 요구사항 간의 해결할 수 없는 충돌

### 에스컬레이션 보고서 템플릿

```
Ralph loop reached max iterations (5).

요약:
- Build: PASSING/FAILING
- Tests: X/Y passed
- Architect Review: REJECTED

반복 히스토리:
  1. [피드백] → [조치] → REJECTED
  2. [피드백] → [조치] → REJECTED
  ...

현재 차단 요소: [주요 문제 나열]

옵션:
1. 계속 진행 (재정의)
2. 가이드 제공 및 계속
3. 중단 및 롤백

결정하세요?
```

### 사용자 결정 처리

1. **재정의**: 거부에도 불구하고 완료 표시, `{ "ralphOverride": true }` 추가
2. **가이드**: 카운트를 0으로 재설정, 새 컨텍스트로 재개
3. **중단**: 실패로 표시, 선택적으로 롤백 (git reset)

---

## 모범 사례

### 1. 완료를 주장하기 전에 항상 검증
```typescript
// ❌ Bad: return { status: "complete" }; // "This should work now"
// ✅ Good:
const build = await runBuild();
const tests = await runTests();
const review = await getArchitectReview();
if (build.success && tests.passed && review.approved) {
  return { status: "complete", evidence: {...} };
}
```

### 2. 문제를 즉시 수정 (동일한 반복)
```typescript
// ❌ Bad: issues.push(feedback); return { status: "in_progress" };
// ✅ Good: for (const issue of feedback.issues) await fixIssue(issue);
```

### 3. 리팩토링을 최소화 (집중된 수정)
- 피드백: "POST /api/users에 오류 처리 누락"
- ❌ Bad: 전체 API 레이어 리팩토링
- ✅ Good: POST /api/users만 수정

### 4. 모든 변경 후 상태 업데이트
```typescript
async function ralphIteration() {
  const state = await loadState();
  await fixIssues(); await runTests();
  const review = await getArchitectReview();

  state.ralphLoop.iterationCount++;
  state.ralphLoop.lastReviewResult = review.result;
  state.ralphLoop.architectFeedback.push({...});
  await saveState(state);
  return review;
}
```

### 5. Architect에게 컨텍스트 제공
```typescript
const prompt = `Review Phase 5 (Iteration ${n}).
Previous: ${previousFeedback}
Changes: ${changes}
Review for: quality, errors, performance, security.
Respond: APPROVED or REJECTED with feedback.`;
```

---

## 예제: 전형적인 3회 반복 루프

**컨텍스트**: "인증이 있는 작업 관리를 위한 REST API 구축"

### 반복 1
- Tests: 35/35 통과
- Build: 성공
- Architect: REJECTED (3개 보안 문제: 토큰 만료, 속도 제한, 이메일 확인)
- State: `iterationCount=1, lastReviewResult="rejected"`

### 반복 2
- Changes: 3개 보안 문제 수정, 테스트 추가
- Tests: 38/38 통과
- Build: 성공
- Architect: REJECTED (3개 새로운 문제: 하드코딩된 구성, 재시도 로직 없음, 테스트 누락)
- State: `iterationCount=2`

### 반복 3
- Changes: 환경 구성, 재시도 로직, 통합 테스트
- Tests: 42/42 통과
- Build: 성공
- Architect: APPROVED ("모든 우려 사항 해결됨, 프로덕션 준비됨")
- State: `iterationCount=3, lastReviewResult="approved"`
- **결과**: 5단계 완료 → 6단계 (사용자 데모)

---

## 요약

Ralph 루프는 다음을 통해 품질을 보장합니다:
1. **지속적인 검증** 모든 변경 후
2. **Architect 게이트 완료** (자체 승인 없음)
3. **제한된 반복** 무한 루프 방지
4. **증거 기반 진행** (낙관적 주장 없음)
5. **자동 에스컬레이션** 한계 도달 시

**핵심 요점**: Ralph는 "신뢰하되 검증하라"는 원칙을 구현합니다—완료를 가정하지 말고 항상 증명하십시오.
