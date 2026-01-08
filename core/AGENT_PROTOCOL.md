# Agent Communication Protocol

## Overview

This document defines how agents communicate, delegate tasks, and share context within the DG-VibeCoding-Framework.

## Agent Registry

### Core Agents (Always Available)
| Agent | Priority | Primary Function |
|-------|----------|------------------|
| orchestrator | 10 | Task coordination and agent selection |
| planner | 9 | Requirements analysis and planning |
| architect | 9 | System design and patterns |
| implementer | 8 | Code implementation |
| reviewer | 7 | Code quality review |
| tester | 7 | Test creation and execution |
| debugger | 8 | Issue diagnosis and fixing |

### Specialist Agents (On-Demand)
| Agent | Priority | Specialization |
|-------|----------|----------------|
| security-specialist | 8 | Security review and hardening |
| performance-specialist | 7 | Optimization and profiling |
| database-specialist | 7 | Database design and queries |
| frontend-specialist | 7 | UI/UX implementation |
| backend-specialist | 7 | API and server logic |
| integration-specialist | 6 | External service integration |
| refactorer | 6 | Code improvement |
| documenter | 5 | Documentation |
| research-specialist | 6 | Technical research |

## Communication Format

### Task Handoff Structure
```yaml
handoff:
  from: <source_agent>
  to: <target_agent>
  task:
    type: <implement|review|test|debug|document|research>
    description: <what needs to be done>
    context: <relevant background>
    inputs:
      - <input_1>
      - <input_2>
    expected_outputs:
      - <output_1>
      - <output_2>
    constraints:
      - <constraint_1>
    priority: <high|medium|low>
```

### Response Structure
```yaml
response:
  from: <agent>
  status: <completed|blocked|needs_clarification>
  outputs:
    - type: <code|document|analysis|recommendation>
      content: <the actual output>
  issues:
    - <any problems encountered>
  recommendations:
    - <suggestions for next steps>
  handoff_to: <next_agent if needed>
```

## Delegation Rules

### When to Delegate

| Situation | Delegate To |
|-----------|-------------|
| Task requires planning | planner |
| Architecture decision needed | architect |
| Code needs implementation | implementer |
| Code needs review | reviewer |
| Tests needed | tester |
| Bug found | debugger |
| Security concern | security-specialist |
| Performance issue | performance-specialist |
| Database work | database-specialist |
| Frontend work | frontend-specialist |
| Backend work | backend-specialist |
| External API | integration-specialist |
| Code cleanup | refactorer |
| Docs needed | documenter |
| Need research | research-specialist |

### Delegation Chain Examples

**Feature Implementation:**
```
orchestrator → planner → architect → implementer → reviewer → tester
```

**Bug Fix:**
```
orchestrator → debugger → implementer → tester
```

**Performance Issue:**
```
orchestrator → performance-specialist → implementer → tester
```

**Security Audit:**
```
orchestrator → security-specialist → implementer → reviewer
```

## Context Sharing

### Context Levels
Agents should request and provide context at appropriate levels:

| Level | Tokens | Use When |
|-------|--------|----------|
| 0: Minimal | 100-200 | Quick reference checks |
| 1: Core | 500-800 | Standard tasks |
| 2: Extended | 1500-2500 | Complex features |
| 3: Comprehensive | 3500-5000 | Large systems |
| 4: Maximum | Unlimited | Full analysis |

### Context Handoff
When delegating, always include:
1. **Task context**: What needs to be done
2. **Project context**: Relevant project patterns and conventions
3. **Decision context**: Previous decisions that affect this task
4. **Constraint context**: Limitations and requirements

## Priority Resolution

When multiple agents could handle a task:
1. Check trigger keywords against agent triggers
2. Select agent with highest priority that matches
3. If equal priority, prefer more specialized agent
4. If still equal, orchestrator decides based on task complexity

## Error Handling

### Blocked Tasks
If an agent cannot complete a task:
```yaml
response:
  status: blocked
  reason: <why blocked>
  needs:
    - <what's needed to unblock>
  suggestion: <alternative approach>
```

### Clarification Needed
If requirements are unclear:
```yaml
response:
  status: needs_clarification
  questions:
    - <specific question 1>
    - <specific question 2>
  assumptions: <what would be assumed if not clarified>
```

## Workflow Patterns

### Sequential (Default)
```
Agent A completes → handoff → Agent B starts
```

### Parallel (When Independent)
```
                 → Agent B →
Agent A starts → → Agent C → → Agent D combines
                 → Agent D →
```

### Iterative (Review Loop)
```
implementer → reviewer → [if changes needed] → implementer → reviewer
```

## Best Practices

1. **Single Responsibility**: Each agent focuses on its specialization
2. **Clear Handoffs**: Always specify what's needed from the next agent
3. **Context Efficiency**: Share only relevant context
4. **Early Escalation**: Delegate specialist tasks early
5. **Feedback Loop**: Return results to orchestrator for coordination

---

*Protocol Version: 2.4*
*Part of DG-VibeCoding-Framework v2.6*
