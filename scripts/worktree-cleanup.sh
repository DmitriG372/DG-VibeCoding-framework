#!/bin/bash
# DG-VibeCoding-Framework - Worktree Cleanup
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
if ! git check-ref-format --branch "$BRANCH" >/dev/null 2>&1; then
    echo "worktree-cleanup: invalid branch name: $BRANCH" >&2
    exit 64
fi
ROOT="$(git rev-parse --show-toplevel)"
PROJECT_NAME="$(basename "$ROOT")"

# Ask git where the branch is actually checked out instead of assuming the layout
# worktree-setup.sh happens to use. A worktree created by hand, or one placed under
# .worktrees/, is otherwise invisible to this script: it reports "already removed"
# and leaves the real worktree in place. Fall back to the conventional path so a
# stale directory whose registration git has already pruned still gets cleaned up.
WT_DIR="$(git worktree list --porcelain | awk -v want="refs/heads/$BRANCH" '
    /^worktree /  { path = substr($0, 10) }
    /^branch /    { if (substr($0, 8) == want) { print path; exit } }
')"
if [ -z "$WT_DIR" ]; then
    WT_DIR="$(dirname "$ROOT")/${PROJECT_NAME}-wt-${BRANCH//\//-}"
fi
cd "$ROOT"

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
if git branch --merged --format='%(refname:short)' | grep -Fxq "$BRANCH"; then
    git branch -d "$BRANCH" 2>/dev/null && \
        echo -e "${GREEN}✓${NC} Branch deleted: ${BRANCH}" || true
else
    echo -e "${YELLOW}Branch ${BRANCH} not yet merged — keeping it${NC}"
    echo -e "${YELLOW}ℹ${NC} A squash-merged branch never looks merged to git. To check content:"
    echo -e "    git diff --stat <base> ${BRANCH}    # empty output means it is fully in <base>"
fi

# Prune stale worktree references
git worktree prune 2>/dev/null

echo ""
echo -e "${GREEN}Cleanup complete.${NC}"
echo ""
