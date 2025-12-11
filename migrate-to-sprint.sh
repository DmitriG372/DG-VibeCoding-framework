#!/bin/bash
# DG-VibeCoding-Framework v2.3 - Sprint Migration Script
# Usage: ./migrate-to-sprint.sh /path/to/your/project
# Migrates existing project to use sprint workflow + Anthropic v2.0+ skills

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory (framework location)
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  DG-VibeCoding-Framework v2.3 - Sprint Migration   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate project directory
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Project directory does not exist: $PROJECT_DIR${NC}"
    exit 1
fi

# Convert to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

echo -e "${GREEN}Framework:${NC} $FRAMEWORK_DIR"
echo -e "${GREEN}Project:${NC}   $PROJECT_DIR"
echo ""

# Check if already has sprint
if [ -d "$PROJECT_DIR/sprint" ]; then
    echo -e "${YELLOW}Warning: sprint/ directory already exists${NC}"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Migration cancelled."
        exit 0
    fi
fi

# ─────────────────────────────────────────────────────────────
# 1. Copy sprint templates
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/5] Copying sprint templates...${NC}"

mkdir -p "$PROJECT_DIR/core/sprint"
cp "$FRAMEWORK_DIR/core/sprint/sprint.json.template" "$PROJECT_DIR/core/sprint/"
cp "$FRAMEWORK_DIR/core/sprint/progress.md.template" "$PROJECT_DIR/core/sprint/"

echo -e "  ${GREEN}✓${NC} Sprint templates copied"

# ─────────────────────────────────────────────────────────────
# 2. Copy new sprint commands
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/5] Copying sprint commands...${NC}"

mkdir -p "$PROJECT_DIR/.claude/commands"
cp "$FRAMEWORK_DIR/commands/sprint-init.md" "$PROJECT_DIR/.claude/commands/"
cp "$FRAMEWORK_DIR/commands/feature.md" "$PROJECT_DIR/.claude/commands/"
cp "$FRAMEWORK_DIR/commands/done.md" "$PROJECT_DIR/.claude/commands/"
cp "$FRAMEWORK_DIR/commands/sprint-status.md" "$PROJECT_DIR/.claude/commands/"

echo -e "  ${GREEN}✓${NC} 4 sprint commands copied"

# ─────────────────────────────────────────────────────────────
# 3. Copy skills (v2.3 - Anthropic v2.0+ format)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/5] Copying skills (Anthropic v2.0+ format)...${NC}"

mkdir -p "$PROJECT_DIR/.claude/skills"

# Copy all skills from framework
SKILL_COUNT=0
for skill in "$FRAMEWORK_DIR/.claude/skills"/*.md; do
    if [ -f "$skill" ]; then
        cp "$skill" "$PROJECT_DIR/.claude/skills/"
        ((SKILL_COUNT++))
    fi
done

echo -e "  ${GREEN}✓${NC} $SKILL_COUNT skills copied to .claude/skills/"

# ─────────────────────────────────────────────────────────────
# 4. Update agents (if exist)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/5] Updating agents...${NC}"

if [ -d "$PROJECT_DIR/agents" ]; then
    cp "$FRAMEWORK_DIR/agents/orchestrator.md" "$PROJECT_DIR/agents/"
    cp "$FRAMEWORK_DIR/agents/tester.md" "$PROJECT_DIR/agents/"
    echo -e "  ${GREEN}✓${NC} orchestrator.md updated (Sprint Cycle Enforcement)"
    echo -e "  ${GREEN}✓${NC} tester.md updated (/done integration)"
else
    echo -e "  ${YELLOW}⚠${NC} agents/ directory not found, skipping"
fi

# ─────────────────────────────────────────────────────────────
# 5. Update CLAUDE.md (if exists)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/5] Updating CLAUDE.md...${NC}"

if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    # Check if already has Sprint Workflow section
    if grep -q "Sprint Workflow" "$PROJECT_DIR/CLAUDE.md"; then
        echo -e "  ${YELLOW}⚠${NC} Sprint Workflow section already exists"
    else
        # Append sprint workflow section
        cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'

---

## Sprint Workflow (v2.1)

When `sprint/` directory exists, use the iterative feature cycle.

### Commands

| Command | Purpose |
|---------|---------|
| `/sprint-init` | Initialize sprint from PROJECT.md tasks |
| `/feature` | Start working on next feature |
| `/done` | Complete feature (test + commit) |
| `/sprint-status` | Show sprint progress |

### Cycle

```
/sprint-init → /feature → [work] → /done → /feature → ... → complete
```

See `core/sprint/` for templates.
EOF
        echo -e "  ${GREEN}✓${NC} Sprint Workflow section added to CLAUDE.md"
    fi

    # Check if already has Skills section (v2.3)
    if grep -q "Skills (Anthropic v2.0" "$PROJECT_DIR/CLAUDE.md" || grep -q ".claude/skills/" "$PROJECT_DIR/CLAUDE.md"; then
        echo -e "  ${YELLOW}⚠${NC} Skills section already exists"
    else
        # Append skills section
        cat >> "$PROJECT_DIR/CLAUDE.md" << 'EOF'

---

## Skills (Anthropic v2.0+ Format)

Skills in `.claude/skills/` auto-activate based on task context.

See `.claude/skills/` for all available skills.
EOF
        echo -e "  ${GREEN}✓${NC} Skills section added to CLAUDE.md"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} CLAUDE.md not found, skipping"
fi

# ─────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Migration Complete!                               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Project upgraded to v2.3 at: ${BLUE}$PROJECT_DIR${NC}"
echo ""
echo -e "${YELLOW}New sprint commands available:${NC}"
echo "  /sprint-init   - Initialize sprint from PROJECT.md tasks"
echo "  /feature       - Start next feature"
echo "  /done          - Complete feature (test + commit)"
echo "  /sprint-status - Show sprint progress"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Add tasks to PROJECT.md#Current Sprint"
echo "  2. Run /sprint-init to create sprint.json"
echo "  3. Use /feature to start working"
echo "  4. Use /done when implementation is tested"
echo ""
echo -e "${YELLOW}Skills (v2.3):${NC}"
echo "  Skills auto-activate from .claude/skills/ based on task context."
echo "  No manual loading required - Claude detects relevant skills."
echo ""
echo -e "${YELLOW}Sprint workflow is optional:${NC}"
echo "  Without running /sprint-init, project works as before."
echo ""
