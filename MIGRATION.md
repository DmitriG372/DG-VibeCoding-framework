# Migration Guide: v1.1 → v2.0

## Overview

This guide helps you migrate from DG-VibeCoding-Framework v1.1 to v2.0 (DG-SuperVibe-Framework).

## What's New in v2.0

### Major Additions
- **16 Specialized Agents** - Multi-agent system for complex tasks
- **Context Hierarchy** - 5-level token optimization system
- **Meta-Programming** - Framework self-improvement capabilities
- **MCP Integrations** - Context7, Memory, Playwright server support
- **VS Code Support** - Migrated from Cursor to VS Code

### New Commands
- `/orchestrate` - Multi-agent task coordination
- `/generate-skill` - Create skills from patterns
- `/analyze-patterns` - Detect code patterns

### New Structure
```
DG-VibeCoding-framework/
├── agents/           # NEW: 16 agent definitions
├── meta/             # NEW: Meta-programming system
├── integrations/     # NEW: MCP integrations
│   └── mcp/
├── core/
│   ├── AGENT_PROTOCOL.md     # NEW
│   ├── CONTEXT_HIERARCHY.md  # NEW
│   └── .vscode/              # NEW: VS Code config
└── .claude/
    ├── commands/             # Slash commands
    └── skills/               # Anthropic v2.0+ skills
```

## Migration Steps

### Step 1: Update Core Files

**CLAUDE.md** has been significantly updated. Key changes:
- Added agent loading logic
- Added auto agent detection
- Added context hierarchy
- Added MCP integration instructions

If you have customizations in CLAUDE.md, merge them with the new version.

### Step 2: Remove Cursor Files

If migrating from Cursor:
```bash
rm .cursorrules  # Remove if exists
```

The new `.vscode/` directory provides VS Code configuration.

### Step 3: Adopt Agent System

The agent system is optional but recommended for complex projects.

**Minimal adoption:**
```
Use agents/orchestrator.md for complex tasks
Use agents/implementer.md for standard coding
```

**Full adoption:**
Load relevant agents based on task keywords (see CLAUDE.md for auto-detection).

### Step 4: Configure Context Levels

Add to your project's CLAUDE.md:
```markdown
## Context Level
Default: Level 1 (Core)
Override: Specify level for complex tasks
```

### Step 5: Enable MCP Integrations (Optional)

If you use MCP servers:
1. Review `integrations/mcp/` files
2. Update your Claude Code MCP config
3. Reference integration patterns in prompts

## Breaking Changes

### 1. No More .cursorrules
- Cursor-specific config removed
- Use `.vscode/` for VS Code settings

### 2. Skills Directory Structure
Old:
```
skills/
├── react.skill
├── nextjs.skill
```

New (recommended):
```
skills/
├── component/
│   └── modal.skill
├── hook/
│   └── use-form.skill
└── api/
    └── crud.skill
```

### 3. Scale Levels Renamed
- `small` → `mini` (prototypes, experiments)
- `medium` → `normal` (standard projects)
- `large` → `max` (complex, long-term)

## Compatibility

### Fully Compatible
- All existing skills
- All existing commands (except Cursor-specific)
- Project configurations
- Custom CLAUDE.md additions

### Requires Update
- Cursor-specific workflows → VS Code
- Old scale level names → new names
- Flat skill structure → categorized (optional)

## Rollback

If needed, rollback to v1.1:
```bash
git checkout v1.1  # If using git tags
```

Or manually:
1. Remove `agents/` directory
2. Remove `meta/` directory
3. Remove `integrations/` directory
4. Restore old `core/CLAUDE.md`
5. Restore `.cursorrules` if needed

## FAQ

### Do I need to use all 16 agents?
No. Start with orchestrator + implementer. Add others as needed.

### Will my existing skills work?
Yes. Existing skills are fully compatible.

### Do I need VS Code?
No. The framework works with any editor + Claude Code CLI. VS Code config is optional convenience.

### Can I use Cursor instead?
Yes, but you'll need to create your own `.cursorrules` from `core/CLAUDE.md`.

### Is the meta-programming system required?
No. It's an advanced feature for framework optimization.

## Support

- Issues: GitHub repository
- Documentation: README.md
- Examples: See agent files for usage examples

---

# Migration Guide: v2.0 → v2.1

## Overview

This guide helps you migrate from DG-SuperVibe-Framework v2.0 to v2.1.

## What's New in v2.1

### Sprint Workflow (Anthropic Agentic Workflow)

Based on Anthropic's recommended workflow for long tasks:

- **`sprint/sprint.json`** — Machine-readable feature tracking
- **`sprint/progress.md`** — Human-readable progress log
- **Iterative cycle** — One feature at a time with mandatory testing
- **Recovery** — Resume work after context compaction

### New Commands

| Command | Purpose |
|---------|---------|
| `/sprint-init` | Initialize sprint from PROJECT.md tasks |
| `/feature` | Start working on next feature |
| `/done` | Complete feature (test + commit) |
| `/sprint-status` | Show sprint progress |

### Updated Agents

- **orchestrator.md** — Sprint Cycle Enforcement section
- **tester.md** — /done integration (mandatory testing)

## Migration Steps

### Automatic Migration

Run the migration script:

```bash
cd /path/to/framework
./migrate-to-sprint.sh /path/to/your/project
```

This will:
1. Copy sprint templates to `core/sprint/`
2. Add 4 new commands to `.claude/commands/`
3. Update orchestrator and tester agents
4. Add Sprint Workflow section to CLAUDE.md

### Manual Migration

If you prefer manual migration:

#### Step 1: Copy Templates

```bash
mkdir -p your-project/core/sprint
cp framework/core/sprint/*.template your-project/core/sprint/
```

#### Step 2: Copy Commands

```bash
cp framework/.claude/commands/sprint-init.md your-project/.claude/commands/
cp framework/.claude/commands/feature.md your-project/.claude/commands/
cp framework/.claude/commands/done.md your-project/.claude/commands/
cp framework/.claude/commands/sprint-status.md your-project/.claude/commands/
```

#### Step 3: Update Agents

```bash
cp framework/agents/orchestrator.md your-project/agents/
cp framework/agents/tester.md your-project/agents/
```

#### Step 4: Update CLAUDE.md

Add to your project's CLAUDE.md:

```markdown
## Sprint Workflow (v2.1)

When `sprint/` directory exists, use iterative feature cycle.

### Commands
- `/sprint-init` — Initialize sprint
- `/feature` — Start next feature
- `/done` — Complete with test + commit
- `/sprint-status` — Show progress

### Cycle
/sprint-init → /feature → [work] → /done → repeat
```

## Using Sprint Workflow

After migration:

1. **Add tasks** to PROJECT.md#Current Sprint
2. **Initialize** with `/sprint-init`
3. **Start feature** with `/feature`
4. **Work** on implementation
5. **Complete** with `/done` (runs tests, commits)
6. **Repeat** until sprint complete

## Backwards Compatibility

Sprint workflow is **completely optional**:

- Without `sprint/` directory, framework works exactly as v2.0
- All existing commands and agents continue to work
- No breaking changes

## Benefits of Sprint Workflow

1. **Jätkamisvõime** — Resume after context loss
2. **Testimine** — Mandatory tests before completion
3. **Git ajalugu** — One commit per feature
4. **Fokus** — One feature at a time prevents overload

---

# Migration Guide: v2.1 → v2.2

## Overview

This guide helps you migrate from DG-SuperVibe-Framework v2.1 to v2.2 (Git-First Tracking).

## What's New in v2.2

### Git-First Tracking

Git history is now the **ultimate source of truth**:

```text
┌─────────────────────────────────────────────────────────┐
│                  ULTIMATE SOURCE OF TRUTH                │
│                     GIT HISTORY                          │
│     (immutable, auditable, cannot be lost)               │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                  DERIVED STATE                           │
│                  sprint.json                             │
│     (reconstructable from git, cached state)             │
└────────────────────────┬────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
   progress.md     PROJECT.md     SESSION_LOG.md
    (visual)       (summary)       (history)
```

### New Commands

| Command | Purpose |
|---------|---------|
| `/sprint-reconstruct` | Rebuild sprint.json from git history |
| `/sync` | Synchronize all framework files |
| `/sync --verify` | Verify git matches sprint.json |
| `/sprint-validate` | Validate sprint.json consistency |

### Updated Commands

| Command | Changes |
|---------|---------|
| `/done` | Now captures git hash + timestamp, runs auto-sync |
| `/start-session` | Now verifies git sync before starting |

### Updated sprint.json Format

Old (v2.1):

```json
{
  "version": "2.1",
  "features": [
    {
      "id": "F001",
      "status": "done",
      "commits": ["abc1234"]
    }
  ]
}
```

New (v2.2):

```json
{
  "version": "2.2",
  "source": "git",
  "features": [
    {
      "id": "F001",
      "status": "done",
      "git": {
        "hash": "abc1234def5678...",
        "message": "feat(scope): F001 feature name",
        "timestamp": "2025-12-06T12:00:00+02:00"
      }
    }
  ],
  "last_verified": "2025-12-06T15:00:00+02:00"
}
```

## Migration Steps

### Step 1: Copy New Commands

```bash
cp framework/.claude/commands/sprint-reconstruct.md your-project/.claude/commands/
cp framework/.claude/commands/sync.md your-project/.claude/commands/
cp framework/.claude/commands/sprint-validate.md your-project/.claude/commands/
```

### Step 2: Update Existing Commands

```bash
cp framework/.claude/commands/done.md your-project/.claude/commands/
cp framework/.claude/commands/start-session.md your-project/.claude/commands/
```

### Step 3: Update sprint.json Template

```bash
cp framework/core/sprint/sprint.json.template your-project/core/sprint/
```

### Step 4: Migrate Existing sprint.json

If you have an existing sprint with features, run:

```bash
/sprint-reconstruct
```

This will rebuild sprint.json from git history with proper v2.2 format.

### Step 5: Verify Migration

```bash
/sync --verify
```

Should report all features verified against git.

## Commit Message Standard (CRITICAL)

For `/sprint-reconstruct` to work, commits MUST include feature ID:

**Format:**

```text
feat(<scope>): F<ID> <description>
```

**Examples:**

```text
feat(telemetry): F001 add withPerformanceLog utility
feat(auth): F002 implement OAuth flow
feat(ui): F003 create dashboard component
```

**Bulk commits:**

```text
feat(telemetry): complete F001-F004 full integration
```

Expands to: F001, F002, F003, F004

## Benefits of v2.2

1. **100% kindlus** — Git is immutable, cannot be accidentally overwritten
2. **Disaster recovery** — sprint.json can always be rebuilt from git
3. **Audit trail** — Every feature linked to specific commit
4. **Merge conflict resolution** — Reconstruct from git after merge
5. **Verification** — Always verify documentation matches reality

## Backwards Compatibility

- Existing sprint.json will continue to work
- `/sprint-reconstruct` can upgrade v2.1 → v2.2 format
- All v2.1 commands still work
- Auto-sync ensures files stay in sync

---

# Migration Guide: v2.2 → v2.3

## Overview

This guide helps you migrate from DG-SuperVibe-Framework v2.2 to v2.3 (Anthropic Skills v2.0+).

## What's New in v2.3

### Anthropic Official Skills Format

Skills now use Anthropic's official format with YAML frontmatter:

**Old location:** `core-skills/*.skill`
**New location:** `.claude/skills/*.md`

**Old format:**

```markdown
# Skill Name

> Description

## Content...
```

**New format (v2.3):**

```markdown
---
name: skill-name
description: "Brief description for auto-activation"
---

# Skill Name

> Description

## Content...
```

### Auto-Activation

Claude now automatically activates relevant skills based on the `description` field in YAML frontmatter. No manual loading required.

### 22 Migrated Skills

All core-skills have been converted:

| Skill | Purpose |
|-------|---------|
| `framework-philosophy.md` | Core principles |
| `vue.md` | Vue 3 + Composition API |
| `react.md` | React 18+ patterns |
| `database.md` | Database design |
| `testing.md` | Testing patterns |
| ... | (22 total) |

## Migration Steps

### Step 1: Create Skills Directory

```bash
mkdir -p your-project/.claude/skills
```

### Step 2: Migrate Skills

For each `.skill` file:

1. Copy to `.claude/skills/[name].md`
2. Add YAML frontmatter:

```yaml
---
name: skill-name
description: "Brief description for auto-activation"
---
```

### Step 3: Update References

Update any documentation that references:

- `core-skills/*.skill` → `.claude/skills/*.md`
- `project-skills/*.skill` → `.claude/skills/*.md`
- "Load skill" → "Skills auto-activate"

### Step 4: Update CLAUDE.md

Replace skill loading sections with:

```markdown
## Skills (Anthropic v2.0+ Format)

Skills in `.claude/skills/` auto-activate based on task context.

See `.claude/skills/` for all available skills.
```

### Step 5: Clean Up (Optional)

Legacy directories can be kept for reference or removed:

```bash
# Optional: Remove legacy skill directories
rm -rf core-skills/
rm -rf project-skills/
```

## Backwards Compatibility

- Legacy `.skill` files continue to work if manually loaded
- Framework auto-detects new format in `.claude/skills/`
- All v2.2 features (Git-First, Sprint Workflow) unchanged

## Benefits of v2.3

1. **Official format** — Uses Anthropic's recommended skill format
2. **Auto-activation** — No manual skill loading needed
3. **Standard location** — `.claude/skills/` is the official directory
4. **Better discovery** — YAML frontmatter enables smart activation

---

# Migration Guide: v2.3 → v2.4

## Overview

This guide helps you migrate from DG-SuperVibe-Framework v2.3 to v2.4 (Hooks + Reasoning Modes + Agent Activation + Skills Format).

## What's New in v2.4

### Skills Subdirectory Format (BREAKING CHANGE)

**Skills must now be in subdirectory format:**

Old (v2.3):
```
.claude/skills/
├── react.md          ❌ Won't be detected
├── testing.md        ❌ Won't be detected
└── vue.md            ❌ Won't be detected
```

New (v2.4):
```
.claude/skills/
├── react/
│   └── SKILL.md      ✅ Correct
├── testing/
│   └── SKILL.md      ✅ Correct
└── vue/
    └── SKILL.md      ✅ Correct
```

**Migration script:** `./scripts/migrate-skills.sh`

### Agent Activation System

Framework agents are now properly documented and activated via slash commands:

```
/orchestrate "Add authentication"
       │
       ▼
Read: agents/orchestrator.md  ← Command loads agent file
       │
       ▼
Claude adopts orchestrator role
       │
       ▼
Output: Orchestration Plan
```

| Command | Loads Agent |
|---------|-------------|
| `/orchestrate` | `agents/orchestrator.md` |
| `/plan` | `agents/planner.md` |
| `/review` | `agents/reviewer.md` |
| `/done` | `agents/tester.md` |

### Hooks System

Automated validation via pre/post tool-use hooks:

| Hook Event | When | Can Block? |
|------------|------|------------|
| `PreToolUse` | Before tool execution | ✅ Yes (exit 2) |
| `PostToolUse` | After tool execution | ❌ No |
| `SessionStart` | Session begins | ❌ No |
| `SessionEnd` | Session ends | ❌ No |
| `UserPromptSubmit` | User submits prompt | ✅ Yes |

### Usage Tracking

New hook to monitor framework component usage:

```bash
cat .claude/usage.log

# Output:
# 2025-12-13T10:00:00Z | COMMAND: /orchestrate
# 2025-12-13T10:01:00Z | SKILL: testing
# 2025-12-13T10:02:00Z | AGENT: Explore
```

### Reasoning Modes (Extended Thinking)

Unlock deeper reasoning with phrases:

| Phrase | Level | Use Case |
|--------|-------|----------|
| `"Think"` | Basic | Simple logic |
| `"Think more"` | Extended | Multi-step problems |
| `"Think a lot"` | Comprehensive | Architecture decisions |
| `"Think longer"` | Extended time | Deep debugging |
| `"Ultrathink"` | Maximum | Critical decisions |

### Context Control

| Action | Method | Purpose |
|--------|--------|---------|
| Stop | `Escape` | Stop mid-response |
| Rewind | `Escape` twice | Jump back in conversation |
| Summarize | `/compact` | Preserve knowledge, reduce noise |
| Fresh start | `/clear` | Delete conversation |

### Playwright MCP

Browser automation for UI development:

```bash
claude mcp add playwright -- npx @anthropic-ai/mcp-playwright
```

Key tools: `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_fill_form`

### New Files

| File | Purpose |
|------|---------|
| `core/HOOKS.md` | Hook system documentation |
| `core/REASONING_MODES.md` | Thinking modes + context control |
| `core/AGENT_ACTIVATION.md` | How agents work via commands |
| `VERIFICATION.md` | Framework testing guide |
| `hooks/block-env.js` | Block sensitive file access |
| `hooks/type-check.js` | TypeScript error detection |
| `hooks/auto-format.js` | Auto-format on edit |
| `hooks/usage-tracker.js` | Track skill/command/agent usage |
| `scripts/migrate-skills.sh` | Convert skills to subdirectory format |
| `integrations/mcp/playwright.integration.md` | Playwright MCP guide |

## Migration Steps

### Step 1: Copy New Core Files

```bash
cp framework/core/HOOKS.md your-project/core/
cp framework/core/REASONING_MODES.md your-project/core/
```

### Step 2: Copy Hooks Directory

```bash
mkdir -p your-project/hooks
cp framework/hooks/*.js your-project/hooks/
```

### Step 3: Copy Playwright Integration

```bash
cp framework/integrations/mcp/playwright.integration.md your-project/integrations/mcp/
```

### Step 4: Update CLAUDE.md

Add to your project's CLAUDE.md:

```markdown
## Reasoning Modes (v2.4)

For complex tasks, use thinking phrases:
- "Think" → Simple logic
- "Think more" → Multi-step problems
- "Think a lot" → Architecture decisions
- "Ultrathink" → Critical decisions

See: core/REASONING_MODES.md

---

## Hooks (v2.4)

Automated validation via hooks.

Configuration: `.claude/settings.local.json`

See: core/HOOKS.md
```

### Step 5: Configure Hooks (Optional)

Add to `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Grep",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/block-env.js"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/type-check.js"
          }
        ]
      }
    ]
  }
}
```

### Step 6: Install Playwright MCP (Optional)

```bash
claude mcp add playwright -- npx @anthropic-ai/mcp-playwright
```

### Step 7: Remove GitHub MCP (If Present)

GitHub MCP has been removed. Use `gh` CLI directly instead:

```bash
# Remove from MCP config if present
claude mcp remove github
```

## Hook Configuration Locations

Hooks can be defined in three locations (priority order):

| Location | Scope | Committed? |
|----------|-------|------------|
| `~/.claude/settings.json` | Global (all projects) | No |
| `.claude/settings.json` | Project (team) | Yes |
| `.claude/settings.local.json` | Project (personal) | No |

## Hook Format (2025)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Grep|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/my-hook.js",
            "timeout": 30,
            "statusMessage": "Running validation..."
          }
        ]
      }
    ]
  }
}
```

**Important:** Tool names are case-sensitive (`Read`, not `read`).

## MCP Changes

| v2.3 | v2.4 |
|------|------|
| Context7 | Context7 ✅ |
| Memory | Memory ✅ |
| GitHub | ❌ Removed (use `gh` CLI) |
| — | Playwright ✅ NEW |

## Backwards Compatibility

- All v2.3 features (Skills, Git-First, Sprint) unchanged
- Hooks are optional — framework works without them
- Reasoning modes are optional — just add phrases when needed
- Playwright MCP is optional — install only if needed

## Benefits of v2.4

1. **Automated validation** — Hooks catch errors before they happen
2. **Deeper reasoning** — Thinking modes for complex tasks
3. **Visual development** — Playwright for UI work
4. **Better control** — Context control for long sessions
5. **Security** — Block sensitive file access with hooks

## Quick Start Checklist

- [ ] Copy `core/HOOKS.md`
- [ ] Copy `core/REASONING_MODES.md`
- [ ] Copy `hooks/` directory
- [ ] Copy `integrations/mcp/playwright.integration.md`
- [ ] Update CLAUDE.md with v2.4 sections
- [ ] (Optional) Configure hooks in settings.local.json
- [ ] (Optional) Install Playwright MCP
- [ ] (Optional) Remove GitHub MCP if present

---

*Migration Guide for DG-SuperVibe-Framework v2.4*
*Last updated: 2025-12-13*
