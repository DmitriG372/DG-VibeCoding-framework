---
description: Manually refresh project context (rules, sprint, git state)
allowed-tools:
  - Read
  - Bash
  - Glob
---

# /context-refresh

Manually reload project context when automatic recovery is insufficient.

## Usage

```
/context-refresh
```

## Your Task

Execute all steps in order. This is a **read-only** command — do not modify any files.

### Step 1: Load Project Rules (MANDATORY)

```
Read: PROJECT.md
```

Internalize all sections: Rules, Patterns, Stack, Commands, Conventions.
This is the SINGLE SOURCE OF TRUTH for project configuration.

If `PROJECT.md` doesn't exist:
```
⚠️ No PROJECT.md found. This project may not use DG-VibeCoding-Framework.
```

### Step 2: Load Sprint State

```
Read: sprint/sprint.json
```

Note active features, assignments, current feature, and sprint progress.

If `sprint/sprint.json` doesn't exist:
```
ℹ️ No sprint found. Skipping sprint state.
```

### Step 3: Review Git State

```bash
git branch --show-current
git status --short
git log -10 --pretty="[%h] %ad %s" --date=short
```

### Step 4: Check Context Snapshot

```
Read: .claude/context-snapshot.json
```

If exists, compare snapshot timestamp with current state.
If missing, note that no pre-compaction snapshot is available.

### Step 5: Display Recovery Report

```markdown
## Context Refresh Report

### Project Rules
- Loaded from: PROJECT.md ✅ / ❌
- Key rules: [list top 3-5 rules]
- Patterns: [list active patterns]

### Sprint State
- Sprint: sprint/sprint.json ✅ / ❌
- Current feature: [feature or none]
- Progress: X/Y completed
- In progress: [count]

### Git State
- Branch: [current branch]
- Uncommitted: [count] files
- Recent activity: [summary]

### Snapshot State
- Snapshot: .claude/context-snapshot.json ✅ / ❌
- Age: [timestamp or N/A]

### Status
✅ Context fully loaded / ⚠️ Partial context (see missing items above)
```

## Rules

- **Read-only** — does not modify any files
- Always read PROJECT.md first (single source of truth)
- sprint/sprint.json contains ONLY sprint state, never rules
- Report what was loaded and what was missing

## Output

- Context recovery report with status indicators
- Clear indication of what was successfully loaded
- Warnings for any missing context sources

---

*DG-VibeCoding-Framework v5.0.0 — Context Robustness*
