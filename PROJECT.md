# DG-VibeCoding-Framework

The agent framework itself. This repository contains no application code — every
file here is machinery that ships into other projects.

## Stack

Node.js (no runtime dependencies), Bash, Python 3 for a few test assertions.
Tests use `node:test` and plain shell. Nothing is installed to run them.

## Layout

| Path | Contents |
|---|---|
| `core/` | The templates that ship: `AGENTS.md`, `CLAUDE.md`, both hook configs, `PROJECT.md` |
| `.claude/` | This repo's own commands and subagents |
| `hooks/` | The five lifecycle hooks, shared by both runtimes |
| `scripts/` | Install, validation, review, and worktree tools |
| `templates/` | Project and schema templates |
| `tests/` | Nine suites; `tests/run.sh` runs all of them |
| `archive/` | Retired components, kept for reference and recovery |

## Commands

```bash
bash tests/run.sh                          # all nine suites
./setup-project.sh <dir>                   # new project
./migrate-to-v9.sh <dir> [--dry-run]       # existing 4.x–8.x project
shellcheck setup-project.sh migrate-*.sh scripts/*.sh tests/*.sh
```

`VERSION` is the single source of truth for the version number.
`tests/framework-consistency.sh` fails if any other file hardcodes it, or if
`framework.json` drifts from what is actually on disk.

## Conventions

- `core/AGENTS.md` is the contract this framework exists to deliver. Editing it
  changes the behaviour of every project that installs the framework, so keep it
  under 150 lines and prefer removing a rule over adding one.
- The framework ships no `.claude/rules/` and no `.claude/skills/`. Codex reads
  neither, so neither may carry anything an agent needs. `tests/parity.test.js`
  enforces this.
- Retire components by moving them to `archive/`, not by deleting them.
- Changes to hook wiring must land in both `core/settings.template.json` and
  `core/codex-hooks.template.json`, or the parity suite fails.
