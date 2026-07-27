---
description: Hand a task to the partner agent (CC ↔ CX) in its own worktree.
---

Follow the `## Handoff` section of `AGENTS.md`.

Identity: this file is the Claude Code entry point, so you are `cc` and the target is `cx`.

Argument: `$ARGUMENTS` — an existing task id, or a description to turn into one. Refuse the handoff
if the task is ambiguous or needs live user interaction; say so instead of guessing.
