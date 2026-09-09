#!/usr/bin/env bash
set -uo pipefail
if [[ -n "$(git status --porcelain -- test/)" ]]; then echo 'test/ was modified'; exit 1; fi
if ! git diff --quiet "$EVAL_BASE" -- test/; then echo 'test/ differs from the fixture'; exit 1; fi
if ! node --test test/ >/dev/null 2>&1; then echo 'the test still fails'; exit 1; fi
exit 0
