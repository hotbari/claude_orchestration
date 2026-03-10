# Clean 3-Layer 아키텍처

**목적**: 관심사 분리, 독립 테스트, 확장 가능성

---

## 디렉토리 구조

```
app/
├── api/                    # API Layer
│   ├── v1/
│   │   ├── endpoints/
│   │   │   ├── users.py
│   │   │   └── products.py
│   │   └── router.py
│   └── dependencies.py
├── services/               # Business Logic
│   ├── user_service.py
│   └── product_service.py
├── repositories/           # Data Access
│   ├── user_repository.py
│   └── product_repository.py
├── models/                 # SQLAlchemy
│   └── user.py
├── schemas/                # Pydantic
│   └── user.py
└── core/
    ├── config.py
    ├── security.py
    └── database.py
```

## 레이어 책임

### 1. API Layer (`api/`)
- HTTP 요청/응답 처리
- 라우팅 및 엔드포인트 정의
- 요청 유효성 검사 (Pydantic)
- 인증/인가 적용

### 2. Service Layer (`services/`)
- 비즈니스 로직
- 데이터 변환 및 검증
- 여러 Repository 조율
- 비즈니스 예외 처리

### 3. Repository Layer (`repositories/`)
- 데이터베이스 쿼리
- CRUD 작업
- 데이터 모델과 상호작용

## 장점

✅ **관심사 분리**: 각 레이어가 명확한 책임을 가짐
✅ **테스트 용이**: 각 레이어를 독립적으로 테스트
✅ **확장 가능**: 새 기능 추가 시 영향 범위 최소화
✅ **유지보수**: 변경사항이 특정 레이어에 국한됨

## 데이터 흐름

```
Request → API → Service → Repository → Database
                    ↓
Response ← API ← Service ← Repository ← Database
```

## 참고

- [dependency-injection.md](./dependency-injection.md) - 레이어 간 의존성 주입
- [database.md](./database.md) - Repository 패턴 구현
- [error-handling.md](./error-handling.md) - 레이어별 예외 처리
