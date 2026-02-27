# 코드 스타일 규칙

## Python (백엔드 - FastAPI)

### 네이밍
- **함수/변수**: `snake_case` (예: `get_user_by_id`, `access_token`)
- **클래스**: `PascalCase` (예: `UserService`, `AuthMiddleware`)
- **상수**: `UPPER_SNAKE_CASE` (예: `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE`)
- **모듈/파일**: `snake_case` (예: `user_service.py`, `auth_middleware.py`)

### Import 순서
1. 표준 라이브러리 (`os`, `sys`, `datetime`)
2. 서드파티 (`fastapi`, `sqlalchemy`, `pydantic`)
3. 로컬 모듈 (`from src.api import ...`)
4. 각 그룹 사이에 빈 줄 삽입

### 에러 핸들링
- FastAPI의 `HTTPException`을 사용하여 API 에러 반환
- 비즈니스 로직에서는 커스텀 예외 클래스 정의
- bare `except:` 사용 금지, 항상 구체적인 예외 타입 지정
- 에러 로깅 시 `logger.exception()` 사용

### 타입 힌트
- 모든 함수 시그니처에 타입 힌트 필수
- `Optional[T]` 대신 `T | None` 사용 (Python 3.10+)
- Pydantic 모델로 요청/응답 스키마 정의

## React (프론트엔드)

### 네이밍
- **컴포넌트**: `PascalCase` (예: `UserProfile`, `LoginForm`)
- **함수/변수**: `camelCase` (예: `handleSubmit`, `isLoading`)
- **상수**: `UPPER_SNAKE_CASE` (예: `API_BASE_URL`)
- **파일**: 컴포넌트는 `PascalCase.tsx`, 유틸은 `camelCase.ts`

### JSX 규약
- 함수형 컴포넌트만 사용 (class 컴포넌트 금지)
- props는 구조 분해 할당으로 받기
- 조건부 렌더링은 삼항 연산자 또는 `&&` 사용
- 이벤트 핸들러는 `handle` 접두사 (예: `handleClick`, `handleSubmit`)

### 상태 관리
- 로컬 상태: `useState`, `useReducer`
- 서버 상태: React Query 또는 SWR 사용 권장
- 전역 상태: Context API (작은 규모) 또는 Zustand (큰 규모)

### Tailwind 운영 규칙
- 페이지별 임의 width/padding 금지 → ContentContainer와 공통 래퍼에서만 관리
- 커스텀 토큰 최소화 (tailwind.config.ts에 brand color, radius, shadow만)
- 인터랙션 애니메이션은 공통 클래스/유틸로만 제공
- 페이지별 개별 애니메이션 구현 금지

### 자산 네이밍 규칙
- 아이콘: SVG, currentColor 우선, `ic_{name}_{size}.svg` (크기: 16/20/24)
- 이미지: `img_{feature}_{name}.png`
- 저장 경로: `src/assets/`
