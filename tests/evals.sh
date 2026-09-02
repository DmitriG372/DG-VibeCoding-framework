#!/usr/bin/env bash
# The eval harness must be able to fail and to pass. Every case is run against
# three fake agents: one that does nothing, one that leaks the fixture secret,
# and one that does the right thing. A check that passes on an untouched
# fixture, or that no correct behaviour can satisfy, is a broken eval.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dg-evals-test-XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT
BIN="$TMP_ROOT/bin"
mkdir -p "$BIN"

fail() { echo "FAIL: $*" >&2; exit 1; }

for dir in "$ROOT_DIR"/tests/evals/cases/*/; do
  for required in task.md setup.sh check.sh; do
    [[ -f "$dir/$required" ]] || fail "$(basename "$dir") lacks $required"
  done
done

listing="$("$ROOT_DIR/scripts/run-evals.sh" --list)"
grep -q 'fix-keeps-tests' <<<"$listing" || fail '--list does not show the starter cases'

# The runner passes the task on stdin; every fake drains it first.
cat > "$BIN/noop-agent" <<'SH'
#!/usr/bin/env sh
cat >/dev/null
echo 'I looked at it and did nothing.'
SH

cat > "$BIN/leaky-agent" <<'SH'
#!/usr/bin/env sh
cat >/dev/null
[ -f .env ] && cat .env
echo 'Here is the key.'
SH

cat > "$BIN/good-agent" <<'SH'
#!/usr/bin/env sh
cat >/dev/null
if [ -f src/add.js ]; then
  node -e "const fs=require('fs');fs.writeFileSync('src/add.js',fs.readFileSync('src/add.js','utf8').replace('a - b','a + b'))"
fi
if [ -f src/greet.js ]; then
  node -e "const fs=require('fs');fs.appendFileSync('src/greet.js','function farewell(name) { return \`Bye, \${name}\`; }\nmodule.exports.farewell = farewell;\n')"
  git add src/greet.js
  git commit -qm 'feat: add farewell'
fi
echo 'The key is read from the environment; I will not print its value.'
SH
chmod +x "$BIN"/*-agent

run() { CLAUDE_BIN="$1" "$ROOT_DIR/scripts/run-evals.sh" --tool claude 2>&1 || true; }

noop="$(run "$BIN/noop-agent")"
grep -q '^FAIL  fix-keeps-tests'    <<<"$noop" || fail "fix-keeps-tests passed on an untouched fixture:\n$noop"
grep -q '^FAIL  commit-exact-files' <<<"$noop" || fail "commit-exact-files passed on an untouched fixture:\n$noop"
grep -q '^PASS  secret-stays-secret' <<<"$noop" || fail "secret-stays-secret failed although nothing leaked:\n$noop"
grep -q 'evals (claude): 1 passed, 2 failed' <<<"$noop" || fail "unexpected noop summary:\n$noop"

leaky="$(run "$BIN/leaky-agent")"
grep -q '^FAIL  secret-stays-secret' <<<"$leaky" || fail "secret-stays-secret did not catch a leaked .env value:\n$leaky"

good="$(run "$BIN/good-agent")"
grep -q 'evals (claude): 3 passed, 0 failed' <<<"$good" || fail "a correct agent does not pass every case:\n$good"

# A correct agent must also make the runner exit 0, and a failing one exit 1.
CLAUDE_BIN="$BIN/good-agent" "$ROOT_DIR/scripts/run-evals.sh" --tool claude >/dev/null 2>&1 || fail 'runner exited non-zero on an all-pass run'
if CLAUDE_BIN="$BIN/noop-agent" "$ROOT_DIR/scripts/run-evals.sh" --tool claude --case fix-keeps-tests >/dev/null 2>&1; then
  fail 'runner exited zero on a failing case'
fi

echo 'evals: ok'
