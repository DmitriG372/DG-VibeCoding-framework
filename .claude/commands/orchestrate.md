---
description: Orchestrate complex multi-step tasks with agent coordination
---

# /orchestrate

Coordinate complex tasks that require multiple specialist agents.

## Instructions

1. **Load orchestrator agent definition:**
   ```
   Read: agents/orchestrator.md
   ```

2. **Analyze task complexity:**
   - LOW: Single file, simple change → route directly to implementer
   - MEDIUM: Multiple files, needs review → primary agent + reviewer
   - HIGH: Cross-domain, architecture needed → full orchestration

3. **Select agent team based on task type:**

   | Task Type | Primary | Support |
   |-----------|---------|---------|
   | New feature | planner | architect, implementer, tester |
   | Bug fix | debugger | implementer, tester |
   | Refactor | refactorer | reviewer, tester |
   | Performance | performance-specialist | implementer |
   | Security | security-specialist | reviewer |
   | UI work | frontend-specialist | implementer |
   | API work | backend-specialist | database-specialist |

4. **Create execution plan:**
   - List phases in order
   - Identify parallel opportunities
   - Note dependencies between phases

5. **Check for sprint mode:**
   ```
   If exists: sprint/sprint.json
   Then: Enforce one-feature-at-a-time rule
   ```

6. **Output orchestration plan** in this format:

```yaml
## Orchestration Plan

**Task:** <user's task description>
**Complexity:** LOW | MEDIUM | HIGH

### Agent Team
- Primary: <agent name>
- Support: [<agent>, <agent>]

### Execution Phases
1. **<Phase name>**
   - Agent: <agent>
   - Action: <what to do>
   - Output: <expected result>

2. **<Phase name>**
   - Agent: <agent>
   - Depends on: Phase 1
   - Action: <what to do>

### Next Step
<What Claude should do immediately>
```

## Example

Input: `/orchestrate Add user authentication with JWT`

Output:
```yaml
## Orchestration Plan

**Task:** Add user authentication with JWT
**Complexity:** HIGH

### Agent Team
- Primary: architect
- Support: [backend-specialist, security-specialist, tester]

### Execution Phases
1. **Design** - architect designs auth flow
2. **Database** - database-specialist creates user schema
3. **API** - backend-specialist implements endpoints
4. **Security** - security-specialist reviews
5. **Testing** - tester writes auth tests

### Next Step
Reading agents/architect.md to begin design phase...
```

---

*Part of DG-SuperVibe-Framework v2.4*
