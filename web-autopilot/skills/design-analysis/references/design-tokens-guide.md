# Design Tokens 가이드

## 개요

Design tokens는 시스템의 시각적 언어를 정의하는 재사용 가능한 값입니다.

**목적:** Figma → 코드 일관성, 유지보수성, DRY 원칙

---

## Figma에서 추출

### 추출 프로세스
1. Figma 이미지 분석
2. 화면 전체 반복 패턴 식별
3. 정확한 값 추출 (HEX, px, 글꼴)
4. design-analysis.md 문서화

### 추출할 항목

| 카테고리 | 찾을 항목 | 예제 |
|----------|----------|------|
| **색상** | 배경, 텍스트, 테두리, 버튼 | `#3B82F6`, `rgba(59,130,246,0.1)` |
| **간격** | 여백, 패딩 | `4px`, `8px`, `16px`, `24px`, `32px` |
| **타이포그래피** | 글꼴, 크기, 굵기, 줄 높이 | `Inter`, `16px`, `600`, `1.5` |
| **테두리** | 반경, 너비, 색상 | `8px`, `1px`, `#E5E7EB` |
| **그림자** | 박스 그림자 | `0 4px 6px rgba(0,0,0,0.1)` |

---

## 토큰 구조 예제

### 색상
```typescript
colors: {
  primary: '#3B82F6',
  secondary: '#10B981',
  gray100: '#F3F4F6',
  gray900: '#111827',
  success: '#10B981',
  error: '#EF4444',
  textPrimary: '#111827',
  textMuted: '#9CA3AF',
  bgPrimary: '#FFFFFF',
  borderDefault: '#E5E7EB'
}
```

### 간격 (4px 기본)
```typescript
spacing: {
  xs: '4px',
  sm: '8px',
  md: '16px',
  lg: '24px',
  xl: '32px',
  '2xl': '48px'
}
```

### 타이포그래피
```typescript
typography: {
  fontFamily: { sans: 'Inter, sans-serif', mono: 'Fira Code, monospace' },
  fontSize: { xs: '12px', sm: '14px', base: '16px', lg: '18px', xl: '20px', '2xl': '24px' },
  fontWeight: { normal: '400', medium: '500', semibold: '600', bold: '700' },
  lineHeight: { tight: '1.25', normal: '1.5', relaxed: '1.75' }
}
```

---

## 네이밍 규칙

**원칙:**
- **의미론적 우선:** `primary`, `success` (X: `blue`, `green`)
- **계층 구조:** `gray100`, `gray900` (밝음 → 어두움)
- **사용 컨텍스트:** `textPrimary`, `bgSecondary`

**패턴:**
- 색상: `{role}-{variant}` (예: `primary-light`, `text-muted`)
- 간격: `{size}` (예: `xs`, `md`, `2xl`)
- 타이포그래피: `{property}-{size}` (예: `fontSize-lg`)

---

## 구현

### Tailwind CSS 매핑
```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: require('./lib/design-tokens').colors,
      spacing: require('./lib/design-tokens').spacing,
      fontFamily: require('./lib/design-tokens').typography.fontFamily
    }
  }
}
```

### 사용 예제
```tsx
<button className="bg-primary text-white px-md py-sm rounded-lg">
  Submit
</button>
```

---

## 요약

1. **추출:** Figma에서 반복 패턴 식별
2. **구조화:** 카테고리별 (색상/간격/타이포/테두리/그림자)
3. **네이밍:** 의미론적, 계층적
4. **구현:** `lib/design-tokens.ts` → Tailwind config
