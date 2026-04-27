#!/usr/bin/env node
// DG-VibeCoding-Framework — Test Directory Protection Hook
// PreToolUse on Edit|Write|MultiEdit; blocks edits to test files within 120s
// of a test run (fresh test failure → likely "fix by modifying the test" anti-pattern).
// Exit code 2 = hard block.

const fs = require('fs');
const path = require('path');

const FRESHNESS_WINDOW_MS = 120_000; // 2 minutes

let stdin = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => (stdin += c));
process.stdin.on('end', () => {
  let payload;
  try { payload = JSON.parse(stdin || '{}'); } catch { process.exit(0); }

  const tool = payload.tool_name || '';
  if (!/^(Edit|Write|MultiEdit)$/.test(tool)) return process.exit(0);

  const target = (payload.tool_input && (payload.tool_input.file_path || payload.tool_input.path)) || '';
  if (!isTestFile(target)) return process.exit(0);

  const marker = path.resolve(process.cwd(), '.claude', '.last-test-run');
  if (!fs.existsSync(marker)) return process.exit(0);

  let lastRun;
  try { lastRun = Number(fs.readFileSync(marker, 'utf8').trim()); } catch { return process.exit(0); }
  if (!Number.isFinite(lastRun)) return process.exit(0);

  const age = Date.now() - lastRun;
  if (age > FRESHNESS_WINDOW_MS) return process.exit(0); // stale marker, allow

  process.stderr.write(
    `\n[test-dir-protection] Blocked edit to test file: ${target}\n` +
    `A test run just happened ${Math.round(age / 1000)}s ago. ` +
    `Modifying tests to make them pass is a known anti-pattern.\n` +
    `Options:\n` +
    `  1. Fix the code under test, not the test itself\n` +
    `  2. If the test is genuinely wrong, add a commit note explaining why\n` +
    `  3. Touch any non-test file first to clear the freshness window, then edit\n`
  );
  process.exit(2);
});

function isTestFile(p) {
  if (!p) return false;
  return /(^|\/)(tests?|__tests__|spec)\//.test(p)
    || /\.(test|spec)\.[jt]sx?$/.test(p)
    || /_test\.(py|go|rs)$/.test(p);
}
