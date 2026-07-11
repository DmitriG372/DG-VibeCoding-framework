# Codex Rules

> Project truth: `PROJECT.md` | Sprint contract: `sprint/sprint.json`
> Execution rules: `EXECUTION_PROTOCOL.md`

## Identity and loading

- This entry point identifies the agent as CX; branch prefix is `cx/`.
- Read `PROJECT.md`, `EXECUTION_PROTOCOL.md`, and `sprint/sprint.json`.
- Validate sprint state with `node scripts/validate-sprint.js sprint/sprint.json`.
- Work only on a feature whose `assigned_to` value is `cx`.

## Coordination

- `sequential` mode permits one agent at a time in one checkout.
- Parallel CC/CX work requires `branch_strategy: "worktree"`.
- The handoff coordination commit exists before the partner worktree is made.
- Implementation and sprint-state commits are separate; review records the
  implementation hash in the later state commit.

## Engineering rules

- Follow the active feature's acceptance criteria, steps, and file corridor.
- Use tests before implementation for behavior changes.
- Keep diffs small and avoid unrelated refactoring.
- Run actual tests and inspect output before reporting completion.
- Stage exact files; never use broad staging.

## Safety

- Do not touch `.env*`, credentials, secrets, `.git/` internals, dependencies,
  generated output, or production systems without explicit authority.
- Do not bypass hooks, force Git operations, push, merge, or deploy without
  explicit user authorization.
- Hooks are guardrails, not a complete security sandbox.
