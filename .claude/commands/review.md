---
description: Review the current change with a fresh context.
---

Follow the `## Review` section of `AGENTS.md`. Launch the `reviewer` subagent so the review runs
against a fresh context rather than your own.

Argument (optional): `$ARGUMENTS` — a branch, path, or diff range to review. If absent, review the
uncommitted changes plus commits on this branch that are not on the base branch.
