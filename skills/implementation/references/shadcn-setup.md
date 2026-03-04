# shadcn/ui 설정 가이드

> 웹 애플리케이션을 위한 shadcn/ui 설정 및 사용자 정의에 대한 완전한 가이드

## 개요

shadcn/ui는 컴포넌트 라이브러리가 **아닙니다**. 프로젝트에 복사하여 완전히 소유하는 **재사용 가능한 컴포넌트** 모음입니다.

**철학:**
- 컴포넌트는 종속성으로 설치되는 것이 아니라 프로젝트에 복사됩니다
- 접근성을 위해 Radix UI 위에 구축
- Tailwind CSS로 스타일링
- 완전히 사용자 정의 가능 - 코드를 제어합니다

**주요 이점:**
- 컴포넌트 코드에 대한 완전한 제어
- 패키지 버전 충돌 없음
- 디자인 시스템을 위한 쉬운 사용자 정의
- Radix UI를 통한 내장 접근성
- 기본 TypeScript 지원

---

## 설치

### 1. shadcn/ui 초기화

```bash
npx shadcn-ui@latest init
```

다음이 생성됩니다:
- `components.json` - 구성 파일
- `lib/utils.ts` - 유틸리티 함수 (cn helper)
- 필요한 설정으로 `tailwind.config.js` 업데이트
- CSS 변수로 `globals.css` 업데이트

### 2. components.json 구성

초기화 중에 프롬프트가 표시됩니다:

```
? Which style would you like to use? ›
❯ Default
  New York

? Which color would you like to use as base color? ›
❯ Slate
  Gray
  Zinc
  Neutral
  Stone

? Would you like to use CSS variables for colors? › yes / no
```

**권장 설정:**
- Style: `Default` (더 깔끔하고 현대적)
- Base color: `Slate` (중립적, 전문적)
- CSS variables: `yes` (더 쉬운 테마)

### 3. 결과 components.json

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "src/app/globals.css",
    "baseColor": "slate",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils"
  }
}
```

---

## 컴포넌트 추가

### 필수 컴포넌트

대부분의 애플리케이션에 필요한 핵심 컴포넌트 추가:

```bash
# Core UI Elements
npx shadcn-ui@latest add button
npx shadcn-ui@latest add input
npx shadcn-ui@latest add label
npx shadcn-ui@latest add card
npx shadcn-ui@latest add badge

# Navigation
npx shadcn-ui@latest add navigation-menu
npx shadcn-ui@latest add tabs
npx shadcn-ui@latest add breadcrumb

# Overlays
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add sheet
npx shadcn-ui@latest add popover
npx shadcn-ui@latest add tooltip

# Forms
npx shadcn-ui@latest add form
npx shadcn-ui@latest add select
npx shadcn-ui@latest add checkbox
npx shadcn-ui@latest add radio-group
npx shadcn-ui@latest add textarea
npx shadcn-ui@latest add switch

# Feedback
npx shadcn-ui@latest add toast
npx shadcn-ui@latest add alert
npx shadcn-ui@latest add alert-dialog
npx shadcn-ui@latest add progress

# Data Display
npx shadcn-ui@latest add table
npx shadcn-ui@latest add avatar
npx shadcn-ui@latest add separator
npx shadcn-ui@latest add skeleton
```

### 일괄 설치

여러 컴포넌트를 한 번에 추가:

```bash
npx shadcn-ui@latest add button input card dialog form
```

### 컴포넌트 파일 구조

컴포넌트가 다음에 추가됩니다:
```
src/
  components/
    ui/
      button.tsx       # Component code
      input.tsx
      card.tsx
      ...
  lib/
    utils.ts           # Utility functions
```

---

## 테마 사용자 정의

### 1. CSS 변수 (globals.css)

초기화 후 `globals.css`에는 테마 변수가 포함됩니다:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;

    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;

    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;

    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;

    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;

    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;

    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;

    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;

    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;

    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;

    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;

    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;

    /* ... dark mode values ... */
  }
}
```

### 2. Figma 색상 적용

design-analysis.md에서 색상을 추출하고 CSS 변수에 매핑:

**예제 Figma 팔레트:**
```
Primary: #2563EB (Blue)
Secondary: #10B981 (Green)
Accent: #F59E0B (Amber)
Neutral: #6B7280 (Gray)
```

**HSL로 변환:**
```
Primary: 221 83% 53%
Secondary: 158 64% 52%
Accent: 38 92% 50%
Neutral: 220 9% 46%
```

**globals.css 업데이트:**
```css
:root {
  /* Brand Colors from Figma */
  --primary: 221 83% 53%;          /* #2563EB */
  --primary-foreground: 0 0% 100%; /* White text */

  --secondary: 158 64% 52%;        /* #10B981 */
  --secondary-foreground: 0 0% 100%;

  --accent: 38 92% 50%;            /* #F59E0B */
  --accent-foreground: 0 0% 100%;

  /* Keep default values for system colors */
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --muted: 220 9% 46%;
  --border: 214.3 31.8% 91.4%;
  --destructive: 0 84.2% 60.2%;

  /* Spacing from Figma */
  --radius: 0.5rem;  /* Adjust based on Figma border-radius */
}
```

### 3. Tailwind Config 통합

`tailwind.config.js`가 자동으로 업데이트됩니다:

```js
module.exports = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        // ... other color mappings
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
```

---

## 컴포넌트 사용자 정의

### 1. 컴포넌트 구조 이해

예제: `components/ui/button.tsx`

```tsx
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
```

### 2. 사용자 정의 변형 추가

Figma 특정 변형을 추가하기 위해 `buttonVariants` 확장:

```tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",

        // Custom Figma variants
        accent: "bg-accent text-accent-foreground hover:bg-accent/90",
        success: "bg-green-500 text-white hover:bg-green-600",
        warning: "bg-yellow-500 text-white hover:bg-yellow-600",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",

        // Custom sizes from Figma
        xs: "h-8 rounded-md px-2 text-xs",
        xl: "h-12 rounded-md px-10 text-base",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)
```

### 3. Props 확장

Figma 디자인 요구사항을 위한 사용자 정의 props 추가:

```tsx
export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
  isLoading?: boolean  // Custom prop
  leftIcon?: React.ReactNode  // Custom prop
  rightIcon?: React.ReactNode  // Custom prop
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, isLoading, leftIcon, rightIcon, children, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        disabled={isLoading || props.disabled}
        {...props}
      >
        {isLoading && <span className="mr-2 animate-spin">⏳</span>}
        {leftIcon && <span className="mr-2">{leftIcon}</span>}
        {children}
        {rightIcon && <span className="ml-2">{rightIcon}</span>}
      </Comp>
    )
  }
)
```

---

## 접근성

shadcn/ui 컴포넌트는 다음을 제공하는 **Radix UI** 위에 구축되었습니다:

### 내장 ARIA 속성

```tsx
// Dialog component automatically includes:
<Dialog>
  <DialogTrigger asChild>
    <Button>Open Dialog</Button>
  </DialogTrigger>
  <DialogContent>  {/* aria-modal="true" automatically added */}
    <DialogHeader>
      <DialogTitle>Title</DialogTitle>  {/* aria-labelledby set */}
      <DialogDescription>Description</DialogDescription>  {/* aria-describedby set */}
    </DialogHeader>
    {/* ... */}
  </DialogContent>
</Dialog>
```

### 키보드 탐색

| 컴포넌트 | 키 |
|-----------|------|
| Dialog | `Esc`로 닫기, 내부 포커스 트랩 |
| Select | `화살표 키`로 탐색, `Enter`로 선택 |
| Tabs | `화살표 키`로 탭 전환 |
| RadioGroup | `화살표 키`로 옵션 선택 |
| NavigationMenu | `Tab` 및 `화살표 키`로 탐색 |

### 스크린 리더 지원

모든 컴포넌트에는 적절한 ARIA 레이블 및 역할이 포함됩니다:
- 버튼이 상태를 알립니다
- 폼 필드에 연결된 레이블이 있습니다
- 대화 상자가 콘텐츠를 알립니다
- 탭이 활성 상태를 알립니다

**모범 사례:**
항상 스크린 리더를 위한 의미 있는 텍스트를 제공합니다:

```tsx
<Button variant="ghost" size="icon">
  <span className="sr-only">Close dialog</span>
  <X className="h-4 w-4" />
</Button>
```

---

## 모범 사례

### 1. UI 컴포넌트를 원자적으로 유지

특정 사용 사례를 위해 shadcn/ui 컴포넌트를 직접 수정하지 마십시오:

**나쁜 예:**
```tsx
// components/ui/button.tsx
// Adding business logic to UI component
const Button = ({ onClick, ...props }) => {
  const handleClick = () => {
    trackAnalytics('button_click')
    onClick?.()
  }
  return <button onClick={handleClick} {...props} />
}
```

**좋은 예:**
```tsx
// components/common/AnalyticsButton.tsx
// Extend UI component in a separate file
import { Button } from '@/components/ui/button'

export function AnalyticsButton({ onClick, event, ...props }) {
  const handleClick = () => {
    trackAnalytics(event)
    onClick?.()
  }
  return <Button onClick={handleClick} {...props} />
}
```

### 2. UI 컴포넌트에서 공통 컴포넌트 구축

UI 프리미티브를 구성하여 도메인별 컴포넌트 만들기:

```tsx
// components/common/FeatureCard.tsx
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

interface FeatureCardProps {
  title: string
  description: string
  badge?: string
  onLearnMore: () => void
}

export function FeatureCard({ title, description, badge, onLearnMore }: FeatureCardProps) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>{title}</CardTitle>
          {badge && <Badge>{badge}</Badge>}
        </div>
        <CardDescription>{description}</CardDescription>
      </CardHeader>
      <CardFooter>
        <Button onClick={onLearnMore}>Learn More</Button>
      </CardFooter>
    </Card>
  )
}
```

### 3. 수정하지 말고 확장

사용자 정의 동작이 필요한 경우 래퍼 컴포넌트를 만듭니다:

```tsx
// components/common/FormButton.tsx
import { Button, ButtonProps } from '@/components/ui/button'
import { useFormContext } from 'react-hook-form'

export function FormButton(props: ButtonProps) {
  const { formState: { isSubmitting } } = useFormContext()

  return <Button disabled={isSubmitting} isLoading={isSubmitting} {...props} />
}
```

### 4. 컴포지션 패턴 사용

유연성을 위해 children 및 slot 패턴 활용:

```tsx
import { Card, CardHeader, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'

export function DashboardCard({ icon, title, value, trend, children }) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-2">
          {icon}
          <span className="text-sm text-muted-foreground">{title}</span>
        </div>
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        <div className="text-sm text-muted-foreground">{trend}</div>
        {children}  {/* Flexible slot for additional content */}
      </CardContent>
    </Card>
  )
}
```

---

## 예제: Figma 색상으로 버튼 사용자 정의

Figma 디자인에 맞게 버튼을 사용자 정의하는 완전한 예제:

### 1. CSS 변수 업데이트 (globals.css)

```css
:root {
  /* Figma Brand Colors */
  --brand-primary: 221 83% 53%;      /* #2563EB - Main CTA */
  --brand-secondary: 158 64% 52%;    /* #10B981 - Success actions */
  --brand-accent: 38 92% 50%;        /* #F59E0B - Highlights */

  /* Map to shadcn system */
  --primary: var(--brand-primary);
  --primary-foreground: 0 0% 100%;
}
```

### 2. 버튼 컴포넌트 확장

```tsx
// components/ui/button.tsx
const buttonVariants = cva(
  // ... base styles ...
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        secondary: "bg-[hsl(var(--brand-secondary))] text-white hover:bg-[hsl(var(--brand-secondary))]/90",
        accent: "bg-[hsl(var(--brand-accent))] text-white hover:bg-[hsl(var(--brand-accent))]/90",
        // ... other variants ...
      },
      // ... sizes ...
    },
  }
)
```

### 3. 사용법

```tsx
<Button variant="default">Primary Action</Button>
<Button variant="secondary">Success Action</Button>
<Button variant="accent">Highlighted Action</Button>
```

---

## 요약

**핵심 요점:**
1. `npx shadcn-ui@latest init`을 실행하여 설정
2. `npx shadcn-ui@latest add [component]`로 컴포넌트 추가
3. `globals.css`의 CSS 변수를 통해 테마 사용자 정의
4. 변형과 props를 추가하여 컴포넌트 확장
5. UI 컴포넌트를 원자적으로 유지, 복합 컴포넌트를 별도로 구축
6. Radix UI를 통해 접근성이 내장됨
7. 코드를 소유합니다 - 자유롭게 사용자 정의!

**다음 단계:**
- Figma design-analysis.md에서 디자인 토큰 추출
- CSS 변수에 색상 매핑
- 프로젝트에 필요한 컴포넌트 추가
- UI 프리미티브를 구성하여 공통 컴포넌트 생성
