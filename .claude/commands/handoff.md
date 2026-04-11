---
description: Hand off a feature to the partner agent
context: fork
allowed-tools:
  - Bash
  - Read
  - Glob
  - Write
  - Edit
---

# /handoff

Hand off a feature to the partner agent (CC ↔ CX).

> Handoff protocol details (CC→CX, CX→CC, launch variants) live in `.claude/skills/partnership/references/handoff-protocol.md`. Routing matrix lives in `.claude/skills/partnership/SKILL.md`.

## Usage

```
/handoff <F-ID | feature description>
```

Examples:
```
/handoff F003
/handoff "Implement CRUD endpoints for products API"
/handoff "Add unit tests for all service files"
```

## Instructions

### Step 1: Detect agent identity + target
- `CLAUDE.md` → `$AGENT_ID="cc"`, `$TARGET="cx"`
- `AGENTS.md` → `$AGENT_ID="cx"`, `$TARGET="cc"`

### Step 2: Read context
Read `PROJECT.md` and `sprint/sprint.json`. If sprint.json is missing → prompt `/sprint-init` first.

### Step 3: Validate suitability
Consult the partnership routing matrix in `.claude/skills/partnership/SKILL.md`. Reject ambiguous tasks, user-facing prototyping, or anything needing live interaction.

### Step 4: Resolve feature
**F-ID given** → find in sprint.json, verify status is `pending` or reassignable.

**Description given** → create new feature entry:
- Auto-assign next sequential F-ID
- `name`: short English slug
- `description`: full text from arguments
- `acceptance_criteria`: 2–4 testable criteria derived from description
- `complexity`: estimate from scope
- `status`: `"pending"`
- Update `stats.total`, `stats.pending`

### Step 5: Assign + branch
Update the feature:
- `assigned_to: "$TARGET"`
- `branch: "$TARGET/<id>-<slug>"`
- `last_updated_by: "$AGENT_ID"`
- `last_updated`: ISO timestamp

Create the branch per `branch_strategy`:

**`branch_strategy: "main"`**
```bash
git branch "$TARGET/<id>-<slug>" 2>/dev/null || true
```

**`branch_strategy: "worktree"`**
```bash
PROJECT=$(basename "$(pwd)")
BR="$TARGET/<id>-<slug>"
git worktree add "../${PROJECT}-wt-${BR//\//-}" -b "$BR" 2>/dev/null \
  || git worktree add "../${PROJECT}-wt-${BR//\//-}" "$BR"
```

### Step 6: Write sprint.json (atomic)

### Step 7: Show handoff summary
```
Handoff: F<ID> → $TARGET
Feature: <name>
Branch:  $TARGET/<id>-<slug>
Strategy: main | worktree

Acceptance:
  - <criterion 1>
  - <criterion 2>

Launch $TARGET:
  cd <path>  &&  <codex --full-auto | claude>
```

For worktree strategy, `<path>` is `../<project>-wt-<target>-<id>-<slug>/`. For main, it's the project root.

## Rules

- Always read PROJECT.md first
- Always update sprint.json with the handoff (atomic write)
- Never assign ambiguous tasks — clarify first
- Never hand off tasks needing user interaction
- Always create a branch for the target agent
- Agent identity is symmetric — either side can hand off

## Input / Output

- **Input:** `$ARGUMENTS` — F-ID or feature description
- **Output:** Updated `sprint/sprint.json`, new branch (or worktree), launch instructions for target agent
