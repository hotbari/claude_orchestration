---
name: pipeline
description: 전체 개발 파이프라인 실행 (Research → Architect → TDD → Review → Integrate)
argument-hint: [프로젝트명] [서비스 또는 기능 설명]
---

# /pipeline — 전체 파이프라인 오케스트레이션

5단계 파이프라인을 순차적으로 실행하여 요구사항 분석부터 Docker 배포 준비까지 자동 수행합니다.

## 인자 파싱

`$ARGUMENTS`에서 첫 번째 단어를 프로젝트명으로, 나머지를 기능 설명으로 파싱합니다.
`--palette`, `--figma` 옵션은 기능 설명에서 분리하여 별도 처리합니다.

- 예: `/pipeline bookstore_order 온라인 서점 주문 관리 API`
  - 프로젝트명: `bookstore_order`
  - 기능 설명: `온라인 서점 주문 관리 API`
- 예: `/pipeline bookstore 온라인 서점 --palette forest-green`
  - 프로젝트명: `bookstore`
  - 기능 설명: `온라인 서점`
  - 팔레트: `forest-green`
- 예: `/pipeline bookstore 온라인 서점 --figma https://figma.com/file/xxx`
  - 프로젝트명: `bookstore`
  - Figma URL: `https://figma.com/file/xxx`
- 프로젝트 경로: `projects/{프로젝트명}/`
- 최종 실행: `cd projects/{프로젝트명} && docker compose up --build`

### 옵션 인자
- `--palette [팔레트명]`: 색상 팔레트 (기본: `default-blue`). 선택 가능: `default-blue`, `forest-green`, `warm-amber`, `slate-professional`, `violet-creative`
- `--figma [URL]`: Figma 파일 URL (Figma MCP 서버 설정 시 실시간 조회, 미설정 시 `FIGMA_API_KEY` 환경변수로 REST 폴백)

## 파이프라인 구조

```
projects/{프로젝트명}/
│
Phase 1:  Research         → docs/specs/requirements.md
Phase 2:  Architect        → docs/specs/technical-spec.md, docs/api/api-spec.md
Phase 3a: Backend (TDD)  ──┐
Phase 3b: Frontend (TDD) ──┤→ 병렬 실행
                            │
Phase 4:  Review           → docs/reviews/review-report.md
Phase 5:  Integrate        → docker-compose.yml, Dockerfiles, README.md
          │
          └─ Critical 발견 시 Phase 3a/3b 재실행 (최대 2회)
```

## 지시사항

### Phase 0: 프로젝트 초기화
1. `projects/{프로젝트명}/` 디렉토리 생성
2. 하위 디렉토리 생성:
   - `docs/specs/`, `docs/api/`, `docs/reviews/`
   - `backend/src/api/`, `backend/tests/`
   - `frontend/src/`, `frontend/tests/`
3. 사용자에게 프로젝트 생성 보고

### Phase 0.5: 디자인 설정
1. 인자에서 `--palette`, `--figma` 파싱
2. `projects/{프로젝트명}/design-config.json` 생성:
   ```json
   {
     "palette": "{지정값 또는 default-blue}",
     "figmaUrl": "{지정값 또는 https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq}",
     "figmaFileKey": "{figmaUrl에서 추출 또는 mxCTZeei87Q5piZ75HINFq}",
     "layout": { "header": true, "sidebar": false, "footer": false },
     "components": [
       "Button", "Input", "Select", "Textarea", "Checkbox",
       "Card", "Table", "Form", "Tabs", "SearchInput", "FileUpload",
       "Modal", "Toast", "Badge", "Spinner", "ConfirmDialog"
     ]
   }
   ```
   유저가 `--figma` 옵션을 지정하면 해당 URL로 오버라이드.
3. **Figma MCP 연동** (`.mcp.json`에 Figma MCP 서버가 설정되어 있고 `--figma URL`이 지정된 경우):
   - Figma MCP 도구가 활성 상태인지 확인
   - `design-config.json`에 `figmaUrl`을 저장하면, Phase 3b에서 프론트엔드 에이전트가 MCP를 통해 Figma 디자인을 실시간 조회합니다
   - Phase 0.5에서는 별도의 토큰 추출 작업이 불필요합니다 (에이전트가 구현 중 직접 MCP 호출)
4. **Figma MCP 미설정 폴백** (MCP 서버가 없고 `FIGMA_API_KEY` 환경변수가 있는 경우):
   - Bash로 Figma REST API 호출:
     ```bash
     curl -s -H "X-Figma-Token: $FIGMA_API_KEY" "https://api.figma.com/v1/files/{file_key}"
     ```
   - 응답에서 디자인 토큰 추출 (색상, 타이포그래피, 간격)
   - `design-config.json`에 `figmaTokens` 필드 추가
5. Figma URL이 있으나 MCP도 토큰도 없으면:
   - 사용자에게 Figma MCP 설정 또는 `FIGMA_API_KEY` 환경변수 설정 안내 메시지 출력
   - 기본 팔레트로 진행

### Phase 1: Research
1. Task 도구로 Researcher 서브에이전트를 실행합니다:
   - `subagent_type`: "Explore", `model`: "haiku"
   - 사용자 요구사항 (기능 설명)
   - 프로젝트 경로: `projects/{프로젝트명}/`
   - 코드베이스 탐색 후 `projects/{프로젝트명}/docs/specs/requirements.md` 작성
   - `.claude/agents/researcher.md`의 절차를 따를 것
   - `.claude/skills/research/templates/requirements-template.md` 참조
2. **게이트 검증**: `projects/{프로젝트명}/docs/specs/requirements.md` 존재 확인
3. 사용자에게 Phase 1 완료 보고

### Phase 2: Architect
1. Task 도구로 Architect 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose", `model`: "sonnet"
   - 프로젝트 경로: `projects/{프로젝트명}/`
   - `requirements.md` 기반 설계
   - Docker Compose 기반 구조 반영
   - `docs/specs/technical-spec.md`, `docs/api/api-spec.md` 작성
   - `.claude/agents/architect.md`의 절차를 따를 것
2. **게이트 검증**: 두 산출물 모두 존재 확인
3. 사용자에게 Phase 2 완료 보고

### Phase 3: TDD-Develop (Backend + Frontend 병렬)

**두 서브에이전트를 병렬로 실행합니다** (Task 도구를 동시에 2개 호출):

**Task A — Phase 3a: Backend Developer**
1. Task 도구로 Backend Developer 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose"
   - 프로젝트 경로: `projects/{프로젝트명}/`
   - `technical-spec.md`, `api-spec.md` 기반 구현
   - **backend만 담당** (frontend 건드리지 않을 것)
   - TDD 사이클(Red → Green → Refactor) 엄격 준수
   - `.claude/agents/backend-developer.md`의 절차를 따를 것
   - `.claude/skills/tdd-develop/templates/test-template.md` 참조

**Task B — Phase 3b: Frontend Developer**
2. Task 도구로 Frontend Developer 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose", `model`: "sonnet"
   - 프로젝트 경로: `projects/{프로젝트명}/`
   - `technical-spec.md`, `api-spec.md` 기반 구현
   - **frontend만 담당** (backend 건드리지 않을 것)
   - TDD 사이클 준수
   - `.claude/agents/frontend-developer.md`의 절차를 따를 것
   - `.claude/skills/tdd-develop/templates/test-template.md` 참조
   - `.claude/skills/tdd-frontend/templates/design-system.md` 읽기 지시
   - `.claude/skills/tdd-frontend/templates/color-palettes.md` 읽기 지시
   - `.claude/skills/tdd-frontend/templates/component-tests.md` 참조
   - `projects/{프로젝트명}/design-config.json` 읽기 지시 (존재 시)
   - Figma MCP 도구 사용 지시: `design-config.json`에 `figmaUrl`이 있으면 MCP로 Figma 디자인을 실시간 조회하여 스타일 반영

3. **두 에이전트 모두 완료 대기**
4. **게이트 검증**:
   - `backend/tests/` + `backend/src/` 파일 존재 확인
   - `frontend/tests/` + `frontend/src/` 파일 존재 확인
   - 백엔드 테스트: `cd projects/{프로젝트명}/backend && pytest`
   - 프론트엔드 테스트: `cd projects/{프로젝트명}/frontend && npx vitest run`
5. 사용자에게 Phase 3 완료 보고 (백엔드/프론트엔드 각각 요약)

### Phase 4: Review
1. Task 도구로 Reviewer 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose", `model`: "sonnet"
   - 프로젝트 경로: `projects/{프로젝트명}/`
   - 5차원 리뷰 (스펙 준수, 보안, 성능, 테스트, 코드 품질)
   - 테스트 실행: `cd projects/{프로젝트명}/backend && pytest`
   - `docs/reviews/review-report.md` 작성
   - `.claude/agents/reviewer.md`의 절차를 따를 것
2. **게이트 검증**: `review-report.md` 존재 확인
3. **REVIEW_FAILED 확인**:
   - `REVIEW_FAILED` 마커가 있으면:
     - 재시도 횟수 확인 (최대 2회)
     - 한도 내: Phase 3a/3b부터 재실행 (Critical이 백엔드/프론트엔드 중 어디에 해당하는지에 따라 해당 에이전트만 재실행)
     - 한도 초과: 사용자에게 Critical 이슈 보고 후 중단
   - 마커가 없으면: Phase 5로 진행
4. 사용자에게 Phase 4 완료 보고

### Phase 5: Integrate
1. Task 도구로 Integrator 서브에이전트를 실행합니다:
   - `subagent_type`: "general-purpose"
   - 프로젝트 경로: `projects/{프로젝트명}/`
   - Warning/Suggestion 피드백 반영
   - Docker 환경 구성:
     - `docker-compose.yml` (api + frontend + db)
     - `Dockerfile.api`, `Dockerfile.frontend`
     - `frontend/nginx.conf` (프론트엔드 있는 경우)
   - `README.md` 생성 (docker compose 실행 가이드)
   - `.env.example` 생성
   - 최종 통합 테스트
   - `.claude/agents/integrator.md`의 절차를 따를 것
2. **게이트 검증**: `docker-compose.yml`, `README.md` 존재, 전체 테스트 통과
3. 사용자에게 파이프라인 완료 보고

## 에러 처리

- 어떤 Phase에서든 게이트 검증 실패 시 해당 Phase 재실행 (1회)
- 재실행에도 실패하면 사용자에게 상태 보고 후 중단
- 중단 시 현재까지의 산출물과 실패 원인을 명확히 보고

## 완료 보고 포맷

```
✅ 파이프라인 완료: projects/{프로젝트명}/

📋 Phase 1 (Research): 완료 — requirements.md
📐 Phase 2 (Architect): 완료 — technical-spec.md, api-spec.md
💻 Phase 3a (Backend):  완료 — N개 테스트, M개 파일
💻 Phase 3b (Frontend): 완료 — N개 테스트, M개 파일
🔍 Phase 4 (Review): 통과 — Warning N건, Suggestion M건
📦 Phase 5 (Integrate): 완료 — docker-compose.yml, README.md

🚀 실행 방법:
   cd projects/{프로젝트명}
   cp .env.example .env
   docker compose up --build

   → 백엔드: http://localhost:8000
   → 프론트엔드: http://localhost:3000
   → API 문서: http://localhost:8000/docs
```
