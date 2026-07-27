const test = require('node:test');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
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
    '.envrc',                 // direnv; routinely holds exported credentials
    '.env.examplefoo',        // the template suffix is anchored, not a prefix
    '.env.example.bak',
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

test('completion-guard ignores anything that is not a Bash git commit', () => {
  // Each payload must carry tool_name — without it the hook short-circuits on
  // the tool gate and the command is never examined at all, which made an
  // earlier version of this test pass no matter what the command said.
  const cases = [
    { tool_name: 'Bash', tool_input: { command: 'pnpm test' } },
    { tool_name: 'Bash', tool_input: { command: 'git status' } },
    { tool_name: 'Edit', tool_input: { command: 'git commit -m x' } },
  ];
  for (const payload of cases) {
    assert.equal(runHook('completion-guard.js', payload).status, 0,
      `expected pass-through for ${JSON.stringify(payload)}`);
  }
});

test('completion-guard blocks a commit whose staged code contains a stub', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'dg-guard-'));
  const repoRoot = path.resolve(__dirname, '..');
  fs.mkdirSync(path.join(directory, 'scripts'));
  fs.copyFileSync(path.join(repoRoot, 'scripts/stub-check.sh'), path.join(directory, 'scripts/stub-check.sh'));
  fs.chmodSync(path.join(directory, 'scripts/stub-check.sh'), 0o755);

  const git = (...args) => spawnSync('git', args, { cwd: directory, encoding: 'utf8' });
  git('init', '-q');
  git('config', 'user.name', 'Test');
  git('config', 'user.email', 'test@example.invalid');

  fs.writeFileSync(path.join(directory, 'clean.js'), 'module.exports = () => 1;\n');
  git('add', 'clean.js');
  const clean = spawnSync(process.execPath, [path.resolve(repoRoot, 'hooks/completion-guard.js')], {
    cwd: directory,
    input: JSON.stringify({ tool_name: 'Bash', tool_input: { command: 'git commit -m ok' } }),
    encoding: 'utf8',
  });
  assert.equal(clean.status, 0, `clean staged code must commit: ${clean.stderr}`);

  fs.writeFileSync(path.join(directory, 'stub.js'), 'function f() {\n  // TODO: implement\n}\n');
  git('add', 'stub.js');
  const blocked = spawnSync(process.execPath, [path.resolve(repoRoot, 'hooks/completion-guard.js')], {
    cwd: directory,
    input: JSON.stringify({ tool_name: 'Bash', tool_input: { command: 'git commit -m wip' } }),
    encoding: 'utf8',
  });
  assert.equal(blocked.status, 2, 'a staged TODO must block the commit');
  assert.match(blocked.stderr, /Stub code detected/);

  fs.rmSync(directory, { recursive: true, force: true });
});

test('completion-guard skips silently when stub-check.sh is absent', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'dg-guard-bare-'));
  const result = spawnSync(process.execPath, [path.resolve(__dirname, '../hooks/completion-guard.js')], {
    cwd: directory,
    input: JSON.stringify({ tool_name: 'Bash', tool_input: { command: 'git commit -m x' } }),
    encoding: 'utf8',
  });
  fs.rmSync(directory, { recursive: true, force: true });
  assert.equal(result.status, 0, 'a missing checker must not block work');
});

test('the three context hooks run and exit cleanly', () => {
  // Existence checks in parity.test.js would not notice a hook that crashes on
  // startup. SNAPSHOT.md is no longer installed, so this also pins that these
  // degrade instead of erroring.
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'dg-ctx-'));
  for (const hook of ['git-context.js', 'pre-compact.js', 'context-reload.js']) {
    const result = spawnSync(process.execPath, [path.resolve(__dirname, `../hooks/${hook}`)], {
      cwd: directory,
      input: JSON.stringify({ session_id: 'test', trigger: 'compact' }),
      encoding: 'utf8',
    });
    assert.equal(result.status, 0, `${hook} exited ${result.status}: ${result.stderr}`);
  }
  fs.rmSync(directory, { recursive: true, force: true });
});

test('context-reload never orders the agent to read the optional sprint file', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'dg-reload-'));
  const result = spawnSync(process.execPath, [path.resolve(__dirname, '../hooks/context-reload.js')], {
    cwd: directory,
    input: JSON.stringify({ source: 'compact' }),
    encoding: 'utf8',
  });
  fs.rmSync(directory, { recursive: true, force: true });
  const context = JSON.parse(result.stdout).hookSpecificOutput.additionalContext;
  assert.doesNotMatch(context, /MANDATORY/,
    'the contract says sprint state is optional; the hook must not contradict it');
  assert.doesNotMatch(context, /sprint\/sprint\.json/);
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
