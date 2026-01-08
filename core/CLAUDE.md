# Claude Code Rules (v2.7)

> All project details → `PROJECT.md`
> Agent definitions → `.claude/agents/`
> Skills → `.claude/skills/` (Anthropic v2.0+ format)

---

## Behavior

### Language
- Code: English always
- Comments: English
- Commits: English
- Chat: Match user's language

### Context Loading (v2.3)

**Level-based loading** — See `.claude/agents/README.md` for details.

1. Always read `PROJECT.md` first
2. Skills auto-activate based on task context (`.claude/skills/`)
3. Determine context level based on task complexity (0-4)
4. Load agents as needed (see Agent Loading below)
5. Check active tasks in PROJECT.md#current-sprint

### Skills (Anthropic v2.0+ Format)

Skills are in `.claude/skills/` with YAML frontmatter. Claude auto-activates relevant skills based on task context.

**IMPORTANT:** Skills must be in subdirectory format:

```
.claude/skills/
├── framework-philosophy/
│   └── SKILL.md            ✅ Correct format
├── react/
│   └── SKILL.md            ✅ Correct format
├── testing/
│   └── SKILL.md            ✅ Correct format
└── vue.md                  ❌ Won't be detected
```

**Migration:** Run `./scripts/migrate-skills.sh` to convert flat files.

**Skill format:**

```markdown
---
name: skill-name
description: "Brief description for auto-activation"
---

# Skill Content
```

---

## Agent System (v2.4)

### How Agents Work

**IMPORTANT:** Framework agents are NOT separate processes. They are **role definitions** that Claude adopts when executing slash commands.

```
/orchestrate "Add authentication"
       │
       ▼
Read: .claude/agents/orchestrator.md  ← Command loads agent file
       │
       ▼
Claude adopts orchestrator role ← Same session, full context
       │
       ▼
Output: Orchestration Plan
```

See `.claude/agents/README.md` for complete documentation.

### Agent Activation Methods

1. **Slash commands** (primary):
   - `/orchestrate` → loads `.claude/agents/orchestrator.md`
   - `/plan` → loads `.claude/agents/planner.md`
   - `/review` → loads `.claude/agents/reviewer.md`
   - `/done` → loads `.claude/agents/tester.md`

2. **Direct request:**
   - "Use the security-specialist agent to review this"

3. **Orchestrator routing:**
   - Orchestrator automatically selects agents based on task

### Agent Loading

Load agents based on task type:

| Task Type | Primary Agent | Support Agents |
|-----------|---------------|----------------|
| New feature | planner → architect → implementer | reviewer, tester |
| Bug fix | debugger | reviewer, tester |
| Refactoring | refactorer | reviewer, architect |
| Performance | performance-specialist | architect, reviewer |
| UI component | frontend-specialist | reviewer, tester |
| API endpoint | backend-specialist | security, tester |
| Database | database-specialist | security, reviewer |
| Research | research-specialist | documenter |
| Documentation | documenter | — |

### Agent Protocol

See `.claude/agents/README.md` for:
- Orchestrator coordination
- Agent-to-agent context passing
- Agent responsibilities
- Parallel execution patterns

### Agent Directory
```
.claude/agents/
├── README.md               # Agent system documentation
├── _AGENT_TEMPLATE.md      # Template for new agents
├── orchestrator.md         # Main coordinator
├── planner.md              # Planning
├── architect.md            # Architecture
├── implementer.md          # Implementation
├── reviewer.md             # Code review
├── tester.md               # Testing
├── debugger.md             # Debugging
├── refactorer.md           # Refactoring
├── documenter.md           # Documentation
├── security-specialist.md  # Security
├── performance-specialist.md # Performance
├── integration-specialist.md # Integrations
├── database-specialist.md  # Database
├── frontend-specialist.md  # Frontend
├── backend-specialist.md   # Backend
└── research-specialist.md  # Research
```

---

## Auto Skill Activation (v2.3)

Claude automatically activates skills from `.claude/skills/` based on task context. Skill descriptions in YAML frontmatter guide activation:

| Task Context | Auto-Activated Skill |
|--------------|---------------------|
| UI, CSS, Tailwind, component | ui.md |
| database, Supabase, RLS, query | database.md |
| test, vitest, jest, spec | testing.md |
| API, endpoint, REST | api.md |
| React, useState, hooks | react.md |
| Vue, ref, composable | vue.md |
| Next.js, app router | nextjs.md |
| auth, security, JWT | security.md |
| debug, error, fix | debugging.md |
| TypeScript, types | typescript.md |
| git, commit, branch | git.md |

Multiple skills can activate simultaneously for complex tasks.

---

## Auto Agent Detection (v2.0)

Load agents automatically based on task keywords:

| Keywords | Agent to Activate |
|----------|-------------------|
| plan, design, architecture, feature | planner, architect |
| implement, create, add, build | implementer |
| review, check, audit | reviewer |
| test, spec, coverage | tester |
| fix, debug, error, bug, issue | debugger |
| refactor, clean, optimize code | refactorer |
| document, readme, explain | documenter |
| security, auth, vulnerability | security-specialist |
| performance, speed, optimize | performance-specialist |
| integrate, connect, API | integration-specialist |
| database, schema, migration | database-specialist |
| UI, frontend, component | frontend-specialist |
| backend, API, server | backend-specialist |
| research, analyze, compare | research-specialist |

Complex tasks automatically activate the **orchestrator**.

---

## Session Workflow

### Starting Session
1. Use `/start-session` OR manually:
   - Read PROJECT.md
   - Read SESSION_LOG.md (if exists)
   - Determine context level
   - Load relevant agents
   - Check pending tasks
2. Review last session's decisions and blockers
3. Confirm today's focus with user

### During Session
- Use `/iterate` to log significant attempts
- Use `/orchestrate` for complex multi-step tasks
- Update task status in PROJECT.md as you complete
- Note key decisions in real-time

### Ending Session
1. Use `/end-session` to:
   - Log completed work
   - Capture decisions made
   - Document patterns learned
   - Trigger pattern detection
   - Set next session priorities
2. Commit any changes

---

## Workflow

### Before Coding
1. Read PROJECT.md for context
2. Check SESSION_LOG.md for previous session context
3. Determine context level (0-4)
4. Load appropriate agents
5. Check current sprint tasks
6. Understand patterns and rules

### During Coding
- Follow patterns → PROJECT.md#patterns
- Respect rules → PROJECT.md#rules
- Use correct commands → PROJECT.md#commands
- Delegate to specialist agents when needed

### After Coding
- Run tests before commit
- Follow git conventions → PROJECT.md#git
- Update task status in PROJECT.md
- Log learnings via pattern detector

---

## Token Optimization

### Context Hierarchy (v2.0)

| Level | Tokens | When to Use |
|-------|--------|-------------|
| 0: Minimal | 100-200 | Status queries, quick questions |
| 1: Core | 500-800 | Standard tasks |
| 2: Extended | 1500-2500 | Complex implementation |
| 3: Comprehensive | 3500-5000 | Architecture decisions |
| 4: Maximum | Unlimited | Deep research, full analysis |

### Do
- Reference PROJECT.md sections instead of repeating info
- Load skills only when relevant
- Use context hierarchy levels appropriately
- Load agents on-demand
- Use `<details>` for optional context

### Don't
- Duplicate info from PROJECT.md
- Load all skills at once
- Load all agents at once
- Add unnecessary comments

---

## Slash Commands

Available in `.claude/commands/`:

### Core Commands
- `/plan` — **Use CC native** (Shift+Tab twice or type `/plan`)
- `/implement` — Execute plan
- `/review` — Review code
- `/fix` — Fix issues

> **Note (v2.6):** Framework's `/plan` removed. Use Claude Code's native `/plan` which enters plan mode with file research.

### Session Commands
- `/start-session` — Start with context from last session
- `/end-session` — Log work and set next priorities
- `/iterate` — Log significant attempt with learnings

### Workflow Commands
- `/pr` — Create PR with auto-generated description

### v2.0 Commands
- `/orchestrate` — Activate multi-agent workflow
- `/generate-skill` — Create new skill from patterns
- `/analyze-patterns` — Detect and log patterns

---

## MCP Integrations (v2.4)

When available, use MCP servers automatically:

| MCP Server | Auto-Use Scenario |
|------------|-------------------|
| Context7 | Fetch docs for unknown libraries |
| Memory | Store/retrieve project patterns, decisions |
| Playwright | Browser automation, UI testing, visual feedback |

### Playwright Quick Reference

```bash
# Install
claude mcp add playwright -- npx @anthropic-ai/mcp-playwright
```

**Common workflow:**
1. `browser_navigate` → open URL
2. `browser_snapshot` → get element refs (ALWAYS do this first!)
3. `browser_click/type/fill_form` → interact
4. `browser_snapshot` → verify result

**Key tools:**
- `browser_snapshot` — Get accessibility tree (machine-readable)
- `browser_take_screenshot` — Visual capture
- `browser_click` — Click element by ref
- `browser_fill_form` — Fill multiple fields
- `browser_console_messages` — Debug errors

See `integrations/mcp/playwright.integration.md` for full documentation.

---

## Sprint Workflow (v2.1)

When `sprint/` directory exists, use the iterative feature cycle for better progress tracking and recoverability.

### Sprint Commands

| Command | Purpose |
|---------|---------|
| `/sprint-init` | Initialize sprint from PROJECT.md tasks |
| `/feature` | Start working on next feature |
| `/done` | Complete feature (test + commit) |
| `/sprint-status` | Show sprint progress |

### Sprint Cycle

```text
/sprint-init → /feature → [work] → /done → /feature → ... → complete
```

### Key Files

- `sprint/sprint.json` — Machine-readable feature tracking
- `sprint/progress.md` — Human-readable progress log

### Rules

1. **One feature at a time** — Focus prevents context overload
2. **Testing required** — Cannot `/done` without passing tests
3. **Commit per feature** — Clean git history
4. **Recovery enabled** — Resume after context compaction

### When to Use

- Long tasks (>1 hour)
- Multiple features to implement
- Need to pause and resume work
- Want structured progress tracking

### Backwards Compatibility

Sprint workflow is **optional**. Without `sprint/` directory, framework works as before.

---

## Git-First Tracking (v2.2)

Git history is the **ultimate source of truth**. All documentation is derived from git commits.

### Hierarchy

```text
GIT HISTORY (immutable, ultimate truth)
    ↓
sprint.json (derived, reconstructable)
    ↓
progress.md, PROJECT.md, SESSION_LOG.md (views)
```

### v2.2 Commands

| Command | Purpose |
|---------|---------|
| `/sprint-reconstruct` | Rebuild sprint.json from git history |
| `/sync` | Synchronize all framework files |
| `/sync --verify` | Verify git matches sprint.json |
| `/sprint-validate` | Validate sprint.json consistency |

### Commit Message Standard

For git-based tracking to work, commits MUST include feature ID:

```text
feat(<scope>): F<ID> <description>
```

Examples:

- `feat(telemetry): F001 add withPerformanceLog utility`
- `feat(auth): F002 implement OAuth flow`

### Benefits

1. **Disaster recovery** — sprint.json can always be rebuilt from git
2. **Audit trail** — Every feature linked to specific commit
3. **Verification** — Always verify documentation matches reality
4. **Auto-sync** — All files update automatically after `/done`

---

## Reasoning Modes (v2.4)

For complex tasks, use thinking phrases:

| Phrase | Use Case |
|--------|----------|
| `"Think"` | Simple logic |
| `"Think more"` | Multi-step problems |
| `"Think a lot"` | Architecture decisions |
| `"Think longer"` | Deep debugging |
| `"Ultrathink"` | Critical decisions, complex algorithms |

**Example:** `"Ultrathink about the best auth implementation"`

### Plan Mode vs Thinking Mode

- **Plan Mode** (`Shift+Tab` twice or `/plan`) → Breadth: research more files
- **Thinking Mode** (phrase) → Depth: more reasoning tokens

> **v2.6:** Use CC native `/plan` command. Framework `/plan` has been removed.

See: `core/REASONING_MODES.md` for full documentation.

---

## Hooks (v2.4)

Automated validation via pre/post tool-use hooks.

**Configuration:** `.claude/settings.local.json` or `/hooks` command

**Available hooks:**
- `hooks/block-env.js` — Block sensitive file access (PreToolUse)
- `hooks/type-check.js` — TypeScript error detection (PostToolUse)
- `hooks/auto-format.js` — Auto-format on edit (PostToolUse)
- `hooks/usage-tracker.js` — Track skill/command/agent usage (PostToolUse)

### Usage Tracking

Monitor framework component usage:

```bash
# View usage log
cat .claude/usage.log

# Output:
# 2025-12-13T10:00:00Z | COMMAND: /orchestrate
# 2025-12-13T10:01:00Z | SKILL: testing
# 2025-12-13T10:02:00Z | AGENT: Explore
```

See: `core/HOOKS.md` for full documentation.

---

## References

### Project Files
- Tech stack → `PROJECT.md#tech-stack`
- Structure → `PROJECT.md#structure`
- Tasks → `PROJECT.md#current-sprint`
- Patterns → `PROJECT.md#patterns`
- Rules → `PROJECT.md#rules`
- Commands → `PROJECT.md#commands`
- Git → `PROJECT.md#git`
- Session history → `SESSION_LOG.md`

### Framework Core
- Skills → `.claude/skills/[name]/SKILL.md` (v2.4 format)
- Agents → `.claude/agents/`
- **Agent system → `.claude/agents/README.md` (v2.7, consolidated)**

### v2.6 Features (CC 2.1.0)
- **Native `/plan`** — Use CC built-in plan mode (framework /plan removed)
- **Wildcard permissions** — `Bash(npm *)`, `Bash(git *)` in settings
- **`context: fork`** — Skills run in isolated sub-agent context
- **`once: true` hooks** — Run hook only once per session
- **`Ctrl+B` backgrounding** — Background agents and commands
- **Settings template** → `core/settings.template.json`
- **Session init hook** → `hooks/session-init.js`

### v2.4 Features
- Hooks → `HOOKS.md`
- Reasoning modes → `REASONING_MODES.md`
- Playwright → `integrations/mcp/playwright.integration.md`
- **Verification → `VERIFICATION.md`**
- **Migration script → `scripts/migrate-skills.sh`**

### Other
- MCP integrations → `integrations/mcp/`
- Sprint tracking → `sprint/` (v2.1)
- Git-first tracking → v2.2 commands
