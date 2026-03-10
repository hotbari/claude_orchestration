---
name: web-autopilot
description: Full Figma-to-production pipeline orchestrator
version: 2.0.0
type: pipeline
---

# Web Autopilot - Full Pipeline

## 개요

Figma 디자인 → 프로덕션 웹 서비스 전체 파이프라인 자동화

**7 Phase Pipeline:**
1. **design-analysis** - Figma 분석
2. **requirements** - PRD, API/DB 명세
3. **architecture** - 시스템 아키텍처
4. **implementation** - 코드 생성 (Next.js + FastAPI)
5. **qa** - 테스트, 린트, 타입 체크
6. **deployment** - Docker 컨테이너화 및 배포
7. **completion** - 최종 검증 및 인수

---

## 실행 모드

### 자동 파이프라인 (권장)
```
/web-autopilot
```
전체 7단계 순차 실행

### 개별 Phase 실행
```
/web-autopilot:design-analysis
/web-autopilot:requirements
/web-autopilot:architecture
/web-autopilot:implementation
/web-autopilot:qa
/web-autopilot:deployment
/web-autopilot:completion
```

---

## 전제 조건

**필수:**
- Figma URL (또는 로컬 이미지)
- Service Name (예: "my-blog")

**선택:**
- tech-stack.md (커스텀 스택)
- 요구사항 (초기 기능 설명)

---

## 파이프라인 실행 프로세스

### Step 1: 초기화

서비스명 확인 + 프로젝트 구조 생성:
```
.omc/web-projects/{service}/
  ├── docs/          # 명세 문서
  ├── frontend/      # Next.js
  ├── backend/       # FastAPI
  └── state.json     # 파이프라인 상태
```


---

### Step 3: 각 Phase 요약

**Phase 1: design-analysis**
- Figma 분석
- 컴포넌트, design token, 화면 플로우 추출
- 출력: `design-analysis.md`

**Phase 2: requirements**
- 7단계 대화형 spec-writer
- 근거/대안 제시, 업계 사례 인용, 교차 검증
- 출력: `prd.md`, `api-spec.md`, `db-schema.md`, `tech-stack.md`, `spec-writer-decisions.md`

**Phase 3: architecture**
- 시스템 아키텍처 설계
- 디렉토리 구조, 컴포넌트 매핑, API 라우팅
- 출력: `architecture.md`

**Phase 4: implementation**
- Next.js + FastAPI 코드 생성
- DB 마이그레이션, API 엔드포인트, 프론트엔드 컴포넌트
- 출력: 작동하는 fullstack 앱

**Phase 5: qa**
- 빌드, 테스트, 린트, 타입 체크
- ralph-loop로 오류 해결
- 출력: 검증된 코드베이스

**Phase 6: deployment**
- Docker 환경 구성 (Dockerfile, docker-compose.yml)
- 컨테이너화 및 오케스트레이션
- `docker compose up --build -d` 실행
- 출력: 실행 중인 서비스 (PostgreSQL + Backend + Frontend)

**Phase 7: completion**
- 최종 검증 (Architect 승인)
- 배포된 서비스 확인
- 출력: 프로덕션 준비 완료


---

## 진행 상황 보고

각 phase 완료 시:
```
✓ Phase 1: design-analysis completed
  → design-analysis.md generated

✓ Phase 2: requirements completed
  → prd.md, api-spec.md, db-schema.md generated

Current phase: architecture (3/7)
```


---

## 사용자 확인

파이프라인 완료:
```
✓ All phases completed successfully!

Generated and deployed fullstack service: {service-name}
Location: .omc/web-projects/{service-name}/

🚀 Services running:
  • PostgreSQL: localhost:5432
  • Backend API: http://localhost:8000
  • API Docs: http://localhost:8000/docs
  • Frontend: http://localhost:3000

Next steps:
1. Test the deployed services
2. Review logs: docker compose logs -f
3. Monitor health: ./skills/deployment/scripts/health-check.sh

To stop: docker compose down
To restart: docker compose up -d
```

