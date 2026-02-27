# 테스트 규칙

> 적용 경로: tests/**, *.test.*, *.spec.*

## 공통 원칙

- **TDD 필수**: 구현 전에 반드시 실패하는 테스트를 먼저 작성
- **Red-Green-Refactor**: 실패(Red) → 최소 구현으로 통과(Green) → 리팩토링(Refactor)
- **테스트 격리**: 각 테스트는 독립적으로 실행 가능해야 함
- **Given-When-Then**: 테스트 구조를 명확히 구분
- **한 테스트 한 검증**: 하나의 테스트는 하나의 동작만 검증

## Python 백엔드 (pytest)

### 구조
```
tests/
├── api/
│   ├── conftest.py          # 공통 fixture
│   ├── test_auth.py         # 인증 API 테스트
│   └── test_users.py        # 사용자 API 테스트
├── services/
│   └── test_user_service.py # 서비스 레이어 테스트
└── conftest.py              # 루트 fixture
```

### Fixture 패턴
- `conftest.py`에 공통 fixture 정의
- `@pytest.fixture`로 테스트 데이터 생성
- FastAPI `TestClient` 사용하여 API 테스트
- 데이터베이스: 테스트용 SQLite in-memory 또는 테스트 DB

### 네이밍
- 테스트 파일: `test_*.py`
- 테스트 함수: `test_[대상]_[시나리오]_[기대결과]`
- 예: `test_create_user_with_valid_data_returns_201`

### 필수 테스트 유형
- **단위 테스트**: 서비스 레이어, 유틸리티 함수
- **통합 테스트**: API 엔드포인트 (TestClient)
- **에러 케이스**: 잘못된 입력, 인증 실패, 권한 부족

## React 프론트엔드 (Vitest)

### 구조
```
tests/
└── frontend/
    ├── components/
    │   └── LoginForm.test.tsx
    ├── hooks/
    │   └── useAuth.test.ts
    └── setup.ts             # 테스트 환경 설정
```

### React Testing Library 원칙
- 구현 세부사항이 아닌 사용자 행동 기준 테스트
- `getByRole`, `getByText` 등 접근성 쿼리 우선 사용
- `getByTestId`는 최후의 수단
- `userEvent` 사용하여 사용자 인터랙션 시뮬레이션

### 네이밍
- 테스트 파일: `*.test.tsx` 또는 `*.test.ts`
- describe 블록: 컴포넌트/훅 이름
- it/test 블록: 사용자 관점 동작 기술

### 필수 테스트 유형
- **렌더링 테스트**: 컴포넌트가 올바르게 렌더링되는지
- **인터랙션 테스트**: 사용자 입력, 클릭 등
- **상태 변화 테스트**: 상태 변경 후 UI 업데이트
- **에러 상태 테스트**: 에러 메시지 표시

## 커버리지

- 목표: 핵심 비즈니스 로직 80% 이상
- 필수: 모든 API 엔드포인트, 인증/인가 로직
- 선택: UI 컴포넌트 (핵심 흐름만)
