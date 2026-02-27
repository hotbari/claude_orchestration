<<<<<<< HEAD
# Web Autopilot Plugin: Figma에서 웹 서비스까지 완전 자동화

> Figma 디자인부터 배포 가능한 완성된 웹 서비스까지, 6단계 자동화 파이프라인

## 목차

1. [빠른 시작](#빠른-시작) ⚡
2. [프로젝트 개요](#프로젝트-개요)
3. [핵심 개념](#핵심-개념)
4. [시스템 아키텍처](#시스템-아키텍처)
5. [기술 스택](#기술-스택)
6. [사용 방법](#사용-방법)
7. [6단계 파이프라인](#6단계-파이프라인)
8. [실제 사용 시나리오](#실제-사용-시나리오)
9. [재사용 가능한 설계 패턴](#재사용-가능한-설계-패턴)
10. [확장성 및 커스터마이징](#확장성-및-커스터마이징)
11. [개발자 가이드](#개발자-가이드)
12. [문제 해결](#문제-해결)

---

## 빠른 시작

### 1️⃣ 플러그인 설치

**글로벌 설치 (모든 프로젝트에서 사용)**
```bash
cd ~/.claude/plugins
git clone <이 저장소 URL> web-autopilot
```

**또는 프로젝트별 설치**
```bash
cd /your/project/.claude/plugins
git clone <이 저장소 URL> web-autopilot
=======
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
>>>>>>> origin/main
```

---

<<<<<<< HEAD
### 2️⃣ 플러그인 활성화

**`~/.claude/settings.json` 파일에 추가:**
```json
{
  "enabledPlugins": {
    "web-autopilot@local": true
  }
}
```

**또는 프로젝트별 설정** (`.claude/settings.local.json`):
```json
{
  "enabledPlugins": {
    "web-autopilot@local": true
  }
}
```

---

### 3️⃣ Figma MCP 서버 설정 (필수)

**`~/.claude/settings.json`에 추가:**
```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-figma"],
      "env": {
        "FIGMA_PERSONAL_ACCESS_TOKEN": "your-figma-token-here"
      }
    }
  }
}
```

**Figma 토큰 발급 방법:**
1. Figma → Settings → Account → Personal access tokens
2. "Generate new token" 클릭
3. 토큰 복사 후 위 설정에 붙여넣기

---

### 4️⃣ 첫 프로젝트 실행

**프로젝트 정보 준비:**
```bash
# project-brief.md 파일 생성
cat > project-brief.md << 'EOF'
# Project Brief

## Service Name
my-blog

## Figma URL
https://www.figma.com/design/your-figma-file-url

## Description
개인 블로그 웹 애플리케이션 (포스팅, 댓글, 좋아요 기능)
EOF
```

**파이프라인 시작:**
```bash
# Claude Code 실행
claude code

# 전체 파이프라인 실행 (6단계 자동)
/web-autopilot:web-autopilot

# 또는 단계별 실행
/web-autopilot:design-analysis    # Phase 1
/web-autopilot:requirements        # Phase 2
/web-autopilot:architecture        # Phase 3
/web-autopilot:implementation      # Phase 4
/web-autopilot:qa                  # Phase 5
/web-autopilot:completion          # Phase 6
```

**생성된 서비스 실행:**
```bash
# Frontend (Next.js)
cd .omc/web-projects/my-blog/frontend
npm install
npm run dev
# → http://localhost:3000

# Backend (FastAPI)
cd .omc/web-projects/my-blog/backend
pip install -r requirements.txt
uvicorn main:app --reload
# → http://localhost:8000/docs
```

---

### ✅ 설치 확인

```bash
# 1. Claude Code 재시작
exit

# 2. 플러그인 로드 확인 (스킬 목록에 표시됨)
/help

# 3. 테스트 실행
/web-autopilot:design-analysis --help
```

**문제 발생 시**: [문제 해결](#문제-해결) 섹션 참조

---

## 프로젝트 개요

### 목적

Web Autopilot Plugin은 **AI 기반의 완전 자동화된 웹 서비스 생성 파이프라인**입니다. 디자이너가 만든 Figma 디자인으로부터 시작하여, 단계적으로 진행하면서 최종적으로 완전히 기능하는 프로덕션 준비 웹 서비스를 생성합니다.

### 가치 제안

| 기존 프로세스 | Web Autopilot |
|-------------|---------------|
| 디자인 분석 + 요구사항 정의 + 아키텍처 설계 + 코드 작성 + 테스트 + 문서화 (수주) | **6단계 자동 파이프라인** (몇 시간) |
| 디자이너 → PM → 아키텍트 → 개발자 (여러 인력) | **AI 에이전트 자동 조율** (협업 불필요) |
| 단계별 재작업 및 조율 문제 | **State 기반 진행 관리** (명확한 체크포인트) |
| 수동 검증 및 품질 보증 | **Ralph 루프** (자동 검증-리팩토링 반복) |

### 주요 특징

✅ **완전 자동화**: Figma → 완성된 웹 서비스 (사람 개입 최소화)
✅ **단계적 제어**: 각 단계별 사용자 확인 및 피드백 반영
✅ **재사용 가능한 구조**: 모듈화된 6단계 phase 시스템
✅ **검증 기반**: Ralph 루프로 품질 보증
✅ **유연한 설정**: 기술 스택 커스터마이징, 인증 전략 선택
✅ **명확한 문서화**: 6단계 모두 생성된 프로덕션 문서 포함

---

## 핵심 개념

### 1. 6단계 파이프라인 구조

```
[1] Design Analysis  →  [2] Requirements  →  [3] Architecture
       ↓                       ↓                      ↓
   Figma 분석          요구사항 정의           시스템 설계

       ↓                       ↓                      ↓
[6] Completion  ←  [5] QA & Refactor  ←  [4] Implementation
   최종 문서             검증 루프             코드 작성
```

각 단계는:
- **독립적인 Skill**: 다시 실행 가능
- **명확한 입출력**: 문서 기반 통신
- **State 기반 진행**: 현재 상태 추적

### 2. Phase 독립 Skill 시스템

각 단계는 별도의 **Skill 파일**로 구현:

```
.claude/plugins/web-autopilot/skills/
├── design-analysis/SKILL.md      # Phase 1
├── requirements/SKILL.md          # Phase 2
├── architecture/SKILL.md          # Phase 3
├── implementation/SKILL.md        # Phase 4
├── qa/SKILL.md                   # Phase 5
└── completion/SKILL.md           # Phase 6
```

**이점:**
- 단계별 독립 재실행 가능 (특정 phase에서 실패했을 때)
- 명확한 책임 분리
- 쉬운 디버깅 및 수정

### 3. State 기반 진행 관리

```json
{
  "active": true,
  "serviceName": "todo-app",
  "currentPhase": "implementation",
  "phases": {
    "design-analysis": "completed",
    "requirements": "completed",
    "architecture": "completed",
    "implementation": "in_progress",
    "qa": "pending",
    "completion": "pending"
  }
}
```

**상태 값:**
- `pending`: 아직 시작 안 됨
- `in_progress`: 현재 실행 중
- `completed`: 성공적으로 완료
- `failed`: 오류 발생 (재시도 가능)

### 4. Agent 위임 패턴

각 단계는 **적절한 Agent**에 위임:

| Phase | Agent | 모델 |
|-------|-------|------|
| Design Analysis | vision, designer | sonnet |
| Requirements | analyst | opus |
| Architecture | architect | opus |
| Implementation (BE) | executor-high | opus |
| Implementation (FE) | designer-high | opus |
| QA | tdd-guide, qa-tester, architect | sonnet/opus |
| Completion | writer | haiku |

### 5. Progressive Disclosure (점진적 공개)

정보는 필요에 따라 점층적으로 공개:

```
SKILL.md (핵심만, ≤500줄)
  ↓ 필요하면 참조
references/ (상세 가이드)
  ↓ 실제 수행 필요
scripts/ (실행 가능한 유틸)
  ↓ 템플릿/샘플 필요
assets/ (템플릿, 예제)
```

### 6. Ralph Loop 검증 패턴

QA 단계에서 자동으로 반복:

```
테스트 실행
  ↓
테스트 통과? → 아니오 → 오류 수정
  ↓ 예
Architect 코드 검토
  ↓
승인됨? → 아니오 → 리팩토링
  ↓ 예
✅ 완료 (최대 5회 반복)
```

**철학:** "완료"를 주장하기 전에 반드시 검증 통과

---

## 시스템 아키텍처

### 프로젝트 디렉토리 구조

```
.claude/plugins/web-autopilot/
├── COMMON.md                      # 공통 규약 (모든 phase가 따르는)
├── IMPLEMENTATION_PLAN.md         # 전체 구현 계획
├── skills/
│   ├── design-analysis/
│   │   ├── SKILL.md              # Phase 1 가이드
│   │   ├── references/           # 상세 문서
│   │   ├── scripts/              # 실행 유틸
│   │   └── assets/               # 템플릿
│   ├── requirements/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   └── assets/
│   ├── architecture/
│   ├── implementation/
│   ├── qa/
│   └── completion/
└── utils/
    └── state-manager.js          # State 읽기/쓰기 유틸

.omc/
├── state/
│   └── web-autopilot-state.json   # 파이프라인 상태
└── web-projects/
    └── {service-name}/
        ├── docs/                 # 생성된 문서
        │   ├── design-analysis.md
        │   ├── prd.md
        │   ├── api-spec.md
        │   ├── db-schema.md
        │   ├── tech-stack.md
        │   └── architecture.md
        └── figma-designs/        # 다운로드된 디자인 이미지

projects/
├── {service-name}-frontend/      # Next.js 프로젝트
│   ├── components/
│   ├── app/
│   ├── lib/
│   └── package.json
└── {service-name}-backend/       # FastAPI 프로젝트
    ├── api/
    ├── models/
    ├── services/
    └── requirements.txt
```

### State 관리 흐름

```
1. Phase 시작
   ↓
2. COMMON.md + Phase SKILL.md 읽기
   ↓
3. 의존성 확인 (이전 phase 완료했나?)
   ↓
4. 작업 실행 (Agent 위임)
   ↓
5. 산출물 생성 (문서, 코드)
   ↓
6. State 업데이트 (phase → "completed")
   ↓
7. 검증 체크리스트 확인
   ↓
8. 사용자 확인 대기
```

### Agent 간 통신

**원칙:** 문서를 통해 통신, State는 메타데이터만 저장

```javascript
// Phase 1: design-analysis.md 생성
// ↓
// Phase 2: design-analysis.md 읽기
const designAnalysis = fs.readFileSync(
  '.omc/web-projects/service-name/docs/design-analysis.md'
);
```

**이점:**
- 각 Agent는 필요한 문서만 읽음
- 파이프라인 자동화 가능
- 디버깅 용이 (문서 보존)
=======
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
>>>>>>> origin/main

---

## 기술 스택

<<<<<<< HEAD
### 기본 스택 (Default)

#### Frontend

```
- Framework: Next.js 14+
- Language: TypeScript 5.0+
- Styling: Tailwind CSS 3.4+
- UI Library: shadcn/ui (Radix UI 기반)
- State Management: Zustand
- Testing: Jest + React Testing Library + Playwright
- HTTP: fetch API / axios
```

#### Backend

```
- Framework: FastAPI 0.110+
- Language: Python 3.10+
- ORM: SQLAlchemy 2.0+
- Validation: Pydantic 2.0+
- Migration: Alembic
- Testing: pytest
- Database: PostgreSQL 15+
```

#### Database

```
- PostgreSQL 15+
- Async driver: asyncpg
- Connection pooling: SQLAlchemy async
```

### 커스텀 스택

**`tech-stack.md` 파일로 기술 스택 오버라이드 가능:**

```markdown
# Tech Stack: 프로젝트명

## Frontend
- Framework: Next.js 14
- Language: TypeScript 5.0
- Styling: Tailwind CSS 3.4
- UI: shadcn/ui + custom themes

## Backend
- Framework: FastAPI 0.110
- Language: Python 3.11
- ORM: SQLAlchemy 2.0

## Database
- Type: PostgreSQL
- Version: 15
```

---

## 사용 방법

### 기본 플로우

#### 1단계: 프로젝트 초기화

```bash
# project-brief.md 파일 생성
cat > project-brief.md << 'EOF'
# Project Brief

## Service Name
todo-app

## Figma URL
https://www.figma.com/file/ABC123/Todo-App-Design

## Description
멀티 플랫폼 할 일 관리 애플리케이션
EOF
```

#### 2단계: Phase별 실행

**Phase 1: Design Analysis**
```bash
/web-autopilot:design-analysis project-brief.md
```
→ 결과 확인 (`design-analysis.md` 생성)
→ 사용자 확인: "좋아, 다음"

**Phase 2: Requirements**
```bash
/web-autopilot:requirements
```
→ 사용자 인터뷰 (인증 전략, 기능 확인)
→ 결과 확인 (`prd.md`, `api-spec.md`, `db-schema.md`)
→ 사용자 확인: "다음"

**Phase 3: Architecture**
```bash
/web-autopilot:architecture
```
→ 시스템 아키텍처 설계
→ 결과 확인 (`architecture.md`)

**Phase 4: Implementation**
```bash
/web-autopilot:implementation
```
→ Backend 구현 → Frontend 구현
→ 빌드 성공 확인

**Phase 5: QA & Refactoring**
```bash
/web-autopilot:qa
```
→ Unit 테스트 → E2E 테스트
→ 코드 검토 → Architect 승인 (자동 반복)

**Phase 6: Completion**
```bash
/web-autopilot:completion
```
→ 최종 문서 생성 (README)
→ State 정리

### Phase별 실행 방법

#### 특정 Phase만 재시도

**만약 Phase 3에서 실패했다면:**

```bash
# 오류 수정 후
/web-autopilot:architecture

# Phase 3만 재실행
# (이전 단계 생략, 자동으로 의존성 확인)
```

#### 다운스트림 Phase는 자동 리셋

**Phase 2를 재실행하면:**
```
Phase 2 (requirements) 재실행
  ↓
Phase 3 (architecture) 상태 → "pending"로 리셋
Phase 4-6 도 모두 리셋
```

**이유:** 상위 단계의 변경이 하위 단계에 영향을 줄 수 있기 때문

### 파일 경로 규약

생성되는 모든 산출물은 표준화된 경로 사용:

| 산출물 | 경로 |
|--------|------|
| State | `.omc/state/web-autopilot-state.json` |
| Design Analysis | `.omc/web-projects/{service}/docs/design-analysis.md` |
| PRD | `.omc/web-projects/{service}/docs/prd.md` |
| API Spec | `.omc/web-projects/{service}/docs/api-spec.md` |
| DB Schema | `.omc/web-projects/{service}/docs/db-schema.md` |
| Architecture | `.omc/web-projects/{service}/docs/architecture.md` |
| Frontend 코드 | `projects/{service}-frontend/` |
| Backend 코드 | `projects/{service}-backend/` |
| Figma 이미지 | `.omc/web-projects/{service}/figma-designs/` |

---

## 6단계 파이프라인

### Phase 1: Design Analysis (디자인 분석)

**목적**: Figma 디자인을 구현 사양으로 변환

**입력**:
- Figma 파일 URL
- 프로젝트 개요 (project-brief.md)

**작업**:
1. Figma MCP로 디자인 파일 가져오기
2. Vision Agent가 시각적 요소 분석
   - 레이아웃 구조
   - 컴포넌트 인벤토리
   - Design Token 추출 (색상, 타이포그래피, 간격)
3. Designer Agent가 구현 관점 분석
   - 재사용 가능한 컴포넌트 식별
   - shadcn/ui 매핑

**출력**:
- `design-analysis.md` (완전한 디자인 분석)
- `figma-designs/` (디자인 이미지들)

**성공 기준**:
- ✅ 모든 화면 분석됨
- ✅ Design token이 실제 값으로 추출됨
- ✅ 컴포넌트 목록이 포괄적
- ✅ shadcn/ui 매핑 완료

---

### Phase 2: Requirements (요구사항 정의)

**목적**: 디자인을 구체적인 기능 요구사항으로 변환

**입력**:
- `design-analysis.md` (Phase 1 결과)

**작업**:
1. Analyst Agent가 요구사항 초안 작성
2. 사용자 인터뷰 (AskUserQuestion):
   - 핵심 기능 확인
   - 인증 전략 선택 (JWT/OAuth2/Session 등)
   - 성능/확장성 요구사항
   - 외부 통합 필요 여부
3. PRD, API 명세, DB 스키마 생성

**출력**:
- `prd.md` (Product Requirements Document)
- `api-spec.md` (OpenAPI 명세)
- `db-schema.md` (데이터베이스 테이블 정의)
- `tech-stack.md` (기술 스택 확정)

**검증**:
- ✅ API 명세가 PRD의 모든 기능 포함
- ✅ DB 스키마가 API 작업 지원
- ✅ 사용자 인터뷰 완료

---

### Phase 3: Architecture (시스템 설계)

**목적**: 기술적 구현 계획 수립

**입력**:
- `prd.md`, `api-spec.md`, `db-schema.md` (Phase 2 결과)

**작업**:
1. Architect Agent가 시스템 아키텍처 설계
   - Frontend 컴포넌트 구조
   - Backend 계층화 (Clean Architecture)
   - 데이터베이스 설계
   - 인증/인가 전략
   - 오류 처리 및 검증 방식

**출력**:
- `architecture.md` (상세 설계 문서)

**설계 패턴**:

**Backend (Clean Architecture 3-Layer)**:
```
API Layer (FastAPI routes)
  ↓
Service Layer (Business Logic)
  ↓
Repository Layer (Data Access)
```

**Frontend (Bottom-up)**:
```
UI Components (shadcn/ui 기본)
  ↓
Common Components (Header, Footer, Navigation)
  ↓
Feature Components (페이지별 기능)
  ↓
Pages (App Router)
```

---

### Phase 4: Implementation (코드 구현)

**목적**: 실제 코드 작성

**입력**:
- `architecture.md`, `api-spec.md`, `db-schema.md`

**작업**:

#### 4.1 Backend 구현 (Executor-High)
1. FastAPI 프로젝트 초기화
2. SQLAlchemy 모델 구현
3. API 엔드포인트 구현
4. 비즈니스 로직 (services/)
5. 데이터 접근 (repositories/)
6. 입력 검증 (Pydantic)
7. 오류 처리
8. DB 마이그레이션 스크립트 (Alembic)

#### 4.2 Frontend 구현 (Designer-High)
1. Next.js 프로젝트 초기화
2. shadcn/ui 설정
3. Design Token 추출 및 적용
4. 컴포넌트 구현 (UI → Common → Features)
5. 페이지 구현 (App Router)
6. API 통합
7. 상태 관리 (Zustand)
8. 반응형 디자인

**출력**:
- `projects/{service}-backend/` (완전한 FastAPI 프로젝트)
- `projects/{service}-frontend/` (완전한 Next.js 프로젝트)

**검증**:
- ✅ Backend 빌드 성공 (`uvicorn 실행`)
- ✅ Frontend 빌드 성공 (`next build`)
- ✅ 타입 체크 통과

---

### Phase 5: QA & Refactoring (품질 보증)

**목적**: 품질 검증 및 최적화

**입력**:
- 구현된 Frontend 및 Backend 코드

**작업**:

#### 5.1 Unit Testing
- Backend: pytest
- Frontend: Jest + React Testing Library

#### 5.2 E2E Testing
- Playwright로 사용자 플로우 테스트

#### 5.3 Build & Type Check
```bash
# Backend
mypy app/
uvicorn app:app --reload

# Frontend
tsc --noEmit
next build
```

#### 5.4 Code Review
- Architect가 코드 품질 검토
- 아키텍처 준수 여부 확인
- 보안 취약점 확인

#### 5.5 Refactoring
- Architect 피드백 반영
- 코드 개선

#### 5.6 Ralph Loop 반복
```
테스트 실행
  ↓
통과? → 아니오 → 수정 → 다시 테스트
  ↓ 예
Architect 검토
  ↓
승인? → 아니오 → 리팩토링 → 다시 테스트
  ↓ 예
✅ 완료 (최대 5회 반복)
```

**성공 기준**:
- ✅ 모든 unit 테스트 통과
- ✅ 모든 E2E 테스트 통과
- ✅ 빌드 성공 (에러 없음)
- ✅ Architect 승인 획득
- ✅ 보안 검토 통과
- ✅ 서비스 실행 확인

---

### Phase 6: Completion (최종 완성)

**목적**: 문서화 및 배포 준비

**입력**:
- 검증된 코드
- 모든 생성된 문서

**작업**:
1. Writer Agent가 README 작성
   - 프로젝트 개요
   - 설치 방법
   - 실행 방법
   - API 문서 링크
2. 환경 변수 가이드 (.env.example)
3. State 파일 정리 (삭제)

**출력**:
- `projects/{service}-frontend/README.md`
- `projects/{service}-backend/README.md`
- `.env.example` 파일들

**완료 체크리스트**:
- ✅ README 작성 완료
- ✅ 설치/실행 가이드 명확
- ✅ 환경 변수 설정 가이드
- ✅ State 파일 정리 완료
- ✅ 모든 단계 검증 완료

---

## 실제 사용 시나리오

### 시나리오 1: 새 프로젝트 시작

```bash
# 1. project-brief.md 작성
cat > project-brief.md << 'EOF'
# Project Brief

## Service Name
weather-app

## Figma URL
https://www.figma.com/file/XYZ789/Weather-App-Design

## Description
날씨 정보 조회 및 공유 웹 애플리케이션
EOF

# 2. Phase 1 실행
/web-autopilot:design-analysis project-brief.md

# 결과 확인
cat .omc/web-projects/weather-app/docs/design-analysis.md

# 3. Phase 2-6 순차 진행
/web-autopilot:requirements
# → 사용자 인터뷰 진행
# → prd.md, api-spec.md, db-schema.md 생성

/web-autopilot:architecture
# → architecture.md 생성

/web-autopilot:implementation
# → projects/weather-app-backend/ 생성
# → projects/weather-app-frontend/ 생성

/web-autopilot:qa
# → 테스트 실행, 자동 반복 (Ralph Loop)

/web-autopilot:completion
# → README 작성
# → 최종 완료
```

### 시나리오 2: Phase 중간에 실패

```bash
# Phase 4 (Implementation)에서 실패

# 1. 오류 분석
cat projects/weather-app-backend/logs/errors.json

# 2. 문제 해결 (수동 또는 AI 지원)
# ...

# 3. Phase 4 재실행
/web-autopilot:implementation

# Phase 5-6은 자동으로 진행
```

### 시나리오 3: 요구사항 변경

```bash
# Phase 2 (Requirements)에서 새로운 기능 추가

# 1. 재실행
/web-autopilot:requirements

# 2. 자동으로 리셋되는 단계들
# Phase 3 (Architecture) → pending
# Phase 4 (Implementation) → pending
# Phase 5 (QA) → pending
# Phase 6 (Completion) → pending

# 3. Phase 3부터 다시 시작
/web-autopilot:architecture
# ... (계속)
```

### 시나리오 4: 기술 스택 커스터마이징

```bash
# Phase 1 전에 커스텀 스택 정의
cat > tech-stack.md << 'EOF'
# Tech Stack

## Frontend
- Framework: Remix 2.0 (Next.js 대신)
- UI: Shadcn/ui
- Styling: Tailwind CSS 4.0

## Backend
- Framework: Django 5.0 (FastAPI 대신)
- ORM: Django ORM
- Database: PostgreSQL 16

## Deployment
- Frontend: Vercel
- Backend: AWS Lambda
EOF

# Phase 1 실행
/web-autopilot:design-analysis project-brief.md

# Phase 2에서 커스텀 스택 인식 및 적용
/web-autopilot:requirements
```

---

## 재사용 가능한 설계 패턴

### 패턴 1: 모듈화된 Phase 시스템

**문제**: 대규모 파이프라인에서 특정 단계 재실행이 어려움

**해결책**: 각 Phase를 독립적 Skill로 분리

```javascript
// 각 phase는 완전히 독립적
/web-autopilot:design-analysis
/web-autopilot:requirements    // 이전 단계 완료 필요
/web-autopilot:architecture    // 이전 단계 완료 필요
/web-autopilot:implementation
/web-autopilot:qa
/web-autopilot:completion
```

**재사용 가능성**:
- ✅ 다른 프로젝트에서 동일한 phase 구조 사용
- ✅ 특정 phase만 추가/제거 가능
- ✅ Phase 간 의존성 명확

### 패턴 2: State 기반 진행 관리

**문제**: 장시간 실행되는 파이프라인에서 상태 추적이 어려움

**해결책**: 중앙화된 JSON state 파일로 모든 progress 기록

```json
{
  "serviceName": "app-name",
  "phases": {
    "design-analysis": "completed",
    "requirements": "in_progress"
  }
}
```

**이점**:
- ✅ Resume 가능 (중단했다가 재시작)
- ✅ 실패 시 복구 가능
- ✅ 다중 프로젝트 관리 가능
- ✅ 진행 상황 시각화 가능

### 패턴 3: Agent 위임 패턴

**문제**: 다양한 종류의 작업을 단순 순차 처리로 인한 느린 속도

**해결책**: 작업 유형별 최적 Agent에 위임

```javascript
Task({
  subagent_type: "oh-my-claudecode:vision",
  model: "sonnet",
  prompt: "시각적 분석"
})

Task({
  subagent_type: "oh-my-claudecode:executor-high",
  model: "opus",
  prompt: "복잡한 구현"
})

Task({
  subagent_type: "oh-my-claudecode:writer",
  model: "haiku",
  prompt: "문서 작성"
})
```

**재사용**:
- ✅ 각 phase마다 최적 agent 선택
- ✅ 병렬 실행 가능 (독립적 작업)
- ✅ 실패 시 해당 agent만 재실행

### 패턴 4: Progressive Disclosure (점진적 공개)

**문제**: 초보 사용자에게 너무 많은 정보 제공

**해결책**: 필요에 따라 정보 공개

```
SKILL.md (필수, ≤500줄)
└── references/ (선택적 상세 문서)
└── scripts/ (실행 코드)
└── assets/ (템플릿, 예제)
```

**이점**:
- ✅ 초보자: SKILL.md만으로 충분
- ✅ 숙련자: 필요시 references/ 참조
- ✅ 개발자: scripts/ 및 assets/ 활용
- ✅ 문서 복잡도 관리

### 패턴 5: Ralph Loop 검증 패턴

**문제**: 코드 품질 보증이 어려움 (일회성 검증 한계)

**해결책**: 테스트-리뷰-리팩토링 자동 반복

```
실행 → 테스트 → 검토 → 리팩토링 → (다시 실행)
         ↑________________________↓
         (최대 5회 반복, Architect 승인까지)
```

**이점**:
- ✅ 품질 보증 자동화
- ✅ 일관된 코드 스타일
- ✅ 서서히 개선되는 코드
- ✅ 개발자 개입 최소화

### 패턴 6: Document-Driven Communication

**문제**: Agent 간 복잡한 정보 전달

**해결책**: 마크다운 문서를 통한 통신

```javascript
// Phase 1 결과
.omc/web-projects/service-name/docs/design-analysis.md

// Phase 2가 읽음
const analysis = fs.readFileSync('design-analysis.md', 'utf8');

// Phase 2 결과
.omc/web-projects/service-name/docs/prd.md
.omc/web-projects/service-name/docs/api-spec.md

// Phase 3이 읽음
const prd = fs.readFileSync('prd.md', 'utf8');
const apiSpec = fs.readFileSync('api-spec.md', 'utf8');
```

**이점**:
- ✅ 모든 정보 추적 가능
- ✅ Versioning 용이
- ✅ 손상 방지 (읽기 전용)
- ✅ 자동 다중 프로젝트 관리 가능

---

## 확장성 및 커스터마이징

### 새로운 Phase 추가

**예: Phase 7 - Deployment**

```markdown
# .claude/plugins/web-autopilot/skills/deployment/SKILL.md

---
name: deployment
description: Deployment phase - Docker, CI/CD, hosting setup
version: 1.0.0
depends_on: completion
---

# Deployment Phase

## 개요
Phase 6 완료 후 실제 배포를 자동화합니다.

## 입력
- 프로덕션 준비 코드
- 환경 설정 파일

## 작업
1. Docker 이미지 생성
2. CI/CD 파이프라인 구성 (GitHub Actions)
3. 클라우드 배포 (Vercel, AWS, etc.)

## 출력
- Dockerfile, docker-compose.yml
- .github/workflows/*.yml
```

**Phase 의존성 업데이트 (COMMON.md)**:
```javascript
const PHASE_DEPENDENCIES = {
  'design-analysis': null,
  'requirements': 'design-analysis',
  'architecture': 'requirements',
  'implementation': 'architecture',
  'qa': 'implementation',
  'completion': 'qa',
  'deployment': 'completion'  // 추가
};
```

### 기술 스택 변경

**예: Django + React로 변경**

```markdown
# tech-stack.md

## Frontend
- Framework: React 18
- Build tool: Vite
- Styling: Tailwind CSS
- UI: shadcn/ui (React version)

## Backend
- Framework: Django 5.0
- ORM: Django ORM
- Task queue: Celery
```

**Phase 별 영향**:
- Phase 3 (Architecture): 다른 설계 패턴
- Phase 4 (Implementation): Django/React 사용
- Phase 5 (QA): pytest + Vitest

### Agent 재정의

기본 Agent 대신 커스텀 Agent 사용:

```javascript
Task({
  subagent_type: "oh-my-claudecode:custom-backend-expert",
  model: "opus",
  prompt: "구현..."
})
```

### 성능 최적화

**병렬 실행 예**: 동일 Phase 내 독립적 작업

```javascript
// Phase 4: 백엔드와 프론트엔드 동시 구현
Task({ subagent_type: "executor-high", ... });    // Backend
Task({ subagent_type: "designer-high", ... });    // Frontend
// 병렬 실행 가능
```

---

## 개발자 가이드

### 프로젝트 구조 상세 설명

#### 1. COMMON.md (공통 규약)

모든 Phase가 따르는 표준:
- State 읽기/쓰기 프로토콜
- 파일 경로 규칙
- Agent 호출 형식
- Phase 의존성 정의
- 오류 처리 방식
- 검증 표준

**수정 가이드:**
```markdown
변경 사항 발생 시:
1. COMMON.md 업데이트
2. 모든 SKILL.md가 새 규칙 따르는지 확인
3. 이전 phase들도 호환성 검증
```

#### 2. Phase SKILL.md 작성 원칙

**구조:**
```yaml
---
name: phase-name
description: 짧은 설명
depends_on: 이전-phase
---

# Phase Name

## 개요
## 전제 조건
## 입력/출력
## Agents
## 단계별 프로세스
## 검증 체크리스트
## 오류 처리
```

**작성 가이드:**
1. 500줄 이하 유지 (간결함)
2. 구체적인 예제 포함
3. Agent 위임 형식 명시
4. 검증 기준 명확
5. references/ 링크 제공

#### 3. State 파일 구조

```json
{
  "active": true,
  "serviceName": "string",
  "currentPhase": "string",
  "phases": {
    "phase-name": "pending|in_progress|completed|failed"
  },
  "documents": {
    "designAnalysis": "path",
    "prd": "path",
    ...
  },
  "ralphLoop": {
    "iterationCount": 0,
    "maxIterations": 5,
    "lastReviewResult": "pending|approved|rejected"
  }
}
```

**수정 규칙:**
- ✅ 해당 phase가 아닌 곳에서 수정 금지
- ✅ Phase 내에서만 자신의 상태 변경
- ✅ 하위 phase는 상위 phase 상태 변경 금지

### 주요 파일 역할

| 파일 | 역할 | 수정 시기 |
|------|------|---------|
| COMMON.md | 공유 규약 | 규칙 변경 시 |
| skills/*/SKILL.md | Phase 가이드 | 작업 방식 변경 시 |
| utils/state-manager.js | State 유틸 | API 변경 시 |
| .omc/state/*.json | 진행 상태 | 자동으로 관리 |
| .omc/web-projects/*/docs/ | 산출물 | 각 Phase가 생성 |

### 개발 시 주의사항

#### 1. Phase 의존성 체크

```javascript
// 항상 실행
const state = readState();
if (state.phases['previous-phase'] !== 'completed') {
  throw new Error(`Previous phase not completed`);
}
```

#### 2. 원자적 작업

한 번에 하나의 Phase만 실행:
```bash
# ✅ 정상
/web-autopilot:requirements

# ❌ 금지 (동시 실행)
/web-autopilot:requirements
/web-autopilot:architecture
```

#### 3. 문서 콘텐츠 충실도

Figma 텍스트는 절대 변경 금지:
```markdown
# ✅ 정상: Figma에서 복사
Button: "전송"

# ❌ 금지: 의역/번역
Button: "Submit" (Figma는 한글)
```

#### 4. 오류 로깅

모든 오류는 state에 기록:
```javascript
try {
  // 작업
} catch (error) {
  updatePhaseError('phase-name', error);
  throw error;
}
```

---

## 문제 해결

### 일반적인 오류 및 해결 방법

#### 1. State 파일을 찾을 수 없음

**오류**:
```
Error: State file not found: .omc/state/web-autopilot-state.json
```

**원인**: Phase 1을 실행하지 않음

**해결**:
```bash
/web-autopilot:design-analysis project-brief.md
```

#### 2. Phase 의존성 미충족

**오류**:
```
Error: design-analysis must complete first (current status: pending)
```

**원인**: 이전 단계를 완료하지 않음

**해결**:
```bash
# 이전 단계 확인
cat .omc/state/web-autopilot-state.json | jq .phases

# 누락된 단계 실행
/web-autopilot:design-analysis project-brief.md
```

#### 3. Figma URL 유효하지 않음

**오류**:
```
Error: Invalid Figma URL format
```

**원인**: 잘못된 URL 형식

**해결**:
```bash
# 올바른 형식
https://www.figma.com/file/{fileId}/...

# project-brief.md 수정
```

#### 4. MCP 도구를 사용할 수 없음

**오류**:
```
Error: MCP tool mcp__figma__get_file not found
```

**원인**: Figma MCP 구성 안 됨

**해결**:
```bash
# MCP 설정
/oh-my-claudecode:mcp-setup

# 또는 수동으로 Figma 디자인 내보내기
# .omc/web-projects/{service}/figma-designs/ 에 업로드
```

#### 5. 빌드 실패

**오류** (Backend):
```
ModuleNotFoundError: No module named 'sqlalchemy'
```

**원인**: 의존성 미설치

**해결**:
```bash
cd projects/{service}-backend
pip install -r requirements.txt
```

**오류** (Frontend):
```
error TS2307: Cannot find module 'shadcn/ui'
```

**원인**: 컴포넌트 미설치

**해결**:
```bash
cd projects/{service}-frontend
npm install
npx shadcn-ui@latest init
```

#### 6. Ralph Loop 최대 반복 도달

**오류**:
```
Error: Ralph loop reached max iterations (5). Manual intervention required.
```

**원인**: 5회 반복 후에도 Architect 승인 미획득

**해결**:
1. Architect 피드백 검토
2. 주요 오류 식별
3. 수동 수정 후 재실행
```bash
/web-autopilot:qa
```

#### 7. 파일 경로 오류

**오류**:
```
Error: File not found: .omc/web-projects/service-name/docs/prd.md
```

**원인**: Service name 불일치

**해결**:
```javascript
// 현재 service name 확인
const state = readState();
console.log(state.serviceName);

// 맞는 경로 사용
```

### 디버깅 팁

#### 1. State 파일 확인

```bash
# Phase 상태 확인
cat .omc/state/web-autopilot-state.json | jq .phases

# 특정 document 경로 확인
cat .omc/state/web-autopilot-state.json | jq .documents
```

#### 2. 로그 파일 확인

```bash
# Phase별 오류 로그
cat .omc/web-projects/{service}/logs/{phase}-errors.json

# Build 로그
cd projects/{service}-backend
uvicorn app:app --reload 2>&1 | tee app.log
```

#### 3. 문서 검증

```bash
# design-analysis.md 섹션 확인
grep -E "^## |^### " .omc/web-projects/{service}/docs/design-analysis.md

# API spec 엔드포인트 수 확인
grep -c "^### " .omc/web-projects/{service}/docs/api-spec.md
```

#### 4. 의존성 버전 확인

```bash
# Backend
pip list | grep -E "fastapi|sqlalchemy|pydantic"

# Frontend
npm list next typescript tailwindcss
```

### FAQ

**Q: Phase를 다시 실행할 수 있나요?**
```
A: 네, 언제든 /web-autopilot:{phase-name} 으로 재실행 가능합니다.
   단, 의존성을 먼저 완료해야 합니다.
```

**Q: 여러 프로젝트를 동시에 진행할 수 있나요?**
```
A: 네, 하지만 State는 하나만 유지되므로,
   마지막 프로젝트의 상태로 덮어씌워집니다.
   여러 프로젝트 관리를 위해 State를 여러 개로 분리할 계획입니다.
```

**Q: 생성된 코드의 라이선스는?**
```
A: 사용하는 기술의 라이선스를 따릅니다.
   - Next.js: MIT
   - FastAPI: MIT
   - shadcn/ui: MIT
   - PostgreSQL: PostgreSQL License
```

**Q: 커스텀 컴포넌트를 추가할 수 있나요?**
```
A: 네, Phase 4 완료 후 수동으로 추가할 수 있습니다.
   또는 design-analysis.md에 사전 정의하고 재실행할 수 있습니다.
```

**Q: API 문서는 자동 생성되나요?**
```
A: api-spec.md로 제공되며, FastAPI는 자동으로 OpenAPI
   문서를 생성합니다 (/docs 엔드포인트).
```

---

## 마무리

Web Autopilot Plugin은 **재사용 가능한 설계**와 **자동화 철학**을 바탕으로 만들어졌습니다.

### 핵심 철학

1. **모듈화**: 각 phase는 독립적, 재사용 가능
2. **투명성**: State로 모든 진행 상황 추적
3. **신뢰성**: Ralph Loop로 품질 보증
4. **유연성**: 기술 스택 커스터마이징 가능
5. **사용 편의성**: 최소 개입으로 최대 자동화

### 다음 단계

- 실제 Figma 디자인으로 첫 프로젝트 테스트
- Phase별 문제 피드백
- 추가 기능 요청 (배포 자동화, 모니터링 등)

---

**프로젝트명**: Web Autopilot Plugin
**버전**: 1.0.0
**마지막 업데이트**: 2026-02-27
=======
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
>>>>>>> origin/main
