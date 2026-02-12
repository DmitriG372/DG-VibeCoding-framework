#!/bin/bash
# DG-VibeCoding-Framework v4.0.0 - Worktree Cleanup
# Usage: scripts/worktree-cleanup.sh <branch-name>
# Removes a git worktree after merge

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

echo -e "${BLUE}Cleaning up worktree for branch: ${BRANCH}${NC}"
echo ""

# Check for uncommitted changes
if [ -d "$WT_DIR" ]; then
    cd "$WT_DIR"
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo -e "${RED}WARNING: Uncommitted changes in ${WT_DIR}${NC}"
        echo -e "${RED}Commit or stash changes before cleanup.${NC}"
        git status --short
        echo ""
        read -p "Force remove anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi
    cd - > /dev/null
fi

# Remove worktree
git worktree remove "$WT_DIR" --force 2>/dev/null && \
    echo -e "${GREEN}✓${NC} Worktree removed: ${WT_DIR}" || \
    echo -e "${YELLOW}Worktree already removed${NC}"

# Optionally delete branch (only if merged)
if git branch --merged | grep -q "$BRANCH"; then
    git branch -d "$BRANCH" 2>/dev/null && \
        echo -e "${GREEN}✓${NC} Branch deleted: ${BRANCH}" || true
else
    echo -e "${YELLOW}Branch ${BRANCH} not yet merged — keeping it${NC}"
fi

# Prune stale worktree references
git worktree prune 2>/dev/null

echo ""
echo -e "${GREEN}Cleanup complete.${NC}"
echo ""
