# Command: /feature

Start working on the next feature in the sprint cycle.

## Usage

```
/feature [feature-id]
```

## Instructions

1. **Read sprint/sprint.json**
   - If file doesn't exist, prompt: "Run /sprint-init first"

2. **Select feature**
   - If `feature-id` provided: select that specific feature
   - If not provided: select first feature with `status: "pending"`
   - If no pending features: "All features completed! Run /sprint-init for new sprint."

3. **Update sprint.json**
   - Set selected feature `status: "in_progress"`
   - Set `current_feature: "<feature-id>"`
   - Update stats

4. **Display feature details**
   - Show name, description, acceptance criteria
   - Show suggested agent flow based on feature type

5. **Activate appropriate agents**
   - Complex feature: planner → architect → implementer
   - Simple feature: implementer directly
   - UI feature: frontend-specialist → implementer

## Output Format

```
╔══════════════════════════════════════════════════╗
║  Feature Started: F001                           ║
╚══════════════════════════════════════════════════╝

Name: User authentication
Description: Email/password login with JWT

Acceptance Criteria:
  ✓ User can register with email
  ✓ User can login
  ✓ JWT token is returned

Agent Flow: planner → implementer → tester

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
When implementation is complete and tested:
  → Use /done to commit and mark as completed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules

### One Feature at a Time
- Cannot start new feature if `current_feature` is set
- Must complete current feature with `/done` first
- Exception: `/feature --force` to switch (marks current as pending)

### Recovery After Compaction
If context is lost mid-feature:
1. `/feature` reads `current_feature` from sprint.json
2. Resumes work on that feature
3. Shows: "Resuming F001: User authentication"

## Examples

### Start next pending feature
```
/feature

→ Feature Started: F001 - User authentication
```

### Start specific feature
```
/feature F003

→ Feature Started: F003 - Shopping cart
```

### Resume after break
```
/feature

→ Resuming F002: Product catalog (in_progress)
  Last worked: 2 hours ago
```

### All done
```
/feature

→ All features completed!
  Sprint progress: 5/5 (100%)
  Run /sprint-init to start a new sprint.
```

## Integration with Agents

When feature starts, auto-detect agent needs:

| Feature Keywords | Agents to Activate |
|-----------------|-------------------|
| auth, login, user | security-specialist, backend-specialist |
| UI, component, page | frontend-specialist |
| API, endpoint | backend-specialist |
| database, schema | database-specialist |
| test, coverage | tester |

---

*Part of DG-SuperVibe-Framework v2.1*
