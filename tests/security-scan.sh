#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-security-scan-test-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

FAKE_BIN="$TMP_ROOT/codex-security"
ARGS_FILE="$TMP_ROOT/args.txt"
RESULTS_DIR="$(cd "$TMP_ROOT" && pwd -P)/results"
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" "$@" > "$SECURITY_ARGS_FILE"' > "$FAKE_BIN"
chmod +x "$FAKE_BIN"

SECURITY_ARGS_FILE="$ARGS_FILE" CODEX_SECURITY_BIN="$FAKE_BIN" \
  "$ROOT_DIR/scripts/security-scan.sh" --diff HEAD --mode deep \
  --fail-on-severity high --output-dir "$RESULTS_DIR" >/dev/null

EXPECTED="$TMP_ROOT/expected.txt"
printf '%s\n' \
  scan "$ROOT_DIR" --output-dir "$RESULTS_DIR" --mode deep --json \
  --diff HEAD --head HEAD --fail-on-severity high > "$EXPECTED"
diff -u "$EXPECTED" "$ARGS_FILE"

if SECURITY_ARGS_FILE="$ARGS_FILE" CODEX_SECURITY_BIN="$FAKE_BIN" \
  "$ROOT_DIR/scripts/security-scan.sh" --output-dir "$ROOT_DIR/.security-results" >/dev/null 2>&1; then
  echo 'FAIL: security scan accepted a results directory inside the repository' >&2
  exit 1
fi

echo 'security-scan: ok'
