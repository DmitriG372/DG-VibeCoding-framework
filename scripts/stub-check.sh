#!/usr/bin/env bash
#
# stub-check.sh — detect placeholder code in changed files
#
# Usage:
#   scripts/stub-check.sh [--staged | --last-commit | --files <file>...]
#
# Exit codes:
#   0 — clean
#   1 — stubs found (soft)
#   2 — stubs found AND STUB_CHECK_BLOCK=1 (hook hard block)
#
# Compatible with bash 3.2 (macOS default) — no mapfile, no readarray.

set -u

MODE="${1:---staged}"
shift || true

FILES_RAW=""

case "$MODE" in
  --staged)
    FILES_RAW="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)"
    ;;
  --last-commit)
    FILES_RAW="$(git diff --name-only HEAD~1..HEAD 2>/dev/null || true)"
    ;;
  --files)
    FILES_RAW="$(printf '%s\n' "$@")"
    ;;
  *)
    echo "Usage: $0 [--staged | --last-commit | --files <file>...]" >&2
    exit 64
    ;;
esac

if [ -z "$FILES_RAW" ]; then
  exit 0
fi

# Collect source files into a list (newline-separated)
SRC_LIST=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    *.ts|*.tsx|*.js|*.jsx|*.py|*.vue|*.svelte|*.go|*.rs)
      [ -f "$f" ] && SRC_LIST="${SRC_LIST}${f}"$'\n'
      ;;
  esac
done <<EOF
$FILES_RAW
EOF

if [ -z "$SRC_LIST" ]; then
  exit 0
fi

# Expand SRC_LIST into positional args for grep
OLDIFS="$IFS"
IFS=$'\n'
# shellcheck disable=SC2086
set -- $SRC_LIST
IFS="$OLDIFS"

FOUND=0

# Pattern 1: TODO/FIXME/HACK/XXX markers
if grep -nE '\b(TODO|FIXME|HACK|XXX|PLACEHOLDER)\b' "$@" 2>/dev/null; then
  FOUND=1
fi

# Pattern 2: console.log or print() inside catch/except blocks
if grep -nE '(console\.log|print\()' "$@" 2>/dev/null | grep -Ei '(catch|except)'; then
  FOUND=1
fi

# Pattern 3: placeholder content
if grep -niE '\b(lorem ipsum|asdf|test123|foo bar|baz)\b' "$@" 2>/dev/null; then
  FOUND=1
fi

# Pattern 4: empty function bodies returning null/undefined/pass
if grep -nE '^[[:space:]]*(return null|return undefined|pass)[[:space:]]*$' "$@" 2>/dev/null; then
  FOUND=1
fi

if [ $FOUND -eq 0 ]; then
  exit 0
fi

if [ "${STUB_CHECK_BLOCK:-0}" = "1" ]; then
  exit 2
fi
exit 1
