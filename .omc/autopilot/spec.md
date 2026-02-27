# Web Autopilot Plugin - Consolidated Specification

## Executive Summary

The web-autopilot plugin is a 6-phase pipeline that transforms Figma designs into complete, production-ready web services. It automates the journey from design files to deployed fullstack applications (Next.js + FastAPI + PostgreSQL).

---

## Requirements Analysis

### Functional Requirements

#### The 6 Phases

1. **Design Analysis** - Fetch Figma designs, extract design tokens, identify components
2. **Requirements** - User interview, create PRD, API spec, DB schema
3. **Architecture** - System design, tech stack decisions, dependency planning
4. **Implementation** - Backend (FastAPI) then Frontend (Next.js + shadcn/ui)
5. **QA & Refactoring** - Ralph loop: test → review → refactor → repeat until APPROVED
6. **Completion** - Documentation, state cleanup

#### Progressive Disclosure Pattern

- **SKILL.md**: Core guide (≤500 lines)
- **references/**: Detailed documentation
- **scripts/**: Executable utilities
- **assets/**: Templates and samples

#### State-Driven Orchestration

- Phase dependency checking via `.omc/state/web-autopilot-state.json`
- User confirms each phase before proceeding
- Failed phases can be retried independently

### Non-Functional Requirements

- **User Control**: Step-by-step confirmation, re-execution capability
- **Verification-Driven**: Ralph pattern ensures quality through evidence
- **Figma Fidelity**: Content (text) must match exactly; visual design adapted reasonably
- **OMC Integration**: Reuses existing agent patterns, state conventions

### Directory Structure

```
.claude/plugins/web-autopilot/
  ├── .claude-plugin/plugin.json
  ├── COMMON.md
  ├── IMPLEMENTATION_PLAN.md
  ├── skills/
  │   ├── design-analysis/SKILL.md
  │   ├── requirements/SKILL.md
  │   ├── architecture/SKILL.md
  │   ├── implementation/SKILL.md
  │   ├── qa/SKILL.md
  │   └── completion/SKILL.md
  └── utils/state-manager.js

.omc/state/web-autopilot-state.json
.omc/web-projects/{service-name}/docs/...
projects/{service-name}-frontend/
projects/{service-name}-backend/
```

---

## Technical Specification

### Tech Stack

**Plugin**:
- Markdown-based skills (YAML frontmatter)
- JSON state management
- JavaScript utilities (Node.js)

**Generated Services**:
- Frontend: Next.js 14+ + TypeScript + Tailwind CSS + shadcn/ui
- Backend: FastAPI + SQLAlchemy + Pydantic
- Database: PostgreSQL
- Testing: pytest, Jest, Playwright

### Architecture

**Phase Interaction**:
```
design-analysis → requirements → architecture → implementation → qa → completion
                  ↑                                               ↓
                  └─────────────── Ralph Loop ──────────────────┘
```

**State Schema**:
```json
{
  "active": true,
  "serviceName": "example-service",
  "currentPhase": "implementation",
  "phases": {
    "design-analysis": "completed",
    "requirements": "completed",
    "architecture": "completed",
    "implementation": "in_progress",
    "qa": "pending",
    "completion": "pending"
  },
  "ralphLoop": {
    "iterationCount": 0,
    "maxIterations": 5,
    "lastReviewResult": "pending"
  },
  "documents": {
    "designAnalysis": ".omc/web-projects/example/docs/design-analysis.md",
    "prd": ".omc/web-projects/example/docs/prd.md",
    "apiSpec": ".omc/web-projects/example/docs/api-spec.md"
  },
  "figmaUrl": "https://figma.com/file/...",
  "techStack": null
}
```

### Agent Delegation

| Phase | Agent | Model | Task |
|-------|-------|-------|------|
| design-analysis | vision, designer | sonnet | Analyze Figma designs |
| requirements | analyst, architect-low | opus, haiku | Extract requirements |
| architecture | architect | opus | Design system |
| implementation (BE) | executor-high | opus | Build FastAPI backend |
| implementation (FE) | designer-high | opus | Build Next.js frontend |
| qa (tests) | tdd-guide, executor | sonnet | Unit/E2E tests |
| qa (review) | architect | opus | Code review |
| qa (security) | security-reviewer | opus | Security audit |
| completion | writer | haiku | Documentation |

### Dependencies

**OMC Agents Required**: vision, designer, designer-high, analyst, architect-low, architect, executor, executor-high, tdd-guide, qa-tester-high, build-fixer, security-reviewer, writer

**MCP Servers**: Figma MCP (required for Phase 1)

**Tools**: Node.js 18+, Python 3.10+, npm/pnpm, pip/uv

---

## Implementation Phases

### Phase 1: Core Setup (NOW)
- Create directory structure
- Write `plugin.json`
- Write `COMMON.md`
- Write `utils/state-manager.js`

### Phase 2: MVP Skills (NEXT)
- `skills/design-analysis/SKILL.md`
- `skills/requirements/SKILL.md`
- Test end-to-end

### Phase 3: Implementation Skills
- `skills/architecture/SKILL.md`
- `skills/implementation/SKILL.md`

### Phase 4: QA & Completion
- `skills/qa/SKILL.md` (Ralph loop)
- `skills/completion/SKILL.md`

### Phase 5: References & Assets
- Priority 1: design-tokens-guide.md, prd-template.md, api-spec-format.md, fastapi-patterns.md, shadcn-setup.md, ralph-loop-guide.md
- Priority 2: Remaining references
- Assets: Templates and examples
- Scripts: init-nextjs.sh, init-fastapi.py, run-tests.sh

### Phase 6: End-to-End Validation
- Real Figma design
- Execute all 6 phases
- Verify complete working system

---

## Success Criteria

**Phase 1 Complete**:
- [ ] All directories created
- [ ] plugin.json valid
- [ ] COMMON.md comprehensive
- [ ] state-manager.js functional

**Phase 2 Complete**:
- [ ] design-analysis skill works with real Figma URL
- [ ] requirements skill generates valid PRD/API spec/DB schema
- [ ] State transitions correctly

**Phases 3-4 Complete**:
- [ ] All 6 phase skills executable
- [ ] Ralph loop functional
- [ ] State cleanup works

**Phase 5 Complete**:
- [ ] All P1 references written
- [ ] Key templates available

**Phase 6 Complete**:
- [ ] End-to-end test passes
- [ ] Generated code builds and runs
- [ ] All tests pass

---

## Critical Design Decisions

1. **Phase Independence**: Each phase is a separate skill, can be re-run independently
2. **Sequential Implementation**: Backend before frontend (API contract first)
3. **Content Fidelity**: Figma text must match exactly; visual design adapted
4. **Ralph Pattern**: QA phase loops until architect approval (max 5 iterations)
5. **Progressive Disclosure**: Core instructions in SKILL.md, details in references/

---

## Known Limitations

- Sequential phases (no backend/frontend parallelization)
- Requires Figma MCP server
- Single service at a time
- No deployment automation (Phase 6 could add this)

**EXPANSION COMPLETE**
