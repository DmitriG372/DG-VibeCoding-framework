# Command: /sprint-status

Display current sprint progress and status.

## Usage

```
/sprint-status [--verbose]
```

## Instructions

1. **Read sprint/sprint.json**
   - If not exists: "No active sprint. Use /sprint-init to start."

2. **Calculate progress**
   - Percentage: (completed / total) * 100
   - Progress bar visualization

3. **Display status**

## Output Format

### Standard Output
```
╔══════════════════════════════════════════════════╗
║  Sprint Status                                   ║
╚══════════════════════════════════════════════════╝

Sprint: MVP Ready
Goal: Launch beta version by end of week
Started: 2025-12-05

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Progress: [████████░░] 80% (4/5 features)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current: F005 - Checkout flow (in_progress)

Completed:
  ✓ F001: User authentication (abc123)
  ✓ F002: Product catalog (def456)
  ✓ F003: Shopping cart (ghi789)
  ✓ F004: User profile (jkl012)

Pending:
  (none)

Use /done to complete F005.
```

### Verbose Output (--verbose)
```
╔══════════════════════════════════════════════════╗
║  Sprint Status (Verbose)                         ║
╚══════════════════════════════════════════════════╝

Sprint: MVP Ready
Goal: Launch beta version by end of week
Started: 2025-12-05

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Progress: [████████░░] 80% (4/5 features)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌─────────────────────────────────────────────────┐
│ CURRENT: F005 - Checkout flow                   │
├─────────────────────────────────────────────────┤
│ Status: in_progress                             │
│ Tested: false                                   │
│                                                 │
│ Acceptance Criteria:                            │
│   • Process payment via Stripe                  │
│   • Send confirmation email                     │
│   • Update inventory                            │
└─────────────────────────────────────────────────┘

COMPLETED FEATURES:
┌──────┬─────────────────────┬─────────┬──────────┐
│ ID   │ Name                │ Commit  │ Tested   │
├──────┼─────────────────────┼─────────┼──────────┤
│ F001 │ User authentication │ abc123  │ ✓        │
│ F002 │ Product catalog     │ def456  │ ✓        │
│ F003 │ Shopping cart       │ ghi789  │ ✓        │
│ F004 │ User profile        │ jkl012  │ ✓        │
└──────┴─────────────────────┴─────────┴──────────┘

COMMIT LOG:
  abc123 feat(auth): User authentication
  def456 feat(catalog): Product catalog
  ghi789 feat(cart): Shopping cart
  jkl012 feat(profile): User profile

PENDING: (none)
```

### No Sprint
```
No active sprint found.

Use /sprint-init to initialize a new sprint from PROJECT.md tasks.
```

### All Complete
```
╔══════════════════════════════════════════════════╗
║  Sprint Complete!                                ║
╚══════════════════════════════════════════════════╝

Sprint: MVP Ready
Progress: [██████████] 100% (5/5 features)

All features completed and tested!

Commits:
  abc123, def456, ghi789, jkl012, mno345

Next steps:
  1. Review all changes: git log --oneline -5
  2. Push to remote: git push
  3. Start new sprint: /sprint-init "Sprint 2"
```

## Use Cases

### Recovery After Context Loss
When Claude loses context (compaction), user runs:
```
/sprint-status
```
Claude sees current state and can resume work:
- If `current_feature` exists → knows what to work on
- If no current → prompts to start next feature

### Progress Check
Quick progress update during work session.

### Handoff to Another Session
At end of session, `/sprint-status` shows exactly where things are.

---

*Part of DG-SuperVibe-Framework v2.1*
