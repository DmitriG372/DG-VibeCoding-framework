# Agent System Documentation

> Consolidated from: AGENT_PROTOCOL.md, AGENT_ACTIVATION.md, CONTEXT_HIERARCHY.md

---

## Key Concept

**Framework agents are NOT separate processes.** They are **role definitions** that Claude adopts when executing slash commands.

```
/orchestrate "Add authentication"
       │
       ▼
Read: .claude/agents/orchestrator.md  ← Command loads agent file
       │
       ▼
Claude adopts orchestrator role ← SAME session, full context
       │
       ▼
Output: Orchestration Plan
```

---

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
| security-specialist | 8 | Security review |
| performance-specialist | 7 | Optimization |
| database-specialist | 7 | Database design |
| frontend-specialist | 7 | UI/UX |
| backend-specialist | 7 | API/server |
| integration-specialist | 6 | External APIs |
| refactorer | 6 | Code improvement |
| documenter | 5 | Documentation |
| research-specialist | 6 | Technical research |

---

## How to Activate Agents

### Method 1: Slash Commands (Primary)

| Command | Activates | When to Use |
|---------|-----------|-------------|
| `/orchestrate` | orchestrator | Complex multi-agent tasks |
| `/review` | reviewer | After code changes |
| `/done` | tester | Complete feature with tests |
| `/fix` | debugger | Bug investigation |

### Method 2: Direct Request

```
User: Use the security-specialist agent to review this code

Claude:
1. Read: .claude/agents/security-specialist.md
2. Adopt security specialist role
3. Review code for vulnerabilities
```

### Method 3: Orchestrator Routing

Orchestrator automatically selects agents based on task type.

---

## Delegation Rules

| Situation | Delegate To |
|-----------|-------------|
| Task requires planning | planner |
| Architecture decision | architect |
| Code implementation | implementer |
| Code review | reviewer |
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

### Delegation Chain Examples

**Feature Implementation:**
```
orchestrator → planner → architect → implementer → reviewer → tester
```

**Bug Fix:**
```
orchestrator → debugger → implementer → tester
```

---

## Context Levels

Agents load context at appropriate levels:

| Level | Tokens | Use When |
|-------|--------|----------|
| 0: Minimal | 100-200 | Quick reference, typo fixes |
| 1: Core | 500-800 | Standard tasks, single feature |
| 2: Extended | 1500-2500 | Complex features, multi-file |
| 3: Comprehensive | 3500-5000 | Architecture decisions |
| 4: Maximum | Unlimited | Full analysis, audits |

### Automatic Level Detection

| Keywords | Level |
|----------|-------|
| typo, fix, simple, quick | 0 |
| add, create, implement, test | 1 |
| feature, refactor, integrate | 2 |
| architecture, design, system | 3 |
| audit, review all, analyze | 4 |

---

## Quick Reference

```
┌────────────────────────────────────────────────────────────────┐
│ AGENT ACTIVATION CHEAT SHEET                                   │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ Complex task?     → /orchestrate "task description"            │
│ Review code?      → /review path/to/file.ts                    │
│ Done with feature → /done                                      │
│ Fix a bug?        → /fix "bug description"                     │
│                                                                │
│ Direct agent?     → "Use the [agent] agent to..."              │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

*Part of DG-VibeCoding-Framework v2.7*
