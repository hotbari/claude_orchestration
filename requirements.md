 # 프로젝트 요구사항: MH OCR AI

## 개요
- **프로젝트명**: MH OCR AI
- **Figma URL**: https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq/MH-OCR-AI
- **기술 스택**: React 18 + TypeScript + Vite (Frontend) / FastAPI + Python 3.11 (Backend)
- **생성 방식**: AI 자동 생성 (Figma 분석 기반)
- **주요 기능**: OCR 추출, 파일 관리, 통계 제공, 문서 템플릿 관리

### 테스트용 계정 정보

**관리자 계정:**
- 이메일: `admin@mhocr.com`
- 비밀번호: `Admin1234!`
- 역할: `ADMIN`
- 권한: 모든 기능 접근 가능 (설정, 시스템 로그, 사용자 권한 관리 포함)

**일반 사용자 계정:**
- 이메일: `user@mhocr.com`
- 비밀번호: `User1234!`
- 역할: `USER`
- 권한: 파일 관리, OCR 실행, 대시보드 조회 (설정 페이지 접근 불가)

**참고:**
- 테스트 환경에서는 회원가입 기능을 비활성화하고 위 하드코딩된 계정만 사용
- 프로덕션 환경에서는 회원가입 기능 활성화 및 RBAC 적용

---

## 페이지: AI OCR & LLM Extraction Landing Page

**메타데이터**
- **URL**: /
- **Figma Frame**: AI OCR & LLM Extraction Landing Page
- **인증 필요**: No

**페이지 설명**
MH OCR AI 서비스를 소개하는 랜딩 페이지. 서비스의 주요 기능과 장점을 설명하고 사용자를 로그인/회원가입으로 유도합니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "시작하기" CTA 버튼 | /files로 이동 (파일 관리 페이지) | 로그인 안 되어 있으면 /login으로 리다이렉트 |
| "로그인" 링크 (Header) | /login으로 이동 | 미인증 시에만 표시 |
| "대시보드" 링크 (Header) | /dashboard로 이동 | 인증 시에만 표시 |

---

## 페이지: Login

**메타데이터**
- **URL**: /login
- **Figma Frame**: (별도 Frame 없음, 표준 로그인 폼)
- **인증 필요**: No

**페이지 설명**
사용자 로그인 페이지. 이메일과 비밀번호를 입력받아 JWT 토큰을 발급받습니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "로그인" 버튼 | POST /api/auth/login → /files로 이동 | 폼 검증 통과 시 |
| "비밀번호 표시" 아이콘 | 비밀번호 텍스트 표시/숨김 토글 | - |
| "홈으로" 링크 | /로 이동 | - |

---

## 페이지: File Management & OCR Trigger

**메타데이터**
- **URL**: /files
- **Figma Frame**: File Management & OCR Trigger
- **인증 필요**: Yes

**페이지 설명**
업로드된 파일 목록을 조회하고 OCR 처리를 시작할 수 있는 메인 파일 관리 페이지입니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "새 파일 업로드" 버튼 | /files/upload로 이동 | - |
| "버전 업데이트" 버튼 | /files/:id/version으로 이동 | 파일 선택 시 활성화 |
| 파일 카드 클릭 | /files/:id/result로 이동 (상세 페이지) | - |
| "편집" 버튼 (파일 카드) | /files/:id/edit로 이동 | - |
| "삭제" 버튼 (파일 카드) | 삭제 확인 모달 표시 | - |
| 검색 입력 | GET /api/files?search={query} 호출 | 입력 후 디바운스 |
| 상태 필터 (드롭다운) | GET /api/files?status={status} 호출 | 선택 변경 시 |
| 페이지네이션 버튼 | GET /api/files?skip={offset}&limit=20 호출 | - |

---

## 페이지: File Management & New File Upload Start

**메타데이터**
- **URL**: /files/upload
- **Figma Frame**: File Management & New File Upload Start
- **인증 필요**: Yes

**페이지 설명**
드래그 앤 드롭 또는 파일 선택을 통해 새 파일을 업로드하는 페이지입니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "파일 선택" 버튼 | 파일 선택 다이얼로그 표시 | - |
| 드래그 앤 드롭 영역 | 파일 드롭 시 업로드 시작 | 파일 검증 통과 시 |
| "업로드" 버튼 | POST /api/files → /files로 이동 | 파일 선택 후 활성화 |
| "취소" 버튼 | /files로 이동 | - |

**파일 검증:**
- 허용 형식: PDF, PNG, JPG, JPEG, TIF, TIFF
- 최대 크기: 10MB

---

## 페이지: File Management & Version Update_File Select

**메타데이터**
- **URL**: /files/:id/version
- **Figma Frame**: File Management & Version Update_File Select
- **인증 필요**: Yes

**페이지 설명**
기존 파일의 새 버전을 업로드하는 페이지입니다. 버전 번호는 자동으로 증가합니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "파일 선택" 버튼 | 파일 선택 다이얼로그 표시 | - |
| "버전 업로드" 버튼 | POST /api/files/{id}/versions → /files로 이동 | 파일 선택 후 활성화 |
| "취소" 버튼 | /files로 이동 | - |

---

## 페이지: Edit File Metadata

**메타데이터**
- **URL**: /files/:id/edit
- **Figma Frame**: Edit File Metadata
- **인증 필요**: Yes

**페이지 설명**
파일의 메타데이터(제목, 설명, 태그)를 수정하는 페이지입니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "저장" 버튼 | PATCH /api/files/{id} → /files로 이동 | 변경 사항 있을 때 활성화 |
| "취소" 버튼 | /files로 이동 | - |

---

## 페이지: OCR Detailed Result Viewer

**메타데이터**
- **URL**: /files/:id/result
- **Figma Frame**: OCR Detailed Result Viewer
- **인증 필요**: Yes

**페이지 설명**
OCR 처리 결과를 상세하게 보여주는 페이지입니다. 원본 이미지, 추출된 텍스트, 구조화된 데이터, 좌표 정보를 탭으로 구분하여 표시합니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "Original Image" 탭 | 원본 이미지 표시 | - |
| "Text Result" 탭 | 추출된 텍스트 표시 | OCR 완료 시 |
| "Structured Data" 탭 | JSON 형식 데이터 표시 | OCR 완료 시 |
| "Coordinates" 탭 | 좌표 정보 표시 | OCR 완료 시 |
| "복사" 버튼 | 클립보드에 복사 | 각 탭에 존재 |
| "다운로드" 버튼 | 파일로 다운로드 (txt, json) | 각 탭에 존재 |
| "뒤로" 버튼 | /files로 이동 | - |

---

## 페이지: Analytics Dashboard Overview

**메타데이터**
- **URL**: /dashboard
- **Figma Frame**: Analytics Dashboard Overview
- **인증 필요**: Yes

**페이지 설명**
파일 처리 통계를 시각화하여 보여주는 대시보드 페이지입니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "오늘" 버튼 | GET /api/analytics?period=today 호출 | - |
| "이번 주" 버튼 | GET /api/analytics?period=week 호출 | - |
| "이번 달" 버튼 | GET /api/analytics?period=month 호출 | - |
| 통계 카드 (총 파일 수) | /files로 이동 | - |
| 통계 카드 (완료) | /files?status=COMPLETED로 이동 | - |
| 통계 카드 (처리 중) | /files?status=PROCESSING로 이동 | - |
| 통계 카드 (실패) | /files?status=FAILED로 이동 | - |
| 최근 파일 항목 클릭 | /files/:id/result로 이동 | - |

---

## 페이지: Analytics Dashboard Sub Main

**메타데이터**
- **URL**: /dashboard/details
- **Figma Frame**: Analytics Dashboard Sub Main
- **인증 필요**: Yes

**페이지 설명**
상세 통계 정보를 보여주는 서브 대시보드 페이지입니다.

---

## 페이지: Settings & Data Management

**메타데이터**
- **URL**: /settings
- **Figma Frame**: Settings & Data Management
- **인증 필요**: Yes (Admin만)

**페이지 설명**
시스템 설정 및 데이터 관리 페이지입니다. 관리자만 접근 가능합니다.

**인터랙션 명세**

| 버튼/링크 설명 | 클릭하면 어디로? | 조건 |
|----------------|------------------|------|
| "Document Templates" 탭 | 문서 템플릿 설정 표시 | - |
| "OCR Engine" 탭 | OCR 엔진 설정 표시 | - |
| "User Permissions" 탭 | 사용자 권한 관리 표시 | - |
| "System Logs" 탭 | 시스템 로그 표시 | - |
| "저장" 버튼 | PUT /api/settings → 설정 저장 | 변경 사항 있을 때 활성화 |
| "취소" 버튼 | 변경 사항 되돌리기 | - |

---

## 페이지: 시스템 사용이력 상세 조회

**메타데이터**
- **URL**: /logs/:id
- **Figma Frame**: 시스템 사용이력 상세 조회
- **인증 필요**: Yes (Admin만)

**페이지 설명**
특정 로그 항목의 상세 정보를 조회하는 페이지입니다.

---

## 모달: file initialize confirm

**Figma Frame**: file initialize confirm

**사용 시점**: 파일 초기화 시 확인

**인터랙션 명세**

| 버튼/링크 설명 | 동작 |
|----------------|------|
| "확인" 버튼 | POST /api/files/{id}/initialize → 모달 닫기 |
| "취소" 버튼 | 모달 닫기 |

---

## 모달: file delete confirm

**Figma Frame**: file delete confirm

**사용 시점**: 파일 삭제 시 확인

**인터랙션 명세**

| 버튼/링크 설명 | 동작 |
|----------------|------|
| "삭제" 버튼 | DELETE /api/files/{id} → 모달 닫기 → /files로 이동 |
| "취소" 버튼 | 모달 닫기 |

---

## 컴포넌트: 상태별 토스트 메시지 시스템

**Figma Frame**: 상태별 토스트 메시지 시스템 디자인

**사용 시점**: 성공/에러/정보 메시지 표시

**상태 종류:**
- Success (초록색)
- Error (빨간색)
- Warning (노란색)
- Info (파란색)

---

## API 엔드포인트 요구사항

### 1. 인증 API

#### POST /api/auth/login
- 요청: `{ email: string, password: string }`
- 응답: `{ access_token: string, refresh_token: string, user: UserResponse }`
- 테스트 계정으로 검증

#### POST /api/auth/refresh
- 요청: `{ refresh_token: string }`
- 응답: `{ access_token: string }`

#### GET /api/auth/me
- 응답: `UserResponse`
- 헤더: `Authorization: Bearer {access_token}`

### 2. 파일 관리 API

#### POST /api/files
- 요청: `multipart/form-data` (file)
- 응답: `FileUploadResponse` (201)
- 검증: 파일 형식, 크기

#### GET /api/files
- 쿼리: `skip`, `limit`, `status`, `search`
- 응답: `FileListResponse` (페이지네이션)

#### GET /api/files/{id}
- 응답: `FileDetailResponse`

#### PATCH /api/files/{id}
- 요청: `{ title?: string, description?: string, tags?: string[] }`
- 응답: `FileResponse`

#### DELETE /api/files/{id}
- 응답: 204

#### POST /api/files/{id}/versions
- 요청: `multipart/form-data` (file)
- 응답: 201

### 3. OCR API

#### POST /api/files/{id}/ocr
- OCR 처리 시작 (BackgroundTask)
- 응답: 202

#### GET /api/files/{id}/ocr/result
- OCR 결과 조회
- 응답: `OCRResultResponse`

### 4. 통계 API

#### GET /api/analytics
- 쿼리: `period` (today, week, month)
- 응답: `AnalyticsResponse`

### 5. 설정 API

#### GET /api/settings
- 응답: `SettingsResponse`
- 권한: Admin만

#### PUT /api/settings
- 요청: `SettingsUpdateRequest`
- 응답: `SettingsResponse`
- 권한: Admin만

### 6. 로그 API

#### GET /api/logs
- 쿼리: `skip`, `limit`
- 응답: `LogListResponse`
- 권한: Admin만

#### GET /api/logs/{id}
- 응답: `LogDetailResponse`
- 권한: Admin만

---

## 데이터 모델

### User
- id: UUID
- email: string
- hashed_password: string
- role: enum (USER, ADMIN)
- created_at: datetime

### File
- id: UUID
- user_id: UUID
- filename: string
- original_filename: string
- file_path: string
- file_size: int
- mime_type: string
- status: enum (PENDING, PROCESSING, COMPLETED, FAILED)
- version: int
- parent_file_id: UUID | null
- title: string | null
- description: string | null
- tags: list[string]
- created_at: datetime
- updated_at: datetime

### OCRResult
- id: UUID
- file_id: UUID
- text_result: string
- structured_data: JSON
- coordinates: JSON
- confidence: float
- processing_time: float
- created_at: datetime

### Analytics
- period: enum (TODAY, WEEK, MONTH)
- total_files: int
- completed_files: int
- processing_files: int
- failed_files: int
- avg_processing_time: float
