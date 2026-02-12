#!/bin/bash
# DG-VibeCoding-Framework v4.0.0 - Worktree Setup
# Usage: scripts/worktree-setup.sh <branch-name>
# Creates a git worktree for parallel agent work (CC or CX)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

BRANCH="${1:?Usage: $0 <branch-name>}"
PROJECT_NAME=$(basename "$(pwd)")
WT_DIR="../${PROJECT_NAME}-wt-${BRANCH//\//-}"

echo -e "${BLUE}Setting up worktree for branch: ${BRANCH}${NC}"
echo -e "${BLUE}Worktree path: ${WT_DIR}${NC}"
echo ""

# Create worktree
if [ -d "$WT_DIR" ]; then
    echo -e "${YELLOW}Worktree already exists: ${WT_DIR}${NC}"
else
    git worktree add "$WT_DIR" -b "$BRANCH" 2>/dev/null || git worktree add "$WT_DIR" "$BRANCH"
    echo -e "${GREEN}✓${NC} Worktree created"
fi

cd "$WT_DIR"

# Auto-detect package manager and install dependencies
if [ -f pnpm-lock.yaml ]; then
    echo -e "${YELLOW}Installing dependencies (pnpm)...${NC}"
    pnpm install --frozen-lockfile 2>/dev/null || pnpm install
    echo -e "${GREEN}✓${NC} pnpm install complete"
elif [ -f yarn.lock ]; then
    echo -e "${YELLOW}Installing dependencies (yarn)...${NC}"
    yarn install --frozen-lockfile 2>/dev/null || yarn install
    echo -e "${GREEN}✓${NC} yarn install complete"
elif [ -f package-lock.json ]; then
    echo -e "${YELLOW}Installing dependencies (npm)...${NC}"
    npm ci 2>/dev/null || npm install
    echo -e "${GREEN}✓${NC} npm install complete"
elif [ -f requirements.txt ]; then
    echo -e "${YELLOW}Python project detected. Run: pip install -r requirements.txt${NC}"
fi

# Copy .env files from main worktree
for env in "../${PROJECT_NAME}"/.env*; do
    if [ -f "$env" ]; then
        cp "$env" . 2>/dev/null
        echo -e "${GREEN}✓${NC} Copied $(basename "$env")"
    fi
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Worktree Ready!                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "Path:   ${BLUE}${WT_DIR}${NC}"
echo -e "Branch: ${BLUE}${BRANCH}${NC}"
echo ""
echo -e "${YELLOW}For Codex:${NC}"
echo "  cd ${WT_DIR} && codex --full-auto"
echo ""
echo -e "${YELLOW}For Claude Code:${NC}"
echo "  cd ${WT_DIR} && claude"
echo ""
