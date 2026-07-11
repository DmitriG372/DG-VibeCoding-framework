# Claude Code Rules

> Project truth: `PROJECT.md` | Sprint contract: `sprint/sprint.json`
> Execution rules: `EXECUTION_PROTOCOL.md`

## Session loading

1. Read `PROJECT.md`.
2. Read and validate `sprint/sprint.json`.
3. Read `EXECUTION_PROTOCOL.md` for execution and safety constraints.
4. Confirm the current branch matches the active feature.

## Before editing

- Non-trivial features require 5–10 structured steps.
- Every feature requires measurable acceptance criteria and a file corridor.
- Run `node scripts/validate-sprint.js sprint/sprint.json`.
- `sequential` mode permits one agent at a time; parallel work uses worktrees.

## During work

- Follow `PROJECT.md` patterns and the active feature corridor.
- Keep changes minimal and evidence-driven.
- Use tests before implementation for behavior changes.
- Treat hooks as guardrails, not as a complete security boundary.

## Completion

- Run the relevant tests and show actual output.
- Stage implementation files explicitly and run `scripts/stub-check.sh --staged`.
- Create the implementation commit first.
- Record its hash in sprint state using a later coordination commit.
- Never push, merge, or deploy without the user's authorization.
