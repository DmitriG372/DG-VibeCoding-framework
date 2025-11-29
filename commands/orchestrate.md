# Command: /orchestrate

## Purpose

Activates the orchestrator agent for complex, multi-step tasks that require coordination between multiple agents.

## Usage

```
/orchestrate <task-description>
```

## When to Use

- Complex features requiring multiple agents
- Tasks with unclear scope needing analysis
- Multi-file changes across different domains
- When unsure which agent to use

## Workflow

```
/orchestrate "Add user authentication"
           ↓
    Orchestrator Activates
           ↓
    Analyzes Task Complexity
           ↓
    Selects Agent Team
           ↓
    Creates Execution Plan
           ↓
    Coordinates Agents
           ↓
    Synthesizes Results
```

## Agent Selection

The orchestrator selects agents based on:

| Task Type | Primary Agent | Support Agents |
|-----------|---------------|----------------|
| New feature | planner | architect, implementer |
| Bug fix | debugger | implementer, tester |
| Performance | performance-specialist | implementer |
| Security | security-specialist | reviewer |
| Refactor | refactorer | reviewer, tester |
| API work | backend-specialist | database-specialist |
| UI work | frontend-specialist | implementer |

## Output Format

```yaml
## Orchestration Plan

**Task:** <task description>
**Complexity:** <LOW|MEDIUM|HIGH>

### Agent Team
- Primary: <agent>
- Support: [<agent>, <agent>]

### Execution Phases
1. **Phase 1**: <description>
   - Agent: <agent>
   - Output: <expected>

2. **Phase 2**: <description>
   - Agent: <agent>
   - Input: <from phase 1>
   - Output: <expected>

### Context Level
Loading: Level <0-4>

### Estimated Steps
<number> agent handoffs
```

## Examples

### Example 1: Feature Request
```
/orchestrate "Add dark mode toggle to settings"

## Orchestration Plan

**Task:** Add dark mode toggle to settings
**Complexity:** MEDIUM

### Agent Team
- Primary: planner
- Support: [frontend-specialist, implementer, tester]

### Execution Phases
1. **Planning**: Define requirements and acceptance criteria
2. **Architecture**: Design state management approach
3. **Implementation**: Build toggle component and theme system
4. **Testing**: Unit and integration tests
5. **Review**: Code quality check

### Context Level
Loading: Level 2 (Extended)
```

### Example 2: Bug Fix
```
/orchestrate "Fix login not working on mobile"

## Orchestration Plan

**Task:** Fix login not working on mobile
**Complexity:** MEDIUM

### Agent Team
- Primary: debugger
- Support: [frontend-specialist, tester]

### Execution Phases
1. **Diagnosis**: Reproduce and identify root cause
2. **Fix**: Implement minimal fix
3. **Testing**: Verify fix on mobile devices
4. **Prevention**: Add mobile-specific tests
```

## Options

| Option | Description |
|--------|-------------|
| --dry-run | Show plan without executing |
| --context <level> | Force specific context level |
| --agents <list> | Override agent selection |

## Best Practices

1. **Be Descriptive**: More detail = better orchestration
2. **Include Context**: Mention relevant files or features
3. **State Goals**: What success looks like
4. **Trust the Plan**: Let orchestrator coordinate

---

*Part of DG-SuperVibe-Framework v2.0*
