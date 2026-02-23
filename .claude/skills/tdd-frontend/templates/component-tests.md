# UI 컴포넌트 테스트 패턴

> 이 문서는 디자인 시스템 UI 컴포넌트의 테스트 패턴을 정의합니다.
> 프론트엔드 에이전트는 TDD로 각 컴포넌트를 구현할 때 이 패턴을 참조합니다.

## 공통 설정

```typescript
// tests/setup.ts 에 추가
import "@testing-library/jest-dom";
```

```typescript
// 모든 테스트 파일 공통 import
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi } from "vitest";
```

---

## Button.test.tsx

```typescript
describe("Button", () => {
  // 렌더링
  it("기본 버튼을 렌더링한다", () => {
    render(<Button>클릭</Button>);
    expect(screen.getByRole("button", { name: "클릭" })).toBeInTheDocument();
  });

  it("각 variant를 올바르게 렌더링한다", () => {
    const variants = ["primary", "secondary", "outline", "ghost", "destructive"] as const;
    variants.forEach((variant) => {
      const { unmount } = render(<Button variant={variant}>버튼</Button>);
      expect(screen.getByRole("button")).toBeInTheDocument();
      unmount();
    });
  });

  it("각 size를 올바르게 렌더링한다", () => {
    const sizes = ["sm", "md", "lg"] as const;
    sizes.forEach((size) => {
      const { unmount } = render(<Button size={size}>버튼</Button>);
      expect(screen.getByRole("button")).toBeInTheDocument();
      unmount();
    });
  });

  // 인터랙션
  it("클릭 이벤트를 처리한다", async () => {
    const user = userEvent.setup();
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>클릭</Button>);

    await user.click(screen.getByRole("button"));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it("disabled 상태에서 클릭을 무시한다", async () => {
    const user = userEvent.setup();
    const handleClick = vi.fn();
    render(<Button disabled onClick={handleClick}>클릭</Button>);

    await user.click(screen.getByRole("button"));
    expect(handleClick).not.toHaveBeenCalled();
    expect(screen.getByRole("button")).toBeDisabled();
  });

  // 로딩 상태
  it("loading 상태에서 Spinner와 '처리 중...' 텍스트를 표시한다", () => {
    render(<Button loading>저장</Button>);
    expect(screen.getByRole("status")).toBeInTheDocument();
    expect(screen.getByText("처리 중...")).toBeInTheDocument();
    expect(screen.getByRole("button")).toBeDisabled();
    // 원래 children은 숨겨짐
    expect(screen.queryByText("저장")).not.toBeInTheDocument();
  });

  // press 애니메이션
  it("press 애니메이션 클래스가 적용된다", () => {
    render(<Button>클릭</Button>);
    const button = screen.getByRole("button");
    expect(button.className).toContain("active:scale-[0.97]");
    expect(button.className).toContain("active:brightness-95");
  });

  // focus 접근성
  it("focus-visible ring이 적용된다", () => {
    render(<Button>클릭</Button>);
    const button = screen.getByRole("button");
    expect(button.className).toContain("focus-visible:ring-2");
  });
});
```

---

## Input.test.tsx

```typescript
describe("Input", () => {
  // 렌더링
  it("label과 함께 렌더링한다", () => {
    render(<Input label="이메일" />);
    expect(screen.getByLabelText("이메일")).toBeInTheDocument();
  });

  it("placeholder를 표시한다", () => {
    render(<Input label="이메일" placeholder="입력하세요" />);
    expect(screen.getByPlaceholderText("입력하세요")).toBeInTheDocument();
  });

  // 에러 상태
  it("에러 메시지를 표시한다", () => {
    render(<Input label="이메일" error="유효하지 않습니다" />);
    expect(screen.getByRole("alert")).toHaveTextContent("유효하지 않습니다");
    expect(screen.getByLabelText("이메일")).toHaveAttribute("aria-invalid", "true");
  });

  // 도움말
  it("helperText를 표시한다", () => {
    render(<Input label="비밀번호" helperText="8자 이상" />);
    expect(screen.getByText("8자 이상")).toBeInTheDocument();
  });

  // 인터랙션
  it("사용자 입력을 받는다", async () => {
    const user = userEvent.setup();
    render(<Input label="이름" />);

    await user.type(screen.getByLabelText("이름"), "홍길동");
    expect(screen.getByLabelText("이름")).toHaveValue("홍길동");
  });

  // variant 기반 스타일
  it("error variant에서 에러 스타일이 적용된다", () => {
    render(<Input label="이메일" variant="error" error="유효하지 않습니다" />);
    const input = screen.getByLabelText("이메일");
    expect(input.className).toContain("border-error");
  });

  // focus 애니메이션
  it("focus 애니메이션 클래스가 적용된다", () => {
    render(<Input label="이름" />);
    const input = screen.getByLabelText("이름");
    expect(input.className).toContain("focus:animate-input-focus");
  });

  // disabled 상태
  it("disabled 상태에서 입력을 받지 않는다", () => {
    render(<Input label="이름" disabled />);
    expect(screen.getByLabelText("이름")).toBeDisabled();
  });
});
```

---

## Card.test.tsx

```typescript
describe("Card", () => {
  it("children을 렌더링한다", () => {
    render(<Card>카드 내용</Card>);
    expect(screen.getByText("카드 내용")).toBeInTheDocument();
  });

  it("header를 렌더링한다", () => {
    render(<Card header={<h2>제목</h2>}>내용</Card>);
    expect(screen.getByRole("heading", { name: "제목" })).toBeInTheDocument();
  });

  it("footer를 렌더링한다", () => {
    render(<Card footer={<span>푸터</span>}>내용</Card>);
    expect(screen.getByText("푸터")).toBeInTheDocument();
  });

  it("header와 footer 모두 렌더링한다", () => {
    render(
      <Card header={<h2>제목</h2>} footer={<span>푸터</span>}>
        내용
      </Card>,
    );
    expect(screen.getByRole("heading", { name: "제목" })).toBeInTheDocument();
    expect(screen.getByText("내용")).toBeInTheDocument();
    expect(screen.getByText("푸터")).toBeInTheDocument();
  });
});
```

---

## Table.test.tsx

```typescript
describe("Table", () => {
  const columns = [
    { key: "name", header: "이름" },
    { key: "email", header: "이메일" },
  ];
  const data = [
    { name: "홍길동", email: "hong@example.com" },
    { name: "김철수", email: "kim@example.com" },
  ];

  it("헤더를 렌더링한다", () => {
    render(<Table columns={columns} data={data} />);
    expect(screen.getByText("이름")).toBeInTheDocument();
    expect(screen.getByText("이메일")).toBeInTheDocument();
  });

  it("데이터 행을 렌더링한다", () => {
    render(<Table columns={columns} data={data} />);
    expect(screen.getByText("홍길동")).toBeInTheDocument();
    expect(screen.getByText("kim@example.com")).toBeInTheDocument();
  });

  it("빈 데이터일 때 메시지를 표시한다", () => {
    render(<Table columns={columns} data={[]} />);
    expect(screen.getByText("데이터가 없습니다.")).toBeInTheDocument();
  });

  it("커스텀 빈 메시지를 표시한다", () => {
    render(<Table columns={columns} data={[]} emptyMessage="항목이 없습니다" />);
    expect(screen.getByText("항목이 없습니다")).toBeInTheDocument();
  });

  it("커스텀 렌더러를 사용한다", () => {
    const columnsWithRender = [
      { key: "name", header: "이름", render: (item: any) => <strong>{item.name}</strong> },
    ];
    render(<Table columns={columnsWithRender} data={data} />);
    expect(screen.getByText("홍길동").tagName).toBe("STRONG");
  });

  it("정렬 콜백을 호출한다", async () => {
    const user = userEvent.setup();
    const onSort = vi.fn();
    render(<Table columns={columns} data={data} onSort={onSort} />);

    await user.click(screen.getByText("이름"));
    expect(onSort).toHaveBeenCalledWith("name");
  });
});
```

---

## Badge.test.tsx

```typescript
describe("Badge", () => {
  it("텍스트를 렌더링한다", () => {
    render(<Badge>활성</Badge>);
    expect(screen.getByText("활성")).toBeInTheDocument();
  });

  it("각 variant를 렌더링한다", () => {
    const variants = ["default", "success", "warning", "error", "info"] as const;
    variants.forEach((variant) => {
      const { unmount } = render(<Badge variant={variant}>라벨</Badge>);
      expect(screen.getByText("라벨")).toBeInTheDocument();
      unmount();
    });
  });
});
```

---

## Spinner.test.tsx

```typescript
describe("Spinner", () => {
  it("로딩 상태를 렌더링한다", () => {
    render(<Spinner />);
    expect(screen.getByRole("status")).toBeInTheDocument();
  });

  it("접근성 레이블이 있다", () => {
    render(<Spinner />);
    expect(screen.getByLabelText("로딩 중")).toBeInTheDocument();
  });

  it("각 size를 렌더링한다", () => {
    const sizes = ["sm", "md", "lg"] as const;
    sizes.forEach((size) => {
      const { unmount } = render(<Spinner size={size} />);
      expect(screen.getByRole("status")).toBeInTheDocument();
      unmount();
    });
  });
});
```

---

## Form.test.tsx

```typescript
describe("Form", () => {
  it("children을 렌더링한다", () => {
    render(
      <Form>
        <Input label="이름" />
      </Form>,
    );
    expect(screen.getByLabelText("이름")).toBeInTheDocument();
  });

  it("submit 이벤트를 처리한다", async () => {
    const user = userEvent.setup();
    const handleSubmit = vi.fn((e) => e.preventDefault());
    render(
      <Form onSubmit={handleSubmit}>
        <Button type="submit">제출</Button>
      </Form>,
    );

    await user.click(screen.getByRole("button", { name: "제출" }));
    expect(handleSubmit).toHaveBeenCalledTimes(1);
  });
});
```

---

## Modal.test.tsx

```typescript
describe("Modal", () => {
  it("open=true일 때 내용을 렌더링한다", () => {
    render(
      <Modal open={true} onClose={vi.fn()} title="확인">
        모달 내용
      </Modal>,
    );
    expect(screen.getByRole("dialog")).toBeInTheDocument();
    expect(screen.getByText("확인")).toBeInTheDocument();
    expect(screen.getByText("모달 내용")).toBeInTheDocument();
  });

  it("open=false일 때 렌더링하지 않는다", () => {
    render(
      <Modal open={false} onClose={vi.fn()} title="확인">
        모달 내용
      </Modal>,
    );
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("Escape 키로 닫힌다", async () => {
    const user = userEvent.setup();
    const onClose = vi.fn();
    render(
      <Modal open={true} onClose={onClose} title="확인">
        내용
      </Modal>,
    );

    await user.keyboard("{Escape}");
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it("오버레이 클릭으로 닫힌다", async () => {
    const user = userEvent.setup();
    const onClose = vi.fn();
    render(
      <Modal open={true} onClose={onClose} title="확인">
        내용
      </Modal>,
    );

    // aria-hidden="true" 인 backdrop 요소 클릭
    const backdrop = document.querySelector("[aria-hidden='true']");
    if (backdrop) await user.click(backdrop);
    expect(onClose).toHaveBeenCalled();
  });

  it("액션 버튼을 렌더링한다", () => {
    render(
      <Modal
        open={true}
        onClose={vi.fn()}
        title="삭제"
        actions={<Button variant="destructive">삭제</Button>}
      >
        삭제하시겠습니까?
      </Modal>,
    );
    expect(screen.getByRole("button", { name: "삭제" })).toBeInTheDocument();
  });
});
```

---

## Toast.test.tsx (Zustand Store)

```typescript
import { act } from "react";
import { useToastStore, toast } from "@/components/feedback/Toast/useToast";

describe("Toast Store", () => {
  beforeEach(() => {
    // Zustand store 초기화
    useToastStore.setState({ toasts: [] });
  });

  it("success 토스트를 추가한다", () => {
    act(() => {
      toast.success("업로드가 완료되었습니다.");
    });
    const { toasts } = useToastStore.getState();
    expect(toasts).toHaveLength(1);
    expect(toasts[0].tone).toBe("success");
    expect(toasts[0].message).toBe("업로드가 완료되었습니다.");
  });

  it("error 토스트를 추가한다", () => {
    act(() => {
      toast.error("요청 처리에 실패했습니다.");
    });
    const { toasts } = useToastStore.getState();
    expect(toasts[0].tone).toBe("error");
  });

  it("success/info 기본 duration은 3000ms이다", () => {
    act(() => {
      toast.success("저장 완료");
      toast.info("안내 메시지");
    });
    const { toasts } = useToastStore.getState();
    expect(toasts[0].duration).toBe(3000);
    expect(toasts[1].duration).toBe(3000);
  });

  it("warn/error 기본 duration은 5000ms이다", () => {
    act(() => {
      toast.warn("경고 메시지");
      toast.error("에러 메시지");
    });
    const { toasts } = useToastStore.getState();
    expect(toasts[0].duration).toBe(5000);
    expect(toasts[1].duration).toBe(5000);
  });

  it("dismiss로 토스트를 제거한다", () => {
    act(() => {
      toast.success("메시지");
    });
    const { toasts, dismiss } = useToastStore.getState();
    act(() => {
      dismiss(toasts[0].id);
    });
    expect(useToastStore.getState().toasts).toHaveLength(0);
  });
});

describe("ToastContainer", () => {
  beforeEach(() => {
    useToastStore.setState({ toasts: [] });
  });

  it("토스트 메시지를 렌더링한다", () => {
    act(() => {
      toast.success("업로드가 완료되었습니다.");
    });
    render(<ToastContainer />);
    expect(screen.getByText("업로드가 완료되었습니다.")).toBeInTheDocument();
  });

  it("tone별 아이콘을 표시한다", () => {
    act(() => {
      toast.success("성공");
    });
    render(<ToastContainer />);
    expect(screen.getByText("✓")).toBeInTheDocument();
  });

  it("닫기 버튼으로 수동 닫기", async () => {
    const user = userEvent.setup();
    act(() => {
      toast.info("알림 메시지");
    });
    render(<ToastContainer />);

    await user.click(screen.getByRole("button", { name: "닫기" }));
    expect(screen.queryByText("알림 메시지")).not.toBeInTheDocument();
  });

  it("지정 시간 후 자동으로 사라진다", async () => {
    vi.useFakeTimers();
    act(() => {
      toast.success("자동 사라짐");
    });
    render(<ToastContainer />);
    expect(screen.getByText("자동 사라짐")).toBeInTheDocument();

    act(() => {
      vi.advanceTimersByTime(3000);
    });
    expect(screen.queryByText("자동 사라짐")).not.toBeInTheDocument();
    vi.useRealTimers();
  });
});
```

---

## Header.test.tsx

```typescript
describe("Header", () => {
  it("타이틀을 렌더링한다", () => {
    render(<Header title="내 앱" />);
    expect(screen.getByText("내 앱")).toBeInTheDocument();
  });

  it("내비게이션 항목을 렌더링한다", () => {
    const navItems = [
      { label: "홈", href: "/" },
      { label: "소개", href: "/about" },
    ];
    render(<Header title="앱" navItems={navItems} />);
    expect(screen.getByText("홈")).toBeInTheDocument();
    expect(screen.getByText("소개")).toBeInTheDocument();
  });

  it("로고를 렌더링한다", () => {
    render(<Header title="앱" logo={<img alt="로고" src="/logo.png" />} />);
    expect(screen.getByAltText("로고")).toBeInTheDocument();
  });

  it("액션 영역을 렌더링한다", () => {
    render(<Header title="앱" actions={<Button>로그인</Button>} />);
    expect(screen.getByRole("button", { name: "로그인" })).toBeInTheDocument();
  });
});
```

---

## Footer.test.tsx

```typescript
describe("Footer", () => {
  it("children을 렌더링한다", () => {
    render(<Footer>Copyright 2026</Footer>);
    expect(screen.getByText("Copyright 2026")).toBeInTheDocument();
  });
});
```

---

## Sidebar.test.tsx

```typescript
describe("Sidebar", () => {
  const items = [
    { label: "대시보드", href: "/dashboard" },
    { label: "설정", href: "/settings" },
  ];

  it("내비게이션 항목을 렌더링한다", () => {
    render(<Sidebar items={items} />);
    expect(screen.getByText("대시보드")).toBeInTheDocument();
    expect(screen.getByText("설정")).toBeInTheDocument();
  });

  it("링크가 올바른 href를 가진다", () => {
    render(<Sidebar items={items} />);
    expect(screen.getByText("대시보드").closest("a")).toHaveAttribute("href", "/dashboard");
  });

  it("collapsed 모드에서 라벨을 숨긴다", () => {
    render(<Sidebar items={items} collapsed />);
    expect(screen.queryByText("대시보드")).not.toBeInTheDocument();
  });
});
```

---

## AppLayout.test.tsx

```typescript
describe("AppLayout", () => {
  it("children을 렌더링한다", () => {
    render(<AppLayout>페이지 내용</AppLayout>);
    expect(screen.getByText("페이지 내용")).toBeInTheDocument();
  });

  it("sidebar를 렌더링한다", () => {
    render(
      <AppLayout sidebar={<nav>사이드바</nav>}>
        내용
      </AppLayout>,
    );
    expect(screen.getByText("사이드바")).toBeInTheDocument();
  });

  it("sidebar 없이 전체 너비로 렌더링한다", () => {
    const { container } = render(<AppLayout>내용</AppLayout>);
    // sidebar 영역이 없음을 확인
    expect(container.querySelector("aside")).not.toBeInTheDocument();
  });
});
```

---

## ConfirmDialog.test.tsx

```typescript
describe("ConfirmDialog", () => {
  const defaultProps = {
    open: true,
    title: "삭제하시겠습니까?",
    description: "이 작업은 되돌릴 수 없습니다.",
    onConfirm: vi.fn(),
    onCancel: vi.fn(),
  };

  it("open=true일 때 타이틀과 설명을 렌더링한다", () => {
    render(<ConfirmDialog {...defaultProps} />);
    expect(screen.getByText("삭제하시겠습니까?")).toBeInTheDocument();
    expect(screen.getByText("이 작업은 되돌릴 수 없습니다.")).toBeInTheDocument();
  });

  it("open=false일 때 렌더링하지 않는다", () => {
    render(<ConfirmDialog {...defaultProps} open={false} />);
    expect(screen.queryByText("삭제하시겠습니까?")).not.toBeInTheDocument();
  });

  it("확인 버튼 클릭 시 onConfirm을 호출한다", async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    render(<ConfirmDialog {...defaultProps} onConfirm={onConfirm} />);

    await user.click(screen.getByRole("button", { name: "확인" }));
    expect(onConfirm).toHaveBeenCalledTimes(1);
  });

  it("취소 버튼 클릭 시 onCancel을 호출한다", async () => {
    const user = userEvent.setup();
    const onCancel = vi.fn();
    render(<ConfirmDialog {...defaultProps} onCancel={onCancel} />);

    await user.click(screen.getByRole("button", { name: "취소" }));
    expect(onCancel).toHaveBeenCalledTimes(1);
  });

  it("오버레이 클릭 시 onCancel을 호출한다", async () => {
    const user = userEvent.setup();
    const onCancel = vi.fn();
    render(<ConfirmDialog {...defaultProps} onCancel={onCancel} />);

    const overlay = document.querySelector("[aria-hidden='true']");
    if (overlay) await user.click(overlay);
    expect(onCancel).toHaveBeenCalled();
  });

  it("커스텀 버튼 라벨을 표시한다", () => {
    render(
      <ConfirmDialog {...defaultProps} confirmLabel="삭제" cancelLabel="돌아가기" />,
    );
    expect(screen.getByRole("button", { name: "삭제" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "돌아가기" })).toBeInTheDocument();
  });

  it("destructive=true일 때 확인 버튼에 에러 스타일이 적용된다", () => {
    render(<ConfirmDialog {...defaultProps} destructive confirmLabel="삭제" />);
    const confirmBtn = screen.getByRole("button", { name: "삭제" });
    expect(confirmBtn.className).toContain("bg-error");
  });

  it("destructive=false일 때 확인 버튼에 primary 스타일이 적용된다", () => {
    render(<ConfirmDialog {...defaultProps} destructive={false} />);
    const confirmBtn = screen.getByRole("button", { name: "확인" });
    expect(confirmBtn.className).toContain("bg-primary-500");
  });
});
```

---

## Select.test.tsx

```typescript
describe("Select", () => {
  const options = [
    { value: "kr", label: "한국어" },
    { value: "en", label: "English" },
    { value: "jp", label: "日本語" },
  ];

  it("옵션 목록을 렌더링한다", async () => {
    const user = userEvent.setup();
    render(<Select options={options} label="언어" />);

    await user.click(screen.getByRole("combobox"));
    expect(screen.getByRole("listbox")).toBeInTheDocument();
    expect(screen.getAllByRole("option")).toHaveLength(3);
  });

  it("클릭으로 열고 닫는다", async () => {
    const user = userEvent.setup();
    render(<Select options={options} label="언어" />);

    const trigger = screen.getByRole("combobox");
    await user.click(trigger);
    expect(screen.getByRole("listbox")).toBeInTheDocument();

    await user.click(trigger);
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
  });

  it("키보드로 내비게이션한다", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Select options={options} label="언어" onChange={onChange} />);

    const trigger = screen.getByRole("combobox");
    await user.click(trigger);
    await user.keyboard("{ArrowDown}{ArrowDown}{Enter}");
    expect(onChange).toHaveBeenCalledWith("en");
  });

  it("disabled 상태에서 열리지 않는다", async () => {
    const user = userEvent.setup();
    render(<Select options={options} label="언어" disabled />);

    await user.click(screen.getByRole("combobox"));
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
  });

  it("onChange 콜백을 호출한다", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Select options={options} label="언어" onChange={onChange} />);

    await user.click(screen.getByRole("combobox"));
    await user.click(screen.getByText("English"));
    expect(onChange).toHaveBeenCalledWith("en");
  });

  it("Escape 키로 닫힌다", async () => {
    const user = userEvent.setup();
    render(<Select options={options} label="언어" />);

    await user.click(screen.getByRole("combobox"));
    expect(screen.getByRole("listbox")).toBeInTheDocument();

    await user.keyboard("{Escape}");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
  });
});
```

---

## Textarea.test.tsx

```typescript
describe("Textarea", () => {
  it("label과 함께 렌더링한다", () => {
    render(<Textarea label="설명" />);
    expect(screen.getByLabelText("설명")).toBeInTheDocument();
  });

  it("에러 메시지를 표시한다", () => {
    render(<Textarea label="설명" error="필수 입력입니다" />);
    expect(screen.getByRole("alert")).toHaveTextContent("필수 입력입니다");
    expect(screen.getByLabelText("설명")).toHaveAttribute("aria-invalid", "true");
  });

  it("focus 애니메이션 클래스가 적용된다", () => {
    render(<Textarea label="설명" />);
    const textarea = screen.getByLabelText("설명");
    expect(textarea.className).toContain("focus:animate-input-focus");
  });

  it("disabled 상태에서 입력을 받지 않는다", () => {
    render(<Textarea label="설명" disabled />);
    expect(screen.getByLabelText("설명")).toBeDisabled();
  });

  it("사용자 입력을 받는다", async () => {
    const user = userEvent.setup();
    render(<Textarea label="메모" />);

    await user.type(screen.getByLabelText("메모"), "테스트 내용");
    expect(screen.getByLabelText("메모")).toHaveValue("테스트 내용");
  });

  it("helperText를 표시한다", () => {
    render(<Textarea label="설명" helperText="최대 500자" />);
    expect(screen.getByText("최대 500자")).toBeInTheDocument();
  });
});
```

---

## Checkbox.test.tsx

```typescript
describe("Checkbox", () => {
  it("체크/해제를 토글한다", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Checkbox label="약관 동의" onChange={onChange} />);

    await user.click(screen.getByRole("checkbox"));
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it("label 클릭으로 토글한다", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Checkbox label="약관 동의" onChange={onChange} />);

    await user.click(screen.getByText("약관 동의"));
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it("disabled 상태에서 클릭을 무시한다", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Checkbox label="약관 동의" disabled onChange={onChange} />);

    await user.click(screen.getByRole("checkbox"));
    expect(onChange).not.toHaveBeenCalled();
    expect(screen.getByRole("checkbox")).toBeDisabled();
  });

  it("aria-checked 속성이 올바르다", () => {
    const { rerender } = render(<Checkbox label="동의" checked={false} />);
    expect(screen.getByRole("checkbox")).toHaveAttribute("aria-checked", "false");

    rerender(<Checkbox label="동의" checked={true} />);
    expect(screen.getByRole("checkbox")).toHaveAttribute("aria-checked", "true");
  });
});
```

---

## Tabs.test.tsx

```typescript
describe("Tabs", () => {
  const tabs = [
    { id: "tab1", label: "탭 1", content: <div>콘텐츠 1</div> },
    { id: "tab2", label: "탭 2", content: <div>콘텐츠 2</div> },
    { id: "tab3", label: "탭 3", content: <div>콘텐츠 3</div> },
  ];

  it("탭 목록을 렌더링한다", () => {
    render(<Tabs tabs={tabs} />);
    expect(screen.getByRole("tablist")).toBeInTheDocument();
    expect(screen.getAllByRole("tab")).toHaveLength(3);
  });

  it("클릭 시 탭을 전환한다", async () => {
    const user = userEvent.setup();
    render(<Tabs tabs={tabs} />);

    expect(screen.getByText("콘텐츠 1")).toBeInTheDocument();

    await user.click(screen.getByRole("tab", { name: "탭 2" }));
    expect(screen.getByText("콘텐츠 2")).toBeInTheDocument();
    expect(screen.queryByText("콘텐츠 1")).not.toBeInTheDocument();
  });

  it("active 탭에 aria-selected가 true이다", async () => {
    const user = userEvent.setup();
    render(<Tabs tabs={tabs} />);

    expect(screen.getByRole("tab", { name: "탭 1" })).toHaveAttribute("aria-selected", "true");
    expect(screen.getByRole("tab", { name: "탭 2" })).toHaveAttribute("aria-selected", "false");

    await user.click(screen.getByRole("tab", { name: "탭 2" }));
    expect(screen.getByRole("tab", { name: "탭 2" })).toHaveAttribute("aria-selected", "true");
    expect(screen.getByRole("tab", { name: "탭 1" })).toHaveAttribute("aria-selected", "false");
  });

  it("키보드(Arrow)로 탭을 전환한다", async () => {
    const user = userEvent.setup();
    render(<Tabs tabs={tabs} />);

    screen.getByRole("tab", { name: "탭 1" }).focus();
    await user.keyboard("{ArrowRight}");
    expect(screen.getByText("콘텐츠 2")).toBeInTheDocument();
  });

  it("onChange 콜백을 호출한다", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Tabs tabs={tabs} onChange={onChange} />);

    await user.click(screen.getByRole("tab", { name: "탭 2" }));
    expect(onChange).toHaveBeenCalledWith("tab2");
  });
});
```

---

## SearchInput.test.tsx

```typescript
describe("SearchInput", () => {
  it("placeholder를 표시한다", () => {
    render(<SearchInput placeholder="파일 검색..." />);
    expect(screen.getByPlaceholderText("파일 검색...")).toBeInTheDocument();
  });

  it("입력 후 clear 버튼으로 초기화한다", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<SearchInput onChange={onChange} />);

    const input = screen.getByRole("searchbox");
    await user.type(input, "test");

    const clearBtn = screen.getByRole("button", { name: "검색어 지우기" });
    await user.click(clearBtn);
    expect(input).toHaveValue("");
  });

  it("debounce 후 onChange를 호출한다", async () => {
    vi.useFakeTimers();
    const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });
    const onChange = vi.fn();
    render(<SearchInput onChange={onChange} debounceMs={200} />);

    await user.type(screen.getByRole("searchbox"), "검색어");
    expect(onChange).not.toHaveBeenCalled();

    vi.advanceTimersByTime(200);
    expect(onChange).toHaveBeenCalledWith("검색어");
    vi.useRealTimers();
  });

  it("돋보기 아이콘이 표시된다", () => {
    render(<SearchInput />);
    // SVG 아이콘은 aria-hidden이므로 DOM 존재 확인
    const input = screen.getByRole("searchbox");
    expect(input.parentElement?.querySelector("svg")).toBeInTheDocument();
  });

  it("Escape 키로 입력을 초기화한다", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<SearchInput onChange={onChange} />);

    const input = screen.getByRole("searchbox");
    await user.type(input, "test");
    await user.keyboard("{Escape}");
    expect(input).toHaveValue("");
  });
});
```

---

## FileUpload.test.tsx

```typescript
describe("FileUpload", () => {
  it("드래그 영역을 렌더링한다", () => {
    render(<FileUpload />);
    expect(screen.getByRole("button", { name: "파일 업로드 영역" })).toBeInTheDocument();
  });

  it("파일 선택 후 파일 정보를 표시한다", async () => {
    const user = userEvent.setup();
    const onFiles = vi.fn();
    render(<FileUpload onFiles={onFiles} />);

    const file = new File(["내용"], "test.pdf", { type: "application/pdf" });
    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    await user.upload(input, file);

    expect(screen.getByText("test.pdf")).toBeInTheDocument();
    expect(onFiles).toHaveBeenCalledWith([file]);
  });

  it("크기 제한 초과 시 에러를 표시한다", async () => {
    const user = userEvent.setup();
    render(<FileUpload maxSizeMB={0.001} />);

    const bigContent = new Array(2000).fill("a").join("");
    const file = new File([bigContent], "big.pdf", { type: "application/pdf" });
    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    await user.upload(input, file);

    expect(screen.getByRole("alert")).toBeInTheDocument();
  });

  it("최대 크기 안내 텍스트를 표시한다", () => {
    render(<FileUpload maxSizeMB={5} />);
    expect(screen.getByText("최대 5MB")).toBeInTheDocument();
  });

  it("accept 속성을 전달한다", () => {
    render(<FileUpload accept=".pdf,.jpg" />);
    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    expect(input).toHaveAttribute("accept", ".pdf,.jpg");
  });
});
```
