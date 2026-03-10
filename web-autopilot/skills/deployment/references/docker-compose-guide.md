# Docker Compose 설정 가이드

**목적**: 멀티 서비스 오케스트레이션 베스트 프랙티스

---

## 기본 구조

```yaml
version: '3.8'

services:
  # 서비스 정의
  postgres:
    # ...
  backend:
    # ...
  frontend:
    # ...

volumes:
  # 데이터 영속성

networks:
  # 네트워크 격리
```

---

## Service 정의

### PostgreSQL

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: ${PROJECT_NAME}_postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql  # 초기화 스크립트
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - app_network
```

### Backend (FastAPI)

```yaml
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      args:
        - PYTHON_VERSION=3.11
    container_name: ${PROJECT_NAME}_backend
    depends_on:
      postgres:
        condition: service_healthy  # ⭐ Health check 기반 시작
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      SECRET_KEY: ${SECRET_KEY}
      CORS_ORIGINS: ${CORS_ORIGINS}
    volumes:
      - ./backend:/app  # 개발 시 코드 마운트 (프로덕션에서는 제거)
    ports:
      - "${BACKEND_PORT:-8000}:8000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s  # 시작 시간 여유
    restart: unless-stopped
    networks:
      - app_network
    command: >
      sh -c "alembic upgrade head &&
             uvicorn main:app --host 0.0.0.0 --port 8000"
```

### Frontend (Next.js)

```yaml
services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      target: runner  # Multi-stage의 특정 stage
    container_name: ${PROJECT_NAME}_frontend
    depends_on:
      backend:
        condition: service_healthy
    environment:
      NEXT_PUBLIC_API_URL: ${NEXT_PUBLIC_API_URL}
      NODE_ENV: production
    ports:
      - "${FRONTEND_PORT:-3000}:3000"
    restart: unless-stopped
    networks:
      - app_network
```

---

## depends_on 전략

### 기본 의존성 (시작 순서만)

```yaml
depends_on:
  - postgres  # postgres가 시작된 후 backend 시작 (건강 상태 무관)
```

### Health check 기반 (권장)

```yaml
depends_on:
  postgres:
    condition: service_healthy  # postgres가 healthy 상태일 때만 시작
```

---

## 환경 변수 관리

### .env 파일

```env
# .env.production
PROJECT_NAME=myapp

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_here
POSTGRES_DB=appdb
POSTGRES_PORT=5432

# Backend
BACKEND_PORT=8000
SECRET_KEY=your-secret-key-min-32-chars
CORS_ORIGINS=["http://localhost:3000"]

# Frontend
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://localhost:8000/api
```

### docker-compose.yml에서 사용

```yaml
services:
  backend:
    environment:
      # 직접 참조
      SECRET_KEY: ${SECRET_KEY}

      # 기본값 제공
      BACKEND_PORT: ${BACKEND_PORT:-8000}

      # 계산된 값
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
```

---

## 볼륨 (Volumes)

### Named Volumes (권장)

```yaml
volumes:
  postgres_data:
    driver: local

services:
  postgres:
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

**장점**: Docker가 관리, 백업 용이

### Bind Mounts (개발용)

```yaml
services:
  backend:
    volumes:
      - ./backend:/app  # 호스트 디렉토리 마운트
      - /app/node_modules  # 익명 볼륨 (제외)
```

**주의**: 프로덕션에서는 제거

---

## 네트워크 (Networks)

### 기본 설정

```yaml
networks:
  app_network:
    driver: bridge
```

### 다중 네트워크 (고급)

```yaml
networks:
  frontend_network:
  backend_network:
  db_network:

services:
  postgres:
    networks:
      - db_network

  backend:
    networks:
      - backend_network
      - db_network

  frontend:
    networks:
      - frontend_network
      - backend_network

  nginx:
    networks:
      - frontend_network
```

---

## Health Checks

### PostgreSQL

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
  interval: 10s
  timeout: 5s
  retries: 5
```

### FastAPI

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s  # 마이그레이션 시간 고려
```

### Next.js

```yaml
healthcheck:
  test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
```

---

## Restart Policies

```yaml
services:
  backend:
    restart: unless-stopped  # 수동 중지 전까지 재시작

# 옵션:
# - no: 재시작 안 함
# - always: 항상 재시작
# - on-failure: 실패 시만 재시작
# - unless-stopped: 수동 중지 전까지 재시작 (권장)
```

---

## 리소스 제한 (선택)

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

---

## 프로덕션 Nginx 프록시

```yaml
services:
  nginx:
    image: nginx:alpine
    container_name: ${PROJECT_NAME}_nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro  # SSL 인증서
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
    restart: unless-stopped
    networks:
      - app_network
```

**nginx.conf:**
```nginx
upstream backend {
    server backend:8000;
}

upstream frontend {
    server frontend:3000;
}

server {
    listen 80;
    server_name example.com;

    location /api/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location / {
        proxy_pass http://frontend;
        proxy_set_header Host $host;
    }
}
```

---

## 개발 vs 프로덕션

### docker-compose.yml (프로덕션)
```yaml
services:
  backend:
    build: ./backend
    restart: unless-stopped
```

### docker-compose.dev.yml (개발)
```yaml
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    volumes:
      - ./backend:/app  # 코드 핫 리로드
    command: uvicorn main:app --reload --host 0.0.0.0
```

**사용:**
```bash
# 개발
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# 프로덕션
docker compose up -d
```

---

## 명령어 모음

### 기본 명령

```bash
# 빌드 & 시작
docker compose up --build -d

# 중지
docker compose down

# 볼륨 포함 삭제
docker compose down -v

# 로그 확인
docker compose logs -f [service_name]

# 상태 확인
docker compose ps

# 특정 서비스 재시작
docker compose restart backend
```

### 디버깅

```bash
# 서비스 쉘 접속
docker compose exec backend bash

# 환경 변수 확인
docker compose config

# 네트워크 확인
docker network ls
docker network inspect <network_name>
```

---

## 요약 체크리스트

배포 전 확인:

- [ ] Health checks 정의됨
- [ ] depends_on 조건 설정
- [ ] .env 파일 생성 (secrets 변경)
- [ ] 볼륨으로 데이터 영속성 확보
- [ ] restart: unless-stopped
- [ ] 네트워크 격리
- [ ] 포트 충돌 없음
- [ ] 개발용 bind mount 제거 (프로덕션)

**테스트 명령:**
```bash
docker compose config  # 문법 검증
docker compose up --build -d
docker compose ps  # 모든 서비스 healthy 확인
```
