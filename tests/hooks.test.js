const test = require('node:test');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const path = require('node:path');

const { isBlocked } = require('../hooks/block-env');
const { mergeConfig } = require('../scripts/merge-hook-config');

const runHook = (hook, payload) => spawnSync(
  process.execPath,
  [path.resolve(__dirname, `../hooks/${hook}`)],
  { input: JSON.stringify(payload), encoding: 'utf8' },
);

test('block-env blocks secret files', () => {
  for (const filePath of [
    '.env',
    '.env.local',
    'config/.env.production',
    'secrets/api.json',
    'certs/server.pem',
    'keys/deploy.key',
    '.ssh/id_rsa',
    'credentials.json',
    '.aws/credentials',
  ]) {
    assert.equal(isBlocked(filePath), true, `${filePath} should be blocked`);
  }
});

test('block-env allows source files whose names merely mention secrets', () => {
  // A substring matcher used to block all of these, which made the hook a
  // daily obstacle rather than a guardrail.
  for (const filePath of [
    'src/auth/password-reset.ts',
    'docs/api_key_rotation.md',
    'lib/credentials-form.tsx',
    'src/utils/keyboard.ts',
    'tests/env.spec.ts',
    '.env.example',
    '.env.template',
  ]) {
    assert.equal(isBlocked(filePath), false, `${filePath} should be readable`);
  }
});

test('block-env exits 2 on a secret and 0 otherwise', () => {
  assert.equal(runHook('block-env.js', { tool_input: { file_path: '.env.production' } }).status, 2);
  assert.equal(runHook('block-env.js', { tool_input: { file_path: 'src/index.ts' } }).status, 0);
});

test('block-env fails open on malformed input', () => {
  const result = spawnSync(process.execPath, [path.resolve(__dirname, '../hooks/block-env.js')], {
    input: 'not json',
    encoding: 'utf8',
  });
  assert.equal(result.status, 0, 'a broken hook must never stop work');
});

test('completion-guard ignores commands that are not a commit', () => {
  assert.equal(runHook('completion-guard.js', { tool_input: { command: 'pnpm test' } }).status, 0);
});

test('merges framework and custom permissions without dropping either side', () => {
  const merged = mergeConfig(
    { permissions: { allow: ['Read(*)'], deny: ['Bash(rm -rf /)'] }, hooks: {} },
    { permissions: { allow: ['Bash(git status)'] }, hooks: {} },
  );
  assert.deepEqual(merged.permissions, {
    allow: ['Read(*)', 'Bash(git status)'],
    deny: ['Bash(rm -rf /)'],
  });
});
