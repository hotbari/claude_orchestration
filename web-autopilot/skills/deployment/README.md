# Deployment Skill

**Phase 5**: Infrastructure setup and containerized deployment with Docker Compose

**Goal**: Execute `docker compose up --build -d` to run the entire stack

---

## 개요

Backend + Frontend + PostgreSQL을 Docker 컨테이너로 패키징하고 Docker Compose로 오케스트레이션하여 배포합니다.

---

## 전제 조건

- **Phase 4 (Implementation)** 완료
- Backend 코드 (FastAPI)
- Frontend 코드 (Next.js)
- Docker 및 Docker Compose 설치됨

---

## Agent

**infrastructure-deployer** (Opus)
- Docker 환경 구성 (Dockerfile, docker-compose.yml)
- 환경 변수 관리
- 서비스 오케스트레이션
- `docker compose up --build -d` 실행

📄 [Agent 정의](../../agents/infrastructure-deployer.md)

---

## 빠른 시작

### 자동 초기화 (권장)

```bash
# 프로젝트 루트에서
cd skills/deployment/scripts
./init-docker.sh <project-name>

# .env 파일 편집 (SECRET_KEY, POSTGRES_PASSWORD 변경)
nano .env

# 빌드 및 실행
docker compose up --build -d

# 헬스체크
./scripts/health-check.sh
```

### 수동 설정

[SKILL.md](./SKILL.md) 참조

---

## 디렉토리 구조

```
deployment/
├── SKILL.md                          # Skill 정의 및 워크플로우
├── README.md                         # 이 파일
├── references/
│   ├── docker-patterns.md            # Dockerfile 베스트 프랙티스
│   ├── docker-compose-guide.md       # Docker Compose 설정 가이드
│   └── deployment-checklist.md       # 배포 전 체크리스트
└── scripts/
    ├── init-docker.sh                # Docker 환경 자동 초기화
    └── health-check.sh               # 서비스 헬스체크 검증
```

---

## 주요 파일

### 1. Dockerfile (Backend)
```dockerfile
# Multi-stage build
# Stage 1: Builder (의존성)
# Stage 2: Runtime (slim image)
```

### 2. Dockerfile (Frontend)
```dockerfile
# Multi-stage build
# Stage 1: Dependencies
# Stage 2: Builder (Next.js build)
# Stage 3: Runner (standalone)
```

### 3. docker-compose.yml
```yaml
services:
  postgres:    # Health check + volumes
  backend:     # Depends on postgres (healthy)
  frontend:    # Depends on backend (healthy)
```

### 4. .env
```env
PROJECT_NAME=myapp
POSTGRES_PASSWORD=***
SECRET_KEY=***
BACKEND_PORT=8000
FRONTEND_PORT=3000
```

---

## 배포 워크플로우

```
Phase 5.1: Docker 환경 구성
  → Dockerfile 작성 (backend, frontend)
  → .dockerignore 생성

Phase 5.2: Docker Compose 오케스트레이션
  → docker-compose.yml 작성
  → .env 환경 변수 설정

Phase 5.3: 배포 실행
  → docker compose build
  → docker compose up --build -d
  → Health check 검증

Phase 5.4: 검증 완료
  ✅ PostgreSQL: Healthy
  ✅ Backend API: Healthy
  ✅ Frontend: Running
```

---

## 검증

### 서비스 상태
```bash
docker compose ps
```

**예상 출력:**
```
NAME                STATUS              PORTS
myapp_postgres      Up (healthy)        5432/tcp
myapp_backend       Up (healthy)        0.0.0.0:8000->8000/tcp
myapp_frontend      Up                  0.0.0.0:3000->3000/tcp
```

### API 테스트
```bash
curl http://localhost:8000/health
# {"status": "healthy", "database": "connected"}

curl http://localhost:8000/docs
# OpenAPI documentation

curl http://localhost:3000
# Next.js homepage
```

### 자동 헬스체크
```bash
./scripts/health-check.sh
```

---

## 트러블슈팅

### 포트 충돌
```bash
# .env에서 포트 변경
BACKEND_PORT=8001
FRONTEND_PORT=3001
```

### 빌드 실패
```bash
# 캐시 없이 재빌드
docker compose build --no-cache
```

### 데이터베이스 연결 실패
```bash
# PostgreSQL 로그 확인
docker compose logs postgres

# Health check 상태
docker compose ps postgres
```

### 로그 확인
```bash
# 실시간 로그
docker compose logs -f

# 특정 서비스
docker compose logs backend
docker compose logs frontend
```

---

## Reference 문서

- **[docker-patterns.md](./references/docker-patterns.md)**
  - Multi-stage builds
  - 레이어 캐싱 최적화
  - 보안 베스트 프랙티스
  - Health checks

- **[docker-compose-guide.md](./references/docker-compose-guide.md)**
  - Service 정의
  - depends_on 전략
  - 환경 변수 관리
  - 볼륨 및 네트워크

- **[deployment-checklist.md](./references/deployment-checklist.md)**
  - 보안 체크리스트
  - 배포 전 확인사항
  - 트러블슈팅 가이드

---

## 스크립트

### init-docker.sh
```bash
./scripts/init-docker.sh <project-name>
```
**기능:**
- Dockerfile 생성 (backend, frontend)
- docker-compose.yml 생성
- .env.example 및 .env 생성
- .dockerignore 생성
- .gitignore 업데이트

### health-check.sh
```bash
./scripts/health-check.sh
```
**기능:**
- Docker Compose 상태 확인
- PostgreSQL health check
- Backend API /health 엔드포인트 테스트
- Frontend 접근성 확인
- 로그 에러 검사

---

## 다음 단계

배포 완료 후:

1. **Phase 6 (QA)**: 통합 테스트 및 성능 검증
2. **CI/CD 설정**: GitHub Actions 자동 배포 (선택)
3. **모니터링**: 로깅 및 메트릭 수집 (선택)
4. **백업**: PostgreSQL 볼륨 정기 백업

---

## 요약

| 항목 | 설명 |
|------|------|
| **Input** | Backend + Frontend 코드 |
| **Output** | Running Docker Compose stack |
| **Agent** | infrastructure-deployer (Opus) |
| **Goal** | `docker compose up --build -d` 실행 |
| **Validation** | All services healthy |

**목표 달성 조건:**
```bash
$ docker compose ps
# 모든 서비스 Up (healthy)

$ curl http://localhost:8000/health
# {"status": "healthy"}

$ curl http://localhost:3000
# HTTP 200 OK
```

🎯 **배포 성공!**
