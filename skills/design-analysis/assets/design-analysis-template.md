# 디자인 분석 - {Project Name}

**생성일**: {date}
**디자인 소스**: {Figma URL / Screenshot / Description}
**상태**: 초안

---

## 1. 개요

디자인의 목적, 대상 사용자, 주요 사용자 경험 목표에 대한 간략한 요약.

**예시:**
개인 전문가 및 소규모 팀을 위한 현대적인 작업 관리 대시보드입니다. 인터페이스는 단순성과 시각적 명확성을 우선시하며, 모바일 우선 반응형과 접근성에 중점을 둡니다. 디자인은 사용자 참여를 향상시키기 위해 미묘한 애니메이션과 함께 깔끔하고 미니멀한 미학을 사용합니다.

---

## 2. 디자인 토큰

디자인 토큰은 애플리케이션 전반에 걸쳐 시각적 일관성을 만드는 원자적 디자인 결정입니다.

### 2.1 컬러 팔레트

#### 주요 색상
| Token Name | Hex | 사용처 |
|------------|-----|-------|
| `primary-50` | `#eff6ff` | Light backgrounds, hover states |
| `primary-100` | `#dbeafe` | Secondary backgrounds |
| `primary-500` | `#3b82f6` | Primary actions, links |
| `primary-600` | `#2563eb` | Hover states for primary actions |
| `primary-700` | `#1d4ed8` | Active states |

#### 중립 색상
| Token Name | Hex | 사용처 |
|------------|-----|-------|
| `neutral-50` | `#fafafa` | Page backgrounds |
| `neutral-100` | `#f5f5f5` | Card backgrounds |
| `neutral-200` | `#e5e5e5` | Borders, dividers |
| `neutral-500` | `#737373` | Secondary text |
| `neutral-900` | `#171717` | Primary text |

#### 의미론적 색상
| Token Name | Hex | 사용처 |
|------------|-----|-------|
| `success` | `#22c55e` | Success messages, completed states |
| `warning` | `#f59e0b` | Warnings, caution states |
| `error` | `#ef4444` | Error messages, destructive actions |
| `info` | `#3b82f6` | Informational messages |

#### 배경 및 서피스
| Token Name | Hex | 사용처 |
|------------|-----|-------|
| `bg-primary` | `#ffffff` | Main page background |
| `bg-secondary` | `#fafafa` | Secondary surfaces |
| `surface` | `#ffffff` | Cards, modals, dropdowns |
| `surface-elevated` | `#ffffff` | Elevated components (higher z-index) |

### 2.2 타이포그래피

#### 폰트 패밀리
| Token Name | Value | 사용처 |
|------------|-------|-------|
| `font-sans` | `'Inter', -apple-system, system-ui, sans-serif` | Body text, UI elements |
| `font-mono` | `'Fira Code', 'Courier New', monospace` | Code blocks, technical content |

#### 폰트 크기
| Token Name | Size (rem) | Pixels (16px base) | 사용처 |
|------------|------------|-------------------|-------|
| `text-xs` | `0.75rem` | `12px` | Small labels, captions |
| `text-sm` | `0.875rem` | `14px` | Secondary text, helper text |
| `text-base` | `1rem` | `16px` | Body text, default size |
| `text-lg` | `1.125rem` | `18px` | Emphasized text |
| `text-xl` | `1.25rem` | `20px` | Headings (H4) |
| `text-2xl` | `1.5rem` | `24px` | Headings (H3) |
| `text-3xl` | `1.875rem` | `30px` | Headings (H2) |
| `text-4xl` | `2.25rem` | `36px` | Page titles (H1) |

#### 폰트 굵기
| Token Name | Value | 사용처 |
|------------|-------|-------|
| `font-normal` | `400` | Body text |
| `font-medium` | `500` | Emphasized text, labels |
| `font-semibold` | `600` | Subheadings, buttons |
| `font-bold` | `700` | Headings |

#### 줄 높이
| Token Name | Value | 사용처 |
|------------|-------|-------|
| `leading-tight` | `1.25` | Headings |
| `leading-normal` | `1.5` | Body text |
| `leading-relaxed` | `1.75` | Long-form content |

### 2.3 간격

8px 그리드 시스템 기반.

| Token Name | Size (rem) | Pixels | 사용처 |
|------------|------------|--------|-------|
| `space-1` | `0.25rem` | `4px` | Micro spacing |
| `space-2` | `0.5rem` | `8px` | Tight spacing between elements |
| `space-3` | `0.75rem` | `12px` | Small gaps |
| `space-4` | `1rem` | `16px` | Standard spacing |
| `space-6` | `1.5rem` | `24px` | Medium gaps |
| `space-8` | `2rem` | `32px` | Large gaps |
| `space-12` | `3rem` | `48px` | Section spacing |
| `space-16` | `4rem` | `64px` | Major section separation |

### 2.4 테두리 반경

| Token Name | Value | 사용처 |
|------------|-------|-------|
| `rounded-sm` | `0.125rem` (`2px`) | Small elements, badges |
| `rounded` | `0.25rem` (`4px`) | Buttons, inputs |
| `rounded-md` | `0.375rem` (`6px`) | Cards, panels |
| `rounded-lg` | `0.5rem` (`8px`) | Large cards, modals |
| `rounded-full` | `9999px` | Circular avatars, pills |

### 2.5 그림자

| Token Name | Value | 사용처 |
|------------|-------|-------|
| `shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Subtle elevation |
| `shadow` | `0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)` | Standard elevation |
| `shadow-md` | `0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.06)` | Cards, dropdowns |
| `shadow-lg` | `0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)` | Modals, popovers |
| `shadow-xl` | `0 20px 25px rgba(0,0,0,0.1), 0 10px 10px rgba(0,0,0,0.04)` | Major elevated elements |

### 2.6 중단점 (반응형 디자인)

| Breakpoint | Min Width | 사용처 |
|------------|-----------|-------|
| `mobile` | `0px` | Default, mobile-first |
| `sm` | `640px` | Small tablets |
| `md` | `768px` | Tablets |
| `lg` | `1024px` | Desktop |
| `xl` | `1280px` | Large desktop |
| `2xl` | `1536px` | Extra large screens |

---

## 3. 컴포넌트 목록

디자인에서 식별된 모든 UI 컴포넌트의 전체 목록.

### 3.1 핵심 컴포넌트

#### 버튼
- **Primary Button**: 단색 배경, 주요 색상, 주요 작업에 사용
- **Secondary Button**: 윤곽선 스타일, 보조 작업에 사용
- **Ghost Button**: 테두리 없음, 투명 배경, 미묘한 호버
- **Destructive Button**: 삭제/제거 작업을 위한 빨간색 색상 구성
- **Icon Button**: 정사각형 또는 원형, 아이콘만, 툴바에 사용

**변형**:
- 크기: `sm` (32px 높이), `md` (40px 높이), `lg` (48px 높이)
- 상태: Default, Hover, Active, Disabled, Loading

#### 폼 입력
- **Text Input**: 한 줄 텍스트 입력
- **Textarea**: 여러 줄 텍스트 입력
- **Select Dropdown**: 목록에서 단일 선택
- **Checkbox**: 다중 선택
- **Radio Button**: 그룹에서 단일 선택
- **Toggle Switch**: Boolean on/off 상태
- **Date Picker**: 캘린더 선택 인터페이스
- **Search Input**: 검색 아이콘이 있는 텍스트 입력

**상태**: Default, Focus, Error, Disabled, Success

#### 카드
- **Content Card**: 선택적 헤더/푸터가 있는 범용 컨테이너
- **Interactive Card**: 높이 변경이 있는 클릭/호버 가능한 카드
- **Image Card**: 이미지 썸네일이 있는 카드
- **Stats Card**: 아이콘과 값으로 주요 지표 표시

**기능**: Shadow, border, padding, hover effects

#### 네비게이션
- **Top Navigation Bar**: 로고, 메뉴 항목, 사용자 프로필이 있는 고정 헤더
- **Side Navigation**: 계층적 메뉴가 있는 접을 수 있는 사이드바
- **Breadcrumbs**: 페이지 계층 구조를 보여주는 탐색 경로
- **Tabs**: 수평 또는 수직 탭 탐색
- **Pagination**: 목록을 위한 페이지 번호 탐색

#### 모달 및 오버레이
- **Modal Dialog**: 집중된 상호작용을 위한 중앙 오버레이
- **Confirmation Dialog**: 간단한 yes/no 결정 모달
- **Drawer**: 측면(좌/우)에서 슬라이드인 패널
- **Tooltip**: 추가 컨텍스트가 있는 작은 호버 팝업
- **Popover**: 클릭으로 트리거되는 플로팅 패널

#### 피드백 컴포넌트
- **Toast Notification**: 화면 가장자리에 나타나는 임시 메시지
- **Alert Banner**: 콘텐츠 영역 상단의 영구 메시지
- **Progress Bar**: 선형 진행률 표시기
- **Spinner**: 로딩 표시기 (원형 애니메이션)
- **Skeleton Loader**: 로딩 중 플레이스홀더 콘텐츠

#### 데이터 표시
- **Table**: 정렬/필터링이 있는 구조화된 데이터 표시
- **List**: 선택적 작업이 있는 수직 항목 목록
- **Avatar**: 사용자 프로필 이미지 (원형 또는 사각형)
- **Badge**: 상태/카운트 표시기를 위한 작은 레이블
- **Tag**: 분류를 위한 제거 가능한 레이블
- **Divider**: 수평 또는 수직 구분선

### 3.2 레이아웃 컴포넌트

- **Container**: 콘텐츠 중앙 정렬을 위한 최대 너비 래퍼
- **Grid**: 반응형 열 기반 레이아웃
- **Stack**: 자식 요소 간 수직 간격
- **Flexbox Layout**: 유연한 행/열 배열
- **Sidebar Layout**: 고정 사이드바가 있는 2열 레이아웃

### 3.3 복합 컴포넌트

- **Data Table with Filters**: Table + search + column filters + pagination
- **Form Wizard**: 진행률 표시기가 있는 다단계 폼
- **Dashboard Widget**: 차트/통계가 있는 구성 가능한 카드
- **File Upload**: 파일 목록이 있는 드래그 앤 드롭 영역
- **Rich Text Editor**: 툴바가 있는 서식 있는 텍스트 입력

---

## 4. 화면 분석

디자인의 각 주요 화면/페이지에 대한 상세 분석.

### 4.1 대시보드 (홈 화면)

**목적**: 주요 지표 및 최근 활동 개요

**레이아웃 구조**:
```
┌─────────────────────────────────────────┐
│ Top Navigation Bar                      │
├─────┬───────────────────────────────────┤
│     │ Page Header (Title + Actions)     │
│ S   ├───────────────────────────────────┤
│ i   │ Stats Cards Row (3-4 cards)      │
│ d   ├───────────────────────────────────┤
│ e   │ Main Content Area                 │
│ b   │ ┌──────────┬──────────┐          │
│ a   │ │ Chart/   │ Recent   │          │
│ r   │ │ Graph    │ Activity │          │
│     │ └──────────┴──────────┘          │
└─────┴───────────────────────────────────┘
```

**사용된 컴포넌트**:
- Top Navigation Bar
- Side Navigation
- Stats Cards (4x)
- Chart Widget
- Activity List Card
- Primary Buttons (2x)

**주요 상호작용**:
- 통계 카드 클릭 → 상세 보기로 이동
- 차트 호버 → 데이터 툴팁 표시
- 활동 항목 클릭 → 상세 모달 열기
- "새로 추가" 클릭 → 생성 폼 열기

**반응형 동작**:
- 모바일: 모든 카드를 세로로 쌓기, 사이드바 숨김
- 태블릿: 통계 카드 2열 그리드, 사이드바를 아이콘으로 축소
- 데스크톱: 확장된 사이드바가 있는 전체 레이아웃

**접근성 참고사항**:
- 모든 통계 카드는 키보드로 탐색 가능
- 차트에는 텍스트 대체 설명이 있음
- 모바일에서 사이드바 메뉴가 열릴 때 포커스 트랩

---

### 4.2 목록/테이블 뷰

**목적**: 항목 컬렉션 표시 및 관리

**레이아웃 구조**:
```
┌─────────────────────────────────────────┐
│ Top Navigation Bar                      │
├─────┬───────────────────────────────────┤
│     │ Page Header + Search + Filters    │
│ S   ├───────────────────────────────────┤
│ i   │ Data Table                         │
│ d   │ ┌────┬────┬────┬────┬────────┐  │
│ e   │ │ □  │Col1│Col2│Col3│ Actions│  │
│ b   │ ├────┼────┼────┼────┼────────┤  │
│ a   │ │ □  │Data│Data│Data│  •••   │  │
│ r   │ └────┴────┴────┴────┴────────┘  │
│     │ Pagination Controls               │
└─────┴───────────────────────────────────┘
```

**사용된 컴포넌트**:
- Search Input
- Filter Dropdown (2-3x)
- Data Table with checkboxes
- Pagination
- Action Menu (kebab icon)
- Bulk Action Toolbar (선택 시 나타남)

**주요 상호작용**:
- 열 헤더 클릭 → 해당 열로 정렬
- 행 클릭 → 상세 페이지로 이동
- 체크박스 클릭 → 대량 작업을 위한 항목 선택
- 작업 메뉴 클릭 → 편집/삭제/추가 옵션 표시
- 검색창 입력 → 실시간 결과 필터링

**반응형 동작**:
- 모바일: 카드 기반 목록 뷰 (테이블 아님), 하단 시트의 필터
- 태블릿: 더 적은 열이 표시되는 압축된 테이블
- 데스크톱: 모든 열이 있는 전체 테이블

---

### 4.3 상세/프로필 뷰

**목적**: 단일 항목 세부 정보 보기 및 편집

**레이아웃 구조**:
```
┌─────────────────────────────────────────┐
│ Top Navigation Bar                      │
├─────┬───────────────────────────────────┤
│     │ Back Button + Page Title          │
│ S   ├───────────────────────────────────┤
│ i   │ ┌─────────────────────────────┐  │
│ d   │ │ Header Card (Avatar/Image)  │  │
│ e   │ │ Name, Status, Metadata      │  │
│ b   │ └─────────────────────────────┘  │
│ a   │ Tabs: Overview | Details | More  │
│ r   │ ┌─────────────────────────────┐  │
│     │ │ Tab Content                 │  │
│     │ │ (Forms, Lists, Data)        │  │
│     │ └─────────────────────────────┘  │
└─────┴───────────────────────────────────┘
```

**사용된 컴포넌트**:
- Back Button
- Header Card with Image
- Status Badge
- Tabs Navigation
- Form Fields (다양한 유형)
- Save/Cancel Buttons

**주요 상호작용**:
- 뒤로 가기 클릭 → 목록 뷰로 돌아가기
- 탭 전환 → 다른 콘텐츠 섹션 로드
- 필드 편집 → 인라인 편집 모드 활성화
- 저장 클릭 → 검증 및 변경사항 제출
- 취소 클릭 → 변경사항 취소 및 편집 모드 종료

---

### 4.4 폼/생성 화면

**목적**: 새 항목 생성 또는 설정 구성

**레이아웃 구조**:
```
┌─────────────────────────────────────────┐
│ Top Navigation Bar                      │
├─────┬───────────────────────────────────┤
│     │ Form Title + Close/Back Button    │
│ S   ├───────────────────────────────────┤
│ i   │ ┌─────────────────────────────┐  │
│ d   │ │ Form Section 1              │  │
│ e   │ │ [Input Fields]              │  │
│ b   │ └─────────────────────────────┘  │
│ a   │ ┌─────────────────────────────┐  │
│ r   │ │ Form Section 2              │  │
│     │ │ [More Fields]               │  │
│     │ └─────────────────────────────┘  │
│     │ [Cancel Button] [Save Button]    │
└─────┴───────────────────────────────────┘
```

**사용된 컴포넌트**:
- Text Inputs
- Textareas
- Select Dropdowns
- Checkboxes / Radio Buttons
- File Upload Component
- Primary Button (Save)
- Secondary Button (Cancel)
- Form Validation Messages

**주요 상호작용**:
- 필드 입력 → blur 또는 제출 시 검증
- 저장 클릭 → 로딩 상태 표시, 그 다음 성공/오류 메시지
- 취소 클릭 → 저장되지 않은 변경사항이 있으면 확인 표시
- 파일 업로드 → 미리보기 및 진행률 표시

**검증**:
- blur 시 실시간 검증
- 빨간 테두리 + 필드 아래 오류 메시지
- 유효할 때까지 제출 버튼 비활성화
- 성공적인 제출 시 성공 메시지 표시

---

## 5. 상호작용 패턴

일반적인 상호작용 동작 및 마이크로 인터랙션.

### 5.1 호버 상태
- **버튼**: 배경색이 어두워지고, 미묘한 스케일 (1.02x)
- **카드**: 높이가 증가 (그림자 강화)
- **링크**: 밑줄 표시, 색상이 어두워짐
- **테이블 행**: 밝은 배경 하이라이트
- **아이콘**: 색상 변경, 약간의 회전 (예: 화살표)

### 5.2 포커스 상태
- **모든 상호작용 요소**: 2px 파란색 윤곽선 (`ring-2 ring-primary-500`)
- **메인 콘텐츠로 건너뛰기**: 키보드 탐색 시 포커스
- **폼 입력**: 테두리 색상 변경 + 빛나는 그림자

### 5.3 로딩 상태
- **버튼**: 스피너 아이콘 표시, 상호작용 비활성화, 텍스트가 "Loading..."으로 변경
- **페이지 로드**: 스켈레톤 로더가 콘텐츠 대체
- **무한 스크롤**: 목록 하단에 스피너
- **폼 제출**: 버튼에 스피너 표시, 폼 비활성화

### 5.4 빈 상태
- **결과 없음**: 아이콘 + 메시지 + 작업 버튼 ("첫 항목 생성")
- **검색 결과 없음**: 메시지 + 필터 수정 제안
- **삭제된 항목**: 토스트 알림 + 실행 취소 옵션 (5초)

### 5.5 오류 상태
- **폼 검증**: 빨간 테두리 + 아이콘 + 필드 아래 오류 메시지
- **요청 실패**: 재시도 버튼이 있는 토스트 알림
- **404 페이지**: 친절한 메시지 + 탐색 옵션
- **네트워크 오류**: 재시도 작업이 있는 상단 배너

### 5.6 애니메이션
- **페이지 전환**: Fade in (300ms)
- **모달 열기**: 0.95에서 1.0으로 스케일 + fade in (200ms)
- **토스트 알림**: 오른쪽에서 슬라이드 인 (250ms)
- **드롭다운 메뉴**: Fade + 약간의 스케일 (150ms)
- **로딩 스피너**: 연속 회전 (1s 지속 시간)
- **성공 체크마크**: 그리기 애니메이션 (500ms)

### 5.7 제스처 (모바일/터치)
- **목록 항목 오른쪽 스와이프**: 삭제 작업 표시
- **당겨서 새로고침**: 목록 뷰 콘텐츠 새로고침
- **핀치 투 줌**: 상세 뷰의 이미지
- **길게 누르기**: 컨텍스트 메뉴 표시

---

## 6. 접근성 고려사항

### 색상 대비
- 모든 텍스트가 WCAG AA 표준을 충족 (일반 텍스트 4.5:1, 큰 텍스트 3:1)
- 중요한 정보는 색상만으로 전달하지 않음
- 포커스 표시기는 충분한 대비를 가짐

### 키보드 탐색
- 모든 상호작용 요소는 Tab 키로 접근 가능
- 논리적인 탭 순서가 시각적 레이아웃을 따름
- Escape 키로 모달/메뉴 닫기
- Enter 키로 버튼/링크 활성화
- 화살표 키로 컴포넌트 내부 탐색 (예: 날짜 선택기)

### 스크린 리더 지원
- 의미론적 HTML 요소 (`<nav>`, `<main>`, `<button>`)
- 아이콘 전용 버튼에 대한 ARIA 레이블
- 동적 콘텐츠에 대한 ARIA live regions (토스트, 로딩 상태)
- 폼 레이블이 입력과 적절하게 연결됨
- 모든 이미지에 대한 대체 텍스트

### 모션 및 애니메이션
- `prefers-reduced-motion` 미디어 쿼리 존중
- 설정에서 애니메이션 비활성화 옵션 제공
- 깜박이는 콘텐츠 없음 (간질 위험)

---

## 7. 디자인 시스템 권장사항

이 분석을 기반으로 구현을 위해 다음을 권장합니다:

1. **Tailwind CSS 사용** 또는 정의된 디자인 토큰으로 빠른 개발을 위한 유사한 유틸리티 우선 프레임워크
2. **컴포넌트 라이브러리**: 접근 가능한 프리미티브를 위해 shadcn/ui 또는 Radix UI로 구축
3. **아이콘 라이브러리**: Lucide React 또는 Heroicons 사용 (디자인 스타일과 일관성 유지)
4. **애니메이션 라이브러리**: React의 경우 Framer Motion, 또는 간단한 애니메이션의 경우 CSS transitions
5. **폼 검증**: 타입 안전 검증을 위한 React Hook Form + Zod
6. **상태 관리**: 전역 상태를 위한 Zustand 또는 React Context
7. **다크 모드 지원**: 디자인 토큰은 라이트/다크 테마 변형을 지원해야 함

---

## 8. 구현 참고사항

### 우선 구현해야 할 중요한 디자인 토큰
1. 컬러 팔레트 (primary, neutral, semantic)
2. 타이포그래피 스케일
3. 간격 시스템 (8px 그리드)
4. 테두리 반경 값
5. 그림자 스케일

### 컴포넌트 구축 우선순위
1. **Phase 1**: Button, Input, Card, Typography 컴포넌트
2. **Phase 2**: Navigation, Modal, Form 컴포넌트
3. **Phase 3**: Table, 복합 상호작용

### 디자인-코드 워크플로우
1. Figma에서 디자인 토큰 추출 (사용 가능한 경우 Figma Tokens 플러그인 사용)
2. 커스텀 토큰으로 Tailwind CSS 구성
3. Storybook에서 컴포넌트 라이브러리 구축
4. 컴포넌트를 사용하여 페이지 구현
5. 반응형 동작 추가
6. 애니메이션 구현
7. 접근성 감사 및 수정

---

**식별된 총 컴포넌트 수**: 30+
**분석된 총 화면 수**: 4-6
**예상 구현 시간**: 2-4주 (복잡도에 따라)
