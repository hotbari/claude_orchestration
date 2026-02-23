# 기술 설계 명세서

> 작성일: YYYY-MM-DD
> 대상: [기능/서비스명]
> 기반 문서: docs/specs/requirements.md

## 1. 아키텍처 개요

### 1.1 시스템 구조
```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│   React Frontend │────▶│  FastAPI Backend  │────▶│  Database   │
│   (Vite + TS)   │◀────│  (Python 3.11+)  │◀────│  (SQLAlchemy)│
└─────────────────┘     └──────────────────┘     └─────────────┘
```

### 1.2 계층 구조

```
프론트엔드 (React)
├── Pages (라우팅)
├── Components (UI)
├── Hooks (비즈니스 로직)
└── Services (API 호출)

백엔드 (FastAPI)
├── Router (API 엔드포인트)
├── Service (비즈니스 로직)
├── Repository (데이터 접근)
├── Schema (Pydantic 모델)
└── Model (SQLAlchemy 모델)
```

### 1.3 기술 의사결정

| 결정사항 | 선택 | 대안 | 이유 |
|---------|------|------|------|
| [항목] | [선택] | [대안] | [이유] |

## 2. 데이터 모델

### 2.1 ERD

```
[테이블/엔티티 관계도]
```

### 2.2 SQLAlchemy 모델

#### [모델명]
| 컬럼 | 타입 | 제약조건 | 설명 |
|------|------|----------|------|
| id | Integer | PK, auto_increment | 고유 식별자 |
| created_at | DateTime | default=now | 생성 시각 |
| updated_at | DateTime | onupdate=now | 수정 시각 |

### 2.3 인덱스
| 테이블 | 인덱스 | 컬럼 | 타입 |
|--------|--------|------|------|
| [테이블] | [인덱스명] | [컬럼] | UNIQUE / INDEX |

## 3. 컴포넌트 설계

### 3.1 백엔드 컴포넌트

#### Router Layer
```python
# src/api/routes/[모듈].py
router = APIRouter(prefix="/api/v1/[리소스]", tags=["[태그]"])
```

#### Service Layer
```python
# src/api/services/[모듈]_service.py
class [모듈]Service:
    def __init__(self, db: Session):
        self.db = db
```

#### Repository Layer
```python
# src/api/repositories/[모듈]_repository.py
class [모듈]Repository:
    def __init__(self, db: Session):
        self.db = db
```

### 3.2 프론트엔드 컴포넌트

#### 디자인 시스템 설정
- 색상 팔레트: [default-blue / forest-green / warm-amber / slate-professional / violet-creative / custom]
- 레이아웃: Header [Y/N], Sidebar [Y/N], Footer [Y/N]
- UI 컴포넌트: [프로젝트에서 사용할 컴포넌트 목록 — Button, Input, Card, Table, Form, Modal, Toast, Badge, Spinner 중 선택]

#### 페이지 구조
```
src/frontend/
├── pages/
│   └── [PageName].tsx
├── components/
│   ├── ui/            # 디자인 시스템 컴포넌트 (Button, Input, Card 등)
│   └── layout/        # 레이아웃 컴포넌트 (Header, Footer, Sidebar 등)
├── hooks/
│   └── use[HookName].ts
├── lib/
│   └── utils.ts       # cn() 유틸리티
├── styles/
│   └── globals.css    # CSS custom properties + Tailwind
└── services/
    └── [service]Api.ts
```

#### 컴포넌트 트리
```
App
├── ToastProvider
│   └── AppLayout
│       ├── Header
│       ├── Sidebar (선택)
│       └── Main
│           └── [PageComponent]
│               └── [디자인 시스템 UI 컴포넌트 활용]
└── Footer
```

## 4. 에러 처리 전략

### 4.1 백엔드 에러 처리
```python
# 비즈니스 예외 계층
class AppError(Exception): ...
class NotFoundError(AppError): ...
class ValidationError(AppError): ...
class AuthenticationError(AppError): ...
class AuthorizationError(AppError): ...
```

### 4.2 에러 응답 포맷
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "사용자 친화적 메시지",
    "details": []
  }
}
```

### 4.3 프론트엔드 에러 처리
- API 에러: try-catch + 사용자 알림
- 네트워크 에러: 재시도 로직
- 유효성 검증: 폼 레벨 에러 표시

## 5. 보안 설계

### 5.1 인증 (Authentication)
- 방식: [JWT / OAuth2 / Session]
- 토큰 저장: [httpOnly Cookie / localStorage]
- 만료: access token [시간], refresh token [시간]

### 5.2 인가 (Authorization)
- 방식: [RBAC / ABAC]
- 역할: [Admin, User, Guest 등]

### 5.3 입력 검증
- 백엔드: Pydantic 모델로 모든 입력 검증
- 프론트엔드: 폼 검증 (제출 전 클라이언트 검증)

## 6. 파일 구조

```
projects/{project-name}/
├── docker-compose.yml           # docker compose up --build 진입점
├── Dockerfile.api               # 백엔드 이미지
├── Dockerfile.frontend          # 프론트엔드 이미지
├── .env.example                 # 환경 변수 템플릿
├── README.md                    # 프로젝트 설명 + 실행 가이드
│
├── docs/                        # 설계 산출물
│   ├── specs/
│   ├── api/
│   └── reviews/
│
├── backend/                     # FastAPI 백엔드
│   ├── requirements.txt
│   ├── src/
│   │   └── api/
│   │       ├── __init__.py
│   │       ├── main.py          # FastAPI 앱 초기화
│   │       ├── config.py        # 설정 (pydantic-settings)
│   │       ├── database.py      # DB 연결
│   │       ├── models/          # SQLAlchemy 모델
│   │       ├── schemas/         # Pydantic 스키마
│   │       ├── routes/          # API 라우트
│   │       ├── services/        # 비즈니스 로직
│   │       └── repositories/    # 데이터 접근
│   └── tests/
│       └── api/
│           ├── conftest.py
│           └── test_*.py
│
└── frontend/                    # React 프론트엔드
    ├── package.json
    ├── vite.config.ts
    ├── nginx.conf               # 프로덕션 Nginx 설정
    ├── src/
    │   ├── App.tsx
    │   ├── main.tsx
    │   ├── pages/
    │   ├── components/
    │   ├── hooks/
    │   ├── services/
    │   └── types/
    └── tests/
        └── *.test.tsx
```

## 7. Docker 구성

### docker-compose.yml 서비스 구조
| 서비스 | 이미지 | 포트 | 설명 |
|--------|--------|------|------|
| api | Dockerfile.api | 8000 | FastAPI 백엔드 |
| frontend | Dockerfile.frontend | 3000→80 | React (Nginx) |
| db | postgres:16-alpine | 5432 | PostgreSQL |

### 실행 방법
```bash
cd projects/{project-name}
cp .env.example .env
docker compose up --build
```
