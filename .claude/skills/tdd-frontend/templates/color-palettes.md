# 프리셋 컬러 팔레트

> 이 문서는 프론트엔드 디자인 시스템에서 사용할 수 있는 프리셋 컬러 팔레트를 정의합니다.
> 뼈대(구조)만 정의하며, 사용자가 이후 실제 색상 값을 제공할 수 있습니다.
> 기본값으로 `default-blue` 팔레트가 사용됩니다.

## 팔레트 목록

| 이름 | 키 | 기반 색상 | 적합한 프로젝트 |
|------|-----|-----------|----------------|
| 기본 블루 | `default-blue` | blue-500 기반 | 범용, 기본값 |
| 포레스트 그린 | `forest-green` | green-600 기반 | 자연, 환경, 건강 |
| 웜 앰버 | `warm-amber` | amber-500 기반 | 따뜻한 톤, 식음료, 커뮤니티 |
| 슬레이트 프로페셔널 | `slate-professional` | slate-600 기반 | 비즈니스, 관리 도구 |
| 바이올렛 크리에이티브 | `violet-creative` | violet-500 기반 | 크리에이티브, 디자인, 교육 |

---

## 팔레트 상세

### default-blue

MH OCR AI 프로젝트 기준 색상 (#137FEC 기반):

```css
:root {
  /* Primary (#137FEC 기반 스케일) */
  --color-primary-50: #EBF5FF;
  --color-primary-100: #D6EBFF;
  --color-primary-200: #ADD6FF;
  --color-primary-300: #85C2FF;
  --color-primary-400: #4DA3F7;
  --color-primary-500: #137FEC;
  --color-primary-600: #0F6BD4;
  --color-primary-700: #0B57B3;
  --color-primary-800: #084391;
  --color-primary-900: #052F6F;
  --color-primary-950: #031C4A;

  /* Secondary (slate 계열) */
  --color-secondary-50: #F8FAFC;
  --color-secondary-500: #64748B;
  --color-secondary-900: #0F172A;

  /* Accent (indigo 계열) */
  --color-accent-50: #EEF2FF;
  --color-accent-500: #6366F1;
  --color-accent-900: #312E81;

  /* Neutral (gray 계열) */
  --color-neutral-50: #F9FAFB;
  --color-neutral-500: #6B7280;
  --color-neutral-900: #111827;

  /* Semantic */
  --color-success: #16A34A;
  --color-warning: #F59E0B;
  --color-error: #DC2626;
  --color-info: #137FEC;

  /* Background / Foreground */
  --color-background: #FFFFFF;
  --color-foreground: #111418;
  --color-muted: #64748B;
  --color-border: #F3F4F6;

  /* 타이포그래피 */
  --font-sans: "Noto Sans KR", ui-sans-serif, system-ui, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, monospace;

  /* 간격/크기 */
  --radius: 0.75rem;

  /* 브랜드 RGB (Input focus 애니메이션용) */
  --brand-rgb: 19, 127, 236;
}
```

### forest-green

```css
:root {
  /* Primary (green 계열) */
  --color-primary-50: /* 사용자 제공 예정 */;
  --color-primary-500: /* 사용자 제공 예정 */;
  --color-primary-600: /* 사용자 제공 예정 */;
  --color-primary-900: /* 사용자 제공 예정 */;
  /* ... 전체 스케일 (50~950) */

  /* 나머지 동일 구조 */
}
```

### warm-amber

```css
:root {
  /* Primary (amber 계열) */
  --color-primary-50: /* 사용자 제공 예정 */;
  --color-primary-500: /* 사용자 제공 예정 */;
  --color-primary-900: /* 사용자 제공 예정 */;
  /* ... 전체 스케일 (50~950) */

  /* 나머지 동일 구조 */
}
```

### slate-professional

```css
:root {
  /* Primary (slate 계열) */
  --color-primary-50: /* 사용자 제공 예정 */;
  --color-primary-500: /* 사용자 제공 예정 */;
  --color-primary-600: /* 사용자 제공 예정 */;
  --color-primary-900: /* 사용자 제공 예정 */;
  /* ... 전체 스케일 (50~950) */

  /* 나머지 동일 구조 */
}
```

### violet-creative

```css
:root {
  /* Primary (violet 계열) */
  --color-primary-50: /* 사용자 제공 예정 */;
  --color-primary-500: /* 사용자 제공 예정 */;
  --color-primary-900: /* 사용자 제공 예정 */;
  /* ... 전체 스케일 (50~950) */

  /* 나머지 동일 구조 */
}
```

---

## 적용 방법

### 1. design-config.json에서 팔레트 선택

```json
{
  "palette": "forest-green"
}
```

### 2. 에이전트 동작

1. `design-config.json`의 `palette` 값을 읽습니다.
2. 이 문서에서 해당 팔레트의 CSS custom property 값을 가져옵니다.
3. `src/styles/globals.css`의 `:root`에 해당 값을 적용합니다.
4. `tailwind.config.ts`는 CSS custom property를 참조하므로 별도 수정 불필요합니다.

### 3. 커스텀 팔레트 (Figma 오버라이드)

`design-config.json`에 `figmaTokens.colors`가 있으면:
- 프리셋 팔레트 대신 Figma에서 추출한 색상 값을 사용합니다.
- `globals.css`의 CSS custom properties를 Figma 토큰 값으로 채웁니다.

유저가 `--figma` 옵션으로 자신의 Figma URL을 제공하면 Figma MCP에서 추출한 색상이 위 default-blue 기본값을 오버라이드합니다.

### 4. 파이프라인 인자

```bash
/pipeline my-project 내 서비스 --palette forest-green
/pipeline my-project 내 서비스 --figma https://figma.com/file/xxx
```

- `--palette`: 프리셋 팔레트 이름 (기본: `default-blue`)
- `--figma`: Figma 파일 URL (팔레트 오버라이드, `FIGMA_ACCESS_TOKEN` 환경변수 필요)
