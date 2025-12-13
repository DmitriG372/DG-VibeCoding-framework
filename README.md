# DG-SuperVibe-Framework v2.4

> **Philosophy:** Start Simple, Scale Smart, Learn Continuously

Intelligent, self-learning AI development platform optimized for Claude Code + VS Code dual workflow.

## What's New in v2.4

### Core Features
- **Hooks System** — Pre/post tool-use hooks for automated validation
- **Reasoning Modes** — "Think", "Think more", "Ultrathink" for complex tasks
- **Context Control** — Escape, Compact, Clear commands documented
- **Agent Activation** — Documented how agents work via slash commands

### New Files
- `core/AGENT_ACTIVATION.md` — Complete guide to agent system
- `VERIFICATION.md` — Framework testing and verification guide
- `hooks/usage-tracker.js` — Track skill/command/agent usage
- `scripts/migrate-skills.sh` — Convert skills to subdirectory format

### Improvements
- **Skills format** — Must be in `[skill-name]/SKILL.md` subdirectory format
- **Command updates** — `/orchestrate`, `/plan`, `/review` now explicitly load agent files
- **4 Hooks total** — block-env.js, type-check.js, auto-format.js, usage-tracker.js
- **Usage logging** — Monitor framework component usage via `.claude/usage.log`

### v2.3 Features (retained)

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
- MCP Integration — Context7, Memory, Playwright
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

### 3. Skills Auto-Activate (v2.4)

Skills are in `.claude/skills/` using Anthropic's official format. Claude auto-activates relevant skills based on task context.

**Official location:** `.claude/skills/[skill-name]/SKILL.md`

**Format:**

```markdown
---
name: skill-name
description: "Brief description for auto-activation"
---

# Skill Content
...
```

**Important:** Skills must be in subdirectory format:
```
.claude/skills/
├── react/
│   └── SKILL.md     ✅ Correct
├── testing/
│   └── SKILL.md     ✅ Correct
└── vue.md           ❌ Won't be detected
```

**Migration script:** `./scripts/migrate-skills.sh` converts flat files to subdirectory format.

See `.claude/skills/` for all 22 skills (framework-philosophy, vue, react, database, etc.).

### 4. Verify Installation

See `VERIFICATION.md` for complete testing guide:
- Skills visibility check
- Slash command testing
- Hook verification
- Agent activation testing

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
│   ├── HOOKS.md            # Hook system docs (v2.4)
│   ├── REASONING_MODES.md  # Thinking modes + context control (v2.4)
│   ├── AGENT_ACTIVATION.md # How agents work (v2.4)
│   └── .vscode/            # VS Code settings (v2.0)
├── hooks/                  # Hook scripts (v2.4)
│   ├── block-env.js        # Block sensitive file access
│   ├── type-check.js       # TypeScript error detection
│   ├── auto-format.js      # Auto-format on edit
│   └── usage-tracker.js    # Track skill/command/agent usage
├── scripts/                # Utility scripts (v2.4)
│   └── migrate-skills.sh   # Convert skills to subdirectory format
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
├── integrations/           # MCP integrations (v2.4)
│   └── mcp/
│       ├── context7.integration.md
│       ├── memory.integration.md
│       └── playwright.integration.md  # NEW in v2.4
├── .claude/
│   ├── commands/           # Slash commands (18 total)
│   ├── skills/             # Official Anthropic v2.0+ skills (22)
│   └── settings.local.json # Hook configuration (v2.4)
├── scale/                  # Pick your level (mini/normal/max)
├── devops/                 # CI/CD templates
├── prompts/                # Reusable system prompts
├── VERIFICATION.md         # Testing & verification guide (v2.4)
└── MIGRATION.md            # Migration guide between versions
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

### How Agents Work (v2.4)

**Important:** Framework agents are NOT separate processes. They are **role definitions** that Claude adopts when executing slash commands.

```
/orchestrate "Add auth"
       │
       ▼
Read: agents/orchestrator.md
       │
       ▼
Claude adopts orchestrator role
       │
       ▼
Output: Orchestration Plan
```

**Activation methods:**
1. **Slash commands** — `/orchestrate`, `/plan`, `/review`, `/done`
2. **Direct request** — "Use the security-specialist agent"
3. **Orchestrator routing** — Automatic for complex tasks

See `core/AGENT_ACTIVATION.md` for complete guide.

### Quick Reference

| Command | Activates Agent | Use For |
|---------|-----------------|---------|
| `/orchestrate` | orchestrator | Complex multi-step tasks |
| `/plan` | planner | Before implementing features |
| `/review` | reviewer | Code review |
| `/done` | tester | Complete feature with tests |
| `/fix` | debugger | Bug investigation |

---

## Files Reference

| File | Purpose | Tokens |
|------|---------|--------|
| `core/PROJECT.md` | All project info | ~300 |
| `core/CLAUDE.md` | Claude rules + agents | ~200 |
| `core/SESSION_LOG.md` | Session history | ~100 |
| `core/AGENT_PROTOCOL.md` | Agent communication | ~150 |
| `core/CONTEXT_HIERARCHY.md` | Token optimization | ~100 |
| `core/HOOKS.md` | Hook system documentation | ~200 |
| `core/REASONING_MODES.md` | Thinking modes + control | ~150 |
| `core/.vscode/` | VS Code settings | — |
| `hooks/*.js` | Hook scripts | ~50 each |
| `agents/*.md` | Agent definitions | ~100-200 each |
| `meta/*.md` | Meta-programming | ~150 each |
| `.claude/skills/*.md` | Official skills (v2.3) | ~100-400 each |
| `.claude/commands/*.md` | Slash commands | ~50-100 each |

---

## Hooks System (v2.4)

Hooks run commands before/after Claude executes tools.

### Hook Types

| Type | When | Can Block? |
|------|------|------------|
| Pre-tool use | Before execution | ✅ Yes (exit code 2) |
| Post-tool use | After execution | ❌ No |

### Configuration Locations

```
~/.claude/settings.json          # Global (all projects)
.claude/settings.json            # Project (shared)
.claude/settings.local.json      # Project local (personal)
```

### Example Configuration

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Read|Grep",
      "hooks": [{ "type": "command", "command": "node ./hooks/block-env.js" }]
    }],
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{ "type": "command", "command": "node ./hooks/type-check.js" }]
    }]
  }
}
```

### Included Hooks

| Hook | Purpose |
|------|---------|
| `block-env.js` | Block access to .env, credentials, secrets |
| `type-check.js` | Run TypeScript checker after edits |
| `auto-format.js` | Auto-format files with Prettier |

See `core/HOOKS.md` for full documentation.

---

## Reasoning Modes (v2.4)

Use thinking phrases for complex tasks:

| Phrase | Level | Use Case |
|--------|-------|----------|
| `"Think"` | Basic | Simple logic |
| `"Think more"` | Extended | Multi-step problems |
| `"Think a lot"` | Comprehensive | Complex architecture |
| `"Think longer"` | Extended time | Deep debugging |
| `"Ultrathink"` | Maximum | Critical decisions |

### Usage

```
"Ultrathink about the best way to implement real-time sync"
/orchestrate "Think a lot: Design OAuth2 implementation"
```

### Plan Mode vs Thinking Mode

| Mode | Activation | Focus |
|------|------------|-------|
| Plan Mode | `Shift+Tab` twice | Breadth (research more files) |
| Thinking Mode | Phrase in prompt | Depth (more reasoning) |

### Context Control

| Action | Shortcut | Purpose |
|--------|----------|---------|
| Stop | `Escape` | Stop mid-response |
| Rewind | `Escape` twice | Jump back in conversation |
| Summarize | `/compact` | Summarize, preserve knowledge |
| Fresh start | `/clear` | Delete conversation |

See `core/REASONING_MODES.md` for full documentation.

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

## MCP Servers (v2.4)

Three MCP servers are integrated:

| Server | Purpose | Install |
|--------|---------|---------|
| Context7 | Library documentation | `claude mcp add context7 -- npx -y @upstash/context7-mcp` |
| Memory | Persistent knowledge graph | `claude mcp add memory -- npx @anthropic-ai/mcp-memory` |
| Playwright | Browser automation | `claude mcp add playwright -- npx @anthropic-ai/mcp-playwright` |

### Playwright Quick Start

**1. Install:**
```bash
claude mcp add playwright -- npx @anthropic-ai/mcp-playwright
```

**2. Basic workflow:**
```
# Open page
browser_navigate → "http://localhost:3000"

# Get element references (ALWAYS DO THIS FIRST!)
browser_snapshot → returns accessibility tree with refs

# Interact using refs
browser_click → element="Button", ref="btn-1"
browser_type → element="Input", ref="input-2", text="hello"

# Verify result
browser_snapshot → check changes
```

**3. Common tools:**

| Tool | Use |
|------|-----|
| `browser_navigate` | Go to URL |
| `browser_snapshot` | Get elements (preferred over screenshot) |
| `browser_take_screenshot` | Visual capture |
| `browser_click` | Click element |
| `browser_type` | Type text |
| `browser_fill_form` | Fill multiple fields |
| `browser_console_messages` | Debug errors |

**4. UI Development Loop:**
```
1. browser_navigate → localhost:3000
2. browser_snapshot → see current state
3. Edit code
4. browser_navigate → refresh
5. browser_snapshot → verify changes
6. Repeat until done
```

See `integrations/mcp/playwright.integration.md` for full documentation.

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
- [Hooks Documentation](core/HOOKS.md) (v2.4)
- [Reasoning Modes](core/REASONING_MODES.md) (v2.4)
- [Playwright Integration](integrations/mcp/playwright.integration.md) (v2.4)
- [Scale Levels](scale/)
- [Slash Commands](.claude/commands/)

---

## Migration

See [MIGRATION.md](MIGRATION.md) for upgrade guides:

- **v2.3 → v2.4** — Hooks, Thinking Modes, Playwright MCP
- **v2.2 → v2.3** — Anthropic Skills v2.0+ format migration
- **v2.1 → v2.2** — Git-First Tracking upgrade
- **v1.1 → v2.0** — Multi-agent system upgrade

---

*v2.4 — Hooks + Reasoning Modes + Playwright MCP + Git-First + Sprint Workflow + Multi-Agent System*
