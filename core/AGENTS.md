# Codex Rules (v4.0.0)

> Project details → `PROJECT.md` | Task board → `.tasks/board.md`

---

## Language

- Code, comments, commits: English
- Logs and summaries: English

---

## Context Loading

1. Always read `PROJECT.md` first — single source of truth
2. Read `.tasks/board.md` for assigned tasks
3. Work only on tasks assigned to CX
4. Follow patterns and rules from PROJECT.md

---

## Workflow

### Before Coding
1. Read `PROJECT.md` for context, stack, patterns
2. Read `.tasks/board.md` — find your task (Assigned to: CX)
3. Understand the codebase via relevant file reads

### During Coding
- Follow patterns → `PROJECT.md#Patterns`
- Respect rules → `PROJECT.md#Rules`
- Stay within task scope — do not expand beyond assigned work
- Commit frequently with clear messages

### After Coding
- Run tests before marking complete
- Follow git conventions from PROJECT.md
- Update `.tasks/board.md`: move task to "In Review"
- Commit the board.md update

---

## Task Board Protocol

**File:** `.tasks/board.md`

### What CX Can Do
- Move tasks from "Assigned to: CX" → "In Review" when done
- Add notes to tasks (prefix with `[CX]`)
- Create sub-tasks under assigned task

### What CX Cannot Do
- Assign tasks to itself (CC or user assigns)
- Move tasks to "Completed" (CC reviews first)
- Delete or modify CC's tasks
- Change task priorities

---

## Git Conventions

### Branch Naming
- CX branches: `cx/<task-slug>` (e.g., `cx/add-auth-api`)
- Never work on `main` or `dev` directly

### Commits
```
<type>(<scope>): <description>

Types: feat, fix, refactor, docs, test, chore
```

### Worktree
- CX works in: `../<project>-wt-cx-<branch>/`
- Do not modify files in the main worktree

---

## Rules

### Always
- Read PROJECT.md before starting
- Run tests before marking task complete
- Commit to CX branch only
- Update board.md when task status changes
- Handle errors explicitly

### Never
- Push to main/dev directly
- Modify files outside task scope
- Skip tests
- Add dependencies without noting in board.md
- Touch `.env*` files or secrets

---

*DG-VibeCoding-Framework v4.0.0 — CX Entry Point*
