# 배포 체크리스트

**목적**: 배포 전 필수 확인 사항

---

## 🔒 보안

### 환경 변수
- [ ] `.env` 파일이 `.gitignore`에 포함됨
- [ ] `SECRET_KEY`가 32자 이상의 랜덤 문자열
- [ ] `POSTGRES_PASSWORD`가 강력한 비밀번호로 변경됨
- [ ] 프로덕션 키가 하드코딩되지 않음
- [ ] `.env.example`에 placeholder만 존재

### 컨테이너
- [ ] Non-root 사용자 설정
- [ ] 불필요한 포트 노출 제거
- [ ] 최소 권한 base image (slim/alpine)
- [ ] Secrets가 Dockerfile에 하드코딩되지 않음

### 네트워크
- [ ] DB 포트가 외부에 노출되지 않음 (내부 네트워크만)
- [ ] CORS origins가 프로덕션 도메인으로 제한됨
- [ ] Rate limiting 설정 (선택)

---

## 🐳 Docker

### Dockerfile
- [ ] Multi-stage build 사용
- [ ] `.dockerignore` 파일 존재
- [ ] Health check 정의됨
- [ ] CMD/ENTRYPOINT 명확히 설정
- [ ] 불필요한 파일 제외 (.git, tests 등)

### docker-compose.yml
- [ ] 모든 서비스에 health check 존재
- [ ] `depends_on`에 health 조건 설정
- [ ] 볼륨으로 데이터 영속성 확보
- [ ] `restart: unless-stopped` 설정
- [ ] 환경 변수가 `.env` 파일 참조

---

## 🗄️ 데이터베이스

### PostgreSQL
- [ ] 볼륨으로 데이터 디렉토리 마운트
- [ ] Health check가 `pg_isready` 사용
- [ ] 기본 포트(5432) 사용 또는 커스텀 포트 설정
- [ ] `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` 설정

### 마이그레이션
- [ ] Alembic 마이그레이션 파일 존재
- [ ] `alembic upgrade head`가 시작 명령에 포함
- [ ] 마이그레이션 실패 시 컨테이너 중지 로직

---

## 🔧 Backend (FastAPI)

### 코드
- [ ] `/health` 엔드포인트 구현
- [ ] CORS 설정이 환경 변수로 관리
- [ ] 데이터베이스 연결 풀 설정
- [ ] 로깅 설정 (stdout으로 출력)

### Dockerfile
- [ ] `uvicorn` 명령어 정확
- [ ] 포트 8000 EXPOSE
- [ ] 의존성 설치 전 `requirements.txt` COPY

### Health Check
- [ ] `start_period` 충분히 설정 (마이그레이션 시간)
- [ ] `retries` 3회 이상
- [ ] `/health` 엔드포인트가 200 응답

---

## 🎨 Frontend (Next.js)

### 코드
- [ ] `next.config.js`에 `output: 'standalone'` 설정
- [ ] 환경 변수가 `NEXT_PUBLIC_` 접두사 사용
- [ ] API URL이 환경 변수로 관리

### Dockerfile
- [ ] Multi-stage build (deps → builder → runner)
- [ ] `.next/standalone` 복사
- [ ] 포트 3000 EXPOSE
- [ ] `NODE_ENV=production` 설정

---

## 🌐 네트워크

### 포트 매핑
- [ ] PostgreSQL: 5432 (또는 커스텀)
- [ ] Backend: 8000 (또는 커스텀)
- [ ] Frontend: 3000 (또는 커스텀)
- [ ] 포트 충돌 없음 확인

### 서비스 통신
- [ ] Backend → PostgreSQL (내부 네트워크)
- [ ] Frontend → Backend (API URL)
- [ ] 모든 서비스가 같은 네트워크

---

## 📦 볼륨

### 데이터 영속성
- [ ] PostgreSQL 데이터: Named volume
- [ ] 업로드 파일: Named volume (필요 시)
- [ ] 로그 파일: Bind mount (선택)

### 권한
- [ ] 볼륨 소유자가 컨테이너 사용자와 일치
- [ ] 쓰기 권한 확인

---

## 🧪 테스트

### 로컬 테스트
```bash
# 빌드 테스트
docker compose build

# 시작 테스트
docker compose up -d

# Health check 확인
docker compose ps

# 로그 확인
docker compose logs -f
```

### API 테스트
```bash
# Health endpoint
curl http://localhost:8000/health
# 예상: {"status": "healthy"}

# API Docs
curl http://localhost:8000/docs
# 예상: HTML 응답 (OpenAPI)

# Frontend
curl http://localhost:3000
# 예상: HTML 응답
```

### 데이터베이스 테스트
```bash
# 컨테이너 접속
docker compose exec postgres psql -U postgres -d appdb

# 테이블 확인
\dt

# 종료
\q
```

---

## 🚀 배포 실행

### 1. 준비
```bash
# 환경 변수 복사 및 수정
cp .env.example .env
nano .env  # SECRET_KEY, POSTGRES_PASSWORD 등 변경
```

### 2. 빌드
```bash
docker compose build --no-cache
```

### 3. 시작
```bash
docker compose up -d
```

### 4. 검증
```bash
# 서비스 상태
docker compose ps

# 로그 확인
docker compose logs backend
docker compose logs frontend

# Health check
curl http://localhost:8000/health
curl http://localhost:3000
```

---

## 🔍 모니터링

### 로그 확인
```bash
# 실시간 로그
docker compose logs -f

# 특정 서비스
docker compose logs -f backend

# 최근 100줄
docker compose logs --tail=100 backend
```

### 리소스 사용량
```bash
docker stats
```

### 컨테이너 상태
```bash
docker compose ps
```

---

## 🛠️ 트러블슈팅

### 서비스가 시작되지 않을 때
```bash
# 로그 확인
docker compose logs [service_name]

# 컨테이너 재시작
docker compose restart [service_name]

# 강제 재생성
docker compose up -d --force-recreate [service_name]
```

### 포트 충돌
```bash
# 사용 중인 포트 확인 (Windows)
netstat -ano | findstr :8000

# .env 파일에서 포트 변경
BACKEND_PORT=8001
```

### 데이터베이스 연결 실패
```bash
# PostgreSQL 로그 확인
docker compose logs postgres

# Health check 상태
docker compose ps postgres

# DATABASE_URL 확인
docker compose exec backend env | grep DATABASE_URL
```

### 이미지 빌드 실패
```bash
# 캐시 없이 재빌드
docker compose build --no-cache

# 기존 이미지 삭제
docker compose down --rmi all
docker compose build
```

---

## ✅ 배포 완료 확인

모든 항목이 체크되어야 배포 완료:

- [ ] `docker compose ps`에서 모든 서비스 healthy
- [ ] Backend `/health` 응답 200
- [ ] Frontend 접근 가능
- [ ] 데이터베이스 마이그레이션 완료
- [ ] 로그에 에러 없음
- [ ] `.env`에 프로덕션 secrets 설정
- [ ] 불필요한 포트 노출 없음

**배포 성공!** 🎉

---

## 📝 배포 후

### 정기 점검
- [ ] 로그 모니터링 (주 1회)
- [ ] 디스크 사용량 확인
- [ ] 보안 업데이트 적용
- [ ] 백업 설정 (PostgreSQL 볼륨)

### 업데이트 절차
```bash
# 1. 최신 코드 pull
git pull origin main

# 2. 이미지 재빌드
docker compose build

# 3. 무중단 재시작
docker compose up -d --no-deps --build backend
docker compose up -d --no-deps --build frontend

# 4. 검증
docker compose ps
curl http://localhost:8000/health
```

### 백업 (PostgreSQL)
```bash
# 백업 생성
docker compose exec postgres pg_dump -U postgres appdb > backup_$(date +%Y%m%d).sql

# 복원
docker compose exec -T postgres psql -U postgres appdb < backup_20240305.sql
```

---

## 🆘 긴급 중단

```bash
# 모든 서비스 중지
docker compose down

# 볼륨 포함 완전 삭제 (주의!)
docker compose down -v
```
