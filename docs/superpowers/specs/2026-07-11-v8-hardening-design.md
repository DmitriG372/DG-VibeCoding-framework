# DG-VibeCoding Framework v8 Hardening Design

**Date:** 2026-07-11
**Status:** Approved for implementation

## Goal

Make the v8 framework safe to distribute, deterministic to install, compatible
with both Claude Code and Codex, and robust when CC and CX work in parallel.

## Design principles

1. One contract per concern: `framework.json` for inventory, `sprint-v3` for
   coordination state, and platform-specific hook configuration for runtime
   integration.
2. Git-tracked state is shared state. Local settings, logs, secrets, and
   narrative session memory remain local.
3. Parallel agents always use separate worktrees. A single checkout may only
   be used sequentially.
4. Hooks are guardrails, not the sole security boundary. Validation must also
   be callable directly from tests and commands.
5. Setup and migration fail closed on missing framework artifacts and preserve
   project-owned customization.

## Repository state model

The following files stay tracked in all `repo_access` modes:

- `PROJECT.md`
- `AGENTS.md`
- `CLAUDE.md`
- `EXECUTION_PROTOCOL.md`
- `framework.json`
- `sprint/sprint.json`
- reusable skills, commands, agents, hook sources, and validation scripts

The following remain local and ignored:

- `.claude/settings.local.json`
- `.claude/SNAPSHOT.md`
- `.claude/context-snapshot.json`
- `.claude/logs/` and usage/test marker files
- `.env*`, credentials, keys, local databases, and build output

`manifest.md` remains local because it declares local repository-access policy.

## Sprint v3 contract

`templates/sprint.schema.json` is the authoritative schema. The instance uses a
real relative schema URI (`../templates/sprint.schema.json`) while
`schema_version` contains the logical version `sprint-v3`.

Each feature requires:

- unique `id` matching `FNNN`
- non-empty `name` and `description`
- at least one measurable acceptance criterion
- `status`, `assigned_to`, `complexity`, and `tested`
- either `trivial: true` or 5–10 structured steps
- a corridor with explicit `allowed` and `forbidden` arrays

Structured steps use `{ "id", "desc", "done" }`. Hook and snapshot code must
consume those exact names. Root stats are recomputed from features and never
trusted as independent input.

A dependency-free `scripts/validate-sprint.js` validates both JSON Schema-like
invariants and cross-field rules. It is used by tests, decomposition guards,
commands, setup smoke tests, and migrations.

## Runtime integration

Claude Code continues to use `.claude/settings.local.json`. Codex receives
`.codex/hooks.json`. Both configurations call the same hook scripts.

`hooks/lib/hook-input.js` normalizes platform payloads:

- Claude `Edit`, `Write`, and `MultiEdit` file paths
- Codex canonical `apply_patch` payloads
- Bash commands
- working directory and session identity

File-path-dependent post-edit hooks skip safely when a platform provides only
a patch string. Scope and decomposition validation still run because they do
not require a target path; scope checks emit a clear advisory when the path
cannot be derived.

## Coordination workflow

`main` means sequential work in one checkout. It is not a parallel mode.

Every parallel CC/CX handoff follows this sequence:

1. Validate and update `sprint/sprint.json` with assignment, branch, steps, and
   corridor.
2. Commit the coordination update as a dedicated `chore(sprint)` commit.
3. Create the partner branch and worktree from that commit.
4. Launch the partner inside the worktree with the supported sandbox flag.
5. The implementation commit contains code and tests only.
6. Review writes the resulting implementation hash to sprint state in a later
   coordination commit.

This avoids the impossible requirement for a commit to contain its own hash.
Commands never silently skip a missing feature/branch match.

## Installation

`framework.json` becomes the install manifest for runtime artifacts. Setup
copies complete directories recursively, including skill references, and then
runs `scripts/verify-install.js` against the generated project.

Setup refuses to overwrite an initialized project unless `--force` is passed.
With `--force`, it creates a timestamped backup first. Required tools are
checked before writes: Bash, Git, Node.js, Python 3, and `jq` for migration.

The generated project includes:

- full `.claude/skills`, `.claude/commands`, `.claude/agents`, and rules
- `.codex/hooks.json`
- all hooks and their shared libraries
- all runtime helper scripts
- sprint template and schema
- execution and hook documentation
- safe `.gitignore` entries without ignoring team guidance or source files

## Migration

Migration is additive and merge-based:

- all overwritten root files and runtime directories are backed up
- project-owned skills, agents, commands, permissions, and hooks are retained
- framework-managed files are updated by exact name
- sprint conversion is written to a temporary file, validated, then atomically
  renamed
- the original v7 backup is never overwritten on repeated runs
- `--dry-run` reports operations without using `eval`
- failure leaves the original project usable and prints the backup path

The general legacy migrator and the focused v7-to-v8 migrator share copy and
verification helpers to prevent drift.

## Security hardening

No filename or user-supplied value is interpolated into shell program text.
Node child processes use `execFileSync` or `spawnSync` with argument arrays.
Shell loops use quoted positional parameters and null-delimited paths.

Headless review:

- reads tracked files through `git ls-files`, respecting Git ignore rules
- rejects secret-like paths before gathering content
- sends prompts over stdin rather than process arguments
- parses Codex JSONL events line by line
- uses `--output-schema` and `--output-last-message`
- places a byte limit on collected content
- validates tool, mode, branch, target, and output arguments

Auto-format only invokes an already-installed local formatter binary. It never
allows `npx` to download packages.

## Hook behavior and performance

- `test-dir-protection` becomes an advisory after failed test runs instead of a
  two-minute hard block.
- test commands store exit status when the platform exposes it; unknown status
  never causes a hard block.
- type checking and formatting use a per-file debounce and explicit timeouts.
- context-monitor does not use a shared `unknown` session counter; absent
  session IDs disable the heuristic.
- guards select `current_feature` first and reject multiple inconsistent
  `in_progress` features.
- `block-env` is documented as a guardrail and secret paths are also protected
  in review/install workflows.

## Documentation

README and GUIDE use `VERSION` and `framework.json` as validated sources.
Tests compare documented inventory with actual files. All examples use
`sprint-v3`, `completed`, `base_branch`, mandatory worktrees for parallel
handoffs, and supported Codex flags.

The active changelog records the v8 migration. A `LICENSE` file is required
before public distribution.

## Testing strategy

Tests remain dependency-light Bash and Node.js tests:

- unit tests for every critical hook and payload normalization
- schema tests for valid and invalid sprint fixtures
- setup artifact test that checks every manifest path and referenced file
- migration preservation, dry-run, idempotency, and rollback tests
- malicious filename regression tests for formatter and headless review
- Claude and Codex hook payload fixtures
- sequential-main and parallel-worktree handoff integration tests
- Codex JSONL parser fixtures
- documentation/inventory drift tests
- syntax, ShellCheck, and full smoke suite

No network access or real model invocation is required by the automated suite.

## Acceptance criteria

1. `tests/run.sh` passes from a clean checkout.
2. Setup produces a project where all configured and referenced artifacts
   exist and both runtime configurations parse.
3. Official `sprint-init` output validates as sprint-v3 and does not deadlock
   the decomposition guard.
4. A parallel handoff worktree sees its assignment immediately.
5. Malicious filenames cannot execute shell commands during format or review.
6. Codex JSONL review output is parsed without requiring `OPENAI_API_KEY`.
7. Migration preserves custom skills, agents, commands, settings, and root
   guidance while remaining idempotent.
8. Current README, GUIDE, VERSION, framework inventory, and actual files agree.

## Non-goals

- introducing a database or hosted coordination service
- adding third-party runtime dependencies
- redesigning project-specific coding conventions
- automatically pushing, merging, or deploying
- guaranteeing hooks as a complete security sandbox
