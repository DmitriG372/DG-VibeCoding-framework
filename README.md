# DG-SuperVibe-Framework v2.0

> **Philosophy:** Start Simple, Scale Smart, Learn Continuously

Intelligent, self-learning AI development platform optimized for Claude Code + VS Code dual workflow.

## What's New in v2.0

- **🤖 Multi-Agent System** — 16 specialized agents (7 core + 9 specialists)
- **🧠 Meta-Programming** — Framework learns and adapts automatically
- **🎯 Smart Orchestration** — Intelligent agent coordination
- **🔗 MCP Integration** — Automatic Context7, GitHub, Memory integration
- **📊 Context Hierarchy** — 5-level token-optimized context loading
- **🔄 Self-Improvement** — Automatic performance optimization

### v1.1 Features (retained)
- Session Persistence with `SESSION_LOG.md`
- Auto Skill Detection based on task keywords
- Iteration Logging with `/iterate`
- PR Automation with `/pr` command

---

## Quick Start

### 1. Copy Core Files to Your Project

```bash
cp core/PROJECT.md your-project/PROJECT.md
cp core/CLAUDE.md your-project/CLAUDE.md
cp -r core/.vscode your-project/.vscode
```

### 2. Choose Your Scale Level

| Level | When to Use | Add to PROJECT.md |
|-------|-------------|-------------------|
| **mini** | Prototypes, experiments | → `scale/mini.md` |
| **normal** | Standard projects | → `scale/normal.md` |
| **max** | Complex, long-term | → `scale/max.md` |

### 3. Load Skills as Needed

Skills auto-load based on task keywords (see `CLAUDE.md#auto-skill-detection`), or load manually:

```
core-skills/ui.skill       # Frontend patterns
core-skills/database.skill # Database patterns
core-skills/testing.skill  # Testing patterns
core-skills/api.skill      # API patterns
```

See `core-skills/INDEX.md` for full list.

---

## Structure

```
DG-VibeCoding-framework/
├── core/                   # Always needed
│   ├── PROJECT.md          # Single source of truth
│   ├── CLAUDE.md           # Claude Code rules + agent loading
│   ├── SESSION_LOG.md      # Session history
│   ├── AGENT_PROTOCOL.md   # Agent communication (v2.0)
│   ├── CONTEXT_HIERARCHY.md # Token optimization (v2.0)
│   └── .vscode/            # VS Code settings (v2.0)
├── agents/                 # Multi-agent system (v2.0)
│   ├── orchestrator.md     # Main coordinator
│   ├── planner.md          # Planning agent
│   ├── architect.md        # Architecture agent
│   ├── implementer.md      # Implementation agent
│   ├── reviewer.md         # Code review agent
│   ├── tester.md           # Testing agent
│   ├── debugger.md         # Debugging agent
│   └── *-specialist.md     # 9 specialist agents
├── meta/                   # Meta-programming (v2.0)
│   ├── skill-generator.md  # Auto-generate skills
│   ├── pattern-detector.md # Detect patterns
│   └── framework-optimizer.md # Self-optimization
├── integrations/           # MCP integrations (v2.0)
│   └── mcp/
│       ├── context7.integration.md
│       ├── github.integration.md
│       └── memory.integration.md
├── scale/                  # Pick your level (mini/normal/max)
├── core-skills/            # Universal skills (22)
├── project-skills/         # Project-specific skills
├── commands/               # Slash commands (11 total)
├── devops/                 # CI/CD templates
└── prompts/                # Reusable system prompts
```

---

## Token Strategy

**Rule:** Information lives in ONE place only.

```
PROJECT.md  ←── Single source of truth
    ↑
    ├── CLAUDE.md refs sections
    ├── agents/ loaded on demand
    └── skills/ ref when needed
```

### Context Hierarchy (v2.0)

| Level | Tokens | Use Case |
|-------|--------|----------|
| 0: Minimal | 100-200 | Quick queries, status checks |
| 1: Core | 500-800 | Standard tasks |
| 2: Extended | 1500-2500 | Complex tasks |
| 3: Comprehensive | 3500-5000 | Architecture decisions |
| 4: Maximum | Unlimited | Deep research |

**Why?**
- 2000 tokens vs 10000+ tokens per task
- Progressive loading based on complexity
- Automatic escalation when needed

---

## Workflow

### Claude Code (Heavy Lifting)
```bash
claude --dangerously-skip-permissions
# Queue tasks: "Add X", "Also Y", "And Z"
# Let Claude batch execute with agents
```

### VS Code (Quick Edits)
- IntelliSense for small changes
- Extensions for code quality
- Terminal for Claude Code

### Dual Workflow
```
Claude Code: Planning, complex features, multi-file changes, agent orchestration
VS Code: Quick fixes, exploration, code review, debugging
```

---

## Agent System (v2.0)

### Core Agents (7)
| Agent | Role |
|-------|------|
| `orchestrator` | Coordinates all agents, routes tasks |
| `planner` | Breaks down requirements into steps |
| `architect` | Designs system architecture |
| `implementer` | Writes and modifies code |
| `reviewer` | Reviews code quality and patterns |
| `tester` | Creates and runs tests |
| `debugger` | Diagnoses and fixes issues |

### Specialist Agents (9)
| Agent | Focus |
|-------|-------|
| `refactorer` | Code refactoring |
| `documenter` | Documentation |
| `security-specialist` | Security review |
| `performance-specialist` | Performance optimization |
| `integration-specialist` | System integrations |
| `database-specialist` | Database operations |
| `frontend-specialist` | UI/UX implementation |
| `backend-specialist` | API development |
| `research-specialist` | Research and analysis |

### Using Agents
```bash
/orchestrate "Add user authentication"
# Orchestrator routes to: planner → architect → implementer → reviewer → tester
```

---

## Files Reference

| File | Purpose | Tokens |
|------|---------|--------|
| `core/PROJECT.md` | All project info | ~300 |
| `core/CLAUDE.md` | Claude rules + agents | ~200 |
| `core/SESSION_LOG.md` | Session history | ~100 |
| `core/AGENT_PROTOCOL.md` | Agent communication | ~150 |
| `core/CONTEXT_HIERARCHY.md` | Token optimization | ~100 |
| `core/.vscode/` | VS Code settings | — |
| `agents/*.md` | Agent definitions | ~100-200 each |
| `meta/*.md` | Meta-programming | ~150 each |
| `core-skills/*.skill` | Domain knowledge | ~100-400 each |
| `commands/*.md` | Slash commands | ~50-100 each |

---

## Session Workflow

```
/start-session → Work → /iterate (as needed) → /end-session
```

### Start Session
```bash
/start-session my-feature
```
Loads last session context, shows pending tasks, activates relevant agents.

### During Session
```bash
/iterate "Added validation but errors don't show"
```
Logs attempt with result and learnings.

### End Session
```bash
/end-session
```
Captures completed work, decisions, triggers pattern detection.

### Orchestrate (v2.0)
```bash
/orchestrate "Implement user dashboard"
```
Activates multi-agent workflow for complex tasks.

---

## Commands Reference

### Core Commands
| Command | Description |
|---------|-------------|
| `/plan` | Plan implementation |
| `/implement` | Execute plan |
| `/review` | Code review |
| `/fix` | Fix issues |

### Session Commands
| Command | Description |
|---------|-------------|
| `/start-session` | Start with context |
| `/end-session` | Log and close |
| `/iterate` | Log attempt |
| `/pr` | Create PR |

### v2.0 Commands
| Command | Description |
|---------|-------------|
| `/orchestrate` | Multi-agent workflow |
| `/generate-skill` | Create new skill |
| `/analyze-patterns` | Detect patterns |

---

## Links

- [PROJECT.md Template](core/PROJECT.md)
- [Skills Index](core-skills/INDEX.md)
- [Agent Protocol](core/AGENT_PROTOCOL.md)
- [Context Hierarchy](core/CONTEXT_HIERARCHY.md)
- [Scale Levels](scale/)
- [Slash Commands](commands/)

---

## Migration from v1.1

See [MIGRATION.md](MIGRATION.md) for upgrade guide.

Quick summary:
1. Copy `.vscode/` directory to your project
2. Copy `agents/` directory to your project
3. Update `CLAUDE.md` with agent loading logic
4. Enable meta-programming (optional)
5. Configure MCP integrations

---

*v2.0 — Built on SuperCloud concepts + DG-VibeCoding-Framework v1.1*
