#!/bin/bash
# DG-VibeCoding-Framework v5.0.0 - Project Migration Script
# Usage: ./migrate-project.sh /path/to/your/project
# Migrates existing v2.x/v3.x/v4.x project to v5.0.0

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"
VERSION=$(cat "$FRAMEWORK_DIR/VERSION" 2>/dev/null || echo "5.0.0")

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

# Detect current version
CURRENT_VERSION="unknown"
if [ -f "$PROJECT_DIR/.claude/commands/sprint-status.md" ]; then
    CURRENT_VERSION="5.x"
elif [ -f "$PROJECT_DIR/.tasks/board.md" ]; then
    CURRENT_VERSION="4.x"
elif [ -f "$PROJECT_DIR/.claude/commands/spec.md" ]; then
    CURRENT_VERSION="3.x"
elif [ -f "$PROJECT_DIR/.claude/commands/implement.md" ]; then
    CURRENT_VERSION="2.x"
fi
echo -e "${YELLOW}Detected version:${NC} $CURRENT_VERSION"
echo ""

# ─────────────────────────────────────────────────────────────
# 1. Backup old config
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/10] Creating backup...${NC}"

BACKUP_DIR="$PROJECT_DIR/.claude-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup existing .claude directory
if [ -d "$PROJECT_DIR/.claude" ]; then
    cp -r "$PROJECT_DIR/.claude" "$BACKUP_DIR/"
    echo -e "  ${GREEN}✓${NC} Backed up .claude/ to $BACKUP_DIR"
fi

# Backup board.md if exists
if [ -f "$PROJECT_DIR/.tasks/board.md" ]; then
    cp "$PROJECT_DIR/.tasks/board.md" "$BACKUP_DIR/board.md"
    echo -e "  ${GREEN}✓${NC} Backed up .tasks/board.md"
fi

# ─────────────────────────────────────────────────────────────
# 2. Clean obsolete files (v2.x)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/10] Cleaning v2.x obsolete files...${NC}"

for file in SESSION_LOG.md REASONING_MODES.md HOOKS.md VERIFICATION.md WORKTREE_ISOLATION.md; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        rm -f "$PROJECT_DIR/$file"
        echo -e "  ${GREEN}✓${NC} Removed $file"
    fi
done

if [ -d "$PROJECT_DIR/core/sprint" ]; then
    rm -rf "$PROJECT_DIR/core/sprint"
    echo -e "  ${GREEN}✓${NC} Removed core/sprint/"
fi

for cmd in sprint-init sprint-status sprint-reconstruct sprint-validate start-session end-session iterate sync analyze-patterns generate-skill implement pr qa-loop; do
    if [ -f "$PROJECT_DIR/.claude/commands/$cmd.md" ]; then
        rm -f "$PROJECT_DIR/.claude/commands/$cmd.md"
        echo -e "  ${GREEN}✓${NC} Removed obsolete command: $cmd"
    fi
done

# ─────────────────────────────────────────────────────────────
# 3. Clean v3.x files (spec-factory → partnership)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/10] Cleaning v3.x spec-factory files...${NC}"

for cmd in spec codex-review; do
    if [ -f "$PROJECT_DIR/.claude/commands/$cmd.md" ]; then
        rm -f "$PROJECT_DIR/.claude/commands/$cmd.md"
        echo -e "  ${GREEN}✓${NC} Removed v3.x command: $cmd"
    fi
done

for skill in codex spec-factory; do
    if [ -d "$PROJECT_DIR/.claude/skills/$skill" ]; then
        rm -rf "$PROJECT_DIR/.claude/skills/$skill"
        echo -e "  ${GREEN}✓${NC} Removed v3.x skill: $skill"
    fi
done

# ─────────────────────────────────────────────────────────────
# 4. Clean v4.x files (board.md → sprint.json)
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/10] Cleaning v4.x board.md system...${NC}"

# Remove validate-board hook
if [ -f "$PROJECT_DIR/hooks/validate-board.js" ]; then
    rm -f "$PROJECT_DIR/hooks/validate-board.js"
    echo -e "  ${GREEN}✓${NC} Removed hooks/validate-board.js"
fi

# Remove sync-tasks command (replaced by sprint-status)
if [ -f "$PROJECT_DIR/.claude/commands/sync-tasks.md" ]; then
    rm -f "$PROJECT_DIR/.claude/commands/sync-tasks.md"
    echo -e "  ${GREEN}✓${NC} Removed sync-tasks.md (replaced by sprint-status)"
fi

# Remove .tasks directory (board.md backed up in step 1)
if [ -d "$PROJECT_DIR/.tasks" ]; then
    rm -rf "$PROJECT_DIR/.tasks"
    echo -e "  ${GREEN}✓${NC} Removed .tasks/ directory (board.md backed up)"
fi

# Remove old progress.md if it exists
if [ -f "$PROJECT_DIR/sprint/progress.md" ]; then
    rm -f "$PROJECT_DIR/sprint/progress.md"
    echo -e "  ${GREEN}✓${NC} Removed sprint/progress.md (replaced by auto-generated sprint.md)"
fi

# ─────────────────────────────────────────────────────────────
# 5. Update commands
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/10] Updating commands...${NC}"

mkdir -p "$PROJECT_DIR/.claude/commands"
cp "$FRAMEWORK_DIR/.claude/commands/"*.md "$PROJECT_DIR/.claude/commands/"

COMMAND_COUNT=$(ls -1 "$PROJECT_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $COMMAND_COUNT commands updated"

# ─────────────────────────────────────────────────────────────
# 6. Update skills
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[6/10] Updating skills...${NC}"

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
# 7. Update agents
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[7/10] Updating agents...${NC}"

if [ -d "$PROJECT_DIR/.claude/agents" ]; then
    rm -rf "$PROJECT_DIR/.claude/agents"
fi
mkdir -p "$PROJECT_DIR/.claude/agents"
cp "$FRAMEWORK_DIR/.claude/agents/"*.md "$PROJECT_DIR/.claude/agents/"

AGENT_COUNT=$(ls -1 "$PROJECT_DIR/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $AGENT_COUNT starter agents installed"

# ─────────────────────────────────────────────────────────────
# 8. Update hooks
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[8/10] Updating hooks...${NC}"

mkdir -p "$PROJECT_DIR/hooks"

# Remove old hooks
for hook in auto-format.js session-init.js type-check.js usage-tracker.js validate-board.js; do
    if [ -f "$PROJECT_DIR/hooks/$hook" ]; then
        rm -f "$PROJECT_DIR/hooks/$hook"
    fi
done

cp "$FRAMEWORK_DIR/hooks/"*.js "$PROJECT_DIR/hooks/" 2>/dev/null || true

HOOK_COUNT=$(ls -1 "$PROJECT_DIR/hooks/"*.js 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} $HOOK_COUNT hooks installed"

# Archive CHANGELOG.md
if [ -f "$PROJECT_DIR/CHANGELOG.md" ]; then
    mv "$PROJECT_DIR/CHANGELOG.md" "$BACKUP_DIR/"
    echo -e "  ${GREEN}✓${NC} Archived CHANGELOG.md (replaced by git log hook)"
fi

# ─────────────────────────────────────────────────────────────
# 9. Install AGENTS.md and sprint directory
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[9/10] Installing partnership files...${NC}"

# AGENTS.md (CX entry point)
cp "$FRAMEWORK_DIR/templates/project-init/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
echo -e "  ${GREEN}✓${NC} AGENTS.md (CX entry point — v5.0.0 sprint-based)"

# Sprint directory
mkdir -p "$PROJECT_DIR/sprint"

if [ -f "$PROJECT_DIR/sprint/sprint.json" ]; then
    # Existing sprint.json — check if it's v1 (no branch_strategy field)
    if ! grep -q '"branch_strategy"' "$PROJECT_DIR/sprint/sprint.json" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC} sprint.json exists but is v1 schema — will be upgraded on next /sprint-init"
    else
        echo -e "  ${GREEN}✓${NC} sprint/sprint.json already exists (v2 schema)"
    fi
else
    cp "$FRAMEWORK_DIR/templates/sprint.template.json" "$PROJECT_DIR/sprint/sprint.json"
    echo -e "  ${GREEN}✓${NC} sprint/sprint.json (template — run /sprint-init to populate)"
fi

# ─────────────────────────────────────────────────────────────
# 10. Install worktree scripts
# ─────────────────────────────────────────────────────────────
echo -e "${YELLOW}[10/10] Installing worktree scripts...${NC}"

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
echo -e "${YELLOW}v5.0.0 Changes:${NC}"
echo "  - Sprint-based coordination: sprint/sprint.json replaces .tasks/board.md"
echo "  - Symmetric agents: cc/ and cx/ branch prefixes"
echo "  - Branch strategy per-sprint (main or worktree)"
echo "  - Auto sprint-init from Plan Mode (plan-to-sprint hook)"
echo "  - sprint.md auto-generated (sprint-sync hook)"
echo "  - Agent identity auto-detected (CLAUDE.md → cc, AGENTS.md → cx)"
echo ""
echo -e "${YELLOW}New commands:${NC}"
echo "  /sprint-init      - Initialize sprint from plan (auto-triggered by Plan Mode)"
echo "  /sprint-status    - Sprint state and branch overview (replaces /sync-tasks)"
echo ""
echo -e "${YELLOW}Removed (replaced):${NC}"
echo "  - .tasks/board.md → sprint/sprint.json"
echo "  - /sync-tasks     → /sprint-status"
echo "  - validate-board  → sprint-sync hook"
echo "  - /spec           → /handoff"
echo "  - /codex-review   → /peer-review"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review PROJECT.md — update Agent Coordination section"
echo "  2. Run /sprint-init to create your first sprint"
echo "  3. Use Plan Mode → plan auto-converts to sprint"
echo ""
