---
name: design-analysis
description: Executes design analysis phase - fetches Figma designs, extracts design tokens, identifies components
version: 1.0.0
---

# Design Analysis Phase

## 개요

design-analysis phase는 web-autopilot 파이프라인의 **첫 번째 단계**입니다. MCP 도구를 사용하여 Figma 디자인을 가져오고, vision agent로 시각적 요소를 분석하며, 이후 모든 단계를 안내하는 포괄적인 디자인 분석 문서를 생성합니다.

**핵심 책임:**
- Figma 디자인 파일 가져오기 및 이미지 내보내기
- 레이아웃, 컴포넌트, 인터랙션 패턴 분석
- Design token 추출 (색상, 타이포그래피, 간격)
- 재사용 가능한 컴포넌트 및 shadcn/ui 매핑 식별

---

## 전제 조건

| 요구사항 | 상태 | 비고 |
|----------|------|------|
| State | 없음 | 첫 번째 단계, 의존성 없음 |
| Figma URL | 필수 | project-brief 파일에 포함되어야 함 |
| Figma MCP | 필수 | `references/figma-mcp-setup.md` 참조 |
| tech-stack.md | 선택 | 커스텀 스택 오버라이드 |

---

## 입력

| 입력 | 소스 | 필수 | 설명 |
|------|------|------|------|
| project-brief file | User argument | Yes | 서비스 이름, Figma URL, 프로젝트 설명 포함 |
| Figma URL | brief에서 추출 | Yes | `https://figma.com/file/{fileKey}/...` |
| tech-stack.md | 선택적 파일 경로 | No | 커스텀 기술 스택 구성 |

**Project Brief 형식:**
```markdown
# Project Brief
## Service Name
my-service-name
## Figma URL
https://www.figma.com/file/ABC123/My-Design
## Description
[프로젝트 설명...]
```

---

## 출력

| 출력 | 경로 | 설명 |
|------|------|------|
| design-analysis.md | `.omc/web-projects/{service}/docs/design-analysis.md` | 완전한 디자인 분석 |
| Figma images | `.omc/web-projects/{service}/figma-designs/*.png` | 내보낸 디자인 화면 |
| State file | `.omc/state/web-autopilot-state.json` | 초기화된 파이프라인 state |

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| vision | sonnet | Figma 이미지 분석 - 레이아웃, 컴포넌트, design token 추출 |
| designer | sonnet | UI/UX 관점 - 컴포넌트 아키텍처, shadcn/ui 매핑 |

---

## 단계별 프로세스

### Step 0: 초기화

**실행자: Orchestrator (직접)**

1. **project-brief 파일 읽기** 및 서비스 이름 + Figma URL 추출
2. **Figma URL 검증** 형식: `https://figma.com/file/{fileKey}/...`
3. **tech-stack.md 확인** - 제공되지 않으면 기본 스택 사용
4. **state 초기화** `state-manager.js` 사용:
   ```javascript
   stateManager.initState(serviceName, figmaUrl);
   stateManager.updatePhase('design-analysis', 'in_progress');
   ```
5. **프로젝트 디렉토리 생성**:
   ```
   .omc/web-projects/{service-name}/docs/
   .omc/web-projects/{service-name}/figma-designs/
   ```

---

### Step 1: Figma 디자인 가져오기

**실행자: Orchestrator (직접, MCP 사용)**

1. **fileKey 추출** URL에서: `https://www.figma.com/file/ABC123xyz/...` -> `ABC123xyz`

2. **파일 구조 가져오기**:
   ```
   Tool: mcp__figma__get_file
   Input: { fileId: "{fileKey}" }
   ```

3. **디자인 이미지 내보내기**:
   ```
   Tool: mcp__figma__get_images
   Input: { fileId: "{fileKey}", nodeIds: [...], format: "png", scale: 2 }
   ```

4. **이미지 저장** `.omc/web-projects/{service}/figma-designs/screen-{N}-{name}.png`로

5. **오류 처리**: MCP를 사용할 수 없으면 수동 내보내기 안내

---

### Step 2: Vision 분석

**실행자: vision agent (sonnet)**

프롬프트로 위임:
```
Analyze Figma images in: .omc/web-projects/{service}/figma-designs/

Extract for EACH screen:

1. **Layout Structure** - Grid system, spacing values (px), container widths

2. **Component Inventory** - Buttons (variants), Inputs, Cards, Navigation, Modals, Lists

3. **Design Tokens**:
   - Colors: Primary, Secondary, Background, Text, Border (HEX values)
   - Typography: Font family, sizes (h1-h6, body), weights, line-heights
   - Spacing: Base unit (4px/8px), scale (xs, sm, md, lg, xl)
   - Borders: Radius values, widths
   - Shadows: Box shadow values

4. **Interaction Patterns** - Hover, active, disabled, loading states

5. **Text Content** - ALL visible text EXACTLY as shown (DO NOT translate)

Output to: .omc/web-projects/{service}/docs/design-analysis.md
```

---

### Step 3: Designer 관점

**실행자: designer agent (sonnet)**

프롬프트로 위임:
```
Review: .omc/web-projects/{service}/docs/design-analysis.md

Add sections:

1. **Reusable Component Architecture**
   - components/ui/ - Base UI (Button, Input, Card, Dialog)
   - components/common/ - Service-wide (Header, Footer, Sidebar)
   - components/features/ - Feature-specific (LoginForm, ProductCard)

2. **shadcn/ui Mapping**
   | Figma Component | shadcn/ui | Customization |
   |-----------------|-----------|---------------|

3. **Responsive Strategy** - Breakpoints, layout changes per screen size

4. **State Management Hints** - Auth, UI, Form, Server state needs

5. **Implementation Priority** - Build order recommendation

Update: .omc/web-projects/{service}/docs/design-analysis.md
```

---

### Step 4: 결과 통합

**실행자: Orchestrator (직접)**

1. **완전성 검증** - 모든 필수 섹션 존재 확인
2. **state 업데이트**:
   ```javascript
   stateManager.updateDocument('designAnalysis', docPath);
   stateManager.updatePhase('design-analysis', 'completed');
   ```
3. **사용자에게 보고**:
   ```
   Design analysis complete.
   Generated: design-analysis.md, figma-designs/ (N images)
   Next: /web-autopilot:requirements
   ```

---

## 검증 체크리스트

- [ ] design-analysis.md가 올바른 경로에 존재
- [ ] 컴포넌트 목록이 포괄적 (버튼, 입력, 카드 등)
- [ ] 실제 값으로 design token 추출 (색상, 타이포그래피, 간격)
- [ ] Figma 이미지가 figma-designs/에 다운로드됨
- [ ] 텍스트 콘텐츠가 정확히 보존됨 (번역 안 함)
- [ ] shadcn/ui 매핑 완료
- [ ] state.phases.design-analysis === "completed"

---

## 출력 문서 구조

```markdown
# Design Analysis: {Service Name}

## 1. Overview
- 총 화면 수, 사용자 플로우, 디자인 스타일

## 2. Layout Structure
- Grid: columns, gutter, max-width
- Spacing scale: xs(4px), sm(8px), md(16px), lg(24px), xl(32px)

## 3. Design Tokens
### Colors
| Token | Value | Usage |
|-------|-------|-------|
| primary | #3B82F6 | Buttons |
| background | #FFFFFF | Page bg |
| text-primary | #111827 | Headings |

### Typography
| Token | Font | Size | Weight |
|-------|------|------|--------|
| h1 | Inter | 36px | 700 |
| body | Inter | 16px | 400 |

### Borders & Shadows
- Radius: sm=4px, md=8px, lg=12px
- Shadows: sm, md values

## 4. Component Inventory
- UI Components (Button, Input, Card, Dialog, etc.)
- Common Components (Header, Footer, Sidebar)
- Feature Components (per Figma analysis)

## 5. shadcn/ui Mapping
| Figma | shadcn/ui | Customization |
|-------|-----------|---------------|

## 6. Responsive Strategy
- Breakpoints: sm(640), md(768), lg(1024), xl(1280)
- Layout changes per breakpoint

## 7. Text Content
- Navigation, Buttons, Headings, Body (exact from Figma)

## 8. Implementation Priority
1. Design tokens -> 2. UI components -> 3. Common -> 4. Features -> 5. Pages
```

---

## 오류 처리

| 오류 | 원인 | 해결 방법 |
|------|------|-----------|
| MCP tools not found | Figma MCP가 구성되지 않음 | `~/.claude/mcp.json` 확인, `/oh-my-claudecode:mcp-setup` 실행 |
| Invalid Figma URL | 잘못된 URL 형식 | 형식 확인: `https://www.figma.com/file/{fileKey}/...` |
| 403 Forbidden | API 토큰 문제 | 토큰이 `file:read` 스코프를 가지는지 확인, 만료되면 재생성 |
| Image export failed | 유효하지 않은 nodeIds | 노드가 존재하고 표시되는지 확인 |

**대체 방법 (MCP 없음):** 사용자가 수동으로 Figma를 PNG로 내보내고 figma-designs/에 업로드

---

## 참조

- `references/figma-mcp-setup.md` - Figma MCP 구성
- `references/design-tokens-guide.md` - Token 추출 모범 사례
- `references/component-mapping.md` - Figma에서 shadcn/ui로 매핑

---

## 요약

Phase 1은 Figma 디자인을 구현 사양으로 변환합니다:

1. **초기화** - State 및 디렉토리
2. **가져오기** - MCP를 통한 Figma 파일
3. **분석** - Vision agent가 시각적 요소 추출
4. **설계** - Designer agent가 컴포넌트 계획
5. **통합** - design-analysis.md 생성

**성공 기준:**
- 모든 섹션을 포함한 완전한 design-analysis.md
- 실제 값이 있는 design token
- shadcn/ui 매핑이 있는 컴포넌트 인벤토리
- 로컬에 저장된 Figma 이미지
- "completed"로 업데이트된 state
