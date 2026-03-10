#!/usr/bin/env bash

# init-docker.sh - Initialize Docker environment for FastAPI + Next.js project
# Usage: ./init-docker.sh <project-name>

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handler
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Info message
info() {
    echo -e "${BLUE}→ $1${NC}"
}

# Warning message
warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if project name provided
if [ $# -lt 1 ]; then
    error_exit "Usage: $0 <project-name>"
fi

PROJECT_NAME="$1"
PROJECT_DIR="$(pwd)"

info "Initializing Docker environment for: $PROJECT_NAME"

# Check if backend and frontend directories exist
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    error_exit "backend/ and frontend/ directories must exist"
fi

# ===========================
# 1. Create Backend Dockerfile
# ===========================
info "Creating backend/Dockerfile..."

cat > backend/Dockerfile << 'EOF'
# Multi-stage build for FastAPI
FROM python:3.11-slim as builder

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim

WORKDIR /app

# Copy installed packages
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Set environment
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health', timeout=5)"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

success "backend/Dockerfile created"

# ===========================
# 2. Create Frontend Dockerfile
# ===========================
info "Creating frontend/Dockerfile..."

cat > frontend/Dockerfile << 'EOF'
# Multi-stage build for Next.js
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat

WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:20-alpine AS builder

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build Next.js
RUN npm run build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy necessary files
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
EOF

success "frontend/Dockerfile created"

# ===========================
# 3. Create .dockerignore
# ===========================
info "Creating .dockerignore files..."

cat > backend/.dockerignore << 'EOF'
# Python
__pycache__
*.pyc
*.pyo
*.pyd
.pytest_cache
.venv
venv
.env
.env.local
test.db
*.db

# Git
.git
.gitignore

# IDE
.vscode
.idea
*.swp

# Docker
Dockerfile
.dockerignore

# Tests
tests/
*.test.py
EOF

cat > frontend/.dockerignore << 'EOF'
# Node
node_modules
.next
out
.vercel
*.tsbuildinfo

# Environment
.env*.local
.env

# Git
.git
.gitignore

# IDE
.vscode
.idea

# Docker
Dockerfile
.dockerignore

# Tests
__tests__
*.test.ts
*.test.tsx
*.spec.ts
EOF

success ".dockerignore files created"

# ===========================
# 4. Create docker-compose.yml
# ===========================
info "Creating docker-compose.yml..."

cat > docker-compose.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: \${PROJECT_NAME:-${PROJECT_NAME}}_postgres
    environment:
      POSTGRES_USER: \${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD:-postgres}
      POSTGRES_DB: \${POSTGRES_DB:-appdb}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "\${POSTGRES_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - app_network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: \${PROJECT_NAME:-${PROJECT_NAME}}_backend
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://\${POSTGRES_USER:-postgres}:\${POSTGRES_PASSWORD:-postgres}@postgres:5432/\${POSTGRES_DB:-appdb}
      SECRET_KEY: \${SECRET_KEY}
      ALGORITHM: \${ALGORITHM:-HS256}
      ACCESS_TOKEN_EXPIRE_MINUTES: \${ACCESS_TOKEN_EXPIRE_MINUTES:-30}
      BACKEND_CORS_ORIGINS: \${BACKEND_CORS_ORIGINS:-["http://localhost:3000"]}
    ports:
      - "\${BACKEND_PORT:-8000}:8000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped
    networks:
      - app_network
    command: >
      sh -c "alembic upgrade head &&
             uvicorn main:app --host 0.0.0.0 --port 8000"

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: \${PROJECT_NAME:-${PROJECT_NAME}}_frontend
    depends_on:
      backend:
        condition: service_healthy
    environment:
      NEXT_PUBLIC_API_URL: \${NEXT_PUBLIC_API_URL:-http://localhost:8000/api}
    ports:
      - "\${FRONTEND_PORT:-3000}:3000"
    restart: unless-stopped
    networks:
      - app_network

volumes:
  postgres_data:
    driver: local

networks:
  app_network:
    driver: bridge
EOF

success "docker-compose.yml created"

# ===========================
# 5. Create .env template
# ===========================
info "Creating .env.example..."

cat > .env.example << EOF
# Project
PROJECT_NAME=${PROJECT_NAME}

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=CHANGE_THIS_IN_PRODUCTION
POSTGRES_DB=appdb
POSTGRES_PORT=5432

# Backend
BACKEND_PORT=8000
SECRET_KEY=CHANGE_THIS_SECURE_RANDOM_KEY_MIN_32_CHARS
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
BACKEND_CORS_ORIGINS=["http://localhost:3000"]

# Frontend
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://localhost:8000/api
EOF

success ".env.example created"

# ===========================
# 6. Check for .env file
# ===========================
if [ -f ".env" ]; then
    warn ".env file already exists. Skipping creation."
else
    info "Creating .env from template..."
    cp .env.example .env
    success ".env created (remember to update SECRET_KEY and POSTGRES_PASSWORD)"
fi

# ===========================
# 7. Add to .gitignore
# ===========================
if [ -f ".gitignore" ]; then
    if ! grep -q "^\.env$" .gitignore; then
        echo ".env" >> .gitignore
        success "Added .env to .gitignore"
    fi
else
    echo ".env" > .gitignore
    success "Created .gitignore with .env"
fi

# ===========================
# 8. Summary
# ===========================
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Docker environment initialized successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "Project: ${YELLOW}${PROJECT_NAME}${NC}"
echo -e "Location: ${YELLOW}${PROJECT_DIR}${NC}"
echo ""
echo "Files created:"
echo "  ✓ backend/Dockerfile"
echo "  ✓ frontend/Dockerfile"
echo "  ✓ backend/.dockerignore"
echo "  ✓ frontend/.dockerignore"
echo "  ✓ docker-compose.yml"
echo "  ✓ .env.example"
echo "  ✓ .env (if not exists)"
echo ""
echo -e "${YELLOW}⚠ IMPORTANT: Update .env file with secure values:${NC}"
echo "  - SECRET_KEY (min 32 random characters)"
echo "  - POSTGRES_PASSWORD (strong password)"
echo ""
echo "Next steps:"
echo "  1. Edit .env and set SECRET_KEY and POSTGRES_PASSWORD"
echo "  2. Ensure backend has /health endpoint"
echo "  3. Ensure frontend has output: 'standalone' in next.config.js"
echo "  4. Run: docker compose build"
echo "  5. Run: docker compose up -d"
echo "  6. Check: docker compose ps"
echo "  7. Test: curl http://localhost:8000/health"
echo ""
