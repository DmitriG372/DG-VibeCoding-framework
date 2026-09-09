#!/usr/bin/env bash
#
# Migrate a project from framework 4.x–8.x to v9 "Lean".
#
# v9 mostly removes. The retired machinery is deleted by name, so anything a
# project added itself — custom skills, agents, commands, hooks — survives.
#
set -euo pipefail

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
PROJECT_ARG=""

# Unknown arguments are rejected rather than ignored: this script deletes files,
# so a typo such as `--dryrun` must never silently become a real migration.
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) echo "Usage: migrate-to-v9.sh <project-path> [--dry-run]"; exit 0 ;;
    -*) echo "migration: unknown option: $arg" >&2; exit 64 ;;
    *)
      if [[ -n "$PROJECT_ARG" ]]; then
        echo "migration: only one project directory may be provided" >&2
        exit 64
      fi
      PROJECT_ARG="$arg"
      ;;
  esac
done

if [[ -z "$PROJECT_ARG" || ! -d "$PROJECT_ARG" ]]; then
  echo "Usage: migrate-to-v9.sh <project-path> [--dry-run]" >&2
  exit 64
fi
PROJECT_DIR="$(cd "$PROJECT_ARG" && pwd)"

command -v node >/dev/null 2>&1 || { echo "migration: missing tool node" >&2; exit 1; }

# A worktree shares its object store with the main checkout; migrating one would
# land framework files on a feature branch and fight the next merge. Comparing
# the two git dirs is exact — a `.git` *file* also means a submodule, and a
# subdirectory of a worktree has no `.git` entry of its own at all.
if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Both resolved the same way: --absolute-git-dir resolves symlinks while a
  # plain `pwd` does not, and on macOS /var is a symlink to /private/var.
  GIT_DIR="$(cd "$PROJECT_DIR" && cd "$(git rev-parse --git-dir)" && pwd -P)"
  GIT_COMMON_DIR="$(cd "$PROJECT_DIR" && cd "$(git rev-parse --git-common-dir)" && pwd -P)"
  if [[ "$GIT_DIR" != "$GIT_COMMON_DIR" ]]; then
    echo "migration: $PROJECT_DIR is a git worktree; migrate the main checkout instead" >&2
    exit 1
  fi
fi

RETIRED_RULES=(autonomy components context-management delegation execution-integrity
  negative-constraints production-safety)
RETIRED_SKILLS=(debugging finish git housekeeping partnership start testing vibecoding)
RETIRED_COMMANDS=(sprint-init feature fix orchestrate peer-review sprint-status
  context-refresh sync-notebook framework-update)
RETIRED_AGENTS=(orchestrator implementer tester plan-checker)
RETIRED_HOOKS=(decomposition-guard type-check auto-format scope-guard sprint-sync
  plan-to-sprint context-monitor usage-tracker test-dir-protection test-output-filter)
RETIRED_ROOT=(EXECUTION_PROTOCOL.md HOOKS.md)
# The five v9 hooks were wired as `node ./hooks/x.js`, which fails whenever the session cwd is a
# subdirectory. That form is stripped here and re-added root-resolved by the merge below; a
# project's own hooks keep whatever form they use.
FRAMEWORK_HOOKS=(block-env completion-guard pre-compact git-context context-reload)

if [[ $DRY_RUN -eq 1 ]]; then
  echo "migration dry-run: $PROJECT_DIR"
  echo "  back up everything listed below to .dg-framework-backup-* first"
  echo "  DELETE by name: ${#RETIRED_RULES[@]} rules, ${#RETIRED_SKILLS[@]} skills, ${#RETIRED_COMMANDS[@]} commands, ${#RETIRED_AGENTS[@]} agents, ${#RETIRED_HOOKS[@]} hooks"
  echo "  DELETE: ${RETIRED_ROOT[*]}, .tasks/, hooks/lib/hook-input.js, sprint/sprint.md"
  echo "  OVERWRITE: AGENTS.md, CLAUDE.md, REVIEW.md, framework.json, the 4 commands, the 2 agents, the 5 hooks"
  echo "  REWRITE: .claude/settings.local.json and .codex/hooks.json (retired and cwd-relative wirings stripped, v9 merged in)"
  echo "  APPEND:  .gitignore patterns that are missing"
  echo "  ARCHIVE: sprint/sprint.json to sprint/archive/ if it does not satisfy schema v4"
  echo "  KEEP:    PROJECT.md, and every custom skill, agent, command, hook, rule and setting"
  exit 0
fi

BACKUP_DIR="$(mktemp -d "$PROJECT_DIR/.dg-framework-backup-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
for item in .claude .codex hooks scripts templates sprint .tasks AGENTS.md CLAUDE.md REVIEW.md \
  EXECUTION_PROTOCOL.md HOOKS.md framework.json manifest.md .gitignore; do
  [[ -e "$PROJECT_DIR/$item" ]] && cp -R "$PROJECT_DIR/$item" "$BACKUP_DIR/"
done
echo "migration: backup created at $BACKUP_DIR"

# --- remove the retired v8 machinery ------------------------------------------
for name in "${RETIRED_RULES[@]}";    do rm -f  "$PROJECT_DIR/.claude/rules/$name.md"; done
for name in "${RETIRED_SKILLS[@]}";   do rm -rf "$PROJECT_DIR/.claude/skills/$name" "$PROJECT_DIR/.agents/skills/$name"; done
# Codex mirrors commands as .agents/skills/source-command-<name>; drop the mirrors of retired commands.
for name in "${RETIRED_COMMANDS[@]}"; do rm -rf "$PROJECT_DIR/.agents/skills/source-command-$name"; done
for name in "${RETIRED_COMMANDS[@]}"; do rm -f  "$PROJECT_DIR/.claude/commands/$name.md"; done
for name in "${RETIRED_AGENTS[@]}";   do rm -f  "$PROJECT_DIR/.claude/agents/$name.md"; done
for name in "${RETIRED_HOOKS[@]}";    do rm -f  "$PROJECT_DIR/hooks/$name.js"; done
for name in "${RETIRED_ROOT[@]}";     do rm -f  "$PROJECT_DIR/$name"; done
rm -rf "$PROJECT_DIR/.tasks"
rm -f "$PROJECT_DIR/sprint/sprint.md"          # v8 generated overview; nothing regenerates it
rm -f "$PROJECT_DIR/hooks/lib/hook-input.js"   # by name — a project's own hooks/lib survives
rmdir "$PROJECT_DIR/hooks/lib" "$PROJECT_DIR/.claude/rules" "$PROJECT_DIR/.claude/skills" "$PROJECT_DIR/.agents/skills" 2>/dev/null || true

# --- strip the retired wirings out of both settings files ---------------------
for config in "$PROJECT_DIR/.claude/settings.local.json" "$PROJECT_DIR/.codex/hooks.json"; do
  [[ -f "$config" ]] || continue
  FRAMEWORK_HOOKS_LIST="${FRAMEWORK_HOOKS[*]}" node - "$config" "${RETIRED_HOOKS[@]}" <<'NODE'
const fs = require('node:fs');
const [configPath, ...retired] = process.argv.slice(2);
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const frameworkHooks = (process.env.FRAMEWORK_HOOKS_LIST || '').split(' ').filter(Boolean);
const isRetired = command =>
  retired.some(name => (command || '').includes(`${name}.js`)) ||
  frameworkHooks.some(name => (command || '') === `node ./hooks/${name}.js`);

for (const [event, groups] of Object.entries(config.hooks || {})) {
  const kept = groups
    .map(group => ({ ...group, hooks: (group.hooks || []).filter(h => !isRetired(h.command)) }))
    .filter(group => group.hooks.length > 0);
  if (kept.length) config.hooks[event] = kept;
  else delete config.hooks[event];
}
fs.writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`);
NODE
done

# --- install the v9 runtime ---------------------------------------------------
mkdir -p "$PROJECT_DIR/.claude/commands" "$PROJECT_DIR/.claude/agents" \
  "$PROJECT_DIR/.codex" "$PROJECT_DIR/hooks" "$PROJECT_DIR/scripts" "$PROJECT_DIR/templates"

cp -R "$FRAMEWORK_DIR/.claude/commands/." "$PROJECT_DIR/.claude/commands/"
cp -R "$FRAMEWORK_DIR/.claude/agents/."   "$PROJECT_DIR/.claude/agents/"
cp -R "$FRAMEWORK_DIR/hooks/." "$PROJECT_DIR/hooks/"

node "$FRAMEWORK_DIR/scripts/merge-hook-config.js" \
  "$PROJECT_DIR/.claude/settings.local.json" "$FRAMEWORK_DIR/core/settings.template.json"
node "$FRAMEWORK_DIR/scripts/merge-hook-config.js" \
  "$PROJECT_DIR/.codex/hooks.json" "$FRAMEWORK_DIR/core/codex-hooks.template.json"

# The old entry points are the drift this release exists to end. They are in the
# backup; project facts belong in PROJECT.md, not in an agent instruction file.
cp "$FRAMEWORK_DIR/core/AGENTS.md" "$PROJECT_DIR/AGENTS.md"
cp "$FRAMEWORK_DIR/core/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
cp "$FRAMEWORK_DIR/core/REVIEW.md" "$PROJECT_DIR/REVIEW.md"
cp "$FRAMEWORK_DIR/framework.json" "$PROJECT_DIR/framework.json"
[[ -f "$PROJECT_DIR/PROJECT.md" ]] || cp "$FRAMEWORK_DIR/templates/project-init/PROJECT.md" "$PROJECT_DIR/PROJECT.md"

if [[ ! -f "$PROJECT_DIR/.gitignore" ]]; then
  cp "$FRAMEWORK_DIR/templates/.gitignore.template" "$PROJECT_DIR/.gitignore"
else
  while IFS= read -r pattern || [[ -n "$pattern" ]]; do
    [[ -z "$pattern" ]] && continue
    grep -Fxq "$pattern" "$PROJECT_DIR/.gitignore" || printf '%s\n' "$pattern" >> "$PROJECT_DIR/.gitignore"
  done < "$FRAMEWORK_DIR/templates/.gitignore.template"
fi

cp "$FRAMEWORK_DIR/templates/sprint.schema.json" "$PROJECT_DIR/templates/sprint.schema.json"
cp "$FRAMEWORK_DIR/templates/sprint.template.json" "$PROJECT_DIR/templates/sprint.template.json"
cp "$FRAMEWORK_DIR/templates/review-output.schema.json" "$PROJECT_DIR/templates/review-output.schema.json"
[[ -f "$PROJECT_DIR/manifest.md" ]] || cp "$FRAMEWORK_DIR/templates/manifest.md.template" "$PROJECT_DIR/manifest.md"

runtime_scripts=(
  validate-sprint.js verify-install.js stub-check.sh security-scan.sh framework-state-mode.sh
  switch-repo-access.sh worktree-setup.sh worktree-cleanup.sh handoff-worktree.sh
  headless-review.sh parse-codex-jsonl.js normalize-review.js
)
# The hooks and scripts are CommonJS. A project whose package.json says "type": "module" would
# load them as ESM and crash on `require`; a nested package.json pins the type per directory.
cp "$FRAMEWORK_DIR/scripts/package.json" "$PROJECT_DIR/scripts/package.json"
for script in "${runtime_scripts[@]}"; do
  [[ -f "$FRAMEWORK_DIR/scripts/$script" ]] || continue
  cp "$FRAMEWORK_DIR/scripts/$script" "$PROJECT_DIR/scripts/$script"
  chmod +x "$PROJECT_DIR/scripts/$script"
done

# --- sprint: v9 has no schema-compatible upgrade path, so archive rather than convert
SPRINT="$PROJECT_DIR/sprint/sprint.json"
if [[ -f "$SPRINT" ]] && ! node "$FRAMEWORK_DIR/scripts/validate-sprint.js" "$SPRINT" >/dev/null 2>&1; then
  mkdir -p "$PROJECT_DIR/sprint/archive"
  # mktemp, not a bare timestamp: two runs in the same second must not silently
  # overwrite the first archive.
  ARCHIVED="$(mktemp "$PROJECT_DIR/sprint/archive/pre-v9-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
  mv "$SPRINT" "$ARCHIVED"
  echo "migration: pre-v9 sprint state archived at $ARCHIVED"
  echo "migration: sprint/sprint.json is optional in v9 — recreate it only for parallel CC/CX work"
fi

node "$FRAMEWORK_DIR/scripts/verify-install.js" "$PROJECT_DIR"
echo "migration complete; backup: $BACKUP_DIR"
echo "Review $BACKUP_DIR/CLAUDE.md and move any project facts it held into PROJECT.md."
