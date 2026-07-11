const test = require('node:test');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const {
  escapeMarkdownCell,
  getToolExitCode,
  normalizeHookInput,
  resolveLocalNodeBinary,
} = require('../hooks/lib/hook-input');
const { mergeConfig } = require('../scripts/merge-hook-config');

test('normalizes a Claude Edit payload', () => {
  const result = normalizeHookInput({
    tool_name: 'Edit',
    tool_input: { file_path: '/repo/src/a.ts' },
    cwd: '/repo',
    session_id: 'claude-1',
  });
  assert.equal(result.isEdit, true);
  assert.equal(result.filePath, '/repo/src/a.ts');
  assert.deepEqual(result.filePaths, ['/repo/src/a.ts']);
  assert.equal(result.sessionId, 'claude-1');
});

test('normalizes Codex apply_patch and extracts every target path', () => {
  const command = [
    '*** Begin Patch',
    '*** Update File: src/a.ts',
    '*** Add File: tests/a.test.ts',
    '*** End Patch',
  ].join('\n');
  const result = normalizeHookInput({
    tool_name: 'apply_patch',
    tool_input: { command },
    cwd: '/repo',
  });
  assert.equal(result.isEdit, true);
  assert.deepEqual(result.filePaths, ['src/a.ts', 'tests/a.test.ts']);
  assert.equal(result.filePath, 'src/a.ts');
});

test('normalizes Bash command and preserves a missing session id as null', () => {
  const result = normalizeHookInput({
    tool_name: 'Bash',
    tool_input: { command: 'npm test' },
  }, '/repo');
  assert.equal(result.command, 'npm test');
  assert.equal(result.sessionId, null);
  assert.equal(result.cwd, '/repo');
});

test('resolves only installed local node binaries', () => {
  const fakeExists = candidate => candidate === path.join('/repo', 'node_modules', '.bin', 'prettier');
  assert.equal(
    resolveLocalNodeBinary('/repo', 'prettier', fakeExists),
    path.join('/repo', 'node_modules', '.bin', 'prettier'),
  );
  assert.equal(resolveLocalNodeBinary('/repo', 'eslint', fakeExists), null);
});

test('extracts explicit tool exit status and leaves unknown status null', () => {
  assert.equal(getToolExitCode({ tool_response: { exit_code: 1 } }), 1);
  assert.equal(getToolExitCode({ tool_response: { status: 0 } }), 0);
  assert.equal(getToolExitCode({ tool_response: { stdout: 'failed' } }), null);
});

test('escapes Markdown table delimiters and line breaks', () => {
  assert.equal(escapeMarkdownCell('a|b\nnext'), 'a\\|b next');
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

test('auto-format passes a malicious filename as data, not shell code', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'dg-format-test-'));
  const binDirectory = path.join(directory, 'node_modules', '.bin');
  fs.mkdirSync(binDirectory, { recursive: true });
  const prettier = path.join(binDirectory, 'prettier');
  fs.writeFileSync(prettier, '#!/usr/bin/env sh\nprintf "%s\\n" "$@" > "$PWD/formatter-args"\n');
  fs.chmodSync(prettier, 0o755);
  const malicious = 'safe"; touch PWNED; #.js';
  fs.writeFileSync(path.join(directory, malicious), 'const safe = true;\n');

  const result = spawnSync(process.execPath, [path.resolve(__dirname, '../hooks/auto-format.js')], {
    cwd: directory,
    input: JSON.stringify({ tool_name: 'Edit', tool_input: { file_path: malicious }, cwd: directory }),
    encoding: 'utf8',
  });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(fs.existsSync(path.join(directory, 'PWNED')), false);
  assert.match(fs.readFileSync(path.join(directory, 'formatter-args'), 'utf8'), /--write/);
  fs.rmSync(directory, { recursive: true, force: true });
});
