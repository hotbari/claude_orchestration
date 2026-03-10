# Resume Command

**Purpose**: Resume a paused or interrupted pipeline

**Trigger**: User says "resume", "continue", or "restart from where we left off"

---

## What This Command Does

Intelligently resumes the pipeline from the last saved state:
- Detects last completed phase
- Validates existing deliverables
- Continues from interruption point
- Handles partial phase completion

---

## Usage

```
/resume

# Resume from specific phase
/resume --from architecture

# Force restart current phase
/resume --restart-phase

# Resume with different settings
/resume --skip-interview
```

---

## Execution Flow

### Step 1: State Detection

```
🔍 Detecting last state...

Found state: .omc/state/autopilot-state.json
Last active: 15 minutes ago
Current phase: Architecture (45% complete)

✓ Phase 1: Design Analysis - Completed
✓ Phase 2: Requirements - Completed
⚙ Phase 3: Architecture - Partial (stopped at database schema)
⏳ Phase 4-6: Pending
```

### Step 2: Validation

```
🔎 Validating existing deliverables...

✓ docs/design-analysis.md - Valid (45 components)
✓ docs/PRD.md - Valid (2,340 words)
⚠ docs/architecture.md - Incomplete (missing database section)

✓ Figma MCP - Connected
✓ Git repository - Clean
✓ Dependencies - Up to date
```

### Step 3: Resume Point Decision

```
📍 Resume options:

1. Continue from Architecture (45%) - Recommended
   → Pick up database schema design
   → Estimated time: ~20m

2. Restart Architecture from beginning
   → Regenerate entire architecture
   → Estimated time: ~35m

3. Skip to Implementation
   → Requires manual architecture completion
   → Risky: May cause errors

Which option? [1/2/3] (default: 1)
```

### Step 4: Execution

```
▶ Resuming from Architecture phase...

⚙ Loading context from previous session...
✓ Loaded design analysis (45 components)
✓ Loaded requirements (15 user stories)
✓ Loaded partial architecture (API design, tech stack)

🔄 Continuing database schema design...
```

---

## Implementation Logic

```javascript
async function resumePipeline(args) {
  // 1. Load state
  const state = await loadAutopilotState();
  if (!state) {
    return "No pipeline to resume. Use /autopilot to start new.";
  }

  // 2. Validate deliverables
  const validation = await validateDeliverables(state);
  if (!validation.valid) {
    await handleCorruptedState(validation.errors);
  }

  // 3. Determine resume point
  const resumePoint = args.from || determineResumePoint(state);

  // 4. Confirm with user if ambiguous
  if (needsUserConfirmation(resumePoint)) {
    await askResumeOptions(resumePoint);
  }

  // 5. Resume pipeline
  await invokePipelineSkill({
    startFrom: resumePoint,
    previousState: state,
    preserveContext: true
  });
}
```

---

## Resume Strategies

| Scenario | Strategy |
|----------|----------|
| Clean interruption (Ctrl+C) | Resume from exact point |
| Phase completed but not saved | Restart phase with cache |
| Partial deliverable exists | Offer continue or restart |
| Corrupted state | Offer repair or start fresh |
| Error during phase | Fix error, then resume |
| Long time elapsed (>24h) | Revalidate all dependencies |

---

## State Recovery

### Valid State
```
✓ State is valid and recent
→ Resuming immediately
```

### Stale State (>24 hours)
```
⚠ State is 2 days old. Checking for changes...

✓ Figma design - No changes
✓ Dependencies - Up to date
⚠ Architecture best practices - Updated (React 19 released)

Recommendation: Restart Architecture phase to use latest patterns.
Continue anyway? [y/N]
```

### Corrupted State
```
✗ State file corrupted or incomplete

Options:
1. Repair state from git history
2. Repair state from deliverables
3. Start fresh (keep existing deliverables)

Which option? [1/2/3]
```

---

## Context Preservation

When resuming, preserve:
- User preferences from requirements interview
- Design decisions from architecture phase
- Custom configurations
- Error fixes applied
- Manual code edits

Example:
```
🧠 Restoring context...

✓ User preferences:
  - Authentication: JWT
  - Database: PostgreSQL
  - Deployment: Vercel + Railway

✓ Custom edits preserved:
  - frontend/utils/custom-hook.ts (manual edit)
  - backend/config.py (custom settings)

These files will not be overwritten.
```

---

## Error Handling During Resume

| Error Type | Handling |
|------------|----------|
| Missing deliverable | Regenerate from previous phase |
| Corrupted file | Restore from git or regenerate |
| Dependency changed | Update and continue |
| MCP disconnected | Reconnect and retry |
| Conflict with manual edits | Ask user to resolve |

---

## Integration with Other Commands

- `/status` → `/resume` - Check before resuming
- `/resume` + `/clean --cache` - Fresh resume
- `/resume --from X` after fixing errors
- `/autopilot` vs `/resume` - Resume checks for existing state

---

## Behavior Rules

1. **Safe**: Never overwrite manual user edits
2. **Smart**: Auto-detect best resume point
3. **Transparent**: Show what will be preserved/regenerated
4. **Flexible**: Allow manual resume point selection
5. **Fast**: Resume within 5 seconds of confirmation

---

## Examples

### Basic Resume
```
User: "resume"
→ Auto-detect and continue from last point
```

### Resume from Specific Phase
```
User: "resume from implementation"
→ Skip to implementation, keep earlier phases
```

### Resume After Error Fix
```
User: "I fixed the database schema error, resume"
→ Validate fix, continue architecture phase
```

### Resume with Fresh Start of Current Phase
```
User: "resume --restart-phase"
→ Restart architecture from beginning, keep phase 1-2
```

---

## State File Usage

Reads and updates `.omc/state/autopilot-state.json`:

```json
{
  "resumable": true,
  "resumePoint": {
    "phase": "architecture",
    "task": "database-schema",
    "progress": 0.45
  },
  "preservedContext": {
    "userPreferences": {...},
    "designDecisions": {...},
    "manualEdits": ["frontend/utils/custom-hook.ts"]
  },
  "lastSaveTime": "2026-03-05T15:48:00Z"
}
```

---

## Success Criteria

Resume is successful when:
- Pipeline continues without errors
- Previous context is preserved
- Manual edits are not overwritten
- User-confirmed resume point is used
- Progress tracking is accurate
