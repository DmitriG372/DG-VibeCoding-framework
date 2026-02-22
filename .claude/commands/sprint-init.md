---
description: "Initialize a new sprint from a plan — creates sprint/sprint.json with features and acceptance criteria."
---

# Command: /sprint-init

Create a new sprint from a plan, backlog, or user description. Generates `sprint/sprint.json` automatically.

## Usage

```
/sprint-init [plan or description]
```

## Instructions

1. **Read PROJECT.md** for project context (stack, patterns, domain)

2. **Gather sprint input**
   - If `$ARGUMENTS` contains a plan or feature list: use that directly
   - If `$ARGUMENTS` references a file (e.g., `BACKLOG.md`, `plan.md`): read that file
   - If `$ARGUMENTS` is empty: ask user "Millised featuurid sellesse sprinti tulevad?"

3. **Parse features from input**
   - Extract distinct features from the plan
   - For each feature, generate:
     - `id`: Sequential `F001`, `F002`, ...
     - `name`: Short descriptive name (English)
     - `description`: What needs to be done (1-2 sentences)
     - `acceptance_criteria`: Concrete, testable criteria (list of strings)
     - `complexity`: `low` | `medium` | `high` (estimate based on scope)
     - `status`: `"pending"`

4. **Determine sprint ID**
   - If `sprint/sprint.json` already exists: increment sprint_id (S01 → S02)
   - If not: start with `S01`
   - If existing sprint has incomplete features: warn user and ask for confirmation

5. **Create sprint directory and file**
   - Create `sprint/` directory if it doesn't exist
   - Write `sprint/sprint.json` with the structure below
   - Create `sprint/progress.md` with sprint header

6. **Display sprint summary**

## Output: sprint/sprint.json

```json
{
  "sprint_id": "S01",
  "created": "2026-02-22T10:00:00Z",
  "current_feature": null,
  "features": [
    {
      "id": "F001",
      "name": "Feature name",
      "description": "What needs to be done",
      "acceptance_criteria": [
        "Criterion 1",
        "Criterion 2"
      ],
      "complexity": "medium",
      "status": "pending",
      "git_hash": null,
      "completed_at": null
    }
  ],
  "stats": {
    "total": 5,
    "completed": 0
  }
}
```

## Output: sprint/progress.md

```markdown
# Sprint S01 Progress

Started: 2026-02-22

## Features

| ID | Feature | Status | Commit |
|----|---------|--------|--------|
| F001 | Feature name | pending | — |
| F002 | Feature name | pending | — |

## Session Log

_Updated automatically by /done_
```

## Output Format (terminal)

```
╔══════════════════════════════════════════════════╗
║  Sprint S01 Initialized                          ║
╚══════════════════════════════════════════════════╝

Features (5):
  F001  [low]     User registration form
  F002  [medium]  Authentication API endpoints
  F003  [medium]  JWT token management
  F004  [high]    Role-based access control
  F005  [low]     Login page UI

Files created:
  ✓ sprint/sprint.json
  ✓ sprint/progress.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next step: /feature to start working on F001
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

- **Always read PROJECT.md** first for project context
- **Acceptance criteria must be testable** — "works correctly" is not acceptable; "returns 200 with JWT token" is
- **Feature names in English** — code-facing, used in commit messages
- **Descriptions can be bilingual** — if user writes in Estonian, keep context but ensure names are English
- **Never overwrite** an active sprint without user confirmation
- **Complexity is an estimate** — used by `/feature` for agent routing (low → implementer, high → planner → architect → implementer)

## Examples

### From a plan description
```
/sprint-init Vaja: kasutaja registreerimine, login API, JWT tokenid, rollipõhine ligipääs, login UI

→ Sprint S01 Initialized (5 features)
```

### From a backlog file
```
/sprint-init Read features from BACKLOG.md

→ Sprint S01 Initialized (8 features from BACKLOG.md)
```

### New sprint when previous exists
```
/sprint-init Next sprint: performance optimeerimised, caching, monitoring

→ ⚠️  Sprint S01 exists with 2/5 incomplete features.
   Continue with new sprint S02? (incomplete features will be carried over)
```

### Empty — interactive mode
```
/sprint-init

→ Millised featuurid sellesse sprinti tulevad?
  (Kirjelda vabas vormis, loen BACKLOG.md-st, või anna feature'de nimekiri)
```

---

*Part of DG-VibeCoding-Framework v4.1.0*
