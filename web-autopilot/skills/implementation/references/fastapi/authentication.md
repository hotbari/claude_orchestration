# 인증 패턴

**목적**: JWT 기반 인증 및 OAuth2 Password Flow 구현

---

## JWT 유틸리티

```python
# core/security.py
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from typing import Optional
from core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """비밀번호 해싱"""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """비밀번호 검증"""
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(
    data: dict,
    expires_delta: Optional[timedelta] = None
) -> str:
    """JWT 액세스 토큰 생성"""
    to_encode = data.copy()
    expire = datetime.utcnow() + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def decode_access_token(token: str) -> Optional[dict]:
    """JWT 토큰 디코드"""
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError:
        return None
```

## OAuth2 Password Flow

```python
# api/dependencies.py
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from core.security import decode_access_token
from services.user_service import get_user
from api.dependencies import get_db

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/v1/auth/token")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
):
    """현재 인증된 사용자 가져오기"""
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
    if not user:
        raise credentials_exception

    return user
```

## 로그인 엔드포인트

```python
# api/v1/endpoints/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta

from api.dependencies import get_db
from core.security import verify_password, create_access_token
from core.config import settings
from repositories.user_repository import UserRepository

router = APIRouter()

@router.post("/token")
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """로그인 및 토큰 발급"""
    # 사용자 조회
    user = await UserRepository.get_by_email(db, form_data.username)

    # 인증 실패
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 토큰 생성
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(user.id)},
        expires_delta=access_token_expires
    )

    return {
        "access_token": access_token,
        "token_type": "bearer"
    }
```

## 보호된 엔드포인트

```python
# api/v1/endpoints/users.py
from fastapi import APIRouter, Depends
from api.dependencies import get_current_user
from models.user import User

router = APIRouter()

@router.get("/me")
async def read_current_user(current_user: User = Depends(get_current_user)):
    """현재 사용자 정보 조회"""
    return current_user

@router.put("/me")
async def update_current_user(
    updates: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """현재 사용자 정보 수정"""
    return await user_service.update_user(db, current_user.id, updates)
```

## 설정 (core/config.py)

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    SECRET_KEY: str = "CHANGE-THIS-IN-PRODUCTION"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    class Config:
        env_file = ".env"
```

## 클라이언트 사용 예제

```bash
# 로그인
curl -X POST "http://localhost:8000/api/v1/auth/token" \
  -d "username=user@example.com&password=Password123"

# 응답: {"access_token": "eyJ...", "token_type": "bearer"}

# 보호된 엔드포인트 접근
curl -X GET "http://localhost:8000/api/v1/users/me" \
  -H "Authorization: Bearer eyJ..."
```

## 장점

✅ **표준 준수**: OAuth2 Password Flow 사용
✅ **무상태**: JWT로 서버 세션 불필요
✅ **자동 문서화**: OpenAPI의 "Authorize" 버튼 자동 생성
✅ **확장 가능**: 권한(scope) 추가 용이

## 보안 주의사항

⚠️ **SECRET_KEY는 반드시 환경변수로 관리**
⚠️ **HTTPS 사용 필수 (프로덕션)**
⚠️ **토큰 만료 시간 적절히 설정**
⚠️ **비밀번호 정책 엄격히 적용**

## 참고

- [dependency-injection.md](./dependency-injection.md) - 인증 의존성
- [error-handling.md](./error-handling.md) - 인증 실패 처리
