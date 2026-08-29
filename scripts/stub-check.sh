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
DIFF_ARGS=""

case "$MODE" in
  --staged)
    FILES_RAW="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)"
    DIFF_ARGS="--cached"
    ;;
  --last-commit)
    FILES_RAW="$(git diff --name-only HEAD~1..HEAD 2>/dev/null || true)"
    DIFF_ARGS="HEAD~1..HEAD"
    ;;
  --files)
    FILES_RAW="$(printf '%s\n' "$@")"
    DIFF_ARGS=""   # explicit file list: scan whole files, the caller asked for it
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

# Expand SRC_LIST into positional args
OLDIFS="$IFS"
IFS=$'\n'
# shellcheck disable=SC2086
set -- $SRC_LIST
IFS="$OLDIFS"

# Build the text to scan as "file:line:content".
#
# In --staged and --last-commit mode scan only the lines this change ADDS. Reading
# whole files means every pre-existing `return null` anywhere in a file you touched
# is reported as your stub — which made the guard unusable on merge commits, where
# every merged file counts as changed and nothing in them was written today.
# --files keeps whole-file scanning: the caller named those files on purpose.
SCAN_INPUT="$(
  if [ -n "$DIFF_ARGS" ]; then
    # shellcheck disable=SC2086
    git diff $DIFF_ARGS -U0 -- "$@" 2>/dev/null | awk '
      /^\+\+\+ b\// { file = substr($0, 7); next }
      /^@@ / {
        # @@ -old,n +new,m @@  -> next added line is at new
        match($0, /\+[0-9]+/)
        line = substr($0, RSTART + 1, RLENGTH - 1) + 0
        next
      }
      /^\+/ { print file ":" line ":" substr($0, 2); line++ }
    '
  else
    for f in "$@"; do grep -n '' "$f" 2>/dev/null | sed "s|^|$f:|"; done
  fi
)"

if [ -z "$SCAN_INPUT" ]; then
  exit 0
fi

FOUND=0

scan() {
  # $1 = grep flags, $2 = pattern; matches against the content after "file:line:"
  if printf '%s\n' "$SCAN_INPUT" | grep $1 -E "$2" 2>/dev/null; then
    FOUND=1
  fi
}

# Pattern 1: TODO/FIXME/HACK/XXX markers
scan "" '^[^:]*:[0-9]+:.*\b(TODO|FIXME|HACK|XXX|PLACEHOLDER)\b'

# Pattern 2: console.log or print() inside catch/except blocks
if printf '%s\n' "$SCAN_INPUT" | grep -E '(console\.log|print\()' 2>/dev/null | grep -Ei '(catch|except)'; then
  FOUND=1
fi

# Pattern 3: placeholder content
scan "-i" '^[^:]*:[0-9]+:.*\b(lorem ipsum|asdf|test123|foo bar|baz)\b'

# Pattern 4: empty function bodies returning null/undefined/pass
scan "" '^[^:]*:[0-9]+:[[:space:]]*(return null|return undefined|pass)[[:space:]]*$'

if [ $FOUND -eq 0 ]; then
  exit 0
fi

if [ "${STUB_CHECK_BLOCK:-0}" = "1" ]; then
  exit 2
fi
exit 1
