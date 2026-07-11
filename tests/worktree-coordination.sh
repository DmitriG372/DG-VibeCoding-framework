#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-worktree-test-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
PROJECT="$TMP_ROOT/project"

"$ROOT_DIR/setup-project.sh" "$PROJECT" >/dev/null
cd "$PROJECT"
git init -q
git config user.name 'Framework Test'
git config user.email 'framework-test@example.invalid'
git add .
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

node - <<'NODE'
const fs = require('node:fs');
const sprint = JSON.parse(fs.readFileSync('sprint/sprint.json', 'utf8'));
sprint.branch_strategy = 'worktree';
sprint.features = [{
  id: 'F001',
  name: 'Parallel feature',
  description: 'Verify handoff state reaches the partner worktree.',
  acceptance_criteria: ['The partner worktree sees its assignment.'],
  steps: [
    { id: 'S1', desc: 'Prepare state', done: false },
    { id: 'S2', desc: 'Commit state', done: false },
    { id: 'S3', desc: 'Create worktree', done: false },
    { id: 'S4', desc: 'Read state', done: false },
    { id: 'S5', desc: 'Verify result', done: false }
  ],
  corridor: { allowed: ['src/**', 'tests/**'], forbidden: ['.env*'] },
  trivial: false,
  complexity: 'medium',
  status: 'pending',
  assigned_to: 'cx',
  branch: 'cx/F001-parallel-feature',
  tested: false,
  notes: '',
  git: { hash: null, message: null, timestamp: null },
  completed_at: null,
  review: { score: null, verdict: null, reviewer: null }
}];
sprint.stats = { total: 1, pending: 1, in_progress: 0, in_review: 0, completed: 0, blocked: 0 };
sprint.last_updated_by = 'cc';
fs.writeFileSync('sprint/sprint.json', `${JSON.stringify(sprint, null, 2)}\n`);
NODE

node - <<'NODE'
const fs = require('node:fs');
const sprint = JSON.parse(fs.readFileSync('sprint/sprint.json', 'utf8'));
sprint.features[0].branch = '-bad';
fs.writeFileSync('sprint/sprint.json', `${JSON.stringify(sprint, null, 2)}\n`);
NODE
head_before_invalid_handoff="$(git rev-parse HEAD)"
set +e
handoff_invalid_output="$(scripts/handoff-worktree.sh F001 cx 2>&1)"
handoff_invalid_status=$?
set -e
[[ $handoff_invalid_status -eq 64 ]] || {
  echo 'FAIL: handoff did not reject an invalid feature branch with usage status' >&2
  exit 1
}
[[ "$(git rev-parse HEAD)" == "$head_before_invalid_handoff" ]] || {
  echo 'FAIL: invalid handoff created a coordination commit' >&2
  exit 1
}
printf '%s\n' "$handoff_invalid_output" | grep -Fq 'invalid branch name'
node - <<'NODE'
const fs = require('node:fs');
const sprint = JSON.parse(fs.readFileSync('sprint/sprint.json', 'utf8'));
sprint.features[0].branch = 'cx/F001-parallel-feature';
fs.writeFileSync('sprint/sprint.json', `${JSON.stringify(sprint, null, 2)}\n`);
NODE

printf 'dirty\n' >> PROJECT.md
if scripts/handoff-worktree.sh F001 cx >/dev/null 2>&1; then
  echo 'FAIL: handoff accepted unrelated tracked changes' >&2
  exit 1
fi
git restore PROJECT.md

output="$(scripts/handoff-worktree.sh F001 cx)"
worktree="${output##*handoff-worktree: }"
[[ -d "$worktree" ]]
[[ "$(git -C "$worktree" branch --show-current)" == 'cx/F001-parallel-feature' ]]
node - "$worktree" <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const root = process.argv[2];
const sprint = JSON.parse(fs.readFileSync(path.join(root, 'sprint/sprint.json'), 'utf8'));
const feature = sprint.features.find(item => item.id === 'F001');
if (!feature || feature.assigned_to !== 'cx') process.exit(1);
NODE
git log -1 --format=%s | grep -Fxq 'chore(sprint): hand off F001 to cx'

echo 'worktree-coordination: ok'
