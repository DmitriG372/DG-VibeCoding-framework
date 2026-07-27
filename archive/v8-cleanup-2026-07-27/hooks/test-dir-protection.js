#!/usr/bin/env node
// DG-VibeCoding-Framework — Test Directory Protection Hook
// PreToolUse on Edit|Write|MultiEdit; blocks edits to test files within 120s
// of a test run (fresh test failure → likely "fix by modifying the test" anti-pattern).
// Exit code 2 = hard block.

const fs = require('fs');
const path = require('path');
const { normalizeHookInput } = require('./lib/hook-input');

const FRESHNESS_WINDOW_MS = 120_000; // 2 minutes

let stdin = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => (stdin += c));
process.stdin.on('end', () => {
  let payload;
  try { payload = JSON.parse(stdin || '{}'); } catch { process.exit(0); }

  const normalized = normalizeHookInput(payload);
  if (!normalized.isEdit) return process.exit(0);
  const testTargets = normalized.filePaths.filter(isTestFile);
  if (testTargets.length === 0) return process.exit(0);

  const marker = path.resolve(normalized.cwd, '.claude', '.last-test-run');
  if (!fs.existsSync(marker)) return process.exit(0);

  let state;
  try { state = JSON.parse(fs.readFileSync(marker, 'utf8')); } catch { return process.exit(0); }
  if (!Number.isFinite(state.timestamp) || !Number.isInteger(state.exitCode) || state.exitCode === 0) {
    return process.exit(0);
  }

  const age = Date.now() - state.timestamp;
  if (age > FRESHNESS_WINDOW_MS) return process.exit(0); // stale marker, allow

  process.stderr.write(
    `\n[test-dir-protection] Advisory for ${testTargets.join(', ')}\n` +
    `A test command failed ${Math.round(age / 1000)}s ago (exit ${state.exitCode}). ` +
    `Confirm the expected behavior before changing the test; valid TDD edits remain allowed.\n`
  );
  process.exit(0);
});

function isTestFile(p) {
  if (!p) return false;
  return /(^|\/)(tests?|__tests__|spec)\//.test(p)
    || /\.(test|spec)\.[jt]sx?$/.test(p)
    || /_test\.(py|go|rs)$/.test(p);
}
