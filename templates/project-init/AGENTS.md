# Codex Rules

> Project truth: `PROJECT.md` | Sprint contract: `sprint/sprint.json`
> Execution rules: `EXECUTION_PROTOCOL.md`

## Session loading

1. Read `PROJECT.md` and `EXECUTION_PROTOCOL.md`.
2. Read `sprint/sprint.json` and run its validator.
3. Work only on a feature assigned to `cx`.
4. Confirm the current branch and worktree match the feature branch.

## Workflow

- Run `node scripts/validate-sprint.js sprint/sprint.json` before editing.
- Non-trivial features require 5–10 steps and an explicit file corridor.
- `sequential` mode is one agent at a time in one checkout.
- Parallel CC/CX work always uses a dedicated Git worktree.
- Follow the closest `AGENTS.md` and `PROJECT.md` conventions.
- Write behavior tests before implementation and show real verification output.

## Completion

1. Stage only implementation and test files.
2. Run `scripts/stub-check.sh --staged` and project tests.
3. Create the implementation commit on `cx/FNNN-<slug>`.
4. Update sprint state to `in_review`, record the implementation hash, validate
   it, and create a separate `chore(sprint)` coordination commit.

## Safety

- Never modify `.env*`, credentials, secrets, generated output, or `.git/` internals.
- Never broaden feature scope silently or add dependencies without approval.
- Never work directly on `main`/`dev`, bypass hooks, force Git operations, push,
  merge, or deploy without explicit authorization.
