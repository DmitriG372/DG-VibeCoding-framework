---
description: Show task board status and CX branch overview
allowed-tools:
  - Bash
  - Read
  - Glob
---

# /sync-tasks

Show the current task board status, CX branches, and worktree state.

## Usage

```
/sync-tasks
```

## Your Task

### Step 1: Read Task Board

```
Read: .tasks/board.md
```

If `.tasks/board.md` doesn't exist:
```
No task board found. Create one with /handoff or manually at .tasks/board.md
```

### Step 2: Check Git State

```bash
# List worktrees
git worktree list

# List CX branches
git branch -a | grep cx/

# Recent CX commits
for branch in $(git branch --list 'cx/*' | tr -d ' '); do
  echo "--- $branch ---"
  git log "$branch" --oneline -3
done
```

### Step 3: Check for Conflicts

```bash
# Check if CX branches can merge cleanly
for branch in $(git branch --list 'cx/*' | tr -d ' '); do
  git merge-tree $(git merge-base HEAD "$branch") HEAD "$branch" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "CONFLICT: $branch"
  else
    echo "CLEAN: $branch"
  fi
done
```

### Step 4: Display Summary

```markdown
## Task Board Status

### Active Tasks
| ID | Description | Assigned | Branch | Status |
|----|-------------|----------|--------|--------|
| TASK-001 | ... | CC | feat/... | In Progress |
| TASK-002 | ... | CX | cx/... | In Review |

### Worktrees
| Path | Branch | Status |
|------|--------|--------|
| . | main | clean |
| ../project-wt-cx-add-auth/ | cx/add-auth | 3 commits ahead |

### CX Branches
| Branch | Commits | Merge Status |
|--------|---------|-------------|
| cx/add-auth | 5 ahead | Clean |
| cx/add-tests | 3 ahead | CONFLICT |

### Summary
- **Backlog:** X tasks
- **CC active:** X tasks
- **CX active:** X tasks
- **In review:** X tasks
- **Completed:** X tasks
```

## Rules

- Read-only command — does not modify any files
- Report conflicts clearly so user can decide
- Show new commits on CX branches since last sync

## Input

No arguments needed.

## Output

- Task board summary
- Worktree and branch status
- Merge conflict warnings

---

*DG-VibeCoding-Framework v4.0.0 — Equal Partnership*
