# DG-SuperVibe-Framework v2.3

> **Philosophy:** Start Simple, Scale Smart, Learn Continuously

Intelligent, self-learning AI development platform optimized for Claude Code + VS Code dual workflow.

## What's New in v2.3

- **Anthropic Skills v2.0+** — Official Claude skill format with YAML frontmatter
- **`.claude/skills/`** — Skills in standard location for auto-activation
- **22 Migrated Skills** — All core-skills converted to official format
- **VS Code Integration** — `@github` and terminal output in conversation

## v2.2 Features (retained)

- **Git-First Tracking** — Git history is the ultimate source of truth
- **`/sprint-reconstruct`** — Rebuild sprint.json from git commits
- **`/sync --verify`** — Verify documentation matches git reality
- **`/sprint-validate`** — Validate sprint.json consistency
- **Auto-sync** — All framework files update automatically after `/done`
- **Disaster recovery** — Never lose progress, always rebuildable from git

### v2.1 Features (retained)

- **Sprint Workflow** — Anthropic's agentic workflow for long tasks
- **`/sprint-init`** — Initialize sprint from PROJECT.md tasks
- **`/feature`** — Start working on next feature
- **`/done`** — Complete feature with mandatory testing + commit
- **`/sprint-status`** — Show sprint progress and recovery
- **Jätkamisvõime** — Resume work after context compaction

### v2.0 Features (retained)
- Multi-Agent System — 16 specialized agents
- Meta-Programming — Framework learns automatically
- Smart Orchestration — Intelligent agent coordination
- MCP Integration — Context7, GitHub, Memory
- Context Hierarchy — 5-level token optimization

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

### 3. Skills Auto-Activate (v2.3)

Skills are now in `.claude/skills/` using Anthropic's official format. Claude auto-activates relevant skills based on task context.

**Official location:** `.claude/skills/*.md`

**Format:**

```markdown
---
name: skill-name
description: "Brief description for auto-activation"
---

# Skill Content
...
```

See `.claude/skills/` for all 22 skills (framework-philosophy, vue, react, database, etc.).

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
├── .claude/
│   ├── commands/           # Slash commands (20 total)
│   └── skills/             # Official Anthropic v2.0+ skills (22)
├── scale/                  # Pick your level (mini/normal/max)
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
| `.claude/skills/*.md` | Official skills (v2.3) | ~100-400 each |
| `.claude/commands/*.md` | Slash commands | ~50-100 each |

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

### v2.1 Sprint Commands
| Command | Description |
|---------|-------------|
| `/sprint-init` | Initialize sprint from tasks |
| `/feature` | Start next feature |
| `/done` | Complete feature (test + commit) |
| `/sprint-status` | Show sprint progress |

### v2.2 Git-First Commands

| Command | Description |
|---------|-------------|
| `/sprint-reconstruct` | Rebuild sprint.json from git history |
| `/sync` | Synchronize all framework files |
| `/sync --verify` | Verify git matches sprint.json |
| `/sprint-validate` | Validate sprint.json consistency |

---

## Sprint Workflow (v2.1)

Based on Anthropic's recommended agentic workflow for long tasks.

### Why Sprint Workflow?

Problems with long tasks:
1. **Context loss** — After compaction, Claude forgets progress
2. **Untested code** — Features marked done without validation
3. **Messy git history** — No clear feature-to-commit mapping

Sprint workflow solves these:
- **`sprint.json`** — Machine-readable progress (survives compaction)
- **Mandatory testing** — Cannot `/done` without passing tests
- **One commit per feature** — Clean, traceable history

### Sprint Cycle

```
/sprint-init → /feature → [work] → /done → /feature → ... → complete
```

### Quick Start

1. Add tasks to `PROJECT.md#Current Sprint`
2. Run `/sprint-init` to create `sprint/sprint.json`
3. Run `/feature` to start first feature
4. Implement the feature
5. Run `/done` to test, commit, and complete
6. Repeat until sprint complete

### Recovery After Context Loss

If Claude loses context (compaction), run:
```
/sprint-status
```
Shows current state and what to resume.

---

## Links

- [PROJECT.md Template](core/PROJECT.md)
- [Skills Directory](.claude/skills/) (Anthropic v2.0+ format)
- [Agent Protocol](core/AGENT_PROTOCOL.md)
- [Context Hierarchy](core/CONTEXT_HIERARCHY.md)
- [Scale Levels](scale/)
- [Slash Commands](.claude/commands/)

---

## Migration

See [MIGRATION.md](MIGRATION.md) for upgrade guides:

- **v2.2 → v2.3** — Anthropic Skills v2.0+ format migration
- **v2.1 → v2.2** — Git-First Tracking upgrade
- **v1.1 → v2.0** — Multi-agent system upgrade

---

*v2.3 — Anthropic Skills v2.0+ + Git-First Tracking + Sprint Workflow + Multi-Agent System*
