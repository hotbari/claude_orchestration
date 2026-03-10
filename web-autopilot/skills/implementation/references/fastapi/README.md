# FastAPI 구현 패턴

**목적**: 깔끔하고 테스트 가능한 FastAPI 백엔드를 위한 표준 패턴 모음

## 📚 패턴 목록

1. **[architecture.md](./architecture.md)** - Clean 3-Layer 아키텍처
2. **[dependency-injection.md](./dependency-injection.md)** - 의존성 주입 패턴
3. **[error-handling.md](./error-handling.md)** - 오류 처리 및 예외 관리
4. **[validation.md](./validation.md)** - Pydantic 유효성 검사
5. **[database.md](./database.md)** - SQLAlchemy + Repository 패턴
6. **[authentication.md](./authentication.md)** - JWT 인증 구현
7. **[testing.md](./testing.md)** - 테스트 패턴 및 픽스처
8. **[crud-example.md](./crud-example.md)** - 완전한 CRUD 예제

## 💡 사용법

각 패턴은 독립적으로 참조 가능하며, 프로젝트 요구사항에 따라 선택적으로 적용할 수 있습니다.

**권장 적용 순서**:
1. Architecture → 프로젝트 구조 설정
2. Dependency Injection → DI 설정
3. Database → 모델 및 Repository 구현
4. Validation → 스키마 정의
5. Error Handling → 예외 처리 설정
6. Authentication → 인증 구현 (필요시)
7. Testing → 테스트 작성

## 🎯 핵심 원칙

- **레이어 분리**: API → Service → Repository
- **의존성 주입**: Depends()로 느슨한 결합
- **타입 안전성**: Pydantic으로 런타임 검증
- **테스트 가능**: 모든 레이어 독립적 테스트
