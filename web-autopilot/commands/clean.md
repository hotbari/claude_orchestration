# Clean Command

**Purpose**: Clean up pipeline state, cache, and temporary files

**Trigger**: User says "clean", "reset", or "clear state"

---

## What This Command Does

Safely removes:
- Pipeline state files
- Agent cache
- Temporary build artifacts
- Old logs (optional)
- Generated documentation (with confirmation)

**Does NOT remove**:
- Source code
- Git history
- User configurations
- Final deliverables (unless specified)

---

## Usage

```
/clean

# Clean specific items
/clean state
/clean cache
/clean logs

# Clean everything
/clean --all

# Clean with confirmation prompts
/clean --interactive

# Force clean without prompts
/clean --force

# Dry run (show what would be deleted)
/clean --dry-run
```

---

## Clean Targets

### Default Clean (Safe)

```
🧹 Cleaning temporary files...

✓ Removed pipeline state (.omc/state/autopilot-state.json)
✓ Removed agent cache (.omc/cache/) - 45 MB freed
✓ Removed build artifacts (node_modules/.cache/) - 128 MB freed
✓ Removed old logs (older than 7 days) - 3 files

Total space freed: 173 MB

✅ Clean complete. Your code and deliverables are safe.
```

### Selective Clean

```
/clean state

🧹 Cleaning state files...

Files to remove:
  - .omc/state/autopilot-state.json
  - .omc/state/pipeline-state.json
  - .omc/state/agent-sessions.json

⚠ Warning: You won't be able to resume current pipeline.

Continue? [y/N]
```

### Full Clean (Aggressive)

```
/clean --all

⚠️  FULL CLEAN MODE

This will remove:
  ✓ Pipeline state
  ✓ Agent cache
  ✓ Build artifacts
  ✓ All logs
  ✓ Generated documentation (docs/)
  ✓ Temporary configs

This will NOT remove:
  ✗ Source code (frontend/, backend/)
  ✗ Git history
  ✗ User settings
  ✗ project_brief.md

⚠ This action cannot be undone!
Type 'clean everything' to confirm:
```

---

## Implementation Logic

```javascript
async function cleanProject(args) {
  // 1. Determine clean scope
  const scope = args.all ? 'all' : args.target || 'safe';

  // 2. Identify files to remove
  const targets = await identifyCleanTargets(scope);

  // 3. Safety check
  if (shouldConfirm(scope, targets)) {
    const confirmed = await confirmClean(targets);
    if (!confirmed) return "Clean cancelled.";
  }

  // 4. Perform clean
  const results = await removeTargets(targets);

  // 5. Report
  return generateCleanReport(results);
}
```

---

## Clean Targets Details

### State Files (.omc/state/)
```
autopilot-state.json       - Current pipeline state
ultrapilot-state.json      - Parallel pipeline state
pipeline-state.json        - Custom pipeline state
agent-sessions.json        - Agent conversation cache
notepad-*.json             - Temporary notes
```
**Impact**: Cannot resume pipelines, start fresh
**Recommended**: Clean after successful deployment

### Cache (.omc/cache/)
```
agent-responses/           - Cached agent outputs
figma-cache/              - Cached Figma data
mcp-cache/                - MCP server cache
```
**Impact**: Re-fetch data on next run (slower)
**Recommended**: Clean if stale or taking too much space

### Build Artifacts
```
node_modules/.cache/      - Build cache
.next/                    - Next.js build output
__pycache__/              - Python bytecode
.pytest_cache/            - Test cache
dist/                     - Build distribution files
```
**Impact**: Rebuild required (slower next build)
**Recommended**: Clean before fresh deployment

### Logs (.omc/logs/)
```
pipeline.log              - Pipeline execution log
agents.log                - Agent activity log
errors.log                - Error log
deployment.log            - Deployment log
```
**Impact**: Lose debugging history
**Recommended**: Clean logs older than 30 days

### Generated Documentation (docs/)
```
design-analysis.md        - Figma analysis output
PRD.md                    - Requirements document
architecture.md           - Architecture design
API.md                    - API documentation
```
**Impact**: Lose generated docs (can regenerate)
**Recommended**: Only clean if starting completely fresh

---

## Safety Features

### Protected Files (Never Cleaned)

```
✗ Cannot clean these:
  - frontend/ (source code)
  - backend/ (source code)
  - tests/ (test files)
  - .git/ (git history)
  - project_brief.md (project config)
  - .claude-plugin/ (plugin definition)
  - mcp.json (MCP servers)
```

### Confirmation Prompts

| Clean Scope | Confirmation Level |
|-------------|-------------------|
| `state` | Simple yes/no |
| `cache` | No confirmation |
| `logs` | No confirmation |
| `docs` | Type filename to confirm |
| `--all` | Type phrase to confirm |
| `--force` | No confirmation (dangerous) |

### Dry Run

```
/clean --dry-run

🔍 Clean Simulation (no actual deletion)

Would remove:
  📁 .omc/state/ (3 files, 24 KB)
  📁 .omc/cache/ (128 files, 45 MB)
  📁 node_modules/.cache/ (234 files, 128 MB)
  📁 .omc/logs/ (5 files, 2 MB)

Total: 370 files, 175 MB

Protected (will NOT remove):
  ✓ frontend/ (23 files)
  ✓ backend/ (12 files)
  ✓ docs/ (4 files)

To execute: /clean --force
```

---

## Clean Strategies

### After Successful Deployment
```
/clean state cache logs

Safe to clean since everything is deployed:
  ✓ State no longer needed (not resuming)
  ✓ Cache can be rebuilt
  ✓ Logs archived
```

### Before Starting Fresh
```
/clean --all

Start completely fresh:
  ✓ Remove all state
  ✓ Clear all cache
  ✓ Delete generated docs
  ✓ Keep source code
```

### Disk Space Recovery
```
/clean cache --logs-older-than 7

Free up space without losing important data:
  ✓ Remove agent cache (45 MB)
  ✓ Remove old logs (2 MB)
  ✓ Keep current state and docs
```

### Debugging Issues
```
/clean cache

Clear cache to force fresh data fetch:
  ✓ May fix stale Figma data
  ✓ May fix MCP connection issues
  ✓ Keep state to resume after
```

---

## Clean Report

```
🧹 Clean Report

Removed:
  ✓ .omc/state/autopilot-state.json (12 KB)
  ✓ .omc/cache/ (45 MB, 128 files)
  ✓ node_modules/.cache/ (128 MB, 234 files)
  ✓ .omc/logs/*.log (2 MB, 5 files)

Total freed: 175 MB

Kept:
  ✓ Source code (frontend/, backend/)
  ✓ Generated docs (docs/)
  ✓ Git history (.git/)

✅ Clean complete!

Next steps:
  - To start fresh: /autopilot
  - To check status: /status
```

---

## Advanced Options

### Time-based Clean
```
/clean logs --older-than 30

Remove logs older than 30 days:
  ✓ Removed 15 log files (8 MB)
  ✓ Kept recent logs (last 30 days)
```

### Size-based Clean
```
/clean cache --larger-than 10MB

Remove cached files larger than 10MB:
  ✓ Removed 3 cache files (45 MB)
  ✓ Kept smaller cache files
```

### Pattern-based Clean
```
/clean --pattern "*.tmp"

Remove files matching pattern:
  ✓ Removed 23 temporary files (1.2 MB)
```

---

## Integration with Other Commands

- `/clean` before `/autopilot` - Fresh start
- `/status` then `/clean state` - Clean after completion
- `/clean --dry-run` before `/clean --all` - Preview changes
- `/clean cache` after Figma design update - Refresh cache

---

## Behavior Rules

1. **Safe by default**: Never remove source code or git history
2. **Confirm destructive actions**: Prompt before removing docs
3. **Reversible when possible**: Suggest backup before --all
4. **Fast**: Complete in <5 seconds for typical clean
5. **Informative**: Show what was removed and space freed

---

## Examples

```
User: "clean"
→ Safe clean: state, cache, old logs

User: "clean everything"
→ Prompt for confirmation, clean all temporary files

User: "clean state"
→ Remove only state files, keep everything else

User: "clean --dry-run"
→ Show what would be deleted without actually deleting

User: "I need to start over"
→ Suggest /clean --all, then /autopilot
```

---

## Recovery

If accidentally cleaned important files:

```
⚠ Accidentally deleted docs/?

Recovery options:
  1. Regenerate from pipeline: /autopilot --resume
  2. Restore from git: git checkout docs/
  3. Restore from state: /restore --from-state

Note: State files cannot be recovered if deleted.
```
