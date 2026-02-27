# 디자인 시스템 컴포넌트 현황표

> 최종 업데이트: 2026-02-23
> 참조 파일: `.claude/skills/tdd-frontend/templates/design-system.md`, `component-tests.md`

## 요약

| 구분 | 개수 |
|------|------|
| 완성 (디자인 명세 + 테스트 패턴) | 21개 |
| 미구현 (추가 필요) | 15개 |
| **합계** | **36개** |

---

## 1. 완성된 컴포넌트 (21개)

디자인 시스템 명세(`design-system.md`)에 Props, 참조 구현, Tailwind 클래스까지 정의 완료.
테스트 패턴(`component-tests.md`)에 Vitest 테스트 코드 정의 완료.

| # | 컴포넌트 | 카테고리 | 특이사항 |
|---|----------|----------|----------|
| 1 | **Spinner** | 기본 UI | `role="status"`, 3가지 사이즈 |
| 2 | **Badge** | 기본 UI | 5가지 variant (default/success/warning/error/info) |
| 3 | **Button** | 기본 UI | press 애니메이션 `active:scale-[0.97]`, 5가지 variant, loading "처리 중..." |
| 4 | **Input** | 기본 UI | focus pulse 애니메이션, variant(default/error), 5가지 상태 |
| 5 | **Select** | 폼 | 키보드 내비게이션 (Arrow/Enter/Escape), `role="listbox"` |
| 6 | **Textarea** | 폼 | Input 동일 focus 애니메이션/error, rows/auto-resize, `aria-invalid` |
| 7 | **Checkbox** | 폼 | 체크 애니메이션, label 연결, `aria-checked`, `role="checkbox"` |
| 8 | **Card** | 기본 UI | header/footer 슬롯 |
| 9 | **Table** | 기본 UI | 제네릭 `<T>`, 커스텀 렌더러, 정렬, 빈 데이터 메시지 |
| 10 | **Form + FormField** | 기본 UI | 네이티브 `<form>` 래퍼 |
| 11 | **Tabs** | 내비게이션 | `role="tablist"/"tab"/"tabpanel"`, Arrow키 전환 |
| 12 | **SearchInput** | 폼 | 아이콘 + clear + debounce, `role="searchbox"`, Escape로 clear |
| 13 | **FileUpload** | 폼 | drag & drop, 파일 선택, 크기 제한, drop zone `aria-label` |
| 14 | **Modal** | 피드백 | Escape 닫기, focus trap, `aria-modal` |
| 15 | **Toast** | 피드백 | Zustand store, 4가지 tone, 자동 소멸(3s/5s), 메시지 규칙표 |
| 16 | **ConfirmDialog** | 피드백 | destructive 모드, 오버레이 닫기, press 애니메이션 |
| 17 | **ContentContainer** | 레이아웃 | w-[1280px] mx-auto py-6, 모든 페이지 필수 |
| 18 | **Header** | 레이아웃 | h-16 (64px), sticky, bg-white/80 backdrop-blur, 좌/우 구조 |
| 19 | **Sidebar** | 레이아웃 | w-[260px], 메뉴 그룹/선택 상태, 스크롤 가능 |
| 20 | **Footer** | 레이아웃 | children 슬롯 (옵션, 기본 미사용) |
| 21 | **AppLayout** | 레이아웃 | min-w-[1440px], Header + ContentContainer + Sidebar + Footer 조합 |

---

## 2. 미구현 컴포넌트 (15개)

### 2.1 필수급 — 대부분의 웹서비스에 필요 (4개)

| # | 컴포넌트 | 카테고리 | 설명 | 우선순위 |
|---|----------|----------|------|----------|
| 22 | **Radio / RadioGroup** | 폼 | 단일 선택, `role="radiogroup"` | P0 |
| 23 | **Toggle / Switch** | 폼 | on/off 설정, `role="switch"`, `aria-checked` | P0 |
| 24 | **Pagination** | 내비게이션 | 페이지 이동, Table과 쌍으로 사용, `aria-current="page"` | P0 |
| 25 | **Tooltip** | 오버레이 | hover/focus 트리거 부가 설명, 위치 자동 조정 | P0 |

### 2.2 권장 — 대부분의 서비스에서 사용 (5개)

| # | 컴포넌트 | 카테고리 | 설명 | 우선순위 |
|---|----------|----------|------|----------|
| 26 | **Avatar** | 표시 | 사용자 프로필 이미지, 이니셜 폴백, 3가지 사이즈 | P1 |
| 27 | **Breadcrumb** | 내비게이션 | 현재 위치 경로 표시, `aria-label="Breadcrumb"` | P1 |
| 28 | **Alert** | 피드백 | 인라인 알림 (Toast와 다름), 페이지 내 고정 메시지, 4가지 tone | P1 |
| 29 | **Skeleton** | 로딩 | 로딩 플레이스홀더, Spinner 대안, 레이아웃 시프트 방지 | P1 |
| 30 | **EmptyState** | 표시 | 데이터 없음 화면, 아이콘 + 메시지 + CTA 버튼 | P1 |

### 2.3 선택 — 프로젝트 성격에 따라 (6개)

| # | 컴포넌트 | 카테고리 | 설명 | 우선순위 |
|---|----------|----------|------|----------|
| 31 | **Progress** | 피드백 | 진행률 표시 바, 업로드/처리 진행, `role="progressbar"` | P2 |
| 32 | **Accordion** | 표시 | 접기/펼치기 패널, FAQ/설정, `aria-expanded` | P2 |
| 33 | **Popover** | 오버레이 | 클릭 트리거 말풍선, Tooltip의 클릭 버전 | P2 |
| 34 | **DatePicker** | 폼 | 날짜 선택, 서드파티 래핑 또는 직접 구현 | P2 |
| 35 | **Tag / Chip** | 표시 | 태그 표시 + 삭제 버튼, Badge의 인터랙티브 버전 | P2 |
| 36 | **Divider / ErrorBoundary** | 기타 | 구분선 + 에러 폴백 UI | P2 |

---

## 3. 전 화면 사이즈 통일 규격 (적용 완료)

| 규격 | 값 | 상태 |
|------|-----|------|
| 기준 해상도 | min-w-[1440px] | ✅ 완료 |
| Content 폭 | w-[1280px] mx-auto (ContentContainer) | ✅ 완료 |
| Header 높이 | h-16 (64px), sticky | ✅ 완료 |
| Sidebar 폭 | w-[260px] | ✅ 완료 |
| 카드/섹션 라운드 | rounded-xl 통일 | ✅ 완료 |
| 그림자 | shadow-sm 통일 | ✅ 완료 |
| 간격 스케일 | 4/8/12/16/24/32/40/48 (px) | ✅ 완료 |

---

## 4. 공통 UX 인터랙션 규칙 (적용 완료)

아래 규칙은 `design-system.md`에 반영 완료. 모든 화면에서 동일하게 적용됨.

| 규칙 | 적용 대상 | 상태 |
|------|----------|------|
| Input focus pulse 애니메이션 | Input, Textarea, SearchInput | ✅ 완료 |
| Button press 애니메이션 `active:scale-[0.97]` | 모든 Button variant | ✅ 완료 |
| Toast 자동 메시지 규칙 | 전 화면 공통 | ✅ 완료 |
| ConfirmDialog destructive 확인 | 파일 삭제(필수), OCR/업로드(옵션) | ✅ 완료 |

---

## 5. Figma MCP 컴포넌트별 추출 규칙 (적용 완료)

| 항목 | 설명 | 상태 |
|------|------|------|
| 기본 Figma URL | `mxCTZeei87Q5piZ75HINFq` (MH OCR AI) | ✅ 완료 |
| 색상 추출 | fill → CSS custom properties / Tailwind | ✅ 완료 |
| 타이포그래피 | font-family, size, weight, line-height | ✅ 완료 |
| 간격/크기 | auto-layout padding, gap, width, height | ✅ 완료 |
| 테두리/그림자 | stroke, borderRadius, effects | ✅ 완료 |
| 아이콘/이미지 | SVG → download_figma_images | ✅ 완료 |
| 진실의 원천 | Figma > design-system.md 참조 구현 | ✅ 완료 |

---

## 6. 설정 파일 현황

| 파일 | 경로 | 상태 |
|------|------|------|
| 디자인 시스템 명세 | `.claude/skills/tdd-frontend/templates/design-system.md` | ✅ 최신 (21개 컴포넌트) |
| 컬러 팔레트 정의 | `.claude/skills/tdd-frontend/templates/color-palettes.md` | ✅ default-blue 실제 값 (#137FEC) |
| 컴포넌트 테스트 패턴 | `.claude/skills/tdd-frontend/templates/component-tests.md` | ✅ 최신 (21개 테스트) |
| 프론트엔드 에이전트 | `.claude/agents/frontend-developer.md` | ✅ Figma MCP + 기본 규격 추가 |
| 코드 스타일 규칙 | `.claude/rules/code-style.md` | ✅ Tailwind/자산 규칙 추가 |
| TDD Frontend 스킬 | `.claude/skills/tdd-frontend/SKILL.md` | ✅ 기본값 참조 추가 |
| Pipeline 스킬 | `.claude/skills/pipeline/SKILL.md` | ✅ 기본 Figma URL + components |
| tailwind.config.ts | design-system.md 내 정의 | ✅ minWidth/width/height 확장 |
| globals.css | design-system.md 내 정의 | ✅ --brand-rgb, @keyframes |
| 의존성 | design-system.md 내 정의 | ✅ zustand 포함 |

---

## 7. 추가 구현 시 참고사항

### 공통 적용 규칙
- 새 폼 컴포넌트에도 **Input과 동일한 focus 애니메이션** 적용
- 모든 인터랙티브 요소에 **focus-visible:ring-2** 접근성 스타일 적용
- 새 버튼형 요소(Pagination, Tag 삭제 등)에도 **press 애니메이션** 적용
- 에러/삭제 관련 액션은 **ConfirmDialog + Toast** 조합 사용
- 페이지별 임의 width/padding 금지 → **ContentContainer에서만 관리**

### 의존성 추가 필요 (선택 컴포넌트)
- DatePicker → `date-fns` 또는 `dayjs`
- Tooltip/Popover → `@floating-ui/react` (위치 자동 조정)

### 테스트 규칙
- 모든 새 컴포넌트는 `component-tests.md`에 테스트 패턴 추가 필수
- Given-When-Then 구조, 접근성 쿼리 우선 (`getByRole`, `getByLabelText`)
