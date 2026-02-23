# 테스트 작성 템플릿

> 경로 기준: `projects/{project-name}/`

## Python 백엔드 (pytest + FastAPI)

### conftest.py (backend/tests/conftest.py)
```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from src.api.main import app
from src.api.database import Base, get_db

# 테스트용 인메모리 SQLite
SQLALCHEMY_DATABASE_URL = "sqlite://"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(autouse=True)
def setup_db():
    """각 테스트 전에 DB 테이블 생성, 후에 삭제"""
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def db():
    """테스트용 DB 세션"""
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture
def client(db):
    """테스트용 FastAPI 클라이언트"""
    def override_get_db():
        try:
            yield db
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()
```

### API 엔드포인트 테스트 패턴
```python
# backend/tests/api/test_[리소스].py

class TestCreate[Resource]:
    """[리소스] 생성 API 테스트"""

    def test_유효한_데이터로_생성하면_201_반환(self, client):
        """Given: 유효한 요청 데이터
        When: POST /api/v1/[리소스]
        Then: 201 Created + 생성된 리소스 반환"""
        # Given
        data = {"field1": "값", "field2": 42}

        # When
        response = client.post("/api/v1/[리소스]", json=data)

        # Then
        assert response.status_code == 201
        result = response.json()
        assert result["field1"] == "값"
        assert "id" in result

    def test_필수_필드_누락시_422_반환(self, client):
        """Given: 필수 필드가 누락된 데이터
        When: POST /api/v1/[리소스]
        Then: 422 Unprocessable Entity"""
        # Given
        data = {}

        # When
        response = client.post("/api/v1/[리소스]", json=data)

        # Then
        assert response.status_code == 422


class TestList[Resource]:
    """[리소스] 목록 조회 API 테스트"""

    def test_빈_목록_조회시_빈_배열_반환(self, client):
        """Given: 데이터 없음
        When: GET /api/v1/[리소스]
        Then: 200 OK + 빈 items"""
        response = client.get("/api/v1/[리소스]")

        assert response.status_code == 200
        result = response.json()
        assert result["items"] == []
        assert result["total"] == 0

    def test_페이지네이션_동작_확인(self, client):
        """Given: N개의 리소스 존재
        When: GET /api/v1/[리소스]?skip=0&limit=5
        Then: 최대 5개 반환"""
        # Given: 데이터 생성 (fixture 또는 직접 생성)
        ...

        # When
        response = client.get("/api/v1/[리소스]?skip=0&limit=5")

        # Then
        assert response.status_code == 200
        result = response.json()
        assert len(result["items"]) <= 5
```

### 서비스 레이어 테스트 패턴
```python
# backend/tests/services/test_[서비스].py

class Test[Service]Service:
    """[서비스] 비즈니스 로직 테스트"""

    def test_정상_동작(self, db):
        """Given: [전제조건]
        When: [동작]
        Then: [기대결과]"""
        # Given
        service = [Service]Service(db)

        # When
        result = service.some_method(arg)

        # Then
        assert result == expected
```

## React 프론트엔드 (Vitest + React Testing Library)

### 컴포넌트 테스트 패턴
```typescript
// frontend/tests/components/[Component].test.tsx

import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect, vi } from 'vitest'
import { [Component] } from '@/components/[Component]'

describe('[Component]', () => {
  it('올바르게 렌더링된다', () => {
    // Given & When
    render(<[Component] />)

    // Then
    expect(screen.getByRole('...'))toBeInTheDocument()
  })

  it('사용자가 [동작]하면 [결과]한다', async () => {
    // Given
    const user = userEvent.setup()
    const mockHandler = vi.fn()
    render(<[Component] onAction={mockHandler} />)

    // When
    await user.click(screen.getByRole('button', { name: '...' }))

    // Then
    expect(mockHandler).toHaveBeenCalledOnce()
  })

  it('에러 상태를 표시한다', () => {
    // Given & When
    render(<[Component] error="에러 메시지" />)

    // Then
    expect(screen.getByText('에러 메시지')).toBeInTheDocument()
  })
})
```

### Hook 테스트 패턴
```typescript
// frontend/tests/hooks/use[Hook].test.ts

import { renderHook, act } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import { use[Hook] } from '@/hooks/use[Hook]'

describe('use[Hook]', () => {
  it('초기 상태가 올바르다', () => {
    const { result } = renderHook(() => use[Hook]())

    expect(result.current.value).toBe(initialValue)
  })

  it('[동작] 시 상태가 업데이트된다', () => {
    const { result } = renderHook(() => use[Hook]())

    act(() => {
      result.current.action(arg)
    })

    expect(result.current.value).toBe(expectedValue)
  })
})
```
