#!/usr/bin/env node
// DG-VibeCoding-Framework v5.0.0 — PreCompact Hook
// Saves critical project context to snapshot before session compaction.
// Claude receives this snapshot via context-reload.js after compaction.

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const SNAPSHOT_PATH = '.claude/context-snapshot.json';

function run(cmd) {
  try {
    return execSync(cmd, { encoding: 'utf8', timeout: 5000 }).trim();
  } catch { return ''; }
}

function readFileSection(filePath, sectionName) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const regex = new RegExp(`^##\\s+${sectionName}\\b[\\s\\S]*?(?=^## |$)`, 'gm');
    const match = content.match(regex);
    return match ? match[0].trim() : '';
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

    // --- Extract current step info ---
    let currentStep = null;
    if (sprintState && sprintState.current_feature && sprintState.features) {
      const cf = sprintState.features.find(f => f.id === sprintState.current_feature);
      if (cf && cf.steps && cf.steps.length > 0) {
        const inProgress = cf.steps.find(s => s.status === 'in_progress');
        const nextPending = cf.steps.find(s => s.status === 'pending');
        currentStep = {
          feature: cf.id,
          current: inProgress ? inProgress.description : null,
          next: nextPending ? nextPending.description : null,
          progress: `${cf.steps.filter(s => s.status === 'done').length}/${cf.steps.length}`
        };
      }
    }

    // --- Build snapshot ---
    const snapshot = {
      version: '5.0.0',
      timestamp: new Date().toISOString(),
      session_id: data.session_id || 'unknown',
      trigger: data.trigger || 'compact',
      project: {
        sections: projectSections,
      },
      git: gitState,
      sprint: sprintState,
      currentStep: currentStep,
    };

    // --- Ensure .claude/ directory exists ---
    const snapshotDir = path.dirname(SNAPSHOT_PATH);
    if (!fs.existsSync(snapshotDir)) {
      fs.mkdirSync(snapshotDir, { recursive: true });
    }

    // --- Write snapshot ---
    fs.writeFileSync(SNAPSHOT_PATH, JSON.stringify(snapshot, null, 2));
    process.stderr.write(`📸 Context snapshot saved to ${SNAPSHOT_PATH}\n`);
  } catch (err) {
    // Fail-open: log error but don't block compaction
    process.stderr.write(`⚠️ pre-compact.js error: ${err.message}\n`);
  }

  process.exit(0);
});
