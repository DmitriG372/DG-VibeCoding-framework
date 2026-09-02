# DG-VibeCoding-Framework

The agent framework itself. This repository contains no application code — every
file here is machinery that ships into other projects.

## Stack

Node.js (no runtime dependencies), Bash, Python 3 for a few test assertions.
Tests use `node:test` and plain shell. Nothing is installed to run them.

## Layout

| Path | Contents |
|---|---|
| `core/` | The templates that ship: `AGENTS.md`, `CLAUDE.md`, `REVIEW.md`, and both hook configs |
| `.claude/` | This repo's own commands and subagents |
| `hooks/` | The five lifecycle hooks, shared by both runtimes |
| `scripts/` | Install, validation, review, and worktree tools |
| `templates/` | Project and schema templates |
| `tests/` | Eleven suites; `tests/run.sh` runs all of them. `tests/evals/` holds behavioural evals, run separately |
| `archive/` | Retired components, kept for reference and recovery |

## Commands

```bash
bash tests/run.sh                          # all eleven suites
scripts/run-evals.sh --tool claude         # behavioural evals (needs a real agent)
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
- The framework ships no `.claude/rules/` — Codex cannot read them — and no
  skills, because none has earned its per-session load cost. Both runtimes read
  the Agent Skills standard (Codex: `.agents/skills/`, Claude: `.claude/skills/`),
  so a project that adds one keeps a single copy and a symlink.
  `tests/parity.test.js` enforces that the framework itself ships neither.
- `core/REVIEW.md` is the only place review criteria live. `reviewer.md` and
  `scripts/headless-review.sh` point at it; the parity suite fails if either
  grows its own.
- Retire components by moving them to `archive/`, not by deleting them.
- Changes to hook wiring must land in both `core/settings.template.json` and
  `core/codex-hooks.template.json`, or the parity suite fails.
