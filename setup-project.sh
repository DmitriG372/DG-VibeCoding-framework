#!/bin/bash
# DG-VibeCoding-Framework v2.0 - Project Setup Script
# Usage: ./setup-project.sh /path/to/your/project [scale]
# Scale options: mini, normal (default), max

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
SCALE="${2:-normal}"

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  DG-VibeCoding-Framework v2.0 - Project Setup      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate project directory
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Creating project directory: $PROJECT_DIR${NC}"
    mkdir -p "$PROJECT_DIR"
fi

# Convert to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

echo -e "${GREEN}Framework:${NC} $FRAMEWORK_DIR"
echo -e "${GREEN}Project:${NC}   $PROJECT_DIR"
echo -e "${GREEN}Scale:${NC}     $SCALE"
echo ""

# Validate scale
if [[ ! "$SCALE" =~ ^(mini|normal|max)$ ]]; then
    echo -e "${RED}Error: Invalid scale '$SCALE'. Use: mini, normal, or max${NC}"
    exit 1
fi

# ─────────────────────────────────────────────────────────────
# 1. Copy core files
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/6] Copying core files...${NC}"

cp "$FRAMEWORK_DIR/core/PROJECT.md" "$PROJECT_DIR/PROJECT.md"
cp "$FRAMEWORK_DIR/core/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
cp "$FRAMEWORK_DIR/core/SESSION_LOG.md" "$PROJECT_DIR/SESSION_LOG.md"
cp "$FRAMEWORK_DIR/core/AGENT_PROTOCOL.md" "$PROJECT_DIR/AGENT_PROTOCOL.md"
cp "$FRAMEWORK_DIR/core/CONTEXT_HIERARCHY.md" "$PROJECT_DIR/CONTEXT_HIERARCHY.md"

echo -e "  ${GREEN}✓${NC} PROJECT.md, CLAUDE.md, SESSION_LOG.md"
echo -e "  ${GREEN}✓${NC} AGENT_PROTOCOL.md, CONTEXT_HIERARCHY.md"

# ─────────────────────────────────────────────────────────────
# 2. Copy .vscode settings
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/6] Setting up VS Code...${NC}"

mkdir -p "$PROJECT_DIR/.vscode"
cp "$FRAMEWORK_DIR/core/.vscode/settings.json" "$PROJECT_DIR/.vscode/settings.json"
cp "$FRAMEWORK_DIR/core/.vscode/extensions.json" "$PROJECT_DIR/.vscode/extensions.json"

echo -e "  ${GREEN}✓${NC} .vscode/settings.json"
echo -e "  ${GREEN}✓${NC} .vscode/extensions.json"

# ─────────────────────────────────────────────────────────────
# 3. Copy agents
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/6] Copying agents...${NC}"

mkdir -p "$PROJECT_DIR/agents"
cp "$FRAMEWORK_DIR/agents/"*.md "$PROJECT_DIR/agents/"

AGENT_COUNT=$(ls -1 "$PROJECT_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $AGENT_COUNT agents copied"

# ─────────────────────────────────────────────────────────────
# 4. Copy slash commands
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/6] Setting up slash commands...${NC}"

mkdir -p "$PROJECT_DIR/.claude/commands"
cp "$FRAMEWORK_DIR/commands/"*.md "$PROJECT_DIR/.claude/commands/"

COMMAND_COUNT=$(ls -1 "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $COMMAND_COUNT commands copied to .claude/commands/"

# ─────────────────────────────────────────────────────────────
# 5. Copy core skills
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/6] Copying core skills...${NC}"

mkdir -p "$PROJECT_DIR/core-skills"
cp "$FRAMEWORK_DIR/core-skills/"*.skill "$PROJECT_DIR/core-skills/"
cp "$FRAMEWORK_DIR/core-skills/INDEX.md" "$PROJECT_DIR/core-skills/"

mkdir -p "$PROJECT_DIR/project-skills"
cp "$FRAMEWORK_DIR/project-skills/INDEX.md" "$PROJECT_DIR/project-skills/"

SKILL_COUNT=$(ls -1 "$PROJECT_DIR/core-skills/"*.skill 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $SKILL_COUNT skills copied"
echo -e "  ${GREEN}✓${NC} project-skills/ directory created"

# ─────────────────────────────────────────────────────────────
# 6. Copy sprint templates (v2.1)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[6/7] Copying sprint templates...${NC}"

mkdir -p "$PROJECT_DIR/core/sprint"
cp "$FRAMEWORK_DIR/core/sprint/sprint.json.template" "$PROJECT_DIR/core/sprint/"
cp "$FRAMEWORK_DIR/core/sprint/progress.md.template" "$PROJECT_DIR/core/sprint/"

echo -e "  ${GREEN}✓${NC} Sprint templates copied"

# ─────────────────────────────────────────────────────────────
# 7. Apply scale level
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[7/7] Applying scale level: $SCALE${NC}"

# Append scale content to PROJECT.md
echo "" >> "$PROJECT_DIR/PROJECT.md"
echo "---" >> "$PROJECT_DIR/PROJECT.md"
echo "" >> "$PROJECT_DIR/PROJECT.md"
cat "$FRAMEWORK_DIR/scale/$SCALE.md" >> "$PROJECT_DIR/PROJECT.md"

echo -e "  ${GREEN}✓${NC} Scale '$SCALE' applied to PROJECT.md"

# ─────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup Complete!                                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Project structure created at: ${BLUE}$PROJECT_DIR${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit PROJECT.md with your project details"
echo "  2. Run 'cd $PROJECT_DIR && claude' to start Claude Code"
echo "  3. Use '/start-session' to begin"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo "  /plan          - Plan implementation"
echo "  /implement     - Execute plan"
echo "  /review        - Code review"
echo "  /fix           - Fix issues"
echo "  /orchestrate   - Multi-agent workflow"
echo "  /start-session - Start with context"
echo "  /end-session   - Log and close"
echo ""
echo -e "${YELLOW}Sprint commands (v2.1):${NC}"
echo "  /sprint-init   - Initialize sprint from tasks"
echo "  /feature       - Start next feature"
echo "  /done          - Complete feature (test + commit)"
echo "  /sprint-status - Show sprint progress"
echo ""
echo -e "${YELLOW}Structure created:${NC}"
echo "  $PROJECT_DIR/"
echo "  ├── PROJECT.md           # Single source of truth"
echo "  ├── CLAUDE.md            # Claude rules"
echo "  ├── SESSION_LOG.md       # Session history"
echo "  ├── AGENT_PROTOCOL.md    # Agent communication"
echo "  ├── CONTEXT_HIERARCHY.md # Token optimization"
echo "  ├── .vscode/             # VS Code settings"
echo "  ├── .claude/commands/    # Slash commands"
echo "  ├── agents/              # Agent definitions"
echo "  ├── core-skills/         # Universal skills"
echo "  ├── core/sprint/         # Sprint templates (v2.1)"
echo "  └── project-skills/      # Project-specific skills"
echo ""
