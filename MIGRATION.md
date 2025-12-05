# Migration Guide: v1.1 → v2.0

## Overview

This guide helps you migrate from DG-VibeCoding-Framework v1.1 to v2.0 (DG-SuperVibe-Framework).

## What's New in v2.0

### Major Additions
- **16 Specialized Agents** - Multi-agent system for complex tasks
- **Context Hierarchy** - 5-level token optimization system
- **Meta-Programming** - Framework self-improvement capabilities
- **MCP Integrations** - Context7, GitHub, Memory server support
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
└── commands/
    ├── orchestrate.md        # NEW
    ├── generate-skill.md     # NEW
    └── analyze-patterns.md   # NEW
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
- `small` → `SOLO`
- `medium` → `TEAM`
- `large` → `SCALE`

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
cp framework/commands/sprint-init.md your-project/.claude/commands/
cp framework/commands/feature.md your-project/.claude/commands/
cp framework/commands/done.md your-project/.claude/commands/
cp framework/commands/sprint-status.md your-project/.claude/commands/
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

*Migration Guide for DG-SuperVibe-Framework v2.1*
*Last updated: 2025-12-05*
