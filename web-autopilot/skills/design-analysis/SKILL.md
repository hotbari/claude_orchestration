---
name: design-analysis
description: Executes design analysis phase - fetches Figma designs, extracts design tokens, identifies components
version: 1.0.0
---

# Design Analysis Phase

## 개요

web-autopilot 파이프라인의 첫 번째 단계. Figma 디자인을 가져와 시각적 요소를 분석하고 디자인 분석 문서 생성.

**핵심 책임:**
- Figma 파일 가져오기 및 이미지 내보내기
- 레이아웃, 컴포넌트, 인터랙션 분석
- Design token 추출
- shadcn/ui 매핑

---

## 전제 조건 & 입출력

**전제 조건:**
- Figma URL (project-brief에 포함)
- Figma MCP 구성 (`references/figma-mcp-setup.md`)
- tech-stack.md (선택)

**Project Brief 형식:**
```markdown
# Project Brief
## Service Name
my-service-name
## Figma URL
https://www.figma.com/file/ABC123/My-Design
## Description
[설명]
```

**출력:**
- design-analysis.md (`.omc/web-projects/{service}/docs/`)
- Figma images (`.omc/web-projects/{service}/figma-designs/*.png`)
- State file (`.omc/state/web-autopilot-state.json`)

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| figma-analyzer | sonnet | Figma 디자인 → 기술 스펙 변환 (design-analysis.md 생성) |

---

## 단계별 프로세스

### Step 0: 초기화

**Orchestrator (직접):**

1. project-brief 읽기 → 서비스명 + Figma URL 추출
2. Figma URL 검증: `https://figma.com/file/{fileKey}/...`
3. tech-stack.md 확인 (없으면 기본 스택)
4. state 초기화:
   ```javascript
   stateManager.initState(serviceName, figmaUrl);
   stateManager.updatePhase('design-analysis', 'in_progress');
   ```
5. 디렉토리 생성:
   ```
   .omc/web-projects/{service}/docs/
   .omc/web-projects/{service}/figma-designs/
   ```

---

### Step 1: Figma 디자인 가져오기

**Orchestrator (직접, MCP):**

1. **fileKey 추출:** `https://www.figma.com/file/ABC123xyz/...` → `ABC123xyz`

2. **파일 구조 가져오기:**
   ```
   Tool: mcp__figma__get_file
   Input: { fileId: "{fileKey}" }
   ```

3. **이미지 내보내기:**
   ```
   Tool: mcp__figma__get_images
   Input: { fileId: "{fileKey}", nodeIds: [...], format: "png", scale: 2 }
   ```

4. **이미지 저장:** `.omc/web-projects/{service}/figma-designs/screen-{N}-{name}.png`

5. **오류 처리:** MCP 불가 시 수동 내보내기 안내


---

### Step 3: 결과 통합

**Orchestrator (직접):**

1. **완전성 검증** - 필수 섹션 존재 확인
2. **state 업데이트:**
   ```javascript
   stateManager.updateDocument('designAnalysis', docPath);
   stateManager.updatePhase('design-analysis', 'completed');
   ```
3. **사용자 보고:**
   ```
   Design analysis complete.
   Generated: design-analysis.md, figma-designs/ (N images)
   Next: /web-autopilot:requirements
   ```

---

## 검증 체크리스트

- [ ] design-analysis.md 올바른 경로 존재
- [ ] 컴포넌트 목록 포괄적 (Button, Input, Card 등)
- [ ] Design token 실제 값 (색상, 타이포그래피, 간격, 텍스트 내용)
- [ ] Figma 이미지 figma-designs/ 다운로드
- [ ] 텍스트, 레이아웃, 구조, 위치, 색상, 아이콘 정확히 보존
- [ ] shadcn/ui 매핑 완료
- [ ] state.phases.design-analysis === "completed"

---

## 출력 문서 구조

```markdown
# Design Analysis: {Service Name}

## 1. Overview
- 화면 수, 플로우, 스타일

## 2. Layout Structure
- Grid, Spacing scale

## 3. Design Tokens
### Colors
| Token | Value | Usage |
### Typography
| Token | Font | Size | Weight |
### Borders & Shadows

## 4. Component Inventory
- UI (Button, Input, Card, Dialog)
- Common (Header, Footer, Sidebar)
- Features (per Figma)

## 5. shadcn/ui Mapping
| Figma | shadcn/ui | Customization |

## 6. Responsive Strategy
- Breakpoints, Layout changes

## 7. Text Content
- Exact from Figma

## 8. Implementation Priority
Design tokens → UI → Common → Features → Pages
```


---

## 참조

**References:** figma-output-format.md, figma-mcp-setup.md, design-tokens-guide.md, component-mapping.md

**Agents:** figma-analyzer.md

