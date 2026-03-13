# Codex Rules

> Project details → `PROJECT.md` | Sprint → `sprint/sprint.json`

## Context Loading

1. Read `PROJECT.md` first
2. Read `sprint/sprint.json` for assigned features
3. Work only on features with `assigned_to: "cx"`

## Workflow

1. Read PROJECT.md for context
2. Find your assigned features in sprint/sprint.json
3. Implement on `cx/FXXX-<slug>` branch
4. Run tests before marking complete
5. Use /done to complete feature

## Git

- Branch: `cx/FXXX-<slug>` (e.g., `cx/F001-user-auth`)
- Commit: `<type>(<scope>): <description>`
- Never push to main/dev directly

## Rules

### Always
- Follow PROJECT.md patterns
- Run tests before completing
- Use /done to update sprint state

### Never
- Modify files outside task scope
- Skip tests
- Touch .env files
