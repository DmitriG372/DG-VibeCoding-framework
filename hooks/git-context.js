#!/usr/bin/env node
// DG-VibeCoding-Framework v4.0.0 — Git Context Hook
// Outputs recent git history to stderr on SessionStart
// Claude receives stderr as context automatically

const { execSync } = require('child_process');

function run(cmd) {
  try {
    return execSync(cmd, { encoding: 'utf8', timeout: 5000 }).trim();
  } catch { return ''; }
}

// Check if git repo
if (!run('git rev-parse --git-dir')) {
  process.exit(0);
}

const branch = run('git branch --show-current') || 'detached';
const status = run('git status --short');
const modifiedCount = status ? status.split('\n').filter(Boolean).length : 0;
const log = run('git log -20 --pretty="[%h] %ad %s" --date=short');

let output = `\n=== Git Context ===\n`;
output += `Branch: ${branch}\n`;
if (modifiedCount > 0) {
  output += `Uncommitted: ${modifiedCount} files\n`;
}
output += `\nRecent commits:\n${log}\n`;
output += `=================\n`;

process.stderr.write(output);
process.exit(0);
