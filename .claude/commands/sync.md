---
description: "Sünkroniseerib kõik framework failid sprint.json põhjal."
---

# Command: /sync

Sünkroniseerib kõik framework failid sprint.json põhjal.

## Usage

```bash
/sync [--verbose] [--verify]
```

## Instructions

### Step 1: Read Source of Truth

1. **Read sprint/sprint.json**
   - If file doesn't exist: "No sprint active. Run /sprint-init first."
2. **Extract current state:**
   - Sprint name, goal, started date
   - Features array with statuses
   - Stats (total, completed, in_progress, pending)
   - Current feature (if any)

### Step 2: Update sprint/progress.md

1. **Calculate progress percentage:**

   ```text
   percentage = (completed / total) * 100
   ```

2. **Generate progress bar:**

   ```text
   [████████░░] 80% (8/10)
   ```

   - Use █ for completed
   - Use ░ for remaining
   - 10 characters total

3. **Update sections:**

   **Pending:**

   ```markdown
   - [ ] **F007** - Feature name
   - [ ] **F008** - Feature name
   ```

   **In Progress:**

   ```markdown
   - [ ] **F005** - Feature name *(working)*
   ```

   **Completed:**

   ```markdown
   - [x] **F001** - Feature name
   - [x] **F002** - Feature name
   ```

4. **Update commit log table** from feature commits

### Step 3: Update PROJECT.md

1. **Find "## Current Sprint" section**

2. **Update sprint info:**

   ```markdown
   ## Current Sprint

   **Sprint:** <name>
   **Goal:** <goal>
   **Progress:** [████████░░] 80% (8/10)

   ### Active Tasks
   - [ ] F007 - Feature name
   - [ ] F008 - Feature name

   ### Completed (This Sprint)
   - [x] F001 - Feature name
   - [x] F002 - Feature name
   ...
   ```

### Step 4: Validate Consistency

1. **Check stats match features:**
   - Count features with status:"done" = stats.completed
   - Count features with status:"pending" = stats.pending
   - Count features with status:"in_progress" = stats.in_progress

2. **Fix if mismatch:**
   - Recalculate stats from features
   - Update sprint.json

### Step 5: Git Verification (--verify flag)

If `--verify` flag is provided:

1. **For each feature with status="done":**

   ```bash
   git log --oneline --grep="F<ID>" | head -1
   ```

2. **Check if git commit exists:**
   - If commit found: ✓ Verified
   - If NOT found: ✗ MISMATCH - "Feature F001 marked done but no git commit found"

3. **Check for untracked features in git:**

   ```bash
   git log --oneline --grep="feat.*F[0-9]" --since="<sprint_start>"
   ```

   - Parse for feature IDs not in sprint.json
   - Report: "Git commit found for F009 but not in sprint.json"

4. **Report verification results:**

   ```text
   === Git Verification ===
   ✓ F001 - git: 5c1efc9 | sprint.json: done
   ✓ F002 - git: 5c1efc9 | sprint.json: done
   ...
   ✓ F008 - git: e5ef702 | sprint.json: done

   All features verified. Git matches sprint.json.
   ```

## Output Format

### Success

```text
╔══════════════════════════════════════════════════╗
║  Framework Files Synchronized                    ║
╚══════════════════════════════════════════════════╝

Sprint: <sprint name>
Progress: [██████████] 100% (8/8)

Updated files:
  ✓ sprint/progress.md
  ✓ PROJECT.md

Stats validated: ✓
Git verified: ✓ (if --verify)
```

### Verification Output (--verify)

```text
╔══════════════════════════════════════════════════╗
║  Git Verification Report                         ║
╚══════════════════════════════════════════════════╝

Sprint: <sprint name>

Git vs sprint.json:
  ✓ F001 - 5c1efc9 | done
  ✓ F002 - 5c1efc9 | done
  ✓ F003 - 5c1efc9 | done
  ...

Result: ✓ All features verified
Git history matches sprint.json - documentation is accurate.
```

### Verification Failure

```text
╔══════════════════════════════════════════════════╗
║  Git Verification FAILED                         ║
╚══════════════════════════════════════════════════╝

Mismatches found:

  ✗ F003 - sprint.json: done | git: NOT FOUND
  ✗ F009 - sprint.json: missing | git: abc1234

Run /sprint-reconstruct to fix from git history.
```

### Verbose Output (--verbose)

```text
╔══════════════════════════════════════════════════╗
║  Framework Files Synchronized                    ║
╚══════════════════════════════════════════════════╝

Sprint: <sprint name>
Progress: [██████████] 100% (8/8)

Features:
  ✓ F001 - Feature Name [done]
  ✓ F002 - Feature Name [done]
  ✓ F003 - Feature Name [done]
  ...

Updated files:
  ✓ sprint/progress.md
  ✓ PROJECT.md

Stats validated: ✓
```

## When to Use

1. **Automatically called by:**
   - `/done` - after completing a feature
   - `/start-session` - at session start
   - `/end-session` - at session end

2. **Manually call when:**
   - Files seem out of sync
   - After manual sprint.json edits
   - After context recovery

## Notes

- sprint.json is the SINGLE SOURCE OF TRUTH
- All other files are derived from it
- Running /sync never loses data
- Safe to run multiple times

---

*Part of DG-VibeCoding-Framework v2.2*
