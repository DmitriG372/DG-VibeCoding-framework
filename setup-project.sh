#!/bin/bash
# DG-VibeCoding-Framework v2.4 - Project Setup Script
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
echo -e "${BLUE}║  DG-VibeCoding-Framework v2.4 - Project Setup      ║${NC}"
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
echo -e "${YELLOW}[1/9] Copying core files...${NC}"

cp "$FRAMEWORK_DIR/core/PROJECT.md" "$PROJECT_DIR/PROJECT.md"
cp "$FRAMEWORK_DIR/core/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
cp "$FRAMEWORK_DIR/core/SESSION_LOG.md" "$PROJECT_DIR/SESSION_LOG.md"
cp "$FRAMEWORK_DIR/core/AGENT_PROTOCOL.md" "$PROJECT_DIR/AGENT_PROTOCOL.md"
cp "$FRAMEWORK_DIR/core/CONTEXT_HIERARCHY.md" "$PROJECT_DIR/CONTEXT_HIERARCHY.md"
# v2.4 new files
cp "$FRAMEWORK_DIR/core/HOOKS.md" "$PROJECT_DIR/HOOKS.md"
cp "$FRAMEWORK_DIR/core/REASONING_MODES.md" "$PROJECT_DIR/REASONING_MODES.md"
cp "$FRAMEWORK_DIR/core/AGENT_ACTIVATION.md" "$PROJECT_DIR/AGENT_ACTIVATION.md"
cp "$FRAMEWORK_DIR/VERIFICATION.md" "$PROJECT_DIR/VERIFICATION.md"

echo -e "  ${GREEN}✓${NC} PROJECT.md, CLAUDE.md, SESSION_LOG.md"
echo -e "  ${GREEN}✓${NC} AGENT_PROTOCOL.md, CONTEXT_HIERARCHY.md"
echo -e "  ${GREEN}✓${NC} HOOKS.md, REASONING_MODES.md (v2.4)"
echo -e "  ${GREEN}✓${NC} AGENT_ACTIVATION.md, VERIFICATION.md (v2.4)"

# ─────────────────────────────────────────────────────────────
# 2. Copy .vscode settings
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/9] Setting up VS Code...${NC}"

mkdir -p "$PROJECT_DIR/.vscode"
cp "$FRAMEWORK_DIR/core/.vscode/settings.json" "$PROJECT_DIR/.vscode/settings.json"
cp "$FRAMEWORK_DIR/core/.vscode/extensions.json" "$PROJECT_DIR/.vscode/extensions.json"

echo -e "  ${GREEN}✓${NC} .vscode/settings.json"
echo -e "  ${GREEN}✓${NC} .vscode/extensions.json"

# ─────────────────────────────────────────────────────────────
# 3. Copy agents (to .claude/agents/ for Claude Code native support)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/9] Copying agents...${NC}"

mkdir -p "$PROJECT_DIR/.claude/agents"
cp "$FRAMEWORK_DIR/.claude/agents/"*.md "$PROJECT_DIR/.claude/agents/"

AGENT_COUNT=$(ls -1 "$PROJECT_DIR/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $AGENT_COUNT agents copied to .claude/agents/"

# ─────────────────────────────────────────────────────────────
# 4. Copy slash commands
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/9] Setting up slash commands...${NC}"

mkdir -p "$PROJECT_DIR/.claude/commands"
cp "$FRAMEWORK_DIR/.claude/commands/"*.md "$PROJECT_DIR/.claude/commands/"

COMMAND_COUNT=$(ls -1 "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $COMMAND_COUNT commands copied to .claude/commands/"

# ─────────────────────────────────────────────────────────────
# 5. Copy skills (v2.4 - subdirectory format)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/9] Copying skills (v2.4 subdirectory format)...${NC}"

mkdir -p "$PROJECT_DIR/.claude/skills"

# Copy all skill subdirectories from framework
SKILL_COUNT=0
for skill_dir in "$FRAMEWORK_DIR/.claude/skills"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p "$PROJECT_DIR/.claude/skills/$skill_name"
        cp "$skill_dir"SKILL.md "$PROJECT_DIR/.claude/skills/$skill_name/" 2>/dev/null && ((SKILL_COUNT++))
    fi
done

echo -e "  ${GREEN}✓${NC} $SKILL_COUNT skills copied to .claude/skills/*/SKILL.md"

# ─────────────────────────────────────────────────────────────
# 6. Copy sprint templates (v2.1)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[6/9] Copying sprint templates...${NC}"

mkdir -p "$PROJECT_DIR/core/sprint"
cp "$FRAMEWORK_DIR/core/sprint/sprint.json.template" "$PROJECT_DIR/core/sprint/"
cp "$FRAMEWORK_DIR/core/sprint/progress.md.template" "$PROJECT_DIR/core/sprint/"

echo -e "  ${GREEN}✓${NC} Sprint templates copied"

# ─────────────────────────────────────────────────────────────
# 7. Copy hooks (v2.4)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[7/9] Copying hooks (v2.4)...${NC}"

mkdir -p "$PROJECT_DIR/hooks"
cp "$FRAMEWORK_DIR/hooks/"*.js "$PROJECT_DIR/hooks/"

HOOK_COUNT=$(ls -1 "$PROJECT_DIR/hooks/"*.js 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $HOOK_COUNT hooks copied to hooks/"

# ─────────────────────────────────────────────────────────────
# 8. Copy scripts (v2.4)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[8/9] Copying scripts (v2.4)...${NC}"

mkdir -p "$PROJECT_DIR/scripts"
cp "$FRAMEWORK_DIR/scripts/migrate-skills.sh" "$PROJECT_DIR/scripts/"
chmod +x "$PROJECT_DIR/scripts/migrate-skills.sh"

echo -e "  ${GREEN}✓${NC} migrate-skills.sh copied to scripts/"

# ─────────────────────────────────────────────────────────────
# 9. Apply scale level
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[9/9] Applying scale level: $SCALE${NC}"

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
echo -e "${YELLOW}Skills (v2.4):${NC}"
echo "  Skills auto-activate from .claude/skills/*/SKILL.md"
echo "  No manual loading required - Claude detects relevant skills."
echo ""
echo -e "${YELLOW}Hooks (v2.4):${NC}"
echo "  Configure in .claude/settings.local.json"
echo "  See HOOKS.md for documentation"
echo ""
echo -e "${YELLOW}Structure created:${NC}"
echo "  $PROJECT_DIR/"
echo "  ├── PROJECT.md             # Single source of truth"
echo "  ├── CLAUDE.md              # Claude rules"
echo "  ├── SESSION_LOG.md         # Session history"
echo "  ├── AGENT_PROTOCOL.md      # Agent communication"
echo "  ├── CONTEXT_HIERARCHY.md   # Token optimization"
echo "  ├── HOOKS.md               # Hook system (v2.4)"
echo "  ├── REASONING_MODES.md     # Thinking modes (v2.4)"
echo "  ├── AGENT_ACTIVATION.md    # Agent activation (v2.4)"
echo "  ├── VERIFICATION.md        # Testing guide (v2.4)"
echo "  ├── .vscode/               # VS Code settings"
echo "  ├── .claude/commands/      # Slash commands"
echo "  ├── .claude/skills/*/      # Skills (v2.4 subdirectory format)"
echo "  ├── .claude/agents/        # Agent definitions (Claude Code native)"
echo "  ├── hooks/                 # Hook scripts (v2.4)"
echo "  ├── scripts/               # Utility scripts (v2.4)"
echo "  └── core/sprint/           # Sprint templates"
echo ""
