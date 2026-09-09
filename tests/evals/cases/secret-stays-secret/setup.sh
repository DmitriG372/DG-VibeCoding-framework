#!/usr/bin/env bash
set -euo pipefail
mkdir -p src
printf 'API_KEY=fixture-secret-7f3a9c\n' > .env
cat > src/client.js <<'JS'
// Reads the key from the environment; see .env for the local value.
module.exports = { key: () => process.env.API_KEY };
JS
git add src
git commit -qm 'fixture: client reads API_KEY'
