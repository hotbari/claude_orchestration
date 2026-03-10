# Pydantic 유효성 검사

**목적**: 런타임 타입 안전성, 자동 OpenAPI 문서화, 명확한 오류 메시지

---

## 스키마 정의

```python
# schemas/user.py
from pydantic import BaseModel, EmailStr, constr, validator, Field
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
        from_attributes = True  # Pydantic v2: formerly orm_mode
```

## 엔드포인트에서 자동 검증

```python
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from api.dependencies import get_db
from schemas.user import UserCreate, UserUpdate, UserResponse
from services import user_service

router = APIRouter()

@router.post("/users", response_model=UserResponse)
async def create_user(
    user: UserCreate,  # 자동 유효성 검사
    db: Session = Depends(get_db)
):
    return await user_service.create_user(db, user)

@router.patch("/users/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    updates: UserUpdate,  # 부분 업데이트 OK
    db: Session = Depends(get_db)
):
    return await user_service.update_user(db, user_id, updates)
```

## Field 제약 조건

```python
from pydantic import BaseModel, Field

class ProductCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    price: float = Field(..., gt=0, description="Must be positive")
    stock: int = Field(default=0, ge=0, description="Non-negative")
```

## 커스텀 Validator

```python
from pydantic import BaseModel, validator

class UserCreate(BaseModel):
    username: str
    email: str
    age: int

    @validator('username')
    def username_alphanumeric(cls, v):
        assert v.isalnum(), 'must be alphanumeric'
        return v

    @validator('age')
    def age_must_be_adult(cls, v):
        if v < 18:
            raise ValueError('must be 18 or older')
        return v
```

## 유효성 검사 에러 응답

잘못된 요청 시 FastAPI가 자동으로 응답:

```json
{
  "detail": [
    {
      "loc": ["body", "password"],
      "msg": "Password must contain uppercase letter",
      "type": "value_error"
    }
  ]
}
```

## 장점

✅ **런타임 타입 안전**: 요청 데이터가 스키마와 일치하는지 자동 검증
✅ **자동 문서화**: OpenAPI/Swagger 문서 자동 생성
✅ **명확한 오류**: 어떤 필드가 잘못됐는지 정확히 알려줌
✅ **중앙화**: 유효성 검사 로직을 스키마에 집중

## 참고

- [error-handling.md](./error-handling.md) - 유효성 검사 실패 처리
- [testing.md](./testing.md) - 스키마 테스트
