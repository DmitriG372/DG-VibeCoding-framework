#!/usr/bin/env bash
# Secure headless code review with Claude Code or Codex.
# Usage: headless-review.sh [--tool claude|codex] [--mode quick|full]
#        [--branch name|--staged|target] [--output path]

set -euo pipefail

TOOL="claude"
MODE="quick"
BRANCH=""
STAGED=false
OUTPUT=""
TARGET=""
BYTE_LIMIT="${REVIEW_BYTE_LIMIT:-1000000}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CODEX_BIN="${CODEX_BIN:-codex}"

usage() {
  sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool) [[ $# -ge 2 ]] || { echo 'Missing --tool value' >&2; exit 64; }; TOOL="$2"; shift 2 ;;
    --mode) [[ $# -ge 2 ]] || { echo 'Missing --mode value' >&2; exit 64; }; MODE="$2"; shift 2 ;;
    --branch) [[ $# -ge 2 ]] || { echo 'Missing --branch value' >&2; exit 64; }; BRANCH="$2"; shift 2 ;;
    --staged) STAGED=true; shift ;;
    --output) [[ $# -ge 2 ]] || { echo 'Missing --output value' >&2; exit 64; }; OUTPUT="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; exit 64 ;;
    *) [[ -z "$TARGET" ]] || { echo 'Only one target is supported' >&2; exit 64; }; TARGET="$1"; shift ;;
  esac
done

[[ "$TOOL" =~ ^(claude|codex)$ ]] || { echo "--tool must be claude or codex" >&2; exit 64; }
[[ "$MODE" =~ ^(quick|full)$ ]] || { echo "--mode must be quick or full" >&2; exit 64; }
[[ "$BYTE_LIMIT" =~ ^[0-9]+$ ]] || { echo 'REVIEW_BYTE_LIMIT must be numeric' >&2; exit 64; }
[[ -z "$BRANCH" || -z "$TARGET" ]] || { echo 'Use either --branch or a path target' >&2; exit 64; }

if [[ "$TOOL" == codex ]]; then
  command -v "$CODEX_BIN" >/dev/null 2>&1 || { echo "Codex executable not found: $CODEX_BIN" >&2; exit 1; }
else
  command -v "$CLAUDE_BIN" >/dev/null 2>&1 || { echo "Claude executable not found: $CLAUDE_BIN" >&2; exit 1; }
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo 'Not inside a Git repository' >&2; exit 1; }
cd "$ROOT"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-review-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
RAW="$TMP_ROOT/raw.txt"
LIMITED="$TMP_ROOT/limited.txt"
PROMPT="$TMP_ROOT/prompt.txt"
MODEL_TEXT="$TMP_ROOT/model.txt"
EVENTS="$TMP_ROOT/events.jsonl"
LAST_MESSAGE="$TMP_ROOT/last-message.txt"
: > "$RAW"

is_secret_path() {
  local lower
  lower="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  [[ "$lower" =~ (^|/)(\.env($|\.)|credentials([^/]*\.)?json$|secrets?(/|$)) ]] ||
    [[ "$lower" =~ \.(pem|key|p12)$ ]]
}

append_tracked_file() {
  local file="$1"
  is_secret_path "$file" && { echo "Refusing secret-like review path: $file" >&2; return 2; }
  case "$file" in
    *.ts|*.tsx|*.js|*.jsx|*.py|*.rs|*.go|*.java|*.md|*.sh|*.yaml|*.yml|*.json|*.toml|*.sql|*.css|*.html|*.svelte|*.vue)
      printf '=== %s ===\n' "$file" >> "$RAW"
      cat -- "$file" >> "$RAW"
      printf '\n' >> "$RAW"
      ;;
  esac
}

reject_secret_paths() {
  local file
  while IFS= read -r -d '' file; do
    if is_secret_path "$file"; then
      echo "Refusing secret-like changed path: $file" >&2
      return 1
    fi
  done
}

if [[ -n "$BRANCH" ]]; then
  BASE_BRANCH="main"
  if [[ -f sprint/sprint.json ]]; then
    BASE_BRANCH="$(node -e "const s=require('./sprint/sprint.json'); process.stdout.write(s.base_branch || 'main')")"
  fi
  git rev-parse --verify "$BRANCH" >/dev/null 2>&1 || { echo "Unknown branch: $BRANCH" >&2; exit 1; }
  reject_secret_paths < <(git diff --name-only -z "$BASE_BRANCH...$BRANCH")
  git diff "$BASE_BRANCH...$BRANCH" > "$RAW"
elif [[ "$STAGED" == true ]]; then
  reject_secret_paths < <(git diff --cached --name-only -z)
  git diff --cached > "$RAW"
elif [[ -n "$TARGET" ]]; then
  if [[ -f "$TARGET" ]]; then
    git ls-files --error-unmatch -- "$TARGET" >/dev/null 2>&1 || { echo "Target must be Git-tracked: $TARGET" >&2; exit 1; }
    append_tracked_file "$TARGET"
  elif [[ -d "$TARGET" ]]; then
    found=false
    while IFS= read -r -d '' file; do
      found=true
      append_tracked_file "$file"
    done < <(git ls-files -z -- "$TARGET")
    [[ "$found" == true ]] || { echo "No tracked reviewable files in: $TARGET" >&2; exit 1; }
  else
    echo "Target not found: $TARGET" >&2
    exit 1
  fi
else
  reject_secret_paths < <(git diff --name-only -z)
  git diff > "$RAW"
  if [[ ! -s "$RAW" ]]; then
    reject_secret_paths < <(git diff --cached --name-only -z)
    git diff --cached > "$RAW"
  fi
fi

[[ -s "$RAW" ]] || { echo 'No review content found' >&2; exit 1; }
TRUNCATED=false
bytes="$(wc -c < "$RAW" | tr -d ' ')"
if (( bytes > BYTE_LIMIT )); then
  dd if="$RAW" of="$LIMITED" bs=1 count="$BYTE_LIMIT" 2>/dev/null
  TRUNCATED=true
else
  cp "$RAW" "$LIMITED"
fi

if [[ "$MODE" == full ]]; then MAX_SCORE=35; else MAX_SCORE=17; fi
if [[ -n "$BRANCH" ]]; then TARGET_LABEL="$BRANCH"
elif [[ -n "$TARGET" ]]; then TARGET_LABEL="$TARGET"
elif [[ "$STAGED" == true ]]; then TARGET_LABEL="staged"
else TARGET_LABEL="uncommitted"
fi
cat > "$PROMPT" <<EOF
You are a strict code reviewer. Review the supplied content.
Mode: $MODE. Maximum score: $MAX_SCORE.
Return only JSON matching the supplied output schema.
Check correctness, security, readability, maintainability, tests, documentation,
dependencies, performance, and operational safety in proportion to the mode.
Target label: $TARGET_LABEL

--- REVIEW CONTENT ---
EOF
cat "$LIMITED" >> "$PROMPT"

if [[ "$TOOL" == codex ]]; then
  "$CODEX_BIN" exec --json --sandbox read-only \
    --output-schema "$ROOT/templates/review-output.schema.json" \
    --output-last-message "$LAST_MESSAGE" - < "$PROMPT" > "$EVENTS"
  if [[ -s "$LAST_MESSAGE" ]]; then cp "$LAST_MESSAGE" "$MODEL_TEXT";
  else node scripts/parse-codex-jsonl.js < "$EVENTS" > "$MODEL_TEXT"; fi
else
  "$CLAUDE_BIN" -p --output-format json --max-turns 1 < "$PROMPT" > "$MODEL_TEXT"
fi

if [[ -z "$OUTPUT" ]]; then OUTPUT="$TMP_ROOT/review.json"; PRINT_STDOUT=true; else PRINT_STDOUT=false; fi
node scripts/normalize-review.js "$MODEL_TEXT" "$OUTPUT" "$TOOL" "$TARGET_LABEL" "$MODE" "$TRUNCATED"
if [[ "$PRINT_STDOUT" == true ]]; then cat "$OUTPUT"; else echo "Review saved to $OUTPUT" >&2; fi
