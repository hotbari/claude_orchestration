#!/bin/bash
# Format on Save Hook
# PostToolUse (Write|Edit) 시 실행
# 파일 저장 후 자동 포매팅 (best-effort, 비차단)

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

# 파일 경로가 비어있으면 종료
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# projects/ 내 파일이 아니면 종료 (오케스트레이션 설정 파일은 포매팅 제외)
if [[ "$FILE_PATH" != *"projects/"* ]]; then
    exit 0
fi

# 파일이 존재하지 않으면 종료
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Python 파일 포매팅
if [[ "$FILE_PATH" == *.py ]]; then
    if command -v ruff &> /dev/null; then
        ruff format "$FILE_PATH" 2>/dev/null
        ruff check --fix "$FILE_PATH" 2>/dev/null
    elif command -v black &> /dev/null; then
        black --quiet "$FILE_PATH" 2>/dev/null
    fi
fi

# TypeScript/JavaScript/React 파일 포매팅
if [[ "$FILE_PATH" == *.ts || "$FILE_PATH" == *.tsx || "$FILE_PATH" == *.js || "$FILE_PATH" == *.jsx ]]; then
    # 프로젝트 디렉토리의 node_modules 내 prettier를 사용하거나 글로벌
    PROJECT_DIR=$(echo "$FILE_PATH" | sed 's|\(projects/[^/]*/\).*|\1|')
    if [ -f "${PROJECT_DIR}frontend/node_modules/.bin/prettier" ]; then
        "${PROJECT_DIR}frontend/node_modules/.bin/prettier" --write "$FILE_PATH" 2>/dev/null
    elif command -v prettier &> /dev/null; then
        prettier --write "$FILE_PATH" 2>/dev/null
    fi
fi

# JSON 파일 포매팅
if [[ "$FILE_PATH" == *.json ]]; then
    if command -v prettier &> /dev/null; then
        prettier --write "$FILE_PATH" 2>/dev/null
    fi
fi

# 항상 exit 0 (비차단, best-effort)
exit 0
