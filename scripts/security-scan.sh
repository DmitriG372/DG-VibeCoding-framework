#!/usr/bin/env bash
# Run Codex Security without installing it into the project.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/security-scan.sh [options]

Run Codex Security without installing it into the project.

Options:
  --working-tree              Scan staged and unstaged changes (default).
  --diff <base>               Scan committed changes from <base> to HEAD.
  --mode <standard|deep>      Scan depth (default: standard).
  --fail-on-severity <level>  Fail when a finding reaches this severity.
  --output-dir <path>         Empty directory outside the repository for results.
  --dry-run                   Validate inputs without loading credentials or scanning.
  -h, --help                  Show this help.

Set CODEX_SECURITY_BIN to the approved Codex Security executable. The script
uses a codex-security executable already on PATH only when that variable is
unset. It never installs packages or reads credentials from project files.
EOF
}

TARGET="working-tree"
BASE="HEAD"
MODE="standard"
FAIL_ON_SEVERITY=""
OUTPUT_DIR=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --working-tree) TARGET="working-tree"; BASE="HEAD"; shift ;;
    --diff)
      [[ $# -ge 2 ]] || { echo 'Missing --diff base revision' >&2; exit 64; }
      TARGET="diff"; BASE="$2"; shift 2 ;;
    --mode)
      [[ $# -ge 2 ]] || { echo 'Missing --mode value' >&2; exit 64; }
      MODE="$2"; shift 2 ;;
    --fail-on-severity)
      [[ $# -ge 2 ]] || { echo 'Missing --fail-on-severity value' >&2; exit 64; }
      FAIL_ON_SEVERITY="$2"; shift 2 ;;
    --output-dir)
      [[ $# -ge 2 ]] || { echo 'Missing --output-dir path' >&2; exit 64; }
      OUTPUT_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 64 ;;
  esac
done

[[ "$MODE" == "standard" || "$MODE" == "deep" ]] || {
  echo '--mode must be standard or deep' >&2
  exit 64
}

if [[ -n "${CODEX_SECURITY_BIN:-}" ]]; then
  SECURITY_BIN="$CODEX_SECURITY_BIN"
elif SECURITY_BIN="$(command -v codex-security 2>/dev/null)"; then
  :
else
  echo 'Codex Security executable not found. Set CODEX_SECURITY_BIN to the approved binary.' >&2
  exit 1
fi

[[ -x "$SECURITY_BIN" ]] || {
  echo "Codex Security executable is not executable: $SECURITY_BIN" >&2
  exit 1
}

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo 'security-scan: not inside a Git repository' >&2
  exit 1
}
ROOT="$(cd "$ROOT" && pwd -P)"
git rev-parse --verify "${BASE}^{commit}" >/dev/null 2>&1 || {
  echo "security-scan: unknown base revision: $BASE" >&2
  exit 1
}

umask 077
if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dg-codex-security-XXXXXX")"
else
  OUTPUT_PARENT="$(dirname "$OUTPUT_DIR")"
  OUTPUT_NAME="$(basename "$OUTPUT_DIR")"
  [[ -d "$OUTPUT_PARENT" ]] || {
    echo "security-scan: output directory parent does not exist: $OUTPUT_PARENT" >&2
    exit 1
  }
  OUTPUT_PARENT="$(cd "$OUTPUT_PARENT" && pwd -P)"
  OUTPUT_DIR="$OUTPUT_PARENT/$OUTPUT_NAME"
  [[ "$OUTPUT_DIR" != "$ROOT" && "$OUTPUT_DIR" != "$ROOT"/* ]] || {
    echo 'security-scan: results must be outside the repository' >&2
    exit 1
  }
  if [[ -e "$OUTPUT_DIR" ]]; then
    [[ -d "$OUTPUT_DIR" ]] && [[ -z "$(find "$OUTPUT_DIR" -mindepth 1 -print -quit)" ]] || {
      echo "security-scan: output directory must be new or empty: $OUTPUT_DIR" >&2
      exit 1
    }
  else
    mkdir "$OUTPUT_DIR"
  fi
fi

ARGS=(scan "$ROOT" --output-dir "$OUTPUT_DIR" --mode "$MODE" --json)
if [[ "$TARGET" == "working-tree" ]]; then
  ARGS+=(--working-tree --base "$BASE")
else
  ARGS+=(--diff "$BASE" --head HEAD)
fi
[[ -n "$FAIL_ON_SEVERITY" ]] && ARGS+=(--fail-on-severity "$FAIL_ON_SEVERITY")
[[ "$DRY_RUN" == true ]] && ARGS+=(--dry-run)

echo "security-scan: results will be written to $OUTPUT_DIR" >&2
exec "$SECURITY_BIN" "${ARGS[@]}"
