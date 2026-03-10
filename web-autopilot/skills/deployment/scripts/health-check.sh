#!/usr/bin/env bash

# health-check.sh - Verify all services are healthy
# Usage: ./health-check.sh

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load .env if exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

BACKEND_PORT=${BACKEND_PORT:-8000}
FRONTEND_PORT=${FRONTEND_PORT:-3000}
POSTGRES_PORT=${POSTGRES_PORT:-5432}

echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Service Health Check${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""

FAILED=0

# ===========================
# 1. Check Docker Compose
# ===========================
echo -e "${BLUE}[1/5] Checking Docker Compose status...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found${NC}"
    exit 1
fi

if ! docker compose ps &> /dev/null; then
    echo -e "${RED}✗ Docker Compose not running${NC}"
    exit 1
fi

SERVICES=$(docker compose ps --format json 2>/dev/null | jq -r '.Name' 2>/dev/null || docker compose ps --services)

if [ -z "$SERVICES" ]; then
    echo -e "${RED}✗ No services found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker Compose is running${NC}"
echo ""

# ===========================
# 2. Check PostgreSQL
# ===========================
echo -e "${BLUE}[2/5] Checking PostgreSQL...${NC}"

POSTGRES_HEALTH=$(docker compose ps postgres --format json 2>/dev/null | jq -r '.Health' 2>/dev/null || echo "unknown")

if [ "$POSTGRES_HEALTH" = "healthy" ]; then
    echo -e "${GREEN}✓ PostgreSQL is healthy${NC}"
else
    echo -e "${RED}✗ PostgreSQL is not healthy (status: $POSTGRES_HEALTH)${NC}"
    FAILED=1
fi

# Test connection
if nc -z localhost $POSTGRES_PORT 2>/dev/null || timeout 1 bash -c "echo > /dev/tcp/localhost/$POSTGRES_PORT" 2>/dev/null; then
    echo -e "${GREEN}✓ PostgreSQL port $POSTGRES_PORT is accessible${NC}"
else
    echo -e "${YELLOW}⚠ PostgreSQL port $POSTGRES_PORT not accessible from host${NC}"
fi

echo ""

# ===========================
# 3. Check Backend
# ===========================
echo -e "${BLUE}[3/5] Checking Backend API...${NC}"

BACKEND_HEALTH=$(docker compose ps backend --format json 2>/dev/null | jq -r '.Health' 2>/dev/null || echo "unknown")

if [ "$BACKEND_HEALTH" = "healthy" ]; then
    echo -e "${GREEN}✓ Backend is healthy${NC}"
else
    echo -e "${RED}✗ Backend is not healthy (status: $BACKEND_HEALTH)${NC}"
    FAILED=1
fi

# Test health endpoint
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT/health 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    HEALTH_RESPONSE=$(curl -s http://localhost:$BACKEND_PORT/health 2>/dev/null || echo "{}")
    echo -e "${GREEN}✓ Backend /health endpoint responds: $HEALTH_RESPONSE${NC}"
else
    echo -e "${RED}✗ Backend /health endpoint failed (HTTP $HTTP_CODE)${NC}"
    FAILED=1
fi

# Test API docs
DOCS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT/docs 2>/dev/null || echo "000")

if [ "$DOCS_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Backend /docs accessible${NC}"
else
    echo -e "${YELLOW}⚠ Backend /docs not accessible (HTTP $DOCS_CODE)${NC}"
fi

echo ""

# ===========================
# 4. Check Frontend
# ===========================
echo -e "${BLUE}[4/5] Checking Frontend...${NC}"

FRONTEND_STATUS=$(docker compose ps frontend --format "{{.Status}}" 2>/dev/null || echo "unknown")

if echo "$FRONTEND_STATUS" | grep -q "Up"; then
    echo -e "${GREEN}✓ Frontend is running${NC}"
else
    echo -e "${RED}✗ Frontend is not running (status: $FRONTEND_STATUS)${NC}"
    FAILED=1
fi

# Test frontend
FRONTEND_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$FRONTEND_PORT 2>/dev/null || echo "000")

if [ "$FRONTEND_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Frontend responds (HTTP $FRONTEND_CODE)${NC}"
else
    echo -e "${RED}✗ Frontend not accessible (HTTP $FRONTEND_CODE)${NC}"
    FAILED=1
fi

echo ""

# ===========================
# 5. Check Service Logs
# ===========================
echo -e "${BLUE}[5/5] Checking for errors in logs...${NC}"

# Check for recent errors
BACKEND_ERRORS=$(docker compose logs backend --tail=50 2>/dev/null | grep -iE "error|exception|failed" | wc -l || echo "0")
FRONTEND_ERRORS=$(docker compose logs frontend --tail=50 2>/dev/null | grep -iE "error|exception|failed" | wc -l || echo "0")

if [ "$BACKEND_ERRORS" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $BACKEND_ERRORS error lines in backend logs${NC}"
    echo "  Run: docker compose logs backend --tail=50 | grep -i error"
else
    echo -e "${GREEN}✓ No errors in backend logs${NC}"
fi

if [ "$FRONTEND_ERRORS" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $FRONTEND_ERRORS error lines in frontend logs${NC}"
    echo "  Run: docker compose logs frontend --tail=50 | grep -i error"
else
    echo -e "${GREEN}✓ No errors in frontend logs${NC}"
fi

echo ""

# ===========================
# Summary
# ===========================
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}  ✓ All health checks passed!${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    echo "Service URLs:"
    echo "  • API Health:  http://localhost:$BACKEND_PORT/health"
    echo "  • API Docs:    http://localhost:$BACKEND_PORT/docs"
    echo "  • Frontend:    http://localhost:$FRONTEND_PORT"
    echo "  • PostgreSQL:  localhost:$POSTGRES_PORT"
    echo ""
    exit 0
else
    echo -e "${RED}  ✗ Some health checks failed${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    echo "Troubleshooting commands:"
    echo "  • docker compose ps                 # Check service status"
    echo "  • docker compose logs backend       # Backend logs"
    echo "  • docker compose logs frontend      # Frontend logs"
    echo "  • docker compose logs postgres      # Database logs"
    echo "  • docker compose restart <service>  # Restart specific service"
    echo ""
    exit 1
fi
