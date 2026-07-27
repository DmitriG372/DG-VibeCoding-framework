# Agent Contract

Shared by Claude Code (CC) and Codex (CX). Codex reads this file natively; `CLAUDE.md` imports it.
Anything an agent must know lives here. Agent-specific surfaces add convenience, never capability.

## Project

`PROJECT.md` holds the project facts — stack, architecture, commands, conventions. Read it once per
session. An explicit user request outranks any state stored in this repo.

Branch prefix: `cc/` for Claude Code, `cx/` for Codex. Work on a branch, not on `main`/`dev`/`master`.

## Default loop

Understand → change the minimum that solves it → run the narrowest check that proves it → report evidence.

- Act when you can act. Do not write a plan for work you could finish in the same turn.
- Do not stop between steps to ask permission. Stop only for the approval gates below.
- Do not re-verify what you already verified. One real check is the standard, not a loop.
- Do not add abstractions, flags, or future-proofing the task did not ask for.

Decompose into written steps only when the work is genuinely large — multiple sessions, or several
independent tracks. A written plan is a tool for that case, not a precondition for editing a file.

## Work

1. Read only the files the task touches.
2. Make the change.
3. Run the narrowest real check: the one test file, the one typecheck, the actual command.
4. Report what you ran and what it printed.

Typecheck and formatting belong in `make pre-commit` or CI — once per commit, not once per edit.

## Review

Ask for a review when the change is risky or cross-cutting, not by default.

- CC: `/review` launches the `reviewer` subagent with a fresh context.
- CX: `scripts/headless-review.sh --tool codex`, or `codex exec --sandbox read-only` with the same brief.

Report only findings that affect correctness or the stated requirements. A reviewer asked to find
gaps will always find some; chasing every one produces defensive code and tests for cases that
cannot happen. Treat style opinions as optional.

## Done

1. Confirm the change does what was asked. Run the check; show the real output.
2. Stage the exact files. Never `git add .` or `git add -A`.
3. Commit with a conventional message describing the change.
4. Only if `sprint/sprint.json` exists and lists this task: set its `status` and `updated`, commit separately.

Tests are required when behaviour changed. If a test fails and a few attempts do not fix it, commit
the work, state which test fails and why, and stop. Do not loop.

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

1. Create or pick the task in `sprint/sprint.json`; set `assigned_to` and `branch`.
2. `scripts/handoff-worktree.sh <task-id> <cc|cx>` — validates, makes the coordination commit, creates
   the worktree, prints its path.
3. Give the user the launch line: `cd <worktree> && codex --sandbox workspace-write` (or `claude`).

The partner works in that worktree and sets `status: in_review` when finished. Merging is the user's call.

## Approval gates

Stop and ask only for these. Everything else: decide and proceed.

- Production deploy, production database changes, DNS/domain/SSL, production environment variables
- `git push --force`, `git reset --hard`, `git clean -f`, `git branch -D`, deleting a branch or worktree
- `DROP` / `TRUNCATE` / irreversible migrations
- Installing a new dependency
- Anything that writes to an external service or reaches another person

## Never

- Edit `.env*`, `secrets/*`, credentials, or `.git/` internals
- Commit with `--no-verify`, or commit secret material
- Edit a test in order to make a failing test pass
- Rename files, refactor untouched code, or widen scope without being asked
- Paste `.env` values, API keys, or database URIs into chat or commit messages
- Claim something works without having run it

Hooks are guardrails, not a security sandbox. If you catch yourself about to break one of these
rules, stop and say so — that is the guardrail working, not a failure.

## Evidence

State what you ran and what it returned. If a step failed, report the real error and stop; do not
continue as though it succeeded and do not invent a result.

"Should work", "tests should pass", "I've updated the file", and "everything is in place" are not
evidence. A command and its output are.
