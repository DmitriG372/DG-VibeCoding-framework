#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-install-test-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

PROJECT="$TMP_ROOT/project"
"$ROOT_DIR/setup-project.sh" "$PROJECT" >/dev/null

required=(
  PROJECT.md
  CLAUDE.md
  AGENTS.md
  EXECUTION_PROTOCOL.md
  HOOKS.md
  framework.json
  .gitignore
  .claude/settings.local.json
  .claude/rules/execution-integrity.md
  .claude/skills/partnership/references/handoff-protocol.md
  .claude/skills/testing/references/patterns.md
  .codex/hooks.json
  hooks/lib/hook-input.js
  scripts/validate-sprint.js
  scripts/verify-install.js
  scripts/stub-check.sh
  scripts/framework-state-mode.sh
  scripts/switch-repo-access.sh
  scripts/handoff-worktree.sh
  templates/sprint.schema.json
  templates/SNAPSHOT.md.template
  sprint/sprint.json
)

for relative in "${required[@]}"; do
  if [[ ! -f "$PROJECT/$relative" ]]; then
    echo "FAIL: generated project missing $relative" >&2
    exit 1
  fi
done

node "$PROJECT/scripts/validate-sprint.js" "$PROJECT/sprint/sprint.json" >/dev/null
node "$PROJECT/scripts/verify-install.js" "$PROJECT" >/dev/null
if grep -R -n '{{[A-Z_][A-Z_]*}}' "$PROJECT/manifest.md" "$PROJECT/.claude/SNAPSHOT.md"; then
  echo 'FAIL: generated local templates still contain placeholders' >&2
  exit 1
fi

printf 'sentinel\n' > "$PROJECT/PROJECT.md"
if "$ROOT_DIR/setup-project.sh" "$PROJECT" >/dev/null 2>&1; then
  echo "FAIL: setup overwrote an initialized project without --force" >&2
  exit 1
fi
grep -Fxq sentinel "$PROJECT/PROJECT.md" || {
  echo "FAIL: failed setup changed the existing project" >&2
  exit 1
}

"$ROOT_DIR/setup-project.sh" --force "$PROJECT" >/dev/null
grep -Fq '# Project Name' "$PROJECT/PROJECT.md"
find "$PROJECT" -maxdepth 1 -type d -name '.dg-framework-backup-*' | grep -q . || {
  echo "FAIL: --force did not create a backup" >&2
  exit 1
}

COLLISION_PROJECT="$TMP_ROOT/collision-project"
FAKE_BIN="$TMP_ROOT/fake-bin"
mkdir -p "$FAKE_BIN"
printf '#!/bin/sh\nprintf "20260711-120000\\n"\n' > "$FAKE_BIN/date"
chmod +x "$FAKE_BIN/date"
"$ROOT_DIR/setup-project.sh" "$COLLISION_PROJECT" >/dev/null
PATH="$FAKE_BIN:$PATH" "$ROOT_DIR/setup-project.sh" --force "$COLLISION_PROJECT" >/dev/null
PATH="$FAKE_BIN:$PATH" "$ROOT_DIR/setup-project.sh" --force "$COLLISION_PROJECT" >/dev/null
backup_count="$(find "$COLLISION_PROJECT" -maxdepth 1 -type d -name '.dg-framework-backup-*' | wc -l | tr -d ' ')"
[[ "$backup_count" == 2 ]] || {
  echo "FAIL: repeated --force setup reused a backup directory" >&2
  exit 1
}

echo "install-artifact: ok"
