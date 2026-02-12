# Codex Rules

> Project details → `PROJECT.md` | Task board → `.tasks/board.md`

## Context Loading

1. Read `PROJECT.md` first
2. Read `.tasks/board.md` for assigned tasks
3. Work only on tasks assigned to CX

## Workflow

1. Read PROJECT.md for context
2. Find your task in .tasks/board.md
3. Implement on `cx/<branch>` only
4. Run tests before marking complete
5. Move task to "In Review" in board.md

## Git

- Branch: `cx/<task-slug>`
- Commit: `<type>(<scope>): <description>`
- Never push to main/dev directly

## Rules

### Always
- Follow PROJECT.md patterns
- Run tests before completing
- Update board.md on status change

### Never
- Modify files outside task scope
- Skip tests
- Touch .env files
