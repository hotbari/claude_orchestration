# 데이터베이스 패턴

**목적**: SQLAlchemy 모델 + Repository 패턴으로 데이터 액세스 추상화

---

## SQLAlchemy 모델

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

## Repository 패턴

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
        from core.security import hash_password

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

## 서비스 레이어

```python
# services/user_service.py
from sqlalchemy.orm import Session
from repositories.user_repository import UserRepository
from schemas.user import UserCreate, UserUpdate
from services.exceptions import UserNotFoundError, DuplicateEmailError
from typing import List

async def get_user(db: Session, user_id: int):
    user = await UserRepository.get(db, user_id)
    if not user:
        raise UserNotFoundError(f"User {user_id} not found")
    return user

async def list_users(
    db: Session,
    skip: int = 0,
    limit: int = 100
) -> List:
    return await UserRepository.get_multi(db, skip, limit)

async def create_user(db: Session, user_data: UserCreate):
    # 비즈니스 로직: 이메일 중복 확인
    existing = await UserRepository.get_by_email(db, user_data.email)
    if existing:
        raise DuplicateEmailError(f"Email already exists")

    return await UserRepository.create(db, user_data)

async def update_user(db: Session, user_id: int, updates: UserUpdate):
    user = await get_user(db, user_id)
    update_dict = updates.dict(exclude_unset=True)

    # 비즈니스 로직: 이메일 변경 시 중복 확인
    if 'email' in update_dict:
        existing = await UserRepository.get_by_email(db, update_dict['email'])
        if existing and existing.id != user_id:
            raise DuplicateEmailError("Email already in use")

    return await UserRepository.update(db, user, update_dict)
```

## 장점

✅ **관심사 분리**: 데이터 액세스 로직이 Repository에 캡슐화
✅ **테스트 용이**: Repository만 모킹하면 서비스 테스트 가능
✅ **재사용성**: 같은 쿼리를 여러 서비스에서 재사용
✅ **유지보수**: DB 구조 변경 시 Repository만 수정

## 참고

- [architecture.md](./architecture.md) - 3-layer 구조
- [dependency-injection.md](./dependency-injection.md) - DB 세션 주입
- [crud-example.md](./crud-example.md) - 전체 CRUD 구현 예제
