#!/usr/bin/env bash
set -euo pipefail

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-}"
DRY_RUN=0
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=1

if [[ -z "$PROJECT_DIR" || ! -d "$PROJECT_DIR" ]]; then
  echo "Usage: migrate-v7-to-v8.sh <project-path> [--dry-run]" >&2
  exit 64
fi
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

for tool in node cp; do
  command -v "$tool" >/dev/null 2>&1 || { echo "migration: missing tool $tool" >&2; exit 1; }
done

if [[ $DRY_RUN -eq 1 ]]; then
  echo "migration dry-run: would merge v8 runtime into $PROJECT_DIR"
  echo "migration dry-run: would preserve custom skills, agents, commands, hooks, settings, and root guidance"
  exit 0
fi

BACKUP_DIR="$(mktemp -d "$PROJECT_DIR/.dg-framework-backup-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
for item in .claude .codex hooks scripts templates sprint .tasks AGENTS.md CLAUDE.md \
  EXECUTION_PROTOCOL.md HOOKS.md framework.json manifest.md .gitignore; do
  [[ -e "$PROJECT_DIR/$item" ]] && cp -R "$PROJECT_DIR/$item" "$BACKUP_DIR/"
done

mkdir -p "$PROJECT_DIR/.claude" "$PROJECT_DIR/.codex" "$PROJECT_DIR/hooks" \
  "$PROJECT_DIR/scripts" "$PROJECT_DIR/templates" "$PROJECT_DIR/sprint"

for dir in skills commands agents rules; do
  mkdir -p "$PROJECT_DIR/.claude/$dir"
  cp -R "$FRAMEWORK_DIR/.claude/$dir/." "$PROJECT_DIR/.claude/$dir/"
done
cp -R "$FRAMEWORK_DIR/hooks/." "$PROJECT_DIR/hooks/"

node "$FRAMEWORK_DIR/scripts/merge-hook-config.js" \
  "$PROJECT_DIR/.claude/settings.local.json" "$FRAMEWORK_DIR/core/settings.template.json"
node "$FRAMEWORK_DIR/scripts/merge-hook-config.js" \
  "$PROJECT_DIR/.codex/hooks.json" "$FRAMEWORK_DIR/core/codex-hooks.template.json"

cp "$FRAMEWORK_DIR/framework.json" "$PROJECT_DIR/framework.json"
cp "$FRAMEWORK_DIR/core/EXECUTION_PROTOCOL.md" "$PROJECT_DIR/EXECUTION_PROTOCOL.md"
cp "$FRAMEWORK_DIR/core/HOOKS.md" "$PROJECT_DIR/HOOKS.md"
[[ -f "$PROJECT_DIR/CLAUDE.md" ]] || cp "$FRAMEWORK_DIR/core/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
[[ -f "$PROJECT_DIR/AGENTS.md" ]] || cp "$FRAMEWORK_DIR/core/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
[[ -f "$PROJECT_DIR/PROJECT.md" ]] || cp "$FRAMEWORK_DIR/templates/project-init/PROJECT.md" "$PROJECT_DIR/PROJECT.md"
[[ -f "$PROJECT_DIR/manifest.md" ]] || cp "$FRAMEWORK_DIR/templates/manifest.md.template" "$PROJECT_DIR/manifest.md"
if [[ ! -f "$PROJECT_DIR/.gitignore" ]]; then
  cp "$FRAMEWORK_DIR/templates/.gitignore.template" "$PROJECT_DIR/.gitignore"
else
  while IFS= read -r pattern || [[ -n "$pattern" ]]; do
    [[ -z "$pattern" ]] && continue
    grep -Fxq "$pattern" "$PROJECT_DIR/.gitignore" || printf '%s\n' "$pattern" >> "$PROJECT_DIR/.gitignore"
  done < "$FRAMEWORK_DIR/templates/.gitignore.template"
fi
[[ -f "$PROJECT_DIR/.claude/SNAPSHOT.md" ]] || cp "$FRAMEWORK_DIR/templates/SNAPSHOT.md.template" "$PROJECT_DIR/.claude/SNAPSHOT.md"
node "$FRAMEWORK_DIR/scripts/render-project-templates.js" "$PROJECT_DIR"

cp "$FRAMEWORK_DIR/templates/sprint.schema.json" "$PROJECT_DIR/templates/sprint.schema.json"
cp "$FRAMEWORK_DIR/templates/SNAPSHOT.md.template" "$PROJECT_DIR/templates/SNAPSHOT.md.template"
cp "$FRAMEWORK_DIR/templates/review-output.schema.json" "$PROJECT_DIR/templates/review-output.schema.json"

runtime_scripts=(
  validate-sprint.js verify-install.js stub-check.sh framework-state-mode.sh
  switch-repo-access.sh worktree-setup.sh worktree-cleanup.sh handoff-worktree.sh
  headless-review.sh parse-codex-jsonl.js normalize-review.js
)
for script in "${runtime_scripts[@]}"; do
  [[ -f "$FRAMEWORK_DIR/scripts/$script" ]] || continue
  cp "$FRAMEWORK_DIR/scripts/$script" "$PROJECT_DIR/scripts/$script"
  chmod +x "$PROJECT_DIR/scripts/$script"
done

SPRINT="$PROJECT_DIR/sprint/sprint.json"
if [[ -f "$SPRINT" ]]; then
  [[ -f "$SPRINT.v7.bak" ]] || cp "$SPRINT" "$SPRINT.v7.bak"
  TEMP_SPRINT="$(mktemp "$PROJECT_DIR/sprint/.sprint-v3-XXXXXX")"
  if node "$FRAMEWORK_DIR/scripts/migrate-sprint-v3.js" "$SPRINT" "$TEMP_SPRINT" &&
     node "$FRAMEWORK_DIR/scripts/validate-sprint.js" "$TEMP_SPRINT" >/dev/null; then
    mv "$TEMP_SPRINT" "$SPRINT"
  else
    rm -f "$TEMP_SPRINT"
    echo "migration: sprint conversion failed; original kept at $SPRINT" >&2
    exit 1
  fi
else
  cp "$FRAMEWORK_DIR/templates/sprint.template.json" "$SPRINT"
fi

rm -rf "$PROJECT_DIR/.tasks"
node "$FRAMEWORK_DIR/scripts/verify-install.js" "$PROJECT_DIR"
echo "migration complete; backup: $BACKUP_DIR"
