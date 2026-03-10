# 오류 처리

**목적**: 비즈니스 로직과 HTTP 응답 분리, 일관된 오류 응답

---

## 사용자 정의 예외

```python
# services/exceptions.py
class UserNotFoundError(Exception):
    """Raised when a user cannot be found"""
    pass

class DuplicateEmailError(Exception):
    """Raised when email already exists"""
    pass

class InsufficientPermissionsError(Exception):
    """Raised when user lacks permissions"""
    pass

class InvalidCredentialsError(Exception):
    """Raised when authentication fails"""
    pass
```

## 서비스 레이어에서 사용

```python
# services/user_service.py
from services.exceptions import UserNotFoundError, DuplicateEmailError
from repositories.user_repository import UserRepository
from sqlalchemy.orm import Session
from schemas.user import UserCreate

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

## 예외 핸들러 등록

```python
# api/exception_handlers.py
from fastapi import Request
from fastapi.responses import JSONResponse
from services.exceptions import (
    UserNotFoundError,
    DuplicateEmailError,
    InsufficientPermissionsError,
    InvalidCredentialsError
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

    @app.exception_handler(InvalidCredentialsError)
    async def invalid_credentials_handler(request: Request, exc: InvalidCredentialsError):
        return JSONResponse(
            status_code=401,
            content={"detail": str(exc)},
            headers={"WWW-Authenticate": "Bearer"}
        )
```

## main.py에서 등록

```python
# main.py
from fastapi import FastAPI
from api.exception_handlers import register_exception_handlers

app = FastAPI()
register_exception_handlers(app)
```

## 장점

✅ **비즈니스 로직 독립성**: 서비스 레이어가 HTTP를 몰라도 됨
✅ **재사용성**: 같은 예외를 여러 엔드포인트에서 사용
✅ **테스트 용이**: 서비스 레이어 테스트 시 HTTP 없이 예외만 확인
✅ **일관성**: 모든 오류가 동일한 형식으로 응답

## 에러 응답 형식

```json
{
  "detail": "User 123 not found"
}
```

## 참고

- [architecture.md](./architecture.md) - 레이어별 책임
- [testing.md](./testing.md) - 예외 테스트
