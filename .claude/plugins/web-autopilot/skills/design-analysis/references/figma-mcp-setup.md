# Figma MCP 설정 가이드

## 개요

**Figma Model Context Protocol (MCP)**는 Claude Code가 수동 내보내기 없이 Figma 파일, 디자인 및 이미지에 직접 액세스할 수 있도록 합니다. 이 문서는 Figma MCP 통합 설정 및 검증 과정을 안내합니다.

### Figma MCP를 사용하는 이유는?

- **직접 파일 액세스**: 프로그래밍 방식으로 Figma 파일 쿼리
- **이미지 추출**: 디자인 이미지 및 컴포넌트 자동 가져오기
- **실시간 데이터**: 라이브 Figma 디자인 작업
- **마찰 감소**: 수동 다운로드/업로드 워크플로 불필요

---

## 요구사항

### 1. Figma 계정
- Figma 개인 또는 팀 계정
- 필요한 디자인 파일에 대한 읽기 권한
- 팀 관리자 권한 (팀 파일의 경우)

### 2. Figma API 토큰

개인 액세스 토큰 생성:

1. https://www.figma.com/account 로 이동
2. **Personal access tokens** 섹션으로 스크롤
3. **Create a new token** 클릭
4. 이름 지정: `claude-code-mcp`
5. 범위 선택:
   - `file:read` - 파일 메타데이터 및 콘텐츠 읽기
   - `file_dev:read` - 개발 리소스 읽기
6. 토큰을 안전하게 저장 (다시 볼 수 없음)

### 3. MCP 서버 설정

Figma MCP는 Claude Code의 MCP 생태계를 통해 구성됩니다.

#### 옵션 A: Claude Code를 통한 자동 설정
```bash
/oh-my-claudecode:mcp-setup
```
"Figma"를 선택하고 프롬프트가 나타나면 API 토큰을 제공합니다.

#### 옵션 B: 수동 구성

1. MCP 구성 파일 위치:
   - macOS/Linux: `~/.claude/mcp.json`
   - Windows: `%USERPROFILE%\.claude\mcp.json`

2. Figma 서버 구성 추가:
```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["figma-mcp-server"],
      "env": {
        "FIGMA_API_TOKEN": "your-token-here"
      }
    }
  }
}
```

3. 변경사항 적용을 위해 Claude Code 재시작.

---

## 구성

### MCP 설치 확인

```bash
npm list -g figma-mcp-server
# or
npx figma-mcp-server --version
```

### 연결 테스트

```bash
npx figma-mcp-server test
```

예상 출력:
```
✓ Figma MCP Server running
✓ API token verified
✓ Ready to serve requests
```

### 파일 ID 얻기

Figma에서 파일의 **Share** 버튼을 클릭합니다. URL 형식은 다음과 같습니다:
```
https://www.figma.com/file/{FILE_ID}/...
```

나중에 사용할 수 있도록 `{FILE_ID}`를 복사합니다.

---

## 사용 가능한 도구

구성이 완료되면 다음 도구를 사용할 수 있습니다:

### `mcp__figma__get_file`
Figma 파일 구조 및 메타데이터 검색.

**사용법:**
```
Tool: mcp__figma__get_file
Input:
  fileId: "abc123xyz"
  version: "latest" (optional)
```

**반환값:**
- 파일 이름, 버전 기록
- 노드 ID가 포함된 페이지 목록
- 컴포넌트 메타데이터
- 에셋 종속성

### `mcp__figma__get_images`
특정 노드에서 이미지 내보내기.

**사용법:**
```
Tool: mcp__figma__get_images
Input:
  fileId: "abc123xyz"
  nodeIds: ["node1", "node2"]
  format: "png" | "jpg" | "svg"
  scale: 1 | 2 | 4 (optional)
```

**반환값:**
- 임시 토큰이 포함된 이미지 URL
- 내보낸 에셋에 직접 액세스
- 고품질 디자인 리소스

### 추가 도구
- `mcp__figma__search_components` - 워크스페이스에서 컴포넌트 찾기
- `mcp__figma__get_node_data` - 상세 노드/요소 정보
- `mcp__figma__list_files` - 액세스 가능한 모든 파일 탐색

---

## 대체 옵션

Figma MCP를 사용할 수 없거나 잘못 구성된 경우:

### 수동 이미지 업로드
```bash
1. Figma에서 디자인 내보내기 (File > Export)
2. Claude Code에 이미지 업로드:
   vision tool: image_path
3. vision 기능으로 디자인 분석
```

### 디자인 파일 내보내기
```bash
1. Figma: File > Export > PDF/PNG
2. 프로젝트에 업로드: /uploads
3. 디자인 분석 프롬프트에서 참조
```

### API 대체
MCP를 사용할 수 없는 경우 Figma REST API를 직접 사용:
```bash
curl -H "X-Figma-Token: YOUR_TOKEN" \
  https://api.figma.com/v1/files/{FILE_ID}
```

---

## 오류 처리

### "MCP Server Not Found"
```bash
# Figma MCP 재설치
npm install -g figma-mcp-server

# mcp.json에서 확인
cat ~/.claude/mcp.json | grep figma
```

### "API Token Invalid"
```bash
# figma.com/account에서 토큰 재생성
# mcp.json 업데이트: FIGMA_API_TOKEN=...
# Claude Code 재시작
```

### "File Not Accessible"
- 파일 공유 확인: Figma > Share > Make accessible
- API 토큰에 `file:read` 범위가 있는지 확인
- 팀 권한 확인 (팀 파일의 경우 팀 소유자 필요)

### "Rate Limit Exceeded"
- Figma API: 분당 300 요청
- 가능한 경우 결과 캐시
- 여러 작업 일괄 처리

### "Image Export Failed"
- 파일에 노드 ID가 존재하는지 확인
- 노드가 표시되는지 확인 (숨겨지지 않음)
- 내보내기 형식이 지원되는지 확인 (png, jpg, svg, pdf)

---

## 검증

### 1단계: MCP 서버 상태 확인
```bash
ps aux | grep figma-mcp-server
# 실행 중인 프로세스가 표시되어야 함
```

### 2단계: 도구 사용 가능 여부 테스트
Claude Code에서 실행:
```
Use the mcp__figma__get_file tool to list available files
```

### 3단계: 실제 파일 쿼리
Figma 파일 ID를 제공하고 요청:
```
"Use Figma MCP to fetch the design structure from this file: [FILE_ID]"
```

### 4단계: 이미지 내보내기 확인
```
"Export a component as PNG from this Figma file: [FILE_ID]"
```

### 성공 지표 확인

- [ ] MCP 서버 프로세스 실행 중
- [ ] 사용 가능한 도구 목록에 도구 표시
- [ ] 파일 메타데이터 가져오기 가능
- [ ] 이미지를 성공적으로 내보낼 수 있음
- [ ] 인증 오류 없음

---

## 문제 해결 체크리스트

- [ ] Figma 계정 생성 및 확인
- [ ] 올바른 범위로 개인 액세스 토큰 생성
- [ ] 토큰을 안전하게 저장 (git에 저장하지 않음)
- [ ] MCP 구성 파일이 존재하고 올바른 구문을 가짐
- [ ] Figma MCP 패키지가 전역으로 설치됨
- [ ] 구성 변경 후 Claude Code 재시작
- [ ] 파일 ID가 올바르고 액세스 가능함
- [ ] 디자인 파일 공유가 활성화됨
- [ ] 로그에 속도 제한 경고 없음
- [ ] 테스트 도구 호출이 유효한 응답 반환

추가 도움말:
- Figma API 문서: https://www.figma.com/developers/api
- Claude Code 문서: https://claude.com/docs/mcp
