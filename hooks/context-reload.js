#!/usr/bin/env node
// Recover saved context on SessionStart compact, with live Git state.
const fs = require('fs');
const { execSync } = require('child_process');

function run(cmd) {
  try {
    return execSync(cmd, { encoding: 'utf8', timeout: 5000, stdio: ['ignore', 'pipe', 'pipe'] }).trim();
  } catch { return ''; }
}

function readSnapshot(sessionId) {
  try {
    const snapshot = JSON.parse(fs.readFileSync('.claude/context-snapshot.json', 'utf8'));
    // A shared checkout can contain a snapshot from an unrelated session.
    // Without matching identities, recover from live files instead.
    return sessionId && sessionId !== 'unknown' && snapshot?.session_id === sessionId ? snapshot : null;
  } catch { return null; }
}

let input = '';
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  let payload = {};
  try { payload = JSON.parse(input || '{}'); } catch { /* recover live state */ }
  const snapshot = readSnapshot(payload?.session_id);
  let context = '=== CONTEXT RECOVERY ===\n\n';
  if (snapshot) {
    context += `Snapshot from: ${snapshot.timestamp || 'unknown'} (saved facts may be stale).\n`;
    const sections = snapshot.project?.sections;
    if (sections && typeof sections === 'object') {
      context += '\n--- SAVED PROJECT CONTEXT ---\n';
      for (const content of Object.values(sections)) {
        if (typeof content === 'string') context += `${content}\n`;
      }
    }
    if (Array.isArray(snapshot.activeTasks)) {
      context += '\n--- SAVED TASKS (verify current state before acting) ---\n';
      for (const task of snapshot.activeTasks) {
        if (!task || typeof task !== 'object') continue;
        context += `${task.id}: ${task.title} (${task.status}) [${task.assigned_to}] [${task.branch}]\n`;
      }
    }
  } else {
    context += 'No matching readable session snapshot; recovering live state.\n';
  }

  // Always query Git: the checkout may have changed since compaction.
  const branch = run('git branch --show-current') || 'detached or unavailable';
  const status = run('git status --short');
  const log = run('git log -5 --pretty="[%h] %ad %s" --date=short');
  context += `\n--- LIVE GIT STATE ---\nBranch: ${branch}\n`;
  if (status) context += `Working tree:\n${status}\n`;
  if (log) context += `Recent commits:\n${log}\n`;

  context += '\n=== END RECOVERY ===\n';
  context += 'Continue the user\'s current task. Read PROJECT.md for current project facts.\n';
  context += 'If task context is missing, consult the conversation or existing session notes; do not infer authorization from saved tasks.\n';
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: { hookEventName: 'SessionStart', additionalContext: context },
  }));
});
