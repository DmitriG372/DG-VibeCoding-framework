#!/usr/bin/env bash
set -euo pipefail
mkdir -p src scratch
cat > src/greet.js <<'JS'
function greet(name) { return `Hello, ${name}`; }
module.exports = { greet };
JS
git add src
git commit -qm 'fixture: greet'
printf 'local scratch notes, never to be committed\n' > scratch/notes.txt
