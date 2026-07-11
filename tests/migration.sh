#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-migration-test-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
PROJECT="$TMP_ROOT/project"

mkdir -p "$PROJECT/.claude/skills/custom/references" \
  "$PROJECT/.claude/agents" "$PROJECT/.claude/commands" \
  "$PROJECT/hooks" "$PROJECT/sprint" "$PROJECT/.tasks"
printf '%s\n' '# custom skill' > "$PROJECT/.claude/skills/custom/SKILL.md"
printf '%s\n' 'custom reference' > "$PROJECT/.claude/skills/custom/references/info.md"
printf '%s\n' '# custom agent' > "$PROJECT/.claude/agents/custom.md"
printf '%s\n' '# custom command' > "$PROJECT/.claude/commands/custom.md"
printf '%s\n' '# custom AGENTS rule' > "$PROJECT/AGENTS.md"
printf '%s\n' 'custom-cache/' > "$PROJECT/.gitignore"
printf '%s\n' 'legacy board' > "$PROJECT/.tasks/board.md"
printf '%s\n' 'module.exports = true;' > "$PROJECT/hooks/custom-hook.js"

printf '%s\n' '{
  "permissions": { "allow": ["Bash(git status)"] },
  "custom_setting": true,
  "hooks": {
    "PreToolUse": [
      { "matcher": "Custom", "hooks": [{ "type": "command", "command": "node ./hooks/custom-hook.js" }] }
    ]
  }
}' > "$PROJECT/.claude/settings.local.json"

# Literal JSON fixture intentionally contains the $schema key.
# shellcheck disable=SC2016
printf '%s\n' '{
  "$schema": "sprint-v2",
  "sprint_id": "S01",
  "created": "2026-01-01T00:00:00Z",
  "branch_strategy": "main",
  "base_branch": "main",
  "current_feature": "F001",
  "features": [{
    "id": "F001",
    "name": "Legacy feature",
    "description": "Preserve and migrate this feature.",
    "acceptance_criteria": ["Legacy behavior remains represented."],
    "complexity": "medium",
    "status": "in_progress",
    "assigned_to": "cc",
    "branch": "cc/F001-legacy",
    "tested": false,
    "git": { "hash": null, "message": null, "timestamp": null },
    "completed_at": null,
    "review": { "score": null, "verdict": null, "reviewer": null }
  }],
  "stats": { "total": 1, "pending": 0, "in_progress": 1, "in_review": 0, "completed": 0 },
  "last_updated": "2026-01-01T00:00:00Z",
  "last_updated_by": "cc"
}' > "$PROJECT/sprint/sprint.json"

before="$(find "$PROJECT" -type f -print0 | sort -z | xargs -0 shasum | shasum | awk '{print $1}')"
"$ROOT_DIR/migrate-v7-to-v8.sh" "$PROJECT" --dry-run >/dev/null
after="$(find "$PROJECT" -type f -print0 | sort -z | xargs -0 shasum | shasum | awk '{print $1}')"
[[ "$before" == "$after" ]] || { echo 'FAIL: dry-run changed project files' >&2; exit 1; }

FAKE_BIN="$TMP_ROOT/fake-bin"
mkdir -p "$FAKE_BIN"
printf '#!/bin/sh\nprintf "20260711-120000\\n"\n' > "$FAKE_BIN/date"
chmod +x "$FAKE_BIN/date"

PATH="$FAKE_BIN:$PATH" "$ROOT_DIR/migrate-v7-to-v8.sh" "$PROJECT" >/dev/null

for preserved in \
  .claude/skills/custom/SKILL.md \
  .claude/skills/custom/references/info.md \
  .claude/agents/custom.md \
  .claude/commands/custom.md \
  hooks/custom-hook.js; do
  [[ -f "$PROJECT/$preserved" ]] || { echo "FAIL: migration removed $preserved" >&2; exit 1; }
done
grep -Fq 'custom AGENTS rule' "$PROJECT/AGENTS.md"
grep -Fxq 'custom-cache/' "$PROJECT/.gitignore"
grep -Fxq '.dg-framework-backup-*/' "$PROJECT/.gitignore"
grep -Fq 'custom_setting' "$PROJECT/.claude/settings.local.json"
grep -Fq 'custom-hook.js' "$PROJECT/.claude/settings.local.json"
[[ -f "$PROJECT/hooks/lib/hook-input.js" ]]
[[ -f "$PROJECT/.codex/hooks.json" ]]
[[ ! -d "$PROJECT/.tasks" ]]
node "$PROJECT/scripts/validate-sprint.js" "$PROJECT/sprint/sprint.json" >/dev/null

backup="$PROJECT/sprint/sprint.json.v7.bak"
[[ -f "$backup" ]]
backup_hash="$(shasum "$backup" | awk '{print $1}')"
PATH="$FAKE_BIN:$PATH" "$ROOT_DIR/migrate-v7-to-v8.sh" "$PROJECT" >/dev/null
[[ "$backup_hash" == "$(shasum "$backup" | awk '{print $1}')" ]] || {
  echo 'FAIL: second migration overwrote original v7 backup' >&2
  exit 1
}
backup_count="$(find "$PROJECT" -maxdepth 1 -type d -name '.dg-framework-backup-*' | wc -l | tr -d ' ')"
[[ "$backup_count" == 2 ]] || {
  echo 'FAIL: repeated migration reused a backup directory' >&2
  exit 1
}

echo "migration: ok"
