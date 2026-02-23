# E2E 파이프라인 실행 예시

## 시나리오

사용자가 **"PDF 업로드 → OCR 텍스트 추출 → 벡터 DB 저장/검색 서비스"** 를 구현하려 합니다.
요구사항 정의서가 PDF 파일(`document-search-requirements.pdf`)로 주어져 있습니다.

이 서비스는 다음과 같은 기술적 난이도를 포함합니다:
- 파일 업로드 (멀티파트) + 비동기 처리
- OCR 엔진 연동 (Tesseract / pdf2image)
- 임베딩 생성 (OpenAI / Sentence-Transformers)
- 벡터 DB 저장/유사도 검색 (ChromaDB / pgvector)
- 비동기 작업 상태 추적 (처리 중/완료/실패)

---

## Step 0: 사용자 진입

```
사용자: "이 PDF 요구사항 기반으로 문서 검색 서비스 구현해줘"
        + document-search-requirements.pdf 제공
```

**PDF 전처리**: Claude Code는 PDF를 직접 읽을 수 있지만, 파이프라인의 일관성을 위해 Markdown으로 변환하는 것을 권장합니다.

```bash
# 방법 A: pandoc으로 변환
pandoc document-search-requirements.pdf -o requirements-input.md

# 방법 B: Claude Code에 직접 PDF 경로 전달 (Read 도구가 PDF 지원)
```

사용자가 변환 후 프로젝트 루트에 `requirements-input.md`를 배치했다고 가정합니다.

```
사용자: /pipeline pdf_search_service PDF 업로드 후 OCR 텍스트 추출 및 벡터 DB 기반 문서 검색 서비스 (요구사항은 requirements-input.md 참고)
```

---

## Phase 0: 프로젝트 초기화

### Orchestrator가 하는 일

```bash
mkdir -p projects/pdf_search_service/{docs/{specs,api,reviews},backend/{src/api,tests},frontend/{src,tests}}
```

```
📁 프로젝트 생성: projects/pdf_search_service/
```

---

## Phase 1: Research (Researcher Agent)

### Orchestrator → Researcher 위임

```
Task 도구 실행:
  - subagent_type: "Explore"
  - model: haiku
  - prompt: "requirements-input.md를 읽고, 코드베이스를 탐색하여
             projects/pdf_search_service/docs/specs/requirements.md를 작성하라.
             .claude/agents/researcher.md의 절차를 따를 것."
```

### Researcher Agent 실행 내용

**1단계 — 입력 문서 읽기**
```
Read: requirements-input.md
```
원본 PDF에서 변환된 내용을 분석합니다:
> - 사용자가 PDF를 업로드하면 서버에서 OCR을 수행한다
> - 추출된 텍스트를 청크로 분할하고 임베딩을 생성한다
> - 벡터 DB에 저장하여 자연어 검색이 가능하게 한다
> - 문서별 처리 상태를 추적한다 (uploading → processing → completed → failed)
> - 검색 시 유사도 상위 K건을 반환하고 원문 위치를 하이라이트한다
> - 관리자는 문서를 삭제할 수 있다 (벡터 DB에서도 삭제)

**2단계 — 기술 자료 조사**
```
WebSearch: "FastAPI file upload OCR tesseract chromadb integration"
WebSearch: "pdf2image pytesseract text extraction best practice 2026"
WebSearch: "chromadb python embedding storage search"
```

**3단계 — 코드베이스 탐색**
```
Glob: projects/pdf_search_service/**
```
→ 신규 프로젝트 확인 (기존 코드 없음)

**4단계 — 요구사항 문서 작성**

`projects/pdf_search_service/docs/specs/requirements.md`:

```markdown
# 요구사항 명세서

> 작성일: 2026-02-21
> 대상: PDF 문서 검색 서비스
> 원본: requirements-input.md

## 1. 개요

### 1.1 목적
PDF 파일을 업로드하면 OCR로 텍스트를 추출하고, 벡터 DB에 저장하여
자연어 기반 유사도 검색을 제공하는 서비스

### 1.2 범위
- **포함**: PDF 업로드, OCR 추출, 텍스트 청킹, 임베딩 생성,
           벡터 DB 저장/검색, 문서 관리, 검색 UI
- **제외**: 사용자 인증 (MVP에서 제외), PDF 외 파일 포맷,
           실시간 협업, 유료 과금

### 1.3 용어 정의
| 용어 | 정의 |
|------|------|
| Chunk | 텍스트를 검색에 적합한 크기(~500토큰)로 분할한 단위 |
| Embedding | 텍스트를 고차원 벡터로 변환한 수치 표현 |
| 유사도 검색 | 쿼리 벡터와 저장된 벡터 간 코사인 유사도 기반 검색 |

## 2. 기능 요구사항

### 2.1 문서 업로드 및 처리

| ID     | 기능               | 설명                                          | 우선순위 |
|--------|--------------------|----------------------------------------------|---------|
| FR-001 | PDF 업로드          | 멀티파트 파일 업로드 (최대 50MB)                 | P0      |
| FR-002 | OCR 텍스트 추출     | PDF → 이미지 변환 → Tesseract OCR              | P0      |
| FR-003 | 텍스트 청킹         | 추출 텍스트를 ~500토큰 단위 청크로 분할           | P0      |
| FR-004 | 임베딩 생성         | 각 청크를 벡터 임베딩으로 변환                    | P0      |
| FR-005 | 벡터 DB 저장        | 임베딩 + 메타데이터를 ChromaDB에 저장             | P0      |
| FR-006 | 처리 상태 추적      | 문서별 상태 (uploading/processing/completed/failed) | P0   |

### 2.2 검색

| ID     | 기능               | 설명                                          | 우선순위 |
|--------|--------------------|----------------------------------------------|---------|
| FR-007 | 자연어 검색         | 쿼리 텍스트로 유사도 검색, top-K 반환             | P0      |
| FR-008 | 검색 결과 표시      | 매칭 청크, 유사도 점수, 원본 문서/페이지 정보       | P0      |
| FR-009 | 검색 필터           | 문서명, 업로드 날짜 범위 필터                      | P1      |

### 2.3 문서 관리

| ID     | 기능               | 설명                                          | 우선순위 |
|--------|--------------------|----------------------------------------------|---------|
| FR-010 | 문서 목록 조회      | 업로드된 문서 목록 + 처리 상태 표시               | P0      |
| FR-011 | 문서 상세 조회      | 문서 메타데이터, 추출 텍스트, 청크 수              | P1      |
| FR-012 | 문서 삭제          | 파일 + DB 레코드 + 벡터 DB 임베딩 일괄 삭제       | P1      |

## 3. 비기능 요구사항

### 3.1 성능
- PDF 업로드 → OCR 완료: 10페이지 기준 30초 이내
- 검색 응답 시간: < 500ms
- 최대 파일 크기: 50MB
- 동시 처리: 최대 3개 PDF 병렬

### 3.2 안정성
- OCR 실패 시 graceful 에러 처리 (상태를 failed로 전환)
- 부분 실패 시 이미 처리된 청크는 유지

### 3.3 저장
- 원본 PDF: 로컬 파일시스템 (uploads/ 디렉토리)
- 메타데이터: PostgreSQL (SQLAlchemy)
- 벡터 임베딩: ChromaDB (persist_directory)

## 4. 제약조건

### 4.1 기술적 제약
- 기술 스택: FastAPI + React + Docker Compose
- OCR: Tesseract + pdf2image (Poppler 의존)
- 임베딩: sentence-transformers (all-MiniLM-L6-v2) — 오프라인 동작
- 벡터 DB: ChromaDB (경량, 별도 서버 불필요)
- 비동기 처리: FastAPI BackgroundTasks 또는 Celery

### 4.2 Docker 제약
- Tesseract, Poppler는 Dockerfile에서 시스템 패키지로 설치 필요
- ChromaDB persist_directory를 Docker volume으로 마운트
- uploads/ 디렉토리도 volume 마운트 (컨테이너 재시작 시 보존)

## 5. 의존성

### 5.1 백엔드
| 패키지 | 용도 |
|--------|------|
| fastapi + uvicorn | 웹 프레임워크 |
| sqlalchemy + asyncpg | ORM + PostgreSQL |
| python-multipart | 파일 업로드 |
| pdf2image | PDF → 이미지 |
| pytesseract | OCR |
| sentence-transformers | 임베딩 생성 |
| chromadb | 벡터 DB |
| pillow | 이미지 처리 |

### 5.2 프론트엔드
| 패키지 | 용도 |
|--------|------|
| react + react-dom | UI 프레임워크 |
| @tanstack/react-query | 서버 상태 관리 |
| react-dropzone | 파일 업로드 UI |
| axios | HTTP 클라이언트 |

### 5.3 인프라 (Docker)
| 이미지 | 용도 |
|--------|------|
| python:3.11-slim + tesseract-ocr + poppler-utils | 백엔드 |
| node:20-alpine + nginx | 프론트엔드 |
| postgres:16-alpine | 메타데이터 DB |
```

### Gate 검증
```
Orchestrator: projects/pdf_search_service/docs/specs/requirements.md 존재? ✅
→ Phase 2로 진행
```

사용자에게 보고:
```
📋 Phase 1 (Research) 완료
- 원본 문서에서 12개 기능 요구사항 식별 (P0: 8개, P1: 4개)
- 핵심 기술 의존성: Tesseract OCR, ChromaDB, sentence-transformers
- Docker 제약사항 3건 식별 (시스템 패키지, 볼륨 마운트)
- 신규 프로젝트로 확인 (기존 코드 없음)
```

---

## Phase 2: Architect (Architect Agent)

### Orchestrator → Architect 위임

```
Task 도구 실행:
  - subagent_type: "general-purpose"
  - model: sonnet
  - prompt: "projects/pdf_search_service/docs/specs/requirements.md를 읽고,
             기술 설계서와 API 명세를 작성하라.
             .claude/agents/architect.md의 절차를 따를 것."
```

### Architect Agent 실행 내용

**1단계 — 요구사항 분석**
```
Read: projects/pdf_search_service/docs/specs/requirements.md
```
기술적 의사결정 포인트 식별:
- 비동기 처리 방식: BackgroundTasks vs Celery
- 임베딩 모델 로딩 전략: 앱 시작 시 로드 vs 요청 시 로드
- 청킹 전략: 고정 크기 vs 문장 기반 vs 오버랩

**2단계 — 설계 문서 작성**

`projects/pdf_search_service/docs/specs/technical-spec.md`:

```markdown
# 기술 설계 명세서

> 작성일: 2026-02-21
> 대상: PDF 문서 검색 서비스
> 기반 문서: docs/specs/requirements.md

## 1. 아키텍처 개요

### 1.1 시스템 구조

┌──────────────┐    ┌───────────────────────────┐    ┌────────────┐
│ React        │───▶│ FastAPI                   │───▶│ PostgreSQL │
│ (Vite + TS)  │◀───│                           │◀───│ (메타데이터) │
│ :3000        │    │  ┌─────────────────────┐  │    └────────────┘
└──────────────┘    │  │ Background Worker   │  │
                    │  │ PDF→OCR→Chunk→Embed │  │    ┌────────────┐
                    │  └─────────────────────┘  │───▶│ ChromaDB   │
                    │         :8000             │◀───│ (벡터 DB)   │
                    └───────────────────────────┘    └────────────┘
                              │
                         ┌────┴────┐
                         │ uploads/ │  ← Docker Volume
                         └─────────┘

### 1.2 기술 의사결정

| 결정사항 | 선택 | 대안 | 이유 |
|---------|------|------|------|
| 비동기 처리 | BackgroundTasks | Celery+Redis | MVP 복잡도 절감, 단일 컨테이너 |
| 임베딩 모델 | all-MiniLM-L6-v2 | OpenAI API | 오프라인 동작, 무료, 384차원 |
| 벡터 DB | ChromaDB | pgvector | 설정 간소, Python 네이티브 |
| 청킹 전략 | RecursiveCharacterTextSplitter | 고정 크기 | 문맥 보존, 오버랩 지원 |
| 모델 로딩 | 앱 시작 시 (lifespan) | 요청 시 지연로딩 | 첫 검색 지연 방지 |

### 1.3 계층 구조

백엔드 (FastAPI)
├── Router        — API 엔드포인트 (파일 업로드, 검색, 문서 관리)
├── Service       — 비즈니스 로직 (OCR 파이프라인, 검색 로직)
├── Repository    — 데이터 접근 (SQLAlchemy, ChromaDB)
├── Worker        — 백그라운드 처리 (OCR → 청킹 → 임베딩 → 저장)
└── Schema        — Pydantic 요청/응답 모델

## 2. 데이터 모델

### 2.1 PostgreSQL (메타데이터)

#### Document
| 컬럼 | 타입 | 제약조건 | 설명 |
|------|------|----------|------|
| id | UUID | PK, default=uuid4 | 문서 고유 ID |
| filename | String(500) | NOT NULL | 원본 파일명 |
| file_path | String(1000) | NOT NULL | 저장 경로 |
| file_size | Integer | NOT NULL | 파일 크기 (bytes) |
| page_count | Integer | nullable | 총 페이지 수 |
| status | Enum | NOT NULL, default=UPLOADING | 처리 상태 |
| error_message | Text | nullable | 실패 시 에러 메시지 |
| created_at | DateTime | default=now | 업로드 시각 |
| completed_at | DateTime | nullable | 처리 완료 시각 |

#### DocumentStatus Enum
- UPLOADING: 파일 업로드 중
- PROCESSING: OCR + 임베딩 처리 중
- COMPLETED: 처리 완료
- FAILED: 처리 실패

#### Chunk
| 컬럼 | 타입 | 제약조건 | 설명 |
|------|------|----------|------|
| id | UUID | PK, default=uuid4 | 청크 고유 ID |
| document_id | UUID | FK(documents.id), NOT NULL | 소속 문서 |
| page_number | Integer | NOT NULL | 원본 페이지 번호 |
| chunk_index | Integer | NOT NULL | 청크 순서 |
| content | Text | NOT NULL | 텍스트 내용 |
| token_count | Integer | NOT NULL | 토큰 수 |
| created_at | DateTime | default=now | 생성 시각 |

### 2.2 ChromaDB (벡터 저장)

- Collection: "document_chunks"
- ID: chunk.id (UUID → string)
- Embedding: 384차원 float 벡터 (all-MiniLM-L6-v2)
- Metadata: { document_id, page_number, chunk_index, filename }
- Document: chunk.content (원문 텍스트)

## 3. 백그라운드 처리 파이프라인

PDF 업로드 → 파일 저장 → OCR 시작 (BackgroundTask)

      ┌──────────────────────────────────────────────────────┐
      │               Background Worker                      │
      │                                                      │
      │  1. PDF → 이미지 (pdf2image, 페이지별)                 │
      │  2. 이미지 → 텍스트 (pytesseract, 페이지별)             │
      │  3. 텍스트 → 청크 (RecursiveCharacterTextSplitter)     │
      │     - chunk_size: 500 tokens                         │
      │     - chunk_overlap: 50 tokens                       │
      │  4. 청크 → 임베딩 (sentence-transformers)              │
      │  5. 임베딩 + 메타데이터 → ChromaDB 저장                 │
      │  6. 청크 정보 → PostgreSQL 저장                        │
      │  7. Document status → COMPLETED                      │
      │                                                      │
      │  에러 발생 시: status → FAILED + error_message 기록     │
      └──────────────────────────────────────────────────────┘

## 4. 에러 처리 전략

### 4.1 비즈니스 예외 계층
- DocumentNotFoundError → 404
- InvalidFileTypeError → 400 (PDF 외 파일)
- FileTooLargeError → 413 (50MB 초과)
- OCRProcessingError → 500 (내부, 상태를 FAILED로)
- SearchError → 500

### 4.2 파이프라인 에러 복구
- OCR 실패: 해당 페이지 건너뜀 + 나머지 계속 처리
- 전체 실패: status=FAILED, error_message에 원인 기록
- 이미 처리된 청크는 삭제하지 않음 (부분 결과 보존)

## 5. 보안 설계

- 파일 업로드: Content-Type 검증, 파일 크기 제한 (50MB)
- 파일 저장: UUID 기반 경로 (원본 파일명 노출 방지)
- SQL: SQLAlchemy ORM (파라미터 바인딩)
- 경로 순회 공격: 파일 경로 정규화 + 허용 디렉토리 제한

## 6. 파일 구조

projects/pdf_search_service/
├── docker-compose.yml
├── Dockerfile.api             # Tesseract + Poppler 포함
├── Dockerfile.frontend
├── .env.example
├── README.md
│
├── backend/
│   ├── requirements.txt
│   ├── src/api/
│   │   ├── __init__.py
│   │   ├── main.py            # FastAPI 앱 + lifespan (모델 로딩)
│   │   ├── config.py          # 설정 (BaseSettings)
│   │   ├── database.py        # PostgreSQL 세션
│   │   ├── vectorstore.py     # ChromaDB 클라이언트
│   │   ├── models/
│   │   │   ├── document.py    # Document, DocumentStatus
│   │   │   └── chunk.py       # Chunk
│   │   ├── schemas/
│   │   │   ├── document.py    # DocumentCreate, DocumentResponse, ...
│   │   │   └── search.py      # SearchRequest, SearchResult, ...
│   │   ├── routes/
│   │   │   ├── documents.py   # 업로드, 목록, 상세, 삭제
│   │   │   └── search.py      # 검색
│   │   ├── services/
│   │   │   ├── document_service.py  # 문서 CRUD
│   │   │   ├── ocr_service.py       # PDF → 텍스트
│   │   │   ├── embedding_service.py # 텍스트 → 벡터
│   │   │   └── search_service.py    # 유사도 검색
│   │   ├── repositories/
│   │   │   ├── document_repository.py
│   │   │   ├── chunk_repository.py
│   │   │   └── vector_repository.py  # ChromaDB 래퍼
│   │   └── workers/
│   │       └── ocr_pipeline.py       # 백그라운드 파이프라인
│   └── tests/
│       ├── conftest.py
│       └── api/
│           ├── test_documents.py
│           ├── test_search.py
│           └── test_ocr_pipeline.py
│
└── frontend/
    ├── package.json
    ├── vite.config.ts
    ├── nginx.conf
    ├── src/
    │   ├── main.tsx
    │   ├── App.tsx
    │   ├── pages/
    │   │   ├── UploadPage.tsx
    │   │   ├── DocumentListPage.tsx
    │   │   └── SearchPage.tsx
    │   ├── components/
    │   │   ├── FileDropzone.tsx
    │   │   ├── DocumentCard.tsx
    │   │   ├── ProcessingStatus.tsx
    │   │   ├── SearchBar.tsx
    │   │   └── SearchResultCard.tsx
    │   ├── hooks/
    │   │   ├── useDocuments.ts
    │   │   └── useSearch.ts
    │   ├── services/
    │   │   └── api.ts
    │   └── types/
    │       └── index.ts
    └── tests/
        ├── setup.ts
        ├── components/
        │   ├── FileDropzone.test.tsx
        │   ├── SearchBar.test.tsx
        │   └── SearchResultCard.test.tsx
        └── hooks/
            └── useSearch.test.ts
```

**3단계 — API 명세 작성**

`projects/pdf_search_service/docs/api/api-spec.md`:

```markdown
# API 명세서

> 대상: PDF 문서 검색 서비스
> Base URL: /api/v1

## 1. 문서 관리

### 🔓 POST /api/v1/documents/upload — PDF 업로드

**설명**: PDF 파일을 업로드하고 백그라운드 OCR 처리를 시작합니다.

**요청**: multipart/form-data
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| file | File | ✅ | PDF 파일 (최대 50MB) |

**Pydantic 스키마**
class DocumentUploadResponse(BaseModel):
    id: UUID
    filename: str
    file_size: int
    status: DocumentStatus  # UPLOADING → PROCESSING
    created_at: datetime

**응답**
| 상태 코드 | 설명 |
|-----------|------|
| 202 Accepted | 업로드 성공, 백그라운드 처리 시작 |
| 400 Bad Request | PDF가 아닌 파일 |
| 413 Content Too Large | 50MB 초과 |

### 🔓 GET /api/v1/documents — 문서 목록 조회

**쿼리 파라미터**
| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|--------|------|
| skip | int | 0 | 시작 위치 |
| limit | int | 20 | 페이지 크기 (최대 100) |
| status | str | null | 상태 필터 (PROCESSING, COMPLETED 등) |

**응답**: 200 OK
{
  "items": [DocumentResponse],
  "total": int,
  "skip": int,
  "limit": int
}

### 🔓 GET /api/v1/documents/{document_id} — 문서 상세 조회

**응답**: 200 OK
class DocumentDetailResponse(BaseModel):
    id: UUID
    filename: str
    file_size: int
    page_count: int | None
    status: DocumentStatus
    error_message: str | None
    chunk_count: int
    created_at: datetime
    completed_at: datetime | None

### 🔓 GET /api/v1/documents/{document_id}/status — 처리 상태 조회

**설명**: 폴링용 경량 엔드포인트. 프론트엔드가 주기적으로 호출하여 처리 진행률을 확인합니다.

**응답**: 200 OK
class DocumentStatusResponse(BaseModel):
    id: UUID
    status: DocumentStatus
    error_message: str | None

### 🔓 DELETE /api/v1/documents/{document_id} — 문서 삭제

**설명**: 원본 파일 + DB 레코드 + ChromaDB 벡터를 일괄 삭제합니다.

**응답**
| 상태 코드 | 설명 |
|-----------|------|
| 204 No Content | 삭제 성공 |
| 404 Not Found | 문서 없음 |

## 2. 검색

### 🔓 POST /api/v1/search — 유사도 검색

**요청**
class SearchRequest(BaseModel):
    query: str = Field(min_length=1, max_length=1000)
    top_k: int = Field(default=5, ge=1, le=50)
    document_ids: list[UUID] | None = None  # 특정 문서만 검색 (선택)

**응답**: 200 OK
class SearchResponse(BaseModel):
    query: str
    results: list[SearchResultItem]
    total: int

class SearchResultItem(BaseModel):
    chunk_id: UUID
    document_id: UUID
    filename: str
    page_number: int
    content: str           # 매칭된 청크 텍스트
    score: float           # 유사도 점수 (0~1)

## 3. 공통 에러 포맷

{
  "error": {
    "code": "VALIDATION_ERROR | NOT_FOUND | FILE_TOO_LARGE
             | INVALID_FILE_TYPE | PROCESSING_ERROR | INTERNAL_ERROR",
    "message": "사용자 친화적 메시지",
    "details": [...]
  }
}
```

### Gate 검증
```
projects/pdf_search_service/docs/specs/technical-spec.md 존재? ✅
projects/pdf_search_service/docs/api/api-spec.md 존재? ✅
→ Phase 3로 진행
```

사용자에게 보고:
```
📐 Phase 2 (Architect) 완료
- 2개 데이터 모델 (Document, Chunk) + ChromaDB 컬렉션 설계
- 7개 API 엔드포인트 설계
- 백그라운드 OCR 파이프라인 (5단계) 설계
- Docker 이미지에 Tesseract + Poppler 포함 결정
```

> **이 시점부터 `protect-specs.sh` Hook이 스펙 파일 수정을 차단합니다.**

---

## Phase 3a + 3b: TDD-Develop (병렬 실행)

Orchestrator가 **두 서브에이전트를 동시에 실행**합니다:

```
Task A (Backend Developer):
  - subagent_type: "general-purpose"
  - projects/pdf_search_service/ 경로
  - backend만 담당

Task B (Frontend Developer):
  - subagent_type: "general-purpose"
  - model: sonnet
  - projects/pdf_search_service/ 경로
  - frontend만 담당
```

### Phase 3a: Backend Developer Agent

여기서는 가장 복잡한 두 기능 — **PDF 업로드 + OCR 파이프라인**과 **유사도 검색** — 의 TDD 사이클을 상세히 보여줍니다.

---

#### 기능 1: PDF 업로드 + OCR 파이프라인

##### 🔴 Red — 실패하는 테스트 작성

파일: `backend/tests/api/test_documents.py`

```python
import io
import pytest


class TestUploadDocument:
    """PDF 업로드 API 테스트"""

    def test_유효한_PDF_업로드시_202_반환(self, client):
        """Given: 유효한 PDF 파일
        When: POST /api/v1/documents/upload
        Then: 202 Accepted, 문서 ID 반환, 상태 PROCESSING"""
        # Given
        pdf_content = self._create_test_pdf()
        files = {"file": ("test.pdf", pdf_content, "application/pdf")}

        # When
        response = client.post("/api/v1/documents/upload", files=files)

        # Then
        assert response.status_code == 202
        data = response.json()
        assert "id" in data
        assert data["filename"] == "test.pdf"
        assert data["status"] in ("UPLOADING", "PROCESSING")

    def test_PDF가_아닌_파일_업로드시_400_반환(self, client):
        """Given: .txt 파일
        When: POST /api/v1/documents/upload
        Then: 400 Bad Request"""
        files = {"file": ("test.txt", b"hello", "text/plain")}

        response = client.post("/api/v1/documents/upload", files=files)

        assert response.status_code == 400
        assert response.json()["error"]["code"] == "INVALID_FILE_TYPE"

    def test_50MB_초과_파일_업로드시_413_반환(self, client):
        """Given: 50MB 초과 파일
        When: POST /api/v1/documents/upload
        Then: 413 Content Too Large"""
        large_content = b"0" * (50 * 1024 * 1024 + 1)
        files = {"file": ("big.pdf", large_content, "application/pdf")}

        response = client.post("/api/v1/documents/upload", files=files)

        assert response.status_code == 413

    @staticmethod
    def _create_test_pdf() -> bytes:
        """테스트용 최소 PDF 생성"""
        # 최소 유효 PDF 바이트
        return (
            b"%PDF-1.0\n1 0 obj<</Pages 2 0 R>>endobj\n"
            b"2 0 obj<</Kids[3 0 R]/Count 1>>endobj\n"
            b"3 0 obj<</MediaBox[0 0 612 792]>>endobj\n"
            b"trailer<</Root 1 0 R>>"
        )
```

파일: `backend/tests/api/test_ocr_pipeline.py`

```python
from unittest.mock import patch, MagicMock


class TestOCRPipeline:
    """OCR 파이프라인 단위 테스트"""

    def test_PDF에서_텍스트_추출(self, db):
        """Given: 텍스트가 포함된 PDF
        When: OCR 파이프라인 실행
        Then: 텍스트 청크 생성 + 임베딩 저장"""
        # Given
        ocr_service = OCRService()
        mock_pdf_path = "/tmp/test.pdf"

        with patch("src.api.services.ocr_service.convert_from_path") as mock_convert:
            mock_image = MagicMock()
            mock_convert.return_value = [mock_image]  # 1페이지

            with patch("src.api.services.ocr_service.pytesseract") as mock_tess:
                mock_tess.image_to_string.return_value = "테스트 문서 내용입니다. " * 50

                # When
                text_pages = ocr_service.extract_text(mock_pdf_path)

                # Then
                assert len(text_pages) == 1
                assert "테스트 문서" in text_pages[0]

    def test_텍스트_청킹_500토큰_기준(self):
        """Given: 2000토큰 분량 텍스트
        When: 청킹 실행 (chunk_size=500, overlap=50)
        Then: ~4개 청크 생성, 오버랩 존재"""
        from src.api.services.ocr_service import OCRService

        service = OCRService()
        long_text = "이것은 테스트 문장입니다. " * 200

        chunks = service.split_into_chunks(long_text, chunk_size=500, overlap=50)

        assert len(chunks) >= 3
        # 오버랩 확인: 이전 청크 끝과 다음 청크 시작이 겹침
        assert chunks[0][-50:] in chunks[1][:100] or len(chunks[0]) < 500

    def test_OCR_실패시_문서_상태_FAILED(self, db, client):
        """Given: OCR 처리 중 에러 발생
        When: 파이프라인 실행
        Then: Document.status = FAILED, error_message 기록"""
        # (구현 후 검증)
        ...
```

```bash
$ cd projects/pdf_search_service/backend && pytest tests/ -v
FAILED test_유효한_PDF_업로드시_202_반환
FAILED test_PDF가_아닌_파일_업로드시_400_반환
FAILED test_50MB_초과_파일_업로드시_413_반환
FAILED test_PDF에서_텍스트_추출
FAILED test_텍스트_청킹_500토큰_기준
FAILED test_OCR_실패시_문서_상태_FAILED
```
→ 6개 전부 실패 (Red) ✅

##### 🟢 Green — 최소 구현

이 시점에서 `backend/src/api/routes/documents.py`를 작성하려 하면 **`tdd-guard.sh` 체크**:
```
tdd-guard.sh:
  파일: projects/pdf_search_service/backend/src/api/routes/documents.py
  대응 테스트: projects/pdf_search_service/backend/tests/api/test_documents.py
  → 존재함 ✅ 편집 허용
```

주요 구현 파일들:

파일: `backend/src/api/routes/documents.py`
```python
from fastapi import APIRouter, UploadFile, File, BackgroundTasks, Depends, HTTPException

router = APIRouter(prefix="/api/v1/documents", tags=["documents"])

MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB

@router.post("/upload", response_model=DocumentUploadResponse, status_code=202)
async def upload_document(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    # 파일 타입 검증
    if not file.content_type == "application/pdf":
        raise HTTPException(400, detail={
            "error": {"code": "INVALID_FILE_TYPE",
                      "message": "PDF 파일만 업로드 가능합니다."}
        })

    # 파일 크기 검증
    content = await file.read()
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(413, detail={
            "error": {"code": "FILE_TOO_LARGE",
                      "message": "파일 크기는 50MB를 초과할 수 없습니다."}
        })

    # 파일 저장 + DB 레코드 생성
    service = DocumentService(db)
    document = service.create_document(file.filename, content)

    # 백그라운드 OCR 시작
    background_tasks.add_task(ocr_pipeline.process_document, document.id)

    return document
```

파일: `backend/src/api/services/ocr_service.py`
```python
from pdf2image import convert_from_path
import pytesseract


class OCRService:
    def extract_text(self, pdf_path: str) -> list[str]:
        """PDF → 페이지별 텍스트 추출"""
        images = convert_from_path(pdf_path)
        texts = []
        for image in images:
            text = pytesseract.image_to_string(image, lang="kor+eng")
            texts.append(text)
        return texts

    def split_into_chunks(
        self, text: str, chunk_size: int = 500, overlap: int = 50
    ) -> list[str]:
        """텍스트 → 청크 분할 (오버랩 포함)"""
        chunks = []
        start = 0
        while start < len(text):
            end = start + chunk_size
            chunk = text[start:end]
            if chunk.strip():
                chunks.append(chunk)
            start = end - overlap
        return chunks
```

파일: `backend/src/api/workers/ocr_pipeline.py`
```python
async def process_document(document_id: UUID):
    """백그라운드 OCR 파이프라인"""
    db = SessionLocal()
    try:
        doc_repo = DocumentRepository(db)
        document = doc_repo.get(document_id)
        document.status = DocumentStatus.PROCESSING
        db.commit()

        # 1. OCR
        ocr_service = OCRService()
        text_pages = ocr_service.extract_text(document.file_path)

        # 2. 청킹
        all_chunks = []
        for page_num, text in enumerate(text_pages, 1):
            chunks = ocr_service.split_into_chunks(text)
            for idx, content in enumerate(chunks):
                all_chunks.append((page_num, idx, content))

        # 3. 임베딩 생성
        embedding_service = EmbeddingService()
        texts = [c[2] for c in all_chunks]
        embeddings = embedding_service.encode(texts)

        # 4. 벡터 DB 저장
        vector_repo = VectorRepository()
        chunk_repo = ChunkRepository(db)
        for (page_num, idx, content), embedding in zip(all_chunks, embeddings):
            chunk = chunk_repo.create(document_id, page_num, idx, content)
            vector_repo.add(str(chunk.id), embedding, {
                "document_id": str(document_id),
                "page_number": page_num,
                "filename": document.filename,
            }, content)

        # 5. 완료
        document.status = DocumentStatus.COMPLETED
        document.page_count = len(text_pages)
        document.completed_at = datetime.utcnow()
        db.commit()

    except Exception as e:
        document.status = DocumentStatus.FAILED
        document.error_message = str(e)
        db.commit()
    finally:
        db.close()
```

```bash
$ cd projects/pdf_search_service/backend && pytest tests/api/test_documents.py tests/api/test_ocr_pipeline.py -v
PASSED test_유효한_PDF_업로드시_202_반환
PASSED test_PDF가_아닌_파일_업로드시_400_반환
PASSED test_50MB_초과_파일_업로드시_413_반환
PASSED test_PDF에서_텍스트_추출
PASSED test_텍스트_청킹_500토큰_기준
PASSED test_OCR_실패시_문서_상태_FAILED
```
→ 6개 전부 통과 (Green) ✅

---

#### 기능 2: 유사도 검색

##### 🔴 Red

파일: `backend/tests/api/test_search.py`

```python
class TestSearch:
    """유사도 검색 API 테스트"""

    def test_유효한_쿼리로_검색시_결과_반환(self, client, indexed_document):
        """Given: 벡터 DB에 인덱싱된 문서 존재
        When: POST /api/v1/search
        Then: 200 OK, 유사도 결과 반환"""
        response = client.post("/api/v1/search", json={
            "query": "문서에 포함된 키워드",
            "top_k": 3
        })

        assert response.status_code == 200
        data = response.json()
        assert len(data["results"]) <= 3
        assert all(0 <= r["score"] <= 1 for r in data["results"])
        assert all("content" in r for r in data["results"])

    def test_빈_쿼리로_검색시_422_반환(self, client):
        """Given: 빈 쿼리 문자열
        When: POST /api/v1/search
        Then: 422 Unprocessable Entity"""
        response = client.post("/api/v1/search", json={
            "query": "",
            "top_k": 5
        })

        assert response.status_code == 422

    def test_특정_문서_필터_검색(self, client, indexed_document):
        """Given: document_ids 필터 지정
        When: POST /api/v1/search
        Then: 해당 문서의 결과만 반환"""
        doc_id = str(indexed_document.id)
        response = client.post("/api/v1/search", json={
            "query": "검색어",
            "top_k": 5,
            "document_ids": [doc_id]
        })

        assert response.status_code == 200
        for result in response.json()["results"]:
            assert result["document_id"] == doc_id
```

→ 3개 실패 확인 (Red) ✅

##### 🟢 Green → 검색 구현

```python
# backend/src/api/services/search_service.py
class SearchService:
    def search(self, query: str, top_k: int, document_ids: list[UUID] | None) -> list:
        embedding_service = EmbeddingService()
        query_embedding = embedding_service.encode([query])[0]

        vector_repo = VectorRepository()
        where_filter = None
        if document_ids:
            where_filter = {"document_id": {"$in": [str(d) for d in document_ids]}}

        results = vector_repo.query(query_embedding, top_k, where_filter)
        return results
```

```bash
$ cd projects/pdf_search_service/backend && pytest tests/ -v
...
18 passed in 3.2s
```
→ 전체 통과 (Green) ✅

##### 🔵 Refactor → 정리 후 최종 확인

---

#### 기능별 TDD 사이클 요약 (Backend)

```
문서 업로드        → test_documents.py (3 tests) → routes/documents.py       ✅
OCR 파이프라인     → test_ocr_pipeline.py (3 tests) → workers/ocr_pipeline.py ✅
문서 목록/상세     → test_documents.py (+4 tests) → routes/documents.py       ✅
문서 삭제         → test_documents.py (+2 tests) → services/document_service ✅
검색             → test_search.py (3 tests) → routes/search.py              ✅
상태 조회        → test_documents.py (+1 test) → routes/documents.py         ✅
임베딩 서비스     → test_embedding.py (2 tests) → services/embedding_service  ✅
벡터 리포지토리   → test_vector_repo.py (3 tests) → repositories/vector_repo  ✅
```

**최종 백엔드 테스트:**
```bash
$ cd projects/pdf_search_service/backend && pytest --tb=short -q
21 passed in 4.1s ✅
```

---

### Phase 3b: Frontend Developer Agent (병렬 실행)

Backend와 **동시에** 실행됩니다. API 명세(`api-spec.md`)의 인터페이스를 기준으로 구현합니다.

#### 기능 1: 파일 업로드 UI

##### 🔴 Red

파일: `frontend/tests/components/FileDropzone.test.tsx`

```tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'
import { FileDropzone } from '@/components/FileDropzone'

describe('FileDropzone', () => {
  it('드래그 앤 드롭 영역이 렌더링된다', () => {
    render(<FileDropzone onUpload={vi.fn()} />)
    expect(screen.getByText(/PDF 파일을 드래그/)).toBeInTheDocument()
  })

  it('PDF가 아닌 파일 선택 시 에러 메시지 표시', async () => {
    const user = userEvent.setup()
    render(<FileDropzone onUpload={vi.fn()} />)

    const input = screen.getByLabelText(/파일 선택/)
    const file = new File(['hello'], 'test.txt', { type: 'text/plain' })
    await user.upload(input, file)

    expect(screen.getByText(/PDF 파일만/)).toBeInTheDocument()
  })

  it('업로드 중 프로그레스 표시', () => {
    render(<FileDropzone onUpload={vi.fn()} isUploading={true} />)
    expect(screen.getByRole('progressbar')).toBeInTheDocument()
  })
})
```

##### 🟢 Green → 컴포넌트 구현

```tsx
// frontend/src/components/FileDropzone.tsx
import { useDropzone } from 'react-dropzone'

export function FileDropzone({ onUpload, isUploading }: Props) {
  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    accept: { 'application/pdf': ['.pdf'] },
    maxSize: 50 * 1024 * 1024,
    onDropAccepted: (files) => onUpload(files[0]),
    onDropRejected: () => setError('PDF 파일만 업로드 가능합니다.'),
  })
  // ... 렌더링
}
```

---

#### 기능 2: 검색 UI

##### 🔴 Red

파일: `frontend/tests/components/SearchBar.test.tsx`

```tsx
describe('SearchBar', () => {
  it('검색어 입력 후 엔터 시 onSearch 호출', async () => {
    const user = userEvent.setup()
    const mockSearch = vi.fn()
    render(<SearchBar onSearch={mockSearch} />)

    await user.type(screen.getByRole('searchbox'), '계약서 내용 검색')
    await user.keyboard('{Enter}')

    expect(mockSearch).toHaveBeenCalledWith('계약서 내용 검색')
  })

  it('빈 검색어로 제출 시 onSearch 호출하지 않음', async () => {
    const user = userEvent.setup()
    const mockSearch = vi.fn()
    render(<SearchBar onSearch={mockSearch} />)

    await user.keyboard('{Enter}')

    expect(mockSearch).not.toHaveBeenCalled()
  })

  it('로딩 중일 때 스피너 표시', () => {
    render(<SearchBar onSearch={vi.fn()} isLoading={true} />)
    expect(screen.getByRole('status')).toBeInTheDocument()
  })
})
```

파일: `frontend/tests/components/SearchResultCard.test.tsx`

```tsx
describe('SearchResultCard', () => {
  it('검색 결과를 올바르게 표시한다', () => {
    const result = {
      chunk_id: 'uuid-1',
      document_id: 'doc-1',
      filename: '계약서.pdf',
      page_number: 3,
      content: '...계약 조건에 따라 갑은 을에게...',
      score: 0.87,
    }

    render(<SearchResultCard result={result} />)

    expect(screen.getByText('계약서.pdf')).toBeInTheDocument()
    expect(screen.getByText(/3페이지/)).toBeInTheDocument()
    expect(screen.getByText(/87%/)).toBeInTheDocument()
    expect(screen.getByText(/계약 조건/)).toBeInTheDocument()
  })
})
```

##### 🟢 Green → 컴포넌트 구현 → 통과 ✅

---

#### 프론트엔드 TDD 사이클 요약

```
FileDropzone     → FileDropzone.test.tsx (3 tests)     ✅
SearchBar        → SearchBar.test.tsx (3 tests)        ✅
SearchResultCard → SearchResultCard.test.tsx (1 test)  ✅
ProcessingStatus → ProcessingStatus.test.tsx (2 tests) ✅
useSearch Hook   → useSearch.test.ts (2 tests)         ✅
페이지 라우팅     → App.tsx (테스트 예외)                ✅
API 서비스       → api.ts (테스트 예외)                 ✅
```

**최종 프론트엔드 테스트:**
```bash
$ cd projects/pdf_search_service/frontend && npx vitest run
11 tests passed ✅
```

---

### Phase 3 Gate 검증 (두 에이전트 완료 후)

```
backend/tests/  존재?  ✅  (21 tests)
backend/src/    존재?  ✅  (15 files)
frontend/tests/ 존재?  ✅  (11 tests)
frontend/src/   존재?  ✅  (12 files)
pytest 통과?           ✅
vitest 통과?           ✅
→ Phase 4로 진행
```

사용자에게 보고:
```
💻 Phase 3 완료 (병렬 실행)
  3a (Backend):  21개 테스트, 15개 파일 — OCR 파이프라인, 검색 API, 문서 관리
  3b (Frontend): 11개 테스트, 12개 파일 — 업로드 UI, 검색 UI, 상태 표시
```

---

### Hook 동작 예시 — TDD 위반 차단

Backend Developer가 `embedding_service.py`를 테스트 없이 작성 시도:

```
tdd-guard.sh:
  파일: projects/pdf_search_service/backend/src/api/services/embedding_service.py
  대응 테스트: projects/pdf_search_service/backend/tests/api/test_embedding_service.py
  → 존재하지 않음 ❌

🔴 TDD violation: 테스트를 먼저 작성하세요!
구현 파일: .../backend/src/api/services/embedding_service.py
필요한 테스트: .../backend/tests/api/test_embedding_service.py

→ exit 2 (편집 차단)
```

### Hook 동작 예시 — 스펙 보호

Architect Agent가 아닌 다른 에이전트가 Phase 3 진행 중 `api-spec.md`를 수정 시도:

```
protect-specs.sh:
  파일: projects/pdf_search_service/docs/api/api-spec.md
  projects/pdf_search_service/backend/src/ 에 구현 파일 존재? → 있음

🔒 스펙 보호: Phase 2 이후 스펙 파일은 수정할 수 없습니다.

→ exit 2 (편집 차단)
```

---

## Phase 4: Review (Reviewer Agent)

### Reviewer Agent 5차원 리뷰 수행

모든 스펙 문서 3개를 읽고, `backend/src/`, `backend/tests/`, `frontend/src/`, `frontend/tests/`를 전수 검사합니다.

테스트 실행:
```bash
$ cd projects/pdf_search_service/backend && pytest --tb=short -q
21 passed ✅
$ cd projects/pdf_search_service/frontend && npx vitest run
11 tests passed ✅
```

**리뷰 결과:**

`projects/pdf_search_service/docs/reviews/review-report.md`:

```markdown
# 코드 리뷰 리포트

## 요약
- 리뷰 일시: 2026-02-21
- 대상: PDF 문서 검색 서비스
- 결과: REVIEW_FAILED

## 🔴 Critical 발견사항

### C-001: 파일 업로드 시 경로 순회 공격 취약점
- 위치: backend/src/api/services/document_service.py:23
- 설명: `file.filename`을 그대로 파일 저장 경로에 사용.
        공격자가 `../../etc/passwd` 같은 파일명을 전송하면
        의도하지 않은 경로에 파일 저장 가능.
- 스펙 근거: technical-spec.md 5절 "UUID 기반 경로, 원본 파일명 노출 방지"
- 권고: UUID 기반 파일명으로 저장, 원본 파일명은 DB에만 기록

### C-002: 임베딩 모델 미로딩 시 500 에러
- 위치: backend/src/api/services/embedding_service.py:8
- 설명: `SentenceTransformer` 로딩 실패(메모리 부족 등) 시
        에러 핸들링 없이 500 발생. 모든 검색/업로드가 마비됨.
- 권고: lifespan 이벤트에서 모델 로딩, 실패 시 앱 시작 거부

## 🟡 Warning 발견사항

### W-001: OCR 파이프라인에서 대용량 PDF 메모리 이슈
- 위치: backend/src/api/workers/ocr_pipeline.py:15
- 설명: `convert_from_path()`가 모든 페이지를 한번에 메모리에 로드.
        100페이지 PDF 시 OOM 가능.
- 권고: `first_page`/`last_page` 파라미터로 페이지별 순차 처리

### W-002: 프론트엔드 검색 결과에 XSS 가능성
- 위치: frontend/src/components/SearchResultCard.tsx:18
- 설명: `content`를 `dangerouslySetInnerHTML`로 렌더링.
        ChromaDB에 저장된 텍스트에 악의적 스크립트 포함 가능.
- 권고: React의 기본 이스케이프 사용 또는 DOMPurify 적용

### W-003: 문서 삭제 시 업로드 파일 미삭제
- 위치: backend/src/api/services/document_service.py:45
- 설명: DB 레코드와 벡터 DB에서는 삭제하지만 원본 PDF 파일 미삭제
- 권고: `os.remove(document.file_path)` 추가

## 🟢 Suggestion

### S-001: 검색 결과에 하이라이팅 적용
- 현재 원문 텍스트만 반환. 쿼리 키워드 위치를 볼드/마크 처리 제안.

### S-002: 처리 상태 폴링 대신 SSE(Server-Sent Events) 고려
- 현재 프론트엔드가 1초마다 status API 폴링. SSE로 변경하면 효율적.

## 차원별 평가
| 차원       | 점수        | 비고                              |
|-----------|------------|-----------------------------------|
| 스펙 준수  | ⭐⭐⭐⭐     | 핵심 기능 모두 구현, 파일 저장 방식 위배 |
| 보안       | ⭐⭐        | 경로 순회 취약점 (Critical)          |
| 성능       | ⭐⭐⭐       | 대용량 PDF 메모리 이슈              |
| 테스트     | ⭐⭐⭐⭐     | 주요 경로 커버, 보안 테스트 부족       |
| 코드 품질  | ⭐⭐⭐⭐     | 계층 분리 양호                      |
```

### Gate 검증
```
docs/reviews/review-report.md 존재? ✅
REVIEW_FAILED 마커? → 있음! 🔴
→ Phase 3 재실행 (1회차)
```

사용자에게 보고:
```
🔍 Phase 4 (Review) — FAILED
🔴 Critical 2건:
  C-001: 파일 업로드 경로 순회 공격 취약점 (백엔드)
  C-002: 임베딩 모델 로딩 실패 핸들링 없음 (백엔드)

→ Phase 3a(Backend)를 재실행하여 Critical 이슈를 수정합니다. (1/2회)
  ※ Critical이 모두 백엔드에 해당하므로 Frontend는 재실행하지 않습니다.
```

---

## Phase 3a 재실행 (1회차) — Backend만

### Backend Developer가 하는 일

리뷰 리포트의 Critical 2건을 읽고 **각각 TDD로 수정**합니다.

---

#### C-001 수정: 경로 순회 방지

##### 🔴 Red

```python
# backend/tests/api/test_documents.py 에 추가

def test_악의적_파일명으로_업로드시_UUID_경로_사용(self, client, tmp_path):
    """Given: 경로 순회 공격 파일명 ('../../etc/passwd')
    When: POST /api/v1/documents/upload
    Then: 202 반환, 파일은 UUID 기반 경로에 저장"""
    pdf_content = self._create_test_pdf()
    files = {"file": ("../../etc/passwd.pdf", pdf_content, "application/pdf")}

    response = client.post("/api/v1/documents/upload", files=files)

    assert response.status_code == 202
    data = response.json()
    # 파일명에 ../ 가 포함되지 않음
    assert ".." not in data.get("file_path", "")
    # DB에 원본 파일명만 기록
    assert data["filename"] == "../../etc/passwd.pdf"
```

##### 🟢 Green

```python
# backend/src/api/services/document_service.py 수정
import uuid

def create_document(self, original_filename: str, content: bytes) -> Document:
    # UUID 기반 안전한 파일 경로 생성
    safe_filename = f"{uuid.uuid4()}.pdf"
    file_path = os.path.join(UPLOAD_DIR, safe_filename)

    # 경로 정규화 + 허용 디렉토리 확인
    resolved = os.path.realpath(file_path)
    if not resolved.startswith(os.path.realpath(UPLOAD_DIR)):
        raise HTTPException(400, detail={"error": {"code": "VALIDATION_ERROR",
                                                    "message": "잘못된 파일 경로"}})

    with open(file_path, "wb") as f:
        f.write(content)

    document = Document(
        filename=original_filename,  # 원본 파일명은 DB에만 저장
        file_path=file_path,
        file_size=len(content),
        status=DocumentStatus.UPLOADING,
    )
    ...
```

---

#### C-002 수정: 임베딩 모델 lifespan 로딩

##### 🔴 Red

```python
# backend/tests/api/test_embedding.py 에 추가

def test_임베딩_모델_로딩_실패시_앱_시작_거부():
    """Given: 잘못된 모델명
    When: 앱 lifespan 이벤트
    Then: RuntimeError 발생"""
    with pytest.raises(RuntimeError, match="임베딩 모델"):
        embedding_service = EmbeddingService(model_name="nonexistent-model")
        embedding_service.load()
```

##### 🟢 Green

```python
# backend/src/api/main.py 수정
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 시작 시: 임베딩 모델 로딩
    try:
        app.state.embedding_service = EmbeddingService()
        app.state.embedding_service.load()
    except Exception as e:
        raise RuntimeError(f"임베딩 모델 로딩 실패: {e}")
    yield
    # 종료 시: 정리

app = FastAPI(title="PDF Search Service", lifespan=lifespan)
```

**최종 테스트:**
```bash
$ cd projects/pdf_search_service/backend && pytest --tb=short -q
24 passed in 4.8s ✅    ← 기존 21 + 신규 3 (보안 + 모델 로딩)
```

---

## Phase 4 재실행 — Reviewer 재리뷰

```markdown
# 코드 리뷰 리포트 (재리뷰)

## 요약
- 결과: PASSED ✅

## 🔴 Critical: 없음
- C-001: UUID 기반 파일 저장 + 경로 정규화 → 해결됨 ✅
- C-002: lifespan에서 모델 로딩 + 실패 시 앱 시작 거부 → 해결됨 ✅

## 🟡 Warning (3건, Integrator에서 처리)
- W-001: 대용량 PDF 페이지별 순차 처리 (미해결)
- W-002: dangerouslySetInnerHTML XSS (미해결)
- W-003: 문서 삭제 시 원본 파일 삭제 (미해결)

## 차원별 평가
| 차원       | 점수        |
|-----------|------------|
| 스펙 준수  | ⭐⭐⭐⭐⭐   |
| 보안       | ⭐⭐⭐⭐⭐   |
| 성능       | ⭐⭐⭐       |
| 테스트     | ⭐⭐⭐⭐⭐   |
| 코드 품질  | ⭐⭐⭐⭐     |
```

### Gate 검증
```
REVIEW_FAILED 마커 없음? ✅
→ Phase 5로 진행
```

---

## Phase 5: Integrate (Integrator Agent)

### Integrator Agent 실행 내용

#### 1. Warning 수정

**W-001**: 대용량 PDF 페이지별 순차 처리
```python
# backend/src/api/workers/ocr_pipeline.py 수정

# Before: images = convert_from_path(pdf_path)  ← 전체 로드
# After: 페이지별 순차 처리
page_count = get_page_count(pdf_path)
for page_num in range(1, page_count + 1):
    images = convert_from_path(pdf_path, first_page=page_num, last_page=page_num)
    text = pytesseract.image_to_string(images[0], lang="kor+eng")
    # ... 청킹/임베딩
```

**W-002**: XSS 제거
```tsx
// Before: <div dangerouslySetInnerHTML={{ __html: content }} />
// After:
<p className="result-content">{content}</p>
```

**W-003**: 파일 삭제 추가
```python
# backend/src/api/services/document_service.py
def delete_document(self, document_id: UUID):
    document = self.doc_repo.get(document_id)
    # 1. 원본 파일 삭제
    if os.path.exists(document.file_path):
        os.remove(document.file_path)
    # 2. 벡터 DB에서 삭제
    self.vector_repo.delete_by_document(document_id)
    # 3. DB 레코드 삭제 (Chunk → Document 순)
    self.chunk_repo.delete_by_document(document_id)
    self.doc_repo.delete(document_id)
```

#### 2. Docker 환경 구성

`projects/pdf_search_service/docker-compose.yml`:
```yaml
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile.api
    ports:
      - "8000:8000"
    env_file:
      - .env
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - uploads_data:/app/uploads
      - chroma_data:/app/chroma_db

  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    ports:
      - "3000:80"
    depends_on:
      - api

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${DB_USER:-app}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-secret}
      POSTGRES_DB: ${DB_NAME:-pdf_search}
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-app}"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  db_data:
  uploads_data:
  chroma_data:
```

`projects/pdf_search_service/Dockerfile.api`:
```dockerfile
FROM python:3.11-slim

# Tesseract + Poppler 시스템 패키지 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-kor \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .

# 업로드 디렉토리 생성
RUN mkdir -p /app/uploads /app/chroma_db

EXPOSE 8000
CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

`projects/pdf_search_service/Dockerfile.frontend`:
```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

#### 3. 문서화

`projects/pdf_search_service/README.md`:
```markdown
# PDF 문서 검색 서비스

PDF 파일을 업로드하면 OCR로 텍스트를 추출하고, 벡터 DB에 저장하여
자연어 기반 유사도 검색을 제공하는 서비스입니다.

## 실행 방법

### Docker Compose (권장)

    cp .env.example .env
    docker compose up --build

- 백엔드 API: http://localhost:8000
- 프론트엔드: http://localhost:3000
- API 문서 (Swagger): http://localhost:8000/docs

### API 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | /api/v1/documents/upload | PDF 업로드 |
| GET | /api/v1/documents | 문서 목록 조회 |
| GET | /api/v1/documents/{id} | 문서 상세 조회 |
| GET | /api/v1/documents/{id}/status | 처리 상태 조회 |
| DELETE | /api/v1/documents/{id} | 문서 삭제 |
| POST | /api/v1/search | 유사도 검색 |

## 기술 스택
- 백엔드: FastAPI + SQLAlchemy + ChromaDB + Tesseract OCR
- 프론트엔드: React + TypeScript + Vite
- 임베딩: sentence-transformers (all-MiniLM-L6-v2)
- DB: PostgreSQL (메타데이터) + ChromaDB (벡터)
```

`projects/pdf_search_service/.env.example`:
```
DATABASE_URL=postgresql://app:secret@db:5432/pdf_search
UPLOAD_DIR=/app/uploads
CHROMA_PERSIST_DIR=/app/chroma_db
EMBEDDING_MODEL=all-MiniLM-L6-v2
MAX_FILE_SIZE_MB=50
OCR_LANGUAGES=kor+eng
```

#### 4. 최종 통합 테스트

```bash
$ cd projects/pdf_search_service/backend && pytest --tb=short -q
24 passed in 4.8s ✅
$ cd projects/pdf_search_service/frontend && npx vitest run
11 tests passed ✅
```

---

## 최종 보고

```
✅ 파이프라인 완료: projects/pdf_search_service/

📋 Phase 1  (Research):   완료 — 12개 기능 요구사항 (P0: 8, P1: 4)
📐 Phase 2  (Architect):  완료 — 2 데이터 모델, 7 엔드포인트, OCR 파이프라인 설계
💻 Phase 3a (Backend):    완료 — 24개 테스트, 15개 파일
💻 Phase 3b (Frontend):   완료 — 11개 테스트, 12개 파일
   └─ 3a 재실행 1회 (경로 순회 취약점 + 모델 로딩 Critical 수정)
🔍 Phase 4  (Review):     통과 — Warning 3건 해결, Suggestion 2건
📦 Phase 5  (Integrate):  완료 — docker-compose.yml, Dockerfiles, README.md

🚀 실행 방법:
   cd projects/pdf_search_service
   cp .env.example .env
   docker compose up --build

   → 백엔드 API: http://localhost:8000
   → Swagger 문서: http://localhost:8000/docs
   → 프론트엔드: http://localhost:3000
```

---

## 전체 흐름 요약도

```
requirements-input.md (PDF → MD 변환)
         │
         ▼
  ┌──── Phase 1: Research (haiku) ──────┐
  │  Read 원본 → WebSearch 기술 조사     │
  │  → requirements.md (12개 기능)       │
  └──────────┬──────────────────────────┘
             │  Gate: requirements.md ✅
             ▼
  ┌──── Phase 2: Architect (sonnet) ────┐
  │  데이터 모델 + OCR 파이프라인 설계    │
  │  → technical-spec.md               │
  │  → api-spec.md (7 엔드포인트)       │
  └──────────┬──────────────────────────┘
             │  Gate: 2개 스펙 ✅
             │  🔒 스펙 동결 시작
             ▼
  ┌──── Phase 3a: Backend (opus) ───┐
  │  TDD: 업로드, OCR, 검색, 관리   │◄──┐
  │  → 24 tests + 15 files         │   │
  ├─────────────────────────────────┤   │ (병렬)
  │  Phase 3b: Frontend (sonnet)    │   │
  │  TDD: 드롭존, 검색바, 결과 카드  │   │
  │  → 11 tests + 12 files         │   │
  └──────────┬──────────────────────┘   │
             │  Gate: 전체 테스트 통과 ✅  │
             ▼                           │
  ┌──── Phase 4: Review (sonnet) ───┐   │
  │  5차원 리뷰                      │   │
  │  C-001: 경로 순회 취약점 🔴       │   │
  │  C-002: 모델 로딩 실패 🔴        │   │
  │  → REVIEW_FAILED ─── Yes ───────┘   │
  │                      (Backend만 재실행)
  └──────────┬───── 재리뷰 후 PASSED ✅  │
             │                           │
             ▼
  ┌──── Phase 5: Integrate (opus) ──┐
  │  W-001~003 수정                  │
  │  Docker Compose 구성             │
  │  (Tesseract + Poppler 포함)     │
  │  README + .env.example          │
  │  최종 35 tests passed           │
  └──────────┬──────────────────────┘
             │
             ▼
    docker compose up --build ✅
    → :8000 (API) + :3000 (UI) + :5432 (DB)
```
