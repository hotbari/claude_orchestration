---
name: completion
description: Final documentation and state cleanup - README creation, state deletion
version: 1.0.0
---

# Completion Phase

## 개요

README 생성 + state 정리

---

## 전제 조건 & 입출력

**State:** `qa === "completed"`, `ralphLoop.lastReviewResult === "approved"`

**출력:**
- `projects/{service}-backend/README.md`
- `projects/{service}-frontend/README.md`
- State 파일 삭제됨

---

## Agents

| Agent | Model | 책임 |
|-------|-------|------|
| writer | haiku | README 생성 |

---

## 프로세스

### Step 1: 의존성 확인

```javascript
if (state.phases.qa !== "completed") throw Error("QA first");
if (state.ralphLoop?.lastReviewResult !== "approved") throw Error("Architect approval");
```

---

### Step 2: Backend README

**writer 위임:**
```
Create README.md for backend.
Sections: Overview, Tech Stack, Installation, Environment, Running, API Docs, Testing, Structure
Tech: Python 3.10+, FastAPI, PostgreSQL, SQLAlchemy, Alembic
Output: projects/{service}-backend/README.md
```

**포함:** venv, pip install, DATABASE_URL, uvicorn, /docs, pytest, Clean 3-layer

<!-- 생략: README 템플릿 상세 -->

---

### Step 3: Frontend README

**writer 위임:**
```
Create README.md for frontend.
Sections: Overview, Tech Stack, Installation, Environment, Running, Components, Design Tokens, Testing, Figma
Tech: Next.js 14, React 18, TypeScript, Tailwind, shadcn/ui
Output: projects/{service}-frontend/README.md
```

**포함:** npm install, NEXT_PUBLIC_API_URL, npm run dev, ui/common/features, design-tokens.ts, Figma 100% 충실도

<!-- 생략: 컴포넌트 아키텍처 상세 -->

---

### Step 4: State 정리

**중요:** 파일 완전 삭제
```javascript
state.phases.completion = "completed";
stateManager.saveState(state);

fs.unlinkSync('.omc/state/web-autopilot-state.json');
console.log('State cleaned');
```

**검증:** `ls .omc/state/web-autopilot-state.json` # Should fail

<!-- 생략: 삭제 실패 복구 -->

---

### Step 5: 최종 요약

```
✅ Web Autopilot Complete!

📦 Projects:
- Backend: projects/{service}-backend/
- Frontend: projects/{service}-frontend/

📚 Documentation:
- Backend README
- Frontend README

🚀 Quick Start:
Backend: cd backend && venv && pip install && uvicorn
Frontend: cd frontend && npm install && npm run dev

📖 Next: Configure .env, Review READMEs, Deploy

🧹 State cleaned
```

<!-- 생략: Deployment 가이드 -->

---

## 검증 체크리스트

- [ ] Backend README 완전
- [ ] Frontend README 완전
- [ ] 설치/환경/실행 지침
- [ ] API/컴포넌트 문서
- [ ] State 삭제됨

---

## 오류 처리

| 오류 | 조치 |
|------|------|
| State 없음 | 정보 로그, 계속 (멱등) |
| README 실패 | 디렉토리/권한 확인, writer 재실행 |
| Writer 불완전 | 누락 섹션 추가 |

---

**소요:** 5-10분
**성공:** README 완료, state 삭제, 프로젝트 실행 가능
