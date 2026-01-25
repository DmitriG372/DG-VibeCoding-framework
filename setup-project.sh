#!/bin/bash
# DG-VibeCoding-Framework v3.0.1 - Project Setup Script
# Usage: ./setup-project.sh /path/to/your/project

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory (framework location)
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

# Read version
VERSION=$(cat "$FRAMEWORK_DIR/VERSION" 2>/dev/null || echo "3.0.1")

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  DG-VibeCoding-Framework v${VERSION} - Project Setup      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate/create project directory
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Creating project directory: $PROJECT_DIR${NC}"
    mkdir -p "$PROJECT_DIR"
fi

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

echo -e "${GREEN}Framework:${NC} $FRAMEWORK_DIR"
echo -e "${GREEN}Project:${NC}   $PROJECT_DIR"
echo ""

# ─────────────────────────────────────────────────────────────
# 1. Copy core files
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/5] Copying core files...${NC}"

cp "$FRAMEWORK_DIR/templates/project-init/PROJECT.md" "$PROJECT_DIR/PROJECT.md"
cp "$FRAMEWORK_DIR/templates/project-init/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"

echo -e "  ${GREEN}✓${NC} PROJECT.md, CLAUDE.md"

# ─────────────────────────────────────────────────────────────
# 2. Copy agents
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/5] Copying agents...${NC}"

mkdir -p "$PROJECT_DIR/.claude/agents"
cp "$FRAMEWORK_DIR/.claude/agents/"*.md "$PROJECT_DIR/.claude/agents/"

AGENT_COUNT=$(ls -1 "$PROJECT_DIR/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $AGENT_COUNT agents copied"

# ─────────────────────────────────────────────────────────────
# 3. Copy commands
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/5] Copying commands...${NC}"

mkdir -p "$PROJECT_DIR/.claude/commands"
cp "$FRAMEWORK_DIR/.claude/commands/"*.md "$PROJECT_DIR/.claude/commands/"

COMMAND_COUNT=$(ls -1 "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $COMMAND_COUNT commands copied"

# ─────────────────────────────────────────────────────────────
# 4. Copy skills
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/5] Copying skills...${NC}"

mkdir -p "$PROJECT_DIR/.claude/skills"

SKILL_COUNT=0
for skill_dir in "$FRAMEWORK_DIR/.claude/skills"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p "$PROJECT_DIR/.claude/skills/$skill_name"
        cp "$skill_dir"SKILL.md "$PROJECT_DIR/.claude/skills/$skill_name/" 2>/dev/null && ((SKILL_COUNT++)) || true
    fi
done

echo -e "  ${GREEN}✓${NC} $SKILL_COUNT skills copied"

# ─────────────────────────────────────────────────────────────
# 5. Copy hooks
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/5] Copying hooks...${NC}"

mkdir -p "$PROJECT_DIR/hooks"
cp "$FRAMEWORK_DIR/hooks/"*.js "$PROJECT_DIR/hooks/" 2>/dev/null || true

HOOK_COUNT=$(ls -1 "$PROJECT_DIR/hooks/"*.js 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $HOOK_COUNT hooks copied"

# ─────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup Complete!                                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Project: ${BLUE}$PROJECT_DIR${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit PROJECT.md with your project details"
echo "  2. Run 'cd $PROJECT_DIR && claude' to start"
echo ""
echo -e "${YELLOW}Core commands:${NC}"
echo "  /feature         - Start new feature"
echo "  /done            - Complete (test + commit)"
echo "  /review          - Code review"
echo "  /fix             - Fix issues"
echo "  /orchestrate     - Multi-agent workflow"
echo "  /codex-review    - Dual-AI review"
echo "  /framework-update - Check updates"
echo ""
echo -e "${YELLOW}Structure:${NC}"
echo "  $PROJECT_DIR/"
echo "  ├── PROJECT.md           # Project context"
echo "  ├── CLAUDE.md            # Claude rules"
echo "  ├── .claude/commands/    # Slash commands"
echo "  ├── .claude/skills/      # Auto-activated skills"
echo "  ├── .claude/agents/      # Agent definitions"
echo "  └── hooks/               # Validation hooks"
echo ""
