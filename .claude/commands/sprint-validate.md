---
description: "Kontrollib sprint.json konsistentsust ja framework failide sünkrooni."
---

# Command: /sprint-validate

Kontrollib sprint.json konsistentsust ja framework failide sünkrooni.

## Usage

```bash
/sprint-validate
```

## Instructions

### Step 1: Load sprint.json

1. **Read sprint/sprint.json**
2. **Extract:**
   - `stats.total`, `stats.completed`, `stats.in_progress`, `stats.pending`
   - `features` array with individual statuses
   - `current_feature` value

### Step 2: Validate Stats Match Features

1. **Count features by status:**

   ```text
   actual_done = features.filter(status == "done").length
   actual_in_progress = features.filter(status == "in_progress").length
   actual_pending = features.filter(status == "pending").length
   ```

2. **Compare with stats:**
   - `stats.completed` should equal `actual_done`
   - `stats.in_progress` should equal `actual_in_progress`
   - `stats.pending` should equal `actual_pending`

3. **Report discrepancies:**

   ```text
   ✗ Stats mismatch:
     completed: 6 (stats) vs 8 (actual)
     in_progress: 0 (stats) vs 0 (actual)
     pending: 2 (stats) vs 0 (actual)
   ```

### Step 3: Validate current_feature

1. **If current_feature is set:**
   - That feature MUST have status "in_progress"
   - If not: report error

2. **If current_feature is null:**
   - No features should be "in_progress"
   - If any are: report error

3. **Report:**

   ```text
   ✓ current_feature consistency OK
   ```

   or

   ```text
   ✗ current_feature inconsistency:
     current_feature: F003
     F003 status: done (should be in_progress)
   ```

### Step 4: Validate progress.md

1. **Read sprint/progress.md**
2. **Extract progress percentage from file**
3. **Calculate expected:** `(completed / total) * 100`
4. **Compare and report:**

   ```text
   ✓ progress.md matches: 100% (8/8)
   ```

   or

   ```text
   ✗ progress.md mismatch:
     File shows: 0% (0/6)
     Should be: 100% (8/8)
   ```

### Step 5: Generate Report

```text
=== Sprint Validation Report ===

Sprint: <sprint name>
Source: sprint/sprint.json

[Stats Consistency]
✓ Stats match feature counts

[Current Feature]
✓ No active feature (sprint complete)

[Progress File]
✗ progress.md needs sync
  File: 0% | Actual: 100%

[Recommendation]
Run /sync to fix discrepancies
```

### Step 6: Auto-fix Option

If discrepancies found:

1. **Ask user:** "Fix automatically? (y/n)"
2. **If yes:** Run /sync
3. **If no:** Show manual fix instructions

---

## Output Format

```text
=== Sprint Validation ===

Sprint: [name]
Stats: ✓ consistent | ✗ mismatch
Current: ✓ valid | ✗ inconsistent
Progress: ✓ synced | ✗ out of sync

Overall: ✓ All OK | ✗ Issues found

[If issues] → Run /sync to fix
```

---

## Rules

1. This is a diagnostic tool - read-only by default
2. Only modify files if user confirms auto-fix
3. Always show what would change before fixing
4. Use this command when resuming work to verify state

---

*Part of DG-VibeCoding-Framework v2.2*
