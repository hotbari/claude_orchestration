# Status Command

**Purpose**: Check current pipeline progress and system status

**Trigger**: User says "status", "check progress", or "where are we"

---

## What This Command Does

Displays comprehensive status information:
- Current pipeline phase and progress
- Completed vs remaining tasks
- Recent errors or warnings
- Time elapsed and estimated remaining
- System health checks

---

## Usage

```
/status

# Detailed mode
/status --verbose

# Specific phase
/status architecture

# JSON output
/status --json
```

---

## Output Format

### During Pipeline Execution

```
🚀 Web Autopilot Status

📊 Progress: Phase 3/6 (Architecture)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 50%

✓ Phase 1: Design Analysis      [Completed] 15m ago
✓ Phase 2: Requirements          [Completed] 8m ago
⚙ Phase 3: Architecture          [In Progress] 45% - Designing database schema
⏳ Phase 4: Implementation       [Pending]
⏳ Phase 5: QA                   [Pending]
⏳ Phase 6: Completion           [Pending]

⏱ Elapsed: 23m 14s
⏱ Estimated remaining: ~37m

📁 Current deliverables:
  ✓ docs/design-analysis.md (45 components)
  ✓ docs/PRD.md (2,340 words)
  ⚙ docs/architecture.md (in progress)

💾 State: .omc/state/autopilot-state.json
🔄 Last updated: 12s ago
```

### No Active Pipeline

```
✓ Web Autopilot Status

No active pipeline.

📁 Project: my-service-name
🔗 Figma URL: https://figma.com/file/ABC123

Last run: 2 days ago
Status: Completed successfully

📁 Deliverables:
  ✓ docs/design-analysis.md
  ✓ docs/PRD.md
  ✓ docs/architecture.md
  ✓ frontend/ (23 files)
  ✓ backend/ (12 files)
  ✓ tests/ (87 tests passing)

💡 To start a new pipeline: /autopilot
```

### Error State

```
⚠ Web Autopilot Status

Pipeline paused due to error.

✓ Phase 1: Design Analysis      [Completed]
✓ Phase 2: Requirements          [Completed]
✗ Phase 3: Architecture          [Failed] Missing database schema

❌ Last error:
  Phase: Architecture
  Time: 5m ago
  Error: Database schema validation failed
  Details: Missing primary key for 'users' table

🔧 To resume after fixing: /resume
📋 To view full logs: cat .omc/logs/pipeline.log
```

---

## Implementation Logic

```javascript
async function getStatus(args) {
  // 1. Read state file
  const state = await readAutopilotState();

  // 2. Check if pipeline is active
  if (state.currentPhase) {
    return formatActiveStatus(state);
  }

  // 3. Check for completed pipeline
  if (state.lastRun) {
    return formatCompletedStatus(state);
  }

  // 4. No pipeline history
  return formatIdleStatus();
}
```

---

## Status Checks

| Check | What It Does |
|-------|--------------|
| Pipeline Phase | Current phase and progress percentage |
| Task Completion | Completed tasks vs total tasks |
| Deliverables | Which files exist and are valid |
| System Health | MCP servers, git status, dependencies |
| Error Log | Recent errors or warnings |
| Resource Usage | Disk space, memory (if relevant) |

---

## State File Format

Reads from `.omc/state/autopilot-state.json`:

```json
{
  "currentPhase": "architecture",
  "currentPhaseProgress": 0.45,
  "completedPhases": ["design-analysis", "requirements"],
  "startTime": "2026-03-05T15:30:00Z",
  "lastUpdate": "2026-03-05T15:53:14Z",
  "errors": [
    {
      "phase": "architecture",
      "message": "Database schema validation failed",
      "timestamp": "2026-03-05T15:48:00Z",
      "resolved": false
    }
  ],
  "deliverables": {
    "design-analysis.md": {
      "exists": true,
      "size": 45234,
      "lastModified": "2026-03-05T15:45:00Z"
    }
  }
}
```

---

## Verbose Mode

With `--verbose` flag, includes:
- Detailed task breakdown for current phase
- Full error stack traces
- Agent activity log
- File change history
- Git commit log
- Dependency versions

---

## JSON Output

With `--json` flag, outputs machine-readable format:

```json
{
  "status": "in_progress",
  "currentPhase": "architecture",
  "progress": 0.5,
  "elapsed": 1394,
  "estimatedRemaining": 2220,
  "completedPhases": ["design-analysis", "requirements"],
  "errors": [],
  "deliverables": {...}
}
```

---

## Integration with Other Commands

- `/status` before `/resume` - Check what needs to be resumed
- `/status --verbose` before `/clean` - See what will be deleted
- `/status` after `/autopilot` - Monitor progress

---

## Behavior Rules

1. **Fast**: Should respond in <1 second
2. **Non-intrusive**: Read-only, no side effects
3. **Accurate**: Always show real-time state
4. **Helpful**: Suggest next actions based on status
5. **Colorful**: Use emojis and colors for readability

---

## Examples

```
User: "status"
→ Show current pipeline progress

User: "how's it going?"
→ Auto-detect as status check

User: "status --json | jq .progress"
→ Machine-readable output

User: "status architecture"
→ Detailed view of specific phase
```
