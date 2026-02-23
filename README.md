# AI Agent 오케스트레이션 시스템

> 한 줄의 명령으로 웹서비스를 자동 생성하는 Claude Code 기반 AI 개발 파이프라인

## 이 프로젝트는 무엇인가요?

"온라인 서점 주문 관리 서비스를 만들어줘"처럼 **만들고 싶은 서비스를 설명하면**, AI가 요구사항 분석부터 코드 구현, 코드 리뷰, Docker 배포 준비까지 자동으로 수행합니다.

내부적으로는 6명의 전문 AI 에이전트가 5단계 파이프라인을 거쳐 협업하며, 사람이 직접 개발하는 것과 동일한 절차(요구사항 → 설계 → TDD 개발 → 리뷰 → 통합)를 따릅니다.

```
사용자: "문서 검색 서비스 만들어줘"
   ↓
[Phase 1] Researcher가 요구사항을 분석합니다
[Phase 2] Architect가 기술 설계를 합니다
[Phase 3] Backend/Frontend Developer가 코드를 작성합니다  ← 병렬 실행
[Phase 4] Reviewer가 코드를 검증합니다
[Phase 5] Integrator가 Docker로 패키징합니다
   ↓
docker compose up --build 한 번으로 실행 가능한 서비스 완성
```

---

## 시작하기 전에

### 필요한 것

| 항목 | 설명 |
|------|------|
| **Claude Code** | Anthropic의 CLI 도구. 이 시스템의 실행 환경입니다 |
| **Python 3.11+** | 백엔드(FastAPI) 실행용 |
| **Node.js 18+** | 프론트엔드(React) 실행용 |
| **Docker** | 최종 서비스 실행용 (Phase 5) |

### 선택 사항

| 항목 | 설명 |
|------|------|
| **Figma MCP** | Figma 디자인 파일에서 스타일을 실시간 추출할 때 사용 |
| **FIGMA_API_KEY** | Figma MCP가 없을 때 REST API 폴백용 환경변수 |

---

## 빠르게 시작하기

### 1단계: 프로젝트 클론

```bash
git clone <repository-url>
cd 0221_claude_orchestration
```

### 2단계: 전체 파이프라인 실행

Claude Code를 실행한 뒤, 다음 명령어를 입력합니다:

```
/pipeline bookstore 온라인 서점 주문 관리 서비스
```

이 한 줄이면 `projects/bookstore/` 폴더에 완성된 서비스가 생성됩니다.

### 3단계: 서비스 실행

```bash
cd projects/bookstore
cp .env.example .env
docker compose up --build
```

- 백엔드: http://localhost:8000
- 프론트엔드: http://localhost:3000
- API 문서: http://localhost:8000/docs

---

## 명령어 목록

| 명령어 | 설명 | 언제 사용하나요? |
|--------|------|------------------|
| `/pipeline [프로젝트명] [기능 설명]` | 전체 파이프라인 한 번에 실행 | 새로운 서비스를 처음부터 만들 때 |
| `/research [기능 설명]` | 요구사항 분석만 실행 | 어떤 기능이 필요한지 정리할 때 |
| `/architect` | 기술 설계만 실행 | 아키텍처와 API를 설계할 때 |
| `/tdd-develop [컴포넌트]` | 백엔드+프론트엔드 동시 개발 | 코드 구현을 시작할 때 |
| `/tdd-backend [컴포넌트]` | 백엔드만 개발 | 백엔드만 따로 작업할 때 |
| `/tdd-frontend [컴포넌트]` | 프론트엔드만 개발 | 프론트엔드만 따로 작업할 때 |
| `/review` | 코드 리뷰 실행 | 구현이 끝난 뒤 검증할 때 |
| `/integrate` | Docker 통합 및 문서화 | 리뷰 통과 후 배포 준비할 때 |
| `/status` | 현재 진행 상태 확인 | 언제든 |

### 옵션

```bash
# 색상 팔레트 지정 (기본: default-blue)
/pipeline bookstore 온라인 서점 --palette forest-green

# Figma 디자인 연동
/pipeline bookstore 온라인 서점 --figma https://figma.com/design/xxxxx

# 팔레트 + Figma 동시 지정
/pipeline bookstore 온라인 서점 --palette warm-amber --figma https://figma.com/design/xxxxx
```

사용 가능한 팔레트: `default-blue`, `forest-green`, `warm-amber`, `slate-professional`, `violet-creative`

---

## 파이프라인 상세 흐름

서비스가 만들어지는 전체 과정을 단계별로 설명합니다.

### Phase 0: 프로젝트 초기화

파이프라인이 시작되면 먼저 프로젝트 폴더 구조를 생성합니다:

```
projects/bookstore/
├── docs/
│   ├── specs/          ← 요구사항, 기술 스펙이 저장될 곳
│   ├── api/            ← API 명세가 저장될 곳
│   └── reviews/        ← 리뷰 리포트가 저장될 곳
├── backend/
│   ├── src/api/        ← 백엔드 코드가 저장될 곳
│   └── tests/          ← 백엔드 테스트가 저장될 곳
├── frontend/
│   ├── src/            ← 프론트엔드 코드가 저장될 곳
│   └── tests/          ← 프론트엔드 테스트가 저장될 곳
└── design-config.json  ← 디자인 설정 (팔레트, Figma URL 등)
```

### Phase 0.5: 디자인 설정

`design-config.json` 파일을 생성합니다. 이 파일은 프론트엔드 에이전트가 디자인을 구현할 때 참조하는 설정입니다.

```json
{
  "palette": "default-blue",
  "figmaUrl": "https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq",
  "figmaFileKey": "mxCTZeei87Q5piZ75HINFq",
  "layout": { "header": true, "sidebar": false, "footer": false },
  "components": ["Button", "Input", "Select", "Card", "Table", "Modal", "..."]
}
```

`--figma` 옵션으로 자신의 Figma 파일을 지정하면, Phase 3b에서 AI가 해당 디자인을 실시간 조회하여 정확한 스타일(색상, 간격, 크기 등)을 코드에 반영합니다.

### Phase 1: Research (요구사항 분석)

**담당 에이전트**: Researcher (haiku 모델)

사용자가 설명한 기능을 분석하고, 체계적인 요구사항 문서를 작성합니다.

- 입력: 사용자의 기능 설명 (예: "온라인 서점 주문 관리 서비스")
- 산출물: `docs/specs/requirements.md`
- 하는 일: 기능 요구사항, 비기능 요구사항, 사용자 시나리오 정리

**게이트 검증**: `requirements.md`가 존재하는지 확인한 후 다음 단계로 진행합니다.

### Phase 2: Architect (기술 설계)

**담당 에이전트**: Architect (sonnet 모델)

요구사항 문서를 기반으로 시스템 아키텍처를 설계하고 API 명세를 작성합니다.

- 입력: `docs/specs/requirements.md`
- 산출물: `docs/specs/technical-spec.md`, `docs/api/api-spec.md`
- 하는 일: 기술 스택 결정, DB 스키마 설계, API 엔드포인트 정의, 컴포넌트 구조 설계

**게이트 검증**: 두 산출물이 모두 존재하는지 확인합니다.

> **주의 — 스펙 동결**: Phase 3(구현)이 시작되면 스펙 파일은 수정할 수 없습니다. 스펙 변경이 필요하면 사용자 승인 후 Phase 2부터 재시작합니다.

### Phase 3: TDD-Develop (코드 구현)

**담당 에이전트**: Backend Developer + Frontend Developer (병렬 실행)

설계 문서를 기반으로 실제 코드를 작성합니다. 백엔드와 프론트엔드가 동시에 진행됩니다.

```
         ┌── Phase 3a: Backend Developer ──── Python + FastAPI
         │
Phase 3 ─┤                                    (병렬 실행)
         │
         └── Phase 3b: Frontend Developer ─── React + TypeScript
```

#### TDD (테스트 주도 개발) 사이클

모든 코드는 TDD 방식으로 작성됩니다:

1. **Red** — 실패하는 테스트를 먼저 작성합니다
2. **Green** — 테스트를 통과하는 최소한의 코드를 구현합니다
3. **Refactor** — 코드를 정리합니다 (테스트는 계속 통과해야 함)

테스트 없이 구현 코드를 작성하면 `tdd-guard.sh` 훅이 차단합니다.

#### 프론트엔드 디자인 시스템

프론트엔드 에이전트는 21개의 사전 정의된 UI 컴포넌트를 활용합니다:

| 카테고리 | 컴포넌트 |
|----------|----------|
| 기본 UI | Button, Input, Badge, Spinner, Card, Table, Form |
| 폼 | Select, Textarea, Checkbox, SearchInput, FileUpload |
| 내비게이션 | Tabs |
| 피드백 | Modal, Toast, ConfirmDialog |
| 레이아웃 | ContentContainer, Header, Sidebar, Footer, AppLayout |

모든 페이지는 다음 레이아웃 규격을 따릅니다:

- 최소 너비: 1440px
- 콘텐츠 영역: 1280px (ContentContainer 필수 사용)
- 헤더: 64px 고정 높이
- 사이드바: 260px

**게이트 검증**: 테스트 파일과 소스 파일이 존재하고, 테스트가 통과하는지 확인합니다.

### Phase 4: Review (코드 리뷰)

**담당 에이전트**: Reviewer (sonnet 모델)

구현된 코드를 5가지 차원에서 검증합니다:

1. **스펙 준수** — 요구사항대로 구현되었는가?
2. **보안** — SQL Injection, XSS 등 취약점이 없는가?
3. **성능** — 비효율적인 코드가 없는가?
4. **테스트** — 테스트 커버리지가 충분한가?
5. **코드 품질** — 코드 스타일 규칙을 따르는가?

- 산출물: `docs/reviews/review-report.md`
- **Critical 이슈 발견 시**: 해당 코드를 수정하기 위해 Phase 3을 재실행합니다 (최대 2회)

### Phase 5: Integrate (최종 통합)

**담당 에이전트**: Integrator

리뷰 피드백을 반영하고, 서비스를 Docker로 패키징합니다.

- 산출물:
  - `docker-compose.yml` — 전체 서비스 구성 (api + frontend + db)
  - `Dockerfile.api`, `Dockerfile.frontend` — 각 서비스 빌드 설정
  - `frontend/nginx.conf` — 프론트엔드 서빙 설정
  - `README.md` — 실행 가이드
  - `.env.example` — 환경변수 템플릿

---

## 프로젝트 구조

이 저장소는 "서비스를 만드는 시스템" 자체의 설정 파일들로 구성되어 있습니다.

```
0221_claude_orchestration/
├── CLAUDE.md                          # 프로젝트 헌법 (최상위 규칙)
├── README.md                          # 이 파일
│
├── .claude/                           # Claude Code 설정
│   ├── agents/                        # 서브에이전트 정의 (6개)
│   │   ├── researcher.md              #   요구사항 분석 전문가
│   │   ├── architect.md               #   기술 설계 전문가
│   │   ├── backend-developer.md       #   백엔드 개발자
│   │   ├── frontend-developer.md      #   프론트엔드 개발자
│   │   ├── reviewer.md                #   코드 리뷰어
│   │   └── integrator.md              #   통합 담당자
│   │
│   ├── skills/                        # 스킬 정의 (슬래시 명령어)
│   │   ├── pipeline/SKILL.md          #   /pipeline — 전체 흐름
│   │   ├── research/SKILL.md          #   /research — Phase 1
│   │   ├── architect/SKILL.md         #   /architect — Phase 2
│   │   ├── tdd-develop/SKILL.md       #   /tdd-develop — Phase 3 (병렬)
│   │   ├── tdd-backend/SKILL.md       #   /tdd-backend — Phase 3a
│   │   ├── tdd-frontend/SKILL.md      #   /tdd-frontend — Phase 3b
│   │   │   └── templates/
│   │   │       ├── design-system.md   #     UI 컴포넌트 명세 (21개)
│   │   │       ├── color-palettes.md  #     색상 팔레트 정의
│   │   │       └── component-tests.md #     컴포넌트 테스트 패턴
│   │   ├── review/SKILL.md            #   /review — Phase 4
│   │   ├── integrate/SKILL.md         #   /integrate — Phase 5
│   │   └── status/SKILL.md            #   /status — 상태 확인
│   │
│   ├── hooks/                         # 자동 실행 스크립트 (4개)
│   │   ├── tdd-guard.sh               #   TDD 규칙 강제 (테스트 없으면 구현 차단)
│   │   ├── protect-specs.sh           #   스펙 파일 보호 (Phase 3 이후 수정 차단)
│   │   ├── format-on-save.sh          #   파일 저장 시 자동 포매팅
│   │   └── phase-gate.sh              #   Phase 산출물 검증
│   │
│   └── rules/                         # 코드 규칙 (자동 적용)
│       ├── code-style.md              #   네이밍, 포매팅 규칙
│       ├── api-design.md              #   REST API 설계 규칙
│       ├── testing.md                 #   테스트 작성 규칙
│       └── security.md               #   보안 규칙
│
├── memo/                              # 참고 문서
│   ├── design-system-status.md        #   디자인 시스템 현황표
│   └── e2e-pipeline-example.md        #   파이프라인 실행 예시 시나리오
│
└── projects/                          # 생성된 프로젝트들이 저장되는 곳
    └── {프로젝트명}/                   #   /pipeline 실행 시 여기에 생성됨
```

---

## 핵심 개념 설명

### 에이전트 (Agent)

특정 역할을 맡은 AI 작업자입니다. 각 에이전트는 자신의 전문 분야만 담당하며, 허용된 도구만 사용할 수 있습니다.

| 에이전트 | 역할 | 사용 모델 | 읽기/쓰기 |
|----------|------|-----------|-----------|
| Researcher | 요구사항 분석, 도메인 조사 | haiku (빠르고 가벼움) | 읽기 전용 |
| Architect | 기술 설계, API 명세 작성 | sonnet (균형잡힌 성능) | 읽기 + 문서 작성 |
| Backend Developer | Python/FastAPI 백엔드 구현 | 상속 (호출 모델) | 읽기 + 코드 작성 |
| Frontend Developer | React/TypeScript 프론트엔드 구현 | sonnet | 읽기 + 코드 작성 |
| Reviewer | 코드 리뷰, 보안 감사 | sonnet | 읽기 전용 |
| Integrator | Docker 통합, 문서화 | 상속 (호출 모델) | 전체 도구 사용 가능 |

### 스킬 (Skill)

슬래시 명령어(`/`)로 실행하는 자동화된 작업 절차입니다. 각 스킬은 내부적으로 적절한 에이전트를 호출하고, 산출물을 검증하며, 결과를 보고합니다.

예를 들어 `/pipeline`은 Phase 0~5의 모든 스킬을 순서대로 호출하는 메타 스킬입니다.

### 훅 (Hook)

특정 이벤트가 발생할 때 자동으로 실행되는 스크립트입니다. 개발 규칙을 강제하는 안전장치 역할을 합니다.

| 훅 | 실행 시점 | 하는 일 |
|----|-----------|---------|
| `tdd-guard.sh` | 코드 파일 저장 전 | 대응하는 테스트 파일이 없으면 저장을 차단합니다 |
| `protect-specs.sh` | 스펙 파일 수정 전 | Phase 3 이후 스펙 변경을 차단합니다 |
| `format-on-save.sh` | 코드 파일 저장 후 | ruff(Python), prettier(TypeScript)로 자동 포매팅합니다 |
| `phase-gate.sh` | 작업 종료 시 | 각 Phase의 산출물이 올바르게 존재하는지 검증합니다 |

### 규칙 (Rule)

에이전트가 코드를 작성할 때 자동으로 참조하는 코딩 가이드라인입니다. `.claude/rules/` 폴더의 파일들이 자동 로드됩니다.

- **code-style.md**: Python은 snake_case, React는 camelCase 등 네이밍 규칙
- **api-design.md**: RESTful URL 설계, 에러 응답 포맷, 페이지네이션 규칙
- **testing.md**: TDD 필수, Given-When-Then 구조, 접근성 쿼리 우선 사용
- **security.md**: SQL Injection 방지, XSS 방지, JWT 인증 규칙

### 게이트 검증 (Phase Gate)

각 Phase가 끝날 때 산출물이 올바르게 생성되었는지 확인하는 검증 절차입니다. 검증을 통과하지 못하면 다음 Phase로 진행할 수 없습니다.

### TDD (Test-Driven Development, 테스트 주도 개발)

코드를 구현하기 전에 테스트를 먼저 작성하는 개발 방법론입니다. 이 시스템에서는 모든 코드가 TDD로 작성되며, `tdd-guard.sh` 훅이 이를 강제합니다.

### Figma MCP (Model Context Protocol)

Figma 디자인 파일에서 색상, 간격, 크기, 폰트 등을 실시간으로 읽어오는 연동 기능입니다. 이를 통해 디자인 파일과 코드의 시각적 결과물이 일치하도록 합니다.

---

## 기술 스택

| 영역 | 기술 |
|------|------|
| 백엔드 | Python 3.11+ / FastAPI / SQLAlchemy / Pydantic |
| 프론트엔드 | React 18+ / TypeScript / Vite / Tailwind CSS |
| 백엔드 테스트 | pytest |
| 프론트엔드 테스트 | Vitest + React Testing Library |
| 포매팅 | ruff (Python) / prettier + eslint (TypeScript) |
| 배포 | Docker Compose |

---

## 디자인 시스템

프론트엔드에서 사용하는 UI 컴포넌트의 명세가 사전 정의되어 있습니다. 에이전트는 이 명세를 참조하여 일관된 디자인의 화면을 생성합니다.

### 현황

- 완성된 컴포넌트: **21개** (Props, Tailwind 클래스, 접근성, 테스트 패턴 정의 완료)
- 미구현 컴포넌트: **15개** (필요 시 추가 가능)

### 기본 레이아웃 규격

| 항목 | 값 | 설명 |
|------|-----|------|
| 기준 해상도 | 1440px | 모든 페이지의 최소 너비 |
| 콘텐츠 영역 | 1280px | ContentContainer로 관리 |
| 헤더 높이 | 64px | sticky 고정 |
| 사이드바 너비 | 260px | 왼쪽 메뉴 영역 |
| 모서리 | rounded-xl | 카드, 섹션 통일 |
| 그림자 | shadow-sm | 과한 그림자 금지 |

### 색상 팔레트

기본 팔레트(`default-blue`)의 주요 색상:

| 토큰 | 색상 | 용도 |
|------|------|------|
| `--color-primary-500` | #137FEC | 주요 브랜드 색상 |
| `--color-foreground` | #111418 | 본문 텍스트 |
| `--color-muted` | #64748B | 보조 텍스트 |
| `--color-border` | #F3F4F6 | 테두리 |
| `--color-error` | #DC2626 | 에러 표시 |

`--palette` 옵션으로 다른 팔레트를 선택하거나, `--figma` 옵션으로 Figma에서 색상을 추출할 수 있습니다.

---

## 자주 묻는 질문

### 단계별로 실행할 수 있나요?

네. `/pipeline` 대신 각 Phase에 해당하는 명령어를 개별 실행할 수 있습니다:

```
/research bookstore 온라인 서점     ← Phase 1만 실행
/architect bookstore                ← Phase 2만 실행
/tdd-develop bookstore              ← Phase 3만 실행
/review bookstore                   ← Phase 4만 실행
/integrate bookstore                ← Phase 5만 실행
```

### 백엔드만 또는 프론트엔드만 개발할 수 있나요?

네. Phase 3을 분리 실행할 수 있습니다:

```
/tdd-backend bookstore              ← 백엔드만
/tdd-frontend bookstore             ← 프론트엔드만
```

### 코드 리뷰에서 Critical이 나오면 어떻게 되나요?

Phase 4에서 Critical 이슈가 발견되면 자동으로 Phase 3을 재실행하여 문제를 수정합니다. 최대 2회까지 재시도하며, 그래도 해결되지 않으면 사용자에게 보고합니다.

### 현재 진행 상태를 확인하려면?

```
/status
```

각 Phase의 산출물 존재 여부와 테스트 통과 여부를 한눈에 확인할 수 있습니다.

### Figma 디자인을 연동하려면?

`.mcp.json`에 Figma MCP 서버를 설정하거나 `FIGMA_API_KEY` 환경변수를 설정한 뒤, `--figma` 옵션과 함께 실행합니다:

```
/pipeline bookstore 온라인 서점 --figma https://figma.com/design/your-file-key
```

프론트엔드 에이전트가 Figma에서 색상, 간격, 크기, 폰트를 실시간으로 읽어와 코드에 반영합니다.

---

## 참고 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| 프로젝트 규칙 | `CLAUDE.md` | 전체 시스템의 최상위 규칙 |
| 디자인 시스템 현황 | `memo/design-system-status.md` | 컴포넌트 현황 및 설정 파일 목록 |
| 파이프라인 실행 예시 | `memo/e2e-pipeline-example.md` | PDF 문서 검색 서비스 구현 시나리오 |
| 디자인 시스템 명세 | `.claude/skills/tdd-frontend/templates/design-system.md` | 21개 컴포넌트 상세 스펙 |
| 컬러 팔레트 | `.claude/skills/tdd-frontend/templates/color-palettes.md` | 5가지 팔레트 정의 |
| 컴포넌트 테스트 | `.claude/skills/tdd-frontend/templates/component-tests.md` | 21개 컴포넌트 테스트 패턴 |
