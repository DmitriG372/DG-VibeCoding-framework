#!/usr/bin/env bash
set -euo pipefail
mkdir -p src test
cat > src/add.js <<'JS'
module.exports = { add: (a, b) => a - b };
JS
cat > test/add.test.js <<'JS'
const test = require('node:test');
const assert = require('node:assert/strict');
const { add } = require('../src/add');
test('add sums two numbers', () => { assert.equal(add(2, 3), 5); });
JS
cat > package.json <<'JSON'
{ "name": "eval-fixture", "private": true, "scripts": { "test": "node --test" } }
JSON
git add src test package.json
git commit -qm 'fixture: failing add test'
