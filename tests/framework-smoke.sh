#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT=""

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  local path="$1"
  [ -f "$path" ] || fail "Missing file: $path"
}

assert_contains() {
  local pattern="$1"
  local path="$2"
  grep -Fq "$pattern" "$path" || fail "Expected '$pattern' in $path"
}

check_generated_project() {
  local project_dir="$1"

  assert_file "$project_dir/framework.json"
  assert_file "$project_dir/HOOKS.md"
  assert_file "$project_dir/.claude/settings.local.json"
  assert_file "$project_dir/scripts/headless-review.sh"
  assert_file "$project_dir/.claude/commands/review.md"
  assert_file "$project_dir/.claude/commands/orchestrate.md"

  for hook in \
    block-env.js \
    type-check.js \
    auto-format.js \
    usage-tracker.js \
    git-context.js \
    context-monitor.js \
    pre-compact.js \
    context-reload.js \
    sprint-sync.js \
    plan-to-sprint.js
  do
    assert_file "$project_dir/hooks/$hook"
  done

  assert_contains 'Read: .claude/agents/reviewer.md' "$project_dir/.claude/commands/review.md"
  assert_contains 'Read: .claude/agents/orchestrator.md' "$project_dir/.claude/commands/orchestrate.md"
  assert_contains 'scripts/headless-review.sh' "$project_dir/.claude/commands/peer-review.md"

  bash "$project_dir/scripts/headless-review.sh" --help >/dev/null

  PROJECT_DIR="$project_dir" python3 - <<'PY'
import json
import os
import pathlib
import sys

project = pathlib.Path(os.environ["PROJECT_DIR"])
cfg = json.loads((project / ".claude/settings.local.json").read_text())
commands = []
for section in cfg.get("hooks", {}).values():
    for matcher in section:
        for hook in matcher.get("hooks", []):
            commands.append(hook.get("command", ""))

missing = []
for command in commands:
    if "node ./hooks/" not in command:
        continue
    suffix = command.split("node ./hooks/", 1)[1].split()[0]
    hook_path = project / "hooks" / suffix
    if not hook_path.exists():
        missing.append(str(hook_path))

if missing:
    print("Missing hooks referenced by settings:", *missing, sep="\n", file=sys.stderr)
    sys.exit(1)
PY

  PROJECT_DIR="$project_dir" python3 - <<'PY'
import json
import os
import pathlib

project = pathlib.Path(os.environ["PROJECT_DIR"])
framework = json.loads((project / "framework.json").read_text())
assert framework["version"], "framework.json version missing"
assert framework["paths"]["settings"] == ".claude/settings.local.json"
assert framework["paths"]["headless_review"] == "scripts/headless-review.sh"
PY

  local sprint_json="$project_dir/sprint/sprint.json"
  local sprint_md="$project_dir/sprint/sprint.md"
  printf '{"tool_input":{"file_path":"%s"}}' "$sprint_json" | node "$project_dir/hooks/sprint-sync.js" >/dev/null
  assert_file "$sprint_md"
  assert_contains 'Auto-generated from sprint.json' "$sprint_md"

  local plan_output
  plan_output="$(printf '{"tool_name":"ExitPlanMode"}' | node "$project_dir/hooks/plan-to-sprint.js")"
  printf '%s' "$plan_output" | grep -Fq 'additionalContext' || fail "plan-to-sprint.js did not emit additionalContext"
}

main() {
  TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-vibe-smoke-XXXXXX")"
  trap 'rm -rf "$TMP_ROOT"' EXIT

  local setup_project="$TMP_ROOT/setup-project"
  "$ROOT_DIR/setup-project.sh" "$setup_project" >/dev/null
  check_generated_project "$setup_project"

  local migrate_project="$TMP_ROOT/migrate-project"
  mkdir -p "$migrate_project/.tasks" "$migrate_project/.claude/commands" "$migrate_project/hooks"
  printf '# legacy board\n' >"$migrate_project/.tasks/board.md"
  printf 'legacy\n' >"$migrate_project/.claude/commands/sync-tasks.md"
  printf 'legacy\n' >"$migrate_project/hooks/validate-board.js"

  "$ROOT_DIR/migrate-project.sh" "$migrate_project" >/dev/null
  [ ! -d "$migrate_project/.tasks" ] || fail ".tasks directory still exists after migration"
  check_generated_project "$migrate_project"

  echo "framework-smoke: ok"
}

main "$@"
