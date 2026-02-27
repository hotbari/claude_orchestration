# 아키텍처 문서 - {Project Name}

**버전**: 1.0
**생성일**: {date}
**최종 업데이트**: {date}
**상태**: 초안

---

## 1. 시스템 개요

시스템 아키텍처, 주요 설계 결정 및 아키텍처 목표에 대한 높은 수준의 설명.

**예시:**
간단한 블로그 플랫폼은 React 프론트엔드, Node.js REST API 백엔드 및 PostgreSQL 데이터베이스를 사용하여 구축된 현대적인 JAMstack 아키텍처를 사용하는 풀스택 웹 애플리케이션입니다. 시스템은 프로덕션 준비 보안 및 확장성을 유지하면서 단순성, 성능 및 개발자 경험을 우선시합니다. 아키텍처는 3계층 모델을 따릅니다: 프레젠테이션 계층 (React SPA), 애플리케이션 계층 (Node.js API), 데이터 계층 (PostgreSQL + S3).

### 1.1 아키텍처 목표

- **성능**: 빠른 페이지 로드 (< 2초) 및 반응형 사용자 상호작용
- **확장성**: 10,000명 이상의 동시 독자, 100명 이상의 동시 작성자 지원
- **유지보수성**: 명확한 관심사 분리, 잘 문서화된 코드베이스
- **보안**: 업계 표준 인증, 입력 검증, XSS/CSRF 보호
- **개발자 경험**: 빠른 개발 반복, 타입 안전성, 쉬운 로컬 설정

### 1.2 주요 설계 결정

| 결정 | 선택 | 근거 |
|----------|--------|-----------|
| Frontend Framework | React 18 | 대규모 생태계, 컴포넌트 재사용성, 우수한 TypeScript 지원 |
| Backend Framework | Express.js | 경량, 성숙함, 광범위한 미들웨어 생태계 |
| Database | PostgreSQL | ACID 준수, JSON 지원, 강력한 쿼리, 오픈 소스 |
| Authentication | JWT | 무상태, 확장 가능, SPA 아키텍처와 잘 작동 |
| Styling | TailwindCSS | 빠른 개발, 일관된 디자인 시스템, 작은 번들 크기 |
| Type Safety | TypeScript | 조기 오류 발견, 더 나은 IDE 지원, 자체 문서화 코드 |

### 1.3 System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  React SPA (TypeScript)                               │  │
│  │  - Pages (Dashboard, Editor, Post View)               │  │
│  │  - Components (Button, Input, Card, Modal)            │  │
│  │  - State Management (React Context / Zustand)         │  │
│  │  - API Client (Axios)                                 │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕ HTTPS
┌─────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Node.js REST API (Express + TypeScript)             │  │
│  │  - Routes (auth, posts, images)                       │  │
│  │  - Controllers (business logic)                       │  │
│  │  - Middleware (auth, validation, error handling)      │  │
│  │  - Services (database, storage, email)                │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕ SQL
┌─────────────────────────────────────────────────────────────┐
│                         DATA LAYER                          │
│  ┌──────────────────────────┐  ┌──────────────────────────┐ │
│  │  PostgreSQL Database     │  │  AWS S3 / Cloudinary     │ │
│  │  - Users Table           │  │  - User Images           │ │
│  │  - Posts Table           │  │  - Cover Images          │ │
│  │  - Refresh Tokens Table  │  │  - Uploaded Files        │ │
│  └──────────────────────────┘  └──────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 프론트엔드 아키텍처

### 2.1 기술 스택

| 컴포넌트 | 기술 | 버전 | 목적 |
|-----------|-----------|---------|---------|
| Framework | React | 18.2+ | UI 컴포넌트 라이브러리 |
| Language | TypeScript | 5.0+ | 타입 안전 JavaScript |
| Build Tool | Vite | 5.0+ | 빠른 개발 서버 및 번들러 |
| Routing | React Router | 6.x | 클라이언트 사이드 네비게이션 |
| Styling | TailwindCSS | 3.4+ | 유틸리티 우선 CSS 프레임워크 |
| UI Components | shadcn/ui | Latest | 접근 가능한 컴포넌트 프리미티브 |
| Forms | React Hook Form | 7.x | 성능 좋은 폼 처리 |
| Validation | Zod | 3.x | 타입 안전 스키마 검증 |
| State Management | Zustand | 4.x | 경량 전역 상태 |
| HTTP Client | Axios | 1.x | 인터셉터가 있는 API 요청 |
| Markdown Editor | SimpleMDE | 2.x | Markdown 편집 경험 |
| Markdown Parser | Marked | 11.x | Markdown에서 HTML로 변환 |

### 2.2 Project Structure

```
frontend/
├── public/                  # Static assets
│   ├── favicon.ico
│   └── robots.txt
├── src/
│   ├── components/         # Reusable UI components
│   │   ├── ui/            # Base UI primitives (shadcn)
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── card.tsx
│   │   │   └── modal.tsx
│   │   ├── layout/        # Layout components
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   └── Footer.tsx
│   │   └── features/      # Feature-specific components
│   │       ├── PostCard.tsx
│   │       ├── MarkdownEditor.tsx
│   │       └── AuthForm.tsx
│   ├── pages/             # Route pages
│   │   ├── HomePage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── EditorPage.tsx
│   │   ├── PostViewPage.tsx
│   │   └── LoginPage.tsx
│   ├── hooks/             # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── usePosts.ts
│   │   └── useAutoSave.ts
│   ├── services/          # API services
│   │   ├── api.ts         # Axios instance + interceptors
│   │   ├── authService.ts
│   │   ├── postService.ts
│   │   └── imageService.ts
│   ├── store/             # Global state (Zustand)
│   │   ├── authStore.ts
│   │   └── postStore.ts
│   ├── types/             # TypeScript types
│   │   ├── auth.types.ts
│   │   ├── post.types.ts
│   │   └── api.types.ts
│   ├── utils/             # Utility functions
│   │   ├── formatters.ts
│   │   ├── validators.ts
│   │   └── helpers.ts
│   ├── lib/               # External library configs
│   │   └── utils.ts       # shadcn utils
│   ├── styles/            # Global styles
│   │   └── globals.css
│   ├── App.tsx            # Root component
│   ├── main.tsx           # Entry point
│   └── vite-env.d.ts      # Vite type declarations
├── .env.example           # Environment variables template
├── .eslintrc.json         # ESLint configuration
├── .prettierrc            # Prettier configuration
├── tailwind.config.js     # Tailwind configuration
├── tsconfig.json          # TypeScript configuration
├── vite.config.ts         # Vite configuration
└── package.json
```

### 2.3 State Management Strategy

**Local State**: React `useState`, `useReducer` for component-specific state

**Form State**: React Hook Form for complex forms with validation

**Global State**: Zustand stores for:
- Authentication state (user, tokens)
- Posts list cache
- UI state (modals, notifications)

**Server State**: React Query (future enhancement) for API data caching and synchronization

### 2.4 Routing

```typescript
// App.tsx routes
const routes = [
  { path: '/', element: <HomePage /> },                    // Public blog listing
  { path: '/blog/:slug', element: <PostViewPage /> },      // Public post view
  { path: '/login', element: <LoginPage /> },              // Public login
  { path: '/register', element: <RegisterPage /> },        // Public registration
  {
    path: '/dashboard',                                    // Protected routes
    element: <ProtectedRoute />,
    children: [
      { path: '', element: <DashboardPage /> },            // My posts
      { path: 'new', element: <EditorPage /> },            // Create post
      { path: 'edit/:id', element: <EditorPage /> },       // Edit post
      { path: 'settings', element: <SettingsPage /> },     // User settings
    ]
  },
  { path: '*', element: <NotFoundPage /> }                 // 404 page
];
```

### 2.5 Authentication Flow

1. User submits login form
2. Frontend sends credentials to `POST /api/v1/auth/login`
3. Backend validates credentials, returns JWT tokens
4. Frontend stores tokens in Zustand store + localStorage
5. Axios interceptor adds `Authorization: Bearer {token}` to all requests
6. On 401 response, interceptor attempts token refresh via `POST /api/v1/auth/refresh`
7. If refresh fails, redirect to login page

### 2.6 Key Features Implementation

**Auto-Save (Editor)**:
- `useAutoSave` hook debounces changes (30 second delay)
- On trigger, calls `PATCH /api/v1/posts/:id` with updated content
- Shows "Saved" indicator on success, "Error saving" on failure
- Saves to localStorage as backup if offline

**Image Upload**:
- Drag-drop or file picker in editor
- Upload via `POST /api/v1/images/upload` (multipart/form-data)
- Show upload progress bar
- Insert returned URL into Markdown: `![alt](url)`
- Handle errors gracefully (file too large, wrong type)

**Markdown Preview**:
- Split-pane editor: Markdown on left, preview on right
- Use `marked` library to convert Markdown → HTML
- Sanitize HTML output to prevent XSS
- Sync scroll position between editor and preview

---

## 3. 백엔드 아키텍처

### 3.1 기술 스택

| 컴포넌트 | 기술 | 버전 | 목적 |
|-----------|-----------|---------|---------|
| Runtime | Node.js | 20 LTS | JavaScript 런타임 |
| Language | TypeScript | 5.0+ | 타입 안전 JavaScript |
| Framework | Express | 4.x | 웹 프레임워크 |
| Database | PostgreSQL | 15+ | 관계형 데이터베이스 |
| ORM | Prisma | 5.x | 타입 안전 데이터베이스 클라이언트 |
| Authentication | jsonwebtoken | 9.x | JWT 토큰 생성/검증 |
| Password Hashing | bcrypt | 5.x | 안전한 비밀번호 해싱 |
| Validation | Zod | 3.x | 요청 검증 |
| File Upload | Multer | 1.x | Multipart 폼 데이터 처리 |
| Image Storage | AWS SDK (S3) | 3.x | 클라우드 파일 스토리지 |
| Email | Nodemailer | 6.x | 이메일 전송 (인증, 비밀번호 재설정) |

### 3.2 Project Structure

```
backend/
├── src/
│   ├── config/            # Configuration files
│   │   ├── database.ts    # Prisma client initialization
│   │   ├── jwt.ts         # JWT configuration
│   │   ├── storage.ts     # S3 client configuration
│   │   └── email.ts       # Nodemailer configuration
│   ├── middleware/        # Express middleware
│   │   ├── auth.ts        # JWT authentication middleware
│   │   ├── validate.ts    # Zod validation middleware
│   │   ├── errorHandler.ts # Global error handler
│   │   ├── rateLimit.ts   # Rate limiting
│   │   └── cors.ts        # CORS configuration
│   ├── routes/            # API routes
│   │   ├── auth.routes.ts
│   │   ├── posts.routes.ts
│   │   └── images.routes.ts
│   ├── controllers/       # Request handlers
│   │   ├── authController.ts
│   │   ├── postController.ts
│   │   └── imageController.ts
│   ├── services/          # Business logic
│   │   ├── authService.ts
│   │   ├── postService.ts
│   │   ├── imageService.ts
│   │   └── emailService.ts
│   ├── models/            # Prisma models (generated)
│   ├── types/             # TypeScript types
│   │   ├── auth.types.ts
│   │   ├── post.types.ts
│   │   └── express.d.ts   # Express type extensions
│   ├── utils/             # Utility functions
│   │   ├── errors.ts      # Custom error classes
│   │   ├── validators.ts  # Zod schemas
│   │   ├── slugify.ts     # URL slug generation
│   │   └── helpers.ts
│   ├── app.ts             # Express app setup
│   └── server.ts          # Server entry point
├── prisma/
│   ├── schema.prisma      # Database schema
│   ├── migrations/        # Database migrations
│   └── seed.ts            # Database seeding script
├── .env.example           # Environment variables template
├── .eslintrc.json
├── .prettierrc
├── tsconfig.json
└── package.json
```

### 3.3 API Architecture Pattern

**Layered Architecture**:

```
Request → Route → Controller → Service → Database
         ↓         ↓             ↓
    Middleware  Validation   Business Logic
```

**Example: Create Post Flow**

```typescript
// 1. Route (posts.routes.ts)
router.post('/', authMiddleware, validateMiddleware(createPostSchema), postController.create);

// 2. Middleware (auth.ts)
// Verifies JWT, attaches user to req.user

// 3. Middleware (validate.ts)
// Validates request body against Zod schema

// 4. Controller (postController.ts)
async create(req, res, next) {
  const post = await postService.create(req.user.id, req.body);
  res.status(201).json({ success: true, data: post });
}

// 5. Service (postService.ts)
async create(userId, data) {
  const slug = slugify(data.title);
  const post = await prisma.post.create({ data: { ...data, slug, authorId: userId } });
  return post;
}

// 6. Prisma (ORM)
// Executes SQL INSERT query, returns created post
```

### 3.4 Authentication Implementation

**JWT Token Strategy**:

- **Access Token**: Short-lived (1 hour), contains user ID and email
- **Refresh Token**: Long-lived (7 days), stored in database for revocation
- Access token sent in Authorization header
- Refresh token sent in HTTP-only cookie (more secure)

**Token Generation**:
```typescript
// authService.ts
function generateTokens(user: User) {
  const accessToken = jwt.sign(
    { userId: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  const refreshToken = jwt.sign(
    { userId: user.id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: '7d' }
  );

  return { accessToken, refreshToken };
}
```

**Authentication Middleware**:
```typescript
// middleware/auth.ts
async function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await prisma.user.findUnique({ where: { id: decoded.userId } });
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}
```

### 3.5 Error Handling

**Custom Error Classes**:
```typescript
// utils/errors.ts
class AppError extends Error {
  constructor(public statusCode: number, public message: string) {
    super(message);
  }
}

class ValidationError extends AppError {
  constructor(message: string, public details?: any) {
    super(422, message);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(401, message);
  }
}
```

**Global Error Handler**:
```typescript
// middleware/errorHandler.ts
function errorHandler(err, req, res, next) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: { code: err.constructor.name, message: err.message }
    });
  }

  // Unexpected errors
  console.error(err);
  res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' }
  });
}
```

### 3.6 Security Measures

| Threat | Mitigation |
|--------|------------|
| SQL Injection | Prisma ORM with parameterized queries |
| XSS | Input sanitization, Content Security Policy headers |
| CSRF | SameSite cookies, CSRF tokens for state-changing operations |
| Password Attacks | Bcrypt hashing (12 rounds), minimum password complexity |
| Brute Force | Rate limiting: 5 login attempts per 15 minutes |
| JWT Attacks | Short-lived access tokens, refresh token rotation, secret key rotation |
| File Upload Attacks | File type validation, size limits (5MB), virus scanning (future) |
| DDoS | Rate limiting on all endpoints, Cloudflare protection (production) |

---

## 4. Database Architecture

### 4.1 Database Schema

```prisma
// prisma/schema.prisma

model User {
  id            String   @id @default(uuid())
  email         String   @unique
  password      String
  name          String
  blogName      String?
  avatar        String?
  bio           String?
  emailVerified Boolean  @default(false)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  posts         Post[]
  refreshTokens RefreshToken[]

  @@map("users")
}

model Post {
  id              String   @id @default(uuid())
  title           String   @db.VarChar(200)
  slug            String   @unique
  content         String   @db.Text
  excerpt         String?  @db.VarChar(300)
  metaDescription String?  @db.VarChar(160)
  coverImage      String?
  status          String   @default("draft") // "draft" | "published"
  publishedAt     DateTime?
  viewCount       Int      @default(0)
  readingTime     Int?     // in minutes
  authorId        String
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  author          User     @relation(fields: [authorId], references: [id], onDelete: Cascade)

  @@index([authorId])
  @@index([slug])
  @@index([status])
  @@map("posts")
}

model RefreshToken {
  id        String   @id @default(uuid())
  token     String   @unique
  userId    String
  expiresAt DateTime
  createdAt DateTime @default(now())

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@index([token])
  @@map("refresh_tokens")
}
```

### 4.2 Indexes

Critical indexes for query performance:

- `posts.authorId`: Fast lookup of user's posts
- `posts.slug`: Fast lookup of post by URL slug (unique)
- `posts.status`: Filter published vs draft posts
- `refresh_tokens.token`: Fast token validation
- `refresh_tokens.userId`: Fast cleanup of user's tokens

### 4.3 Relationships

- **User → Posts**: One-to-many (one user has many posts)
- **User → RefreshTokens**: One-to-many (one user can have multiple active sessions)

### 4.4 Data Migrations

Use Prisma Migrate for schema changes:

```bash
# Create migration
npx prisma migrate dev --name add_reading_time

# Apply migrations (production)
npx prisma migrate deploy
```

---

## 5. Environment Variables

### 5.1 Frontend (.env)

```bash
# API Configuration
VITE_API_BASE_URL=http://localhost:3000/api/v1

# Feature Flags
VITE_ENABLE_ANALYTICS=false
```

### 5.2 Backend (.env)

```bash
# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/simpleblog

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-refresh-token-secret-key
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# AWS S3
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=simpleblog-images

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
EMAIL_FROM=noreply@simpleblog.com

# Frontend URL (for email links)
FRONTEND_URL=http://localhost:5173

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

---

## 6. Deployment Architecture

### 6.1 Development Environment

```
┌─────────────────┐
│  Developer PC   │
│  - Frontend     │ → http://localhost:5173
│  - Backend      │ → http://localhost:3000
│  - PostgreSQL   │ → localhost:5432
└─────────────────┘
```

### 6.2 Production Environment (Recommended)

```
┌──────────────────────────────────────────────────┐
│               Cloudflare CDN (Edge)              │
│          - DDoS Protection                       │
│          - SSL/TLS                               │
│          - Caching                               │
└──────────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────────┐
│          Vercel (Frontend Hosting)               │
│  - React SPA                                     │
│  - Automatic HTTPS                               │
│  - Global CDN                                    │
│  - Serverless Functions (optional)               │
└──────────────────────────────────────────────────┘
                    ↓ API Requests
┌──────────────────────────────────────────────────┐
│         Railway / Render (Backend Hosting)       │
│  - Node.js API                                   │
│  - Auto-scaling                                  │
│  - Health checks                                 │
└──────────────────────────────────────────────────┘
                    ↓
┌────────────────────┐        ┌──────────────────┐
│  PostgreSQL        │        │   AWS S3         │
│  (Railway DB)      │        │   (Images)       │
└────────────────────┘        └──────────────────┘
```

### 6.3 CI/CD Pipeline

**GitHub Actions Workflow**:

1. **On Push to Main**:
   - Run linter (ESLint)
   - Run type checking (tsc)
   - Run tests (Jest / Vitest)
   - Build frontend (Vite)
   - Build backend (tsc)

2. **On Success**:
   - Deploy frontend to Vercel (automatic)
   - Deploy backend to Railway (automatic)
   - Run database migrations on Railway DB

3. **On Failure**:
   - Send Slack/Discord notification
   - Block deployment

---

## 7. Performance Optimization

### 7.1 Frontend

- **Code Splitting**: Lazy load routes with `React.lazy()`
- **Image Optimization**: Use WebP format, lazy loading, responsive images
- **Bundle Size**: Tree-shaking unused code, dynamic imports
- **Caching**: Service worker for offline support (future)
- **Lighthouse Score Target**: > 90 on all metrics

### 7.2 Backend

- **Database Query Optimization**: Use `select` to fetch only needed fields
- **Pagination**: Limit query results, use cursor-based pagination for large datasets
- **Caching**: Redis cache for frequently accessed posts (future)
- **Database Connection Pooling**: Prisma connection pool (default 10 connections)
- **Response Compression**: Gzip compression middleware

### 7.3 Database

- **Indexes**: Add indexes on frequently queried fields
- **Query Optimization**: Use `EXPLAIN ANALYZE` to identify slow queries
- **Connection Limits**: Max 100 concurrent connections
- **Regular Backups**: Daily automated backups with 30-day retention

---

## 8. Monitoring and Logging

### 8.1 Application Monitoring

- **Error Tracking**: Sentry for frontend and backend errors
- **Performance Monitoring**: Sentry Performance or Datadog APM
- **Uptime Monitoring**: UptimeRobot or Pingdom (ping every 5 minutes)

### 8.2 Logging Strategy

**Frontend**:
- Console errors in development
- Sentry for production errors
- User actions logged for analytics (privacy-focused)

**Backend**:
- Winston or Pino for structured logging
- Log Levels: ERROR, WARN, INFO, DEBUG
- Log to stdout (captured by hosting platform)
- Sensitive data (passwords, tokens) never logged

**Log Format** (JSON):
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "message": "User login successful",
  "userId": "usr_123",
  "ip": "192.168.1.1"
}
```

---

## 9. Testing Strategy

### 9.1 Frontend Testing

- **Unit Tests**: Vitest for component logic, utility functions
- **Component Tests**: React Testing Library for UI components
- **E2E Tests**: Playwright for critical user flows (login, create post, publish)
- **Coverage Target**: 70% overall, 90% for critical paths

### 9.2 Backend Testing

- **Unit Tests**: Jest for services, utilities
- **Integration Tests**: Supertest for API endpoints
- **Database Tests**: Use in-memory SQLite or test PostgreSQL instance
- **Coverage Target**: 80% overall, 95% for authentication and authorization

### 9.3 Test Automation

- Run all tests on every pull request
- Block merge if tests fail
- Run E2E tests nightly on staging environment

---

## 10. Security Considerations

### 10.1 Authentication Security

- Passwords hashed with bcrypt (12 rounds)
- JWT secrets rotated quarterly
- Refresh tokens revoked on logout
- Failed login attempts rate-limited (5 per 15 min)

### 10.2 Data Security

- All data encrypted in transit (HTTPS/TLS 1.3)
- Database encrypted at rest (provider default)
- PII (Personally Identifiable Information) minimized
- GDPR compliance: user data export and deletion endpoints

### 10.3 API Security

- CORS restricted to known frontend origins
- Rate limiting on all endpoints
- Input validation with Zod schemas
- SQL injection prevented by Prisma ORM
- XSS prevented by React's automatic escaping + CSP headers

---

## 11. Future Enhancements

### Phase 2 (Months 2-3)
- Comments system with moderation
- Categories and tags for posts
- Full-text search with ElasticSearch or Typesense
- Email notifications for new comments

### Phase 3 (Months 4-6)
- Multiple authors / team blogs
- Analytics dashboard (view counts, popular posts)
- RSS feed generation
- Scheduled publishing (post at specific date/time)

### Phase 4 (Months 7-12)
- Custom domains for user blogs
- Newsletter integration (Mailchimp/ConvertKit)
- SEO optimization tools (keyword suggestions, internal linking)
- API for third-party integrations

---

## 12. Appendix

### 12.1 Tech Stack Summary

| Layer | Technologies |
|-------|-------------|
| Frontend | React, TypeScript, TailwindCSS, Vite, Zustand |
| Backend | Node.js, Express, TypeScript, Prisma |
| Database | PostgreSQL, AWS S3 |
| Auth | JWT, bcrypt |
| Hosting | Vercel (frontend), Railway (backend) |
| CI/CD | GitHub Actions |
| Monitoring | Sentry, UptimeRobot |

### 12.2 Useful Commands

**Development**:
```bash
# Frontend
cd frontend && npm run dev

# Backend
cd backend && npm run dev

# Database migrations
cd backend && npx prisma migrate dev

# Run tests
npm test

# Type checking
npm run type-check
```

**Production Build**:
```bash
# Frontend
npm run build

# Backend
npm run build

# Start production server
npm start
```

---

**Document Status**: Draft
**Reviewed By**: [Name], [Title] - [Date]
**Next Review**: [Date]
