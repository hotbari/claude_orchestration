# 프론트엔드 디자인 시스템 명세

> 이 문서는 프론트엔드 에이전트가 UI 키트를 구성할 때 참조하는 표준 명세입니다.
> 뼈대(구조)만 정의하며, 실제 색상 값과 상세 스타일은 `design-config.json` 및 `color-palettes.md`에서 가져옵니다.

## 1. 프로젝트 설정

### 1.1 추가 의존성

`package.json`에 다음 의존성을 추가합니다:

```json
{
  "dependencies": {
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.0",
    "zustand": "^4.5.0"
  },
  "devDependencies": {
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0"
  }
}
```

### 1.2 tailwind.config.ts

CSS custom property 기반으로 색상을 매핑합니다. 실제 색상 값은 `globals.css`의 `:root`에서 정의됩니다.

```typescript
import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: {
          50: "var(--color-primary-50)",
          100: "var(--color-primary-100)",
          200: "var(--color-primary-200)",
          300: "var(--color-primary-300)",
          400: "var(--color-primary-400)",
          500: "var(--color-primary-500)",
          600: "var(--color-primary-600)",
          700: "var(--color-primary-700)",
          800: "var(--color-primary-800)",
          900: "var(--color-primary-900)",
          950: "var(--color-primary-950)",
        },
        secondary: {
          // 동일 패턴 (50~950)
        },
        accent: {
          // 동일 패턴 (50~950)
        },
        success: "var(--color-success)",
        warning: "var(--color-warning)",
        error: "var(--color-error)",
        info: "var(--color-info)",
        background: "var(--color-background)",
        foreground: "var(--color-foreground)",
        muted: "var(--color-muted)",
        border: "var(--color-border)",
      },
      fontFamily: {
        sans: ["var(--font-sans)"],
        mono: ["var(--font-mono)"],
      },
      borderRadius: {
        DEFAULT: "var(--radius)",
      },
      minWidth: {
        'app': '1440px',
      },
      width: {
        'content': '1280px',
        'sidebar': '260px',
      },
      height: {
        'header': '64px',
      },
      animation: {
        "input-focus": "input-focus 0.3s ease-out forwards",
      },
      keyframes: {
        "input-focus": {
          "0%": { boxShadow: "0 0 0 0 rgba(var(--brand-rgb), 0.3)" },
          "50%": { boxShadow: "0 0 0 4px rgba(var(--brand-rgb), 0.15)" },
          "100%": { boxShadow: "0 0 0 2px rgba(var(--brand-rgb), 0.2)" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
```

### 1.3 postcss.config.js

```javascript
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
```

### 1.4 src/styles/globals.css

`:root`에 CSS custom properties를 정의합니다. 실제 값은 `design-config.json`의 팔레트에서 가져옵니다.

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* 색상 — color-palettes.md 또는 design-config.json에서 가져온 값 */
    --color-primary-50: /* 팔레트 값 */;
    --color-primary-500: /* 팔레트 값 */;
    --color-primary-900: /* 팔레트 값 */;
    /* ... 전체 스케일 (50~950) */

    /* 시맨틱 색상 */
    --color-success: /* 팔레트 값 */;
    --color-warning: /* 팔레트 값 */;
    --color-error: /* 팔레트 값 */;
    --color-info: /* 팔레트 값 */;

    /* 배경/전경 */
    --color-background: /* 팔레트 값 */;
    --color-foreground: /* 팔레트 값 */;
    --color-muted: /* 팔레트 값 */;
    --color-border: /* 팔레트 값 */;

    /* 타이포그래피 */
    --font-sans: "Inter", ui-sans-serif, system-ui, sans-serif;
    --font-mono: "JetBrains Mono", ui-monospace, monospace;

    /* 간격/크기 */
    --radius: 0.5rem;

    /* 브랜드 RGB (Input focus 애니메이션용) — primary-500 색상의 RGB 값 */
    --brand-rgb: /* 팔레트의 primary-500 RGB 값, 예: 99, 102, 241 */;
  }
}

@layer base {
  body {
    @apply bg-background text-foreground;
  }
}

/* Input focus 애니메이션 */
@keyframes input-focus {
  0%   { box-shadow: 0 0 0 0 rgba(var(--brand-rgb), 0.3); }
  50%  { box-shadow: 0 0 0 4px rgba(var(--brand-rgb), 0.15); }
  100% { box-shadow: 0 0 0 2px rgba(var(--brand-rgb), 0.2); }
}
```

### 1.5 전 화면 사이즈 통일 규격

모든 페이지에 공통 적용되는 레이아웃 기본값입니다. 페이지별 임의 width/padding을 금지하고, 아래 규격을 통일 적용합니다.

```
기준 해상도: 1440px (min-w-[1440px])
ContentContainer: w-[1280px] mx-auto py-6
Header: h-16 (64px), sticky top-0
Sidebar: w-[260px], border-r
스크롤 정책: Content 영역만 세로 스크롤, Header/Sidebar는 sticky
간격 스케일: 4/8/12/16/24/32/40/48 (px)
카드/섹션: rounded-xl 통일
테두리: border 통일
그림자: shadow-sm 통일 (과한 shadow 금지)
페이지별 임의 width/padding 금지 → ContentContainer에서만 관리
```

### 1.6 src/lib/utils.ts — cn() 유틸리티

```typescript
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

---

## 2. 레이아웃 컴포넌트

### 2.1 ContentContainer

모든 페이지에서 필수 사용하는 콘텐츠 래퍼. 1280px 고정 폭 + 가운데 정렬.

**Props:**
```typescript
interface ContentContainerProps {
  children: React.ReactNode;
  className?: string;
}
```

**참조 구현:**
```tsx
export function ContentContainer({ children, className }: ContentContainerProps) {
  return (
    <div className={cn("w-content mx-auto py-6", className)}>
      {children}
    </div>
  );
}
```

### 2.2 AppLayout

전체 페이지를 감싸는 최상위 레이아웃 래퍼. `min-w-[1440px]` 적용. Footer는 옵션 (기본: 미사용).

**Props:**
```typescript
interface AppLayoutProps {
  children: React.ReactNode;
  sidebar?: React.ReactNode;
  footer?: React.ReactNode;
}
```

**참조 구현:**
```tsx
export function AppLayout({ children, sidebar, footer }: AppLayoutProps) {
  return (
    <div className="flex min-h-screen min-w-app flex-col">
      <Header />
      <div className="flex flex-1">
        {sidebar && <aside className="w-sidebar border-r border-border">{sidebar}</aside>}
        <main className="flex-1 overflow-y-auto">
          <ContentContainer>{children}</ContentContainer>
        </main>
      </div>
      {footer && footer}
    </div>
  );
}
```

### 2.3 Header

고정 상단바. 좌측: 로고 + 메인 내비게이션, 우측: 외부 링크 + 사용자 메뉴.

**Props:**
```typescript
interface HeaderProps {
  logo?: React.ReactNode;
  title: string;
  navItems?: { label: string; href: string }[];
  actions?: React.ReactNode;
}
```

**참조 구현:**
```tsx
export function Header({ logo, title, navItems = [], actions }: HeaderProps) {
  return (
    <header className="sticky top-0 z-40 h-header border-b border-border bg-white/80 backdrop-blur-[12px]">
      <div className="flex h-full items-center gap-4 px-6">
        {/* 좌: 로고 + 메인 내비게이션 */}
        {logo && <div className="flex-shrink-0">{logo}</div>}
        <h1 className="text-lg font-semibold">{title}</h1>
        <nav className="ml-6 flex gap-4">
          {navItems.map((item) => (
            <a
              key={item.href}
              href={item.href}
              className="text-sm text-muted hover:text-foreground"
            >
              {item.label}
            </a>
          ))}
        </nav>
        {/* 우: 외부 링크 + 사용자 메뉴 */}
        {actions && <div className="ml-auto flex items-center gap-2">{actions}</div>}
      </div>
    </header>
  );
}
```

### 2.4 Sidebar

사이드 내비게이션. `w-[260px]` 고정, 메뉴 그룹/선택 상태 표시, 스크롤 가능.

**Props:**
```typescript
interface SidebarGroup {
  title?: string;
  items: SidebarItem[];
}

interface SidebarItem {
  label: string;
  href: string;
  icon?: React.ReactNode;
  active?: boolean;
}

interface SidebarProps {
  items: SidebarItem[];
  groups?: SidebarGroup[];
  collapsed?: boolean;
}
```

**참조 구현:**
```tsx
export function Sidebar({ items, groups, collapsed = false }: SidebarProps) {
  const renderItem = (item: SidebarItem) => (
    <a
      key={item.href}
      href={item.href}
      className={cn(
        "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
        item.active
          ? "bg-primary-50 text-primary-700 font-medium"
          : "text-muted hover:bg-primary-50 hover:text-foreground",
      )}
    >
      {item.icon && <span className="flex-shrink-0">{item.icon}</span>}
      {!collapsed && <span>{item.label}</span>}
    </a>
  );

  return (
    <nav className={cn(
      "flex flex-col gap-1 overflow-y-auto p-4",
      collapsed ? "w-16" : "w-sidebar",
    )}>
      {groups
        ? groups.map((group, idx) => (
            <div key={idx} className="flex flex-col gap-1">
              {group.title && (
                <span className="mb-1 px-3 text-xs font-semibold uppercase text-muted">
                  {group.title}
                </span>
              )}
              {group.items.map(renderItem)}
            </div>
          ))
        : items.map(renderItem)}
    </nav>
  );
}
```

### 2.5 Footer

하단 영역 (옵션 — 기본 미사용).

**Props:**
```typescript
interface FooterProps {
  children: React.ReactNode;
}
```

**참조 구현:**
```tsx
export function Footer({ children }: FooterProps) {
  return (
    <footer className="border-t border-border px-6 py-4 text-sm text-muted">
      {children}
    </footer>
  );
}
```

---

## 3. 기본 UI 컴포넌트

### 3.1 Button

**Props:**
```typescript
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "outline" | "ghost" | "destructive";
  size?: "sm" | "md" | "lg";
  loading?: boolean;
}
```

**Tailwind 클래스 매핑:**
```typescript
const variantStyles = {
  primary: "bg-primary-500 text-white hover:bg-primary-600 focus-visible:ring-primary-500",
  secondary: "border border-border bg-white text-foreground hover:bg-primary-50 focus-visible:ring-primary-300",
  outline: "border border-border bg-transparent hover:bg-primary-50 focus-visible:ring-primary-300",
  ghost: "bg-transparent text-muted hover:bg-primary-50 focus-visible:ring-primary-300",
  destructive: "bg-error text-white hover:opacity-90 focus-visible:ring-error",
};

const sizeStyles = {
  sm: "h-8 px-3 text-xs",
  md: "h-10 px-4 text-sm",
  lg: "h-12 px-6 text-base",
};
```

**핵심 동작 — press 애니메이션:**
- 클릭 시 `active:scale-[0.97]` (살짝 scale-down)
- 클릭 시 `active:brightness-95` (색상 살짝 어두워짐)
- **모든 variant(Primary / Secondary / Outline / Ghost / Destructive)에 동일 적용**
- `transition-all duration-150`으로 부드러운 복원
- loading 시 spinner SVG + "처리 중..." 텍스트 표시

**참조 구현:**
```tsx
export function Button({
  variant = "primary",
  size = "md",
  loading = false,
  disabled,
  children,
  className,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(
        // 공통 기본
        "inline-flex items-center justify-center rounded-lg font-medium outline-none transition-all duration-150",
        // 공통 press 애니메이션 (모든 variant 동일)
        "active:scale-[0.97] active:brightness-95",
        // Focus 접근성
        "focus-visible:ring-2 focus-visible:ring-offset-2",
        // Disabled
        "disabled:cursor-not-allowed disabled:opacity-50",
        variantStyles[variant],
        sizeStyles[size],
        className,
      )}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? (
        <span className="flex items-center gap-2">
          <svg className="h-4 w-4 animate-spin" viewBox="0 0 24 24" fill="none" role="status" aria-label="로딩 중">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z" />
          </svg>
          처리 중...
        </span>
      ) : (
        children
      )}
    </button>
  );
}
```

### 3.2 Input

**Props:**
```typescript
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  variant?: "default" | "error";
  label?: string;
  error?: string;
  helperText?: string;
}
```

**상태 정의:**
- `Enabled`: 기본 입력 가능 상태 (`border-border`)
- `Focused`: 테두리/ring 강조 + pulse 애니메이션 (`focus:border-primary-500 focus:ring-2 focus:animate-input-focus`)
- `Typing`: Focused와 동일 (사용자가 입력 중임을 ring으로 표시)
- `Disabled`: 입력 불가, 회색 처리 (`disabled:bg-muted disabled:cursor-not-allowed`)
- `Error`: 빨간 테두리 + 에러 메시지 (`border-error focus:border-error focus:ring-error/20`)

**참조 구현:**
```tsx
export function Input({ variant = "default", label, error, helperText, id, className, ...props }: InputProps) {
  const inputId = id || label?.toLowerCase().replace(/\s+/g, "-");
  const isError = variant === "error" || !!error;

  return (
    <div className="flex flex-col gap-1">
      {label && (
        <label htmlFor={inputId} className="text-sm font-medium text-foreground">
          {label}
        </label>
      )}
      <input
        id={inputId}
        className={cn(
          // 기본 스타일
          "w-full rounded-lg border px-3 py-2 text-sm outline-none transition-all duration-200",
          // Enabled
          "border-border bg-background text-foreground placeholder:text-muted",
          // Focus (포커스 강조 + pulse 애니메이션)
          "focus:border-primary-500 focus:ring-2 focus:ring-primary-500/20",
          "focus:animate-input-focus",
          // Disabled
          "disabled:cursor-not-allowed disabled:bg-muted disabled:text-muted",
          // Error
          isError && "border-error focus:border-error focus:ring-error/20",
          className,
        )}
        aria-invalid={isError}
        aria-describedby={error ? `${inputId}-error` : helperText ? `${inputId}-helper` : undefined}
        {...props}
      />
      {error && (
        <span id={`${inputId}-error`} className="text-xs text-error" role="alert">
          {error}
        </span>
      )}
      {helperText && !error && (
        <p id={`${inputId}-helper`} className="text-sm text-muted">
          {helperText}
        </p>
      )}
    </div>
  );
}
```

### 3.3 Select

**Props:**
```typescript
interface SelectOption {
  value: string;
  label: string;
}

interface SelectProps {
  options: SelectOption[];
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  label?: string;
  error?: string;
  disabled?: boolean;
  className?: string;
}
```

**핵심 동작:**
- 클릭/Enter로 드롭다운 열기, 외부 클릭/Escape로 닫기
- 옵션 목록에서 Arrow Up/Down으로 이동, Enter로 선택
- 선택된 옵션 표시, placeholder 지원
- disabled 상태에서 열기 불가
- `role="listbox"`, 각 옵션 `role="option"`, `aria-selected`

**참조 구현:**
```tsx
export function Select({
  options,
  value,
  onChange,
  placeholder = "선택하세요",
  label,
  error,
  disabled = false,
  className,
}: SelectProps) {
  const [open, setOpen] = useState(false);
  const [highlightIdx, setHighlightIdx] = useState(-1);
  const containerRef = useRef<HTMLDivElement>(null);
  const selectedOption = options.find((o) => o.value === value);
  const selectId = label?.toLowerCase().replace(/\s+/g, "-");

  useEffect(() => {
    if (!open) return;
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (disabled) return;
    if (e.key === "Enter" || e.key === " ") {
      if (!open) { setOpen(true); return; }
      if (highlightIdx >= 0) { onChange?.(options[highlightIdx].value); setOpen(false); }
    }
    if (e.key === "Escape") setOpen(false);
    if (e.key === "ArrowDown") { e.preventDefault(); setHighlightIdx((i) => Math.min(i + 1, options.length - 1)); }
    if (e.key === "ArrowUp") { e.preventDefault(); setHighlightIdx((i) => Math.max(i - 1, 0)); }
  };

  return (
    <div ref={containerRef} className={cn("flex flex-col gap-1", className)}>
      {label && <label htmlFor={selectId} className="text-sm font-medium text-foreground">{label}</label>}
      <button
        id={selectId}
        type="button"
        role="combobox"
        aria-expanded={open}
        aria-haspopup="listbox"
        disabled={disabled}
        onClick={() => !disabled && setOpen(!open)}
        onKeyDown={handleKeyDown}
        className={cn(
          "flex h-10 w-full items-center justify-between rounded-lg border px-3 py-2 text-sm outline-none transition-all",
          "border-border bg-background",
          "focus:border-primary-500 focus:ring-2 focus:ring-primary-500/20",
          "disabled:cursor-not-allowed disabled:opacity-50",
          error && "border-error",
        )}
      >
        <span className={selectedOption ? "text-foreground" : "text-muted"}>
          {selectedOption?.label ?? placeholder}
        </span>
        <span className="text-muted">▾</span>
      </button>
      {open && (
        <ul role="listbox" className="mt-1 max-h-60 overflow-auto rounded-lg border border-border bg-background py-1 shadow-sm">
          {options.map((opt, idx) => (
            <li
              key={opt.value}
              role="option"
              aria-selected={opt.value === value}
              className={cn(
                "cursor-pointer px-3 py-2 text-sm",
                opt.value === value && "bg-primary-50 text-primary-700 font-medium",
                idx === highlightIdx && "bg-primary-50",
                "hover:bg-primary-50",
              )}
              onClick={() => { onChange?.(opt.value); setOpen(false); }}
            >
              {opt.label}
            </li>
          ))}
        </ul>
      )}
      {error && <span className="text-xs text-error" role="alert">{error}</span>}
    </div>
  );
}
```

### 3.4 Textarea

Input과 동일한 focus 애니메이션/error 상태를 공유하는 텍스트 영역.

**Props:**
```typescript
interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  label?: string;
  error?: string;
  helperText?: string;
  autoResize?: boolean;
}
```

**핵심 동작:**
- Input과 동일한 focus pulse 애니메이션 (`focus:animate-input-focus`)
- error 상태 시 빨간 테두리 + 에러 메시지
- `autoResize=true` 시 내용에 따라 높이 자동 조절
- `aria-invalid`, `aria-describedby` 접근성

**참조 구현:**
```tsx
export function Textarea({
  label,
  error,
  helperText,
  autoResize = false,
  id,
  className,
  rows = 4,
  ...props
}: TextareaProps) {
  const textareaId = id || label?.toLowerCase().replace(/\s+/g, "-");
  const isError = !!error;
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const handleInput = () => {
    if (autoResize && textareaRef.current) {
      textareaRef.current.style.height = "auto";
      textareaRef.current.style.height = textareaRef.current.scrollHeight + "px";
    }
  };

  return (
    <div className="flex flex-col gap-1">
      {label && (
        <label htmlFor={textareaId} className="text-sm font-medium text-foreground">
          {label}
        </label>
      )}
      <textarea
        ref={textareaRef}
        id={textareaId}
        rows={rows}
        onInput={handleInput}
        className={cn(
          "w-full rounded-lg border px-3 py-2 text-sm outline-none transition-all duration-200",
          "border-border bg-background text-foreground placeholder:text-muted",
          "focus:border-primary-500 focus:ring-2 focus:ring-primary-500/20",
          "focus:animate-input-focus",
          "disabled:cursor-not-allowed disabled:bg-muted disabled:text-muted",
          isError && "border-error focus:border-error focus:ring-error/20",
          className,
        )}
        aria-invalid={isError}
        aria-describedby={error ? `${textareaId}-error` : helperText ? `${textareaId}-helper` : undefined}
        {...props}
      />
      {error && (
        <span id={`${textareaId}-error`} className="text-xs text-error" role="alert">
          {error}
        </span>
      )}
      {helperText && !error && (
        <p id={`${textareaId}-helper`} className="text-sm text-muted">
          {helperText}
        </p>
      )}
    </div>
  );
}
```

### 3.5 Checkbox

**Props:**
```typescript
interface CheckboxProps {
  checked?: boolean;
  onChange?: (checked: boolean) => void;
  label?: string;
  disabled?: boolean;
  className?: string;
}
```

**핵심 동작:**
- 체크 애니메이션 (CSS transition)
- label 클릭 시 토글
- `aria-checked`, `role="checkbox"` 접근성
- disabled 상태

**참조 구현:**
```tsx
export function Checkbox({
  checked = false,
  onChange,
  label,
  disabled = false,
  className,
}: CheckboxProps) {
  const id = label?.toLowerCase().replace(/\s+/g, "-");

  return (
    <label
      htmlFor={id}
      className={cn(
        "inline-flex items-center gap-2 text-sm",
        disabled ? "cursor-not-allowed opacity-50" : "cursor-pointer",
        className,
      )}
    >
      <input
        id={id}
        type="checkbox"
        role="checkbox"
        aria-checked={checked}
        checked={checked}
        disabled={disabled}
        onChange={(e) => onChange?.(e.target.checked)}
        className={cn(
          "h-4 w-4 rounded border border-border text-primary-500 transition-colors",
          "focus-visible:ring-2 focus-visible:ring-primary-500/20 focus-visible:ring-offset-2",
          "checked:border-primary-500 checked:bg-primary-500",
          "disabled:cursor-not-allowed disabled:opacity-50",
        )}
      />
      {label && <span className="text-foreground">{label}</span>}
    </label>
  );
}
```

### 3.6 Card

**Props:**
```typescript
interface CardProps {
  children: React.ReactNode;
  header?: React.ReactNode;
  footer?: React.ReactNode;
  className?: string;
}
```

**참조 구현:**
```tsx
export function Card({ children, header, footer, className }: CardProps) {
  return (
    <div className={cn("rounded border border-border bg-background shadow-sm", className)}>
      {header && <div className="border-b border-border px-6 py-4">{header}</div>}
      <div className="px-6 py-4">{children}</div>
      {footer && <div className="border-t border-border px-6 py-4">{footer}</div>}
    </div>
  );
}
```

### 3.7 Table

**Props:**
```typescript
interface Column<T> {
  key: string;
  header: string;
  render?: (item: T) => React.ReactNode;
}

interface TableProps<T> {
  columns: Column<T>[];
  data: T[];
  emptyMessage?: string;
  onSort?: (key: string) => void;
}
```

**참조 구현:**
```tsx
export function Table<T extends Record<string, unknown>>({
  columns,
  data,
  emptyMessage = "데이터가 없습니다.",
  onSort,
}: TableProps<T>) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-border">
            {columns.map((col) => (
              <th
                key={col.key}
                className="px-4 py-3 text-left font-medium text-muted"
                onClick={() => onSort?.(col.key)}
                style={onSort ? { cursor: "pointer" } : undefined}
              >
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.length === 0 ? (
            <tr>
              <td colSpan={columns.length} className="px-4 py-8 text-center text-muted">
                {emptyMessage}
              </td>
            </tr>
          ) : (
            data.map((item, idx) => (
              <tr key={idx} className="border-b border-border last:border-0">
                {columns.map((col) => (
                  <td key={col.key} className="px-4 py-3">
                    {col.render ? col.render(item) : String(item[col.key] ?? "")}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
```

### 3.8 Form

네이티브 `<form>` + FormField 패턴.

**Props:**
```typescript
interface FormProps extends React.FormHTMLAttributes<HTMLFormElement> {
  children: React.ReactNode;
}

interface FormFieldProps {
  children: React.ReactNode;
  className?: string;
}
```

**참조 구현:**
```tsx
export function Form({ children, className, ...props }: FormProps) {
  return (
    <form className={cn("flex flex-col gap-4", className)} {...props}>
      {children}
    </form>
  );
}

export function FormField({ children, className }: FormFieldProps) {
  return <div className={cn("flex flex-col gap-1.5", className)}>{children}</div>;
}
```

### 3.9 Tabs

콘텐츠 탭 전환 컴포넌트. Compound Component 패턴.

**Props:**
```typescript
interface Tab {
  id: string;
  label: string;
  content: React.ReactNode;
}

interface TabsProps {
  tabs: Tab[];
  defaultActiveId?: string;
  activeId?: string;
  onChange?: (id: string) => void;
  className?: string;
}
```

**핵심 동작:**
- 탭 클릭 시 해당 콘텐츠 패널 표시
- active 탭에 하단 border 또는 배경 강조
- 키보드: Arrow Left/Right로 탭 이동, Enter/Space로 선택
- `role="tablist"`, `role="tab"`, `role="tabpanel"` 접근성
- `aria-selected`, `aria-controls`, `aria-labelledby`

**참조 구현:**
```tsx
export function Tabs({ tabs, defaultActiveId, activeId, onChange, className }: TabsProps) {
  const [internalActive, setInternalActive] = useState(defaultActiveId ?? tabs[0]?.id);
  const currentId = activeId ?? internalActive;
  const activeTab = tabs.find((t) => t.id === currentId);

  const handleSelect = (id: string) => {
    setInternalActive(id);
    onChange?.(id);
  };

  const handleKeyDown = (e: React.KeyboardEvent, idx: number) => {
    let newIdx = idx;
    if (e.key === "ArrowRight") newIdx = (idx + 1) % tabs.length;
    if (e.key === "ArrowLeft") newIdx = (idx - 1 + tabs.length) % tabs.length;
    if (newIdx !== idx) {
      e.preventDefault();
      handleSelect(tabs[newIdx].id);
    }
  };

  return (
    <div className={className}>
      <div role="tablist" className="flex border-b border-border">
        {tabs.map((tab, idx) => (
          <button
            key={tab.id}
            role="tab"
            aria-selected={tab.id === currentId}
            aria-controls={`tabpanel-${tab.id}`}
            id={`tab-${tab.id}`}
            tabIndex={tab.id === currentId ? 0 : -1}
            onClick={() => handleSelect(tab.id)}
            onKeyDown={(e) => handleKeyDown(e, idx)}
            className={cn(
              "px-4 py-2 text-sm font-medium transition-colors",
              tab.id === currentId
                ? "border-b-2 border-primary-500 text-primary-700"
                : "text-muted hover:text-foreground",
            )}
          >
            {tab.label}
          </button>
        ))}
      </div>
      {activeTab && (
        <div
          role="tabpanel"
          id={`tabpanel-${activeTab.id}`}
          aria-labelledby={`tab-${activeTab.id}`}
          className="py-4"
        >
          {activeTab.content}
        </div>
      )}
    </div>
  );
}
```

### 3.10 SearchInput

아이콘 + clear 버튼 + debounce 내장 검색 입력.

**Props:**
```typescript
interface SearchInputProps {
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  debounceMs?: number;
  className?: string;
}
```

**핵심 동작:**
- 좌측 돋보기 아이콘, 입력 시 우측 clear(X) 버튼 표시
- debounce: 지정 시간(기본 300ms) 후 onChange 호출
- Escape 키로 입력 초기화
- `role="searchbox"` 접근성

**참조 구현:**
```tsx
export function SearchInput({
  value: controlledValue,
  onChange,
  placeholder = "검색...",
  debounceMs = 300,
  className,
}: SearchInputProps) {
  const [internalValue, setInternalValue] = useState(controlledValue ?? "");
  const displayValue = controlledValue ?? internalValue;
  const timerRef = useRef<ReturnType<typeof setTimeout>>();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    setInternalValue(val);
    if (timerRef.current) clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => onChange?.(val), debounceMs);
  };

  const handleClear = () => {
    setInternalValue("");
    onChange?.("");
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Escape") handleClear();
  };

  return (
    <div className={cn("relative", className)}>
      <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-muted">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
          <circle cx="11" cy="11" r="8" /><path d="M21 21l-4.35-4.35" />
        </svg>
      </span>
      <input
        type="text"
        role="searchbox"
        value={displayValue}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        className={cn(
          "w-full rounded-lg border border-border bg-background py-2 pl-9 pr-9 text-sm outline-none transition-all",
          "focus:border-primary-500 focus:ring-2 focus:ring-primary-500/20",
          "placeholder:text-muted",
        )}
      />
      {displayValue && (
        <button
          type="button"
          onClick={handleClear}
          aria-label="검색어 지우기"
          className="absolute right-3 top-1/2 -translate-y-1/2 text-muted hover:text-foreground"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
            <path d="M18 6L6 18M6 6l12 12" />
          </svg>
        </button>
      )}
    </div>
  );
}
```

### 3.11 FileUpload

파일 업로드 영역. drag & drop, 파일 선택 버튼, 크기 제한.

**Props:**
```typescript
interface FileUploadProps {
  accept?: string;
  maxSizeMB?: number;
  multiple?: boolean;
  onFiles?: (files: File[]) => void;
  className?: string;
}
```

**핵심 동작:**
- drag & drop 영역 (드래그 중 시각적 피드백)
- 클릭 시 파일 선택 다이얼로그 열기
- 파일 크기 제한 초과 시 에러 메시지
- 선택된 파일 정보 표시
- drop zone `aria-label`, 파일 상태 안내

**참조 구현:**
```tsx
export function FileUpload({
  accept,
  maxSizeMB = 10,
  multiple = false,
  onFiles,
  className,
}: FileUploadProps) {
  const [isDragging, setIsDragging] = useState(false);
  const [files, setFiles] = useState<File[]>([]);
  const [error, setError] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const validateAndSet = (fileList: FileList | null) => {
    if (!fileList) return;
    const selected = Array.from(fileList);
    const oversized = selected.filter((f) => f.size > maxSizeMB * 1024 * 1024);
    if (oversized.length > 0) {
      setError(`파일 크기가 ${maxSizeMB}MB를 초과합니다: ${oversized.map((f) => f.name).join(", ")}`);
      return;
    }
    setError(null);
    setFiles(selected);
    onFiles?.(selected);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    validateAndSet(e.dataTransfer.files);
  };

  return (
    <div className={cn("flex flex-col gap-2", className)}>
      <div
        role="button"
        aria-label="파일 업로드 영역"
        tabIndex={0}
        onDragOver={(e) => { e.preventDefault(); setIsDragging(true); }}
        onDragLeave={() => setIsDragging(false)}
        onDrop={handleDrop}
        onClick={() => inputRef.current?.click()}
        onKeyDown={(e) => { if (e.key === "Enter" || e.key === " ") inputRef.current?.click(); }}
        className={cn(
          "flex flex-col items-center justify-center rounded-xl border-2 border-dashed p-8 text-center transition-colors",
          isDragging ? "border-primary-500 bg-primary-50" : "border-border hover:border-primary-300",
        )}
      >
        <p className="text-sm text-muted">
          파일을 드래그하거나 <span className="font-medium text-primary-500">클릭하여 선택</span>
        </p>
        <p className="mt-1 text-xs text-muted">최대 {maxSizeMB}MB</p>
        <input
          ref={inputRef}
          type="file"
          accept={accept}
          multiple={multiple}
          onChange={(e) => validateAndSet(e.target.files)}
          className="hidden"
        />
      </div>
      {error && <span className="text-xs text-error" role="alert">{error}</span>}
      {files.length > 0 && (
        <ul className="flex flex-col gap-1 text-sm text-foreground">
          {files.map((f, i) => (
            <li key={i} className="flex items-center gap-2">
              <span>{f.name}</span>
              <span className="text-xs text-muted">({(f.size / 1024).toFixed(1)} KB)</span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

### 3.12 Badge

**Props:**
```typescript
interface BadgeProps {
  variant?: "default" | "success" | "warning" | "error" | "info";
  children: React.ReactNode;
  className?: string;
}
```

**참조 구현:**
```tsx
const badgeVariants = {
  default: "bg-primary-100 text-primary-800",
  success: "bg-green-100 text-green-800",
  warning: "bg-amber-100 text-amber-800",
  error: "bg-red-100 text-red-800",
  info: "bg-blue-100 text-blue-800",
};

export function Badge({ variant = "default", children, className }: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
        badgeVariants[variant],
        className,
      )}
    >
      {children}
    </span>
  );
}
```

### 3.13 Spinner

**Props:**
```typescript
interface SpinnerProps {
  size?: "sm" | "md" | "lg";
  className?: string;
}
```

**참조 구현:**
```tsx
const spinnerSizes = {
  sm: "h-4 w-4",
  md: "h-6 w-6",
  lg: "h-8 w-8",
};

export function Spinner({ size = "md", className }: SpinnerProps) {
  return (
    <svg
      className={cn("animate-spin text-primary-500", spinnerSizes[size], className)}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      role="status"
      aria-label="로딩 중"
    >
      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
      />
    </svg>
  );
}
```

---

## 4. 피드백 컴포넌트

### 4.1 Modal

**Props:**
```typescript
interface ModalProps {
  open: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
  actions?: React.ReactNode;
}
```

**핵심 동작:**
- `open=true`일 때만 렌더링
- Escape 키로 닫기
- 배경(backdrop) 클릭으로 닫기
- focus trap: 열릴 때 첫 포커스 가능 요소에 포커스, Tab 순환
- `role="dialog"`, `aria-modal="true"`, `aria-labelledby`

**참조 구현:**
```tsx
export function Modal({ open, onClose, title, children, actions }: ModalProps) {
  const dialogRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black/50" onClick={onClose} aria-hidden="true" />
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        className="relative z-50 w-full max-w-lg rounded bg-background p-6 shadow-lg"
      >
        <h2 id="modal-title" className="text-lg font-semibold">
          {title}
        </h2>
        <div className="mt-4">{children}</div>
        {actions && <div className="mt-6 flex justify-end gap-2">{actions}</div>}
      </div>
    </div>
  );
}
```

### 4.2 Toast

Zustand store 패턴. 우하단 고정 표시. 자동 사라짐 + 수동 닫기.

**타입 (toast.types.ts):**
```typescript
export type ToastTone = "success" | "info" | "warn" | "error";

export interface ToastItem {
  id: string;
  tone: ToastTone;
  message: string;
  duration?: number; // ms. success/info: 3000, warn/error: 5000
}
```

**Store (useToast.ts — Zustand):**
```typescript
import { create } from "zustand";
import type { ToastItem, ToastTone } from "./toast.types";

interface ToastStore {
  toasts: ToastItem[];
  show: (tone: ToastTone, message: string, duration?: number) => void;
  dismiss: (id: string) => void;
}

export const useToastStore = create<ToastStore>((set) => ({
  toasts: [],
  show: (tone, message, duration) => {
    const id = crypto.randomUUID();
    const defaultDuration = tone === "success" || tone === "info" ? 3000 : 5000;
    set((s) => ({
      toasts: [...s.toasts, { id, tone, message, duration: duration ?? defaultDuration }],
    }));
  },
  dismiss: (id) => set((s) => ({ toasts: s.toasts.filter((t) => t.id !== id) })),
}));

// 편의 함수 — Provider 없이 어디서든 호출 가능
export const toast = {
  success: (msg: string) => useToastStore.getState().show("success", msg),
  info: (msg: string) => useToastStore.getState().show("info", msg),
  warn: (msg: string) => useToastStore.getState().show("warn", msg),
  error: (msg: string) => useToastStore.getState().show("error", msg),
};
```

**컨테이너 (ToastContainer.tsx):**
```tsx
import { useEffect } from "react";
import { useToastStore } from "./useToast";
import { cn } from "@/lib/utils";

const toneStyles: Record<string, string> = {
  success: "border-l-4 border-success bg-background",
  info: "border-l-4 border-info bg-background",
  warn: "border-l-4 border-warning bg-background",
  error: "border-l-4 border-error bg-background",
};

const toneIcons: Record<string, string> = {
  success: "✓",
  info: "ℹ",
  warn: "⚠",
  error: "✕",
};

export function ToastContainer() {
  const { toasts, dismiss } = useToastStore();

  return (
    <div className="fixed bottom-6 right-6 z-50 flex w-80 flex-col gap-2">
      {toasts.map((t) => (
        <ToastCard key={t.id} item={t} onDismiss={dismiss} />
      ))}
    </div>
  );
}

function ToastCard({
  item,
  onDismiss,
}: {
  item: import("./toast.types").ToastItem;
  onDismiss: (id: string) => void;
}) {
  useEffect(() => {
    if (!item.duration) return;
    const timer = setTimeout(() => onDismiss(item.id), item.duration);
    return () => clearTimeout(timer);
  }, [item, onDismiss]);

  return (
    <div className={cn("flex items-start gap-3 rounded-lg p-4 shadow-md", toneStyles[item.tone])}>
      <span className="text-sm font-bold">{toneIcons[item.tone]}</span>
      <p className="flex-1 text-sm text-foreground">{item.message}</p>
      <button onClick={() => onDismiss(item.id)} aria-label="닫기" className="text-muted hover:text-foreground">
        ×
      </button>
    </div>
  );
}
```

**자동 메시지 생성 규칙:**

| 액션 | tone | 메시지 |
|------|------|--------|
| 업로드 성공 | `success` | "업로드가 완료되었습니다." |
| 저장 성공 | `success` | "변경 사항이 저장되었습니다." |
| 삭제 성공 | `success` | "파일이 삭제되었습니다." |
| 처리 실패 | `error` | "요청 처리에 실패했습니다. 잠시 후 다시 시도해주세요." |
| 권한 없음 | `error` | "권한이 없습니다." |
| 경고 | `warn` | 상황에 맞는 메시지 |

### 4.3 ConfirmDialog

되돌리기 어려운 행위(파일 삭제, OCR 실행 등)에 대한 확인 팝업.

**Props:**
```typescript
interface ConfirmDialogProps {
  open: boolean;
  title: string;
  description: string;
  confirmLabel?: string;  // 기본값: "확인"
  cancelLabel?: string;   // 기본값: "취소"
  onConfirm: () => void;
  onCancel: () => void;
  /** 위험 행위 여부 — true면 확인 버튼이 destructive(빨간색) */
  destructive?: boolean;
}
```

**핵심 동작:**
- `open=true`일 때만 렌더링
- 반투명 오버레이(`bg-black/40`) 클릭 시 `onCancel` 호출
- `destructive=true`: 확인 버튼이 `bg-error text-white`
- `destructive=false`: 확인 버튼이 `bg-primary-500 text-white`
- 버튼에 press 애니메이션 (`active:scale-[0.97]`) 적용

**적용 대상:**

| 대상 | 필수 여부 |
|------|----------|
| 파일 삭제 | 필수 |
| OCR 추출 시작 | 옵션 (장시간/비용 발생 시) |
| 버전 업로드 시작 | 옵션 (대용량 시) |

**참조 구현:**
```tsx
export function ConfirmDialog({
  open,
  title,
  description,
  confirmLabel = "확인",
  cancelLabel = "취소",
  onConfirm,
  onCancel,
  destructive = true,
}: ConfirmDialogProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/40" onClick={onCancel} aria-hidden="true" />
      {/* Dialog */}
      <div className="relative z-10 w-full max-w-md rounded-xl bg-background p-6 shadow-lg">
        <h2 className="text-base font-semibold text-foreground">{title}</h2>
        <p className="mt-2 text-sm text-muted">{description}</p>
        <div className="mt-6 flex justify-end gap-3">
          <button
            onClick={onCancel}
            className="h-9 rounded-lg border border-border px-4 text-sm text-foreground transition-all hover:bg-primary-50 active:scale-[0.97]"
          >
            {cancelLabel}
          </button>
          <button
            onClick={onConfirm}
            className={cn(
              "h-9 rounded-lg px-4 text-sm text-white transition-all active:scale-[0.97]",
              destructive ? "bg-error hover:opacity-90" : "bg-primary-500 hover:bg-primary-600",
            )}
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
```

**사용 예시:**
```tsx
function FileDeleteButton({ fileName, onDelete }: { fileName: string; onDelete: () => void }) {
  const [open, setOpen] = useState(false);

  const handleConfirm = () => {
    setOpen(false);
    onDelete();
    toast.success("파일이 삭제되었습니다.");
  };

  return (
    <>
      <button onClick={() => setOpen(true)} aria-label="파일 삭제">
        삭제
      </button>
      <ConfirmDialog
        open={open}
        title="삭제하시겠습니까?"
        description={`"${fileName}"을(를) 삭제하면 복구할 수 없습니다.`}
        confirmLabel="삭제"
        onConfirm={handleConfirm}
        onCancel={() => setOpen(false)}
        destructive
      />
    </>
  );
}
```

---

## 5. 조합 패턴

에이전트는 페이지를 구현할 때 다음 조합 패턴을 따릅니다.

### 5.1 목록 페이지

```tsx
<AppLayout>
  <Card header={<h2>제목</h2>}>
    <Table columns={columns} data={data} />
  </Card>
</AppLayout>
```

### 5.2 폼 페이지

```tsx
<AppLayout>
  <Card header={<h2>폼 제목</h2>}>
    <Form onSubmit={handleSubmit}>
      <Input label="필드명" />
      <Button type="submit">저장</Button>
    </Form>
  </Card>
</AppLayout>
```

### 5.3 대시보드

```tsx
<AppLayout sidebar={<Sidebar items={navItems} />}>
  <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
    <Card header={<h3>카드 제목</h3>}>내용</Card>
    <Card header={<h3>카드 제목</h3>}>내용</Card>
    <Card header={<h3>카드 제목</h3>}>내용</Card>
  </div>
</AppLayout>
```

---

## 6. 접근성 요구사항

### ARIA 역할
- Button: 네이티브 `<button>` 사용, `aria-disabled` 대신 `disabled` 속성
- Modal: `role="dialog"`, `aria-modal="true"`, `aria-labelledby`
- Spinner: `role="status"`, `aria-label="로딩 중"`
- Input/Textarea 에러: `aria-invalid="true"`, `aria-describedby` 에러 메시지 연결
- Table: 네이티브 `<table>`, `<thead>`, `<tbody>` 사용
- Select: `role="listbox"`, 각 옵션 `role="option"`, `aria-selected`
- Checkbox: `role="checkbox"`, `aria-checked`
- Tabs: `role="tablist"` / `role="tab"` / `role="tabpanel"`, `aria-selected`
- SearchInput: `role="searchbox"`, Escape로 clear
- FileUpload: drop zone `aria-label`, 파일 상태 안내

### 키보드 네비게이션
- 모든 인터랙티브 요소는 Tab 키로 접근 가능
- Modal: Escape 닫기, focus trap (Tab 순환)
- Button: Enter/Space로 활성화
- Select: Arrow Up/Down 이동, Enter 선택, Escape 닫기
- Tabs: Arrow Left/Right 탭 이동
- SearchInput: Escape로 입력 초기화
- `focus-visible` 스타일 적용 (마우스 클릭 시 ring 미표시)

### WCAG AA 색상 대비
- 본문 텍스트: 최소 4.5:1 대비비
- 큰 텍스트 (18px+): 최소 3:1 대비비
- UI 컴포넌트: 최소 3:1 대비비

---

## 7. 구현 순서

에이전트는 아래 순서로 TDD 구현합니다 (의존성 순, 총 21개):

1. **Spinner** — 의존성 없음, Button의 loading에 필요
2. **Badge** — 의존성 없음
3. **Button** — Spinner 의존
4. **Input** — 의존성 없음
5. **Select** — 의존성 없음
6. **Textarea** — Input과 동일 focus 애니메이션 공유
7. **Checkbox** — 의존성 없음
8. **Card** — 의존성 없음
9. **Table** — 의존성 없음
10. **Form + FormField** — 의존성 없음
11. **Tabs** — 의존성 없음
12. **SearchInput** — 의존성 없음
13. **FileUpload** — 의존성 없음
14. **Modal** — Button 의존 (actions)
15. **Toast (Zustand Store + Container)** — 의존성 없음
16. **ConfirmDialog** — Button 의존, Toast 의존
17. **ContentContainer** — 의존성 없음
18. **Header** — 의존성 없음
19. **Sidebar** — cn 유틸리티 사용
20. **Footer** — 의존성 없음
21. **AppLayout** — Header, ContentContainer, Sidebar, Footer 조합

---

## 8. Figma 연동

### 8.1 MCP 방식 (권장)

`.mcp.json`에 Figma MCP 서버가 설정되어 있고, `design-config.json`에 `figmaUrl`이 있으면:

1. Figma MCP 도구로 해당 파일의 스타일/컴포넌트를 **실시간 조회**
2. 색상, 타이포그래피, 간격 등을 Figma에서 직접 추출하여 `globals.css`에 반영
3. 각 컴포넌트 구현 시 Figma MCP로 해당 컴포넌트의 세부 디자인 사양 조회
4. 컴포넌트 구조와 Props 인터페이스는 변경하지 않음 — 시각적 스타일만 Figma 기준으로 적용

### Figma MCP 컴포넌트별 추출 규칙

에이전트는 각 컴포넌트/페이지 구현 시 Figma MCP로 해당 노드를 조회하고,
다음 요소를 추출하여 Tailwind 클래스에 반영합니다:

1. **색상**: fill 값 → CSS custom properties 또는 직접 Tailwind 클래스
2. **타이포그래피**: font-family, font-size, font-weight, line-height → Tailwind text-*
3. **간격**: auto-layout padding, gap → Tailwind p-*, gap-*
4. **크기**: width, height → Tailwind w-*, h-*
5. **테두리**: stroke, borderRadius → Tailwind border-*, rounded-*
6. **그림자**: effects → Tailwind shadow-*
7. **아이콘/이미지**: SVG 노드 → download_figma_images로 자산 다운로드

각 페이지 구현 시 해당 페이지의 Figma nodeId를 조회하고,
Figma 디자인과 동일한 시각적 결과물을 코드로 생성합니다.

design-config.json에 figmaUrl이 있으면 Figma가 디자인의 진실의 원천이며,
design-system.md의 참조 구현은 구조적 뼈대로만 사용합니다.

**기본 Figma URL** (MH OCR AI):
```json
{
  "figmaUrl": "https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq",
  "figmaFileKey": "mxCTZeei87Q5piZ75HINFq"
}
```

**MCP 활용 예시:**
- 컴포넌트 색상: Figma MCP로 해당 프레임의 fill 값 조회
- 타이포그래피: Figma MCP로 텍스트 노드의 font-family, size, weight 조회
- 간격: Figma MCP로 auto-layout의 padding, gap 값 조회

### 8.2 REST 폴백 방식

MCP가 설정되지 않고 `design-config.json`에 `figmaTokens` 필드가 존재하면 (Phase 0.5에서 REST API로 추출):

1. `globals.css`의 CSS custom properties를 추출된 값으로 대체
2. 타이포그래피 (font-family, font-size, line-height) 대체
3. 간격 (spacing, padding) 대체
4. 컴포넌트 구조와 Props 인터페이스는 변경하지 않음 — 시각적 스타일만 오버라이드

### design-config.json 구조

```json
{
  "palette": "default-blue",
  "figmaUrl": "https://www.figma.com/design/mxCTZeei87Q5piZ75HINFq",
  "figmaFileKey": "mxCTZeei87Q5piZ75HINFq",
  "layout": {
    "header": true,
    "sidebar": false,
    "footer": false
  },
  "components": [
    "Button", "Input", "Select", "Textarea", "Checkbox",
    "Card", "Table", "Form", "Tabs", "SearchInput", "FileUpload",
    "Modal", "Toast", "Badge", "Spinner", "ConfirmDialog"
  ]
}
```

`figmaTokens` 예시 (REST 폴백으로 추출된 경우):
```json
{
  "figmaTokens": {
    "colors": {
      "primary-500": "#137FEC",
      "background": "#FFFFFF"
    },
    "typography": {
      "fontFamily": "'Noto Sans KR', sans-serif",
      "fontSize": { "sm": "0.875rem", "base": "1rem", "lg": "1.125rem" }
    },
    "spacing": {
      "sm": "0.5rem",
      "md": "1rem",
      "lg": "1.5rem"
    }
  }
}
```

---

## 9. 완료 기준

- 전 페이지 Content 폭 1280px 고정 준수 (ContentContainer 사용)
- Figma 대비 오차: spacing ±2px 허용
- 지원 브라우저: Chrome / Edge (최신)
- 접근성: 탭 이동, 포커스 표시, 아이콘 버튼 aria-label
- 공통 인터랙션 규칙(Input/Button/Toast/Confirm)이 전 화면에서 동일 동작
- 모든 UI 컴포넌트(21개)의 테스트 통과
- design-config.json에 figmaUrl이 있으면 Figma MCP 기반 시각적 일치 검증
