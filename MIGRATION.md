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

*Migration Guide for DG-SuperVibe-Framework v2.0*
*Last updated: 2025-11-29*
