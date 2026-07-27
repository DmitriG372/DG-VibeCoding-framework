#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  grep -Fq -- "$1" "$2" || fail "Expected '$1' in $2"
}

version="$(tr -d '\n' < VERSION)"
readme_title="$(head -n 1 README.md)"
guide_title="$(head -n 1 GUIDE.md)"

[ "$readme_title" = "# DG-VibeCoding-Framework v$version" ] || fail "README version mismatch"
[ "$guide_title" = "# DG-VibeCoding-Framework v$version — Kasutusjuhend" ] || fail "GUIDE version mismatch"

agent_count="$(find .claude/agents -maxdepth 1 -type f -name '*.md' ! -name 'README.md' | wc -l | tr -d ' ')"
command_count="$(find .claude/commands -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
hook_count="$(find hooks -maxdepth 1 -type f -name '*.js' | wc -l | tr -d ' ')"

[ "$agent_count" = "2" ]   || fail "Expected 2 agents, found $agent_count"
[ "$command_count" = "4" ] || fail "Expected 4 commands, found $command_count"
[ "$hook_count" = "5" ]    || fail "Expected 5 hooks, found $hook_count"

# v9 ships no skills and no rules: Codex can read neither, so neither may carry
# anything an agent needs.
[ ! -d .claude/skills ] || [ -z "$(ls -A .claude/skills)" ] || fail "v9 must ship no skills"
[ ! -d .claude/rules ]  || [ -z "$(ls -A .claude/rules)" ]  || fail "v9 must ship no rules"

assert_contains '- **4 commands**' README.md
assert_contains '- **2 subagents**' README.md
assert_contains '- **5 hooks**' README.md
assert_contains '| Commands | 4' GUIDE.md
assert_contains '| Agents   | 2' GUIDE.md
assert_contains '| Hooks    | 5' GUIDE.md

assert_contains '"schema_version": 4' templates/sprint.template.json
assert_contains 'core/codex-hooks.template.json' framework.json
assert_contains 'core/AGENTS.md' framework.json

# Legacy-guidance guard. The scan set is listed explicitly and every path is
# asserted to exist first: `2>/dev/null` on the grep would let this whole check
# pass vacuously the moment a file is renamed.
# CHANGELOG.md is deliberately absent: it names what was removed, which is the
# one place these patterns belong.
legacy_scan=(
  .claude/commands .claude/agents templates GUIDE.md README.md
  PROJECT.md core/AGENTS.md core/CLAUDE.md hooks scripts
)
for path in "${legacy_scan[@]}" CHANGELOG.md; do
  [ -e "$path" ] || fail "legacy-guidance guard points at a missing path: $path"
done

if grep -R -n -E 'sprint-v[23]|codex --full-auto|git add \.( |$)' "${legacy_scan[@]}"; then
  fail "Active documentation contains legacy or unsafe workflow guidance"
fi

# Retired v8 contract shapes must not survive in live code or shipped templates.
# hooks/ and scripts/ were outside the old scan set, which is how two hooks kept
# reading the deleted sprint-v3 fields after the v9 release.
retired_shapes='current_feature|branch_strategy|acceptance_criteria|corridor|sprint\.md|EXECUTION_PROTOCOL|\.claude/rules|/sprint-init|/peer-review|test-dir-protection|decomposition-guard'
if grep -R -n -E "$retired_shapes" \
  hooks scripts templates .claude/commands .claude/agents core/AGENTS.md core/CLAUDE.md \
  --exclude-dir=archive 2>&1 | grep -v '^grep:'; then
  fail "Live code or templates still reference a retired v8 contract shape"
fi

# The contract must carry the safety rules itself — nothing else reaches Codex.
for clause in '--no-verify' 'Approval gates' 'Never' 'Evidence' 'production'; do
  assert_contains "$clause" core/AGENTS.md
done

for source in $(ROOT_DIR="$ROOT_DIR" node - <<'NODE'
const fs = require('node:fs');
const framework = JSON.parse(fs.readFileSync(`${process.env.ROOT_DIR}/framework.json`, 'utf8'));
for (const entry of framework.install.entries) process.stdout.write(`${entry.from}\n`);
NODE
); do
  [ -e "$source" ] || fail "Install manifest source missing: $source"
done

ROOT_DIR="$ROOT_DIR" VERSION="$version" python3 - <<'PY'
import json, os, pathlib, sys

root = pathlib.Path(os.environ["ROOT_DIR"])
framework = json.loads((root / "framework.json").read_text())

if framework["version"] != os.environ["VERSION"]:
    sys.exit("framework.json version mismatch")

agents = sorted(p.stem for p in (root / ".claude/agents").glob("*.md") if p.name != "README.md")
commands = sorted(p.stem for p in (root / ".claude/commands").glob("*.md"))

if sorted(framework["core"]["agents"]) != agents:
    sys.exit(f"framework.json agents mismatch: {framework['core']['agents']} vs {agents}")
if sorted(framework["core"]["commands"]) != commands:
    sys.exit(f"framework.json commands mismatch: {framework['core']['commands']} vs {commands}")
if framework["core"]["skills"]:
    sys.exit("framework.json must declare no skills")
PY

# Version-leak guard: VERSION is the single source of truth. Outside the
# whitelist (VERSION, README.md, GUIDE.md, framework.json, this script), no
# active framework file may hardcode the current version. Both the bare and the
# v-prefixed form count, and tests/ is in scope — a hardcoded version in a test
# fails on the next release for the wrong reason.
leak_scan=(core .claude hooks scripts templates tests)
for path in "${leak_scan[@]}"; do
  [ -e "$path" ] || fail "version-leak guard points at a missing path: $path"
done
# grep -l exits 1 when nothing matches, which is the success case here.
leak_paths=$(grep -rEl "v?${version//./\\.}" "${leak_scan[@]}" || true)
leak_paths=$(printf '%s\n' "$leak_paths" | grep -v '^tests/framework-consistency.sh$' || true)
if [ -n "$leak_paths" ]; then
  echo "FAIL: hardcoded current version v$version found outside the whitelist:" >&2
  printf '%s\n' "$leak_paths" >&2
  exit 1
fi

echo "framework-consistency: ok"
