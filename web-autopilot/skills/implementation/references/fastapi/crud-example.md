# 완전한 CRUD 예제 (Product)

**목적**: 전체 레이어를 아우르는 실전 예제

---

## 1. 모델 (models/product.py)

```python
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

## 2. 스키마 (schemas/product.py)

```python
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

## 3. Repository (repositories/product_repository.py)

```python
from sqlalchemy.orm import Session
from models.product import Product
from schemas.product import ProductCreate
from typing import Optional, List

class ProductRepository:
    @staticmethod
    async def get(db: Session, product_id: int) -> Optional[Product]:
        return db.query(Product).filter(Product.id == product_id).first()

    @staticmethod
    async def get_multi(
        db: Session,
        skip: int = 0,
        limit: int = 100
    ) -> List[Product]:
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

## 4. 서비스 (services/product_service.py)

```python
from sqlalchemy.orm import Session
from repositories.product_repository import ProductRepository
from schemas.product import ProductCreate, ProductUpdate
from services.exceptions import ProductNotFoundError
from typing import List

async def get_product(db: Session, product_id: int):
    """상품 조회"""
    product = await ProductRepository.get(db, product_id)
    if not product:
        raise ProductNotFoundError(f"Product {product_id} not found")
    return product

async def list_products(
    db: Session,
    skip: int = 0,
    limit: int = 100
) -> List:
    """상품 목록 조회"""
    return await ProductRepository.get_multi(db, skip, limit)

async def create_product(db: Session, product_data: ProductCreate):
    """상품 생성"""
    return await ProductRepository.create(db, product_data)

async def update_product(
    db: Session,
    product_id: int,
    updates: ProductUpdate
):
    """상품 수정"""
    product = await get_product(db, product_id)
    update_dict = updates.dict(exclude_unset=True)
    return await ProductRepository.update(db, product, update_dict)

async def delete_product(db: Session, product_id: int):
    """상품 삭제"""
    product = await get_product(db, product_id)
    await ProductRepository.delete(db, product)
```

## 5. API 엔드포인트 (api/v1/endpoints/products.py)

```python
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
    """상품 목록 조회"""
    return await product_service.list_products(db, skip, limit)

@router.post(
    "",
    response_model=ProductResponse,
    status_code=status.HTTP_201_CREATED
)
async def create_product(
    product: ProductCreate,
    db: Session = Depends(get_db)
):
    """상품 생성"""
    return await product_service.create_product(db, product)

@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: int,
    db: Session = Depends(get_db)
):
    """상품 조회"""
    return await product_service.get_product(db, product_id)

@router.patch("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: int,
    updates: ProductUpdate,
    db: Session = Depends(get_db)
):
    """상품 수정"""
    return await product_service.update_product(db, product_id, updates)

@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: int,
    db: Session = Depends(get_db)
):
    """상품 삭제"""
    await product_service.delete_product(db, product_id)
```

## 6. 라우터 등록 (api/v1/api.py)

```python
from fastapi import APIRouter
from api.v1.endpoints import products

api_router = APIRouter()
api_router.include_router(products.router)
```

## 사용 예제

```bash
# 생성
curl -X POST "http://localhost:8000/api/v1/products" \
  -H "Content-Type: application/json" \
  -d '{"name": "Laptop", "price": 999.99, "stock": 10}'

# 목록 조회
curl "http://localhost:8000/api/v1/products"

# 단일 조회
curl "http://localhost:8000/api/v1/products/1"

# 수정
curl -X PATCH "http://localhost:8000/api/v1/products/1" \
  -H "Content-Type: application/json" \
  -d '{"price": 899.99}'

# 삭제
curl -X DELETE "http://localhost:8000/api/v1/products/1"
```

## 참고

이 예제는 다음 패턴들을 통합합니다:

- [architecture.md](./architecture.md) - 3-layer 구조
- [database.md](./database.md) - Repository 패턴
- [validation.md](./validation.md) - Pydantic 스키마
- [error-handling.md](./error-handling.md) - 예외 처리
- [dependency-injection.md](./dependency-injection.md) - DI
