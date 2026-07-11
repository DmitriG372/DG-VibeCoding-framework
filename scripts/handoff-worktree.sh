#!/usr/bin/env bash
set -euo pipefail

FEATURE_ID="${1:-}"
TARGET_AGENT="${2:-}"
if [[ ! "$FEATURE_ID" =~ ^F[0-9]{3,}$ ]] || [[ ! "$TARGET_AGENT" =~ ^(cc|cx)$ ]]; then
  echo "Usage: handoff-worktree.sh <FNNN> <cc|cx>" >&2
  exit 64
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "handoff-worktree: not inside a Git repository" >&2
  exit 1
}
cd "$ROOT"
node scripts/validate-sprint.js sprint/sprint.json --write-stats >/dev/null

BRANCH="$(node - "$FEATURE_ID" "$TARGET_AGENT" <<'NODE'
const fs = require('node:fs');
const [featureId, target] = process.argv.slice(2);
const sprint = JSON.parse(fs.readFileSync('sprint/sprint.json', 'utf8'));
if (sprint.branch_strategy !== 'worktree') throw new Error('branch_strategy must be worktree for parallel handoff');
const feature = sprint.features.find(item => item.id === featureId);
if (!feature) throw new Error(`feature ${featureId} not found`);
if (feature.assigned_to !== target) throw new Error(`feature ${featureId} must be assigned_to ${target}`);
if (!feature.branch) throw new Error(`feature ${featureId} has no branch`);
process.stdout.write(`${feature.branch}\n`);
NODE
)" || exit 1
if ! git check-ref-format --branch "$BRANCH" >/dev/null 2>&1; then
  echo "handoff-worktree: invalid branch name: $BRANCH" >&2
  exit 64
fi

unrelated="$(git status --porcelain --untracked-files=no | awk '$2 != "sprint/sprint.json" { print }')"
if [[ -n "$unrelated" ]]; then
  echo "handoff-worktree: tracked changes outside sprint/sprint.json must be clean" >&2
  echo "$unrelated" >&2
  exit 1
fi

git add -- sprint/sprint.json
if git diff --cached --quiet; then
  echo "handoff-worktree: sprint state has no staged changes" >&2
  exit 1
fi
git commit -m "chore(sprint): hand off $FEATURE_ID to $TARGET_AGENT"

PROJECT_NAME="$(basename "$ROOT")"
WORKTREE="$(dirname "$ROOT")/${PROJECT_NAME}-wt-${BRANCH//\//-}"
if [[ -e "$WORKTREE" ]]; then
  echo "handoff-worktree: target path already exists: $WORKTREE" >&2
  exit 1
fi
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git worktree add "$WORKTREE" "$BRANCH"
else
  git worktree add "$WORKTREE" -b "$BRANCH"
fi

printf 'handoff-worktree: %s\n' "$WORKTREE"
