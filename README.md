# DG-VibeCoding-Framework v3.0.1

> **Philosophy:** Start Simple, Scale Smart

Universal Claude Code framework with Codex dual-AI integration.

## What's New in v3.0.1

### Simplified Structure
- **82 → ~35 files** — Removed obsolete components
- **6 core skills** — sub-agent, debugging, testing, git, vibecoding, codex
- **7 commands** — feature, done, review, fix, orchestrate, codex-review, framework-update
- **5 starter agents** — orchestrator, implementer, reviewer, tester, debugger

### New Features
- `framework.json` — Central configuration (no hardcoded paths)
- `/framework-update` — Check for Claude Code updates
- `templates/` — Project initialization templates
- `archive/` — Project-specific components preserved

### Removed (Obsolete)
- Session commands (start-session, end-session, iterate)
- Sprint commands (sprint-init, sprint-status, etc.)
- REASONING_MODES.md, SESSION_LOG.md, HOOKS.md
- 11 specialist agents → archived

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
├── VERSION                      # "3.0.1"
├── CHANGELOG.md                 # Version history
├── framework.json               # Central config
│
├── core/                        # Core files
│   ├── CLAUDE.md                # Claude rules (~95 lines)
│   ├── HOOKS.md                 # Hook documentation
│   ├── PROJECT.md               # Project template
│   └── settings.template.json   # Settings template
│
├── .claude/                     # Claude Code config
│   ├── skills/                  # 6 core skills
│   │   ├── sub-agent/SKILL.md
│   │   ├── debugging/SKILL.md
│   │   ├── testing/SKILL.md
│   │   ├── git/SKILL.md
│   │   ├── vibecoding/SKILL.md
│   │   └── codex/SKILL.md
│   │
│   ├── commands/                # 7 commands
│   │   ├── feature.md
│   │   ├── done.md
│   │   ├── review.md
│   │   ├── fix.md
│   │   ├── orchestrate.md
│   │   ├── codex-review.md
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
│   ├── skill.template.md
│   ├── command.template.md
│   └── agent.template.md
│
├── archive/                     # Preserved components
│   ├── skills/                  # 16 project-specific
│   ├── agents/                  # 11 specialist agents
│   ├── commands/                # 14 workflow commands
│   └── hooks/                   # 4 additional hooks
│
├── hooks/
│   └── block-env.js             # Essential hook
│
├── scripts/
│   ├── init-project.sh
│   └── migrate-skills.sh
│
├── setup-project.sh             # Project setup
└── migrate-project.sh           # Project migration
```

---

## Commands

| Command | Purpose |
|---------|---------|
| `/feature` | Start new feature |
| `/done` | Complete feature (test + commit) |
| `/review` | Code review |
| `/fix` | Fix issues |
| `/orchestrate` | Multi-agent workflow |
| `/codex-review` | Dual-AI review with Codex |
| `/framework-update` | Check for updates |

---

## Skills

Skills auto-activate based on task context.

| Skill | Purpose |
|-------|---------|
| `sub-agent` | Parallel processing with Haiku |
| `debugging` | Bug finding and fixing |
| `testing` | Test writing patterns |
| `git` | Git workflow conventions |
| `vibecoding` | Framework philosophy |
| `codex` | Dual-AI review integration |

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

## Codex Integration

Dual-AI review: Claude Code builds, Codex critiques.

```bash
# Install Codex CLI
npm install -g @openai/codex

# Set API key
export OPENAI_API_KEY=your-key

# Run review
/codex-review src/
```

**Modes:**
- **CLI** (default) — Local headless review
- **Cloud** — PR comment integration (setup required)
- **GitHub Action** — CI/CD pipeline

---

## Configuration

`framework.json` — Central configuration:

```json
{
  "version": "3.0.1",
  "core": {
    "skills": ["sub-agent", "debugging", "testing", "git", "vibecoding", "codex"],
    "commands": ["feature", "done", "review", "fix", "orchestrate", "codex-review", "framework-update"],
    "agents": ["orchestrator", "implementer", "reviewer", "tester", "debugger"]
  },
  "integrations": {
    "codex": { "cli": true, "cloud": false, "github_action": false }
  }
}
```

---

## Archive

Project-specific components preserved in `archive/`:

**Skills (16):** vue, react, nextjs, supabase-migrations, melior-patterns, api, cli, database, lsp, openrouter, security, techstack, typescript, ui, framework-philosophy, vue-to-react

**Agents (11):** architect, backend-specialist, database-specialist, documenter, frontend-specialist, integration-specialist, performance-specialist, planner, refactorer, research-specialist, security-specialist

**Commands (14):** analyze-patterns, end-session, generate-skill, implement, iterate, pr, qa-loop, spec, sprint-init, sprint-reconstruct, sprint-status, sprint-validate, start-session, sync

To use archived components, copy them to your project:
```bash
cp archive/skills/react .claude/skills/
cp archive/agents/security-specialist.md .claude/agents/
```

---

## Migration from v2.x

```bash
./migrate-project.sh /path/to/project
```

The script will:
1. Backup existing `.claude/` directory
2. Remove obsolete files
3. Install new commands, skills, agents
4. Keep only essential hook (block-env.js)

---

## Links

- [CHANGELOG.md](CHANGELOG.md) — Version history
- [core/CLAUDE.md](core/CLAUDE.md) — Claude rules
- [templates/](templates/) — Project templates
- [archive/](archive/) — Preserved components

---

*v3.0.1 — Simplified, Universal, Codex-Ready*
