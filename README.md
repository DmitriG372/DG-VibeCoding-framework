# DG-VibeCoding-Framework v4.0.0

> **Philosophy:** Start Simple, Scale Smart — Equal Partnership

Universal Claude Code + Codex framework with equal partnership model.

## What's New in v4.0.0

### Equal Partnership Model

CC (Claude Code) and CX (Codex) are **equal partners**, not architect/executor.

```
┌─────────────────────────────────────────────────────────────┐
│  EQUAL PARTNERSHIP MODEL                                     │
├─────────────────────────────────────────────────────────────┤
│  CC (Claude Code)              CX (Codex)                    │
│  ┌─────────────────┐          ┌─────────────────┐           │
│  │ • Interactive    │          │ • Headless        │           │
│  │ • Reasoning      │ <─────> │ • Volume           │           │
│  │ • Design         │ .tasks/ │ • Autonomous       │           │
│  │ • Exploration    │  board  │ • Parallel          │           │
│  └─────────────────┘          └─────────────────┘           │
│                                                              │
│  Shared context: PROJECT.md + .tasks/board.md                │
└─────────────────────────────────────────────────────────────┘
```

- `/handoff` command — Give tasks to CX with automatic worktree setup
- `/peer-review` — Either agent reviews the other's work
- `/sync-tasks` — Task board and branch status overview
- `partnership` skill — Coordination guidance

### Current Stats
- **5 core skills** — debugging, testing, git, vibecoding, partnership
- **12 commands** — sprint-init, feature, done, review, fix, orchestrate, peer-review, handoff, sync-tasks, context-refresh, sync-notebook, framework-update
- **5 starter agents** — orchestrator, implementer, reviewer, tester, debugger
- **3 templates** — project-init, tasks-board, skill/command/agent

---

## Previous: v3.1.0 → v3.0.1

- **v3.1.0** — Spec-Factory model (Claude as Architect, Codex as Executor)
- **v3.0.1** — Simplified from 82 to ~35 files, `framework.json` config

---

## Quick Start

### New Project

```bash
./setup-project.sh /path/to/your/project
```

### Existing Project Migration

```bash
./migrate-project.sh /path/to/your/project
```

---

## Structure

```
DG-VibeCoding-framework/
├── README.md                    # This file
├── VERSION                      # "4.0.0"
├── hooks/                       # Hook scripts
├── framework.json               # Central config
│
├── core/                        # Core files
│   ├── CLAUDE.md                # CC rules
│   ├── AGENTS.md                # CX rules
│   ├── PROJECT.md               # Project template
│   ├── HOOKS.md                 # Hook documentation
│   └── settings.template.json   # Settings template
│
├── .claude/                     # Claude Code config
│   ├── skills/                  # 5 core skills
│   │   ├── debugging/SKILL.md
│   │   ├── testing/SKILL.md
│   │   ├── git/SKILL.md
│   │   ├── vibecoding/SKILL.md
│   │   └── partnership/SKILL.md  # CC + CX coordination
│   │
│   ├── commands/                # 9 commands
│   │   ├── sprint-init.md
│   │   ├── feature.md
│   │   ├── done.md
│   │   ├── review.md
│   │   ├── fix.md
│   │   ├── orchestrate.md
│   │   ├── peer-review.md       # Peer code review
│   │   ├── handoff.md           # Hand off task to CX
│   │   ├── sync-tasks.md        # Task board status
│   │   └── framework-update.md
│   │
│   └── agents/                  # 5 starter agents
│       ├── README.md
│       ├── orchestrator.md
│       ├── implementer.md
│       ├── reviewer.md
│       ├── tester.md
│       └── debugger.md
│
├── templates/                   # Project templates
│   ├── project-init/            # New project starter
│   │   ├── PROJECT.md
│   │   ├── CLAUDE.md
│   │   └── AGENTS.md
│   ├── tasks-board.template.md  # Task board template
│   ├── skill.template.md
│   ├── command.template.md
│   └── agent.template.md
│
├── scripts/                     # Utility scripts
│   ├── worktree-setup.sh        # Create worktree for CX
│   ├── worktree-cleanup.sh      # Remove worktree after merge
│   ├── init-project.sh
│   └── migrate-skills.sh
│
├── archive/                     # Preserved components
│   ├── skills/                  # codex, spec-factory, + 16 others
│   ├── agents/                  # 11 specialist agents
│   ├── commands/                # spec, codex-review, + 14 others
│   └── hooks/                   # 4 additional hooks
│
├── hooks/
│   ├── block-env.js             # Block sensitive file access
│   └── git-context.js           # SessionStart git context hook
│
├── setup-project.sh             # Project setup (8 steps)
└── migrate-project.sh           # Project migration (9 steps)
```

---

## Commands

| Command | Purpose |
|---------|---------|
| `/sprint-init` | Initialize sprint from plan |
| `/feature` | Start new feature |
| `/done` | Complete feature (test + commit) |
| `/review` | Code review |
| `/fix` | Fix issues |
| `/orchestrate` | Multi-agent workflow |
| `/peer-review` | Peer code review (CC or CX) |
| `/handoff` | Hand off task to CX partner |
| `/sync-tasks` | Task board and branch status |
| `/context-refresh` | Manually reload project context |
| `/sync-notebook` | Sync project to NotebookLM |
| `/framework-update` | Check for updates |

---

## Skills

Skills auto-activate based on task context.

| Skill | Purpose |
|-------|---------|
| `debugging` | Bug finding and fixing |
| `testing` | Test writing patterns |
| `git` | Git workflow conventions |
| `vibecoding` | Framework philosophy |
| `partnership` | CC + CX equal partnership coordination |

---

## Agents

| Agent | Purpose |
|-------|---------|
| `orchestrator` | Coordinate complex tasks |
| `implementer` | Execute implementation |
| `reviewer` | Code review |
| `tester` | Testing |
| `debugger` | Debug issues |

---

## Partnership Workflow

CC and CX coordinate through a shared task board:

```bash
# 1. Hand off task to CX
/handoff "Implement CRUD endpoints for products API"

# 2. CX works autonomously in worktree
cd ../project-wt-cx-add-products/ && codex --full-auto

# 3. Check status
/sync-tasks

# 4. Review CX's work
/peer-review cx/add-products

# 5. Merge and cleanup
git merge cx/add-products
scripts/worktree-cleanup.sh cx/add-products
```

### When to Use Which Partner

| Task | Best Partner | Why |
|------|-------------|-----|
| Interactive design | CC | User dialogue needed |
| Large refactor | CX | Volume, autonomous |
| Bug investigation | CC | Reasoning, tools |
| Bulk implementation | CX | Parallel, headless |
| Architecture | CC | Trade-offs, ambiguity |
| Test generation | CX | Repetitive, pattern-based |

---

## Session Context

The framework uses a `SessionStart` hook instead of manual CHANGELOG.md:

- **`hooks/git-context.js`** runs automatically on session start
- Outputs last 20 commits + branch + status to Claude
- ~100 tokens vs ~1000+ for manual changelog
- Zero maintenance — git is the source of truth

---

## Configuration

`framework.json` — Central configuration:

```json
{
  "version": "4.0.0",
  "agents": {
    "cc": { "config": "CLAUDE.md", "branch_prefix": "feat/" },
    "cx": { "config": "AGENTS.md", "branch_prefix": "cx/" }
  },
  "integrations": {
    "codex": { "cli": true, "equal_partner": true }
  }
}
```

---

## Archive

Project-specific and deprecated components preserved in `archive/`:

**Skills:** codex, spec-factory, vue, react, nextjs, supabase-migrations, melior-patterns, api, cli, database, lsp, openrouter, security, techstack, typescript, ui, framework-philosophy, vue-to-react

**Agents (11):** architect, backend-specialist, database-specialist, documenter, frontend-specialist, integration-specialist, performance-specialist, planner, refactorer, research-specialist, security-specialist

**Commands:** spec, codex-review, codex-spec.template, analyze-patterns, end-session, generate-skill, implement, iterate, pr, qa-loop, sprint-init, sprint-reconstruct, sprint-status, sprint-validate, start-session, sync

To use archived components, copy them to your project:
```bash
cp archive/skills/react .claude/skills/
cp archive/agents/security-specialist.md .claude/agents/
```

---

## Migration

### From v3.x
```bash
./migrate-project.sh /path/to/project
```

### From v2.x
```bash
./migrate-project.sh /path/to/project
```

The script handles both migration paths automatically.

---

## Links

- Version history → `git log` or `archive/docs/CHANGELOG.md`
- [core/CLAUDE.md](core/CLAUDE.md) — CC rules
- [core/AGENTS.md](core/AGENTS.md) — CX rules
- [templates/](templates/) — Project templates
- [archive/](archive/) — Preserved components

---

*v4.1.0 — Equal Partnership, Context Robustness, Sprint Init*
