# Design Tokens 가이드

## 개요

**Design Tokens란 무엇인가?**

Design tokens는 시스템의 시각적 언어를 정의하는 원자적 디자인 결정입니다. 디자인 파일에서 추출한 색상, 간격, 타이포그래피, 테두리, 그림자 및 기타 시각적 속성을 나타내는 명명되고 재사용 가능한 값입니다.

**중요한 이유:**
- **일관성**: 모든 시각적 속성에 대한 단일 진실 공급원
- **유지보수성**: 한 번 변경하면 모든 곳에 업데이트
- **DRY 원칙**: 코드베이스 전체에 흩어진 하드코딩된 매직 값 없음
- **확장성**: 쉽게 확장하고 테마 적용
- **디자이너-개발자 브리지**: Figma에서 코드로 직접 매핑

---

## Figma에서 추출

### 프로세스 개요

1. **Vision Agent 분석**: Read 도구를 사용하여 Figma 디자인 이미지 읽기
2. **패턴 식별**: 화면 전체에서 반복되는 값 찾기
3. **정확한 값 추출**: 색상 (HEX/RGB), 간격 (px), 글꼴, 그림자
4. **design-analysis.md에 문서화**: 정확한 값으로 모든 토큰 기록

### 추출할 항목

| 카테고리 | 찾을 항목 | 예제 값 |
|----------|------------------|----------------|
| **색상** | 배경, 텍스트, 테두리, 버튼, 상태 | `#3B82F6`, `rgba(59, 130, 246, 0.1)` |
| **간격** | 여백, 패딩, 요소 간 간격 | `4px`, `8px`, `16px`, `24px`, `32px`, `48px` |
| **타이포그래피** | 글꼴 패밀리, 크기, 굵기, 줄 높이 | `Inter`, `16px`, `600`, `1.5` |
| **테두리** | 테두리 반경, 너비, 색상 | `8px`, `1px`, `#E5E7EB` |
| **그림자** | 카드, 모달, 버튼용 박스 그림자 | `0 4px 6px rgba(0, 0, 0, 0.1)` |
| **Z-Index** | 오버레이, 모달, 드롭다운의 레이어 순서 | `10`, `50`, `100` |

### 추출 체크리스트

- [ ] **주요 색상**: 주요 작업용 브랜드 색상
- [ ] **보조 색상**: 덜 눈에 띄는 작업용 지원 색상
- [ ] **중립 색상**: 배경, 텍스트, 테두리용 회색
- [ ] **의미론적 색상**: 성공 (녹색), 오류 (빨강), 경고 (노랑), 정보 (파랑)
- [ ] **텍스트 색상**: 주요, 보조, 음소거, 비활성화
- [ ] **간격 스케일**: 일관된 증분 (4px 기본 시스템 권장)
- [ ] **글꼴 패밀리**: 주요 (본문), 보조 (제목), 모노 (코드)
- [ ] **글꼴 크기**: 가장 작은 것 (캡션)부터 가장 큰 것 (히어로)까지
- [ ] **테두리 반경**: 버튼, 카드, 입력, 모달용
- [ ] **그림자 레벨**: 미묘한 것부터 눈에 띄는 것까지 (고도 시스템)

---

## 토큰 카테고리

### 1. 색상

**목적**: 애플리케이션 전체에서 사용되는 모든 색상 값 정의

**구조**:
```typescript
colors: {
  // Brand Colors
  primary: '#3B82F6',        // Main brand color
  primaryLight: '#60A5FA',   // Hover, active states
  primaryDark: '#2563EB',    // Pressed, dark mode

  secondary: '#10B981',      // Secondary actions
  secondaryLight: '#34D399',
  secondaryDark: '#059669',

  // Neutral Colors
  gray50: '#F9FAFB',
  gray100: '#F3F4F6',
  gray200: '#E5E7EB',
  gray300: '#D1D5DB',
  gray400: '#9CA3AF',
  gray500: '#6B7280',
  gray600: '#4B5563',
  gray700: '#374151',
  gray800: '#1F2937',
  gray900: '#111827',

  // Semantic Colors
  success: '#10B981',
  error: '#EF4444',
  warning: '#F59E0B',
  info: '#3B82F6',

  // Text Colors
  textPrimary: '#111827',
  textSecondary: '#6B7280',
  textMuted: '#9CA3AF',
  textDisabled: '#D1D5DB',

  // Background Colors
  bgPrimary: '#FFFFFF',
  bgSecondary: '#F9FAFB',
  bgTertiary: '#F3F4F6',

  // Border Colors
  border: '#E5E7EB',
  borderLight: '#F3F4F6',
  borderDark: '#D1D5DB',
}
```

### 2. 간격

**목적**: 여백, 패딩, 간격에 대한 일관된 간격 스케일 정의

**시스템**: 4px 기반 (대부분의 웹 애플리케이션에 권장)

**구조**:
```typescript
spacing: {
  xs: '4px',     // Tight spacing
  sm: '8px',     // Small spacing
  md: '16px',    // Medium spacing (most common)
  lg: '24px',    // Large spacing
  xl: '32px',    // Extra large
  '2xl': '48px', // Section spacing
  '3xl': '64px', // Page-level spacing
  '4xl': '96px', // Hero sections
}
```

**사용 가이드라인**:
- `xs` (4px) 사용: 아이콘-텍스트 간격, 타이트 패딩
- `sm` (8px) 사용: 폼 필드 패딩, 작은 간격
- `md` (16px) 사용: 카드 패딩, 버튼 패딩, 기본 간격
- `lg` (24px) 사용: 섹션 패딩, 카드 간격
- `xl` (32px) 사용: 컴포넌트 간격
- `2xl+` 사용: 페이지 레벨 레이아웃 간격

### 3. 타이포그래피

**목적**: 글꼴 패밀리, 크기, 굵기, 줄 높이 정의

**구조**:
```typescript
typography: {
  // Font Families
  fontFamily: {
    sans: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    serif: 'Georgia, Cambria, "Times New Roman", Times, serif',
    mono: 'Menlo, Monaco, Consolas, "Courier New", monospace',
  },

  // Font Sizes
  fontSize: {
    xs: '12px',    // Captions, small labels
    sm: '14px',    // Body text (small)
    base: '16px',  // Body text (default)
    lg: '18px',    // Large body text
    xl: '20px',    // Subheadings
    '2xl': '24px', // Headings (h3)
    '3xl': '30px', // Headings (h2)
    '4xl': '36px', // Headings (h1)
    '5xl': '48px', // Hero text
    '6xl': '60px', // Display text
  },

  // Font Weights
  fontWeight: {
    light: 300,
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
    extrabold: 800,
  },

  // Line Heights
  lineHeight: {
    tight: 1.25,    // Headings
    normal: 1.5,    // Body text
    relaxed: 1.75,  // Long-form content
    loose: 2,       // Spaced content
  },
}
```

### 4. 테두리

**목적**: 테두리 반경, 너비, 색상 정의

**구조**:
```typescript
borders: {
  // Border Radius
  radius: {
    none: '0',
    sm: '4px',     // Small elements (tags, badges)
    md: '8px',     // Buttons, inputs, cards
    lg: '12px',    // Large cards, modals
    xl: '16px',    // Prominent elements
    full: '9999px', // Pills, avatars
  },

  // Border Width
  width: {
    thin: '1px',   // Default borders
    medium: '2px', // Emphasized borders
    thick: '4px',  // Very emphasized borders
  },
}
```

### 5. 그림자

**목적**: 깊이와 고도를 위한 box-shadow 값 정의

**구조**:
```typescript
shadows: {
  none: 'none',
  sm: '0 1px 2px rgba(0, 0, 0, 0.05)',           // Subtle depth
  md: '0 4px 6px rgba(0, 0, 0, 0.1)',            // Default cards
  lg: '0 10px 15px rgba(0, 0, 0, 0.1)',          // Elevated cards
  xl: '0 20px 25px rgba(0, 0, 0, 0.1)',          // Modals, dropdowns
  '2xl': '0 25px 50px rgba(0, 0, 0, 0.15)',      // Prominent overlays
  inner: 'inset 0 2px 4px rgba(0, 0, 0, 0.06)',  // Pressed states
}
```

**고도 시스템**:
- `none`: 평면 요소 (깊이 없음)
- `sm`: 약간의 고도 (호버 상태)
- `md`: 기본 고도 (카드, 버튼)
- `lg`: 눈에 띄는 고도 (특별한 카드)
- `xl`: 높은 고도 (모달, 팝오버)
- `2xl`: 최대 고도 (토스트, 알림)
- `inner`: 인셋 (눌린 버튼, 활성 입력)

### 6. Z-Index

**목적**: 겹치는 요소의 레이어 순서 정의

**구조**:
```typescript
zIndex: {
  base: 0,          // Default layer
  dropdown: 10,     // Dropdowns
  sticky: 20,       // Sticky headers
  fixed: 30,        // Fixed elements
  modalBackdrop: 40, // Modal backdrops
  modal: 50,        // Modals
  popover: 60,      // Popovers
  tooltip: 70,      // Tooltips
  toast: 80,        // Toast notifications
}
```

---

## Next.js에서의 구현

### 1단계: Design Tokens 파일 생성

**위치**: `lib/design-tokens.ts`

**구조**:
```typescript
export const designTokens = {
  colors: {
    primary: '#3B82F6',
    secondary: '#10B981',
    gray50: '#F9FAFB',
    gray100: '#F3F4F6',
    // ... (full color palette)
    textPrimary: '#111827',
    textSecondary: '#6B7280',
    bgPrimary: '#FFFFFF',
    bgSecondary: '#F9FAFB',
    border: '#E5E7EB',
  },

  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px',
  },

  typography: {
    fontFamily: {
      sans: 'Inter, system-ui, sans-serif',
      mono: 'Menlo, Monaco, monospace',
    },
    fontSize: {
      xs: '12px',
      sm: '14px',
      base: '16px',
      lg: '18px',
      xl: '20px',
      '2xl': '24px',
      '3xl': '30px',
      '4xl': '36px',
    },
    fontWeight: {
      normal: 400,
      medium: 500,
      semibold: 600,
      bold: 700,
    },
    lineHeight: {
      tight: 1.25,
      normal: 1.5,
      relaxed: 1.75,
    },
  },

  borders: {
    radius: {
      sm: '4px',
      md: '8px',
      lg: '12px',
      full: '9999px',
    },
    width: {
      thin: '1px',
      medium: '2px',
    },
  },

  shadows: {
    sm: '0 1px 2px rgba(0, 0, 0, 0.05)',
    md: '0 4px 6px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px rgba(0, 0, 0, 0.1)',
    xl: '0 20px 25px rgba(0, 0, 0, 0.1)',
  },

  zIndex: {
    dropdown: 10,
    sticky: 20,
    fixed: 30,
    modal: 50,
    tooltip: 70,
  },
} as const;

export type DesignTokens = typeof designTokens;
```

### 2단계: CSS 변수에 적용

**위치**: `styles/globals.css`

**구현**:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* Colors */
    --color-primary: #3B82F6;
    --color-secondary: #10B981;
    --color-gray-50: #F9FAFB;
    --color-gray-100: #F3F4F6;
    --color-text-primary: #111827;
    --color-text-secondary: #6B7280;
    --color-bg-primary: #FFFFFF;
    --color-bg-secondary: #F9FAFB;
    --color-border: #E5E7EB;

    /* Spacing */
    --spacing-xs: 4px;
    --spacing-sm: 8px;
    --spacing-md: 16px;
    --spacing-lg: 24px;
    --spacing-xl: 32px;

    /* Typography */
    --font-sans: Inter, system-ui, sans-serif;
    --font-size-base: 16px;
    --font-weight-normal: 400;
    --font-weight-medium: 500;
    --font-weight-semibold: 600;
    --line-height-normal: 1.5;

    /* Borders */
    --border-radius-md: 8px;
    --border-width-thin: 1px;

    /* Shadows */
    --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  }
}
```

### 3단계: Tailwind Config 통합

**위치**: `tailwind.config.ts`

**구현**:
```typescript
import type { Config } from 'tailwindcss';
import { designTokens } from './lib/design-tokens';

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: designTokens.colors.primary,
        secondary: designTokens.colors.secondary,
        gray: {
          50: designTokens.colors.gray50,
          100: designTokens.colors.gray100,
          // ... (map all colors)
        },
      },
      spacing: {
        xs: designTokens.spacing.xs,
        sm: designTokens.spacing.sm,
        md: designTokens.spacing.md,
        lg: designTokens.spacing.lg,
        xl: designTokens.spacing.xl,
      },
      fontFamily: {
        sans: designTokens.typography.fontFamily.sans.split(', '),
        mono: designTokens.typography.fontFamily.mono.split(', '),
      },
      fontSize: designTokens.typography.fontSize,
      fontWeight: designTokens.typography.fontWeight,
      lineHeight: designTokens.typography.lineHeight,
      borderRadius: designTokens.borders.radius,
      boxShadow: designTokens.shadows,
      zIndex: designTokens.zIndex,
    },
  },
  plugins: [],
};

export default config;
```

### 4단계: 컴포넌트에서 사용

**예제 1: Tailwind 클래스 사용**
```tsx
import { Button } from '@/components/ui/button';

export function LoginButton() {
  return (
    <Button
      className="bg-primary text-white px-md py-sm rounded-md shadow-md hover:shadow-lg"
    >
      Login
    </Button>
  );
}
```

**예제 2: Design Tokens 직접 사용**
```tsx
import { designTokens } from '@/lib/design-tokens';

export function Card({ children }: { children: React.ReactNode }) {
  return (
    <div
      style={{
        backgroundColor: designTokens.colors.bgPrimary,
        padding: designTokens.spacing.md,
        borderRadius: designTokens.borders.radius.md,
        boxShadow: designTokens.shadows.md,
        border: `${designTokens.borders.width.thin} solid ${designTokens.colors.border}`,
      }}
    >
      {children}
    </div>
  );
}
```

**예제 3: CSS 변수 사용**
```tsx
export function Hero() {
  return (
    <section
      style={{
        backgroundColor: 'var(--color-bg-secondary)',
        padding: 'var(--spacing-xl)',
        borderRadius: 'var(--border-radius-md)',
      }}
    >
      <h1 style={{ color: 'var(--color-text-primary)' }}>Welcome</h1>
    </section>
  );
}
```

---

## 모범 사례

### 1. DRY (Don't Repeat Yourself)

**나쁜 예** (하드코딩된 값):
```tsx
<Button style={{ backgroundColor: '#3B82F6' }}>Submit</Button>
<Link style={{ color: '#3B82F6' }}>Learn More</Link>
```

**좋은 예** (토큰 사용):
```tsx
<Button className="bg-primary">Submit</Button>
<Link className="text-primary">Learn More</Link>
```

### 2. 의미론적 명명

**나쁜 예** (비의미론적):
```typescript
colors: {
  blue500: '#3B82F6',
  green500: '#10B981',
}
```

**좋은 예** (의미론적):
```typescript
colors: {
  primary: '#3B82F6',      // Brand color (context: main actions)
  success: '#10B981',       // Semantic color (context: positive feedback)
}
```

### 3. 일관성

**시스템 구축**:
- 간격 스케일 (4px, 8px, 16px, ...)을 일관되게 사용
- 색상 팔레트 제한 (5-7개 주요 색상 + 중립색)
- 일관된 글꼴 크기 사용 (최대 6-8개 크기)
- 그림자 레벨 정의 (최대 3-5개 레벨)

### 4. 유지보수성

**단일 진실 공급원**:
- 모든 디자인 값을 `lib/design-tokens.ts`에
- 한 번 업데이트하면 모든 곳에 반영
- 인라인 하드코딩된 값 피하기

### 5. 가독성

**의미 있는 이름 사용**:
```typescript
// Good
spacing: {
  tight: '4px',
  comfortable: '16px',
  spacious: '32px',
}

// Acceptable
spacing: {
  sm: '4px',
  md: '16px',
  lg: '32px',
}

// Bad (unclear)
spacing: {
  s1: '4px',
  s2: '16px',
  s3: '32px',
}
```

### 6. 문서화

**토큰에 주석 달기**:
```typescript
export const designTokens = {
  colors: {
    primary: '#3B82F6',        // Brand blue - use for main CTAs
    secondary: '#10B981',      // Brand green - use for secondary actions
    danger: '#EF4444',         // Red - use for destructive actions
  },
  // ...
};
```

---

## Figma-to-Code 매핑

### 예제 워크플로

**1단계: Vision Agent가 Figma에서 추출**
```markdown
## Colors (from Figma)
- Primary Button: #3B82F6
- Secondary Button: #10B981
- Text (Headings): #111827
- Text (Body): #6B7280
- Background: #F9FAFB
- Border: #E5E7EB

## Spacing (from Figma)
- Button padding: 12px 24px
- Card padding: 24px
- Section gaps: 48px

## Typography (from Figma)
- Font: Inter
- Heading (H1): 36px, weight 700
- Body: 16px, weight 400
- Line height: 1.5
```

**2단계: Designer Agent가 토큰 생성**
```typescript
export const designTokens = {
  colors: {
    primary: '#3B82F6',
    secondary: '#10B981',
    textPrimary: '#111827',
    textSecondary: '#6B7280',
    bgSecondary: '#F9FAFB',
    border: '#E5E7EB',
  },
  spacing: {
    buttonPadding: { x: '24px', y: '12px' },
    cardPadding: '24px',
    sectionGap: '48px',
  },
  typography: {
    fontFamily: { sans: 'Inter, sans-serif' },
    fontSize: { h1: '36px', base: '16px' },
    fontWeight: { bold: 700, normal: 400 },
    lineHeight: { normal: 1.5 },
  },
};
```

**3단계: 컴포넌트에 적용**
```tsx
<button
  className="bg-primary text-white px-6 py-3 rounded-md"
  style={{
    fontFamily: designTokens.typography.fontFamily.sans,
  }}
>
  Submit
</button>
```

---

## 일반적인 함정

### 1. 너무 많은 토큰
**문제**: 과도한 토큰화는 결정 피로를 유발

**해결책**: 필수 항목부터 시작, 필요에 따라 추가
- 5-7개 색상 (50개 아님)
- 6-8개 간격 값 (20개 아님)
- 6-8개 글꼴 크기 (15개 아님)

### 2. 일관성 없는 명명
**문제**: `primary`, `main`, `brand` 모두 같은 의미

**해결책**: 명명 규칙을 정하고 고수

### 3. 토큰과 함께 하드코딩된 값
**문제**: 일부 곳은 토큰 사용, 다른 곳은 하드코딩된 값 사용

**해결책**: 린팅을 통해 토큰 사용 강제 (선택사항)

### 4. 토큰 업데이트 안 함
**문제**: 디자인은 변경되지만 토큰은 오래된 상태로 유지

**해결책**: 토큰을 살아있는 문서로 취급, 정기적으로 업데이트

---

## 요약 체크리스트

디자인 토큰 생성 시:

- [ ] Figma에서 모든 색상 추출 (브랜드, 의미론적, 중립)
- [ ] 간격 스케일 설정 (4px 기반 권장)
- [ ] 타이포그래피 시스템 정의 (패밀리, 크기, 굵기, 줄 높이)
- [ ] 테두리 스타일 문서화 (반경, 너비)
- [ ] 그림자 레벨 정의 (고도 시스템)
- [ ] z-index 레이어 설정
- [ ] `lib/design-tokens.ts` 파일 생성
- [ ] CSS 변수로 `globals.css`에 토큰 적용
- [ ] `tailwind.config.ts`와 통합
- [ ] 컴포넌트에서 토큰을 일관되게 사용 (하드코딩된 값 없음)
- [ ] 토큰 사용 및 컨텍스트 문서화
- [ ] 모든 Figma 값이 정확하게 캡처되었는지 확인

---

## 참고자료

- **Figma Variables**: [Figma Design Tokens Documentation](https://help.figma.com/hc/en-us/articles/15339657135383-Guide-to-variables-in-Figma)
- **Tailwind CSS Customization**: [Tailwind Theming Guide](https://tailwindcss.com/docs/theme)
- **Design Token Specification**: [Design Tokens W3C Community Group](https://www.w3.org/community/design-tokens/)
