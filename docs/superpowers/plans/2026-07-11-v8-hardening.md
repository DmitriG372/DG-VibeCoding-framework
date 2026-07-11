# DG-VibeCoding Framework v8 Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a safe, internally consistent v8 framework installation and
migration flow for Claude Code and Codex.

**Architecture:** Keep `framework.json` and sprint-v3 as declarative contracts,
normalize platform hook payloads in one shared module, and verify generated
projects as artifacts. Parallel partner work is always worktree-based and all
security-sensitive subprocess execution uses argument arrays.

**Tech Stack:** Bash 3.2+, Node.js built-ins (`node:test`, `child_process`,
`fs`, `path`), Git, JSON, Markdown.

## Global Constraints

- Do not add third-party runtime or test dependencies.
- Preserve all pre-existing user changes in the dirty working tree.
- Do not commit, push, switch branches, or deploy.
- Parallel CC/CX work must use worktrees; one checkout is sequential only.
- Tests must not invoke real Claude/Codex models or require network access.
- Do not choose a software license on the owner's behalf.

---

### Task 1: Sprint-v3 contract and validator

**Files:**
- Create: `scripts/validate-sprint.js`, `tests/sprint-validator.test.js`
- Modify: `templates/sprint.schema.json`, `templates/sprint.template.json`
- Modify: `.claude/commands/{sprint-init,feature,handoff}.md`
- Modify: `hooks/decomposition-guard.js`, `hooks/pre-compact.js`

**Interface:** `validateSprint(sprint) -> {valid, errors, normalizedStats}` and
CLI `node scripts/validate-sprint.js <path> [--write-stats]`.

- [ ] Write `node:test` cases for valid non-trivial/trivial sprints, duplicate
  IDs, missing criteria, short step lists, invalid current feature, multiple
  active features, and stale stats.
- [ ] Run `node --test tests/sprint-validator.test.js`; confirm RED because the
  validator module is absent.
- [ ] Implement `validateSprint`/`calculateStats`, strict schema_version v3,
  structured `{id, desc, done}` steps, corridor arrays, enums, and CLI errors.
- [ ] Align sprint-init, feature, handoff, decomposition, and snapshot logic
  with the exact v3 contract.
- [ ] Run `node --test tests/sprint-validator.test.js`; expect all tests pass.

### Task 2: Cross-runtime hook adapter and behavior

**Files:**
- Create: `hooks/lib/hook-input.js`, `tests/hooks.test.js`
- Modify: all hooks that consume tool names, paths, sessions, test results, or
  sprint feature data.

**Interface:** `normalizeHookInput(payload, cwd)` returns `toolName`,
`filePath`, `command`, `sessionId`, and `cwd`.

- [ ] Write failing fixtures for Claude Edit, Codex apply_patch, Bash, absent
  session IDs, malicious paths, current-feature selection, test results, and
  Markdown table escaping.
- [ ] Run `node --test tests/hooks.test.js`; confirm RED on the missing adapter.
- [ ] Implement normalization, argument-array subprocesses, installed-local
  formatter lookup, debounce, advisory test protection, and safe context state.
- [ ] Run `node --test tests/hooks.test.js` plus `node --check` for every hook;
  expect all checks pass.

### Task 3: Deterministic installation and Codex configuration

**Files:**
- Create: `core/codex-hooks.template.json`, `scripts/verify-install.js`,
  `tests/install-artifact.sh`
- Modify: `framework.json`, `setup-project.sh`, `.gitignore` template, smoke test

**Interface:** `node scripts/verify-install.js <project-dir>` and
`setup-project.sh [--force] <project-dir>`.

- [ ] Write a failing generated-project test for complete skill references,
  rules, hook libraries, scripts, schema, Codex hooks, docs, manifest paths,
  and overwrite refusal.
- [ ] Run `bash tests/install-artifact.sh`; confirm RED with missing artifacts.
- [ ] Implement recursive manifest-driven copying, tool preflight, force backup,
  Codex hooks, runtime helpers, and post-install verification.
- [ ] Run install-artifact and framework smoke tests; expect both pass.

### Task 4: Preservation-first migration

**Files:**
- Create: `scripts/lib/framework-install.sh`, `tests/migration.sh`
- Modify: `migrate-project.sh`, `migrate-v7-to-v8.sh`

**Interface:** shared `require_tool`, `backup_path`, `copy_framework_file`,
`merge_framework_dir`, and `verify_project` shell functions.

- [ ] Write failing tests with custom skills, agents, commands, settings,
  hooks, AGENTS rules, dry-run, second run, immutable backup, and rollback.
- [ ] Run `bash tests/migration.sh`; confirm RED on destructive behavior.
- [ ] Replace deletion with named merges, back up every overwritten file,
  remove eval, validate temporary sprint JSON, and atomically rename.
- [ ] Run `bash tests/migration.sh`; expect every preservation scenario passes.

### Task 5: Worktree-safe coordination

**Files:**
- Create: `scripts/handoff-worktree.sh`, `tests/worktree-coordination.sh`
- Modify: worktree scripts, handoff/feature/done/review/status commands,
  `core/AGENTS.md`, and project-init `AGENTS.md`

**Interface:** `handoff-worktree.sh <feature-id> <target-agent>` validates
state, commits only sprint state, and creates the partner worktree.

- [ ] Write temporary-repository tests for sequential main mode, mandatory
  parallel worktree, visible assignment, base branch, dirty-file abort, and
  later review-state hash recording.
- [ ] Run `bash tests/worktree-coordination.sh`; confirm RED on missing helper.
- [ ] Implement explicit staging, no dependency auto-install, supported Codex
  sandbox flags, exact branch matching, and two-phase coordination commits.
- [ ] Run the worktree suite; expect every scenario passes.

### Task 6: Secure headless review

**Files:**
- Create: `templates/review-output.schema.json`,
  `scripts/parse-codex-jsonl.js`, `tests/headless-review.sh`
- Modify: `scripts/headless-review.sh`

**Interfaces:** JSONL parser reads stdin and emits the last agent message;
review script accepts injectable fake model binaries for tests.

- [ ] Write failing malicious-filename, ignored-file, secret-path, JSONL,
  no-API-key, byte-limit, and schema-validation tests.
- [ ] Run `bash tests/headless-review.sh`; confirm RED on injection or parsing.
- [ ] Implement Git-based path collection, prompt stdin, strict options,
  Codex output schema/last-message files, JSONL parsing, and atomic output.
- [ ] Run headless tests and ShellCheck; expect no failures or warnings.

### Task 7: Repo-access model and documentation drift

**Files:**
- Create: `CHANGELOG.md`
- Modify: repo-access scripts, manifest/CLAUDE templates, README, GUIDE,
  HOOKS/PROJECT docs, and framework consistency tests

- [ ] Extend consistency tests for version, inventory, v3 vocabulary,
  supported flags, tracked team files, and unsafe guidance.
- [ ] Run `bash tests/framework-consistency.sh`; confirm RED on current drift.
- [ ] Make mode switching transactional and retain team guidance/sprint state;
  align active docs and record v8 changes. Document license selection as an
  owner release decision.
- [ ] Run consistency tests; expect all assertions pass.

### Task 8: Full verification

**Files:**
- Modify: `tests/run.sh` and only files implicated by fresh failures

- [ ] Aggregate sprint, hook, install, migration, worktree, headless,
  consistency, and smoke suites in `tests/run.sh`.
- [ ] Run `bash tests/run.sh`; expect zero failures.
- [ ] Run Node syntax, Bash syntax, ShellCheck, and `git diff --check`; expect
  every command exits 0.
- [ ] Map each approved acceptance criterion to a passing test or file,
  inspect final status/diff, and report the unresolved owner license choice.
