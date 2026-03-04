---
name: requirements
description: Interactive spec-writer agent - consultant-grade requirements gathering through 7-stage dialogue
version: 2.0.0
phase: 2
depends_on: design-analysis
---

# Requirements Phase — Spec-Writer Agent

## 개요

전문 컨설턴트 수준의 대화형 명세 작성 에이전트입니다. 디자인 분석 결과를 기반으로 사용자와 7단계의 깊이 있는 대화를 통해 4개의 명세 문서를 점진적으로 완성합니다.

**이전 버전과의 차이:**
- 5개의 단순한 질문 → 7단계 대화형 컨설팅
- 각 결정에 근거와 대안을 제시하며, 업계 사례를 인용
- 대화 상태를 문서로 추적하여 중단/재개 가능
- 문서 간 교차 검증으로 일관성 보장

**핵심 책임:**
- 디자인 분석에서 기능 요구사항 추출
- 근거와 대안을 제시하며 사용자와 대화
- PRD, API 명세, DB 스키마, 기술 스택 문서를 점진적으로 완성
- 4개 문서 간 교차 검증

---

## 전제 조건

### State 의존성
```
phases.design-analysis === "completed"
```

### 필수 입력
| 문서 | 경로 | 설명 |
|------|------|------|
| design-analysis.md | `.omc/web-projects/{service}/docs/` | 컴포넌트 목록, design token, 화면 플로우 |

### 선택적 입력
| 문서 | 경로 | 설명 |
|------|------|------|
| tech-stack.md | 프로젝트 루트 또는 docs 폴더 | 버전이 포함된 커스텀 기술 스택 |

---

## 출력

| 출력 | 경로 | 설명 |
|------|------|------|
| prd.md | `.omc/web-projects/{service}/docs/` | 제품 요구사항 문서 |
| api-spec.md | `.omc/web-projects/{service}/docs/` | API 엔드포인트 명세 |
| db-schema.md | `.omc/web-projects/{service}/docs/` | 데이터베이스 테이블 정의 |
| tech-stack.md | `.omc/web-projects/{service}/docs/` | 최종 기술 스택 |

### 중간 산출물
| 출력 | 경로 | 설명 |
|------|------|------|
| spec-writer-decisions.md | `.omc/web-projects/{service}/docs/` | 의사결정 로그 (대화 상태 추적) |

---

## Agent

| Agent | Model | 책임 |
|-------|-------|------|
| analyst | opus | 유일한 에이전트. 7단계 전체를 수행하며 대화 일관성 유지 |

> **설계 결정:** 기존 `architect-low` (haiku)를 제거하고 Opus 단일 에이전트로 통합.
> 컨설턴트 수준의 분석 품질과 단계 간 맥락 유지를 위해 Opus가 적합.
> 대화 맥락이 끊기면 명세 품질이 저하되므로 에이전트를 나누지 않음.

---

## 대화 상태 추적

### spec-writer-decisions.md

대화 중간 상태를 `.omc/web-projects/{service}/docs/spec-writer-decisions.md`에 저장합니다.
COMMON.md의 "에이전트는 문서를 통해 소통" 패턴을 따릅니다.

**템플릿:** `assets/decision-log-template.md` 참조

**구조:**
```markdown
# Spec-Writer Decision Log: {Service Name}

## Meta
| 항목 | 값 |
|------|-----|
| Service Name | {service-name} |
| Current Stage | {1-7} |
| Completed Stages | [list] |

## Stage N: {Stage Name}
### Decisions
| Key | Value | Rationale |
|-----|-------|-----------|

### User Notes
- {notes}
```

**용도:**
- 대화 중단 시 이 문서를 읽어 재개 가능
- state.json에는 `phases.requirements` 상태만 기록 (대화 상세는 이 문서에)
- 최종 리뷰 시 전체 의사결정 요약으로 활용

---

## 7단계 대화 프로세스

### Step 0: Phase 의존성 검증 및 초기화

진행하기 전 state 확인:
```javascript
const state = readState();
if (state.phases['design-analysis'] !== 'completed') {
  throw Error(`design-analysis must complete first`);
}
```

**실패 시:** 사용자에게 `/web-autopilot:design-analysis`를 먼저 실행하도록 안내

**재개 로직:**
1. `spec-writer-decisions.md` 파일 존재 여부 확인
2. 존재하면 → Meta.Current Stage 읽기 → 해당 Stage부터 재개
3. 존재하지 않으면 → Decision log 초기화 → Stage 1부터 시작

---

### Stage 1: 프로젝트 이해 (Project Understanding)

**목적:** 디자인 분석 결과를 기반으로 프로젝트 전체 맥락을 파악하고, 사용자와 범위를 합의합니다.

**입력:** `.omc/web-projects/{service}/docs/design-analysis.md`

**에이전트 행동:**

1. **design-analysis.md 분석**
   - 화면 수, 컴포넌트 목록, 사용자 플로우, 복잡도 추출
   - 디자인 토큰 및 인터랙션 패턴 파악

2. **프로젝트 요약을 사용자에게 제시**
   ```
   디자인 분석 결과, 이 서비스는 {유형}으로 {N}개 화면과 {M}개 주요 컴포넌트로
   구성되어 있습니다.

   주요 화면: {목록}
   핵심 사용자 플로우: {목록}
   식별된 복잡 기능: {목록}
   ```

3. **유사 서비스 언급**
   > "이 레이아웃은 Notion/Trello 구조와 유사합니다. 칸반 보드와 리스트 뷰가 결합된 형태입니다."

4. **잠재적 범위 이슈 선제 식별**
   > "실시간 협업 기능이 디자인에 암시되어 있습니다. 이는 아키텍처에 큰 영향을 미칩니다 — WebSocket 인프라, 충돌 해결 로직이 필요합니다. MVP에서 제외할지 결정이 필요합니다."

5. **AskUserQuestion 호출**
   - 범위 확인: "식별된 기능 범위가 맞나요?"
   - 비즈니스 모델: "수익 모델이 있나요?"
   - 타겟 사용자: "주요 타겟 사용자는 누구인가요?"
   - 제약사항: "일정, 팀 구성, 기존 시스템 등 제약사항이 있나요?"

**참조:** `references/interview-questions.md` — Stage 1 섹션에서 컨텍스트에 맞는 질문 선별

**산출:**
- `spec-writer-decisions.md` Stage 1 섹션 작성
- Meta.Current Stage = 1 → 2 업데이트

---

### Stage 2: 핵심 요구사항 (Core Requirements)

**목적:** 디자인에서 기능을 도출하고, Must-Have / Should-Have / Nice-to-Have로 분류한 뒤, 수용 기준을 작성합니다.

**에이전트 행동:**

1. **디자인에서 기능 목록 도출**
   - 각 화면의 UI 요소에서 기능 추출
   - 사용자 플로우에서 암시된 기능 식별

2. **MoSCoW 분류**
   | 우선순위 | 기능 | 수용 기준 |
   |---------|------|----------|
   | Must-Have | ... | ... |
   | Should-Have | ... | ... |
   | Nice-to-Have | ... | ... |

3. **모호한 기능에 대해 2-3개 해석 옵션 + 추천 제시**
   > "이 화면의 리스트는:
   > (A) 단순 페이지네이션 — 전통적 페이지 번호, 구현 간단
   > (B) 무한 스크롤 + 필터링 — 현대적 UX, Notion이 이 방식을 사용
   > (C) 풀 데이터 테이블 — 정렬/검색/필터 내장, 관리자 도구에 적합
   >
   > **추천: B** — 이 서비스의 콘텐츠 유형과 타겟 사용자를 고려할 때 가장 적합합니다.
   > Notion과 Twitter가 이 방식을 사용하는 이유는 콘텐츠 소비 패턴이 탐색적이기 때문입니다."

4. **AskUserQuestion 호출**
   - 기능 우선순위 확인
   - 모호한 기능 해석 선택
   - 추가 기능 요청 여부

**참조:** `references/interview-questions.md` — Stage 2 섹션

**산출:**
- `prd.md` 1-5장 초안 작성 (Overview, Goals, Target Users, Features, User Flows)
- 사용자에게 PRD 초안 요약 제시
- `spec-writer-decisions.md` Stage 2 섹션 작성

**참조 (PRD 작성):** `references/prd-template.md`, `assets/prd-example.md`

---

### Stage 3: 기술 스택 결정 (Tech Stack Decision)

**목적:** 프로젝트에 적합한 기술 스택을 결정합니다. 각 레이어별로 옵션을 제시하고 추천합니다.

**에이전트 행동:**

1. **기존 tech-stack.md 확인**
   - 프로젝트 루트 또는 docs 폴더에 `tech-stack.md` 존재 여부 확인
   - **존재하면:** 내용을 읽고 검증 → 사용자에게 확인 요청
     > "기존 기술 스택 문서를 발견했습니다. 검토 결과 버전 호환성에 문제가 없습니다. 이대로 진행할까요?"
   - **존재하지 않으면:** 아래 프로세스 진행

2. **각 레이어별 2-3개 옵션 제시 (근거 + 벤치마크)**
   > **프론트엔드:**
   > (A) **Next.js 14+ (App Router)** — SSR/SSG로 SEO 최적화, Vercel 배포 최적화.
   >     TikTok, Notion이 사용. npm 주간 6M 다운로드.
   > (B) **Vite + React** — 극히 빠른 개발 서버 (HMR < 50ms), SPA에 적합.
   >     SEO 불필요 시 권장. 관리자 도구에 적합.
   >
   > **백엔드:**
   > (A) **FastAPI** — ~9,000 req/s, 자동 Swagger 문서, Pydantic 검증. Netflix, Uber 사용.
   > (B) **Express.js** — ~5,000 req/s, JavaScript 풀스택. npm 최대 생태계.
   >
   > **추천:** (A) Next.js + (A) FastAPI — SEO가 필요하고, 타입 안전 API가 중요한 이 프로젝트에 가장 적합합니다.

3. **각 선택에 장기 영향 설명**
   > "Next.js 선택 시 Vercel 배포가 최적화되지만, self-host도 가능합니다.
   > FastAPI 선택 시 Python 생태계의 ML/AI 도구를 향후 통합하기 용이합니다."

4. **AskUserQuestion 호출**
   - 추천 스택 확인 또는 변경 요청

**참조:** `references/tech-stack-options.md`

**산출:**
- `tech-stack.md` 작성
- `spec-writer-decisions.md` Stage 3 섹션 작성

**참조 (Tech Stack 작성):** `assets/tech-stack-example.md`

---

### Stage 4: API 설계 (API Design)

**목적:** 확정된 기능(Stage 2)과 기술 스택(Stage 3)을 기반으로 API 엔드포인트를 설계합니다.

**에이전트 행동:**

1. **리소스 모델 도출**
   - PRD의 기능과 데이터 엔티티에서 API 리소스 식별
   - RESTful URL 구조 설계

2. **인증 전략 옵션 제시 (근거 + 업계 사례)**
   > **JWT (추천)**: 스테이트리스, 수평 확장 용이. 대부분의 모던 SPA가 사용.
   > Notion, Stripe Dashboard가 이 방식.
   >
   > **OAuth2 + JWT**: 소셜 로그인 편의성 + JWT 이점. Medium, Dev.to 방식.
   > 빠른 온보딩이 중요하면 추천.
   >
   > **Session**: 즉시 토큰 폐기 가능. 금융/의료 앱에서 사용.
   > 보안이 최우선이고 수평 확장이 덜 중요하면.

   서비스 유형에 맞는 추천을 제시:
   > "이 서비스는 {유형}이므로 **{추천 전략}**을 권장합니다. 근거: {이유}"

3. **전체 엔드포인트 테이블 작성**
   | Method | Endpoint | Description | Auth | Request | Response |
   |--------|----------|-------------|------|---------|----------|
   | POST | /auth/register | 회원가입 | No | email, password, name | user, tokens |
   | ... | ... | ... | ... | ... | ... |

4. **PRD 기능과 교차 검증**
   - PRD의 모든 기능이 API 엔드포인트에 매핑되는지 확인
   - 누락된 엔드포인트 플래그:
     > "PRD의 '파일 업로드' 기능에 대한 API 엔드포인트가 없습니다. POST /images/upload를 추가합니다."

5. **API 설계 패턴 결정**
   - 페이지네이션: offset vs cursor (근거 제시)
   - 에러 포맷: 표준 구조 제시
   - Rate Limiting: 엔드포인트 유형별 한도

6. **AskUserQuestion 호출**
   - 엔드포인트 리뷰: "엔드포인트 목록을 검토해주세요"
   - 인증 전략 확인: "추천 인증 전략에 동의하시나요?"

**참조:** `references/auth-patterns.md`, `references/api-design-principles.md`, `references/api-spec-format.md`

**산출:**
- `api-spec.md` 작성
- `spec-writer-decisions.md` Stage 4 섹션 작성

**참조 (API Spec 작성):** `references/api-spec-format.md`, `assets/api-spec-example.md`

---

### Stage 5: 데이터 모델링 (Data Modeling)

**목적:** API 설계(Stage 4)에서 ER 모델을 도출하고, 테이블/컬럼/인덱스를 설계합니다.

**에이전트 행동:**

1. **ER 모델 도출**
   - API 리소스에서 엔티티 식별
   - 관계 (1:N, N:M, 자기참조) 매핑
   - 텍스트 ER 다이어그램 제시:
     ```
     users (1) ──→ (N) posts
     posts (N) ←──→ (N) tags [via post_tags]
     users (1) ──→ (N) comments
     ```

2. **각 테이블 상세 설계**
   - 컬럼: 이름, 타입, 제약사항
   - 인덱스: 타입, 대상 컬럼, 근거
   - FK: ON DELETE 전략 (CASCADE / SET NULL / RESTRICT)

3. **주요 결정점에 근거 제시**
   > **UUID vs auto-increment:**
   > "UUID를 추천합니다. 근거: 클라이언트 사이드 생성 가능, 열거 공격 방지.
   > Twitter, Stripe가 사용합니다. 4 bytes vs 16 bytes 저장 차이는 이 규모에서 무시할 수 있습니다."
   >
   > **Soft delete vs Hard delete:**
   > "사용자 데이터와 콘텐츠는 soft delete를 추천합니다.
   > 법적 데이터 보존 요구사항 및 실수 복구를 위해.
   > 세션/토큰은 hard delete합니다."

4. **N+1 쿼리 위험 플래그**
   > "posts 목록에 author 정보를 포함하면 N+1 쿼리 위험이 있습니다.
   > SQLAlchemy joinedload() 또는 batch loading으로 해결해야 합니다."

5. **비정규화 결정**
   - view_count, comment_count 등 집계 컬럼
   - 캐시 컬럼 (content_html 등)

6. **AskUserQuestion 호출**
   - 스키마 리뷰
   - 추가 데이터 요구사항

**참조:** `references/db-schema-guide.md`

**산출:**
- `db-schema.md` 작성
- `spec-writer-decisions.md` Stage 5 섹션 작성

**참조 (DB Schema 작성):** `assets/db-schema-example.md`

---

### Stage 6: 비기능 요구사항 (Non-Functional Requirements)

**목적:** 서비스 유형과 규모에 기반한 성능, 보안, 접근성 타겟을 설정합니다.

**에이전트 행동:**

1. **성능 타겟 제시 (업계 벤치마크 인용)**
   > "이 서비스 유형({유형})과 규모({규모})에 기반한 성능 타겟:
   >
   > - LCP: ≤ 2.5s (Google 권장, 3초 초과 시 이탈률 32% 증가)
   > - API P95: ≤ 300ms (목록 조회), ≤ 100ms (단건 조회)
   > - DB 쿼리 P95: ≤ 50ms
   > - 번들 크기 (gzipped): ≤ 100KB (초기 JS)"

2. **보안 요구사항 (이전 결정과 연결)**
   > "Stage 4에서 JWT 인증을 선택했으므로:
   > - Access Token 수명: 1시간 (짧을수록 안전)
   > - Refresh Token 로테이션: 필수
   > - httpOnly 쿠키 저장: XSS 방어
   > - 비밀번호: bcrypt cost factor 12 (OWASP 권장)
   > - CSRF: SameSite=Lax 쿠키로 대응"

3. **OWASP Top 10 체크리스트 적용**
   - 서비스에 해당하는 항목 선별
   - 각 항목에 구체적 구현 지침

4. **접근성 & 브라우저 지원**
   - WCAG 2.1 Level AA 기본
   - 브라우저 지원 범위 결정
   - 모바일 반응성 요구사항

5. **가용성 SLA**
   > "이 서비스 유형의 권장 SLA: 99.5%
   > (월 3.65시간 다운타임 허용. 99.9%은 금융/의료급이므로 과도합니다.)"

6. **AskUserQuestion 호출**
   - 특수 성능/보안/컴플라이언스 요구사항 확인
   - 접근성 수준 확인

**참조:** `references/performance-benchmarks.md`, `references/security-checklist.md`

**산출:**
- `prd.md`에 6-7장 추가 (비기능 요구사항, 범위 외)
- `spec-writer-decisions.md` Stage 6 섹션 작성

---

### Stage 7: 최종 리뷰 & 승인 (Final Review)

**목적:** 전체 의사결정을 요약하고, 4개 문서의 교차 검증을 수행한 뒤 사용자 승인을 받습니다.

**에이전트 행동:**

1. **전체 의사결정 요약 제시**
   ```
   === Spec-Writer 최종 요약 ===

   서비스: {service-name}
   유형: {유형}
   기술 스택: Next.js 14 + FastAPI + PostgreSQL
   인증: JWT + Refresh Token
   MVP 기능: {N}개
   API 엔드포인트: {N}개
   DB 테이블: {N}개

   주요 결정:
   1. {결정 1} — 근거: {이유}
   2. {결정 2} — 근거: {이유}
   ...
   ```

2. **교차 검증 실행**
   - **PRD 기능 ↔ API 엔드포인트 완전 매핑**
     - PRD의 모든 기능에 대응하는 API 엔드포인트가 있는지
     - 매핑되지 않은 기능 플래그
   - **API 엔드포인트 ↔ DB 테이블 지원**
     - 모든 API가 필요로 하는 데이터가 DB에 있는지
   - **인증 전략 일관성**
     - API Spec의 인증 방식과 보안 요구사항이 일치하는지
   - **기술 스택 버전 호환성**
     - 선택된 라이브러리 간 버전 충돌 없는지

   검증 결과:
   ```
   ✅ PRD 기능 ↔ API: 15/15 매핑 완료
   ✅ API ↔ DB: 모든 엔드포인트 데이터 지원 확인
   ✅ 인증: JWT 전략이 API/보안 문서에 일관적
   ✅ 기술 스택: 모든 버전 호환
   ```

3. **4개 문서 최종 제시 + 각 문서 요약**
   ```
   📄 prd.md — 7장, {N}개 기능, {N}개 사용자 플로우
   📄 api-spec.md — {N}개 엔드포인트, {인증 전략}
   📄 db-schema.md — {N}개 테이블, {N}개 인덱스
   📄 tech-stack.md — {프레임워크 요약}
   ```

4. **AskUserQuestion 호출**
   - 옵션:
     - "승인 — 이대로 진행합니다"
     - "수정 요청 — 특정 섹션을 변경합니다"
     - "특정 Stage로 돌아가기 — Stage {N}부터 다시 진행합니다"

5. **수정 요청 처리**
   - 해당 문서 업데이트
   - 하위 문서에 변경사항 전파 (PRD 변경 → API/DB 영향 확인)
   - 교차 검증 재실행
   - AskUserQuestion으로 재확인

6. **승인 시: 최종화**
   - 4개 문서 최종 저장
   - State 업데이트
   - 완료 요약 제시

---

## 출력 저장

```javascript
const paths = getProjectPaths(serviceName);
writeFile(paths.documents.prd, prdContent);
writeFile(paths.documents.apiSpec, apiSpecContent);
writeFile(paths.documents.dbSchema, dbSchemaContent);
writeFile(paths.documents.techStack, techStackContent);
```

---

## State 업데이트

```javascript
updatePhaseStatus('requirements', 'completed');
const state = readState();
state.documents = {
  ...state.documents,
  prd: paths.documents.prd,
  apiSpec: paths.documents.apiSpec,
  dbSchema: paths.documents.dbSchema,
  techStack: paths.documents.techStack
};
writeState(state);
```

---

## 검증 체크리스트

- [ ] design-analysis phase 완료 (의존성 충족)
- [ ] design-analysis.md 읽고 분석됨
- [ ] 7단계 대화 프로세스 완료 (모든 Stage 통과)
- [ ] spec-writer-decisions.md 작성 완료 (전체 의사결정 기록)
- [ ] prd.md 존재 (기능, 사용자 플로우, 비기능 요구사항, 범위 외 포함)
- [ ] api-spec.md 존재 (엔드포인트, 인증, 에러 응답, 페이지네이션 포함)
- [ ] db-schema.md 존재 (테이블, 인덱스, 관계, ER 다이어그램 포함)
- [ ] tech-stack.md 존재 (각 레이어, 버전, 선택 근거 포함)
- [ ] 교차 검증 통과:
  - [ ] PRD 기능 ↔ API 엔드포인트 완전 매핑
  - [ ] API 엔드포인트 ↔ DB 테이블 지원
  - [ ] 인증 전략 문서 간 일관성
  - [ ] 기술 스택 버전 호환성
- [ ] 사용자 최종 승인 획득
- [ ] State: `phases.requirements === "completed"`

---

## 오류 처리

| 오류 | 조치 |
|------|------|
| 의존성 미충족 | 사용자에게 `/web-autopilot:design-analysis`를 먼저 실행하도록 안내 |
| design-analysis.md 누락 | state 확인, 파일 존재 확인 |
| 대화 중단 (세션 만료 등) | spec-writer-decisions.md에서 마지막 Stage 읽어 재개 |
| 사용자가 Stage 되돌아가기 요청 | 해당 Stage부터 재실행, 하위 문서 영향 확인 |
| 교차 검증 실패 | 불일치 항목 보고, 해당 문서 수정 후 재검증 |
| 불완전한 기능 매핑 | 매핑되지 않은 요소 나열, TBD로 표시 |

---

## 참조 문서

### Reference (지식 베이스)
- `references/prd-template.md` — PRD 구조 템플릿
- `references/api-spec-format.md` — OpenAPI 규칙
- `references/auth-patterns.md` — 인증 패턴 카탈로그 (JWT/OAuth2/Session/API Key + 업계 사례)
- `references/tech-stack-options.md` — 프레임워크 비교 매트릭스 (벤치마크, 커뮤니티 지표)
- `references/api-design-principles.md` — REST API 설계 원칙 (페이지네이션, 버저닝, 에러 포맷)
- `references/db-schema-guide.md` — DB 설계 패턴 (인덱싱, 관계, 네이밍, UUID vs 정수 ID)
- `references/performance-benchmarks.md` — 서비스 유형별 성능 타겟 (Web Vitals, API 응답시간)
- `references/security-checklist.md` — 보안 체크리스트 (OWASP Top 10, 인증별 보안 요구사항)
- `references/interview-questions.md` — 확장 질문 은행 (카테고리별 질문 + 의미 설명)

### Assets (예제 & 템플릿)
- `assets/prd-example.md` — 블로그 플랫폼 PRD 예제
- `assets/api-spec-example.md` — 블로그 플랫폼 API 명세 예제
- `assets/db-schema-example.md` — 블로그 플랫폼 DB 스키마 예제
- `assets/tech-stack-example.md` — 기술 스택 문서 예제
- `assets/decision-log-template.md` — 의사결정 로그 템플릿

---

## 사용자 확인

완료 후:
```
Requirements phase complete.

Generated:
- .omc/web-projects/{service}/docs/prd.md
- .omc/web-projects/{service}/docs/api-spec.md
- .omc/web-projects/{service}/docs/db-schema.md
- .omc/web-projects/{service}/docs/tech-stack.md
- .omc/web-projects/{service}/docs/spec-writer-decisions.md (decision log)

Cross-validation: All checks passed ✅

Next: architecture

Say "continue" or run /web-autopilot:architecture
```
