# FastAPI 구현 패턴

**목적**: 깔끔하고 테스트 가능한 FastAPI 백엔드를 위한 표준 패턴

---

## 1. Clean 3-Layer 아키텍처

### 디렉토리 구조

```
app/
├── api/                    # API Layer (FastAPI routes)
│   ├── v1/
│   │   ├── endpoints/
│   │   │   ├── users.py
│   │   │   ├── auth.py
│   │   │   └── products.py
│   │   └── router.py
│   └── dependencies.py
├── services/               # Business Logic Layer
│   ├── user_service.py
│   ├── auth_service.py
│   └── product_service.py
├── repositories/           # Data Access Layer
│   ├── user_repository.py
│   └── product_repository.py
├── models/                 # SQLAlchemy Models
│   ├── user.py
│   └── product.py
├── schemas/                # Pydantic Schemas
│   ├── user.py
│   └── product.py
└── core/                   # Core utilities
    ├── config.py
    ├── security.py
    └── database.py
```

### 장점

- 명확한 관심사 분리
- 각 레이어를 독립적으로 테스트하기 쉬움
- 확장 가능 (비즈니스 로직 변경이 API에 영향을 주지 않음)

---

## 2. Dependency Injection

### 데이터베이스 세션 관리

```python
# core/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

SQLALCHEMY_DATABASE_URL = "sqlite:///./app.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# api/dependencies.py
from typing import Generator
from core.database import SessionLocal

def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### 엔드포인트에서 사용

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

---

## 3. 오류 처리

### 사용자 정의 예외

```python
# services/exceptions.py
class UserNotFoundError(Exception):
    """Raised when a user cannot be found"""
    pass

class DuplicateEmailError(Exception):
    """Raised when trying to create a user with existing email"""
    pass

class InsufficientPermissionsError(Exception):
    """Raised when user lacks required permissions"""
    pass
```

### 서비스 레이어 구현

```python
# services/user_service.py
from services.exceptions import UserNotFoundError, DuplicateEmailError
from repositories.user_repository import UserRepository

async def get_user(db: Session, user_id: int):
    user = await UserRepository.get(db, user_id)
    if not user:
        raise UserNotFoundError(f"User {user_id} not found")
    return user

async def create_user(db: Session, user_data: UserCreate):
    existing = await UserRepository.get_by_email(db, user_data.email)
    if existing:
        raise DuplicateEmailError(f"Email {user_data.email} already exists")
    return await UserRepository.create(db, user_data)
```

### 예외 핸들러

```python
# api/exception_handlers.py
from fastapi import Request
from fastapi.responses import JSONResponse
from services.exceptions import (
    UserNotFoundError,
    DuplicateEmailError,
    InsufficientPermissionsError
)

def register_exception_handlers(app):
    @app.exception_handler(UserNotFoundError)
    async def user_not_found_handler(request: Request, exc: UserNotFoundError):
        return JSONResponse(
            status_code=404,
            content={"detail": str(exc)}
        )

    @app.exception_handler(DuplicateEmailError)
    async def duplicate_email_handler(request: Request, exc: DuplicateEmailError):
        return JSONResponse(
            status_code=409,
            content={"detail": str(exc)}
        )

    @app.exception_handler(InsufficientPermissionsError)
    async def permission_handler(request: Request, exc: InsufficientPermissionsError):
        return JSONResponse(
            status_code=403,
            content={"detail": str(exc)}
        )

# main.py
from fastapi import FastAPI
from api.exception_handlers import register_exception_handlers

app = FastAPI()
register_exception_handlers(app)
```

### 장점

- 비즈니스 로직이 HTTP 관련 사항과 독립적으로 유지됨
- 엔드포인트 간 높은 재사용성
- 테스트하기 쉬움

---

## 4. Pydantic을 사용한 유효성 검사

### 스키마 정의

```python
# schemas/user.py
from pydantic import BaseModel, EmailStr, constr, validator
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    username: constr(min_length=3, max_length=50)

class UserCreate(UserBase):
    password: constr(min_length=8, max_length=100)

    @validator('password')
    def validate_password(cls, v):
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain uppercase letter')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain digit')
        return v

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[constr(min_length=3, max_length=50)] = None

class UserResponse(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True  # formerly orm_mode
```

### 자동 유효성 검사

```python
# api/v1/endpoints/users.py
@router.post("/users", response_model=UserResponse)
async def create_user(
    user: UserCreate,  # Automatically validated
    db: Session = Depends(get_db)
):
    return await user_service.create_user(db, user)

@router.patch("/users/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    updates: UserUpdate,  # Automatically validated, partial OK
    db: Session = Depends(get_db)
):
    return await user_service.update_user(db, user_id, updates)
```

### 장점

- 런타임 타입 안전성
- 자동 생성된 OpenAPI 문서
- 명확하고 유익한 오류 메시지
- 스키마에 유효성 검사 로직 중앙화

---

## 5. 데이터베이스 패턴

### SQLAlchemy 모델

```python
# models/user.py
from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
```

### Repository 패턴

```python
# repositories/user_repository.py
from sqlalchemy.orm import Session
from models.user import User
from schemas.user import UserCreate
from typing import Optional, List

class UserRepository:
    @staticmethod
    async def get(db: Session, user_id: int) -> Optional[User]:
        return db.query(User).filter(User.id == user_id).first()

    @staticmethod
    async def get_by_email(db: Session, email: str) -> Optional[User]:
        return db.query(User).filter(User.email == email).first()

    @staticmethod
    async def get_multi(
        db: Session,
        skip: int = 0,
        limit: int = 100
    ) -> List[User]:
        return db.query(User).offset(skip).limit(limit).all()

    @staticmethod
    async def create(db: Session, user: UserCreate) -> User:
        db_user = User(
            email=user.email,
            username=user.username,
            hashed_password=hash_password(user.password)
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user

    @staticmethod
    async def update(db: Session, user: User, updates: dict) -> User:
        for key, value in updates.items():
            setattr(user, key, value)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    async def delete(db: Session, user: User) -> None:
        db.delete(user)
        db.commit()
```

### 서비스 레이어 로직

```python
# services/user_service.py
from sqlalchemy.orm import Session
from repositories.user_repository import UserRepository
from schemas.user import UserCreate, UserUpdate
from services.exceptions import UserNotFoundError
from typing import List

async def get_user(db: Session, user_id: int):
    user = await UserRepository.get(db, user_id)
    if not user:
        raise UserNotFoundError(f"User {user_id} not found")
    return user

async def list_users(db: Session, skip: int = 0, limit: int = 100) -> List:
    return await UserRepository.get_multi(db, skip, limit)

async def create_user(db: Session, user_data: UserCreate):
    # Business logic here
    existing = await UserRepository.get_by_email(db, user_data.email)
    if existing:
        raise DuplicateEmailError(f"Email already exists")

    return await UserRepository.create(db, user_data)

async def update_user(db: Session, user_id: int, updates: UserUpdate):
    user = await get_user(db, user_id)

    # Business logic here
    update_dict = updates.dict(exclude_unset=True)
    if 'email' in update_dict:
        existing = await UserRepository.get_by_email(db, update_dict['email'])
        if existing and existing.id != user_id:
            raise DuplicateEmailError("Email already in use")

    return await UserRepository.update(db, user, update_dict)
```

---

## 6. 인증 패턴

### JWT 구현

```python
# core/security.py
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from typing import Optional

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_access_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None
```

### OAuth2 Password Flow

```python
# api/dependencies.py
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from core.security import decode_access_token
from services.user_service import get_user

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception

    user_id: int = payload.get("sub")
    if user_id is None:
        raise credentials_exception

    user = await get_user(db, user_id)
    return user
```

### 인증 엔드포인트

```python
# api/v1/endpoints/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from api.dependencies import get_db
from core.security import verify_password, create_access_token
from repositories.user_repository import UserRepository

router = APIRouter()

@router.post("/token")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    user = await UserRepository.get_by_email(db, form_data.username)
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "token_type": "bearer"}
```

---

## 7. 테스트 패턴

### 테스트 설정

```python
# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from api.dependencies import get_db
from main import app

SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture
def db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture
def client(db):
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

### 엔드포인트 테스트

```python
# tests/test_users.py
def test_create_user(client):
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
    # Create user first
    user = create_test_user(db, email="test@example.com")

    response = client.get(f"/api/v1/users/{user.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "test@example.com"
```

### 종속성 모킹

```python
# tests/test_services.py
from unittest.mock import AsyncMock, patch
import pytest

@pytest.mark.asyncio
async def test_get_user_not_found(db):
    with patch('repositories.user_repository.UserRepository.get') as mock_get:
        mock_get.return_value = None

        with pytest.raises(UserNotFoundError):
            await user_service.get_user(db, 999)
```

---

## 8. 완전한 CRUD 예제

### 모델

```python
# models/product.py
from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from core.database import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    price = Column(Float, nullable=False)
    stock = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
```

### 스키마

```python
# schemas/product.py
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class ProductBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None
    price: float = Field(..., gt=0)
    stock: int = Field(default=0, ge=0)

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    price: Optional[float] = Field(None, gt=0)
    stock: Optional[int] = Field(None, ge=0)

class ProductResponse(ProductBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
```

### Repository

```python
# repositories/product_repository.py
from sqlalchemy.orm import Session
from models.product import Product
from schemas.product import ProductCreate
from typing import Optional, List

class ProductRepository:
    @staticmethod
    async def get(db: Session, product_id: int) -> Optional[Product]:
        return db.query(Product).filter(Product.id == product_id).first()

    @staticmethod
    async def get_multi(db: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        return db.query(Product).offset(skip).limit(limit).all()

    @staticmethod
    async def create(db: Session, product: ProductCreate) -> Product:
        db_product = Product(**product.dict())
        db.add(db_product)
        db.commit()
        db.refresh(db_product)
        return db_product

    @staticmethod
    async def update(db: Session, product: Product, updates: dict) -> Product:
        for key, value in updates.items():
            setattr(product, key, value)
        db.commit()
        db.refresh(product)
        return product

    @staticmethod
    async def delete(db: Session, product: Product) -> None:
        db.delete(product)
        db.commit()
```

### 서비스

```python
# services/product_service.py
from sqlalchemy.orm import Session
from repositories.product_repository import ProductRepository
from schemas.product import ProductCreate, ProductUpdate
from services.exceptions import ProductNotFoundError

async def get_product(db: Session, product_id: int):
    product = await ProductRepository.get(db, product_id)
    if not product:
        raise ProductNotFoundError(f"Product {product_id} not found")
    return product

async def list_products(db: Session, skip: int = 0, limit: int = 100):
    return await ProductRepository.get_multi(db, skip, limit)

async def create_product(db: Session, product_data: ProductCreate):
    return await ProductRepository.create(db, product_data)

async def update_product(db: Session, product_id: int, updates: ProductUpdate):
    product = await get_product(db, product_id)
    update_dict = updates.dict(exclude_unset=True)
    return await ProductRepository.update(db, product, update_dict)

async def delete_product(db: Session, product_id: int):
    product = await get_product(db, product_id)
    await ProductRepository.delete(db, product)
```

### API 엔드포인트

```python
# api/v1/endpoints/products.py
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from api.dependencies import get_db
from schemas.product import ProductCreate, ProductUpdate, ProductResponse
from services import product_service

router = APIRouter(prefix="/products", tags=["products"])

@router.get("", response_model=List[ProductResponse])
async def list_products(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    return await product_service.list_products(db, skip, limit)

@router.post("", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    product: ProductCreate,
    db: Session = Depends(get_db)
):
    return await product_service.create_product(db, product)

@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: int,
    db: Session = Depends(get_db)
):
    return await product_service.get_product(db, product_id)

@router.patch("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: int,
    updates: ProductUpdate,
    db: Session = Depends(get_db)
):
    return await product_service.update_product(db, product_id, updates)

@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: int,
    db: Session = Depends(get_db)
):
    await product_service.delete_product(db, product_id)
```

---

## 요약

이러한 패턴은 다음을 제공합니다:

1. **Clean Architecture**: 명확한 레이어 분리
2. **Dependency Injection**: 유연하고 테스트 가능한 종속성
3. **오류 처리**: HTTP 매핑이 있는 비즈니스 로직 예외
4. **유효성 검사**: 타입 안전, 자동 문서화된 유효성 검사
5. **데이터베이스**: 서비스 레이어가 있는 Repository 패턴
6. **인증**: JWT + OAuth2 보안
7. **테스트**: 모의 종속성이 있는 TestClient
8. **완전한 예제**: 전체 CRUD 구현

일관되고 유지 관리 가능한 FastAPI 애플리케이션을 위한 템플릿으로 사용하십시오.
