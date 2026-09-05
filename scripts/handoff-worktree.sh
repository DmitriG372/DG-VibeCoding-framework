#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:-}"
TARGET_AGENT="${2:-}"
if [[ -z "$TASK_ID" ]] || [[ ! "$TARGET_AGENT" =~ ^(cc|cx)$ ]]; then
  echo "Usage: handoff-worktree.sh <task-id> <cc|cx>" >&2
  exit 64
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "handoff-worktree: not inside a Git repository" >&2
  exit 1
}
cd "$ROOT"
node scripts/validate-sprint.js sprint/sprint.json >/dev/null

BRANCH="$(node - "$TASK_ID" "$TARGET_AGENT" <<'NODE'
const fs = require('node:fs');
const [taskId, target] = process.argv.slice(2);
const sprint = JSON.parse(fs.readFileSync('sprint/sprint.json', 'utf8'));
const task = sprint.tasks.find(item => item.id === taskId);
if (!task) throw new Error(`task ${taskId} not found`);
if (task.assigned_to !== target) throw new Error(`task ${taskId} must be assigned_to ${target}`);
if (!task.branch) throw new Error(`task ${taskId} has no branch`);
process.stdout.write(`${task.branch}\n`);
NODE
)" || exit 1
if ! git check-ref-format --branch "$BRANCH" >/dev/null 2>&1; then
  echo "handoff-worktree: invalid branch name: $BRANCH" >&2
  exit 64
fi

# Preflight before the coordination commit: reusing an old branch loses the new assignment.
PROJECT_NAME="$(basename "$ROOT")"
WORKTREE="$(dirname "$ROOT")/${PROJECT_NAME}-wt-${BRANCH//\//-}"
if [[ -e "$WORKTREE" || -L "$WORKTREE" ]]; then
  echo "handoff-worktree: target path already exists: $WORKTREE" >&2
  exit 1
fi
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  echo "handoff-worktree: branch already exists; choose a new task branch: $BRANCH" >&2
  exit 1
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
git commit -m "chore(sprint): hand off $TASK_ID to $TARGET_AGENT"

git worktree add "$WORKTREE" -b "$BRANCH"

# .claude/settings.local.json is gitignored, so the partner agent would start in a
# worktree with no Claude Code hook wiring while Codex keeps its tracked
# .codex/hooks.json. Seed it. Permissions and hook wiring only, never secrets.
if [[ -f "$ROOT/.claude/settings.local.json" && ! -f "$WORKTREE/.claude/settings.local.json" ]]; then
  mkdir -p "$WORKTREE/.claude"
  cp "$ROOT/.claude/settings.local.json" "$WORKTREE/.claude/settings.local.json"
fi

printf 'handoff-worktree: %s\n' "$WORKTREE"
