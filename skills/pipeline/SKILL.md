---
name: web-autopilot
description: Full Figma-to-production pipeline orchestrator
version: 1.0.0
type: pipeline
---

# Web Autopilot - Full Pipeline

## 개요

Figma 디자인에서 프로덕션 준비 완료 웹 서비스까지 전체 파이프라인을 자동화합니다.

**6 Phase Pipeline:**
1. **design-analysis** - Figma 분석
2. **requirements** - PRD, API/DB 명세 생성
3. **architecture** - 시스템 아키텍처 설계
4. **implementation** - 코드 생성 (Next.js + FastAPI)
5. **qa** - 테스트, 린트, 타입 체크
6. **completion** - 최종 검증 및 배포 준비

---

## 실행 모드

### 자동 파이프라인 (권장)
```
/web-autopilot
```
또는
```
/web-autopilot:web-autopilot
```

전체 6단계를 순차적으로 실행합니다.

### 개별 Phase 실행
```
/web-autopilot:design-analysis
/web-autopilot:requirements
/web-autopilot:architecture
/web-autopilot:implementation
/web-autopilot:qa
/web-autopilot:completion
```

---

## 전제 조건

### 필수 입력
| 입력 | 설명 |
|------|------|
| Figma URL | 디자인 파일 링크 (또는 로컬 이미지) |
| Service Name | 프로젝트 이름 (예: "my-blog", "admin-dashboard") |

### 선택적 입력
| 입력 | 설명 |
|------|------|
| tech-stack.md | 커스텀 기술 스택 (없으면 기본값 사용) |
| 요구사항 | 초기 기능 설명 (없으면 인터뷰로 수집) |

---

## 파이프라인 실행 프로세스

### Step 1: 초기화

서비스 이름 확인 및 프로젝트 디렉토리 구조 생성:
```
.omc/web-projects/{service-name}/
  ├── docs/          # 명세 문서
  ├── frontend/      # Next.js 코드
  ├── backend/       # FastAPI 코드
  └── state.json     # 파이프라인 상태
```

### Step 2: Phase 실행

각 phase를 순차적으로 실행하며, 이전 phase 완료를 확인합니다:

```javascript
const phases = [
  'design-analysis',
  'requirements',
  'architecture',
  'implementation',
  'qa',
  'completion'
];

for (const phase of phases) {
  const state = readState(serviceName);

  // 이전 phase 완료 확인
  if (phaseIndex > 0) {
    const prevPhase = phases[phaseIndex - 1];
    if (state.phases[prevPhase] !== 'completed') {
      throw Error(`${prevPhase} must complete first`);
    }
  }

  // Phase 실행
  await executePhase(phase, serviceName);

  // 완료 검증
  verifyPhaseCompletion(phase, serviceName);
}
```

### Step 3: 각 Phase 요약

#### Phase 1: design-analysis
- Figma 디자인 분석
- 컴포넌트, design token, 화면 플로우 추출
- 출력: `design-analysis.md`

#### Phase 2: requirements
- 사용자 인터뷰로 요구사항 수집
- PRD, API 명세, DB 스키마 생성
- 출력: `prd.md`, `api-spec.md`, `db-schema.md`, `tech-stack.md`

#### Phase 3: architecture
- 시스템 아키텍처 설계
- 디렉토리 구조, 컴포넌트 매핑, API 라우팅
- 출력: `architecture.md`

#### Phase 4: implementation
- Next.js + FastAPI 코드 생성
- DB 마이그레이션, API 엔드포인트, 프론트엔드 컴포넌트
- 출력: 작동하는 fullstack 앱

#### Phase 5: qa
- 빌드, 테스트, 린트, 타입 체크
- ralph-loop로 모든 오류 해결
- 출력: 검증된 코드베이스

#### Phase 6: completion
- 최종 검증 (Architect 승인)
- 배포 준비 확인
- 출력: 프로덕션 준비 완료 서비스

---

## 오류 처리

| 오류 | 조치 |
|------|------|
| Figma URL 없음 | 사용자에게 요청 |
| Phase 의존성 실패 | 이전 phase 재실행 |
| 검증 실패 | 해당 phase 재시도 또는 수동 개입 |
| 타임아웃 | 진행 상황 저장, 재개 가능하도록 상태 유지 |

---

## State 관리

### State 파일 위치
```
.omc/web-projects/{service-name}/state.json
```

### State 구조
```json
{
  "serviceName": "my-service",
  "currentPhase": "requirements",
  "phases": {
    "design-analysis": "completed",
    "requirements": "in-progress",
    "architecture": "pending",
    "implementation": "pending",
    "qa": "pending",
    "completion": "pending"
  },
  "documents": {
    "designAnalysis": ".omc/web-projects/my-service/docs/design-analysis.md",
    "prd": ".omc/web-projects/my-service/docs/prd.md",
    ...
  },
  "startedAt": "2024-02-27T10:00:00Z",
  "updatedAt": "2024-02-27T10:30:00Z"
}
```

---

## 진행 상황 보고

각 phase 완료 시:
```
✓ Phase 1: design-analysis completed
  → design-analysis.md generated

✓ Phase 2: requirements completed
  → prd.md, api-spec.md, db-schema.md generated

Current phase: architecture (3/6)
```

---

## 사용자 확인

파이프라인 완료 시:
```
✓ All phases completed successfully!

Generated fullstack service: {service-name}

Location: .omc/web-projects/{service-name}/

Next steps:
1. Review generated code
2. Run: cd frontend && npm install && npm run dev
3. Run: cd backend && pip install -r requirements.txt && uvicorn main:app --reload
4. Open: http://localhost:3000

Say "deploy" for deployment instructions.
```

---

## 참조

- Individual phase skills: `skills/{phase}/SKILL.md`
- Pipeline state management: `.omc/web-projects/README.md`
- Troubleshooting: `docs/troubleshooting.md`
