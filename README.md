# DG-VibeCoding-Framework v7.1.0

> **Philosophy:** Start Simple, Scale Smart — Equal Partnership

Universal Claude Code + Codex framework with equal partnership model.

## Current Features

### Sprint-Based Coordination

`sprint/sprint.json` is the structured sprint state — single source of truth for feature assignments, branches, and review status.

- CC branch prefix changed from `feat/` to `cc/`
- `/sync-tasks` replaced with `/sprint-status`
- `validate-board.js` hook replaced with `sprint-sync.js`
- Generated projects now include `framework.json`, `scripts/headless-review.sh`, and `.claude/settings.local.json`

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
│  │ • Design         │ sprint/ │ • Autonomous       │           │
│  │ • Exploration    │  .json  │ • Parallel          │           │
│  └─────────────────┘          └─────────────────┘           │
│                                                              │
│  Shared context: PROJECT.md + sprint/sprint.json             │
└─────────────────────────────────────────────────────────────┘
```

- `/handoff` command — Give tasks to CX with automatic worktree setup
- `/peer-review` — Either agent reviews the other's work
- `/sprint-status` — Sprint progress and branch status overview
- `partnership` skill — Coordination guidance

### Current Stats
- **8 core skills** — debugging, testing, git, vibecoding, partnership, start, finish, housekeeping
- **12 commands** — sprint-init, feature, done, review, fix, orchestrate, peer-review, handoff, sprint-status, context-refresh, sync-notebook, framework-update
- **6 starter agents** — orchestrator, implementer, reviewer, tester, debugger, plan-checker
- **13 hooks** — block-env, type-check, auto-format, usage-tracker, git-context, context-monitor, pre-compact, context-reload, sprint-sync, plan-to-sprint, completion-guard, test-dir-protection, test-output-filter
- **3 templates** — project-init, sprint, skill/command/agent

---

## Version History

> Current version: see `VERSION` file (single source of truth) and `framework.json`. Validated by `tests/framework-consistency.sh`.

- **v7.1.0** — `manifest.md` + `repo_access` modes, operational rules pack (autonomy/delegation/context-management/production-safety), session-level skills (`/start`, `/finish`, `/housekeeping`), narrative `SNAPSHOT.md`
- **v7.0.0** — Progressive-disclosure skills, evidence hooks, slim CLAUDE.md
- **v5.1.0** — Sprint-based coordination, framework.json/headless-review.sh in generated projects
- **v4.1.0** — Context preservation hooks, NLM integration
- **v4.0.0** — Equal Partnership Model (CC + CX)
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
├── VERSION                      # "5.1.0"
├── hooks/                       # Hook scripts
├── framework.json               # Central config
│
├── core/                        # Core files
│   ├── CLAUDE.md                # CC rules
│   ├── AGENTS.md                # CX rules
│   ├── PROJECT.md               # Project template
│   ├── HOOKS.md                 # Hook documentation
│   └── settings.template.json   # Template for .claude/settings.local.json
│
├── .claude/                     # Claude Code config
│   ├── skills/                  # 8 core skills
│   │   ├── debugging/SKILL.md
│   │   ├── testing/SKILL.md
│   │   ├── git/SKILL.md
│   │   ├── vibecoding/SKILL.md
│   │   └── partnership/SKILL.md  # CC + CX coordination
│   │
│   ├── commands/                # 12 commands
│   │   ├── sprint-init.md
│   │   ├── feature.md
│   │   ├── done.md
│   │   ├── review.md
│   │   ├── fix.md
│   │   ├── orchestrate.md
│   │   ├── peer-review.md       # Peer code review
│   │   ├── handoff.md           # Hand off task to CX
│   │   ├── sprint-status.md     # Sprint progress overview
│   │   ├── context-refresh.md
│   │   ├── sync-notebook.md
│   │   └── framework-update.md
│   │
│   └── agents/                  # 6 starter agents
│       ├── README.md
│       ├── orchestrator.md
│       ├── implementer.md
│       ├── reviewer.md
│       ├── tester.md
│       ├── debugger.md
│       └── plan-checker.md
│
├── templates/                   # Project templates
│   ├── project-init/            # New project starter
│   │   ├── PROJECT.md
│   │   ├── CLAUDE.md
│   │   └── AGENTS.md
│   ├── sprint.template.json     # Sprint template
│   ├── skill.template.md
│   ├── command.template.md
│   └── agent.template.md
│
├── scripts/                     # Utility scripts
│   ├── worktree-setup.sh        # Create worktree for CX
│   ├── worktree-cleanup.sh      # Remove worktree after merge
│   ├── headless-review.sh       # Headless peer review runner
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
│   ├── type-check.js            # Best-effort type checking
│   ├── auto-format.js           # Best-effort formatting
│   ├── usage-tracker.js         # JSONL usage log
│   ├── git-context.js           # SessionStart git context hook
│   ├── context-monitor.js       # Context window monitor
│   ├── pre-compact.js           # Pre-compact snapshot hook
│   ├── context-reload.js        # Restore context after compact
│   ├── sprint-sync.js           # Sprint state sync hook
│   └── plan-to-sprint.js        # Plan Mode → sprint bridge
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
| `/sprint-status` | Sprint progress and branch status |
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

CC and CX coordinate through a shared sprint file:

```bash
# 1. Hand off task to CX
/handoff "Implement CRUD endpoints for products API"

# 2. CX works autonomously
codex --full-auto

# 3. Check status
/sprint-status

# 4. Review CX's work
/peer-review cx/F003-add-products

# 5. Merge and cleanup
git merge cx/F003-add-products
scripts/worktree-cleanup.sh cx/F003-add-products
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
  "version": "<see VERSION file — single source of truth>",
  "agents": {
    "cc": { "config": "CLAUDE.md", "branch_prefix": "cc/" },
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

### From v4.x
```bash
./migrate-project.sh /path/to/project
```

Key changes: `.tasks/board.md` → `sprint/sprint.json`, `feat/` → `cc/` branch prefix, `/sync-tasks` → `/sprint-status`

### From v3.x
```bash
./migrate-project.sh /path/to/project
```

### From v2.x
```bash
./migrate-project.sh /path/to/project
```

The script handles all migration paths automatically.

---

## Links

- Version history → `git log` or `archive/docs/CHANGELOG.md`
- [core/CLAUDE.md](core/CLAUDE.md) — CC rules
- [core/AGENTS.md](core/AGENTS.md) — CX rules
- [templates/](templates/) — Project templates
- [archive/](archive/) — Preserved components

---

*Sprint-Based Coordination, Equal Partnership — see `VERSION` file for current version*
