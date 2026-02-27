#!/usr/bin/env bash

# check-types.sh - Check types for backend (mypy) and frontend (tsc)
# Usage: ./check-types.sh [--backend-only|--frontend-only] [--strict]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
RUN_BACKEND=true
RUN_FRONTEND=true
STRICT_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backend-only)
            RUN_FRONTEND=false
            shift
            ;;
        --frontend-only)
            RUN_BACKEND=false
            shift
            ;;
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --backend-only     Check only backend types"
            echo "  --frontend-only    Check only frontend types"
            echo "  --strict           Enable strict type checking"
            echo "  --help, -h         Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Print section header
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Print success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message
error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print info message
info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Print warning message
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Track results
BACKEND_PASSED=false
FRONTEND_PASSED=false
BACKEND_OUTPUT=""
FRONTEND_OUTPUT=""
BACKEND_ERROR_COUNT=0
FRONTEND_ERROR_COUNT=0

# Check backend types with mypy
check_backend_types() {
    print_header "BACKEND TYPE CHECKING (mypy)"

    # Find backend directory
    BACKEND_DIR=""
    if [ -d "backend" ]; then
        BACKEND_DIR="backend"
    elif [ -f "requirements.txt" ] && [ -d "app" ]; then
        BACKEND_DIR="."
    elif [ -f "requirements.txt" ]; then
        BACKEND_DIR="."
    else
        error "Backend directory not found"
        return 1
    fi

    info "Checking types in: $BACKEND_DIR"

    # Change to backend directory
    cd "$BACKEND_DIR" || return 1

    # Check if mypy is available
    if ! command -v mypy &> /dev/null; then
        warning "mypy is not installed"
        echo "  Install with: pip install mypy"
        cd - > /dev/null || return 1
        return 1
    fi

    # Check if virtual environment exists
    if [ -d "venv" ] || [ -d ".venv" ]; then
        VENV_DIR="venv"
        [ -d ".venv" ] && VENV_DIR=".venv"

        info "Activating virtual environment: $VENV_DIR"
        if [ -f "$VENV_DIR/bin/activate" ]; then
            source "$VENV_DIR/bin/activate"
        elif [ -f "$VENV_DIR/Scripts/activate" ]; then
            source "$VENV_DIR/Scripts/activate"
        fi
    fi

    # Find Python package directory
    PACKAGE_DIR=""
    if [ -d "app" ]; then
        PACKAGE_DIR="app"
    else
        # Find first directory with __init__.py
        for dir in */; do
            if [ -f "${dir}__init__.py" ]; then
                PACKAGE_DIR="${dir%/}"
                break
            fi
        done
    fi

    if [ -z "$PACKAGE_DIR" ]; then
        warning "No Python package directory found"
        cd - > /dev/null || return 1
        return 1
    fi

    info "Checking package: $PACKAGE_DIR"

    # Build mypy command
    MYPY_CMD="mypy $PACKAGE_DIR"

    if [ "$STRICT_MODE" = true ]; then
        MYPY_CMD="$MYPY_CMD --strict"
        info "Running in strict mode"
    fi

    # Check if mypy.ini or setup.cfg exists
    if [ -f "mypy.ini" ]; then
        info "Using mypy.ini configuration"
    elif [ -f "setup.cfg" ]; then
        info "Using setup.cfg configuration"
    elif [ -f "pyproject.toml" ]; then
        info "Using pyproject.toml configuration"
    fi

    # Run mypy
    BACKEND_OUTPUT=$($MYPY_CMD 2>&1) || true
    BACKEND_EXIT_CODE=$?

    # Display output
    if [ -n "$BACKEND_OUTPUT" ]; then
        echo "$BACKEND_OUTPUT"
    fi

    # Count errors
    BACKEND_ERROR_COUNT=$(echo "$BACKEND_OUTPUT" | grep -c "error:" || true)

    cd - > /dev/null || return 1

    if [ $BACKEND_EXIT_CODE -eq 0 ]; then
        BACKEND_PASSED=true
        success "Backend types: No errors found"
        return 0
    else
        error "Backend types: $BACKEND_ERROR_COUNT error(s) found"
        return 1
    fi
}

# Check frontend types with TypeScript compiler
check_frontend_types() {
    print_header "FRONTEND TYPE CHECKING (tsc)"

    # Find frontend directory
    FRONTEND_DIR=""
    if [ -d "frontend" ]; then
        FRONTEND_DIR="frontend"
    elif [ -f "package.json" ] && [ -f "tsconfig.json" ]; then
        FRONTEND_DIR="."
    else
        error "Frontend directory not found"
        return 1
    fi

    info "Checking types in: $FRONTEND_DIR"

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        error "npm is not installed"
        return 1
    fi

    # Change to frontend directory
    cd "$FRONTEND_DIR" || return 1

    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        warning "node_modules not found"
        echo "  Run: npm install"
        cd - > /dev/null || return 1
        return 1
    fi

    # Check if TypeScript is installed
    if [ ! -f "node_modules/.bin/tsc" ] && [ ! -f "node_modules/.bin/tsc.cmd" ]; then
        warning "TypeScript is not installed"
        echo "  Install with: npm install --save-dev typescript"
        cd - > /dev/null || return 1
        return 1
    fi

    # Check if tsconfig.json exists
    if [ ! -f "tsconfig.json" ]; then
        error "tsconfig.json not found"
        cd - > /dev/null || return 1
        return 1
    fi

    info "Using tsconfig.json configuration"

    # Build tsc command
    TSC_CMD="npx tsc --noEmit"

    if [ "$STRICT_MODE" = true ]; then
        TSC_CMD="$TSC_CMD --strict"
        info "Running in strict mode"
    fi

    # Run tsc
    FRONTEND_OUTPUT=$($TSC_CMD 2>&1) || true
    FRONTEND_EXIT_CODE=$?

    # Display output
    if [ -n "$FRONTEND_OUTPUT" ]; then
        echo "$FRONTEND_OUTPUT"
    fi

    # Count errors
    FRONTEND_ERROR_COUNT=$(echo "$FRONTEND_OUTPUT" | grep -c "error TS" || true)

    cd - > /dev/null || return 1

    if [ $FRONTEND_EXIT_CODE -eq 0 ]; then
        FRONTEND_PASSED=true
        success "Frontend types: No errors found"
        return 0
    else
        error "Frontend types: $FRONTEND_ERROR_COUNT error(s) found"
        return 1
    fi
}

# Main execution
main() {
    print_header "TYPE CHECKING"

    OVERALL_SUCCESS=true

    # Check backend types
    if [ "$RUN_BACKEND" = true ]; then
        if ! check_backend_types; then
            OVERALL_SUCCESS=false
        fi
    fi

    # Check frontend types
    if [ "$RUN_FRONTEND" = true ]; then
        if ! check_frontend_types; then
            OVERALL_SUCCESS=false
        fi
    fi

    # Print summary
    print_header "TYPE CHECK SUMMARY"

    if [ "$RUN_BACKEND" = true ]; then
        if [ "$BACKEND_PASSED" = true ]; then
            success "Backend: PASSED (0 errors)"
        else
            error "Backend: FAILED ($BACKEND_ERROR_COUNT errors)"
        fi
    fi

    if [ "$RUN_FRONTEND" = true ]; then
        if [ "$FRONTEND_PASSED" = true ]; then
            success "Frontend: PASSED (0 errors)"
        else
            error "Frontend: FAILED ($FRONTEND_ERROR_COUNT errors)"
        fi
    fi

    echo ""

    if [ "$OVERALL_SUCCESS" = true ]; then
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  ALL TYPE CHECKS PASSED ✓${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo ""
        exit 0
    else
        echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}  TYPE CHECK FAILED ✗${NC}"
        echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
        echo ""

        # Show total error count
        TOTAL_ERRORS=$((BACKEND_ERROR_COUNT + FRONTEND_ERROR_COUNT))
        if [ $TOTAL_ERRORS -gt 0 ]; then
            echo -e "${YELLOW}Total errors: $TOTAL_ERRORS${NC}"
            echo ""
        fi

        exit 1
    fi
}

# Run main function
main
