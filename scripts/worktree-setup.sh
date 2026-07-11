#!/bin/bash
# DG-VibeCoding-Framework - Worktree Setup
# Usage: scripts/worktree-setup.sh <branch-name>
# Creates a git worktree for parallel agent work (CC or CX)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BRANCH="${1:?Usage: $0 <branch-name>}"
if ! git check-ref-format --branch "$BRANCH" >/dev/null 2>&1; then
    echo "worktree-setup: invalid branch name: $BRANCH" >&2
    exit 64
fi
ROOT="$(git rev-parse --show-toplevel)"
PROJECT_NAME="$(basename "$ROOT")"
WT_DIR="$(dirname "$ROOT")/${PROJECT_NAME}-wt-${BRANCH//\//-}"
cd "$ROOT"

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

echo -e "${YELLOW}Dependencies were not installed automatically.${NC}"
echo -e "${YELLOW}Run the project's documented bootstrap command inside the worktree if needed.${NC}"

# Do not copy .env files automatically.
# This keeps secret handling explicit and aligned with AGENTS.md rules.
if ls "../${PROJECT_NAME}"/.env* >/dev/null 2>&1; then
    echo -e "${YELLOW}ℹ${NC} Detected .env files in the main worktree."
    echo -e "${YELLOW}ℹ${NC} They were NOT copied to this worktree. Provision secrets manually if needed."
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Worktree Ready!                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "Path:   ${BLUE}${WT_DIR}${NC}"
echo -e "Branch: ${BLUE}${BRANCH}${NC}"
echo ""
echo -e "${YELLOW}For Codex:${NC}"
echo "  cd ${WT_DIR} && codex --sandbox workspace-write"
echo ""
echo -e "${YELLOW}For Claude Code:${NC}"
echo "  cd ${WT_DIR} && claude"
echo ""
