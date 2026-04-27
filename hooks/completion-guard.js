#!/usr/bin/env node
// DG-VibeCoding-Framework — Completion Guard Hook
// PreToolUse on Bash; blocks `git commit` if scripts/stub-check.sh finds stubs.
// Exit code 2 = hard block; Claude receives the error and must fix before retrying.

const { execFileSync } = require('child_process');
const path = require('path');
const fs = require('fs');

let stdin = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => (stdin += c));
process.stdin.on('end', () => {
  let payload;
  try { payload = JSON.parse(stdin || '{}'); } catch { process.exit(0); }

  const toolName = payload.tool_name || '';
  const cmd = (payload.tool_input && payload.tool_input.command) || '';

  if (toolName !== 'Bash') return process.exit(0);
  if (!/\bgit\s+commit\b/.test(cmd)) return process.exit(0);

  // Locate stub-check.sh — hook may run from any project; check current repo first.
  const candidates = [
    path.resolve(process.cwd(), 'scripts/stub-check.sh'),
    path.resolve(__dirname, '..', 'scripts/stub-check.sh'),
  ];
  const script = candidates.find(p => fs.existsSync(p));
  if (!script) return process.exit(0); // no script, skip silently

  try {
    // execFileSync avoids shell interpolation; args passed as a list.
    execFileSync('bash', [script, '--staged'], {
      env: { ...process.env, STUB_CHECK_BLOCK: '1' },
      stdio: 'pipe'
    });
    process.exit(0); // clean
  } catch (err) {
    const code = err.status || 1;
    if (code !== 2) return process.exit(0); // only block on explicit exit 2
    const out = (err.stdout || '').toString();
    process.stderr.write(
      '\n[completion-guard] Stub code detected in staged files. ' +
      'Resolve these before committing (execution-integrity Rule 3).\n' +
      (out ? out + '\n' : '') +
      'Override with `--skip-stubs` on /done only when truly WIP.\n'
    );
    process.exit(2);
  }
});
