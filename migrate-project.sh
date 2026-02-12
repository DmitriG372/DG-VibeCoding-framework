#!/bin/bash
# DG-VibeCoding-Framework v4.0.0 - Project Migration Script
# Usage: ./migrate-project.sh /path/to/your/project
# Migrates existing v2.x/v3.x project to v4.0.0

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"
VERSION=$(cat "$FRAMEWORK_DIR/VERSION" 2>/dev/null || echo "4.0.0")

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
echo -e "${YELLOW}[1/9] Creating backup...${NC}"

BACKUP_DIR="$PROJECT_DIR/.claude-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existing .claude directory
if [ -d "$PROJECT_DIR/.claude" ]; then
    cp -r "$PROJECT_DIR/.claude" "$BACKUP_DIR/"
    echo -e "  ${GREEN}✓${NC} Backed up .claude/ to $BACKUP_DIR"
fi

# ─────────────────────────────────────────────────────────────
# 2. Clean obsolete files (v2.x)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/9] Cleaning v2.x obsolete files...${NC}"

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

# Remove legacy v2.x commands
for cmd in sprint-init sprint-status sprint-reconstruct sprint-validate start-session end-session iterate sync analyze-patterns generate-skill implement pr qa-loop; do
    if [ -f "$PROJECT_DIR/.claude/commands/$cmd.md" ]; then
        rm -f "$PROJECT_DIR/.claude/commands/$cmd.md"
        echo -e "  ${GREEN}✓${NC} Removed obsolete command: $cmd"
    fi
done

# ─────────────────────────────────────────────────────────────
# 3. Clean v3.x files (spec-factory → partnership)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/9] Cleaning v3.x spec-factory files...${NC}"

# Remove v3.x commands
for cmd in spec codex-review; do
    if [ -f "$PROJECT_DIR/.claude/commands/$cmd.md" ]; then
        rm -f "$PROJECT_DIR/.claude/commands/$cmd.md"
        echo -e "  ${GREEN}✓${NC} Removed v3.x command: $cmd"
    fi
done

# Remove v3.x skills
for skill in codex spec-factory; do
    if [ -d "$PROJECT_DIR/.claude/skills/$skill" ]; then
        rm -rf "$PROJECT_DIR/.claude/skills/$skill"
        echo -e "  ${GREEN}✓${NC} Removed v3.x skill: $skill"
    fi
done

# ─────────────────────────────────────────────────────────────
# 4. Update commands
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/9] Updating commands...${NC}"

mkdir -p "$PROJECT_DIR/.claude/commands"
cp "$FRAMEWORK_DIR/.claude/commands/"*.md "$PROJECT_DIR/.claude/commands/"

COMMAND_COUNT=$(ls -1 "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $COMMAND_COUNT commands updated"

# ─────────────────────────────────────────────────────────────
# 5. Update skills (6 core: sub-agent, debugging, testing, git, vibecoding, partnership)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/9] Updating skills...${NC}"

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
# 6. Update agents (keep only 5 starters)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[6/9] Updating agents...${NC}"

if [ -d "$PROJECT_DIR/.claude/agents" ]; then
    rm -rf "$PROJECT_DIR/.claude/agents"
fi
mkdir -p "$PROJECT_DIR/.claude/agents"
cp "$FRAMEWORK_DIR/.claude/agents/"*.md "$PROJECT_DIR/.claude/agents/"

AGENT_COUNT=$(ls -1 "$PROJECT_DIR/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $AGENT_COUNT starter agents installed"

# ─────────────────────────────────────────────────────────────
# 7. Update hooks
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[7/9] Updating hooks...${NC}"

mkdir -p "$PROJECT_DIR/hooks"

# Remove old hooks, keep only block-env.js
for hook in auto-format.js session-init.js type-check.js usage-tracker.js; do
    if [ -f "$PROJECT_DIR/hooks/$hook" ]; then
        rm -f "$PROJECT_DIR/hooks/$hook"
    fi
done

cp "$FRAMEWORK_DIR/hooks/"*.js "$PROJECT_DIR/hooks/" 2>/dev/null || true

HOOK_COUNT=$(ls -1 "$PROJECT_DIR/hooks/"*.js 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $HOOK_COUNT hooks installed (block-env.js, git-context.js)"

# ─────────────────────────────────────────────────────────────
# 7b. Archive CHANGELOG.md and remove old session-init hook
# ─────────────────────────────────────────────────────────────
if [ -f "$PROJECT_DIR/CHANGELOG.md" ]; then
    mv "$PROJECT_DIR/CHANGELOG.md" "$BACKUP_DIR/"
    echo -e "  ${GREEN}✓${NC} Archived CHANGELOG.md (replaced by git log hook)"
fi

if [ -f "$PROJECT_DIR/hooks/session-init.js" ]; then
    rm -f "$PROJECT_DIR/hooks/session-init.js"
    echo -e "  ${GREEN}✓${NC} Removed session-init.js (replaced by git-context.js)"
fi

# ─────────────────────────────────────────────────────────────
# 8. Install AGENTS.md and .tasks/board.md
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[8/9] Installing partnership files...${NC}"

# AGENTS.md (CX entry point)
cp "$FRAMEWORK_DIR/templates/project-init/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
echo -e "  ${GREEN}✓${NC} AGENTS.md (CX entry point)"

# .tasks/board.md
mkdir -p "$PROJECT_DIR/.tasks"
if [ ! -f "$PROJECT_DIR/.tasks/board.md" ]; then
    cp "$FRAMEWORK_DIR/templates/tasks-board.template.md" "$PROJECT_DIR/.tasks/board.md"
    echo -e "  ${GREEN}✓${NC} .tasks/board.md (new)"
else
    echo -e "  ${YELLOW}⚠${NC} .tasks/board.md already exists — keeping existing"
fi

# ─────────────────────────────────────────────────────────────
# 9. Install worktree scripts
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[9/9] Installing worktree scripts...${NC}"

mkdir -p "$PROJECT_DIR/scripts"
cp "$FRAMEWORK_DIR/scripts/worktree-setup.sh" "$PROJECT_DIR/scripts/"
cp "$FRAMEWORK_DIR/scripts/worktree-cleanup.sh" "$PROJECT_DIR/scripts/"
chmod +x "$PROJECT_DIR/scripts/worktree-setup.sh"
chmod +x "$PROJECT_DIR/scripts/worktree-cleanup.sh"

echo -e "  ${GREEN}✓${NC} worktree-setup.sh, worktree-cleanup.sh"

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
echo -e "${YELLOW}v4.0.0 Changes:${NC}"
echo "  - Partnership model: CC + CX as equal partners"
echo "  - 6 core skills: sub-agent, debugging, testing, git, vibecoding, partnership"
echo "  - 9 commands: feature, done, review, fix, orchestrate, peer-review, handoff, sync-tasks, framework-update"
echo "  - 5 starter agents: orchestrator, implementer, reviewer, tester, debugger"
echo "  - AGENTS.md: CX entry point"
echo "  - .tasks/board.md: Shared task board"
echo "  - Worktree scripts for parallel work"
echo ""
echo -e "${YELLOW}New commands:${NC}"
echo "  /handoff          - Hand off task to CX partner"
echo "  /peer-review      - Peer code review (CC or CX)"
echo "  /sync-tasks       - Task board and branch status"
echo ""
echo -e "${YELLOW}Removed (replaced):${NC}"
echo "  - /spec           → /handoff"
echo "  - /codex-review   → /peer-review"
echo "  - codex skill     → partnership skill"
echo "  - spec-factory    → partnership skill"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review PROJECT.md and update if needed"
echo "  2. Edit AGENTS.md if CX needs project-specific rules"
echo "  3. Test with 'claude' to verify"
echo ""
