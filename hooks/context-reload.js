#!/usr/bin/env node
// DG-VibeCoding-Framework v5.0.0 — Context Reload Hook
// Recovers project context after session compaction.
// Triggered by SessionStart with matcher "compact".
// Outputs JSON to stdout with additionalContext for Claude.

const fs = require('fs');
const { execSync } = require('child_process');

const SNAPSHOT_PATH = '.claude/context-snapshot.json';

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

      // --- Sprint state ---
      if (snapshot.sprint) {
        context += '--- SPRINT STATE ---\n';
        if (snapshot.sprint.sprint_id) {
          context += `Sprint: ${snapshot.sprint.sprint_id}\n`;
        }
        if (snapshot.sprint.current_feature) {
          context += `Current feature: ${snapshot.sprint.current_feature}\n`;
        }
        if (snapshot.sprint.branch_strategy) {
          context += `Branch strategy: ${snapshot.sprint.branch_strategy}\n`;
        }
        if (snapshot.sprint.stats) {
          const s = snapshot.sprint.stats;
          context += `Progress: ${s.completed || 0}/${s.total || 0} completed`;
          if (s.in_progress > 0) context += `, ${s.in_progress} in progress`;
          if (s.in_review > 0) context += `, ${s.in_review} in review`;
          context += '\n';
        }
        // Show current feature details
        if (snapshot.sprint.current_feature && snapshot.sprint.features) {
          const cf = snapshot.sprint.features.find(f => f.id === snapshot.sprint.current_feature);
          if (cf) {
            context += `Feature ${cf.id}: ${cf.name} (${cf.status})`;
            if (cf.assigned_to) context += ` [assigned: ${cf.assigned_to}]`;
            if (cf.branch) context += ` [branch: ${cf.branch}]`;
            context += '\n';
          }
        }
        context += '\n';
      }

      context += '=== END RECOVERY ===\n\n';
      context += 'MANDATORY: Read PROJECT.md and sprint/sprint.json NOW to refresh full context.\n';

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
      context += 'MANDATORY: Read PROJECT.md and sprint/sprint.json NOW to refresh full context.\n';
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
        additionalContext: 'Context recovery failed. MANDATORY: Read PROJECT.md and sprint/sprint.json NOW.',
      },
    };
    process.stdout.write(JSON.stringify(fallback));
  }

  process.exit(0);
});
