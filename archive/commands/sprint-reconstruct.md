---
description: "Rekonstrueerib sprint.json git history põhjal."
---

# Command: /sprint-reconstruct

Rekonstrueerib sprint.json git history põhjal.

## Usage

```bash
/sprint-reconstruct                    # Rekonstrueeri praegune sprint
/sprint-reconstruct --since 2025-12-06 # Alates kuupäevast
/sprint-reconstruct --verify           # Võrdle git vs sprint.json
/sprint-reconstruct --dry-run          # Näita mida teeks
```

## Instructions

### Step 1: Parse Git History

1. **Run git log command:**

   ```bash
   git log --format="%H|%s|%aI" --since="<start_date>"
   ```

2. **Parse commit messages with regex:**

   ```regex
   feat\((?<scope>[^)]+)\):\s*F(?<id>\d{3})\s+(?<desc>.+)
   ```

3. **Handle bulk commits:**

   ```regex
   feat\([^)]+\):\s*complete\s+F(\d{3})-F(\d{3})\s+(.+)
   ```

   Expand to individual features: F001-F004 → F001, F002, F003, F004

### Step 2: Extract Feature Data

For each matching commit:

```javascript
{
  "id": "F001",
  "name": "<description from commit>",
  "status": "done",
  "git": {
    "hash": "<full commit hash>",
    "message": "<full commit subject>",
    "timestamp": "<ISO timestamp>"
  }
}
```

### Step 3: Build sprint.json

```json
{
  "version": "2.2",
  "source": "git",
  "reconstructed_at": "<current ISO timestamp>",
  "project": "<project name>",
  "sprint": {
    "name": "<infer from scope or ask user>",
    "started": "<earliest commit date>",
    "goal": "<from existing sprint.json or ask user>"
  },
  "features": [
    // sorted by ID
  ],
  "current_feature": null,
  "stats": {
    "total": "<count>",
    "completed": "<count>",
    "in_progress": 0,
    "pending": 0
  },
  "last_verified": "<current ISO timestamp>"
}
```

### Step 4: Verification Mode (--verify)

1. **Load existing sprint.json**
2. **Compare with git:**

   | Check | Pass | Fail |
   |-------|------|------|
   | Feature in sprint.json with status=done | Has matching git commit | No git commit found |
   | Git commit with F### pattern | In sprint.json | Missing from sprint.json |

3. **Report discrepancies:**

   ```text
   === Sprint Verification Report ===

   ✓ F001 - git: abc1234 | sprint.json: done
   ✓ F002 - git: def5678 | sprint.json: done
   ✗ F003 - git: NOT FOUND | sprint.json: done (MISMATCH)
   ✗ F004 - git: ghi9012 | sprint.json: pending (MISMATCH)

   Summary: 2 OK, 2 mismatches
   ```

### Step 5: Dry Run Mode (--dry-run)

1. **Show what would be reconstructed:**

   ```text
   === Dry Run: Sprint Reconstruction ===

   Source: git log --since=2025-12-06
   Commits found: 8

   Would create:
   - F001: add withPerformanceLog utility (abc1234)
   - F002: fix N+1 query in Projects.vue (def5678)
   - ...

   Sprint stats: 8 completed, 0 pending

   No changes made. Run without --dry-run to apply.
   ```

2. **Do NOT modify any files**

### Step 6: Apply Changes

If not --dry-run and not --verify:

1. **Backup existing sprint.json** (if exists)
2. **Write new sprint.json**
3. **Run /sync** to update derived files
4. **Report:**

   ```text
   ✓ Sprint reconstructed from git history
   ✓ 8 features found (8 completed)
   ✓ Files synced: progress.md, PROJECT.md

   Backup saved: sprint/sprint.json.backup
   ```

---

## Output Format

### Success (Reconstruct)

```text
╔══════════════════════════════════════════════════════════╗
║  Sprint Reconstructed from Git                           ║
╚══════════════════════════════════════════════════════════╝

Source: git log --since=2025-12-06
Commits parsed: 12
Features found: 8

Progress: [██████████] 100% (8/8)

Features:
  F001 ✓ feature description
  F002 ✓ feature description
  F003 ✓ feature description
  ...

Files updated:
  ✓ sprint/sprint.json
  ✓ sprint/progress.md
  ✓ PROJECT.md
```

### Success (Verify)

```text
╔══════════════════════════════════════════════════════════╗
║  Sprint Verification: PASSED                             ║
╚══════════════════════════════════════════════════════════╝

All 8 features verified against git history.
No discrepancies found.

Last commit: feat(scope): F008 description (e5ef702)
```

### Failure (Verify)

```text
╔══════════════════════════════════════════════════════════╗
║  Sprint Verification: FAILED                             ║
╚══════════════════════════════════════════════════════════╝

Discrepancies found:

  ✗ F003 marked "done" but NO git commit found
  ✗ F007 has git commit but marked "pending"

Run `/sprint-reconstruct` to fix from git history.
```

---

## Commit Message Patterns

### Standard Feature Commit

```text
feat(<scope>): F<ID> <description>
```

Examples:

- `feat(telemetry): F001 add withPerformanceLog utility`
- `feat(outlook): F003 implement OAuth flow`

### Bulk Feature Commit

```text
feat(<scope>): complete F<start>-F<end> <description>
```

Example:

- `feat(telemetry): complete F001-F004 full integration`

Expands to: F001, F002, F003, F004

---

## Rules

1. **Git is ultimate truth** - If commit exists, feature is done
2. **Preserve acceptance criteria** - Keep from existing sprint.json if available
3. **Never lose data** - Always backup before overwrite
4. **Verify before reconstruct** - Use --verify first to see discrepancies
5. **Auto-sync after reconstruct** - Run /sync to update derived files

---

*Part of DG-VibeCoding-Framework v2.6*
