# Claude/Codex Workflow Optimization — Execution Plan

> **SUPERSEDED 2026-07-27 by framework v9.0.0.** This plan diagnosed several of
> the right problems — advisory hooks, opt-in sprint state, the autonomy/gate
> contradiction — but gated its own execution behind the very
> stop-after-every-phase rule it proposed to delete, and it kept the machinery
> that caused the problem. v9 removed that machinery instead: see `CHANGELOG.md`
> and `AGENTS.md`. Retained for the baseline measurements in
> "Verified Baseline" and "The Ownership Conflict", which remain accurate.

> **Execution plan for an existing implementation plan.** The source plan lives in another repository:
> `~/_VibeCoding/01_ACTIVE/melior-plus-mvp/docs/superpowers/plans/2026-07-26-claude-codex-workflow-optimization.md` (7 tasks, 39 steps, untracked at the time of writing).
>
> This document sequences that work across **two repositories**, records the verified baseline, and fixes one ownership conflict the source plan does not account for.

**Goal:** Deliver the source plan's outcome — one lightweight engineering process shared by Claude and Codex, with a fast default path and explicit heavy gates — without losing any of it to the pending framework v7.1 → v8 migration.

**Architecture:** Split the source plan by *file ownership*. Project-owned artifacts (shared contract document, entrypoints, Makefile gates, agent scripts, validation evidence) stay in `melior-plus-mvp`. Framework-owned artifacts (`hooks/*.js`, `.claude/rules/*.md`, `.claude/commands/*.md`, `framework.json`) move upstream into `DG-VibeCoding-framework` and reach the project through a normal version migration.

**Repositories:**

| Alias | Path | Role |
|---|---|---|
| `PROJECT` | `~/_VibeCoding/01_ACTIVE/melior-plus-mvp` | Consumer, framework v7.1.0, branch `cx/command-palette-search-followup` |
| `FRAMEWORK` | `~/_VibeCoding/_tools/DG-VibeCoding-framework` | Owner of hooks/rules/commands, v8.0.0, branch `main` @ `f80abcd` |

**Tech Stack:** Markdown configuration, Node.js 22.17.0, pnpm 11.7.0, Make, Vitest, Vue TSC, ESLint, Bash. No new runtime dependency.

---

## Verified Baseline (2026-07-26)

Re-verified against the live repositories before writing this plan. All seven source-plan baseline claims hold.

| # | Claim | Evidence | Status |
|---|---|---|---|
| 1 | Contradictory entrypoints | `PROJECT/AGENTS.md:1` = `v4.0.0`, 8 references to `.tasks/board.md`; `PROJECT/CLAUDE.md:1` = `v7.1.0`, declares `sprint/sprint.json` | Confirmed |
| 2 | Stale sprint state | `git show HEAD:sprint/sprint.json` = `S79-… status: completed`; **working tree** = `S77-supabase-advisor-hardening-2026-06-28`, `status: planned`, `current_feature: S77-001` (+315/−173, uncommitted) | Confirmed — and it is a **regression**, not forward progress |
| 3 | Toolchain mismatch | shell `node --version` = `v20.19.2`, `pnpm --version` = `10.25.0`; `package.json` engines = `22.17.0` / `11.7.0` | Confirmed — **but v22.17.0 is already installed under nvm**, and `packageManager: "pnpm@11.7.0"` + `corepack` are available |
| 4 | Root Vitest requires Supabase env | `SUPABASE_TEST_URL`, `SUPABASE_TEST_SERVICE_ROLE_KEY`, `SUPABASE_TEST_ANON_KEY` | Accepted from source plan — not re-run (toolchain blocked) |
| 5 | Frontend baseline green (3076 tests / 200 files, `vue-tsc` passes) | Not re-run — requires F0 | **Unverified** |
| 6 | Worktree/branch entropy | `git worktree list` = 41, `git branch` = 118 | Confirmed |
| 7 | Secret-bearing local permissions | `PROJECT/.claude/settings.local.json` — 73 KB, **461** `permissions.allow` entries, **187** credential-pattern hits; ignored via `~/.config/git/ignore` (never committed) | Confirmed |

Additional facts not in the source plan:

- `PROJECT/framework.json` version = **7.1.0**; `FRAMEWORK/VERSION` = **8.0.0**. The project is a migration target.
- `PROJECT/Makefile` has no `agent-doctor`, `agent-classify`, `qa-fast`, or `qa-full` target. Existing targets: `help dev dev-web kill build test lint typecheck frontend-verify pre-commit install clean worktree-add worktree-rm worktree-list ship hotfix release-status release-abort doctor`.
- `PROJECT/docs/engineering/` does not exist.
- `FRAMEWORK` has an unmerged branch `cx/bulk-framework-migration` (16 commits ahead of `main`, clean worktree, +4679 lines) implementing a bulk 7.x → current-VERSION migrator.

## The Ownership Conflict

`FRAMEWORK/migrate-v7-to-v8.sh:34-43` overwrites framework-owned trees in the target project:

```bash
for dir in skills commands agents rules; do
  cp -R "$FRAMEWORK_DIR/.claude/$dir/." "$PROJECT_DIR/.claude/$dir/"
done
cp -R "$FRAMEWORK_DIR/hooks/." "$PROJECT_DIR/hooks/"
cp "$FRAMEWORK_DIR/framework.json" "$PROJECT_DIR/framework.json"
```

It preserves *added* files, not *modified* copies of framework files. Therefore source-plan **Task 5** (hooks) and **Task 6** (rules + commands) would be silently reverted the next time the project is migrated.

By contrast, entrypoints are safe — the script only copies them when absent:

```bash
[[ -f "$PROJECT_DIR/CLAUDE.md" ]] || cp "$FRAMEWORK_DIR/core/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
[[ -f "$PROJECT_DIR/AGENTS.md" ]] || cp "$FRAMEWORK_DIR/core/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
```

**Resolution (approved 2026-07-26):** Tasks 5 and 6 are re-homed to `FRAMEWORK` and released as **v8.1.0**; the project receives them by migrating 7.1.0 → 8.1.0. This is the single deliberate deviation from the source plan's File Map.

## Task Ownership Map

| Source task | Owner repo | Phase |
|---|---|---|
| Task 1 — canonical shared contract | PROJECT | F1 |
| Task 2 — entrypoint parity | PROJECT | F1 |
| Task 3 — deterministic classifier | PROJECT | F2 |
| Task 4 — toolchain + quality gates | PROJECT | F2 |
| Task 5 — hooks reduced to guardrails | **FRAMEWORK** | F3 (step 5 → F0) |
| Task 6 — sprint/worktree state opt-in | **FRAMEWORK** | F3 (step 5 → F0) |
| Task 7 — parity + pilot validation | PROJECT | F5 |
| *(new)* migration 7.1.0 → 8.1.0 | both | F4 |

## Global Constraints

Inherited from the source plan, plus two additions:

- `PROJECT.md` remains the single source of truth for project facts; the shared contract owns execution policy.
- No production database, deployment, secrets, or environment-variable change without an explicit production gate.
- No new runtime dependency in either repository.
- No application feature code changes; no Supabase schema/RLS/Edge Function/Vercel changes.
- No worktree or branch deletion — cleanup is a separately approved maintenance task.
- **New:** no framework-owned file is edited inside `PROJECT`; such edits belong in `FRAMEWORK`.
- **New:** the uncommitted `PROJECT/sprint/sprint.json` diff is triaged (F0) before any phase reads or writes sprint state.

---

## F0 — Preconditions

**Owner:** PROJECT (local only) · **Gate:** must close before F1 · **Nothing here is committed except the sprint decision.**

- [ ] **Step 1: Pin the toolchain**

  ```bash
  cd ~/_VibeCoding/01_ACTIVE/melior-plus-mvp
  nvm use 22.17.0
  corepack enable && corepack prepare pnpm@11.7.0 --activate
  node --version && pnpm --version
  ```

  Expected: `v22.17.0` and `11.7.0`. Add `.nvmrc` containing `22.17.0` so the mismatch cannot recur silently (project-owned file, safe from migration).

- [ ] **Step 2: Confirm the frontend baseline**

  ```bash
  pnpm install --frozen-lockfile
  pnpm --filter @meliorplus/web-frontend typecheck
  pnpm --filter @meliorplus/web-frontend test:unit
  ```

  Record actual counts. This closes baseline claim #5, which is currently unverified. If the numbers differ from 3076 tests / 200 files, record the real numbers — do not restate the source plan's figures.

- [ ] **Step 3: Triage the sprint.json regression**

  ```bash
  git show HEAD:sprint/sprint.json | head -20
  git diff -- sprint/sprint.json | head -60
  ```

  Committed state is S79 `completed`; the working tree replaces it with S77 `planned`. Decide explicitly, and record the decision in the validation document (F5):

  - **(a) discard** — `git checkout -- sprint/sprint.json`, keeping S79 as committed history; or
  - **(b) archive** — move the working-tree S77 content to `sprint/archive/S77-supabase-advisor-hardening-2026-06-28.json`, restore S79, and commit the archive.

  Do **not** commit the working-tree diff as-is: it would make an older sprint the current state. Also decide the fate of the untracked `sprint/archive/S76-hardening-2026-06-22.json`.

- [ ] **Step 4: Contain the local credential exposure** *(source plan Task 5 Step 5)*

  `.claude/settings.local.json` holds 461 permission entries and 187 credential-pattern matches. It is ignored globally (`~/.config/git/ignore`), so nothing leaked into git history — but the material is live on disk.

  1. Rotate every affected credential in its control plane (Supabase, Vercel, secret manager) — **not** in the repository.
  2. Back the file up outside the repo, then replace it with a minimal file allowing only the F2 canonical commands.
  3. Verify no credential pattern remains in *tracked* files:

  ```bash
  rg -n "eyJ|sbp_|SERVICE_ROLE|ANON_KEY|SUPABASE_ACCESS_TOKEN|password" \
    .claude/settings.json hooks framework.json Makefile
  ```

  Expected: no output.

- [ ] **Step 5: Track the source plan**

  The source plan file is untracked. Commit it so the work has a referenceable base:

  ```bash
  git add docs/superpowers/plans/2026-07-26-claude-codex-workflow-optimization.md
  git commit -m "docs(workflow): track Claude/Codex optimization plan"
  ```

**F0 exit criteria:** correct Node/pnpm active · real frontend baseline numbers recorded · sprint state decided and no longer a silent regression · local permissions rebuilt with zero credential material · source plan tracked.

---

## F1 — Canonical Contract and Entrypoint Parity

**Owner:** PROJECT · **Source tasks:** 1, 2 · **Gate:** F0 closed

- [ ] **Step 1: Create `docs/engineering/agent-workflow.md`** *(Task 1 Step 1)*

  Exact sections required by the source plan: `Purpose`, `Source of Truth`, `Operating Modes`, `Task Classification`, `Execution Loop`, `Quality Gates`, `Error Classification`, `Stop-Loss Rules`, `Production Gate`, `Git/Worktree Policy`, `Claude/Codex Tool Parity`. Default loop:

  ```text
  Understand → classify → inspect only relevant files → change minimally → run the narrowest valid check → report evidence
  ```

  Include the four stop-loss rules verbatim from the source plan (one identical environment failure → `make agent-doctor`; two failed attempts without a new hypothesis → report blocker; no completion without a real check result, but an unavailable environment is an environment blocker; no unrelated sprint/snapshot/worktree reading for Fast tasks).

  Note the directory does not exist yet and must be created.

- [ ] **Step 2: Strip stale process text from `PROJECT.md`** *(Task 1 Step 2)*

  Keep stack, architecture, domain, security, persistence, UI-language, deployment facts. Replace `Current sprint` prose with a link to the state file plus the rule that state is subordinate to the user request. Link to the contract.

- [ ] **Step 3: Rewrite both entrypoints as thin adapters** *(Task 2 Steps 1–2)*

  `CLAUDE.md` and `AGENTS.md` carry the same `## Shared Contract` section in the same order; `CLAUDE.md` adds only Claude command syntax, `AGENTS.md` only Codex session/tool syntax. Remove from `AGENTS.md`: the `.tasks/board.md` requirement, "CX only" ownership rules, the mandatory-worktree rule, and the v4 `In Review` protocol. Move any safety constraint worth keeping into the contract or `PROJECT.md` rather than deleting it.

- [ ] **Step 4: Add a parity check script** *(Task 2 Step 3)*

  The source plan's `diff -u <(sed …) <(sed …)` relies on process substitution. Implement `scripts/check-entrypoint-parity.mjs` instead — it extracts the `## Shared Contract` section from both files and exits non-zero on divergence. Wire it into the Makefile in F2.

- [ ] **Step 5: Validate** *(Task 1 Step 3, Task 2 Step 4)*

  ```bash
  rg -n "board\.md|MANDATORY|must ask|after every step|auto.*sprint|one feature at a time" \
    docs/engineering/agent-workflow.md PROJECT.md
  rg -n "\.tasks/board\.md|Assigned to: CX|after each step|auto.*sprint" CLAUDE.md AGENTS.md
  node scripts/check-entrypoint-parity.mjs
  git diff --check
  ```

  Expected: no stale board reference as an active state source; no per-step user-pause rule; no automatic sprint creation; parity script exits 0.

- [ ] **Step 6: Commit in two pieces** *(Task 1 Step 4, Task 2 Step 5)*

  ```bash
  git add docs/engineering/agent-workflow.md PROJECT.md
  git commit -m "docs(workflow): define shared Claude and Codex agent contract"
  git add CLAUDE.md AGENTS.md scripts/check-entrypoint-parity.mjs
  git commit -m "chore(workflow): align Claude and Codex entrypoints"
  ```

**F1 exit criteria:** one contract document exists · both entrypoints reference it and contradict nothing · parity check is executable and green.

---

## F2 — Toolchain Diagnosis, Quality Gates, Classifier

**Owner:** PROJECT · **Source tasks:** 4, then 3 · **Gate:** F1 closed

Order follows the source plan's rollout (Task 4 before Task 3): the classifier's output is only useful once the gates it names exist.

- [ ] **Step 1: Implement `scripts/agent-doctor.mjs`** *(Task 4 Step 1)*

  Checks in order: Node satisfies `22.17.0`; pnpm satisfies `11.7.0`; root `node_modules` and frontend dependencies exist; `pnpm --version` executes without a runtime exception; the frontend package exposes `test:unit` and `typecheck`. One line per check with `PASS` / `FAIL` / `BLOCKED`. Exit 0 only when all local checks pass. Never read `.env` or print environment values.

- [ ] **Step 2: Add `qa-fast` and `qa-full` to the Makefile** *(Task 4 Steps 2–4)*

  `qa-fast: agent-doctor` → frontend `test:unit` + `typecheck`. Fast mode may substitute one focused Vitest path but still runs typecheck for TypeScript changes.

  `qa-full: agent-doctor` → assert the three `SUPABASE_TEST_*` variables are non-empty and exit 2 with a `BLOCKED:` message otherwise, then `pnpm test` and the frontend `verify` script. The gate must fail immediately with a classified environment message rather than running partial commands repeatedly.

  Add a root `qa:fast` script invoking `make qa-fast`, and document that root `pnpm test` is not the default frontend check. Also register the F1 parity script as a Makefile target here.

- [ ] **Step 3: Implement `scripts/agent-task-classifier.mjs`** *(Task 3 Steps 1–2)*

  Deterministic rules only:

  ```text
  high-risk if --db, --security, --production, or --ambiguous is present
  standard  if --files is greater than 2 or --feature is present
  fast      otherwise
  ```

  Reject negative or non-integer `--files` with exit code 2. Never inspect source filenames to guess risk. Output one machine-readable line: `mode=…`, reasons, required checks. Add `agent-classify:` to the Makefile with `ARGS` pass-through.

- [ ] **Step 4: Validate the gates and the classifier** *(Task 4 Step 5, Task 3 Step 3)*

  ```bash
  make agent-doctor
  make qa-fast
  make qa-full
  make agent-classify ARGS="--files 1"       # → mode=fast
  make agent-classify ARGS="--files 5 --feature"  # → mode=standard
  make agent-classify ARGS="--db"            # → mode=high-risk
  make agent-classify ARGS="--files 0"       # → mode=fast
  make agent-classify ARGS="--files nope"    # → exit 2
  ```

  Note the source plan expects `agent-doctor` to *detect* the Node/pnpm mismatch. After F0 the shell is already correct, so record a second run from an un-pinned shell to prove the detection path fires.

- [ ] **Step 5: Commit** *(Task 4 Step 6, Task 3 Step 4)*

  ```bash
  git add scripts/agent-doctor.mjs Makefile package.json docs/engineering/agent-workflow.md
  git commit -m "chore(tooling): add classified fast and full quality gates"
  git add scripts/agent-task-classifier.mjs Makefile docs/engineering/agent-workflow.md
  git commit -m "feat(workflow): add deterministic task classification"
  ```

**F2 exit criteria:** `make agent-doctor` distinguishes environment failure from code failure · `qa-fast` is the default frontend gate and reaches the F0 baseline · `qa-full` reports missing Supabase credentials in one `BLOCKED` message with no retry loop · classifier output is deterministic and rejects bad input.

---

## F3 — Framework Upstream: Advisory Hooks and Opt-in State

**Owner:** FRAMEWORK · **Source tasks:** 5, 6 (minus their local-only Step 5, done in F0) · **Gate:** F2 closed
**Branch:** `cc/workflow-optimization` off `main`. Target release: **v8.1.0**.

Before writing, read the current framework files — v8.0.0 already moved in this direction (`CHANGELOG.md`: "Changed test-file protection from a hard block to a failed-test advisory"). Do not re-solve what v8 already solved.

- [ ] **Step 1: Reconcile with v8.0.0 first**

  For each source-plan complaint, check whether `FRAMEWORK`'s v8 file already satisfies it, and record the finding. Only genuinely remaining gaps become work items. Files to read: `hooks/type-check.js`, `hooks/auto-format.js`, `hooks/context-monitor.js`, `hooks/plan-to-sprint.js`, `.claude/rules/{autonomy,delegation,execution-integrity,context-management}.md`, `.claude/commands/{feature,done,orchestrate,context-refresh}.md`, `core/settings.template.json`.

- [ ] **Step 2: Make hooks advisory** *(Task 5 Steps 1–4)*

  `type-check.js` must not run a repository-wide command after every TypeScript edit — print `typecheck pending`, or run only when `AGENT_RUN_EDIT_CHECKS=1` is set. `auto-format.js` stays opt-in and never silently rewrites a file unless formatting was requested. `plan-to-sprint.js` stops writing `sprint/sprint.json` or creating a branch and emits only:

  ```text
  Plan approved. Sprint tracking is optional; run sprint initialization only for Standard or High-risk work.
  ```

  `context-monitor.js` keeps warnings but must not imply the agent should commit user changes automatically, and must not mutate tracked files or state. `core/settings.template.json` keeps environment-file blocking and production/destructive guards; no broad `Bash(*)` permission, no historical command strings.

- [ ] **Step 3: Introduce the three operating modes into the rules pack** *(Task 6 Steps 1–2, 6)*

  Rewrite `.claude/rules/autonomy.md` around Fast / Standard / High-risk: drop the universal five-step plan, the per-step user gate, mandatory tester-agent activation, and sprint updates for all work. Keep evidence-based completion, honest failure reporting, production approval, and destructive-operation protection in **every** mode.

  In `delegation.md`, delegation becomes allowed only for Standard/High-risk work where a separate context materially reduces risk — never triggered by a bare line-count threshold. Reconcile `execution-integrity.md` Rule 1 and Rule 5 and `context-management.md` with the modes so they no longer mandate contradictory behavior.

  Worktree policy: Fast stays in the current worktree; Standard uses at most one dedicated worktree; High-risk uses an isolated worktree with explicit branch names; pruning is a separate approved operation, never a session hook.

  **Cross-check:** these four rule files are also loaded for this very framework repository. Verify the rewrite does not weaken the safety posture the framework itself depends on.

- [ ] **Step 4: Make commands conditional and stale-safe** *(Task 6 Steps 3–5)*

  `/feature` requires an explicit feature ID or explicit Standard/High-risk sprint mode. `/done` accepts a Fast task without `current_feature`, sprint mutation, peer review, or a full root suite — while still requiring evidence for the changed scope. Add stale-state detection: before using `sprint/sprint.json`, compare `last_updated` and the active branch against `git status` and the current request; on mismatch print `STALE_STATE` and continue with the user request. Never overwrite a sprint file whose working-tree diff changes sprint identity or feature state — report the conflict and ask for a separate reconciliation task.

  The F0 Step 3 situation is the canonical regression fixture for this behavior.

- [ ] **Step 5: Version, test, document**

  Bump `VERSION` and `framework.json` to `8.1.0`, add a `CHANGELOG.md` entry, and run the framework's own suite:

  ```bash
  cd ~/_VibeCoding/_tools/DG-VibeCoding-framework
  ./tests/run.sh
  node hooks/plan-to-sprint.js <<'JSON'
  {"tool_name":"ExitPlanMode"}
  JSON
  rg -n "eyJ|sbp_|SERVICE_ROLE|ANON_KEY|SUPABASE_ACCESS_TOKEN|password" \
    .claude core/settings.template.json hooks framework.json
  ```

  Expected: suite green; plan approval produces an informational message only and writes nothing; no credential pattern in tracked framework files.

- [ ] **Step 6: Commit and merge to `main`**

  ```bash
  git add hooks .claude/rules .claude/commands core/settings.template.json \
          framework.json VERSION CHANGELOG.md
  git commit -m "refactor(workflow): make hooks advisory and sprint state opt-in"
  ```

**F3 exit criteria:** framework v8.1.0 on `main`, own test suite green · no hook runs a full check per edit · plan approval mutates nothing · rules and commands describe one consistent three-mode model.

---

## F4 — Migrate the Project to v8.1.0

**Owner:** both · **Gate:** F3 merged — **explicit user approval required before this phase runs**

This phase rewrites `PROJECT`'s `hooks/`, `.claude/{rules,commands,agents,skills}/`, and `framework.json` from the framework. It is the riskiest step in the plan and the reason the ownership split exists.

- [ ] **Step 1: Decide the migration vehicle**

  Two options — resolve before running anything:

  - `FRAMEWORK/migrate-v7-to-v8.sh <project> [--dry-run]` — single-project, already on `main`, proven path.
  - `cx/bulk-framework-migration` (16 commits, unmerged, +4679 lines, plan checkboxes never ticked) — purpose-built for 7.x → current VERSION, dry-run by default. Using it here would be its first real exercise, but it is unreviewed and unmerged.

  Recommendation: run the single-project script for this migration; treat merging the bulk branch as separate work.

- [ ] **Step 2: Dry run and snapshot**

  ```bash
  cd ~/_VibeCoding/01_ACTIVE/melior-plus-mvp
  git status --short            # must be clean apart from intended work
  ~/_VibeCoding/_tools/DG-VibeCoding-framework/migrate-v7-to-v8.sh "$PWD" --dry-run
  ```

  The script also writes a `.dg-framework-backup-*` directory on the real run; confirm it lands somewhere acceptable and is git-ignored.

- [ ] **Step 3: Migrate on a dedicated branch**

  Run the real migration, then diff every framework-owned tree against the framework to confirm the F3 work arrived intact, and confirm `CLAUDE.md` / `AGENTS.md` / `PROJECT.md` from F1 were **not** overwritten (the script only copies them when absent — verify, do not assume).

- [ ] **Step 4: Re-run the F2 gates after migration**

  ```bash
  make agent-doctor && make qa-fast
  node scripts/check-entrypoint-parity.mjs
  ```

  Expected: identical results to F2. Any regression here means a framework file overwrote project-owned behavior — stop and report.

**F4 exit criteria:** `PROJECT/framework.json` = 8.1.0 · F3 hooks/rules/commands present in the project · F1 and F2 artifacts intact · gates still green.

---

## F5 — Parity Matrix, Pilot, and Handoff

**Owner:** PROJECT · **Source task:** 7 · **Gate:** F4 closed

- [ ] **Step 1: Record the parity matrix** *(Task 7 Step 1)*

  Five rows in `docs/engineering/agent-workflow-validation.md`: Fast TypeScript bugfix · Standard UI change · High-risk RLS change · toolchain mismatch · missing Supabase test env. Each row states the Claude command path, the Codex command path, and the expected result.

- [ ] **Step 2: Run the Fast pilot** *(Task 7 Step 2)*

  ```bash
  make agent-doctor
  make agent-classify ARGS="--files 1"
  pnpm --filter @meliorplus/web-frontend test:unit -- --run tests/composables/useCommandSearch.spec.ts
  pnpm --filter @meliorplus/web-frontend typecheck
  ```

  Record elapsed time, output summary, files inspected, and whether any sprint or worktree state changed. Confirm the named spec file still exists before relying on it.

- [ ] **Step 3: Prove no accidental state mutation** *(Task 7 Step 3)*

  ```bash
  git status --short
  git diff -- sprint/sprint.json
  git worktree list
  ```

  Expected: no sprint change, no new worktree, worktree count unchanged at 41.

- [ ] **Step 4: Standard and High-risk dry runs** *(Task 7 Step 4)*

  ```bash
  make agent-classify ARGS="--files 5 --feature"
  make agent-classify ARGS="--db"
  ```

  Classifier-only. No database touched, nothing deployed.

- [ ] **Step 5: Document acceptance and update the README** *(Task 7 Steps 5–6)*

  The validation document records actual output or exact failure messages, the date, Node/pnpm versions, selected mode, the F0 sprint decision, and unresolved exceptions. It must not contain "should work". Replace the README's default workflow example with:

  ```text
  make agent-doctor
  make agent-classify ARGS="--files 1"
  inspect → patch → focused check → make qa-fast when applicable
  ```

- [ ] **Step 6: Commit** *(Task 7 Step 7)*

  ```bash
  git add docs/engineering/agent-workflow-validation.md README.md docs/engineering/agent-workflow.md
  git commit -m "docs(workflow): record Claude and Codex parity validation"
  ```

**F5 exit criteria:** every source-plan acceptance criterion has recorded evidence, including the ones that F3/F4 moved upstream.

---

## Phase Gates

Per `.claude/rules/execution-integrity.md` Rule 5, stop after each phase and report evidence before starting the next.

| Gate | Blocks | Reason |
|---|---|---|
| F0 → F1 | toolchain unpinned, or sprint regression undecided | F2/F5 are unverifiable without a working toolchain; F3 Step 4 needs the sprint decision as its fixture |
| F2 → F3 | gates not green in PROJECT | F3 rewrites shared rules; do it against a known-good project baseline |
| F3 → F4 | **explicit user approval** | F4 overwrites framework-owned trees in a repo with 41 worktrees and 118 branches |
| F4 → F5 | any F2 gate regressed after migration | a regression means the migration clobbered project-owned behavior |

## Acceptance Criteria

The source plan's ten criteria carry over unchanged, with ownership annotated:

- Claude and Codex share one contract with no contradictory board/branch/sprint/testing rules — **F1**
- A one-file frontend fix completes without sprint init, worktree, delegation, or per-step confirmation — **F3 + F5**
- `make agent-doctor` detects a Node/pnpm mismatch before any expensive command — **F2**
- `make qa-fast` is the default frontend gate on the verified workspace path — **F2**
- `make qa-full` reports missing Supabase credentials without disguising an environment blocker as a code failure — **F2**
- Plan approval does not mutate sprint state — **F3**
- Stale sprint state cannot silently replace the current request — **F3**
- No tracked workflow/config file contains embedded credentials or secret-bearing command patterns — **F0 (project) + F3 (framework)**
- A recorded pilot shows the fast path changes no sprint or worktree state — **F5**
- Production safety, RLS, secrets, and evidence-based completion protections remain intact for High-risk work — **F3**

Plus two added by this plan:

- The F3 work survives a full framework migration — proven by re-running the F2 gates in **F4 Step 4**.
- No framework-owned file in `PROJECT` diverges from `FRAMEWORK` v8.1.0 after F4.

## Explicit Non-Goals

Inherited from the source plan, unchanged: no application feature code · no Supabase schema, RLS, Edge Function, Vercel, or production-data change · no worktree or branch deletion · no credential rotation inside the repository · no new agent framework, orchestration service, or runtime dependency.

Added: this plan does not merge `cx/bulk-framework-migration`, does not tick that branch's plan checkboxes, and does not migrate any project other than `melior-plus-mvp`.

## Open Questions

1. **F0 Step 3** — discard or archive the working-tree S77 sprint content? Needs a human decision; the plan refuses to guess.
2. **F4 Step 1** — single-project migrator (recommended) or the unmerged bulk branch?
3. **F3 Step 1** — how much of Tasks 5/6 does v8.0.0 already satisfy? Answerable only by reading the current framework files; the answer shrinks F3.

## Deviations From the Source Plan

| Source plan says | This plan does | Why |
|---|---|---|
| Modify `hooks/*.js`, `.claude/rules/*`, `.claude/commands/*`, `framework.json` in the project | Do it in `FRAMEWORK`, release v8.1.0, migrate | `migrate-v7-to-v8.sh:34-43` overwrites those trees; the work would be lost |
| Task 5 Step 5 sits inside the hooks task | Moved to **F0 Step 4** | Credential containment is a security item and must not wait five phases |
| Parity check via `diff -u <(sed …) <(sed …)` | `scripts/check-entrypoint-parity.mjs` | The source plan already flags process substitution as replaceable; a script is testable and shell-independent |
| Baseline claim #5 treated as verified | Marked **unverified**, re-measured in F0 Step 2 | It could not be re-run under the broken toolchain |
| `sprint/sprint.json` diff described as "user-owned changes" to preserve | Triaged as a probable **regression** (S79 → S77) with an explicit discard/archive decision | Committed history is newer than the working tree; committing it would make an old sprint current |
| No migration step | **F4** added | The project is on 7.1.0; without this the framework work never reaches it |
