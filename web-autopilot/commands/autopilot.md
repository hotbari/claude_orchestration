# Web Autopilot Command

**Purpose**: Start the complete Figma-to-production pipeline automatically

**Trigger**: User says "autopilot", "start pipeline", or "build from figma"

---

## What This Command Does

This command launches the full 6-phase web service automation pipeline:

1. **Design Analysis** - Extract structured specs from Figma
2. **Requirements** - Generate PRD with user interview
3. **Architecture** - Design system architecture and tech stack
4. **Implementation** - Build fullstack application (Next.js + FastAPI + PostgreSQL)
5. **QA** - Test and verify all functionality
6. **Completion** - Final verification and handoff

---

## Usage

```
/webautopilot
```

Optional with arguments:
```
/autopilot --figma-url https://figma.com/file/...
/autopilot --service-name my-app
/autopilot --skip-interview  # Skip requirements interview
```

---

## Execution Flow

### Phase 1: Initialization
1. Check if `project_brief.md` exists
2. If missing Figma URL, prompt user
3. Validate Figma access via MCP

### Phase 2: Pipeline Execution
1. Invoke `/pipeline` skill
2. Monitor progress through all 6 phases
3. Handle errors with auto-retry (max 3 attempts per phase)

### Phase 3: Completion
1. Verify all deliverables exist:
   - `docs/design-analysis.md`
   - `docs/PRD.md`
   - `docs/architecture.md`
   - Working codebase (frontend + backend)
   - Test results
2. Generate completion report
3. Offer deployment options

---

## Required Context

Before running, ensure:
- [ ] Figma MCP server configured (check `mcp.json`)
- [ ] `project_brief.md` exists with Figma URL
- [ ] Git repository initialized

If missing, the command will guide you through setup.

---

## Output

### Success
```
✓ Web Autopilot completed successfully!

📊 Results:
- Design Analysis: ✓ 45 components analyzed
- Requirements: ✓ PRD generated (2,340 words)
- Architecture: ✓ System design complete
- Implementation: ✓ Frontend (23 files) + Backend (12 files)
- QA: ✓ All tests passing (87 tests)
- Completion: ✓ Production-ready

📁 Deliverables:
- docs/design-analysis.md
- docs/PRD.md
- docs/architecture.md
- frontend/ (Next.js 14)
- backend/ (FastAPI)
- tests/

🚀 Next steps:
  1. Review generated documentation
  2. Run local dev: npm run dev && uvicorn main:app
  3. Deploy: /deploy
```

### Partial Failure
```
⚠ Web Autopilot paused at phase 3 (Architecture)

✓ Phase 1: Design Analysis - Complete
✓ Phase 2: Requirements - Complete
✗ Phase 3: Architecture - Error: Missing database schema

📋 To resume:
  /pipeline --resume --from architecture
```

---

## Implementation Logic

```javascript
// Pseudo-code for command execution
async function executeAutopilot(args) {
  // 1. Validate environment
  const config = await validateSetup();

  // 2. Initialize project state
  await initProjectState(config);

  // 3. Execute pipeline
  const result = await invokePipelineSkill({
    phases: ['design-analysis', 'requirements', 'architecture', 'implementation', 'qa', 'completion'],
    autoRetry: true,
    maxRetries: 3,
    continueOnError: false
  });

  // 4. Handle result
  if (result.success) {
    await generateCompletionReport(result);
    await offerDeployment();
  } else {
    await handlePartialFailure(result);
  }
}
```

---

## Error Handling

| Error Type | Action |
|------------|--------|
| Missing Figma URL | Prompt user for URL |
| Figma access denied | Guide to MCP setup |
| Phase failure | Auto-retry up to 3 times |
| Persistent failure | Pause and offer resume |
| User cancellation | Save state for resume |

---

## State Management

State saved to `.omc/state/autopilot-state.json`:

```json
{
  "currentPhase": "architecture",
  "completedPhases": ["design-analysis", "requirements"],
  "startTime": "2026-03-05T15:30:00Z",
  "config": {
    "figmaUrl": "https://...",
    "serviceName": "my-service",
    "skipInterview": false
  },
  "errors": [],
  "retryCount": 1
}
```

---

## Integration with Skills

This command orchestrates existing skills:

| Phase | Skill Called | Agent Used |
|-------|--------------|------------|
| Design Analysis | `/design-analysis` | figma-analyzer (sonnet) |
| Requirements | `/requirements` | design-to-spec-analyst (opus) |
| Architecture | `/architecture` | system-architect (opus) |
| Implementation | `/implementation` | fullstack-builder (sonnet) |
| QA | `/qa` | qa-tester (sonnet) |
| Completion | `/completion` | completion-verifier (opus) |

---

## Behavior Rules

1. **Non-blocking**: User can cancel at any time with "stop" or Ctrl+C
2. **Resumable**: Always save state for resume capability
3. **Transparent**: Show progress for each phase
4. **Smart**: Skip phases if deliverables already exist (with confirmation)
5. **Autonomous**: Minimal user interaction (except requirements interview)

---

## Success Criteria

Command is successful when:
- All 6 phases complete without errors
- All deliverable files exist and are valid
- Code builds and tests pass
- Architect verification passes
- No blocking issues remain

---

## Related Commands

- `/pipeline` - Execute custom phase sequence
- `/deploy` - Deploy to production
- `/qa` - Run QA only
- `/status` - Check autopilot progress

---

## Examples

### Basic usage
```
User: "autopilot"
→ Reads project_brief.md, starts full pipeline
```

### With Figma URL
```
User: "autopilot https://figma.com/file/ABC123"
→ Updates project_brief.md, starts pipeline
```

### Resume after pause
```
User: "resume autopilot"
→ Reads state, continues from last phase
```

### Skip interview mode
```
User: "autopilot --skip-interview"
→ Uses defaults, no user questions
```
