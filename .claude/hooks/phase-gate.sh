#!/bin/bash
# Phase Gate Hook
# Stop 이벤트 시 실행
# projects/ 하위의 모든 프로젝트에 대해 산출물 존재 및 유효성 검증

GREEN="✅"
RED="❌"
WARN="⚠️"

# projects/ 디렉토리가 없으면 종료
if [ ! -d "projects" ]; then
    exit 0
fi

# projects/ 하위 프로젝트 탐색
PROJECT_DIRS=$(find projects/ -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

if [ -z "$PROJECT_DIRS" ]; then
    exit 0
fi

echo "📊 Phase Gate 검증 시작..."
echo ""

for PROJECT_DIR in $PROJECT_DIRS; do
    PROJECT_NAME=$(basename "$PROJECT_DIR")
    echo "━━━ 프로젝트: $PROJECT_NAME ━━━"

    ISSUES=0

    # Phase 1
    if [ -f "$PROJECT_DIR/docs/specs/requirements.md" ] && [ -s "$PROJECT_DIR/docs/specs/requirements.md" ]; then
        echo "$GREEN Phase 1 (Research): requirements.md"
    else
        echo "$RED Phase 1 (Research): requirements.md 없음"
    fi

    # Phase 2
    if [ -f "$PROJECT_DIR/docs/specs/technical-spec.md" ]; then
        echo "$GREEN Phase 2 (Architect): technical-spec.md"
    else
        echo "$RED Phase 2 (Architect): technical-spec.md 없음"
    fi

    if [ -f "$PROJECT_DIR/docs/api/api-spec.md" ]; then
        echo "$GREEN Phase 2 (Architect): api-spec.md"
    else
        echo "$RED Phase 2 (Architect): api-spec.md 없음"
    fi

    # Phase 3
    TEST_COUNT=$(find "$PROJECT_DIR/backend/tests/" "$PROJECT_DIR/frontend/tests/" -type f \
        \( -name "test_*.py" -o -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" \) \
        2>/dev/null | wc -l | tr -d ' ')
    SRC_COUNT=$(find "$PROJECT_DIR/backend/src/" "$PROJECT_DIR/frontend/src/" -type f \
        \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" \) \
        ! -name "__init__.py" ! -name "*.d.ts" \
        2>/dev/null | wc -l | tr -d ' ')

    if [ "$TEST_COUNT" -gt 0 ]; then
        echo "$GREEN Phase 3 (TDD): 테스트 ${TEST_COUNT}개"
    else
        echo "$RED Phase 3 (TDD): 테스트 없음"
    fi

    if [ "$SRC_COUNT" -gt 0 ]; then
        echo "$GREEN Phase 3 (TDD): 소스 ${SRC_COUNT}개"
    else
        echo "$RED Phase 3 (TDD): 소스 없음"
    fi

    # Phase 3 테스트 실행
    if [ "$TEST_COUNT" -gt 0 ] && [ "$SRC_COUNT" -gt 0 ]; then
        if command -v pytest &> /dev/null && [ -d "$PROJECT_DIR/backend/tests" ]; then
            if pytest "$PROJECT_DIR/backend/tests/" --tb=short -q 2>/dev/null; then
                echo "$GREEN 백엔드 테스트 통과"
            else
                echo "$RED 백엔드 테스트 실패"
                ISSUES=$((ISSUES + 1))
            fi
        fi
    fi

    # Phase 4
    if [ -f "$PROJECT_DIR/docs/reviews/review-report.md" ]; then
        if grep -q "REVIEW_FAILED" "$PROJECT_DIR/docs/reviews/review-report.md" 2>/dev/null; then
            echo "$RED Phase 4 (Review): REVIEW_FAILED"
            ISSUES=$((ISSUES + 1))
        else
            echo "$GREEN Phase 4 (Review): 통과"
        fi
    else
        echo "$RED Phase 4 (Review): review-report.md 없음"
    fi

    # Phase 5
    if [ -f "$PROJECT_DIR/docker-compose.yml" ]; then
        echo "$GREEN Phase 5 (Integrate): docker-compose.yml"
    else
        echo "$RED Phase 5 (Integrate): docker-compose.yml 없음"
    fi

    if [ -f "$PROJECT_DIR/README.md" ]; then
        echo "$GREEN Phase 5 (Integrate): README.md"
    else
        echo "$RED Phase 5 (Integrate): README.md 없음"
    fi

    if [ "$ISSUES" -gt 0 ]; then
        echo "$WARN ${ISSUES}건의 이슈"
    fi
    echo ""
done

# 항상 exit 0 (비차단)
exit 0
