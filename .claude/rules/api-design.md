# API 설계 규칙

> 적용 경로: src/api/**, docs/api/**

## RESTful 규약

### URL 설계
- 리소스는 복수형 명사 사용: `/users`, `/posts`, `/comments`
- 계층 관계: `/users/{user_id}/posts`
- 동사 사용 금지 (예: `/getUser` → `/users/{id}`)
- kebab-case 사용: `/user-profiles` (snake_case 아님)
- API 버전: `/api/v1/...`

### HTTP 메서드
| 메서드 | 용도 | 응답 코드 |
|--------|------|-----------|
| GET | 리소스 조회 | 200 |
| POST | 리소스 생성 | 201 |
| PUT | 리소스 전체 수정 | 200 |
| PATCH | 리소스 부분 수정 | 200 |
| DELETE | 리소스 삭제 | 204 |

## FastAPI 구현 패턴

### Router 구조
```python
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter(prefix="/api/v1/users", tags=["users"])

@router.get("/", response_model=list[UserResponse])
async def list_users(
    skip: int = 0,
    limit: int = Query(default=20, le=100),
    db: Session = Depends(get_db),
):
    ...
```

### Pydantic 스키마
```python
# 요청 스키마
class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    name: str = Field(min_length=1, max_length=100)

# 응답 스키마 (비밀번호 제외)
class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
```

## 에러 응답 포맷

모든 에러는 일관된 JSON 구조로 반환:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "입력 데이터가 유효하지 않습니다.",
    "details": [
      {
        "field": "email",
        "message": "유효한 이메일 형식이 아닙니다."
      }
    ]
  }
}
```

### 에러 코드 체계
- `VALIDATION_ERROR`: 입력 검증 실패 (422)
- `NOT_FOUND`: 리소스 없음 (404)
- `UNAUTHORIZED`: 인증 필요 (401)
- `FORBIDDEN`: 권한 부족 (403)
- `CONFLICT`: 리소스 충돌 (409)
- `INTERNAL_ERROR`: 서버 내부 에러 (500)

## 페이지네이션

### Offset 기반 (기본)
```
GET /api/v1/users?skip=0&limit=20

응답:
{
  "items": [...],
  "total": 100,
  "skip": 0,
  "limit": 20
}
```

### 파라미터
- `skip`: 시작 위치 (기본값: 0)
- `limit`: 페이지 크기 (기본값: 20, 최대: 100)
- `sort_by`: 정렬 기준 필드
- `order`: `asc` 또는 `desc` (기본값: `asc`)

## 응답 헤더
- `Content-Type: application/json`
- 목록 응답에 `X-Total-Count` 헤더 포함
- CORS 헤더 적절히 설정
