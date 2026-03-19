---
description: "Complete the current feature with mandatory testing and git commit."
---

# Command: /done

Complete the current feature with mandatory testing and git commit.

## Usage

```bash
/done [--skip-tests] [--skip-stubs] [--message "custom commit message"]
```

## Instructions

### Step 0: Detect Agent Identity

Determine which agent you are:
- If context loaded from CLAUDE.md → agent = "cc"
- If context loaded from AGENTS.md → agent = "cx"
- Fallback: ask user

Store as `$AGENT_ID` for sprint.json updates.

### Step 1: Validate State

1. **Read sprint/sprint.json**
2. **Check current_feature**
   - If null: "No feature in progress. Use /feature to start."
3. **Get feature details**
4. **Verify assignment** -- confirm `assigned_to` matches `$AGENT_ID` (warn if mismatch)

### Step 2: Verify Acceptance Criteria (if defined)

If the feature has an `acceptance` block in sprint.json:

1. **Check truths** — for each `acceptance.truths[]` entry, verify it is observable
2. **Check artifacts** — for each `acceptance.artifacts[]`, verify file exists:
   ```bash
   test -f <artifact_path> && echo "✓ exists" || echo "✗ MISSING"
   ```
3. **Run verify command** — if `acceptance.verify` is set:
   ```bash
   eval "$VERIFY_CMD"
   ```
4. **If any check fails:** Stop and report. Do NOT proceed to tests.

> This is goal-backward verification — we check the OUTCOME, not just the process.

### Step 3: Run Tests (MANDATORY)

1. **Activate tester agent**
2. **Check for tests**
   - Look for test files related to feature
   - If no tests exist: "Tests required. Create tests first."
3. **Run test suite**
   ```bash
   npm test  # or project-specific command from Makefile
   ```
4. **SHOW the actual test output** (ära kokkuvõta)
   - Kuva tegelik test runner väljund
   - Minimaalselt: total/passed/failed arvud ja veateated
5. **Hinda tulemusi näidatud väljundi põhjal**
   - If tests FAIL: Stop, show errors, do NOT mark done
   - If tests PASS: Continue to commit

> KEELATUD: Ära ütle "tests pass" ilma tegelikku väljundit näitamata.
> KEELATUD: Ära jäta teste käivitamata ja väida et need läbisid.

### Step 4: Stub Detection (MANDATORY)

Scan modified files for placeholder code that should not ship:

```bash
# Get files changed in this feature
git diff --name-only HEAD~1..HEAD 2>/dev/null || git diff --cached --name-only

# Scan for stubs (exclude test files and config)
grep -rn "TODO\|FIXME\|HACK\|XXX\|PLACEHOLDER" <changed_files> --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.py' --include='*.vue' || true
grep -rn "return null\|return undefined\|pass$\|\.\.\.$$" <changed_files> || true
grep -rn "console\.log\|print(" <changed_files> --include='*.ts' --include='*.tsx' --include='*.js' --include='*.py' | grep -i "error\|catch\|except" || true
grep -rn "lorem\|ipsum\|asdf\|test123\|foo\|bar\|baz" <changed_files> --include='*.ts' --include='*.tsx' --include='*.vue' || true
```

**Evaluate findings:**
- `TODO`/`FIXME` in changed files → BLOCK (must resolve or explicitly defer)
- Empty function bodies → BLOCK (stub code)
- `console.log` in error handlers → WARN (should use proper error handling)
- Placeholder text → BLOCK (not production-ready)

**If stubs found:**
```text
╔══════════════════════════════════════════════════╗
║  Stub Code Detected — Cannot Complete            ║
╚══════════════════════════════════════════════════╝

Found in changed files:
  ✗ src/auth/login.ts:45  — TODO: implement password hashing
  ✗ src/auth/handler.ts:12 — empty catch block (console.log only)
  ⚠ src/utils/format.ts:8  — console.log in error handler

Resolve stubs, then run /done again.
Feature remains: in_progress
```

**If clean:** Continue to git commit.

> Skip stub detection with `--skip-stubs` (NOT RECOMMENDED).

### Step 5: Git Commit

1. **Stage relevant files**

   ```bash
   git add .
   ```

2. **Create descriptive commit with feature ID**

   ```bash
   git commit -m "feat(<scope>): F<ID> <feature name>

   - <key change 1>
   - <key change 2>

   Acceptance criteria met:
   - <criterion 1>
   - <criterion 2>

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

   **IMPORTANT:** Commit message MUST include `F<ID>` pattern for git tracking.

3. **Capture git hash and timestamp**

   ```bash
   git rev-parse HEAD        # Get full hash
   git log -1 --format="%aI" # Get ISO timestamp
   ```

### Step 6: Update sprint.json

Update the feature and sprint state:

```json
{
  "features": [
    {
      "id": "F001",
      "status": "in_review",
      "tested": true,
      "git": {
        "hash": "abc1234def5678...",
        "message": "feat(scope): F001 feature name",
        "timestamp": "2026-03-13T12:00:00+02:00"
      },
      "completed_at": null
    }
  ],
  "current_feature": null,
  "stats": {
    "total": 5,
    "pending": 4,
    "in_progress": 0,
    "in_review": 1,
    "completed": 0
  },
  "last_updated": "2026-03-13T12:00:00+02:00",
  "last_updated_by": "$AGENT_ID"
}
```

**Git info is required** -- this enables sprint reconstruction from git history.

### Step 7: Sprint.md Auto-Regeneration

The `sprint/sprint.md` file is regenerated automatically by the sprint-sync hook after sprint.json is updated. Do NOT update sprint.md manually.

### Step 8: Show Next Feature

1. Find next pending feature
2. Display summary

### Step 9: NotebookLM Sync Reminder

If `.claude/notebook.json` exists:
1. Read `last_sync_commit`
2. Count commits since last sync:
   ```bash
   git rev-list --count <last_sync_commit>..HEAD 2>/dev/null || echo 0
   ```
3. If > 5 commits behind:
   ```
   NotebookLM pole sunkroniseeritud (X commiti taga).
   Kasuta /sync-notebook uuendamiseks.
   ```
4. If 5 or fewer: skip silently

## Output Format

### Success

```text
╔══════════════════════════════════════════════════╗
║  Feature Ready For Review: F001                  ║
╚══════════════════════════════════════════════════╝

Agent: $AGENT_ID
Branch: cc/F001-user-auth

Evidence:
+ Tests passed (12/12) — actual output shown above
+ Files changed: src/auth/login.ts, src/auth/schema.ts
+ Committed: abc1234
+ sprint.json updated (status: in_review)
~ sprint.md regenerated by hook

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sprint Progress: [====......] 20% (1/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next: ask a partner to run /peer-review or continue with /feature after review.
```

### Test Failure

```text
╔══════════════════════════════════════════════════╗
║  Cannot Complete: Tests Failed                   ║
╚══════════════════════════════════════════════════╝

x Tests failed (10/12)

Failed tests:
  - auth.test.ts:45 - login should return JWT
  - auth.test.ts:67 - invalid password should reject

Fix the failing tests, then run /done again.
Feature remains: in_progress
```

### No Tests

```text
╔══════════════════════════════════════════════════╗
║  Cannot Complete: No Tests Found                 ║
╚══════════════════════════════════════════════════╝

Feature: F001 - User authentication

No test files found for this feature.
Tests are REQUIRED before marking as done.

Suggested test file: src/auth/__tests__/auth.test.ts

Create tests that verify:
  - User can register with email
  - User can login
  - JWT token is returned

Then run /done again.
```

## Options

| Option | Description |
|--------|-------------|
| `--skip-tests` | Skip test requirement (NOT RECOMMENDED) |
| `--skip-stubs` | Skip stub detection (NOT RECOMMENDED) |
| `--message "..."` | Custom commit message |
| `--no-commit` | Update status without committing |

## Rules

1. **Tests are mandatory** -- No exceptions by default
2. **One commit per feature** -- Clean git history
3. **Atomic updates** -- sprint.json is the single source of truth
4. **No partial completion** -- Either fully done or still in_progress
5. **Agent tracking** -- `last_updated_by` always set to `$AGENT_ID`
6. **/done moves a feature to `in_review`** -- `/peer-review` closes it as `completed`
7. **sprint.md is auto-generated** -- Never update it manually

---

*Part of DG-VibeCoding-Framework v5.1.0*
