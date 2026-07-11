# Bulk Framework Migration — Design Specification

**Date:** 2026-07-11
**Status:** Approved
**Target release:** post-8.0.0
**Scope:** Safely discover and migrate DG-VibeCoding projects below one root directory

## 1. Problem

`migrate-project.sh` safely migrates one project at a time, but there is no
coordinator for a directory containing many projects. A naïve recursive shell
loop would have an excessive blast radius: it could update dirty repositories,
linked worktrees, unsupported framework versions, excluded client projects, or
continue after a systemic migration failure.

The bulk updater must coordinate the existing single-project migrator without
duplicating its migration logic.

## 2. Goals

- Recursively discover framework projects under an explicit root directory.
- Support persistent and command-line exclusion patterns.
- Default to a read-only dry run.
- Skip dirty repositories and other unsafe candidates.
- Apply migrations sequentially and stop at the first migration failure.
- Preserve the backup and verification guarantees of `migrate-project.sh`.
- Produce human-readable and machine-readable audit reports.
- Never commit, push, pull, install dependencies, or contact the network.

## 3. Non-goals

- Migrating non-Git directories automatically.
- Automatically repairing unsupported or ambiguous legacy projects.
- Updating dependencies or application code.
- Parallel migration.
- Automatic destructive rollback.
- Automatically committing or publishing migrated projects.

## 4. Considered Approaches

### 4.1 Thin batch orchestrator — selected

A dependency-free Node.js coordinator discovers projects, performs preflight
checks, and invokes `migrate-project.sh` with argument arrays.

Advantages:

- one source of truth for migration behavior;
- safe handling of paths and structured reports;
- independently testable discovery and policy logic;
- small implementation surface.

### 4.2 Explicit project inventory only

An inventory file would be maximally predictable but would require continuous
manual maintenance and would not satisfy recursive folder discovery.

### 4.3 Parallel per-project workers

Parallel execution would be faster but increases log ambiguity, disk pressure,
concurrent Git risk, and the number of projects affected before a systemic
failure is detected. It is rejected for the initial version.

## 5. User Interface

The entry point is:

```text
scripts/bulk-migrate.js
```

Supported forms:

```bash
# Read-only discovery and preflight
node scripts/bulk-migrate.js /projects/root

# Add command-line exclusions
node scripts/bulk-migrate.js /projects/root \
  --exclude "archive/**" \
  --exclude "**/legacy-*"

# Apply the displayed plan after an interactive confirmation
node scripts/bulk-migrate.js /projects/root --apply

# Explicit non-interactive apply
node scripts/bulk-migrate.js /projects/root --apply --yes

# Continue after a project migration failure
node scripts/bulk-migrate.js /projects/root --apply --continue-on-error

# Override the persistent report location
node scripts/bulk-migrate.js /projects/root --report-dir /audit/reports
```

`--yes` is valid only together with `--apply`. Unknown options and missing
option values exit with usage status 64.

## 6. Discovery

The coordinator resolves the root to an absolute real path and walks it without
following symbolic links.

A directory is considered a repository candidate only when it contains a real
`.git` directory. A `.git` file is classified as a linked worktree or submodule
and skipped. Once a repository is found, its subtree is pruned so nested build
artifacts cannot be treated as separate projects.

Automatic migration additionally requires a readable `framework.json` whose
`name` is `DG-VibeCoding-Framework`. A repository with only weak legacy markers
such as `AGENTS.md`, `CLAUDE.md`, `.claude/`, or `.tasks/board.md` is reported as
`manual_review`, not migrated.

Version policy:

- supported 7.x version: `eligible`;
- current framework version: `current`;
- older, newer, missing, or malformed version: `unsupported` or
  `manual_review`;
- version comparison uses the source framework's `VERSION` file.

## 7. Exclusions

The root may contain `.dg-framework-ignore`. Its syntax is the supported subset
of Gitignore semantics: blank lines and `#` comments are ignored, `/` separates
path components, and `*`, `**`, and `?` are supported. Patterns are evaluated
against normalized POSIX-style paths relative to the scan root.

Every `--exclude <pattern>` value is added to the file-based patterns. Exclusion
is a union; command-line patterns do not replace the ignore file.

The following exclusions are built in and cannot be negated:

- `.git/**`;
- `node_modules/**`;
- `dist/**`, `build/**`, `.next/**`, `.vercel/**`;
- `.dg-framework-backup-*/**`;
- `.dg-framework-reports/**`;
- linked Git worktrees and symbolic-link directories.

User patterns do not support negation in the initial version. This avoids a
surprising re-inclusion of a safety exclusion.

## 8. Preflight State Machine

Each discovered repository receives exactly one status:

| Status | Meaning | Apply behavior |
|---|---|---|
| `eligible` | Supported framework project and safe Git state | Migrate |
| `current` | Already on the source framework version | Skip |
| `excluded` | Matched an exclusion | Skip |
| `dirty` | Tracked, staged, or untracked changes exist | Skip |
| `worktree` | `.git` is a file | Skip |
| `git_operation` | Merge, rebase, revert, or cherry-pick is active | Skip |
| `detached` | HEAD is detached | Skip |
| `unsupported` | Framework version is outside the automatic corridor | Skip |
| `manual_review` | Framework identity is ambiguous | Skip |
| `changed_since_plan` | Git safety state changed after preflight | Stop by default |
| `updated` | Migration and post-validation succeeded | Complete |
| `failed` | Migration or post-validation failed | Stop by default |

Dirty detection uses:

```bash
git status --porcelain --untracked-files=all
```

The coordinator also resolves the repository Git directory and checks for
merge, rebase, revert, and cherry-pick state. It never tries to clean, stash, or
commit a repository.

## 9. Two-phase Execution

### Phase 1: plan

Every invocation performs discovery and all preflight checks first. Without
`--apply`, it prints and records the plan, makes no changes inside projects, and
exits.

### Phase 2: apply

With `--apply`, the exact preflight plan is displayed. Interactive execution
requires confirmation containing the eligible project count. `--yes` is the
explicit automation bypass.

Projects are processed sequentially in stable lexical path order. Immediately
before migrating each project, its Git safety checks are repeated to close the
time-of-check/time-of-use gap. If the project state changed after planning, it
is classified as `changed_since_plan` and the circuit breaker stops the batch by
default. Apply mode never adds a project that was not eligible in the frozen
plan.

The migrator is invoked without a shell:

```text
migrate-project.sh <absolute-project-path>
```

No migration logic is reimplemented in the coordinator.

## 10. Locking and Interruption

An atomic lock directory in the operating-system temporary directory prevents
two bulk updates of the same real root from running concurrently:

```text
${TMPDIR:-/tmp}/dg-framework-bulk-<sha256(real-root)>.lock/
```

The lock records PID, start time, framework path, and command mode. A live lock
blocks a new run. A stale lock is reported with a dedicated removal instruction;
it is not deleted silently.

Signal handlers stop before starting another project, finalize the report, and
remove only the lock owned by the current process. An interrupted in-progress
project retains the backup created by its single-project migrator.

## 11. Failure and Recovery

The default circuit breaker stops the batch after the first `failed` project.
`--continue-on-error` is an explicit override; the final process status remains
non-zero if any project failed.

Automatic rollback is deliberately excluded. The target was clean before
migration, but deleting newly installed files automatically could still destroy
state created during an interruption. The report records the immutable backup
path printed by `migrate-project.sh` and provides recovery guidance.

After a successful migrator exit, the coordinator runs:

```bash
node <project>/scripts/verify-install.js <project>
node <project>/scripts/validate-sprint.js <project>/sprint/sprint.json
```

A post-validation failure is treated exactly like a migration failure.

## 12. Reports

Each run writes both formats outside the scan root so reporting cannot make a
candidate repository dirty. The default is:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/dg-vibecoding/bulk-migrate/<timestamp>.json
${XDG_STATE_HOME:-$HOME/.local/state}/dg-vibecoding/bulk-migrate/<timestamp>.md
```

`--report-dir` overrides this location. The resolved report directory must not
be inside the scan root.

The JSON report is the canonical record. It includes:

- schema version, command mode, root, framework source, and timestamps;
- all configured and built-in exclusions;
- every discovered candidate and its status reason;
- pre-migration framework version, branch, and HEAD;
- migration exit code and bounded stdout/stderr summaries;
- backup path when one was created;
- post-validation results and final framework version;
- aggregate counts and overall exit status.

Reports must not contain environment values, Git credentials, file contents, or
unbounded command output. Markdown is rendered from the JSON record.

## 13. Security Constraints

- All child processes use argument arrays with `shell: false`.
- Paths are realpath-normalized and must remain below the requested root.
- Symbolic links are never followed during discovery.
- The framework source repository must itself be clean before apply mode. Its
  `VERSION` must match `framework.json.version`, and every
  `framework.install.entries[].from` source must exist. Installed-project
  verification is not incorrectly applied to the source layout.
- The updater performs no network access.
- No secrets, local settings contents, diffs, or source files enter reports.
- Excluded and unsafe projects are never passed to the migrator.

## 14. Exit Codes

| Code | Meaning |
|---:|---|
| 0 | Dry run completed, or every applied migration succeeded |
| 1 | One or more projects failed migration or validation |
| 2 | Global preflight or lock failure prevented apply mode |
| 64 | Invalid command usage |
| 130 | Interrupted by the user |

Skipped, dirty, excluded, current, and manual-review projects are reported but
do not alone make a dry run fail. Apply mode exits 2 when no project is eligible,
because `--apply` would otherwise give a misleading success signal.

## 15. Test Strategy

Unit tests cover:

- path normalization and root containment;
- Gitignore-subset glob matching;
- built-in exclusion precedence;
- version and status classification;
- deterministic ordering and report aggregation.

Integration tests create temporary Git repositories and cover:

- recursive discovery through category directories;
- file-based and repeated CLI exclusions;
- spaces and shell metacharacters in project paths;
- dirty, detached, linked-worktree, and active-Git-operation skips;
- current, supported, unsupported, and ambiguous framework projects;
- dry-run immutability;
- explicit apply confirmation;
- sequential migration and post-validation;
- first-failure circuit breaking and `--continue-on-error`;
- live and stale locks;
- signal cleanup and partial reports;
- repeated-run idempotency;
- JSON and Markdown report consistency.

The test runner uses temporary fixtures and injects a fake child-process runner
through the coordinator's internal module boundary, so no production override
flag exists and no real project is modified.

## 16. Acceptance Criteria

1. A default invocation recursively reports projects without changing them.
2. Ignore-file and CLI exclusions reliably prevent migrator invocation.
3. Dirty repositories, linked worktrees, symlinks, detached heads, and active
   Git operations are never migrated.
4. Apply mode processes only the frozen eligible plan, sequentially, after
   explicit confirmation.
5. The first project failure stops the batch unless `--continue-on-error` was
   supplied.
6. Every successful project passes install and sprint validation.
7. Every run produces bounded, secret-free JSON and Markdown reports.
8. The coordinator never commits, pushes, pulls, installs dependencies, or
   accesses the network.
