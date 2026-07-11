#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-review-test-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
PROJECT="$TMP_ROOT/project"
BIN="$TMP_ROOT/bin"
mkdir -p "$BIN"

"$ROOT_DIR/setup-project.sh" "$PROJECT" >/dev/null
cd "$PROJECT"
git init -q
git config user.name 'Framework Test'
git config user.email 'framework-test@example.invalid'
mkdir -p src
malicious='safe"; touch PWNED; #.js'
printf '%s\n' 'export const safe = true;' > "src/$malicious"
git add .
git commit -qm 'test: review fixture'

cat > "$BIN/codex" <<'SH'
#!/usr/bin/env sh
cat >/dev/null
printf '%s\n' '{"type":"thread.started","thread_id":"test"}'
printf '%s\n' '{"type":"item.completed","item":{"type":"agent_message","text":"{\"target\":\"fixture\",\"mode\":\"quick\",\"score\":17,\"max_score\":17,\"verdict\":\"PASS\",\"issues\":[],\"summary\":\"ok\"}"}}'
SH
chmod +x "$BIN/codex"

SYSTEM_PATH="$BIN:$(dirname "$(command -v node)"):/usr/bin:/bin:/usr/sbin:/sbin"
PATH="$SYSTEM_PATH" OPENAI_API_KEY=test CODEX_BIN="$BIN/codex" scripts/headless-review.sh \
  --tool codex --mode quick --output "$TMP_ROOT/review.json" src >/dev/null

[[ ! -e PWNED ]] || { echo 'FAIL: malicious filename executed a shell command' >&2; exit 1; }
node -e "const r=require(process.argv[1]); if(r.verdict!=='PASS'||r.tool!=='codex') process.exit(1)" "$TMP_ROOT/review.json"

unset OPENAI_API_KEY || true
PATH="$SYSTEM_PATH" CODEX_BIN="$BIN/codex" scripts/headless-review.sh \
  --tool codex --mode quick --output "$TMP_ROOT/review-no-key.json" src >/dev/null

printf '%s\n' \
  '{"type":"thread.started"}' \
  '{"type":"item.completed","item":{"type":"agent_message","text":"final answer"}}' |
  node scripts/parse-codex-jsonl.js | grep -Fxq 'final answer'

mkdir -p config
printf '%s\n' '{"token":"not-a-real-secret"}' > config/credentials.json
git add -f config/credentials.json
git commit -qm 'test: secret path fixture'
if PATH="$SYSTEM_PATH" CODEX_BIN="$BIN/codex" scripts/headless-review.sh --tool codex config >/dev/null 2>&1; then
  echo 'FAIL: review accepted a secret-like tracked path' >&2
  exit 1
fi
printf '%s\n' '{"token":"changed"}' > config/credentials.json
git add -f config/credentials.json
if PATH="$SYSTEM_PATH" CODEX_BIN="$BIN/codex" scripts/headless-review.sh --tool codex --staged >/dev/null 2>&1; then
  echo 'FAIL: staged review accepted a secret-like changed path' >&2
  exit 1
fi

echo 'headless-review: ok'
