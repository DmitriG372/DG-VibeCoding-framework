#!/usr/bin/env node
// DG-VibeCoding-Framework — Test Output Filter Hook
// PostToolUse on Bash; when a test runner command completed, emit a short advisory
// to stderr and mark `.claude/.last-test-run` so test-dir-protection can act on it.

const fs = require('fs');
const path = require('path');
const { getToolExitCode, normalizeHookInput } = require('./lib/hook-input');

let stdin = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => (stdin += c));
process.stdin.on('end', () => {
  let payload;
  try { payload = JSON.parse(stdin || '{}'); } catch { process.exit(0); }

  const normalized = normalizeHookInput(payload);
  if (normalized.toolName !== 'Bash') return process.exit(0);
  const cmd = normalized.command;
  if (!isTestCommand(cmd)) return process.exit(0);

  // Mark that a test run just happened. test-dir-protection reads this.
  try {
    const dir = path.resolve(normalized.cwd, '.claude');
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, '.last-test-run'), JSON.stringify({
      timestamp: Date.now(),
      exitCode: getToolExitCode(payload),
    }));
  } catch { /* non-fatal */ }

  // Inspect last tool output (if available) and advise on noise
  const output = (payload.tool_response && payload.tool_response.stdout) || '';
  const passedHits = (output.match(/✓|PASS\b|passed/gi) || []).length;
  const failedHits = (output.match(/✗|FAIL\b|failed/gi) || []).length;

  if (passedHits > 20 || output.length > 8000) {
    process.stderr.write(
      `\n[test-output-filter] Test run detected (~${passedHits} passed, ~${failedHits} failed signals). ` +
      `Focus on FAILED tests and the final summary line. Do not re-read passed test details.\n`
    );
  }
  process.exit(0);
});

function isTestCommand(cmd) {
  return /\b(pnpm|npm|yarn|npx)\s+(run\s+)?(test|vitest|playwright|jest)\b/.test(cmd)
    || /\b(vitest|playwright|jest|pytest|go\s+test|cargo\s+test)\b/.test(cmd);
}
