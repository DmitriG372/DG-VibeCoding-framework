---
description: "Complete the current feature with mandatory testing and git commit."
---

# /done

Complete the current feature with mandatory testing, stub detection, and git commit. Moves the feature to `in_review` — `/peer-review` closes it as `completed`.

## Usage

```
/done [--skip-tests] [--skip-stubs] [--no-commit] [--message "custom commit message"]
```

## Instructions

### Step 1: Detect agent identity + validate state
- `CLAUDE.md` → `$AGENT_ID="cc"`; `AGENTS.md` → `$AGENT_ID="cx"`
- Read `sprint/sprint.json`, find `current_feature`
- If null → "No feature in progress. Use /feature to start."
- Warn if `assigned_to` ≠ `$AGENT_ID`

### Step 2: Verify acceptance criteria (if `feature.acceptance` exists)
1. **Truths** — each `acceptance.truths[]` must be observable
2. **Artifacts** — each `acceptance.artifacts[]` must exist on disk
3. **Verify command** — run `acceptance.verify` if set
4. Any failure → stop, report, do NOT proceed to tests

This is goal-backward verification — check the OUTCOME, not just the process.

### Step 3: Run tests (MANDATORY unless `--skip-tests`)
1. Activate the `tester` agent
2. If no test file exists for the feature → "Tests required. Create tests first."
3. Run the suite: `pnpm test` or project-specific command
4. **Show the actual runner output** — never summarize into "tests pass"
5. Evaluate visible summary:
   - FAILED → stop, show errors, feature stays `in_progress`
   - PASSED → continue

> KEELATUD: claiming "tests pass" without real output. Execution-integrity Rule 3.

### Step 4: Stub detection (MANDATORY unless `--skip-stubs`)
Run the shared script — it handles the grep patterns, exit codes, and block mode:

```bash
STUB_CHECK_BLOCK=1 scripts/stub-check.sh --staged
```

- Exit 0 → clean, proceed
- Exit 2 → BLOCKED, `hooks/completion-guard.js` surfaces the findings; resolve then re-run `/done`

Hard blockers: TODO/FIXME in changed files, empty function bodies, placeholder text (lorem/asdf/foo-bar).
Warnings: `console.log`/`print()` inside catch/except blocks.

### Step 5: Git commit
```bash
git add <relevant files>
git commit -m "feat(<scope>): F<ID> <name>

- <key change 1>
- <key change 2>

Acceptance met:
- <criterion 1>
- <criterion 2>

Co-Authored-By: Claude <noreply@anthropic.com>"
```

`F<ID>` is mandatory for git-based sprint reconstruction.

Capture hash + timestamp:
```bash
git rev-parse HEAD
git log -1 --format="%aI"
```

### Step 6: Update sprint.json (atomic)
Set on the feature:
- `status: "in_review"`
- `tested: true`
- `git: { hash, message, timestamp }`
- `completed_at: null`

Set at root:
- `current_feature: null`
- `stats` recomputed
- `last_updated: "<ISO>"`
- `last_updated_by: "$AGENT_ID"`

`sprint/sprint.md` is regenerated automatically by the `sprint-sync` hook — do not edit manually.

### Step 7: Show next feature + NotebookLM sync reminder
1. Find next `pending` feature, display summary
2. If `.claude/notebook.json` exists, check commits since `last_sync_commit`:
   ```bash
   git rev-list --count <last_sync_commit>..HEAD 2>/dev/null || echo 0
   ```
   If > 5 commits behind → suggest `/sync-notebook`

## Options

| Option | Description |
|--------|-------------|
| `--skip-tests` | Skip the test gate (NOT RECOMMENDED — execution-integrity violation) |
| `--skip-stubs` | Skip stub detection (NOT RECOMMENDED) |
| `--no-commit` | Update sprint status only, no git commit |
| `--message "..."` | Override the default commit message |

## Rules

1. Tests are mandatory — the runner must have executed and shown output
2. One commit per feature — atomic git history
3. `sprint.json` is the single source of truth — atomic writes
4. `/done` → `in_review`; `/peer-review` → `completed`
5. `last_updated_by` must reflect the acting agent
6. `sprint.md` is auto-generated — never edit manually
