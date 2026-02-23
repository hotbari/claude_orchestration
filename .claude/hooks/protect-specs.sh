#!/bin/bash
# Protect Specs Hook
# PreToolUse (Write|Edit) 시 실행
# Phase 3(구현) 시작 이후 스펙 파일 수정을 차단

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

# 스펙 파일이 아니면 통과
# projects/*/docs/specs/ 또는 projects/*/docs/api/ 경로인지 확인
IS_SPEC=false
if [[ "$FILE_PATH" == *"/docs/specs/"* ]]; then
    IS_SPEC=true
fi
if [[ "$FILE_PATH" == *"/docs/api/"* ]]; then
    IS_SPEC=true
fi

if [ "$IS_SPEC" = false ]; then
    exit 0
fi

# 해당 프로젝트의 경로 추출
# projects/xxx/docs/specs/... → projects/xxx
PROJECT_DIR=$(echo "$FILE_PATH" | sed 's|\(projects/[^/]*/\).*|\1|')

if [ -z "$PROJECT_DIR" ]; then
    exit 0
fi

# Phase 3 이후인지 확인: backend/src/ 디렉토리에 구현 파일이 존재하는지 확인
SRC_FILES=$(find "${PROJECT_DIR}backend/src/" -type f \
    ! -name "__init__.py" \
    ! -name "*.config.*" \
    ! -name "*.d.ts" \
    ! -name "index.*" \
    2>/dev/null | head -1)

if [ -n "$SRC_FILES" ]; then
    echo "🔒 스펙 보호: Phase 2 이후 스펙 파일은 수정할 수 없습니다."
    echo ""
    echo "수정 시도: $FILE_PATH"
    echo "프로젝트: $PROJECT_DIR"
    echo ""
    echo "구현 코드가 이미 존재하므로 (Phase 3 이후) 스펙을 변경하면"
    echo "코드와 스펙 사이에 불일치가 발생할 수 있습니다."
    echo ""
    echo "스펙 변경이 필요한 경우:"
    echo "1. 사용자에게 변경 필요성을 보고하세요."
    echo "2. 승인 후 Phase 2(Architect)부터 재시작하세요."
    exit 2
fi

# Phase 3 이전이면 수정 허용
exit 0
