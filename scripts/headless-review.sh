#!/bin/bash
# DG-VibeCoding-Framework v4.0.0 — Headless Review Script
# Invokes claude -p or codex exec for automated code review.
#
# Usage: ./scripts/headless-review.sh [OPTIONS] [target]
#
# Options:
#   --tool claude|codex   Review tool (default: claude)
#   --mode quick|full     Review depth (default: quick)
#   --branch <name>       Review branch diff vs main
#   --staged              Review staged changes only
#   --output <path>       Save report to file (default: stdout)
#
# Examples:
#   ./scripts/headless-review.sh --branch feat/auth
#   ./scripts/headless-review.sh --tool codex --staged
#   ./scripts/headless-review.sh --mode full src/services/

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────
TOOL="claude"
MODE="quick"
BRANCH=""
STAGED=false
OUTPUT=""
TARGET=""
DIFF_LIMIT=10000

# ── Parse arguments ───────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)   TOOL="$2"; shift 2 ;;
    --mode)   MODE="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --staged) STAGED=true; shift ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --help|-h)
      sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    -*)
      echo "Error: Unknown option $1" >&2
      exit 1
      ;;
    *)
      TARGET="$1"; shift ;;
  esac
done

# ── Validate tool ─────────────────────────────────────────
resolve_tool() {
  if [[ "$TOOL" == "claude" ]]; then
    if command -v claude &>/dev/null; then return 0; fi
    echo "Warning: claude not found, trying codex fallback..." >&2
    if command -v codex &>/dev/null && [[ -n "${OPENAI_API_KEY:-}" ]]; then
      TOOL="codex"; return 0
    fi
    echo "Error: Neither claude nor codex available" >&2; exit 1
  elif [[ "$TOOL" == "codex" ]]; then
    if command -v codex &>/dev/null && [[ -n "${OPENAI_API_KEY:-}" ]]; then return 0; fi
    echo "Warning: codex not available, trying claude fallback..." >&2
    if command -v claude &>/dev/null; then
      TOOL="claude"; return 0
    fi
    echo "Error: Neither codex nor claude available" >&2; exit 1
  else
    echo "Error: --tool must be 'claude' or 'codex'" >&2; exit 1
  fi
}
resolve_tool

# ── Gather diff / code ────────────────────────────────────
DIFF_CONTENT=""
DIFF_TRUNCATED=false

gather_diff() {
  local raw_diff=""

  if [[ -n "$BRANCH" ]]; then
    raw_diff=$(git diff "main...$BRANCH" 2>/dev/null || git diff "main..$BRANCH" 2>/dev/null || echo "")
    if [[ -z "$raw_diff" ]]; then
      echo "Error: Cannot compute diff for branch '$BRANCH'" >&2
      exit 1
    fi
  elif [[ "$STAGED" == true ]]; then
    raw_diff=$(git diff --cached)
  elif [[ -n "$TARGET" ]]; then
    # Target is file or directory — read contents
    if [[ -d "$TARGET" ]]; then
      raw_diff=$(find "$TARGET" -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.py' -o -name '*.rs' -o -name '*.go' -o -name '*.java' -o -name '*.md' -o -name '*.sh' -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.toml' -o -name '*.sql' -o -name '*.css' -o -name '*.html' -o -name '*.svelte' -o -name '*.vue' \) -exec sh -c 'echo "=== {} ==="; cat "{}"' \;)
    elif [[ -f "$TARGET" ]]; then
      raw_diff=$(cat "$TARGET")
    else
      echo "Error: Target '$TARGET' not found" >&2
      exit 1
    fi
  else
    # Default: uncommitted changes
    raw_diff=$(git diff)
    if [[ -z "$raw_diff" ]]; then
      raw_diff=$(git diff --cached)
    fi
    if [[ -z "$raw_diff" ]]; then
      echo "Error: No uncommitted or staged changes found" >&2
      exit 1
    fi
  fi

  # Truncate if too large
  local line_count
  line_count=$(echo "$raw_diff" | wc -l | tr -d ' ')
  if [[ "$line_count" -gt "$DIFF_LIMIT" ]]; then
    DIFF_TRUNCATED=true
    local stat_summary=""
    if [[ -n "$BRANCH" ]]; then
      stat_summary=$(git diff "main...$BRANCH" --stat 2>/dev/null || echo "")
    elif [[ "$STAGED" == true ]]; then
      stat_summary=$(git diff --cached --stat)
    else
      stat_summary=$(git diff --stat)
    fi
    DIFF_CONTENT="NOTE: Diff truncated from $line_count to $DIFF_LIMIT lines.

--- STAT SUMMARY ---
$stat_summary

--- TRUNCATED DIFF (first $DIFF_LIMIT lines) ---
$(echo "$raw_diff" | head -n "$DIFF_LIMIT")"
  else
    DIFF_CONTENT="$raw_diff"
  fi
}
gather_diff

# ── Build checklist ───────────────────────────────────────
QUICK_CHECKLIST='Code Quality (5): readability, function length <50 lines, nesting <4 levels, naming conventions, DRY compliance.
Security (5): no hardcoded secrets, input validation, no injection vulnerabilities, auth/authz checks, data sanitization.
Performance (4): algorithm complexity, memory management, async patterns, database queries.
Patterns (3): project consistency, architecture compliance, no anti-patterns.'

FULL_CHECKLIST="$QUICK_CHECKLIST
Documentation (5): README, API docs, inline comments, types, changelog.
Test Coverage (5): unit tests, integration tests, edge cases, error paths, >=70% coverage.
Dependencies (4): vulnerabilities, outdated, unused, license compliance.
Tech Debt (4): TODOs resolved, no deprecated APIs, reasonable complexity, no duplication."

if [[ "$MODE" == "full" ]]; then
  CHECKLIST="$FULL_CHECKLIST"
  MAX_SCORE=35
else
  CHECKLIST="$QUICK_CHECKLIST"
  MAX_SCORE=17
fi

# ── Determine target label ────────────────────────────────
TARGET_LABEL="${BRANCH:-${TARGET:-uncommitted}}"

# ── Build prompt ──────────────────────────────────────────
PROMPT="You are a strict code reviewer. Review the following code/diff.

## Review Checklist ($MODE mode, max $MAX_SCORE points)
$CHECKLIST

## Scoring
Award points per item (1 = pass, 0 = fail).
$(if [[ "$MODE" == "full" ]]; then
echo "Verdicts: score 28-35 = PASS, score 20-27 = NEEDS_ATTENTION, score 0-19 = FAIL."
else
echo "Verdicts: score 15-17 = PASS, score 10-14 = NEEDS_CHANGES, score 0-9 = FAIL."
fi)

## IMPORTANT: Output ONLY valid JSON
Respond with ONLY a JSON object (no markdown fences, no extra text):
{
  \"target\": \"$TARGET_LABEL\",
  \"mode\": \"$MODE\",
  \"score\": <number>,
  \"max_score\": $MAX_SCORE,
  \"verdict\": \"$(if [[ "$MODE" == "full" ]]; then echo "PASS|NEEDS_ATTENTION|FAIL"; else echo "PASS|NEEDS_CHANGES|FAIL"; fi)\",
  \"issues\": [
    {
      \"severity\": \"CRITICAL|MAJOR|MINOR\",
      \"file\": \"<path>\",
      \"line\": <number or null>,
      \"category\": \"<security|quality|performance|patterns|docs|tests|deps|debt>\",
      \"description\": \"<what is wrong>\",
      \"suggestion\": \"<how to fix>\"
    }
  ],
  \"summary\": \"<1-2 sentence summary>\"
}

## Code to Review
$DIFF_CONTENT"

# ── Execute headless review ───────────────────────────────
RAW_RESPONSE=""

run_claude() {
  RAW_RESPONSE=$(claude -p "$PROMPT" --output-format json --max-turns 1 2>/dev/null) || {
    echo "Error: claude -p failed" >&2
    exit 1
  }
}

run_codex() {
  RAW_RESPONSE=$(codex exec --json --sandbox read-only "$PROMPT" 2>/dev/null) || {
    echo "Error: codex exec failed" >&2
    exit 1
  }
}

if [[ "$TOOL" == "claude" ]]; then
  run_claude
else
  run_codex
fi

# ── Parse response ────────────────────────────────────────
# Extract JSON review from the response.
# claude -p --output-format json wraps in {"type":"result","result":"<text>"}
# codex exec --json returns array of items.
# We need to extract the inner JSON review object.

extract_review_json() {
  local input="$1"

  # Try: direct JSON parse (already valid review object)
  if echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); assert all(k in d for k in ('verdict','score','issues'))" 2>/dev/null; then
    echo "$input"
    return 0
  fi

  # Try: claude -p format — extract .result field, then parse inner JSON
  local inner
  inner=$(echo "$input" | python3 -c "
import sys, json, re
data = json.load(sys.stdin)
text = data.get('result', '') if isinstance(data, dict) else str(data)
# Find JSON object in text
match = re.search(r'\{[\s\S]*\"verdict\"[\s\S]*\}', text)
if match:
    obj = json.loads(match.group())
    print(json.dumps(obj))
else:
    sys.exit(1)
" 2>/dev/null) && { echo "$inner"; return 0; }

  # Try: codex format — find last completed message
  inner=$(echo "$input" | python3 -c "
import sys, json, re
data = json.load(sys.stdin)
text = ''
if isinstance(data, list):
    for item in reversed(data):
        if isinstance(item, dict):
            text = item.get('agent_message', item.get('content', item.get('text', '')))
            if text: break
elif isinstance(data, dict):
    text = json.dumps(data)
match = re.search(r'\{[\s\S]*\"verdict\"[\s\S]*\}', str(text))
if match:
    obj = json.loads(match.group())
    print(json.dumps(obj))
else:
    sys.exit(1)
" 2>/dev/null) && { echo "$inner"; return 0; }

  # Try: raw text contains JSON somewhere
  inner=$(echo "$input" | python3 -c "
import sys, json, re
text = sys.stdin.read()
match = re.search(r'\{[\s\S]*\"verdict\"[\s\S]*\}', text)
if match:
    obj = json.loads(match.group())
    print(json.dumps(obj))
else:
    sys.exit(1)
" 2>/dev/null) && { echo "$inner"; return 0; }

  return 1
}

REVIEW_JSON=$(extract_review_json "$RAW_RESPONSE") || {
  echo "Error: Could not parse review JSON from $TOOL response" >&2
  echo "Raw response (first 500 chars):" >&2
  echo "$RAW_RESPONSE" | head -c 500 >&2
  exit 1
}

# ── Add tool metadata ─────────────────────────────────────
FINAL_JSON=$(echo "$REVIEW_JSON" | python3 -c "
import sys, json
review = json.load(sys.stdin)
review['tool'] = '$TOOL'
if $DIFF_TRUNCATED:
    review['warning'] = 'Diff was truncated to $DIFF_LIMIT lines'
print(json.dumps(review, indent=2))
")

# ── Output ────────────────────────────────────────────────
if [[ -n "$OUTPUT" ]]; then
  echo "$FINAL_JSON" > "$OUTPUT"
  echo "Review saved to $OUTPUT" >&2
else
  echo "$FINAL_JSON"
fi
