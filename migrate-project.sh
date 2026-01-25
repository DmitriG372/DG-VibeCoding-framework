#!/bin/bash
# DG-VibeCoding-Framework v3.0.1 - Project Migration Script
# Usage: ./migrate-project.sh /path/to/your/project
# Migrates existing v2.x project to v3.0.1

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"
VERSION=$(cat "$FRAMEWORK_DIR/VERSION" 2>/dev/null || echo "3.0.1")

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  DG-VibeCoding-Framework v${VERSION} - Migration          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate project directory
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Project directory does not exist: $PROJECT_DIR${NC}"
    exit 1
fi

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

echo -e "${GREEN}Framework:${NC} $FRAMEWORK_DIR"
echo -e "${GREEN}Project:${NC}   $PROJECT_DIR"
echo ""

# ─────────────────────────────────────────────────────────────
# 1. Backup old config
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/6] Creating backup...${NC}"

BACKUP_DIR="$PROJECT_DIR/.claude-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existing .claude directory
if [ -d "$PROJECT_DIR/.claude" ]; then
    cp -r "$PROJECT_DIR/.claude" "$BACKUP_DIR/"
    echo -e "  ${GREEN}✓${NC} Backed up .claude/ to $BACKUP_DIR"
fi

# ─────────────────────────────────────────────────────────────
# 2. Clean obsolete files
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/6] Cleaning obsolete files...${NC}"

# Remove v2.x specific files if they exist
for file in SESSION_LOG.md REASONING_MODES.md HOOKS.md VERIFICATION.md WORKTREE_ISOLATION.md; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        rm -f "$PROJECT_DIR/$file"
        echo -e "  ${GREEN}✓${NC} Removed $file"
    fi
done

# Remove sprint directory
if [ -d "$PROJECT_DIR/core/sprint" ]; then
    rm -rf "$PROJECT_DIR/core/sprint"
    echo -e "  ${GREEN}✓${NC} Removed core/sprint/"
fi

# Remove legacy commands
for cmd in sprint-init sprint-status sprint-reconstruct sprint-validate start-session end-session iterate sync analyze-patterns generate-skill implement pr qa-loop spec; do
    if [ -f "$PROJECT_DIR/.claude/commands/$cmd.md" ]; then
        rm -f "$PROJECT_DIR/.claude/commands/$cmd.md"
        echo -e "  ${GREEN}✓${NC} Removed obsolete command: $cmd"
    fi
done

# ─────────────────────────────────────────────────────────────
# 3. Update commands
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/6] Updating commands...${NC}"

mkdir -p "$PROJECT_DIR/.claude/commands"
cp "$FRAMEWORK_DIR/.claude/commands/"*.md "$PROJECT_DIR/.claude/commands/"

COMMAND_COUNT=$(ls -1 "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $COMMAND_COUNT commands updated"

# ─────────────────────────────────────────────────────────────
# 4. Update skills (keep only core 6)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/6] Updating skills...${NC}"

# Remove old skills
if [ -d "$PROJECT_DIR/.claude/skills" ]; then
    rm -rf "$PROJECT_DIR/.claude/skills"
fi
mkdir -p "$PROJECT_DIR/.claude/skills"

SKILL_COUNT=0
for skill_dir in "$FRAMEWORK_DIR/.claude/skills"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p "$PROJECT_DIR/.claude/skills/$skill_name"
        cp "$skill_dir"SKILL.md "$PROJECT_DIR/.claude/skills/$skill_name/" 2>/dev/null && ((SKILL_COUNT++)) || true
    fi
done

echo -e "  ${GREEN}✓${NC} $SKILL_COUNT core skills installed"

# ─────────────────────────────────────────────────────────────
# 5. Update agents (keep only 5 starters)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/6] Updating agents...${NC}"

# Remove old agents
if [ -d "$PROJECT_DIR/.claude/agents" ]; then
    rm -rf "$PROJECT_DIR/.claude/agents"
fi
mkdir -p "$PROJECT_DIR/.claude/agents"
cp "$FRAMEWORK_DIR/.claude/agents/"*.md "$PROJECT_DIR/.claude/agents/"

AGENT_COUNT=$(ls -1 "$PROJECT_DIR/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $AGENT_COUNT starter agents installed"

# ─────────────────────────────────────────────────────────────
# 6. Update hooks
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[6/6] Updating hooks...${NC}"

mkdir -p "$PROJECT_DIR/hooks"

# Remove old hooks, keep only block-env.js
for hook in auto-format.js session-init.js type-check.js usage-tracker.js; do
    if [ -f "$PROJECT_DIR/hooks/$hook" ]; then
        rm -f "$PROJECT_DIR/hooks/$hook"
    fi
done

cp "$FRAMEWORK_DIR/hooks/block-env.js" "$PROJECT_DIR/hooks/" 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Essential hook (block-env.js) installed"

# ─────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Migration Complete!                               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Project: ${BLUE}$PROJECT_DIR${NC}"
echo -e "Backup:  ${BLUE}$BACKUP_DIR${NC}"
echo ""
echo -e "${YELLOW}v3.0.1 Changes:${NC}"
echo "  - 6 core skills: sub-agent, debugging, testing, git, vibecoding, codex"
echo "  - 7 commands: feature, done, review, fix, orchestrate, codex-review, framework-update"
echo "  - 5 starter agents: orchestrator, implementer, reviewer, tester, debugger"
echo "  - 1 essential hook: block-env.js"
echo ""
echo -e "${YELLOW}New commands:${NC}"
echo "  /framework-update - Check for Claude Code updates"
echo "  /codex-review     - Dual-AI review with OpenAI Codex"
echo ""
echo -e "${YELLOW}Removed (obsolete):${NC}"
echo "  - Sprint commands (/sprint-init, /sprint-status, etc.)"
echo "  - Session commands (/start-session, /end-session)"
echo "  - REASONING_MODES.md, SESSION_LOG.md, HOOKS.md"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review PROJECT.md and update if needed"
echo "  2. Test with 'claude' to verify"
echo ""
