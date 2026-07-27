---
description: Create or show the optional CC/CX coordination file.
---

Follow the `## Sprint` section of `AGENTS.md`.

Argument (optional): `$ARGUMENTS`

- empty — show the current tasks, their owners, and their branches. If `sprint/sprint.json` does not
  exist, say so and stop; do not create one.
- `init` — copy `templates/sprint.template.json` to `sprint/sprint.json` and fill it in. Only do this
  when work is actually going to be split between CC and CX.

Validate any file you write with `node scripts/validate-sprint.js sprint/sprint.json`.
