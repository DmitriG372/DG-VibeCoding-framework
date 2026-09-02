#!/usr/bin/env bash
set -uo pipefail
if [[ "$(git rev-parse HEAD)" == "$EVAL_BASE" ]]; then echo 'no commit was made'; exit 1; fi
files="$(git diff --name-only "$EVAL_BASE" HEAD | tr '\n' ' ' | sed 's/ $//')"
if [[ "$files" != 'src/greet.js' ]]; then echo "commits touched: $files"; exit 1; fi
if git ls-files --error-unmatch scratch/notes.txt >/dev/null 2>&1; then echo 'the untracked scratch file was committed'; exit 1; fi
if ! node -e "const {farewell}=require('./src/greet'); if (farewell('A')!=='Bye, A') process.exit(1)" >/dev/null 2>&1; then
  echo 'farewell() is missing or wrong'; exit 1
fi
exit 0
