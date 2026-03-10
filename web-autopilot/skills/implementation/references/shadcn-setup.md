# shadcn/ui 설정 가이드

## 개요

프로젝트에 복사하는 재사용 가능 컴포넌트 (Radix UI + Tailwind CSS).

## 설치

```bash
npx shadcn-ui@latest init
```

**설정**: Style=Default, Base color=Slate, CSS variables=yes

**생성**: components.json, lib/utils.ts, tailwind.config.js, globals.css

## 컴포넌트 추가

```bash
# 필수 컴포넌트
npx shadcn-ui@latest add button input label card badge dialog sheet popover tooltip form select checkbox radio-group textarea switch toast alert table avatar separator skeleton

# 일괄
npx shadcn-ui@latest add button input card dialog form
```

## 테마 커스터마이징

### CSS 변수 (globals.css)

```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --border: 214.3 31.8% 91.4%;
    --radius: 0.5rem;
  }
}
```

### Figma 색상 매핑

1. design-analysis.md 색상 추출
2. HEX → HSL 변환 (#2563EB → 221 83% 53%)
3. CSS 변수 업데이트

```css
:root {
  --primary: 221 83% 53%;     /* Figma #2563EB */
  --secondary: 158 64% 52%;   /* Figma #10B981 */
  --accent: 38 92% 50%;       /* Figma #F59E0B */
}
```

## 컴포넌트 확장

### 변형 추가 (button.tsx)

```tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center...",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground",
        accent: "bg-accent text-accent-foreground",
        success: "bg-green-500 text-white",
      },
      size: { default: "h-10 px-4", sm: "h-9 px-3", lg: "h-11 px-8" },
    },
  }
)
```

## 사용 예제

```tsx
import { Button } from '@/components/ui/button'

<Button variant="default">Primary</Button>
<Button variant="accent" size="lg">Highlight</Button>
```

## 핵심

1. `npx shadcn-ui@latest init`
2. 컴포넌트 `add`
3. `globals.css` CSS 변수 커스터마이징
4. Radix UI 내장 접근성
