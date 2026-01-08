---
description: "Complete the current feature with mandatory testing and git commit."
---

# Command: /done

Complete the current feature with mandatory testing and git commit.

## Usage

```bash
/done [--skip-tests] [--message "custom commit message"]
```

## Instructions

### Step 1: Validate State

1. **Read sprint/sprint.json**
2. **Check current_feature**
   - If null: "No feature in progress. Use /feature to start."
3. **Get feature details**

### Step 2: Run Tests (MANDATORY)

1. **Activate tester agent**
2. **Check for tests**
   - Look for test files related to feature
   - If no tests exist: "Tests required. Create tests first."
3. **Run test suite**
   ```bash
   npm test  # or project-specific command
   ```
4. **Evaluate results**
   - If tests FAIL: Stop, show errors, do NOT mark done
   - If tests PASS: Continue to commit

### Step 3: Git Commit

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

   🤖 Generated with Claude Code

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

   **IMPORTANT:** Commit message MUST include `F<ID>` pattern for git tracking.

3. **Capture git hash and timestamp**

   ```bash
   git rev-parse HEAD        # Get full hash
   git log -1 --format="%aI" # Get ISO timestamp
   ```

### Step 4: Update sprint.json (v2.2 format)

```json
{
  "features": [
    {
      "id": "F001",
      "status": "done",
      "tested": true,
      "git": {
        "hash": "abc1234def5678...",
        "message": "feat(scope): F001 feature name",
        "timestamp": "2025-12-06T12:00:00+02:00"
      }
    }
  ],
  "current_feature": null,
  "stats": {
    "completed": 1,
    "in_progress": 0,
    "pending": 4
  },
  "last_verified": "<current ISO timestamp>"
}
```

**Git info is required** - This enables `/sprint-reconstruct` to rebuild from git history.

### Step 5: Update progress.md

1. Move feature from "In Progress" to "Completed"
2. Add to commit log table
3. Update progress bar
4. Add timestamp

### Step 6: Show Next Feature

1. Find next pending feature
2. Display summary

### Step 7: Auto-Sync All Files (MANDATORY)

1. **Run /sync automatically**
   - Updates progress.md from sprint.json
   - Updates PROJECT.md with sprint progress
   - Ensures all framework files match sprint.json

2. **Report sync results**
   - Show updated file count
   - Confirm consistency

## Output Format

### Success

```text
╔══════════════════════════════════════════════════╗
║  Feature Completed: F001                         ║
╚══════════════════════════════════════════════════╝

✓ Tests passed (12/12)
✓ Committed: abc1234
✓ sprint.json updated
✓ progress.md updated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sprint Progress: [████░░░░░░] 20% (1/5)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next: F002 - Product catalog
Use /feature to start.
```

### Test Failure

```text
╔══════════════════════════════════════════════════╗
║  Cannot Complete: Tests Failed                   ║
╚══════════════════════════════════════════════════╝

✗ Tests failed (10/12)

Failed tests:
  • auth.test.ts:45 - login should return JWT
  • auth.test.ts:67 - invalid password should reject

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
  • User can register with email
  • User can login
  • JWT token is returned

Then run /done again.
```

## Options

| Option | Description |
|--------|-------------|
| `--skip-tests` | Skip test requirement (NOT RECOMMENDED) |
| `--message "..."` | Custom commit message |
| `--no-commit` | Update status without committing |

## Rules

1. **Tests are mandatory** - No exceptions by default
2. **One commit per feature** - Clean git history
3. **Atomic updates** - sprint.json and progress.md together
4. **No partial completion** - Either fully done or still in_progress
5. **Auto-sync always runs** - Framework files stay in sync after /done

---

*Part of DG-VibeCoding-Framework v2.6*
