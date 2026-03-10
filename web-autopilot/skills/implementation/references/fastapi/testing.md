# 테스트 패턴

**목적**: TestClient + pytest로 API 및 비즈니스 로직 테스트

---

## 테스트 설정 (conftest.py)

```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from core.database import Base
from api.dependencies import get_db
from main import app

# 테스트용 인메모리 DB
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture
def db():
    """테스트용 DB 세션"""
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture
def client(db):
    """TestClient with overridden dependencies"""
    def override_get_db():
        try:
            yield db
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
```

## 엔드포인트 테스트

```python
# tests/test_users.py
def test_create_user(client):
    """사용자 생성 테스트"""
    response = client.post(
        "/api/v1/users",
        json={
            "email": "test@example.com",
            "username": "testuser",
            "password": "Test1234"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data

def test_get_user(client, db):
    """사용자 조회 테스트"""
    # 테스트 사용자 생성
    user = create_test_user(db, email="test@example.com")

    # 조회
    response = client.get(f"/api/v1/users/{user.id}")
    assert response.status_code == 200
    assert response.json()["email"] == "test@example.com"

def test_create_user_duplicate_email(client, db):
    """중복 이메일 테스트"""
    # 첫 번째 사용자
    client.post(
        "/api/v1/users",
        json={"email": "test@example.com", "username": "user1", "password": "Pass1234"}
    )

    # 같은 이메일로 재시도
    response = client.post(
        "/api/v1/users",
        json={"email": "test@example.com", "username": "user2", "password": "Pass1234"}
    )
    assert response.status_code == 409  # Conflict
```

## 서비스 레이어 테스트 (모킹)

```python
# tests/test_services.py
from unittest.mock import patch, AsyncMock
import pytest
from services import user_service
from services.exceptions import UserNotFoundError

@pytest.mark.asyncio
async def test_get_user_not_found(db):
    """존재하지 않는 사용자 조회"""
    with patch('repositories.user_repository.UserRepository.get') as mock_get:
        mock_get.return_value = None

        with pytest.raises(UserNotFoundError):
            await user_service.get_user(db, 999)

@pytest.mark.asyncio
async def test_create_user_duplicate_email(db):
    """중복 이메일로 사용자 생성"""
    from schemas.user import UserCreate

    with patch('repositories.user_repository.UserRepository.get_by_email') as mock:
        mock.return_value = {"id": 1, "email": "test@example.com"}

        with pytest.raises(DuplicateEmailError):
            await user_service.create_user(
                db,
                UserCreate(email="test@example.com", username="test", password="Pass1234")
            )
```

## 인증 테스트

```python
# tests/test_auth.py
def test_login_success(client, db):
    """로그인 성공"""
    # 사용자 생성
    create_test_user(db, email="test@example.com", password="Pass1234")

    # 로그인
    response = client.post(
        "/api/v1/auth/token",
        data={"username": "test@example.com", "password": "Pass1234"}
    )
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_login_wrong_password(client, db):
    """잘못된 비밀번호"""
    create_test_user(db, email="test@example.com", password="Pass1234")

    response = client.post(
        "/api/v1/auth/token",
        data={"username": "test@example.com", "password": "WrongPass"}
    )
    assert response.status_code == 401

def test_protected_endpoint_no_token(client):
    """토큰 없이 보호된 엔드포인트 접근"""
    response = client.get("/api/v1/users/me")
    assert response.status_code == 401
```

## 테스트 헬퍼

```python
# tests/utils.py
from models.user import User
from core.security import hash_password

def create_test_user(db, email="test@example.com", password="Pass1234"):
    """테스트용 사용자 생성"""
    user = User(
        email=email,
        username=email.split("@")[0],
        hashed_password=hash_password(password)
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user
```

## 실행

```bash
# 모든 테스트 실행
pytest

# 특정 파일만
pytest tests/test_users.py

# 커버리지 확인
pytest --cov=app --cov-report=html
```

## 장점

✅ **독립성**: 각 테스트가 독립된 DB 사용
✅ **빠른 실행**: 인메모리 SQLite 사용
✅ **의존성 오버라이드**: FastAPI의 DI 시스템 활용
✅ **모킹**: unittest.mock으로 외부 의존성 제거

## 참고

- [dependency-injection.md](./dependency-injection.md) - 의존성 오버라이드
- [error-handling.md](./error-handling.md) - 예외 테스트
