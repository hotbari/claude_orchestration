# Dependency Injection

**목적**: 느슨한 결합, 테스트 가능성, 재사용성

---

## 데이터베이스 세션 주입

```python
# core/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from typing import Generator

SQLALCHEMY_DATABASE_URL = "sqlite:///./app.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# api/dependencies.py
def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

## 엔드포인트에서 사용

```python
# api/v1/endpoints/users.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from api.dependencies import get_db
from services import user_service
from schemas.user import UserCreate, UserResponse

router = APIRouter()

@router.post("/users", response_model=UserResponse)
async def create_user(
    user: UserCreate,
    db: Session = Depends(get_db)
):
    return await user_service.create_user(db, user)
```

## 다른 의존성 패턴

### 현재 사용자 가져오기

```python
# api/dependencies.py
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    # 토큰 검증 및 사용자 조회
    user = verify_token_and_get_user(token, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )
    return user
```

### 관리자 권한 확인

```python
async def get_current_admin_user(
    current_user = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
    return current_user
```

### 페이지네이션 파라미터

```python
from typing import Optional

async def pagination_params(
    skip: int = 0,
    limit: int = 100
):
    return {"skip": skip, "limit": limit}

@router.get("/users")
async def list_users(
    pagination: dict = Depends(pagination_params),
    db: Session = Depends(get_db)
):
    return await user_service.list_users(
        db,
        skip=pagination["skip"],
        limit=pagination["limit"]
    )
```

## 장점

✅ **테스트 용이**: 의존성을 쉽게 모킹
✅ **재사용성**: 공통 로직을 의존성으로 추출
✅ **가독성**: 엔드포인트 시그니처가 명확
✅ **타입 안전**: FastAPI가 자동으로 타입 검증

## 참고

- [authentication.md](./authentication.md) - 인증 의존성 구현
- [testing.md](./testing.md) - 의존성 오버라이드
