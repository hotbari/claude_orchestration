# Validate Command

**Purpose**: Validate project setup and configuration

**Trigger**: User says "validate", "check setup", or "is everything configured correctly"

---

## What This Command Does

Comprehensive validation of:
- Project structure and required files
- MCP server connectivity
- Figma access and permissions
- Git repository status
- Dependencies and tool versions
- Environment variables
- Plugin configuration

---

## Usage

```
/validate

# Validate specific component
/validate figma
/validate mcp
/validate git
/validate deps

# Quick check (essential only)
/validate --quick

# Detailed validation with fixes
/validate --fix

# JSON output
/validate --json
```

---

## Validation Report

### All Pass

```
✅ Project Validation

📁 Project Structure
  ✓ project_brief.md exists
  ✓ .claude-plugin/plugin.json valid
  ✓ skills/ directory (8 skills found)
  ✓ agents/ directory (2 agents found)
  ✓ commands/ directory (6 commands found)

🔌 MCP Servers
  ✓ mcp.json exists and valid
  ✓ figma-mcp server: Connected
  ✓ context7-mcp server: Connected

🎨 Figma Access
  ✓ Figma URL in project_brief.md
  ✓ Figma file accessible
  ✓ Design has 45 components
  ✓ Last updated: 2 hours ago

📦 Git Repository
  ✓ Git initialized
  ✓ Remote configured (origin)
  ✓ Working tree clean
  ✓ On branch: main

🔧 Dependencies
  ✓ Node.js: v20.10.0
  ✓ npm: v10.2.3
  ✓ Python: v3.11.5
  ✓ pip: v23.3.1

🔐 Environment
  ✓ Required env vars present (3/3)
  ✓ No secrets in git

✅ All checks passed! Ready to run /autopilot
```

### With Issues

```
⚠️  Project Validation - Issues Found

📁 Project Structure
  ✓ project_brief.md exists
  ✗ Figma URL missing in project_brief.md
  ✓ .claude-plugin/plugin.json valid
  ⚠ docs/ directory missing (will be created)

🔌 MCP Servers
  ✓ mcp.json exists
  ✗ figma-mcp server: Not connected
    → Run: claude mcp install @anthropic-ai/figma-mcp
  ✓ context7-mcp server: Connected

🎨 Figma Access
  ✗ Cannot validate - Figma URL missing
    → Add URL to project_brief.md

📦 Git Repository
  ✓ Git initialized
  ⚠ 5 uncommitted changes
    → Run: git status

🔧 Dependencies
  ✓ Node.js: v20.10.0
  ✗ Python not found
    → Install: https://python.org

⚠️  Found 4 issues. Run /validate --fix to auto-fix.
```

---

## Implementation Logic

```javascript
async function validateProject(args) {
  const results = {
    structure: await validateStructure(),
    mcp: await validateMCP(),
    figma: await validateFigma(),
    git: await validateGit(),
    deps: await validateDependencies(),
    env: await validateEnvironment()
  };

  // Compute overall status
  const passed = Object.values(results).every(r => r.passed);

  // Generate report
  const report = formatValidationReport(results);

  // Offer fixes if issues found
  if (!passed && args.fix) {
    await autoFixIssues(results);
  }

  return report;
}
```

---

## Validation Checks

### 1. Project Structure

| Check | Required | Auto-Fix |
|-------|----------|----------|
| project_brief.md exists | Yes | Create template |
| Figma URL in brief | Yes | Prompt user |
| .claude-plugin/plugin.json | Yes | No |
| skills/ directory | Yes | No |
| agents/ directory | Yes | No |
| commands/ directory | No | Create if missing |
| docs/ directory | No | Create on first run |

### 2. MCP Servers

| Check | Required | Auto-Fix |
|-------|----------|----------|
| mcp.json exists | Yes | Create template |
| figma-mcp configured | Yes | Add config |
| figma-mcp connected | Yes | Install MCP |
| context7-mcp connected | No | Suggest install |
| MCP server versions | No | Check for updates |

### 3. Figma Access

| Check | Required | Auto-Fix |
|-------|----------|----------|
| Figma URL provided | Yes | Prompt user |
| Figma file accessible | Yes | Check credentials |
| Design not empty | Yes | No |
| Read permissions | Yes | No |
| Recent changes (< 30 days) | No | Warn if stale |

### 4. Git Repository

| Check | Required | Auto-Fix |
|-------|----------|----------|
| Git initialized | Yes | git init |
| Remote configured | No | Suggest setup |
| Working tree status | No | Report only |
| .gitignore exists | No | Create template |
| No secrets committed | Yes | Warn and suggest removal |

### 5. Dependencies

| Check | Required | Auto-Fix |
|-------|----------|----------|
| Node.js >= 18 | Yes | Install guide |
| npm >= 9 | Yes | npm update -g |
| Python >= 3.10 | Yes (for backend) | Install guide |
| pip >= 23 | Yes (for backend) | python -m pip install --upgrade pip |
| Git >= 2.30 | Yes | Install guide |

### 6. Environment Variables

| Check | Required | Auto-Fix |
|-------|----------|----------|
| .env.example exists | No | Create template |
| Required vars present | No | List missing |
| No secrets in .env committed | Yes | Warn |
| .env in .gitignore | Yes | Add to .gitignore |

---

## Auto-Fix Mode

```
/validate --fix

🔧 Auto-Fixing Issues...

✓ Created docs/ directory
✓ Created .gitignore with common patterns
✓ Added figma-mcp to mcp.json
⚙ Installing figma-mcp server...
  ✓ figma-mcp installed

⚠ Manual action required:
  1. Add Figma URL to project_brief.md
     Format: https://figma.com/file/FILE_ID/TITLE

  2. Install Python 3.11+
     Download: https://python.org

Run /validate again after completing manual steps.
```

---

## Component-Specific Validation

### Figma Only

```
/validate figma

🎨 Figma Validation

Connection:
  ✓ MCP server connected
  ✓ Figma file accessible
  ✓ File ID: ABC123

Design Analysis:
  ✓ 45 components found
  ✓ 12 pages
  ✓ 8 color styles
  ✓ 15 text styles

Structure:
  ✓ Has frames (23)
  ✓ Has components (45)
  ✓ Organized in pages

Readiness:
  ✓ Design is production-ready
  ✓ No naming conflicts
  ✓ All assets exportable

✅ Figma setup valid
```

### MCP Only

```
/validate mcp

🔌 MCP Server Validation

Installed Servers:
  ✓ figma-mcp v2.1.0 - Connected
  ✓ context7-mcp v1.5.0 - Connected
  ✗ postgres-mcp - Not installed (optional)

Configuration:
  ✓ mcp.json valid syntax
  ✓ Server paths correct
  ✓ No conflicting ports

Health Checks:
  ✓ figma-mcp: 45ms response
  ✓ context7-mcp: 23ms response

✅ MCP setup functional
```

### Dependencies Only

```
/validate deps

🔧 Dependency Validation

System:
  ✓ Node.js v20.10.0 (LTS)
  ✓ npm v10.2.3
  ✓ Python v3.11.5
  ✓ pip v23.3.1
  ✓ Git v2.42.0

Frontend (package.json):
  ✓ next v14.0.4
  ✓ react v18.2.0
  ✓ typescript v5.3.3
  ⚠ 3 packages have updates available
    → Run: npm outdated

Backend (requirements.txt):
  ✓ fastapi v0.108.0
  ✓ uvicorn v0.25.0
  ✓ sqlalchemy v2.0.23
  ⚠ 2 packages have updates available
    → Run: pip list --outdated

✅ Dependencies valid
```

---

## Validation Levels

### Quick (Essential Only)

```
/validate --quick

⚡ Quick Validation (5 checks)

✓ project_brief.md exists
✓ Figma MCP connected
✓ Figma URL accessible
✓ Git initialized
✓ Node.js installed

✅ Essential checks passed
```

### Standard (Default)

- All structure checks
- MCP connectivity
- Figma access
- Git status
- Core dependencies

### Thorough (--verbose)

- All standard checks
- Detailed Figma analysis
- All dependency versions
- Environment variable audit
- Security checks
- Performance hints

---

## JSON Output

```json
/validate --json

{
  "status": "warning",
  "passed": 14,
  "warnings": 3,
  "errors": 1,
  "checks": {
    "structure": {
      "status": "pass",
      "checks": [...]
    },
    "mcp": {
      "status": "error",
      "message": "figma-mcp not connected",
      "fix": "claude mcp install @anthropic-ai/figma-mcp"
    },
    ...
  },
  "recommendations": [
    "Install figma-mcp server",
    "Add Figma URL to project_brief.md",
    "Commit current changes"
  ]
}
```

---

## Integration with Other Commands

- Run `/validate` before `/autopilot` - Ensure setup correct
- `/validate --fix` then `/autopilot` - Auto-fix and start
- `/status` vs `/validate` - Status shows progress, validate shows setup
- `/validate figma` after design changes - Verify new design

---

## Error Messages with Guidance

### Missing Figma URL

```
✗ Figma URL missing

📝 To fix:
  1. Open project_brief.md
  2. Add your Figma URL:
     ## Figma URL
     https://www.figma.com/file/ABC123/My-Design
  3. Run /validate again

Need a Figma file? Share a design link with "can view" access.
```

### MCP Not Connected

```
✗ figma-mcp server not connected

🔧 To fix:
  1. Install figma-mcp:
     claude mcp install @anthropic-ai/figma-mcp

  2. Restart Claude Code

  3. Run /validate again

📚 More info: https://docs.anthropic.com/mcp
```

---

## Behavior Rules

1. **Non-destructive**: Never modify files without --fix flag
2. **Informative**: Always explain what's wrong and how to fix
3. **Fast**: Complete in <10 seconds
4. **Actionable**: Provide specific commands to fix issues
5. **Progressive**: Allow partial validation (--quick, specific components)

---

## Success Criteria

Validation passes when:
- All required files exist
- MCP servers connected
- Figma file accessible
- Git repository initialized
- Core dependencies installed
- No secrets committed to git

---

## Examples

```
User: "validate"
→ Run full validation, show report

User: "is everything set up correctly?"
→ Auto-detect as validation check

User: "validate --fix"
→ Run validation and auto-fix issues

User: "validate figma"
→ Check only Figma configuration

User: "validate --json | jq .status"
→ Machine-readable output for scripts
```
