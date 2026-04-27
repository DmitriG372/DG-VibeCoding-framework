#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local pattern="$1"
  local path="$2"
  grep -Fq -- "$pattern" "$path" || fail "Expected '$pattern' in $path"
}

assert_not_contains() {
  local pattern="$1"
  local path="$2"
  if grep -Fq -- "$pattern" "$path"; then
    fail "Did not expect '$pattern' in $path"
  fi
}

version="$(tr -d '\n' < VERSION)"
readme_title="$(head -n 1 README.md)"
guide_title="$(head -n 1 GUIDE.md)"

[ "$readme_title" = "# DG-VibeCoding-Framework v$version" ] || fail "README version mismatch"
[ "$guide_title" = "# DG-VibeCoding-Framework v$version — Kasutusjuhend" ] || fail "GUIDE version mismatch"

skill_count="$(find .claude/skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
agent_count="$(find .claude/agents -maxdepth 1 -type f -name '*.md' ! -name 'README.md' | wc -l | tr -d ' ')"
command_count="$(find .claude/commands -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
hook_count="$(find hooks -maxdepth 1 -type f -name '*.js' | wc -l | tr -d ' ')"

[ "$skill_count" = "8" ] || fail "Expected 8 skills, found $skill_count"
[ "$agent_count" = "6" ] || fail "Expected 6 agents, found $agent_count"
[ "$command_count" = "12" ] || fail "Expected 12 commands, found $command_count"
[ "$hook_count" = "13" ] || fail "Expected 13 hooks, found $hook_count"

assert_contains '- **8 core skills**' README.md
assert_contains '- **6 starter agents**' README.md
assert_contains '- **13 hooks**' README.md
assert_contains '| Skills    | 8' GUIDE.md
assert_contains '| Agents    | 6' GUIDE.md
assert_contains '| Hooks     | 13' GUIDE.md

assert_not_contains 'Read: agents/' .claude/commands/orchestrate.md
assert_not_contains 'Read: agents/' .claude/commands/review.md
assert_not_contains 'Touch .env files' templates/project-init/AGENTS.md

ROOT_DIR="$ROOT_DIR" VERSION="$version" python3 - <<'PY'
import json
import os
import pathlib
import sys

root = pathlib.Path(os.environ["ROOT_DIR"])
version = os.environ["VERSION"]
framework = json.loads((root / "framework.json").read_text())

if framework["version"] != version:
    print("framework.json version mismatch", file=sys.stderr)
    sys.exit(1)

skills = sorted(path.name for path in (root / ".claude/skills").iterdir() if path.is_dir())
agents = sorted(path.stem for path in (root / ".claude/agents").glob("*.md") if path.name != "README.md")
commands = sorted(path.stem for path in (root / ".claude/commands").glob("*.md"))

if sorted(framework["core"]["skills"]) != skills:
    print("framework.json skills mismatch", framework["core"]["skills"], skills, file=sys.stderr)
    sys.exit(1)

if sorted(framework["core"]["agents"]) != agents:
    print("framework.json agents mismatch", framework["core"]["agents"], agents, file=sys.stderr)
    sys.exit(1)

if sorted(framework["core"]["commands"]) != commands:
    print("framework.json commands mismatch", framework["core"]["commands"], commands, file=sys.stderr)
    sys.exit(1)
PY

# Version-leak guard: VERSION file is the single source of truth.
# Outside the whitelist (VERSION, README.md, GUIDE.md, framework.json), no file
# in active framework directories may contain the current vX.Y.Z string.
#
# Whitelist rationale:
#   - VERSION                    : the source of truth itself
#   - README.md / GUIDE.md       : header line is auto-validated against VERSION above
#   - framework.json             : "version" field is auto-validated against VERSION above
#   - tests/framework-consistency.sh: this guard's own implementation
leak_paths=$(grep -rEl "v${version//./\\.}" \
  core .claude hooks scripts templates 2>/dev/null || true)

if [ -n "$leak_paths" ]; then
  echo "FAIL: hardcoded current version v$version found outside the whitelist:" >&2
  printf '%s\n' "$leak_paths" >&2
  echo "Fix: remove or replace with a VERSION-file-derived reference." >&2
  exit 1
fi

echo "framework-consistency: ok"
