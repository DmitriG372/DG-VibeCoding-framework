# Framework Verification Guide

> How to verify that DG-SuperVibe-Framework components are working correctly.

---

## Quick Verification Checklist

```bash
# 1. Check skills are loaded (in Claude Code)
# Look for framework skills in Skill tool's available_skills

# 2. Check usage tracking
cat .claude/usage.log

# 3. Test a slash command
/sprint-status

# 4. Test a hook (should see output)
# Edit a .ts file → should see type-check feedback
```

---

## Skills Verification

### Problem: Skills not visible

Skills must be in subdirectory format:
```
WRONG:  .claude/skills/testing.md
RIGHT:  .claude/skills/testing/SKILL.md
```

### Solution: Run migration

```bash
chmod +x scripts/migrate-skills.sh
./scripts/migrate-skills.sh
```

### Verify skills loaded

In Claude Code, skills appear in the system when they have:
1. Correct path: `.claude/skills/[name]/SKILL.md`
2. YAML frontmatter with `name` and `description`

```yaml
---
name: testing
description: Testing patterns and strategies
---
```

---

## Slash Commands Verification

### Test a command

```
/sprint-status
```

Should output sprint progress or "No sprint initialized."

### Commands available

| Command | Purpose | Test |
|---------|---------|------|
| `/sprint-init` | Initialize sprint | Creates `sprint/` |
| `/feature` | Start feature | Requires sprint |
| `/done` | Complete feature | Requires active feature |
| `/orchestrate` | Complex tasks | Any task |
| `/plan` | Planning mode | Any task |

---

## Hooks Verification

### Test block-env hook

```bash
# Should be blocked
echo '{"tool_name":"Read","tool_input":{"file_path":".env"}}' | node ./hooks/block-env.js
echo "Exit code: $?"  # Should be 2
```

### Test type-check hook

```bash
# Edit any .ts file in Claude Code
# Should see either:
# ✅ TypeScript: No errors
# OR
# ⚠️ TypeScript errors detected...
```

### Test usage-tracker hook

```bash
# After using any skill or command, check:
cat .claude/usage.log

# Should show entries like:
# 2025-12-13T10:00:00.000Z | COMMAND: /sprint-status
# 2025-12-13T10:01:00.000Z | SKILL: testing
```

---

## Agents Verification

### Important: Agents are documentation

The `agents/` folder contains **role definitions**, not automatic triggers.

Agents are invoked via:
1. **Slash commands** — `/orchestrate`, `/plan`, etc.
2. **Claude's judgment** — Based on task complexity
3. **Explicit request** — "Use the tester agent"

### Test orchestration

```
/orchestrate "Add user authentication"
```

Should output:
- Complexity assessment
- Agent team selection
- Execution plan

---

## Framework Installation Check

### In a new project

```bash
# Copy framework to project
cp -r DG-VibeCoding-framework/.claude ./my-project/
cp -r DG-VibeCoding-framework/hooks ./my-project/

# Migrate skills to correct format
cd my-project
chmod +x ../DG-VibeCoding-framework/scripts/migrate-skills.sh
../DG-VibeCoding-framework/scripts/migrate-skills.sh

# Verify
ls -la .claude/skills/*/SKILL.md
```

---

## Test Results (2025-12-13)

### /orchestrate Test

**Input:** `/orchestrate Add user authentication`

**Result:** ✅ SUCCESS

```
1. Loaded agents/orchestrator.md ✓
2. Analyzed complexity: HIGH ✓
3. Selected agents: architect → database → backend → frontend → security → tester ✓
4. Created execution plan with phases ✓
5. Identified parallel opportunities ✓
6. Recommended reasoning mode: "Think a lot" ✓
```

### /plan Test

**Input:** `/plan Add email validation`

**Result:** ✅ SUCCESS

```
1. Loaded agents/planner.md ✓
2. Defined goal and current state ✓
3. Created 4 implementation steps with acceptance criteria ✓
4. Identified risks and mitigations ✓
5. Suggested skills to load ✓
6. Waited for approval (didn't auto-implement) ✓
```

### Agent Loading Verification

| Command | Loads Agent | Status |
|---------|-------------|--------|
| `/orchestrate` | orchestrator.md | ✅ Works |
| `/plan` | planner.md | ✅ Works |
| `/review` | reviewer.md | ✅ Configured |
| `/done` | tester.md | ✅ Configured |

---

## Troubleshooting

### Skills not showing

1. Check file format (must be `SKILL.md` in subdirectory)
2. Check YAML frontmatter has `name` and `description`
3. Restart Claude Code

### Hooks not running

1. Check `.claude/settings.local.json` syntax
2. Check hook script has `#!/usr/bin/env node`
3. Check hook script is in correct path
4. Restart Claude Code

### Commands not found

1. Check `.claude/commands/` contains `.md` files
2. Check each file has YAML frontmatter with `description`
3. Restart Claude Code

### Usage log empty

1. Verify usage-tracker hook is configured
2. Check `.claude/` directory is writable
3. Actually use a skill or command first

---

## Debug Mode

Add verbose logging to any hook:

```javascript
// At start of hook
console.error(`[DEBUG] Hook started: ${process.argv[1]}`);
console.error(`[DEBUG] Input: ${input}`);
```

Then check Claude Code's tool feedback for debug output.

---

*Part of DG-SuperVibe-Framework v2.4*
