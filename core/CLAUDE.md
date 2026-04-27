# Claude Code Rules

> Project → `PROJECT.md` | Sprint → `sprint/sprint.json` | Rules → `.claude/rules/`

---

## Language

- Code, comments, commits: English
- Chat: Match user's language

---

## Context Loading (MANDATORY)

> **CRITICAL:** Execute at every session start, including after compaction.

### Step 1: Load Rules
Read `PROJECT.md` — SINGLE SOURCE OF TRUTH for all rules, patterns, stack, and conventions.

### Step 2: Load Sprint State
Read `sprint/sprint.json` — feature assignments, status, and sprint metadata.

### Step 3: Review Git Context
Auto-loaded via SessionStart hook. After compaction, recovered via `context-reload.js`.

### Step 4: Skills & Agents
Skills auto-activate based on task context. Load agents as needed for complex tasks.

> **Separation Principle:**
> - `PROJECT.md` = Rules, patterns, stack, conventions (IMMUTABLE)
> - `sprint/sprint.json` = Sprint state (MUTABLE)
> - `sprint/sprint.md` = Auto-generated overview (READONLY)
> - Never put rules in sprint.json. Never put task state in PROJECT.md.

> **No CHANGELOG.md** — git log is the source of truth.

---

## Agent Identity Detection

Entry point file determines agent identity:
- `CLAUDE.md` → agent is **CC** (Claude Code), branch prefix `cc/`
- `AGENTS.md` → agent is **CX** (Codex), branch prefix `cx/`

Automatic — no manual configuration needed.

---

## Workflow

### Before Coding
1. Read PROJECT.md for context
2. Check sprint/sprint.json for active features
3. Load appropriate agents if needed

### During Coding
- Follow patterns → PROJECT.md#patterns
- Respect rules → `.claude/rules/execution-integrity.md`
- Delegate to agents when needed

### After Coding
- Run tests before commit
- Follow git conventions
- Update feature status via `/done`

---

## References

### Mandatory rules (LLM safety)
- **Execution integrity:** `.claude/rules/execution-integrity.md` (6 mandatory rules — LLM failure-mode protections)
- **Negative constraints:** `.claude/rules/negative-constraints.md` (what NOT to do)

### Operational rules (how to work)
- **Autonomy:** `.claude/rules/autonomy.md` (deficit→blocker→unblock cycle, anti-paralysis)
- **Delegation:** `.claude/rules/delegation.md` (when to use agents, mandatory post-agent commit cycle)
- **Context management:** `.claude/rules/context-management.md` (compaction protocols, 20-tool checkpoint)
- **Production safety:** `.claude/rules/production-safety.md` (when to ask the user)

### Structure
- **Components map:** `.claude/rules/components.md` (one-screen pointer)
- **Agents:** `.claude/agents/*.md`
- **Skills:** `.claude/skills/*/SKILL.md` (+ `references/` for Level 3)
- **Configuration:** `framework.json`
- **CX config:** `AGENTS.md`
- **Project metadata:** `manifest.md` (project_name, repo_access — see `framework-state-mode.sh`)
