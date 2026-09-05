# Agent Contract

Shared by Claude Code (CC) and Codex (CX). Codex reads this file natively; `CLAUDE.md` imports it.
Anything an agent must know lives here. Agent-specific surfaces add convenience, never capability.

## Project

`PROJECT.md` holds the project facts — stack, architecture, commands, conventions. Read it once per
session. An explicit user request outranks any state stored in this repo.

Branch prefix: `cc/` for Claude Code, `cx/` for Codex. Work on a branch, not on `main`/`dev`/`master`.
Start with `git status --short --branch`. Preserve existing edits and staged files. Use the current task
branch when appropriate; create one from the current checkout otherwise. Never switch another agent's branch.

## Default loop

Understand → change the minimum that solves it → run the narrowest check that proves it → report evidence.

- Act when you can act. Do not write a plan for work you could finish in the same turn.
- Do not stop between steps to ask permission. Stop only for the approval gates below.
- Reuse checks while their inputs are unchanged. Re-run affected checks after a fix or merge.
- Do not add abstractions, flags, or future-proofing the task did not ask for.

Decompose into written steps only when the work is genuinely large — multiple sessions, or several
independent tracks. A written plan is a tool for that case, not a precondition for editing a file.

## Work

1. Read the relevant implementation, callers, and tests; use targeted search rather than loading the repo.
2. Make the change.
3. Run the narrowest real check: the one test file, the one typecheck, the actual command.
4. Report what you ran and what it printed.

Use the project's documented checks; do not assume `make pre-commit` exists. Batch independent reads.
For a bug, first capture the failing case, then add a regression check that fails before the fix.
Test observable behaviour, including the installed artifact for framework/tooling changes.
A green CI run or matching configuration proves only what its checks exercise.

## Review

Ask for a review when the change is risky or cross-cutting, not by default.

- CC: `/review` launches the `reviewer` subagent with a fresh context.
- CX: `scripts/headless-review.sh --tool codex`, or `codex exec --sandbox read-only` with the same brief.

Report only findings that affect correctness or the stated requirements. A reviewer asked to find
gaps will always find some; chasing every one produces defensive code and tests for cases that
cannot happen. Treat style opinions as optional.

## Security scan

Before merge, run `scripts/security-scan.sh` when a change touches authentication, permissions,
public APIs, uploads, payments, secrets, database access, or another meaningful attack surface.
It is an explicit review step, never a pre-commit hook. Review findings and patches as evidence;
do not apply them automatically. Results stay outside the repository and must not be committed.

## Done

1. Confirm the change does what was asked. Run the check; show the real output.
2. If an existing sprint lists this task, update its `status` and `updated` for the same commit.
3. Stage the exact files and inspect the staged diff. Never `git add .` or `git add -A`.
4. Commit with a conventional message describing the change.
5. Report the commit, checks, and remaining work. Push or merge only when requested.

Tests are required when behaviour changed. Diagnose failures and try a targeted fix. If blocked, report
the failing command, cause, and next step. Do not mark failing work done or commit it as completed.

## Sprint

`sprint/sprint.json` is optional. It exists only to coordinate CC and CX working in parallel. Never
create one in order to start work; never treat a missing or stale one as a blocker.

```json
{ "schema_version": 4, "base_branch": "dev", "updated": "2026-07-27T10:00:00Z",
  "tasks": [
    { "id": "T1", "title": "Short imperative title", "assigned_to": "cc",
      "status": "in_progress", "branch": "cc/t1-short-slug" }
  ] }
```

`assigned_to` ∈ `cc` | `cx`. `status` ∈ `planned` | `in_progress` | `in_review` | `done`.
Validate with `node scripts/validate-sprint.js sprint/sprint.json`.

## Handoff

Hand a task to the partner agent when it is genuinely independent and needs no live user interaction.

1. Create or pick the task in `sprint/sprint.json`; set `assigned_to` and a new, unused `branch`.
2. `scripts/handoff-worktree.sh <task-id> <cc|cx>` — validates, makes the coordination commit, creates
   the worktree, prints its path.
3. Give the user the launch line: `cd <worktree> && codex --sandbox workspace-write` (or `claude`).

The partner works in that worktree and sets `status: in_review` when finished. Merging is the user's call.

## Approval gates

Ask only when an action below is not already authorized by the user. Carry existing authorization
forward within its stated scope. Everything else: decide and proceed.

- Production deploy, production database changes, DNS/domain/SSL, production environment variables
- `git push --force`, `git reset --hard`, `git clean -f`, `git branch -D`, deleting a branch or worktree
- `DROP` / `TRUNCATE` / irreversible migrations
- Installing a new dependency
- Anything that writes to an external service or reaches another person

## Never

- Edit `.env*`, `secrets/*`, credentials, or `.git/` internals
- Commit with `--no-verify`, or commit secret material
- Weaken a test to hide a defect; update expectations only when the required behaviour changed
- Rename files, refactor untouched code, or widen scope without being asked
- Paste `.env` values, API keys, or database URIs into chat or commit messages
- Claim something works without having run it

Hooks are guardrails, not a security sandbox. If you catch yourself about to break one of these
rules, stop and say so — that is the guardrail working, not a failure.

## Evidence

State what you ran and what it returned. Distinguish tested behaviour from assumptions and untested
runtime integrations. A failed step is evidence to diagnose, never a success to report.

"Should work", "tests should pass", "I've updated the file", and "everything is in place" are not
evidence. A command and its output are.
