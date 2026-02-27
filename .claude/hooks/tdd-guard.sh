#!/bin/bash
# TDD Guard Hook
# PreToolUse (Write|Edit) 시 실행
# backend/src/ 또는 frontend/src/ 파일 편집 시 대응하는 tests/ 파일 존재 여부 확인

# stdin에서 JSON 입력 받기
INPUT=$(cat)

# tool_input에서 file_path 추출
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tool_input = data.get('tool_input', {})
    path = tool_input.get('file_path', tool_input.get('path', ''))
    print(path)
except:
    print('')
" 2>/dev/null)

# 파일 경로가 비어있으면 통과
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# projects/*/backend/src/ 또는 projects/*/frontend/src/ 파일이 아니면 통과
if [[ "$FILE_PATH" != *"projects/"*"/backend/src/"* ]] && [[ "$FILE_PATH" != *"projects/"*"/frontend/src/"* ]]; then
    exit 0
fi

# 예외 파일 패턴 (테스트 불필요)
BASENAME=$(basename "$FILE_PATH")
case "$BASENAME" in
    __init__.py|index.*|main.tsx|App.tsx|config.*|settings.*|types.*|schemas.*|conftest.py|*.d.ts|pyproject.toml|package.json|*.config.*|*.env*|nginx.conf|vite.config.*)
        exit 0
        ;;
esac

# 백엔드 Python 파일인 경우
# projects/xxx/backend/src/api/auth.py → projects/xxx/backend/tests/api/test_auth.py
if [[ "$FILE_PATH" == *"/backend/src/"*.py ]]; then
    TEST_PATH=$(echo "$FILE_PATH" | sed 's|/backend/src/|/backend/tests/|' | sed 's|/\([^/]*\)\.py$|/test_\1.py|')

    if [ ! -f "$TEST_PATH" ]; then
        echo "🔴 TDD violation: 테스트를 먼저 작성하세요!"
        echo ""
        echo "구현 파일: $FILE_PATH"
        echo "필요한 테스트: $TEST_PATH"
        echo ""
        echo "TDD 사이클: Red(테스트 작성) → Green(구현) → Refactor"
        echo "먼저 실패하는 테스트를 작성한 후 구현을 진행하세요."
        exit 2
    fi
fi

# 프론트엔드 TypeScript/React 파일인 경우
# projects/xxx/frontend/src/components/Login.tsx → projects/xxx/frontend/tests/components/Login.test.tsx
if [[ "$FILE_PATH" == *"/frontend/src/"*.ts ]] || [[ "$FILE_PATH" == *"/frontend/src/"*.tsx ]]; then
    EXT="${FILE_PATH##*.}"
    BASE="${FILE_PATH%.*}"
    TEST_PATH_1=$(echo "$BASE" | sed 's|/frontend/src/|/frontend/tests/|').test."$EXT"
    TEST_PATH_2=$(echo "$BASE" | sed 's|/frontend/src/|/frontend/tests/|').spec."$EXT"

    if [ ! -f "$TEST_PATH_1" ] && [ ! -f "$TEST_PATH_2" ]; then
        echo "🔴 TDD violation: 테스트를 먼저 작성하세요!"
        echo ""
        echo "구현 파일: $FILE_PATH"
        echo "필요한 테스트: $TEST_PATH_1 또는 $TEST_PATH_2"
        echo ""
        echo "TDD 사이클: Red(테스트 작성) → Green(구현) → Refactor"
        echo "먼저 실패하는 테스트를 작성한 후 구현을 진행하세요."
        exit 2
    fi
fi

# 검증 통과
exit 0
