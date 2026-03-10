---
name: deployment
description: Infrastructure setup and containerized deployment with Docker Compose
version: 1.0.0
---

# Deployment Phase

## 개요

Docker 컨테이너화 → Docker Compose 오케스트레이션 → 서비스 배포

**목표**: `docker compose up --build -d`로 전체 스택 실행

---

## 전제 조건 & 입출력

**State:** `phases.implementation === "completed"`
**입력:** Backend + Frontend 코드, .env.example, requirements.txt, package.json
**출력:**
- `Dockerfile` (backend, frontend)
- `docker-compose.yml`
- `.dockerignore`
- `nginx.conf` (프로덕션 프록시)
- **Running Services** on configured ports

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| infrastructure-deployer | opus | Docker 환경 구성 + 배포 자동화 |

**핵심 원칙:**
- Multi-stage builds로 이미지 최적화
- Health checks 필수 포함
- 환경 변수 보안 (secrets 분리)
- 네트워크 격리 (backend, frontend, db)

---

## Phase 5.1: Docker 환경 구성

### 1. Backend Dockerfile

**위임 대상:** infrastructure-deployer
**작업:**
```dockerfile
# Multi-stage build
# Stage 1: Builder (dependencies)
# Stage 2: Runtime (slim image)

# 요구사항:
- Python 3.11+ slim base
- Poetry or pip for dependency management
- Non-root user
- Health check endpoint (/health)
```

**참조:** `references/docker-patterns.md`

### 2. Frontend Dockerfile

**위임 대상:** infrastructure-deployer
**작업:**
```dockerfile
# Multi-stage build
# Stage 1: Dependencies + Build
# Stage 2: Production (nginx or standalone)

# 요구사항:
- Node 20 LTS
- Next.js standalone output
- Static asset optimization
- nginx or Next.js server
```

---

## Phase 5.2: Docker Compose 오케스트레이션

### 1. docker-compose.yml 작성

**위임 대상:** infrastructure-deployer

**서비스 구성:**
```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER
      - POSTGRES_PASSWORD
      - POSTGRES_DB
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]

  backend:
    build: ./backend
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      - DATABASE_URL
      - SECRET_KEY
    ports:
      - "8000:8000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]

  frontend:
    build: ./frontend
    depends_on:
      - backend
    environment:
      - NEXT_PUBLIC_API_URL
    ports:
      - "3000:3000"

volumes:
  postgres_data:

networks:
  default:
    driver: bridge
```

**참조:** `references/docker-compose-guide.md`

### 2. 환경 변수 관리

**파일 생성:**
- `.env.production` (템플릿)
- `.env.local.example`

**보안 체크:**
- `.gitignore`에 `.env*` 추가 확인
- Secrets 하드코딩 검증
- 프로덕션 키 placeholder 명시

---

## Phase 5.3: 배포 실행

### 1. 빌드 & 실행

**명령어:**
```bash
# 이미지 빌드
docker compose build

# 서비스 시작 (detached)
docker compose up --build -d

# 로그 확인
docker compose logs -f

# 상태 확인
docker compose ps
```

### 2. 검증 체크리스트

**infrastructure-deployer 수행:**
- [ ] PostgreSQL 헬스체크 통과
- [ ] Backend API 응답 (`curl http://localhost:8000/health`)
- [ ] Frontend 접근 가능 (`curl http://localhost:3000`)
- [ ] DB 마이그레이션 성공 (alembic upgrade head)
- [ ] 환경 변수 로드 확인

**자동화 스크립트:** `scripts/health-check.sh`

---

## Phase 5.4: 프로덕션 최적화 (선택)

### Nginx 리버스 프록시

**설정 파일:** `nginx.conf`
```nginx
upstream backend {
    server backend:8000;
}

upstream frontend {
    server frontend:3000;
}

server {
    listen 80;

    location /api/ {
        proxy_pass http://backend;
    }

    location / {
        proxy_pass http://frontend;
    }
}
```

**docker-compose.yml 추가:**
```yaml
services:
  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "80:80"
    depends_on:
      - backend
      - frontend
```

---

## 트러블슈팅

### 일반적인 문제

1. **포트 충돌**
   ```bash
   # 사용 중인 포트 확인
   netstat -ano | findstr :8000
   # docker-compose.yml에서 포트 변경
   ```

2. **DB 연결 실패**
   ```bash
   # 헬스체크 로그 확인
   docker compose logs postgres
   # DATABASE_URL 환경변수 검증
   ```

3. **빌드 캐시 이슈**
   ```bash
   # 캐시 없이 재빌드
   docker compose build --no-cache
   ```

**참조:** `references/troubleshooting.md`

---

## 출력 확인

**완료 조건:**
```bash
$ docker compose ps
NAME                STATUS              PORTS
postgres            Up (healthy)        5432/tcp
backend             Up (healthy)        0.0.0.0:8000->8000/tcp
frontend            Up                  0.0.0.0:3000->3000/tcp
```

**API 테스트:**
```bash
curl http://localhost:8000/api/v1/health
# {"status": "healthy", "database": "connected"}

curl http://localhost:3000
# [Next.js 페이지 응답]
```

---

## 다음 단계

- **Phase 6 (QA)**: 통합 테스트 및 성능 검증
- **CI/CD**: GitHub Actions 자동 배포 (선택)
- **모니터링**: 로깅 및 메트릭 수집 (선택)

---

## 참조 문서

- [docker-patterns.md](./references/docker-patterns.md) - Dockerfile 베스트 프랙티스
- [docker-compose-guide.md](./references/docker-compose-guide.md) - Compose 설정 가이드
- [deployment-checklist.md](./references/deployment-checklist.md) - 배포 전 체크리스트
- [troubleshooting.md](./references/troubleshooting.md) - 일반적인 문제 해결

## 스크립트

- [init-docker.sh](./scripts/init-docker.sh) - Docker 환경 초기화
- [health-check.sh](./scripts/health-check.sh) - 서비스 헬스체크
