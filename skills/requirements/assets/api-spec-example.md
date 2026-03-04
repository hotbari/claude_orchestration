# API 명세서 - 간단한 블로그 플랫폼

**버전**: 1.0
**최종 업데이트**: 2024-02-01

## 개요

간단한 블로그 플랫폼을 위한 RESTful API로, 사용자 인증, 블로그 게시물 관리 및 콘텐츠 검색을 위한 엔드포인트를 제공합니다. API는 REST 규칙을 따르고, 모든 요청/응답 본문에 JSON을 사용하며, 보호된 엔드포인트에 대해 JWT 기반 인증을 구현합니다.

## Base URL

- **개발**: `http://localhost:3000/api/v1`
- **스테이징**: `https://staging-api.simpleblog.com/api/v1`
- **프로덕션**: `https://api.simpleblog.com/api/v1`

## 인증

**방법**: JWT Bearer Token

**세부사항**:
- 등록 및 로그인 엔드포인트는 JWT 액세스 토큰과 리프레시 토큰을 반환
- 보호된 엔드포인트에 대해 `Authorization: Bearer {token}` 헤더에 액세스 토큰 포함
- 액세스 토큰은 1시간 후 만료
- 리프레시 토큰은 7일 후 만료
- 재인증 없이 새 액세스 토큰을 얻기 위해 리프레시 토큰 사용

**Token Expiry**:
- Access Token: 1 hour (3600 seconds)
- Refresh Token: 7 days (604800 seconds)

**Example**:
```http
GET /api/v1/posts/my-posts
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NTY3ODkwIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

## 공통 응답 형식

### 성공 응답

```json
{
  "success": true,
  "data": {
    // 리소스 데이터
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### 목록 응답 (페이지네이션 포함)

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 10,
      "total": 45,
      "total_pages": 5
    }
  }
}
```

### 오류 응답

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "잘못된 요청 매개변수",
    "details": [
      {
        "field": "email",
        "message": "잘못된 이메일 형식"
      }
    ]
  }
}
```

## 표준 오류 코드

| HTTP Status | Error Code | 설명 |
|-------------|------------|-------------|
| 400 | BAD_REQUEST | 잘못된 요청 형식 또는 매개변수 |
| 401 | UNAUTHORIZED | 인증 토큰 누락 또는 잘못됨 |
| 403 | FORBIDDEN | 사용자에게 이 작업에 대한 권한 없음 |
| 404 | NOT_FOUND | 리소스를 찾을 수 없음 |
| 409 | CONFLICT | 리소스 충돌 (예: 중복 이메일) |
| 422 | VALIDATION_ERROR | 요청 검증 실패 |
| 429 | RATE_LIMIT_EXCEEDED | 너무 많은 요청 (속도 제한 참조) |
| 500 | INTERNAL_ERROR | 서버 오류 (지원팀에 문의) |
| 503 | SERVICE_UNAVAILABLE | 서비스 일시적으로 사용 불가 |

## Rate Limiting

API implements rate limiting to prevent abuse:

**Limits:**
- Authentication endpoints: 5 requests per 15 minutes per IP
- Authenticated endpoints: 100 requests per minute per user
- Public endpoints: 20 requests per minute per IP

**Response Headers:**
- `X-RateLimit-Limit`: Maximum requests allowed
- `X-RateLimit-Remaining`: Requests remaining in window
- `X-RateLimit-Reset`: Unix timestamp when limit resets

**When Exceeded:**
- HTTP 429 Too Many Requests
- Retry after time indicated in `Retry-After` header (seconds)

---

## 엔드포인트

### 인증

---

#### POST /auth/register

새 사용자 계정 생성.

**인증**: 필요하지 않음

**요청 본문**:

| 필드 | 타입 | 필수 | 검증 | 설명 |
|-------|------|----------|------------|-------------|
| email | string | Yes | Valid email format | 사용자 이메일 주소 |
| password | string | Yes | min:8, contains uppercase, lowercase, number | 계정 비밀번호 |
| name | string | Yes | min:2, max:50 | 사용자 전체 이름 |
| blogName | string | No | max:50 | 블로그 제목 (기본값: "{name}'s Blog") |

**Example Request**:
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123",
  "name": "John Doe",
  "blogName": "John's Tech Blog"
}
```

**Response**: `201 Created`
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr_1234567890",
      "email": "john@example.com",
      "name": "John Doe",
      "blogName": "John's Tech Blog",
      "emailVerified": false,
      "createdAt": "2024-01-15T10:00:00Z"
    },
    "message": "Verification email sent to john@example.com"
  }
}
```

**Error Responses**:
- `409 Conflict`: Email already registered
- `422 Validation Error`: Invalid input (weak password, invalid email)

---

#### POST /auth/login

Authenticate user and receive JWT tokens.

**Authentication**: Not required

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User email address |
| password | string | Yes | User password |

**Example Request**:
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "usr_1234567890",
      "email": "john@example.com",
      "name": "John Doe",
      "emailVerified": true
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid email or password
- `403 Forbidden`: Email not verified (includes resend verification link)
- `429 Too Many Requests`: Rate limit exceeded (5 attempts per 15 min)

---

#### POST /auth/refresh

Obtain new access token using refresh token.

**Authentication**: Not required (uses refresh token in body)

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| refreshToken | string | Yes | Valid refresh token from login |

**Example Request**:
```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or expired refresh token

---

#### POST /auth/logout

Invalidate current refresh token.

**Authentication**: Required

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| refreshToken | string | Yes | Refresh token to invalidate |

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### Posts

---

#### GET /posts

Get all published posts (public endpoint).

**Authentication**: Not required

**Query Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | integer | No | 1 | Page number (1-indexed) |
| per_page | integer | No | 10 | Items per page (max 50) |
| sort | string | No | createdAt | Sort field: `createdAt`, `title`, `updatedAt` |
| order | string | No | desc | Sort order: `asc`, `desc` |
| search | string | No | - | Search in title and content |

**Example Request**:
```http
GET /api/v1/posts?page=1&per_page=10&sort=createdAt&order=desc
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "post_abc123",
      "title": "Getting Started with React Hooks",
      "slug": "getting-started-with-react-hooks",
      "excerpt": "React Hooks are a powerful feature that let you use state and other React features without writing a class. In this guide, we'll explore...",
      "coverImage": "https://cdn.simpleblog.com/images/react-hooks.jpg",
      "author": {
        "id": "usr_1234567890",
        "name": "John Doe",
        "avatar": "https://cdn.simpleblog.com/avatars/john.jpg"
      },
      "publishedAt": "2024-01-15T10:00:00Z",
      "readingTime": 8
    },
    {
      "id": "post_def456",
      "title": "Building Scalable APIs with Node.js",
      "slug": "building-scalable-apis-nodejs",
      "excerpt": "Learn how to design and build production-ready REST APIs using Node.js, Express, and PostgreSQL...",
      "coverImage": "https://cdn.simpleblog.com/images/nodejs-api.jpg",
      "author": {
        "id": "usr_1234567890",
        "name": "John Doe",
        "avatar": "https://cdn.simpleblog.com/avatars/john.jpg"
      },
      "publishedAt": "2024-01-10T14:30:00Z",
      "readingTime": 12
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 10,
      "total": 25,
      "total_pages": 3
    }
  }
}
```

---

#### GET /posts/:slug

Get a single published post by slug (public endpoint).

**Authentication**: Not required

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| slug | string | Yes | Post URL slug |

**Example Request**:
```http
GET /api/v1/posts/getting-started-with-react-hooks
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "post_abc123",
    "title": "Getting Started with React Hooks",
    "slug": "getting-started-with-react-hooks",
    "content": "# Introduction\n\nReact Hooks are a powerful feature...\n\n## What are Hooks?\n\nHooks are functions that...",
    "contentHtml": "<h1>Introduction</h1><p>React Hooks are a powerful feature...</p>",
    "excerpt": "React Hooks are a powerful feature that let you use state...",
    "coverImage": "https://cdn.simpleblog.com/images/react-hooks.jpg",
    "metaDescription": "Learn how to use React Hooks to manage state and side effects in functional components",
    "author": {
      "id": "usr_1234567890",
      "name": "John Doe",
      "bio": "Full-stack developer and tech writer",
      "avatar": "https://cdn.simpleblog.com/avatars/john.jpg"
    },
    "publishedAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2024-01-15T10:00:00Z",
    "readingTime": 8,
    "viewCount": 1247
  }
}
```

**Error Responses**:
- `404 Not Found`: Post with that slug does not exist or is not published

---

#### GET /posts/my-posts

Get all posts owned by authenticated user (drafts and published).

**Authentication**: Required

**Query Parameters**: Same as `GET /posts`, plus:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| status | string | No | all | Filter by status: `all`, `published`, `draft` |

**Example Request**:
```http
GET /api/v1/posts/my-posts?status=draft&sort=updatedAt&order=desc
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": "post_xyz789",
      "title": "Understanding TypeScript Generics",
      "slug": "understanding-typescript-generics",
      "excerpt": "TypeScript generics provide a way to create reusable components...",
      "status": "draft",
      "coverImage": null,
      "createdAt": "2024-01-20T09:00:00Z",
      "updatedAt": "2024-01-20T15:30:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 10,
      "total": 8,
      "total_pages": 1
    },
    "summary": {
      "totalPosts": 8,
      "published": 5,
      "drafts": 3
    }
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid authentication token

---

#### POST /posts

Create a new blog post (saved as draft).

**Authentication**: Required

**Request Body**:

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| title | string | Yes | min:3, max:200 | Post title |
| slug | string | No | Alphanumeric + hyphens | URL slug (auto-generated from title if omitted) |
| content | string | Yes | min:10 | Post content in Markdown |
| excerpt | string | No | max:300 | Short description (auto-generated if omitted) |
| metaDescription | string | No | max:160 | SEO meta description |
| coverImage | string | No | Valid URL | Cover image URL |

**Example Request**:
```http
POST /api/v1/posts
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "title": "Understanding TypeScript Generics",
  "content": "# Introduction\n\nTypeScript generics allow you to...",
  "metaDescription": "A comprehensive guide to using generics in TypeScript",
  "coverImage": "https://cdn.simpleblog.com/images/typescript.jpg"
}
```

**Response**: `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "post_xyz789",
    "title": "Understanding TypeScript Generics",
    "slug": "understanding-typescript-generics",
    "content": "# Introduction\n\nTypeScript generics allow you to...",
    "excerpt": "TypeScript generics allow you to write reusable, type-safe functions...",
    "metaDescription": "A comprehensive guide to using generics in TypeScript",
    "coverImage": "https://cdn.simpleblog.com/images/typescript.jpg",
    "status": "draft",
    "authorId": "usr_1234567890",
    "createdAt": "2024-01-20T09:00:00Z",
    "updatedAt": "2024-01-20T09:00:00Z"
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid authentication token
- `422 Validation Error`: Invalid input (e.g., title too short)
- `409 Conflict`: Slug already exists

---

#### PATCH /posts/:id

Update an existing post (partial update).

**Authentication**: Required (must be post owner)

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Post ID |

**Request Body**: Any subset of fields from POST /posts

**Example Request**:
```http
PATCH /api/v1/posts/post_xyz789
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "title": "Understanding TypeScript Generics (Updated)",
  "content": "# Introduction\n\nUpdated content here..."
}
```

**Response**: `200 OK` (same structure as POST response with updated data)

**Error Responses**:
- `401 Unauthorized`: Missing or invalid authentication token
- `403 Forbidden`: User is not the post owner
- `404 Not Found`: Post not found
- `422 Validation Error`: Invalid input

---

#### POST /posts/:id/publish

Publish a draft post (make it publicly visible).

**Authentication**: Required (must be post owner)

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Post ID |

**Example Request**:
```http
POST /api/v1/posts/post_xyz789/publish
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "post_xyz789",
    "status": "published",
    "publishedAt": "2024-01-20T16:00:00Z",
    "url": "https://simpleblog.com/blog/understanding-typescript-generics"
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid authentication token
- `403 Forbidden`: User is not the post owner
- `404 Not Found`: Post not found
- `422 Validation Error`: Post missing required fields (title, content)

---

#### POST /posts/:id/unpublish

Unpublish a published post (revert to draft).

**Authentication**: Required (must be post owner)

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Post ID |

**Example Request**:
```http
POST /api/v1/posts/post_abc123/unpublish
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "post_abc123",
    "status": "draft",
    "message": "Post unpublished successfully"
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid authentication token
- `403 Forbidden`: User is not the post owner
- `404 Not Found`: Post not found

---

#### DELETE /posts/:id

Permanently delete a post.

**Authentication**: Required (must be post owner)

**Path Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | Post ID |

**Example Request**:
```http
DELETE /api/v1/posts/post_xyz789
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response**: `200 OK`
```json
{
  "success": true,
  "message": "Post deleted successfully"
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid authentication token
- `403 Forbidden`: User is not the post owner
- `404 Not Found`: Post not found

---

### Images

---

#### POST /images/upload

Upload an image for use in blog posts.

**Authentication**: Required

**Request Format**: `multipart/form-data`

**Form Fields**:

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| image | file | Yes | Max 5MB, types: jpg, png, gif, webp | Image file |

**Example Request**:
```http
POST /api/v1/images/upload
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="image"; filename="cover.jpg"
Content-Type: image/jpeg

[binary image data]
--boundary--
```

**Response**: `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "img_123abc",
    "url": "https://cdn.simpleblog.com/images/usr_1234567890/cover-abc123.jpg",
    "filename": "cover.jpg",
    "size": 245678,
    "mimeType": "image/jpeg",
    "width": 1920,
    "height": 1080,
    "uploadedAt": "2024-01-20T10:15:00Z"
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Missing or invalid authentication token
- `413 Payload Too Large`: Image exceeds 5MB limit
- `422 Validation Error`: Invalid file type
- `429 Too Many Requests`: Upload rate limit exceeded (10 per hour)

---

## Webhooks (Future Feature)

Webhooks are not implemented in v1.0 but are planned for v1.1.

**Planned Events:**
- `post.published` - Triggered when post is published
- `post.updated` - Triggered when published post is edited
- `post.deleted` - Triggered when post is deleted

---

## Changelog

### v1.0 (2024-02-01)
- Initial API release
- Authentication endpoints (register, login, refresh, logout)
- Posts CRUD (create, read, update, delete)
- Publish/unpublish functionality
- Image upload endpoint
- Pagination and search support
