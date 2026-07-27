#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-migration-test-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
PROJECT="$TMP_ROOT/project"

# A v8-shaped project: framework machinery plus the project's own additions.
mkdir -p "$PROJECT/.claude/skills/custom/references" "$PROJECT/.claude/skills/testing" \
  "$PROJECT/.claude/rules" "$PROJECT/.claude/agents" "$PROJECT/.claude/commands" \
  "$PROJECT/hooks/lib" "$PROJECT/sprint" "$PROJECT/.tasks"

printf '%s\n' '# custom skill'      > "$PROJECT/.claude/skills/custom/SKILL.md"
printf '%s\n' 'custom reference'    > "$PROJECT/.claude/skills/custom/references/info.md"
printf '%s\n' '# framework skill'   > "$PROJECT/.claude/skills/testing/SKILL.md"
printf '%s\n' '# framework rule'    > "$PROJECT/.claude/rules/execution-integrity.md"
printf '%s\n' '# custom agent'      > "$PROJECT/.claude/agents/custom.md"
printf '%s\n' '# framework agent'   > "$PROJECT/.claude/agents/plan-checker.md"
printf '%s\n' '# custom command'    > "$PROJECT/.claude/commands/custom.md"
printf '%s\n' '# framework command' > "$PROJECT/.claude/commands/sprint-init.md"
printf '%s\n' 'module.exports = 1;' > "$PROJECT/hooks/custom-hook.js"
printf '%s\n' 'module.exports = 1;' > "$PROJECT/hooks/lib/my-lib.js"
printf '%s\n' 'module.exports = 1;' > "$PROJECT/hooks/lib/hook-input.js"
printf '%s\n' '# generated overview'  > "$PROJECT/sprint/sprint.md"
printf '%s\n' 'module.exports = 1;' > "$PROJECT/hooks/decomposition-guard.js"
printf '%s\n' 'module.exports = 1;' > "$PROJECT/hooks/type-check.js"
printf '%s\n' '# v4 entry point'    > "$PROJECT/AGENTS.md"
printf '%s\n' '# v7 entry point'    > "$PROJECT/CLAUDE.md"
printf '%s\n' '# project facts'     > "$PROJECT/PROJECT.md"
printf '%s\n' 'legacy protocol'     > "$PROJECT/EXECUTION_PROTOCOL.md"
printf '%s\n' 'legacy hooks doc'    > "$PROJECT/HOOKS.md"
printf '%s\n' 'custom-cache/'       > "$PROJECT/.gitignore"
printf '%s\n' 'legacy board'        > "$PROJECT/.tasks/board.md"

printf '%s\n' '{
  "permissions": { "allow": ["Bash(git status)"] },
  "custom_setting": true,
  "hooks": {
    "PreToolUse": [
      { "matcher": "Custom", "hooks": [{ "type": "command", "command": "node ./hooks/custom-hook.js" }] },
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "node ./hooks/decomposition-guard.js" }] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "node ./hooks/type-check.js" }] }
    ]
  }
}' > "$PROJECT/.claude/settings.local.json"

# A non-conforming pre-v9 sprint file, as found in the wild.
printf '%s\n' '{
  "sprint_id": "S77-supabase-advisor-hardening",
  "current_feature": "S77-001",
  "features": [{ "id": "S77-001", "assigned_to": "CX" }],
  "last_updated_by": "CX"
}' > "$PROJECT/sprint/sprint.json"

before="$(find "$PROJECT" -type f -print0 | sort -z | xargs -0 shasum | shasum | awk '{print $1}')"
"$ROOT_DIR/migrate-to-v9.sh" "$PROJECT" --dry-run >/dev/null
after="$(find "$PROJECT" -type f -print0 | sort -z | xargs -0 shasum | shasum | awk '{print $1}')"
[[ "$before" == "$after" ]] || { echo 'FAIL: dry-run changed project files' >&2; exit 1; }

FAKE_BIN="$TMP_ROOT/fake-bin"
mkdir -p "$FAKE_BIN"
printf '#!/bin/sh\nprintf "20260727-120000\\n"\n' > "$FAKE_BIN/date"
chmod +x "$FAKE_BIN/date"

PATH="$FAKE_BIN:$PATH" "$ROOT_DIR/migrate-to-v9.sh" "$PROJECT" >/dev/null

# The project's own additions survive.
for preserved in \
  .claude/skills/custom/SKILL.md \
  .claude/skills/custom/references/info.md \
  .claude/agents/custom.md \
  .claude/commands/custom.md \
  hooks/custom-hook.js \
  PROJECT.md; do
  [[ -f "$PROJECT/$preserved" ]] || { echo "FAIL: migration removed $preserved" >&2; exit 1; }
done
grep -Fq 'project facts' "$PROJECT/PROJECT.md"
grep -Fxq 'custom-cache/' "$PROJECT/.gitignore"
grep -Fq 'custom_setting' "$PROJECT/.claude/settings.local.json"
grep -Fq 'custom-hook.js' "$PROJECT/.claude/settings.local.json"

# The framework machinery is gone.
for removed in \
  .claude/skills/testing/SKILL.md \
  .claude/rules/execution-integrity.md \
  .claude/agents/plan-checker.md \
  .claude/commands/sprint-init.md \
  .claude/commands/framework-update.md \
  hooks/decomposition-guard.js \
  hooks/type-check.js \
  hooks/lib/hook-input.js \
  EXECUTION_PROTOCOL.md \
  HOOKS.md \
  .tasks; do
  if [[ -e "$PROJECT/$removed" ]]; then
    echo "FAIL: migration kept $removed" >&2
    exit 1
  fi
done

# The retired wirings are stripped, not merely orphaned.
for retired in decomposition-guard type-check; do
  if grep -Fq "$retired" "$PROJECT/.claude/settings.local.json"; then
    echo "FAIL: retired hook $retired still wired" >&2
    exit 1
  fi
done

# The v9 contract is installed and shared.
head -n 1 "$PROJECT/CLAUDE.md" | grep -Fxq '@AGENTS.md' || {
  echo 'FAIL: CLAUDE.md does not import the shared contract' >&2; exit 1
}
grep -Fq '## Done' "$PROJECT/AGENTS.md"
grep -Fq "\"version\": \"$(tr -d '\n' < "$ROOT_DIR/VERSION")\"" "$PROJECT/framework.json"
[[ -f "$PROJECT/.codex/hooks.json" ]]
[[ -f "$PROJECT/.claude/commands/done.md" ]]

# The old entry points are recoverable.
backup_dir="$(find "$PROJECT" -maxdepth 1 -type d -name '.dg-framework-backup-*' | head -n 1)"
grep -Fq 'v7 entry point' "$backup_dir/CLAUDE.md"
grep -Fq 'v4 entry point' "$backup_dir/AGENTS.md"

# The non-conforming sprint is archived, not silently converted or kept.
[[ ! -f "$PROJECT/sprint/sprint.json" ]] || { echo 'FAIL: invalid sprint kept in place' >&2; exit 1; }
find "$PROJECT/sprint/archive" -name 'pre-v9-*' -type f | grep -q . || {
  echo 'FAIL: pre-v9 sprint was not archived' >&2; exit 1
}
if [[ -f "$PROJECT/sprint/sprint.md" ]]; then
  echo 'FAIL: the v8 generated sprint.md survived' >&2
  exit 1
fi

# A project's own hooks/lib must survive; only the framework file goes.
[[ -f "$PROJECT/hooks/lib/my-lib.js" ]] || { echo 'FAIL: custom hooks/lib was destroyed' >&2; exit 1; }

# An unknown flag must never be read as "not a dry run".
if "$ROOT_DIR/migrate-to-v9.sh" "$PROJECT" --dryrun >/dev/null 2>&1; then
  echo 'FAIL: migration accepted an unknown option' >&2
  exit 1
fi

# A real worktree must be refused; its main checkout must not be.
MAIN="$TMP_ROOT/main-checkout"
mkdir -p "$MAIN"
git -C "$MAIN" init -q
git -C "$MAIN" config user.name 'Framework Test'
git -C "$MAIN" config user.email 'framework-test@example.invalid'
printf '# main\n' > "$MAIN/README.md"
git -C "$MAIN" add README.md
git -C "$MAIN" commit -qm 'test: base'
git -C "$MAIN" worktree add -q "$TMP_ROOT/wt-feature" -b feature

if "$ROOT_DIR/migrate-to-v9.sh" "$TMP_ROOT/wt-feature" --dry-run >/dev/null 2>&1; then
  echo 'FAIL: migration ran inside a worktree' >&2
  exit 1
fi
if ! "$ROOT_DIR/migrate-to-v9.sh" "$MAIN" --dry-run >/dev/null 2>&1; then
  echo 'FAIL: migration refused the main checkout' >&2
  exit 1
fi

echo "migration: ok"
