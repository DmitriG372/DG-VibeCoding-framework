#!/usr/bin/env bash
set -euo pipefail

TARGET_MODE=""
COMMIT_CHANGES=false
for arg in "$@"; do
  case "$arg" in
    public|private-shared|private-solo) TARGET_MODE="$arg" ;;
    --commit) COMMIT_CHANGES=true ;;
    *) echo "Usage: switch-repo-access.sh <public|private-shared|private-solo> [--commit]" >&2; exit 64 ;;
  esac
done
[[ -n "$TARGET_MODE" ]] || { echo "Missing repo_access mode" >&2; exit 64; }

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MANIFEST="$ROOT/manifest.md"
GITIGNORE="$ROOT/.gitignore"
[[ -f "$MANIFEST" ]] || { echo "manifest.md not found" >&2; exit 1; }
[[ -f "$GITIGNORE" ]] || { echo ".gitignore not found" >&2; exit 1; }

if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if ! git -C "$ROOT" diff --quiet || ! git -C "$ROOT" diff --cached --quiet; then
    echo "switch-repo-access: tracked/staged changes must be clean" >&2
    exit 1
  fi
fi

manifest_tmp="$(mktemp "$ROOT/.manifest-XXXXXX")"
awk -F= -v mode="$TARGET_MODE" '
  BEGIN { done=0 }
  /^repo_access=/ { print "repo_access=" mode; done=1; next }
  { print }
  END { if (!done) print "repo_access=" mode }
' "$MANIFEST" > "$manifest_tmp"

required_ignores=(
  'manifest.md'
  '.claude/settings.local.json'
  '.claude/notebook.json'
  '.claude/SNAPSHOT.md'
  '.claude/context-snapshot.json'
  '.claude/usage.log'
  '.claude/logs/'
)
gitignore_tmp="$(mktemp "$ROOT/.gitignore-XXXXXX")"
cp "$GITIGNORE" "$gitignore_tmp"
for pattern in "${required_ignores[@]}"; do
  grep -Fxq "$pattern" "$gitignore_tmp" || printf '%s\n' "$pattern" >> "$gitignore_tmp"
done

mv "$manifest_tmp" "$MANIFEST"
mv "$gitignore_tmp" "$GITIGNORE"

if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$ROOT" rm -r --cached --ignore-unmatch -- \
    .claude/settings.local.json .claude/notebook.json .claude/SNAPSHOT.md \
    .claude/context-snapshot.json .claude/usage.log .claude/logs manifest.md \
    >/dev/null 2>&1 || true
  git -C "$ROOT" add -- .gitignore
  if [[ "$COMMIT_CHANGES" == true ]] && ! git -C "$ROOT" diff --cached --quiet; then
    git -C "$ROOT" commit -m "chore(repo-access): keep local framework state private"
  fi
fi

echo "switch-repo-access: repo_access set to $TARGET_MODE"
echo "switch-repo-access: AGENTS.md, CLAUDE.md, PROJECT.md, and sprint state remain tracked"
