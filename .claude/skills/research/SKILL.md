---
name: research
description: 요구사항 분석 및 코드베이스 탐색. 새 기능 개발 시작 시 사용합니다.
argument-hint: [프로젝트명] [기능 설명]
---

# /research — 요구사항 분석 스킬

사용자의 요구사항을 분석하고 코드베이스를 탐색하여 체계적인 요구사항 문서를 작성합니다.

## 인자 파싱

`$ARGUMENTS`에서 첫 번째 단어를 프로젝트명으로, 나머지를 기능 설명으로 파싱합니다.
- 예: `/research bookstore_order 온라인 서점 주문 관리 API`
  - 프로젝트명: `bookstore_order`
  - 기능 설명: `온라인 서점 주문 관리 API`
- 프로젝트 경로: `projects/{프로젝트명}/`

## 지시사항

1. **프로젝트 디렉토리 생성**:
   - `projects/{프로젝트명}/docs/specs/` 디렉토리 생성
   - `projects/{프로젝트명}/docs/api/` 디렉토리 생성
   - `projects/{프로젝트명}/docs/reviews/` 디렉토리 생성

2. Task 도구로 `researcher` 서브에이전트를 실행합니다:
   - `subagent_type`: "Explore"
   - `model`: "haiku"
   - 프롬프트에 다음을 포함:
     - 사용자 요구사항 (기능 설명)
     - 프로젝트 경로: `projects/{프로젝트명}/`
     - 코드베이스 탐색 지시
     - `projects/{프로젝트명}/docs/specs/requirements.md` 출력 지시
     - 템플릿 참조: `.claude/skills/research/templates/requirements-template.md`
     - `.claude/agents/researcher.md`의 절차를 따를 것

3. 서브에이전트 완료 후:
   - `projects/{프로젝트명}/docs/specs/requirements.md` 파일 존재 확인
   - 사용자에게 결과 요약 보고

## 산출물

- `projects/{프로젝트명}/docs/specs/requirements.md`
