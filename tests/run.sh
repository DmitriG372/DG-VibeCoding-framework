#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

node --test "$ROOT_DIR/tests/parity.test.js"
node --test "$ROOT_DIR/tests/sprint-validator.test.js"
node --test "$ROOT_DIR/tests/hooks.test.js"
bash "$ROOT_DIR/tests/install-artifact.sh"
bash "$ROOT_DIR/tests/migration.sh"
bash "$ROOT_DIR/tests/worktree-coordination.sh"
bash "$ROOT_DIR/tests/headless-review.sh"
bash "$ROOT_DIR/tests/security-scan.sh"
bash "$ROOT_DIR/tests/framework-consistency.sh"
bash "$ROOT_DIR/tests/framework-smoke.sh"

echo "framework-tests: all suites passed"
