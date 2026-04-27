---
description: Show sprint status, branch overview, and merge readiness
allowed-tools:
  - Bash
  - Read
  - Glob
---

# /sprint-status

Show current sprint status, active branches, and merge readiness. This is a **read-only** command — it does not modify any files.

> Replaces the old `/sync-tasks` command. Uses `sprint/sprint.json` as the single source of sprint state.

## Usage

```
/sprint-status
```

## Your Task

Execute all steps in order. Do not modify any files.

### Step 1: Load Sprint State

```
Read: sprint/sprint.json
```

If `sprint/sprint.json` doesn't exist:
```
ℹ️ No sprint found. Run /sprint-init to create one.
```
Stop here.

### Step 2: Load Project Context

```
Read: PROJECT.md
```

Note project name, stack, and conventions for context.

### Step 3: Check Git State

```bash
# Current branch and status
git branch --show-current
git status --short

# All branches (local)
git branch --list

# Recent commits across all branches
git log --all -15 --pretty="[%h] %ad (%an) %s" --date=short

# Check for worktrees
git worktree list
```

### Step 4: Analyze Feature Branches

For each feature in sprint.json with `status: "in_progress"`:

```bash
# Check if feature branch exists
git branch --list "<feature.branch>"

# Count commits ahead of main
git rev-list --count main..<feature.branch> 2>/dev/null || echo "0"

# Check merge status (can it merge cleanly?)
git merge-tree $(git merge-base main <feature.branch>) main <feature.branch> 2>/dev/null
```

For each feature with `status: "completed"` (or legacy `status: "done"`):

```bash
# Check if branch was merged
git branch --merged main | grep "<feature.branch>" 2>/dev/null
```

### Step 5: Display Sprint Status

```markdown
## Sprint Status

**Sprint:** <sprint.meta.id> — <sprint.meta.goal>
**Created:** <sprint.meta.created>
**Last updated by:** <sprint.last_updated_by>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sprint Progress: [████████░░░░░░░░░░░░] 40% (2/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Features

| ID | Name | Status | Branch | Commits Ahead | Merge Ready |
|----|------|--------|--------|---------------|-------------|
| F001 | User auth | completed | cc/F001-user-auth | — | merged |
| F002 | Product catalog | completed | cx/F002-product-catalog | — | merged |
| F003 | Shopping cart | in_progress | cc/F003-shopping-cart | 5 | yes |
| F004 | Checkout flow | pending | — | — | — |
| F005 | Order history | pending | — | — | — |

### Active Branches

| Branch | Feature | Last Commit | Status |
|--------|---------|-------------|--------|
| cc/F003-shopping-cart | F003 | 2h ago | 5 commits ahead, clean merge |

### Worktrees

| Path | Branch | Feature |
|------|--------|---------|
| /path/to/worktree | cx/F004-checkout-flow | F004 |

(Or: "No active worktrees.")

### Warnings

- ⚠️ cc/F003-shopping-cart has potential merge conflicts with main
- ⚠️ F003 has been in_progress for 3 days

### Current Feature

**F003 — Shopping cart** (in_progress)
Assigned to: <feature.assigned_to or "unassigned">
```

Adapt the output to actual data. Omit sections that have no data (e.g., skip Worktrees section if none exist, skip Warnings if none).

### Progress Bar Calculation

```
completed = features with status "completed" (treat legacy `"done"` as completed)
total = all features
percentage = (completed / total) * 100
bar_filled = round(percentage / 5)  # 20 chars total
bar_empty = 20 - bar_filled
```

## Rules

- **Read-only** — does not modify any files
- Always read sprint/sprint.json first
- Show all features regardless of status
- Warn about potential merge conflicts
- Warn about features in_progress for more than 2 days
- Show who last updated sprint.json

## Output

- Sprint progress overview with feature table
- Branch and merge status
- Worktree status
- Actionable warnings
- Current feature highlight

---

*DG-VibeCoding-Framework — Sprint Coordination*
