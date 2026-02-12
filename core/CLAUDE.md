# Claude Code Rules (v4.0.0)

> Project details → `PROJECT.md` | Agents → `.claude/agents/` | Skills → `.claude/skills/` | Tasks → `.tasks/board.md`

---

## Language

- Code, comments, commits: English
- Chat: Match user's language

---

## Context Loading

1. Always read `PROJECT.md` first
2. Check `.tasks/board.md` for active tasks
3. Review git context (auto-loaded via SessionStart hook)
4. Skills auto-activate based on task context
5. Load agents as needed for complex tasks

> **No CHANGELOG.md** — git log is the source of truth for project history.
> The SessionStart hook automatically shows recent commits.

---

## Skills

Skills are in `.claude/skills/[name]/SKILL.md` with YAML frontmatter.

**Format:**
```yaml
---
name: skill-name
description: "Brief description"
---
# Content
```

**Core skills:**
- `sub-agent` — Parallel processing with Haiku
- `debugging` — Bug finding and fixing
- `testing` — Test writing patterns
- `git` — Git workflow conventions
- `vibecoding` — Framework philosophy
- `partnership` — CC + CX equal partnership coordination

---

## Agents

Agents are **role definitions** Claude adopts via slash commands.

**Starter agents:**
| Agent | Purpose | Command |
|-------|---------|---------|
| orchestrator | Coordinate complex tasks | `/orchestrate` |
| implementer | Execute implementation | — |
| reviewer | Code review | `/review` |
| tester | Testing | `/done` |
| debugger | Debug issues | `/fix` |

See `.claude/agents/README.md` for agent protocol.

---

## Commands

Available in `.claude/commands/`:

| Command | Purpose |
|---------|---------|
| `/feature` | Start new feature |
| `/done` | Complete feature (test + commit) |
| `/review` | Review code |
| `/fix` | Fix issues |
| `/orchestrate` | Multi-agent workflow |
| `/peer-review` | Peer code review (CC or CX as reviewer) |
| `/handoff` | Hand off task to CX partner |
| `/sync-tasks` | Show task board and branch status |
| `/framework-update` | Check framework updates |

---

## Agent Coordination

CC and CX are **equal partners**, not architect/executor.

- **Task board:** `.tasks/board.md` — shared state between CC and CX
- **CC works in:** main worktree (interactive)
- **CX works in:** `../<project>-wt-cx-<branch>/` (background/headless)
- **Both read:** `PROJECT.md` for context
- **CX config:** `AGENTS.md` in project root

### When to Use Which Partner

| Task Type | Best For | Why |
|-----------|----------|-----|
| Interactive design | CC | Needs user dialogue |
| Large refactor | CX | Volume, autonomous |
| Bug investigation | CC | Reasoning, exploration |
| Bulk implementation | CX | Parallel, headless |
| Code review | Either | `/peer-review` |
| Architecture | CC | Ambiguity, trade-offs |

---

## Workflow

### Before Coding
1. Read PROJECT.md for context
2. Check .tasks/board.md for active tasks
3. Load appropriate agents if needed
4. Understand patterns and rules

### During Coding
- Follow patterns → PROJECT.md#patterns
- Respect rules → PROJECT.md#rules
- Delegate to agents when needed

### After Coding
- Run tests before commit
- Follow git conventions
- Update task status in .tasks/board.md

---

## Hooks

Hooks in `/hooks`:
- `block-env.js` — Block sensitive file access
- `git-context.js` — Auto-load git history on SessionStart

---

## References

- Project files → `PROJECT.md`
- Task board → `.tasks/board.md`
- CX config → `AGENTS.md`
- Agents → `.claude/agents/README.md`
- Skills → `.claude/skills/[name]/SKILL.md`
- Configuration → `framework.json`
