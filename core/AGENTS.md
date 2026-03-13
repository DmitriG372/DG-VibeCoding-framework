# Codex Rules (v5.0.0)

> Project details → `PROJECT.md` | Sprint state → `sprint/sprint.json`

---

## Language

- Code, comments, commits: English
- Logs and summaries: English

---

## Context Loading

1. Always read `PROJECT.md` first — single source of truth
2. Read `sprint/sprint.json` for assigned features
3. Work only on features with `assigned_to: "cx"`
4. Follow patterns and rules from PROJECT.md

---

## Agent Identity

CX identity is detected automatically from the `AGENTS.md` entry point. Branch prefix is `cx/` — e.g., `cx/F001-auth-api`.

---

## Workflow

### Before Coding
1. Read `PROJECT.md` for context, stack, patterns
2. Read `sprint/sprint.json` — find features assigned to CX
3. Understand the codebase via relevant file reads

### During Coding
- Follow patterns → `PROJECT.md#Patterns`
- Respect rules → `PROJECT.md#Rules`
- Stay within feature scope — do not expand beyond assigned work
- Commit frequently with clear messages

### After Coding
- Run tests before marking complete
- Follow git conventions from PROJECT.md
- Use `/done` command to complete the feature (updates sprint.json status to `in_review`)
- Commit all changes including updated sprint state

---

## Sprint Protocol

**File:** `sprint/sprint.json`

### What CX Can Do
- Work on features with `assigned_to: "cx"`
- Update feature status to `in_review` when done (via `/done` command)
- Add notes to features (prefix with `[CX]`)
- Create sub-tasks under assigned feature

### What CX Cannot Do
- Assign features to itself (CC or user assigns)
- Move features to `completed` (CC reviews first)
- Delete or modify CC's features
- Change feature priorities

---

## Git Conventions

### Branch Naming
- CX branches: `cx/FXXX-<slug>` (e.g., `cx/F003-add-auth-api`)
- Feature ID from sprint.json (F001, F002, etc.)
- Never work on `main` or `dev` directly

### Commits
```
<type>(<scope>): <description>

Types: feat, fix, refactor, docs, test, chore
```

### Worktree
- Worktree usage is optional — determined by `branch_strategy` in sprint.json
- When using worktree: `../<project>-wt-cx-<branch>/`
- When not using worktree: work on CX branch directly

---

## Rules

### Always
- Read PROJECT.md before starting
- Run tests before marking feature complete
- Commit to CX branch only
- Use `/done` command when feature is complete
- Handle errors explicitly

### Never
- Push to main/dev directly
- Modify files outside feature scope
- Skip tests
- Add dependencies without noting in sprint.json feature notes
- Touch `.env*` files or secrets

---

*DG-VibeCoding-Framework v5.0.0 — CX Entry Point*
