#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-worktree-test-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
PROJECT="$TMP_ROOT/project"

"$ROOT_DIR/setup-project.sh" "$PROJECT" >/dev/null
cd "$PROJECT"

# v9 does not install a sprint file — it is created only when work is split.
mkdir -p sprint
printf '%s\n' '{
  "schema_version": 4,
  "base_branch": "main",
  "updated": "2026-07-27T10:00:00Z",
  "tasks": [
    { "id": "T1", "title": "Parallel task", "assigned_to": "cx",
      "status": "planned", "branch": "cx/t1-parallel-task" }
  ]
}' > sprint/sprint.json

git init -q
git config user.name 'Framework Test'
git config user.email 'framework-test@example.invalid'
git add .
git add -f sprint/sprint.json
git commit -qm 'test: initial project'

set +e
setup_invalid_output="$(scripts/worktree-setup.sh -bad 2>&1)"
setup_invalid_status=$?
cleanup_invalid_output="$(scripts/worktree-cleanup.sh -bad 2>&1)"
cleanup_invalid_status=$?
set -e
[[ $setup_invalid_status -eq 64 ]] || {
  echo "FAIL: worktree setup did not reject an invalid branch with usage status" >&2
  exit 1
}
[[ $cleanup_invalid_status -eq 64 ]] || {
  echo "FAIL: worktree cleanup did not reject an invalid branch with usage status" >&2
  exit 1
}
printf '%s\n' "$setup_invalid_output" | grep -Fq 'invalid branch name'
printf '%s\n' "$cleanup_invalid_output" | grep -Fq 'invalid branch name'

set_branch() {
  node - "$1" <<'NODE'
const fs = require('node:fs');
const sprint = JSON.parse(fs.readFileSync('sprint/sprint.json', 'utf8'));
sprint.tasks[0].branch = process.argv[2];
fs.writeFileSync('sprint/sprint.json', `${JSON.stringify(sprint, null, 2)}\n`);
NODE
}

set_branch '-bad'
head_before_invalid_handoff="$(git rev-parse HEAD)"
set +e
handoff_invalid_output="$(scripts/handoff-worktree.sh T1 cx 2>&1)"
handoff_invalid_status=$?
set -e
[[ $handoff_invalid_status -eq 64 ]] || {
  echo 'FAIL: handoff did not reject an invalid task branch with usage status' >&2
  exit 1
}
[[ "$(git rev-parse HEAD)" == "$head_before_invalid_handoff" ]] || {
  echo 'FAIL: invalid handoff created a coordination commit' >&2
  exit 1
}
printf '%s\n' "$handoff_invalid_output" | grep -Fq 'invalid branch name'

set_branch 'cx/t1-parallel-task'

printf 'dirty\n' >> PROJECT.md
if scripts/handoff-worktree.sh T1 cx >/dev/null 2>&1; then
  echo 'FAIL: handoff accepted unrelated tracked changes' >&2
  exit 1
fi
git restore PROJECT.md

# Existing branches can omit the coordination commit. Reject before staging or committing.
git branch cx/existing
set_branch 'cx/existing'
head_before_rejection="$(git rev-parse HEAD)"
if scripts/handoff-worktree.sh T1 cx >/dev/null 2>&1; then
  echo 'FAIL: handoff accepted an existing branch with stale assignment' >&2
  exit 1
fi
[[ "$(git rev-parse HEAD)" == "$head_before_rejection" ]]
git diff --cached --quiet

set_branch 'cx/occupied'
mkdir "$TMP_ROOT/project-wt-cx-occupied"
if scripts/handoff-worktree.sh T1 cx >/dev/null 2>&1; then
  echo 'FAIL: handoff accepted an occupied path' >&2
  exit 1
fi
[[ "$(git rev-parse HEAD)" == "$head_before_rejection" ]]
git diff --cached --quiet
set_branch 'cx/t1-parallel-task'

output="$(scripts/handoff-worktree.sh T1 cx)"
worktree="${output##*handoff-worktree: }"
[[ -d "$worktree" ]]
[[ "$(git -C "$worktree" rev-parse HEAD)" == "$(git rev-parse HEAD)" ]]
[[ -f "$worktree/.claude/settings.local.json" ]]
cmp .claude/settings.local.json "$worktree/.claude/settings.local.json"
[[ "$(git -C "$worktree" branch --show-current)" == 'cx/t1-parallel-task' ]]
node - "$worktree" <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const sprint = JSON.parse(fs.readFileSync(path.join(process.argv[2], 'sprint/sprint.json'), 'utf8'));
const task = sprint.tasks.find(item => item.id === 'T1');
if (!task || task.assigned_to !== 'cx') process.exit(1);
NODE
git log -1 --format=%s | grep -Fxq 'chore(sprint): hand off T1 to cx'

echo 'worktree-coordination: ok'
