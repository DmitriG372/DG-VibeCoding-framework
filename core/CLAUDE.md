# Claude Code Rules (v3.1.0)

> Project details → `PROJECT.md` | Agents → `.claude/agents/` | Skills → `.claude/skills/`

---

## Language

- Code, comments, commits: English
- Chat: Match user's language

---

## Context Loading

1. Always read `PROJECT.md` first
2. Skills auto-activate based on task context
3. Load agents as needed for complex tasks
4. Check active tasks in PROJECT.md

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
- `codex` — Dual-AI review with OpenAI Codex
- `spec-factory` — Claude+Codex tandem workflow for large implementations

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
| `/codex-review` | Dual-AI review with Codex |
| `/framework-update` | Check framework updates |
| `/spec [--execute]` | Generate spec for Codex (auto-execute option) |

---

## Workflow

### Before Coding
1. Read PROJECT.md for context
2. Load appropriate agents if needed
3. Understand patterns and rules

### During Coding
- Follow patterns → PROJECT.md#patterns
- Respect rules → PROJECT.md#rules
- Delegate to agents when needed

### After Coding
- Run tests before commit
- Follow git conventions
- Update task status

---

## Hooks

Essential hook in `/hooks`:
- `block-env.js` — Block sensitive file access

---

## References

- Project files → `PROJECT.md`
- Agents → `.claude/agents/README.md`
- Skills → `.claude/skills/[name]/SKILL.md`
- Configuration → `framework.json`
