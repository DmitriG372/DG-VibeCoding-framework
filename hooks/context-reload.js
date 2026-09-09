#!/usr/bin/env node
// DG-VibeCoding-Framework — Context Reload Hook
// Recovers project context after session compaction.
// Triggered by SessionStart with matcher "compact".
// Outputs JSON to stdout with additionalContext for Claude.
// Surfaces narrative .claude/SNAPSHOT.md when present (free-form session memory).

const fs = require('fs');
const { execSync } = require('child_process');

// Hooks run in the session cwd, which may be a subdirectory of the project. Work from the
// repository root so PROJECT.md, sprint/ and .claude/ resolve the same way every time.
function chdirToProjectRoot() {
  try {
    const root = execSync('git rev-parse --show-toplevel', {
      encoding: 'utf8', timeout: 5000, stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    if (root) process.chdir(root);
  } catch { /* not a git repo — stay in cwd */ }
}
chdirToProjectRoot();

const SNAPSHOT_PATH = '.claude/context-snapshot.json';
const NARRATIVE_SNAPSHOT_PATH = '.claude/SNAPSHOT.md';

function run(cmd) {
  try {
    return execSync(cmd, { encoding: 'utf8', timeout: 5000 }).trim();
  } catch { return ''; }
}

function readFileSafe(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch { return ''; }
}

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    let context = '';

    // --- Try to load snapshot ---
    if (fs.existsSync(SNAPSHOT_PATH)) {
      const snapshot = JSON.parse(fs.readFileSync(SNAPSHOT_PATH, 'utf8'));

      context += '=== CONTEXT RECOVERY (post-compaction) ===\n\n';
      context += `Snapshot from: ${snapshot.timestamp}\n`;
      context += `Session: ${snapshot.session_id}\n\n`;

      // --- Project rules ---
      if (snapshot.project && snapshot.project.sections) {
        const sections = snapshot.project.sections;
        if (Object.keys(sections).length > 0) {
          context += '--- PROJECT RULES & PATTERNS ---\n';
          for (const [name, content] of Object.entries(sections)) {
            context += `\n${content}\n`;
          }
          context += '\n';
        }
      }

      // --- Git state ---
      if (snapshot.git) {
        context += '--- GIT STATE ---\n';
        context += `Branch: ${snapshot.git.branch}\n`;
        if (snapshot.git.uncommitted > 0) {
          context += `Uncommitted: ${snapshot.git.uncommitted} files\n`;
        }
        if (snapshot.git.recentCommits) {
          context += `Recent commits:\n${snapshot.git.recentCommits}\n`;
        }
        context += '\n';
      }

      // --- Parallel CC/CX coordination, when there is any (schema v4) ---
      if (Array.isArray(snapshot.activeTasks) && snapshot.activeTasks.length > 0) {
        context += '--- TASKS IN FLIGHT ---\n';
        for (const task of snapshot.activeTasks) {
          context += `${task.id}: ${task.title} (${task.status})`;
          if (task.assigned_to) context += ` [${task.assigned_to}]`;
          if (task.branch) context += ` [branch: ${task.branch}]`;
          context += '\n';
        }
        context += '\n';
      }

      // --- Narrative SNAPSHOT.md ---
      if (fs.existsSync(NARRATIVE_SNAPSHOT_PATH)) {
        const narrative = readFileSafe(NARRATIVE_SNAPSHOT_PATH);
        if (narrative) {
          context += '--- SNAPSHOT.md (narrative session memory) ---\n';
          context += narrative;
          context += '\n';
        }
      }

      context += '=== END RECOVERY ===\n\n';
      context += 'Read PROJECT.md if you need project facts. Continue the work in progress.\n';

      process.stderr.write('🔄 Context recovered from pre-compaction snapshot\n');
    } else {
      // --- Fallback: basic git context ---
      const branch = run('git branch --show-current') || 'detached';
      const status = run('git status --short');
      const modifiedCount = status ? status.split('\n').filter(Boolean).length : 0;
      const log = run('git log -5 --pretty="[%h] %ad %s" --date=short');

      context += '=== CONTEXT RECOVERY (no snapshot available) ===\n\n';
      context += '--- GIT STATE ---\n';
      context += `Branch: ${branch}\n`;
      if (modifiedCount > 0) {
        context += `Uncommitted: ${modifiedCount} files\n`;
      }
      if (log) {
        context += `Recent commits:\n${log}\n`;
      }
      context += '\n=== END RECOVERY ===\n\n';
      context += 'Read PROJECT.md if you need project facts. Continue the work in progress.\n';
      context += '(No pre-compaction snapshot was found — context may be incomplete.)\n';

      process.stderr.write('⚠️ No snapshot found, providing basic git context\n');
    }

    // --- Output JSON to stdout for Claude ---
    const output = {
      hookSpecificOutput: {
        hookEventName: 'SessionStart',
        additionalContext: context,
      },
    };

    process.stdout.write(JSON.stringify(output));
  } catch (err) {
    // Fail-open: provide minimal context
    process.stderr.write(`⚠️ context-reload.js error: ${err.message}\n`);
    const fallback = {
      hookSpecificOutput: {
        hookEventName: 'SessionStart',
        additionalContext: 'Context recovery failed. Read PROJECT.md and check `git status` before continuing.',
      },
    };
    process.stdout.write(JSON.stringify(fallback));
  }

  process.exit(0);
});
