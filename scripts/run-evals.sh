#!/usr/bin/env bash
# Run the behavioural evals in tests/evals/cases against a real agent.
# Usage: run-evals.sh [--tool claude|codex] [--case <name>] [--keep] [--list]
#
# Each case gets a throwaway project with the framework installed, a git
# history, and the case fixture. The agent runs headless on task.md; check.sh
# then judges the outcome. Exit 1 if any case fails.
#
# The fixture is disposable, so the agent runs with permissions bypassed
# (claude) or in a workspace-write sandbox (codex). Never point this at a real
# project.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASES_DIR="$ROOT_DIR/tests/evals/cases"
TOOL="claude"
ONLY=""
KEEP=false
LIST=false
MAX_TURNS="${EVAL_MAX_TURNS:-30}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CODEX_BIN="${CODEX_BIN:-codex}"

usage() { sed -n '2,/^$/p' "$0" | sed 's/^# \?//'; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool) [[ $# -ge 2 ]] || { echo 'Missing --tool value' >&2; exit 64; }; TOOL="$2"; shift 2 ;;
    --case) [[ $# -ge 2 ]] || { echo 'Missing --case value' >&2; exit 64; }; ONLY="$2"; shift 2 ;;
    --keep) KEEP=true; shift ;;
    --list) LIST=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 64 ;;
  esac
done

[[ "$TOOL" =~ ^(claude|codex)$ ]] || { echo '--tool must be claude or codex' >&2; exit 64; }
[[ -d "$CASES_DIR" ]] || { echo "No cases directory: $CASES_DIR" >&2; exit 1; }

cases=()
for dir in "$CASES_DIR"/*/; do
  name="$(basename "$dir")"
  [[ -z "$ONLY" || "$name" == "$ONLY" ]] && cases+=("$name")
done
[[ ${#cases[@]} -gt 0 ]] || { echo "No matching case: ${ONLY:-<any>}" >&2; exit 1; }

if [[ "$LIST" == true ]]; then
  for name in "${cases[@]}"; do
    printf '%-24s %s\n' "$name" "$(head -n 1 "$CASES_DIR/$name/task.md")"
  done
  exit 0
fi

if [[ "$TOOL" == codex ]]; then
  command -v "$CODEX_BIN" >/dev/null 2>&1 || { echo "Codex executable not found: $CODEX_BIN" >&2; exit 1; }
else
  command -v "$CLAUDE_BIN" >/dev/null 2>&1 || { echo "Claude executable not found: $CLAUDE_BIN" >&2; exit 1; }
fi

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-evals-XXXXXX")"
if [[ "$KEEP" == true ]]; then echo "evals: fixtures kept under $TMP_ROOT" >&2
else trap 'rm -rf "$TMP_ROOT"' EXIT; fi

run_agent() {
  local task="$1" output="$2"
  if [[ "$TOOL" == codex ]]; then
    "$CODEX_BIN" exec --sandbox workspace-write --skip-git-repo-check - < "$task" > "$output" 2>&1 || true
  else
    "$CLAUDE_BIN" -p --dangerously-skip-permissions --max-turns "$MAX_TURNS" < "$task" > "$output" 2>&1 || true
  fi
}

passed=0
failed=0
for name in "${cases[@]}"; do
  case_dir="$CASES_DIR/$name"
  for required in task.md setup.sh check.sh; do
    [[ -f "$case_dir/$required" ]] || { echo "$name: missing $required" >&2; exit 1; }
  done

  fixture="$TMP_ROOT/$name"
  "$ROOT_DIR/setup-project.sh" "$fixture" >/dev/null
  (
    cd "$fixture"
    git init -q
    git config user.name 'Eval Runner'
    git config user.email 'evals@example.invalid'
    git add -A
    git commit -qm 'chore: install framework'
    bash "$case_dir/setup.sh"
  )
  base="$(git -C "$fixture" rev-parse HEAD)"
  output="$TMP_ROOT/$name.output.txt"

  ( cd "$fixture" && run_agent "$case_dir/task.md" "$output" )

  if reason="$(cd "$fixture" && EVAL_FIXTURE="$fixture" EVAL_OUTPUT="$output" EVAL_BASE="$base" bash "$case_dir/check.sh" 2>&1)"; then
    printf 'PASS  %s\n' "$name"; passed=$((passed + 1))
  else
    printf 'FAIL  %s — %s\n' "$name" "${reason:-check.sh exited non-zero}"; failed=$((failed + 1))
  fi
done

echo "evals ($TOOL): $passed passed, $failed failed"
[[ $failed -eq 0 ]]
