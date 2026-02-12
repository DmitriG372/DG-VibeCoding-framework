---
description: Hand off a task to CX (Codex) partner
context: fork
allowed-tools:
  - Bash
  - Read
  - Glob
  - Write
  - Edit
---

# /handoff

Hand off a task to CX (Codex) for autonomous implementation in a separate worktree.

> **Philosophy:** CC and CX are equal partners. Use `/handoff` to delegate tasks that suit CX's strengths (volume, repetitive, autonomous).

## Usage

```
/handoff <task description>
/handoff "Implement CRUD endpoints for products API"
/handoff "Add unit tests for all service files"
/handoff "Migrate CSS modules to Tailwind"
```

## Your Task

### Step 1: Read Context

```
Read: PROJECT.md
Read: .tasks/board.md (create if missing)
```

### Step 2: Analyze Task

Determine if the task is suitable for CX:

| Good for CX | Not for CX |
|-------------|-----------|
| Bulk implementation | Interactive design |
| Test generation | Architecture decisions |
| Migration/refactor | Ambiguous requirements |
| Documentation | Debugging unknown issues |
| Pattern-based coding | User-facing prototyping |

If NOT suitable for CX, explain why and suggest keeping it for CC.

### Step 3: Generate Task Entry

Create a TASK-ID (increment from last in board.md):

```markdown
- [ ] [TASK-XXX] $ARGUMENTS — assigned: CX — branch: cx/<slug>
```

### Step 4: Update Task Board

Add the task to `.tasks/board.md` under "Assigned to: CX" section.

If `.tasks/board.md` doesn't exist, create it from template:

```markdown
# Task Board

> Shared between CC (Claude Code) and CX (Codex). Update after completing tasks.

## Backlog

## Assigned to: CC

## Assigned to: CX
- [ ] [TASK-001] $ARGUMENTS — branch: cx/<slug>

## In Review

## Completed
```

### Step 5: Create Branch and Worktree

Generate a slug from the task description (lowercase, hyphens, max 30 chars):

```bash
# Create worktree
PROJECT_NAME=$(basename "$(pwd)")
BRANCH="cx/<slug>"
scripts/worktree-setup.sh "$BRANCH"
```

If `scripts/worktree-setup.sh` doesn't exist, run manually:

```bash
BRANCH="cx/<slug>"
PROJECT_NAME=$(basename "$(pwd)")
WT_DIR="../${PROJECT_NAME}-wt-${BRANCH}"
git worktree add "$WT_DIR" -b "$BRANCH" 2>/dev/null || git worktree add "$WT_DIR" "$BRANCH"
```

### Step 6: Output Summary

```markdown
## Handoff Complete

**Task:** [TASK-XXX] $ARGUMENTS
**Branch:** cx/<slug>
**Worktree:** ../<project>-wt-cx-<slug>/

### Start CX

```bash
cd ../<project>-wt-cx-<slug>/
codex --full-auto
```

### After CX Completes

```bash
# Review CX's work
/peer-review cx/<slug>

# Check task status
/sync-tasks
```
```

## Rules

- ALWAYS read PROJECT.md first
- ALWAYS update .tasks/board.md
- NEVER assign ambiguous tasks to CX — clarify first
- NEVER hand off tasks that require user interaction
- ALWAYS create a separate branch for CX

## Input

$ARGUMENTS — Task description for CX

## Output

- Updated .tasks/board.md
- New branch and worktree
- CX launch instructions

---

*DG-VibeCoding-Framework v4.0.0 — Equal Partnership*
