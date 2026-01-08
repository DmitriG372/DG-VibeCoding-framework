# Agent Activation Guide (v2.5)

> How framework agents work and how to activate them.

---

## Key Concept

**Framework agents are NOT separate processes.** They are **role definitions** that Claude adopts when executing slash commands.

```
┌──────────────────────────────────────────────────────────────────┐
│                    Agent Activation Flow                         │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│   User: /orchestrate "Add authentication"                        │
│              │                                                   │
│              ▼                                                   │
│   ┌─────────────────────┐                                       │
│   │ Command loads       │                                       │
│   │ agents/orchestrator │                                       │
│   │ .md                 │                                       │
│   └─────────────────────┘                                       │
│              │                                                   │
│              ▼                                                   │
│   ┌─────────────────────┐                                       │
│   │ Claude ADOPTS the   │                                       │
│   │ orchestrator ROLE   │                                       │
│   └─────────────────────┘                                       │
│              │                                                   │
│              ▼                                                   │
│   ┌─────────────────────┐                                       │
│   │ Executes agent      │                                       │
│   │ responsibilities    │                                       │
│   └─────────────────────┘                                       │
│              │                                                   │
│              ▼                                                   │
│   Output: Orchestration Plan                                     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Framework Agents vs Claude Code Task Tool

| Aspect | Framework Agents | Task Tool Subagents |
|--------|------------------|---------------------|
| **Location** | `agents/*.md` | Built into Claude Code |
| **Activation** | Via slash commands | Via `Task` tool |
| **Execution** | Same session | New Claude instance |
| **Context** | Full context preserved | Limited context |
| **Purpose** | Role adoption | Parallel work |
| **Types** | 16+ specialists | 4 fixed types |

### Task Tool Subagent Types
```
- general-purpose
- Explore
- Plan
- claude-code-guide
```

### Framework Agent Types
```
agents/
├── orchestrator.md      # Central coordinator
├── planner.md           # Task breakdown
├── architect.md         # System design
├── implementer.md       # Code writing
├── reviewer.md          # Code review
├── tester.md            # Test creation
├── debugger.md          # Issue diagnosis
├── refactorer.md        # Code refactoring
├── documenter.md        # Documentation
├── security-specialist.md
├── performance-specialist.md
├── integration-specialist.md
├── database-specialist.md
├── frontend-specialist.md
├── backend-specialist.md
└── research-specialist.md
```

---

## How to Activate Agents

### Method 1: Slash Commands (Primary)

| Command | Activates | When to Use |
|---------|-----------|-------------|
| `/orchestrate` | orchestrator | Complex multi-agent tasks |
| `/plan` | planner | Before implementing features |
| `/review` | reviewer | After code changes |
| `/done` | tester | Complete feature with tests |
| `/fix` | debugger | Bug investigation |

**Example:**
```
User: /orchestrate Add user authentication with JWT

Claude:
1. Read: agents/orchestrator.md
2. Analyze task complexity → HIGH
3. Select agent team
4. Output orchestration plan
```

### Method 2: Direct Request

Ask Claude to use a specific agent:

```
User: Use the security-specialist agent to review this code

Claude:
1. Read: agents/security-specialist.md
2. Adopt security specialist role
3. Review code for vulnerabilities
4. Output security report
```

### Method 3: Orchestrator Routing

Orchestrator automatically selects agents:

```
/orchestrate Fix login bug on mobile

Orchestrator analysis:
- Task type: Bug fix
- Primary agent: debugger
- Support agents: tester

Routing to debugger agent...
```

---

## Agent Definition Structure

Each agent file (`agents/*.md`) contains:

```yaml
---
agent: agent-name
role: Brief role description
priority: 1-10 (10 = highest)
triggers: [keywords that activate]
communicates_with: [other agents]
requires_skills: [framework skills needed]
---

# Agent: Name

## Role
What this agent does

## Responsibilities
- [ ] Task 1
- [ ] Task 2

## Workflow
Step-by-step process

## Decision Rules
When to activate, when to delegate

## Prompt Template
The actual prompt Claude uses

## Examples
Input/output examples
```

---

## Agent Communication

Agents pass information through **artifacts**:

```
Planner Agent
    │
    │ Output: Implementation Plan
    ▼
Architect Agent
    │
    │ Input: Plan
    │ Output: Architecture Doc
    ▼
Implementer Agent
    │
    │ Input: Plan + Architecture
    │ Output: Code
    ▼
Tester Agent
    │
    │ Input: Code
    │ Output: Tests + Results
```

---

## Sprint Mode Agent Flow

When `sprint/sprint.json` exists:

```
/sprint-init
    │
    ▼
/feature (activates: planner)
    │
    ▼
[Implementation] (activates: implementer, architect as needed)
    │
    ▼
/done (activates: tester MANDATORY)
    │
    ├── Tests pass → git commit → next feature
    │
    └── Tests fail → fix required → retry /done
```

---

## Monitoring Agent Usage

### Enable Usage Tracking

Add to `.claude/settings.local.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Skill|SlashCommand|Task",
        "hooks": [{
          "type": "command",
          "command": "node ./hooks/usage-tracker.js"
        }]
      }
    ]
  }
}
```

### View Usage Log
```bash
cat .claude/usage.log

# Output:
# 2025-12-13T10:00:00Z | COMMAND: /orchestrate
# 2025-12-13T10:01:00Z | COMMAND: /plan
# 2025-12-13T10:05:00Z | SKILL: testing
```

---

## Best Practices

### Do
- Use `/orchestrate` for complex, multi-domain tasks
- Use `/plan` before implementing non-trivial features
- Let orchestrator route to specialists
- Read agent files to understand capabilities

### Don't
- Don't use Task tool expecting framework agents
- Don't manually coordinate 5+ agents (use orchestrator)
- Don't skip planner for complex features
- Don't bypass tester in `/done` flow

---

## Troubleshooting

### Agent not activating

1. **Check command exists:**
   ```bash
   ls .claude/commands/
   ```

2. **Check agent file exists:**
   ```bash
   ls agents/
   ```

3. **Verify command loads agent:**
   - Command should have: `Read: agents/[name].md`

### Wrong agent behavior

1. **Re-read agent definition:**
   ```
   User: Please re-read agents/orchestrator.md and follow its workflow
   ```

2. **Check for conflicts:**
   - Multiple agent instructions may conflict
   - Simplify by using one agent at a time

---

## Quick Reference

```
┌────────────────────────────────────────────────────────────────┐
│ AGENT ACTIVATION CHEAT SHEET                                   │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ Complex task?     → /orchestrate "task description"            │
│ Need a plan?      → /plan "what to implement"                  │
│ Review code?      → /review path/to/file.ts                    │
│ Done with feature → /done                                      │
│ Fix a bug?        → /fix "bug description"                     │
│                                                                │
│ Direct agent?     → "Use the [agent] agent to..."              │
│                                                                │
│ Check usage?      → cat .claude/usage.log                      │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

*Part of DG-VibeCoding-Framework v2.6*
