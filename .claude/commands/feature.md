---
description: "Start working on the next feature in the sprint cycle."
---

# Command: /feature

Start working on the next feature in the sprint cycle. Assigns the feature to the current agent and creates a feature branch.

## Usage

```
/feature [feature-id]
```

## Instructions

### Step 0: Detect Agent Identity

Determine which agent you are:
- If context loaded from CLAUDE.md → agent = "cc"
- If context loaded from AGENTS.md → agent = "cx"
- Fallback: ask user

Store as `$AGENT_ID` for branch naming and sprint.json updates.

### Step 1: Read Sprint State

1. **Read sprint/sprint.json**
   - If file doesn't exist, prompt: "Run /sprint-init first"

### Step 2: Select Feature

- If `feature-id` provided: select that specific feature
- If not provided: select first feature with `status: "pending"`
- If no pending features: "All features completed! Run /sprint-init for new sprint."

### Step 3: Update sprint.json

- Set selected feature `status: "in_progress"`
- Set `assigned_to: "$AGENT_ID"`
- Set `current_feature: "<feature-id>"`
- Generate branch name: `$AGENT_ID/<feature-id>-<slug>` (e.g., `cc/F001-user-auth`)
- Set `feature.branch: "<branch-name>"`
- Set `last_updated_by: "$AGENT_ID"`
- Set `last_updated` to current ISO timestamp
- Update stats

### Step 4: Create Feature Branch

1. Read `branch_strategy` and `base_branch` from sprint.json
2. **If `branch_strategy == "main"`:**
   ```bash
   git checkout -b $AGENT_ID/<feature-id>-<slug>
   ```
3. **If `branch_strategy == "worktree"` and agent is NOT the sprint initiator:**
   ```bash
   PROJECT_NAME=$(basename "$(pwd)")
   BRANCH="$AGENT_ID/<feature-id>-<slug>"
   WT_DIR="../${PROJECT_NAME}-wt-${BRANCH//\//-}"
   git worktree add "$WT_DIR" -b "$BRANCH" 2>/dev/null || git worktree add "$WT_DIR" "$BRANCH"
   ```
   Report the worktree path to the user.
4. **If `branch_strategy == "worktree"` and agent IS the sprint initiator:**
   - Stay in the main repo, create a regular branch:
   ```bash
   git checkout -b $AGENT_ID/<feature-id>-<slug>
   ```

### Step 5: Display Feature Details

- Show name, description, acceptance criteria
- Show branch name and assigned agent
- Show suggested agent flow based on complexity

### Step 6: Activate Appropriate Agents

- Complex feature (`high`): planner -> architect -> implementer
- Simple feature (`low`): implementer directly
- Medium feature: implementer -> tester

## Output Format

```
╔══════════════════════════════════════════════════╗
║  Feature Started: F001                           ║
╚══════════════════════════════════════════════════╝

Agent: cc
Branch: cc/F001-user-auth

Name: User authentication
Description: Email/password login with JWT

Acceptance Criteria:
  - User can register with email
  - User can login
  - JWT token is returned

Agent Flow: planner -> implementer -> tester

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
When implementation is complete and tested:
  -> Use /done to commit and mark as completed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

### One Feature at a Time (per agent)
- Cannot start new feature if `current_feature` is set for this agent
- Must complete current feature with `/done` first
- Exception: `/feature --force` to switch (marks current as pending, clears assignment)

### Recovery After Compaction
If context is lost mid-feature:
1. `/feature` reads `current_feature` from sprint.json
2. Checks if current feature is assigned to `$AGENT_ID`
3. Resumes work on that feature
4. Shows: "Resuming F001: User authentication (assigned to: cc)"

### Agent Integration

When feature starts, auto-detect agent needs:

| Feature Keywords | Agents to Activate |
|-----------------|-------------------|
| auth, login, user | security-specialist, backend-specialist |
| UI, component, page | frontend-specialist |
| API, endpoint | backend-specialist |
| database, schema | database-specialist |
| test, coverage | tester |

## Examples

### Start next pending feature
```
/feature

-> Feature Started: F001 - User authentication
   Agent: cc | Branch: cc/F001-user-auth
```

### Start specific feature
```
/feature F003

-> Feature Started: F003 - Shopping cart
   Agent: cx | Branch: cx/F003-shopping-cart
```

### Resume after break
```
/feature

-> Resuming F002: Product catalog (in_progress, assigned to: cc)
   Branch: cc/F002-product-catalog
```

### All done
```
/feature

-> All features completed!
   Sprint progress: 5/5 (100%)
   Run /sprint-init to start a new sprint.
```

---

*Part of DG-VibeCoding-Framework v5.0.0*
