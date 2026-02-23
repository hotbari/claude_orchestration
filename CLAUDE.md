# Web Service Development AI Agent Orchestration System

> 이 프로젝트는 5-Phase AI Agent 파이프라인을 통해 웹서비스를 체계적으로 구현합니다.

## Quick Commands

| 명령어 | 설명 | 사용 시점 |
|--------|------|-----------|
| `/pipeline [기능 설명]` | 전체 파이프라인 실행 (Phase 1~5) | 새 기능 개발 시작 |
| `/research [기능 설명]` | 요구사항 분석 및 탐색 | Phase 1 단독 실행 |
| `/architect` | 기술 설계 및 API 명세 | Phase 2 단독 실행 |
| `/tdd-develop [컴포넌트]` | TDD 방식 구현 | Phase 3 단독 실행 |
| `/review` | 코드 리뷰 및 보안 감사 | Phase 4 단독 실행 |
| `/integrate` | 최종 통합 및 문서화 | Phase 5 단독 실행 |
| `/status` | 현재 진행 상태 확인 | 언제든 |

## 파이프라인 구조

```
Phase 1: Research    → docs/specs/requirements.md
Phase 2: Architect   → docs/specs/technical-spec.md, docs/api/api-spec.md
Phase 3: TDD-Develop → tests/**, src/**
Phase 4: Review      → docs/reviews/review-report.md
Phase 5: Integrate   → README 업데이트, 배포 준비
```

## 프로젝트 디렉토리 구조

```
project-root/
├── CLAUDE.md                  # 이 파일 (프로젝트 헌법)
├── .claude/                   # Claude Code 설정
│   ├── agents/                # 서브에이전트 정의
│   ├── skills/                # 스킬 정의
│   ├── rules/                 # 자동 로드 규칙
│   └── hooks/                 # Hook 스크립트
├── docs/                      # 산출물
│   ├── specs/                 # 요구사항, 기술 스펙
│   ├── api/                   # API 명세
│   └── reviews/               # 리뷰 리포트
├── src/                       # 소스 코드
│   ├── api/                   # FastAPI 백엔드
│   └── frontend/              # React 프론트엔드
└── tests/                     # 테스트 코드
    ├── api/                   # 백엔드 테스트
    └── frontend/              # 프론트엔드 테스트
```

## 핵심 규칙

### 1. TDD 필수
- `src/` 내 모든 구현 코드는 대응하는 테스트가 `tests/`에 먼저 존재해야 합니다.
- 테스트 → 구현 → 리팩토링 (Red-Green-Refactor) 사이클을 엄격히 따릅니다.
- 예외: 설정 파일(`config.*`), 타입 정의(`types.*`, `schemas.*`), `__init__.py`, `index.*`

### 2. 스펙 동결
- Phase 3(구현) 시작 이후 `docs/specs/`와 `docs/api/` 파일은 수정할 수 없습니다.
- 스펙 변경이 필요한 경우 사용자 승인 후 Phase 2부터 재시작합니다.

### 3. 산출물 필수
- 각 Phase는 반드시 지정된 산출물을 생성해야 다음 Phase로 진행할 수 있습니다.
- Phase Gate 검증을 통과해야 합니다.

### 4. 서브에이전트 격리
- 각 에이전트는 자신의 허용된 도구만 사용할 수 있습니다.
- Researcher와 Reviewer는 읽기 전용 (코드 수정 불가)입니다.

### 5. 한국어 중심
- 문서, 주석, 커밋 메시지는 한국어로 작성합니다.
- 변수명, 함수명, 기술 용어는 영문을 사용합니다.

## 기술 스택

- **백엔드**: Python 3.11+ / FastAPI / SQLAlchemy / Pydantic
- **프론트엔드**: React 18+ / TypeScript / Vite
- **테스트**: pytest (백엔드) / Vitest (프론트엔드)
- **포매팅**: ruff (Python) / prettier + eslint (TypeScript/React)

## 위임 규칙

### 순차 실행 (기본)
Phase 1 → 2 → 3 → 4 → 5 순서로 실행합니다. 각 Phase의 산출물이 다음 Phase의 입력이 됩니다.

### 병렬 실행 가능
- Phase 3에서 백엔드/프론트엔드를 병렬로 개발할 수 있습니다.
- Phase 4에서 보안 감사와 코드 리뷰를 병렬로 수행할 수 있습니다.

### Review-Fix 루프
- Phase 4(Review)에서 Critical 이슈 발견 시 Phase 3(TDD-Develop)을 재실행합니다.
- 최대 2회까지 재실행하며, 그 이후에도 Critical이 남아있으면 사용자에게 보고합니다.
