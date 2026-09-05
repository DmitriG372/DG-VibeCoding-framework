#!/usr/bin/env node
// DG-VibeCoding-Framework — PreCompact Hook
// Saves critical project context to snapshot before session compaction.
// Claude receives this snapshot via context-reload.js after compaction.
// Narrative session memory is agent-authored; this hook must not mark it fresh.

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const SNAPSHOT_PATH = '.claude/context-snapshot.json';

function readFrameworkVersion() {
  // Single source of truth: VERSION file at the framework root.
  // Look up the directory tree from this hook's location.
  const candidates = [
    path.join(__dirname, '..', 'VERSION'),
    path.join(process.cwd(), 'VERSION'),
  ];
  for (const candidate of candidates) {
    try {
      const v = fs.readFileSync(candidate, 'utf8').trim();
      if (v) return v;
    } catch { /* try next */ }
  }
  return 'unknown';
}

function run(cmd) {
  try {
    return execSync(cmd, { encoding: 'utf8', timeout: 5000 }).trim();
  } catch { return ''; }
}

function readFileSection(filePath, sectionName) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.split('\n');
    const start = lines.findIndex(line => line.trimEnd() === `## ${sectionName}`);
    if (start < 0) return '';
    let end = start + 1;
    while (end < lines.length && !/^##\s/.test(lines[end])) end++;
    return lines.slice(start, end).join('\n').trim();
  } catch { return ''; }
}

function readFileSafe(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch { return ''; }
}

// Read stdin (hook receives JSON with session_id, trigger)
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = input ? JSON.parse(input) : {};

    // --- Collect PROJECT.md sections ---
    const projectSections = {};
    for (const section of ['Rules', 'Patterns', 'Stack', 'Commands', 'Tech Stack', 'Current Sprint']) {
      const content = readFileSection('PROJECT.md', section);
      if (content) projectSections[section] = content;
    }

    // --- Collect git state ---
    const gitState = {
      branch: run('git branch --show-current') || 'detached',
      uncommitted: run('git status --short').split('\n').filter(Boolean).length,
      recentCommits: run('git log -5 --pretty="[%h] %ad %s" --date=short'),
    };

    // --- Collect sprint state ---
    let sprintState = null;
    try {
      const sprintJson = readFileSafe('sprint/sprint.json');
      if (sprintJson) sprintState = JSON.parse(sprintJson);
    } catch { /* ignore parse errors */ }

    // --- Extract the tasks still in flight (schema v4) ---
    let activeTasks = null;
    if (sprintState && Array.isArray(sprintState.tasks)) {
      const open = sprintState.tasks.filter(
        task => task && typeof task === 'object' && task.status !== 'done'
      );
      if (open.length > 0) {
        activeTasks = open.map(task => ({
          id: task.id,
          title: task.title,
          assigned_to: task.assigned_to,
          status: task.status,
          branch: task.branch,
        }));
      }
    }

    // --- Build snapshot ---
    const snapshot = {
      version: readFrameworkVersion(),
      timestamp: new Date().toISOString(),
      session_id: data.session_id || 'unknown',
      trigger: data.trigger || 'compact',
      project: {
        sections: projectSections,
      },
      git: gitState,
      sprint: sprintState,
      activeTasks: activeTasks,
    };

    // --- Ensure .claude/ directory exists ---
    const snapshotDir = path.dirname(SNAPSHOT_PATH);
    if (!fs.existsSync(snapshotDir)) {
      fs.mkdirSync(snapshotDir, { recursive: true });
    }

    // --- Write JSON snapshot ---
    fs.writeFileSync(SNAPSHOT_PATH, JSON.stringify(snapshot, null, 2));
    process.stderr.write(`📸 Context snapshot saved to ${SNAPSHOT_PATH}\n`);


  } catch (err) {
    // Fail-open: log error but don't block compaction
    process.stderr.write(`⚠️ pre-compact.js error: ${err.message}\n`);
  }

  process.exit(0);
});
