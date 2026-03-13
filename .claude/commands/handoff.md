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

Hand off a feature to the partner agent for implementation. Either agent can hand off to the other.

> **Philosophy:** CC and CX are equal partners. Use `/handoff` to delegate features that suit the partner's strengths.

## Usage

```
/handoff <F-ID or feature description>
/handoff F003
/handoff "Implement CRUD endpoints for products API"
/handoff "Add unit tests for all service files"
```

## Instructions

### Step 0: Detect Agent Identity

Determine which agent you are:
- If context loaded from CLAUDE.md → agent = "cc"
- If context loaded from AGENTS.md → agent = "cx"
- Fallback: ask user

Store as `$AGENT_ID`. Determine target agent:
- If `$AGENT_ID == "cc"` → `$TARGET_AGENT = "cx"`
- If `$AGENT_ID == "cx"` → `$TARGET_AGENT = "cc"`

### Step 1: Read Context

```
Read: PROJECT.md
Read: sprint/sprint.json
```

If `sprint/sprint.json` doesn't exist, prompt: "Run /sprint-init first."

### Step 2: Analyze and Validate

Determine if the task is suitable for the target agent:

| Good for partner | Not for partner |
|-----------------|----------------|
| Bulk implementation | Interactive design |
| Test generation | Architecture decisions |
| Migration/refactor | Ambiguous requirements |
| Documentation | Debugging unknown issues |
| Pattern-based coding | User-facing prototyping |

If NOT suitable, explain why and suggest keeping it for the current agent.

### Step 3: Feature Selection

Interpret `$ARGUMENTS`:

**Case A: F-ID provided** (e.g., `F003`)
- Find the feature in sprint.json
- Verify it is `pending` or reassignable (not `done`)

**Case B: Description provided** (e.g., `"Add unit tests for all service files"`)
- Create a NEW feature entry in sprint.json
- Auto-generate the next sequential F-ID
- Parse description into feature fields:
  - `name`: Short English slug
  - `description`: Full description from arguments
  - `acceptance_criteria`: Generate 2-4 testable criteria based on description
  - `complexity`: Estimate from description scope
  - `status`: `"pending"`
- Add the new feature to the `features` array
- Update `stats.total` and `stats.pending`

### Step 4: Assign to Target Agent

Update the feature in sprint.json:
- Set `assigned_to: "$TARGET_AGENT"`
- Generate branch name: `$TARGET_AGENT/<feature-id>-<slug>` (e.g., `cx/F003-crud-endpoints`)
- Set `feature.branch: "<branch-name>"`
- Set `last_updated_by: "$AGENT_ID"`
- Set `last_updated` to current ISO timestamp
- Update stats

### Step 5: Branch/Worktree Setup

Read `branch_strategy` from sprint.json:

**If `branch_strategy == "main"`:**
```bash
BRANCH="$TARGET_AGENT/<feature-id>-<slug>"
git branch "$BRANCH" 2>/dev/null || true
```
Create the branch but do NOT switch to it (the target agent will check it out).

**If `branch_strategy == "worktree"`:**
```bash
PROJECT_NAME=$(basename "$(pwd)")
BRANCH="$TARGET_AGENT/<feature-id>-<slug>"
WT_DIR="../${PROJECT_NAME}-wt-${BRANCH//\//-}"
git worktree add "$WT_DIR" -b "$BRANCH" 2>/dev/null || git worktree add "$WT_DIR" "$BRANCH"
```

### Step 6: Update sprint.json

Write the updated sprint.json with all changes from Steps 3-5.

### Step 7: Show Handoff Summary

Display the handoff result and launch instructions for the target agent.

## Output Format

```
╔══════════════════════════════════════════════════╗
║  Handoff: F003 -> $TARGET_AGENT                  ║
╚══════════════════════════════════════════════════╝

From: $AGENT_ID
To:   $TARGET_AGENT

Feature: F003 - CRUD endpoints
Branch:  cx/F003-crud-endpoints
Strategy: main

Acceptance Criteria:
  - GET /products returns paginated list
  - POST /products creates new product
  - PUT /products/:id updates product
  - DELETE /products/:id removes product

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Start $TARGET_AGENT:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Launch Instructions by Strategy

**main strategy:**
```
# If target is CX:
cd <project-root>
codex --full-auto

# If target is CC:
cd <project-root>
claude
```

**worktree strategy:**
```
# If target is CX:
cd ../<project>-wt-cx-F003-crud-endpoints/
codex --full-auto

# If target is CC:
cd ../<project>-wt-cc-F003-feature-name/
claude
```

### After Partner Completes

```
# Review partner's work
/peer-review $TARGET_AGENT/<feature-id>-<slug>

# Check sprint status
cat sprint/sprint.json
```

## Rules

- ALWAYS read PROJECT.md first
- ALWAYS update sprint.json with the handoff
- NEVER assign ambiguous tasks -- clarify first
- NEVER hand off tasks that require user interaction
- ALWAYS create a branch for the target agent
- Feature descriptions can create NEW features dynamically
- Agent identity is symmetric: either agent can hand off to the other

## Input

$ARGUMENTS -- Feature ID (e.g., F003) or feature description for the target agent

## Output

- Updated sprint/sprint.json
- New branch (and worktree if applicable)
- Target agent launch instructions

---

*Part of DG-VibeCoding-Framework v5.0.0 -- Equal Partnership*
