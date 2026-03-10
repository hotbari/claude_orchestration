#!/usr/bin/env bash

# run-tests.sh - Run all tests for backend and frontend
# Usage: ./run-tests.sh [--backend-only|--frontend-only] [--verbose]

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
VERBOSE=false

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
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --backend-only     Run only backend tests"
            echo "  --frontend-only    Run only frontend tests"
            echo "  --verbose, -v      Show verbose output"
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

# Track results
BACKEND_PASSED=false
FRONTEND_PASSED=false
BACKEND_OUTPUT=""
FRONTEND_OUTPUT=""

# Run backend tests
run_backend_tests() {
    print_header "BACKEND TESTS (pytest)"

    # Find backend directory
    BACKEND_DIR=""
    if [ -d "backend" ]; then
        BACKEND_DIR="backend"
    elif [ -f "requirements.txt" ] && [ -f "pytest.ini" ]; then
        BACKEND_DIR="."
    else
        error "Backend directory not found"
        return 1
    fi

    info "Running tests in: $BACKEND_DIR"

    # Check if pytest is available
    if ! command -v pytest &> /dev/null; then
        error "pytest is not installed"
        echo "  Install with: pip install pytest"
        return 1
    fi

    # Change to backend directory
    cd "$BACKEND_DIR" || return 1

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

    # Run pytest
    if [ "$VERBOSE" = true ]; then
        pytest -v --tb=short --color=yes
    else
        BACKEND_OUTPUT=$(pytest --tb=short --color=yes 2>&1)
    fi

    BACKEND_EXIT_CODE=$?

    # Store output
    if [ "$VERBOSE" = false ]; then
        echo "$BACKEND_OUTPUT"
    fi

    cd - > /dev/null || return 1

    if [ $BACKEND_EXIT_CODE -eq 0 ]; then
        BACKEND_PASSED=true
        success "Backend tests passed"
        return 0
    else
        error "Backend tests failed"
        return 1
    fi
}

# Run frontend tests
run_frontend_tests() {
    print_header "FRONTEND TESTS (npm test)"

    # Find frontend directory
    FRONTEND_DIR=""
    if [ -d "frontend" ]; then
        FRONTEND_DIR="frontend"
    elif [ -f "package.json" ] && [ -d "src" ]; then
        FRONTEND_DIR="."
    else
        error "Frontend directory not found"
        return 1
    fi

    info "Running tests in: $FRONTEND_DIR"

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        error "npm is not installed"
        return 1
    fi

    # Change to frontend directory
    cd "$FRONTEND_DIR" || return 1

    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        error "node_modules not found"
        echo "  Run: npm install"
        cd - > /dev/null || return 1
        return 1
    fi

    # Check if test script exists
    if ! grep -q '"test"' package.json; then
        error "No test script found in package.json"
        cd - > /dev/null || return 1
        return 1
    fi

    # Run npm test
    if [ "$VERBOSE" = true ]; then
        npm test -- --passWithNoTests --watchAll=false
    else
        FRONTEND_OUTPUT=$(npm test -- --passWithNoTests --watchAll=false 2>&1)
    fi

    FRONTEND_EXIT_CODE=$?

    # Store output
    if [ "$VERBOSE" = false ]; then
        echo "$FRONTEND_OUTPUT"
    fi

    cd - > /dev/null || return 1

    if [ $FRONTEND_EXIT_CODE -eq 0 ]; then
        FRONTEND_PASSED=true
        success "Frontend tests passed"
        return 0
    else
        error "Frontend tests failed"
        return 1
    fi
}

# Main execution
main() {
    print_header "RUNNING ALL TESTS"

    OVERALL_SUCCESS=true

    # Run backend tests
    if [ "$RUN_BACKEND" = true ]; then
        if ! run_backend_tests; then
            OVERALL_SUCCESS=false
        fi
    fi

    # Run frontend tests
    if [ "$RUN_FRONTEND" = true ]; then
        if ! run_frontend_tests; then
            OVERALL_SUCCESS=false
        fi
    fi

    # Print summary
    print_header "TEST SUMMARY"

    if [ "$RUN_BACKEND" = true ]; then
        if [ "$BACKEND_PASSED" = true ]; then
            success "Backend: PASSED"
        else
            error "Backend: FAILED"
        fi
    fi

    if [ "$RUN_FRONTEND" = true ]; then
        if [ "$FRONTEND_PASSED" = true ]; then
            success "Frontend: PASSED"
        else
            error "Frontend: FAILED"
        fi
    fi

    echo ""

    if [ "$OVERALL_SUCCESS" = true ]; then
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  ALL TESTS PASSED ✓${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo ""
        exit 0
    else
        echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}  SOME TESTS FAILED ✗${NC}"
        echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
        echo ""
        exit 1
    fi
}

# Run main function
main
