# Docker 베스트 프랙티스

**목적**: 최적화되고 안전한 Dockerfile 작성 가이드

---

## Multi-Stage Builds

### Python (FastAPI) 예제

```dockerfile
# Stage 1: Builder - 의존성 설치
FROM python:3.11-slim as builder

WORKDIR /app

# 의존성만 먼저 복사 (레이어 캐싱 최적화)
COPY requirements.txt .

# 사용자 디렉토리에 설치
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime - 최종 이미지
FROM python:3.11-slim

WORKDIR /app

# Builder에서 설치된 패키지 복사
COPY --from=builder /root/.local /root/.local

# 애플리케이션 코드 복사
COPY . .

# 환경 변수 설정
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

# Non-root 사용자 생성
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health')"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Node (Next.js) 예제

```dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat

WORKDIR /app
COPY package*.json ./
RUN npm ci

# Stage 2: Builder
FROM node:20-alpine AS builder

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js standalone 빌드
RUN npm run build

# Stage 3: Runner
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV production

# Non-root 사용자
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# 필요한 파일만 복사
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
```

---

## 레이어 캐싱 최적화

### 원칙
1. **자주 변경되지 않는 것을 먼저 COPY**
2. **의존성과 코드를 분리**
3. **.dockerignore 활용**

### 예제 (잘못된 방법)
```dockerfile
# ❌ 나쁜 예: 모든 것을 한번에 복사
COPY . .
RUN pip install -r requirements.txt
# → 코드 변경 시마다 의존성 재설치
```

### 예제 (올바른 방법)
```dockerfile
# ✅ 좋은 예: 의존성 먼저 설치
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
# → 코드만 변경 시 캐시 활용
```

---

## .dockerignore

```
# Python
**/__pycache__
**/*.pyc
**/*.pyo
**/*.pyd
**/.pytest_cache
**/.venv
**/venv
**/.env
**/.env.local
**/test.db

# Node.js
**/node_modules
**/.next
**/out
**/.vercel
**/*.tsbuildinfo
**/.env*.local

# 공통
**/.git
**/.gitignore
**/.DS_Store
**/README.md
**/docker-compose.yml
**/Dockerfile
```

---

## 보안 베스트 프랙티스

### 1. Non-root 사용자

```dockerfile
# 사용자 생성
RUN useradd -m -u 1000 appuser

# 소유권 변경
RUN chown -R appuser:appuser /app

# 사용자 전환
USER appuser
```

### 2. Secrets 관리

```dockerfile
# ❌ 나쁜 예: 하드코딩
ENV SECRET_KEY=my-secret-key

# ✅ 좋은 예: 런타임 주입
ENV SECRET_KEY=${SECRET_KEY}
# docker run -e SECRET_KEY=actual-secret ...
```

### 3. 최소 권한 Base Image

```dockerfile
# ✅ Alpine 또는 Slim 사용
FROM python:3.11-slim
FROM node:20-alpine

# ❌ Full 이미지 지양
# FROM python:3.11
# FROM node:20
```

---

## Health Checks

### FastAPI 예제

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

**Backend 코드 (main.py):**
```python
@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

### Next.js 예제

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); })"
```

---

## 이미지 크기 최적화

### 전략

1. **Multi-stage builds** 사용
2. **Alpine base images** 선호
3. **--no-cache-dir** 플래그 (pip)
4. **불필요한 파일 제거**

### 비교

```dockerfile
# ❌ 큰 이미지 (1.2GB)
FROM python:3.11
COPY . .
RUN pip install -r requirements.txt

# ✅ 작은 이미지 (150MB)
FROM python:3.11-slim as builder
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY . .
```

---

## 환경별 설정

### 개발 vs 프로덕션

```dockerfile
# Dockerfile.dev (개발용)
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--reload", "--host", "0.0.0.0"]

# Dockerfile (프로덕션용)
FROM python:3.11-slim as builder
# ... multi-stage build
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--workers", "4"]
```

---

## 빌드 인자 (ARG)

```dockerfile
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim

ARG BUILD_DATE
ARG VERSION
LABEL build_date=${BUILD_DATE} version=${VERSION}

# 빌드 시:
# docker build --build-arg PYTHON_VERSION=3.12 --build-arg VERSION=1.0.0 .
```

---

## 요약 체크리스트

배포 전 확인:

- [ ] Multi-stage build 사용
- [ ] Non-root 사용자
- [ ] .dockerignore 작성
- [ ] Health check 포함
- [ ] Secrets 하드코딩 없음
- [ ] Slim/Alpine base image
- [ ] 레이어 캐싱 최적화
- [ ] 불필요한 파일 제외

**목표 이미지 크기:**
- Python (FastAPI): < 200MB
- Node (Next.js): < 300MB
