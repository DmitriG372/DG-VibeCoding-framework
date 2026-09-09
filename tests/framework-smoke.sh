#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT=""

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "Missing file: $1"
}

assert_contains() {
  grep -Fq "$1" "$2" || fail "Expected '$1' in $2"
}

check_generated_project() {
  local project_dir="$1"

  assert_file "$project_dir/framework.json"
  assert_file "$project_dir/AGENTS.md"
  assert_file "$project_dir/CLAUDE.md"
  assert_file "$project_dir/REVIEW.md"
  assert_file "$project_dir/.claude/settings.local.json"
  assert_file "$project_dir/.codex/hooks.json"
  assert_file "$project_dir/scripts/headless-review.sh"

  for command in 'done' 'review' 'handoff' 'sprint'; do
    assert_file "$project_dir/.claude/commands/$command.md"
  done

  for hook in block-env.js completion-guard.js git-context.js pre-compact.js context-reload.js; do
    assert_file "$project_dir/hooks/$hook"
  done

  # The shared contract must actually be shared, and must carry the workflows.
  head -n 1 "$project_dir/CLAUDE.md" | grep -Fxq '@AGENTS.md' \
    || fail "CLAUDE.md does not import AGENTS.md in $project_dir"
  for section in '## Done' '## Review' '## Handoff' '## Sprint' '## Approval gates'; do
    assert_contains "$section" "$project_dir/AGENTS.md"
  done

  bash "$project_dir/scripts/headless-review.sh" --help >/dev/null

  # block-env is the one blocking guardrail; prove it blocks and does not
  # block ordinary source files.
  if printf '{"tool_input":{"file_path":".env"}}' | node "$project_dir/hooks/block-env.js" >/dev/null 2>&1; then
    fail "block-env did not block .env"
  fi
  if ! printf '{"tool_input":{"file_path":"src/auth/password-reset.ts"}}' \
    | node "$project_dir/hooks/block-env.js" >/dev/null 2>&1; then
    fail "block-env blocked an ordinary source file"
  fi

  PROJECT_DIR="$project_dir" python3 - <<'PY'
import json, os, pathlib, sys

project = pathlib.Path(os.environ["PROJECT_DIR"])
framework = json.loads((project / "framework.json").read_text())
assert framework["version"], "framework.json version missing"
assert framework["paths"]["settings_claude"] == ".claude/settings.local.json"
assert framework["paths"]["settings_codex"] == ".codex/hooks.json"
assert framework["paths"]["headless_review"] == "scripts/headless-review.sh"
assert framework["core"]["skills"] == [], "the framework ships no skills"

def wired(relative):
    config = json.loads((project / relative).read_text())
    return sorted(
        hook.get("command", "")
        for groups in config.get("hooks", {}).values()
        for group in groups
        for hook in group.get("hooks", [])
    )

claude, codex = wired(".claude/settings.local.json"), wired(".codex/hooks.json")
if claude != codex:
    sys.exit(f"installed hook sets differ:\n  claude={claude}\n  codex={codex}")

import re
for command in claude:
    match = re.search(r'hooks/([\w.-]+\.js)', command)
    if match and not (project / "hooks" / match.group(1)).exists():
        sys.exit(f"settings reference missing hook: {match.group(1)}")

# Hand the wired commands to the shell loop below.
(project / ".smoke-hook-commands").write_text("\n".join(claude) + "\n")
PY

  # Both runtimes run hooks in the session cwd, which is often a subdirectory
  # (`apps/web`, a package, a worktree). Every wired command must still find its
  # script from there; `node ./hooks/x.js` did not.
  if [ ! -d "$project_dir/.git" ]; then
    git -C "$project_dir" init -q
  fi
  mkdir -p "$project_dir/sub/dir"
  local stderr_file="$TMP_ROOT/hook-stderr"
  while IFS= read -r command; do
    [ -n "$command" ] || continue
    if ! (cd "$project_dir/sub/dir" \
        && printf '{"tool_name":"Read","tool_input":{"file_path":"src/index.ts"},"session_id":"smoke","trigger":"compact"}' \
        | sh -c "$command" >/dev/null 2>"$stderr_file"); then
      fail "hook failed from a subdirectory: $command — $(cat "$stderr_file")"
    fi
    if grep -q 'Cannot find module' "$stderr_file"; then
      fail "hook did not resolve from the project root: $command"
    fi
  done <"$project_dir/.smoke-hook-commands"
  rm -f "$project_dir/.smoke-hook-commands"

  # A generated project must not presume a sprint, must not carry rules (Codex
  # cannot read them), and must not carry skills (project-owned, never shipped).
  for absent in sprint/sprint.json .claude/rules .claude/skills .agents/skills EXECUTION_PROTOCOL.md HOOKS.md; do
    if [ -e "$project_dir/$absent" ]; then
      fail "generated project must not contain $absent"
    fi
  done
}

main() {
  TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-vibe-smoke-XXXXXX")"
  trap 'rm -rf "$TMP_ROOT"' EXIT

  local setup_project="$TMP_ROOT/setup-project"
  "$ROOT_DIR/setup-project.sh" "$setup_project" >/dev/null
  check_generated_project "$setup_project"

  # A legacy .tasks-era project migrates through the same path.
  local migrate_project="$TMP_ROOT/migrate-project"
  mkdir -p "$migrate_project/.tasks" "$migrate_project/.claude/commands" "$migrate_project/hooks"
  printf '# legacy board\n' >"$migrate_project/.tasks/board.md"
  printf 'legacy\n'         >"$migrate_project/.claude/commands/sync-tasks.md"
  printf 'legacy\n'         >"$migrate_project/hooks/validate-board.js"

  "$ROOT_DIR/migrate-project.sh" "$migrate_project" >/dev/null
  [ ! -d "$migrate_project/.tasks" ] || fail ".tasks directory still exists after migration"
  assert_file "$migrate_project/.claude/commands/sync-tasks.md"
  assert_file "$migrate_project/hooks/validate-board.js"
  check_generated_project "$migrate_project"

  echo "framework-smoke: ok"
}

main "$@"
