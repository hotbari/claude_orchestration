---
name: requirements
description: Interactive spec-writer agent - consultant-grade requirements gathering through 7-stage dialogue
version: 2.0.0
phase: 2
depends_on: design-analysis
---

# Requirements Phase — Spec-Writer Agent

## 개요

디자인 분석 결과를 기반으로 사용자와 7단계 대화를 통해 4개 명세 문서(PRD, API, DB, Tech Stack)를 완성합니다.

**핵심 책임:**
- 디자인 → PRD 초안 자동 생성 (design-to-spec-analyst)
- 7단계 대화로 명세 고도화 (analyst)
- 4개 문서 간 교차 검증

---

## 전제 조건 & 입출력

**State 의존성:** `phases.design-analysis === "completed"`

**필수 입력:** design-analysis.md
**선택 입력:** tech-stack.md (커스텀)

**출력:**
- prd.md, api-spec.md, db-schema.md, tech-stack.md
- spec-writer-decisions.md (의사결정 로그)

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| design-to-spec-analyst | opus | 디자인 → PRD 초안 자동 변환 |
| analyst | opus | 7단계 대화로 명세 고도화 |

---

## 7단계 대화 프로세스

### Step 0: 초기화

1. state 검증: `phases.design-analysis === "completed"` 확인
2. spec-writer-decisions.md 존재하면 재개, 없으면 Stage 1부터

---

### Stage 0.5: PRD 초안 생성

**실행:** design-to-spec-analyst (opus)

**위임 프롬프트:**
```
Read design-analysis.md and generate:
1. prd-draft.md - features, user stories
2. api-draft.md - endpoints, schemas
3. db-draft.md - tables, relationships

Agent autonomously decides: API patterns, DB normalization, auth strategy
See agents/design-to-spec-analyst.md for full role.
```

**산출:** prd-draft.md, api-draft.md, db-draft.md

---

### Stage 1: 프로젝트 이해

**실행:** analyst (opus)

1. 초안 문서 검토 (prd/api/db-draft.md)
2. 프로젝트 요약 제시 (화면 수, 주요 기능, 유사 서비스)
3. 범위 이슈 선제 식별
4. **AskUserQuestion:** 범위/비즈니스 모델/타겟 사용자/제약사항

**산출:** spec-writer-decisions.md Stage 1


---

### Stage 2: 기술 스택 결정

**실행:** analyst (opus)

1. 기존 tech-stack.md 확인 → 있으면 검증 후 사용자 확인
2. 없으면: 각 레이어별 2-3개 옵션 + 벤치마크 제시
3. 장기 영향 설명
4. **AskUserQuestion:** 추천 스택 확인/변경

**산출:** tech-stack.md


---

### Stage 3: 데이터 모델링

**실행:** analyst (opus)

1. db-draft.md 검토 및 개선
2. ER 다이어그램 작성 (텍스트)
3. 테이블 상세 설계 (컬럼/인덱스/FK)
4. 주요 결정점 근거 제시 (UUID vs auto-inc, Soft vs Hard delete)
5. N+1 쿼리 위험 플래그
6. **AskUserQuestion:** 스키마 리뷰

**산출:** db-schema.md


---

### Stage 4: 최종 리뷰 & 승인

**실행:** analyst (opus)

1. **전체 요약:** 서비스 유형, 기술 스택, MVP 기능 수, API/DB 개수
2. **교차 검증:**
   - PRD ↔ API 완전 매핑
   - API ↔ DB 지원 확인
   - 인증 전략 일관성
   - 기술 스택 버전 호환성
3. **4개 문서 제시 + 요약**
4. **AskUserQuestion:** 승인/수정/특정 Stage 되돌아가기
5. 수정 시: 문서 업데이트 → 영향 전파 → 재검증
6. 승인 시: 최종 저장 + State 업데이트


---

## 참조

**References:** prd-template.md, api-spec-format.md, auth-patterns.md, tech-stack-options.md, api-design-principles.md, db-schema-guide.md, performance-benchmarks.md, security-checklist.md, interview-questions.md

**Assets:** prd-example.md, api-spec-example.md, db-schema-example.md, tech-stack-example.md, decision-log-template.md

**Agents:** design-to-spec-analyst.md

