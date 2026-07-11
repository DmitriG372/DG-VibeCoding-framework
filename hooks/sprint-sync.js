#!/usr/bin/env node
// DG-VibeCoding-Framework — Sprint Sync Hook
// PostToolUse hook: regenerates sprint/sprint.md after Write|Edit on sprint.json.
// Never blocks (exit 0 always).

const fs = require('fs');
const path = require('path');
const { escapeMarkdownCell, normalizeHookInput } = require('./lib/hook-input');

function readFileSafe(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch { return ''; }
}

function progressBar(completed, total, width = 20) {
  if (total === 0) return '[' + '░'.repeat(width) + '] 0%';
  const ratio = Math.max(0, Math.min(1, completed / total));
  const filled = Math.round(ratio * width);
  const empty = width - filled;
  const pct = Math.round(ratio * 100);
  return '[' + '█'.repeat(filled) + '░'.repeat(empty) + '] ' + pct + '%';
}

function statusIcon(status) {
  const icons = {
    pending: '⬚',
    in_progress: '▶',
    in_review: '⏳',
    done: '✓',
    completed: '✓',
  };
  return icons[status] || '?';
}

function generateSprintMd(sprint) {
  const lines = [];
  const features = Array.isArray(sprint.features) ? sprint.features : [];
  const stats = {
    total: features.length,
    pending: features.filter(f => f.status === 'pending').length,
    in_progress: features.filter(f => f.status === 'in_progress').length,
    in_review: features.filter(f => f.status === 'in_review').length,
    completed: features.filter(f => f.status === 'completed').length,
    blocked: features.filter(f => f.status === 'blocked').length,
  };
  const total = stats.total;
  const completed = stats.completed;

  lines.push(`# Sprint ${sprint.sprint_id}`);
  lines.push('');
  lines.push(`> Auto-generated from sprint.json — do not edit manually.`);
  lines.push('');
  lines.push(`**Created:** ${sprint.created || 'N/A'}`);
  lines.push(`**Branch Strategy:** ${sprint.branch_strategy || 'main'}`);
  lines.push(`**Base Branch:** ${sprint.base_branch || 'main'}`);
  if (sprint.current_feature) {
    lines.push(`**Current Feature:** ${sprint.current_feature}`);
  }
  lines.push('');

  // Progress bar
  lines.push(`## Progress`);
  lines.push('');
  lines.push(`${progressBar(completed, total)} (${completed}/${total})`);
  lines.push('');

  // Stats
  if (stats.pending > 0 || stats.in_progress > 0 || stats.in_review > 0) {
    const parts = [];
    if (stats.pending > 0) parts.push(`${stats.pending} pending`);
    if (stats.in_progress > 0) parts.push(`${stats.in_progress} in progress`);
    if (stats.in_review > 0) parts.push(`${stats.in_review} in review`);
    if (stats.completed > 0) parts.push(`${stats.completed} completed`);
    lines.push(parts.join(' | '));
    lines.push('');
  }

  // Feature table
  lines.push('## Features');
  lines.push('');
  lines.push('| ID | Name | Status | Assigned | Branch | Tested | Commit |');
  lines.push('|----|------|--------|----------|--------|--------|--------|');

  for (const f of features) {
    const icon = statusIcon(f.status);
    const assigned = f.assigned_to || '—';
    const branch = f.branch || '—';
    const tested = f.tested ? '✓' : '—';
    const commit = f.git && f.git.hash ? f.git.hash.substring(0, 7) : '—';
    const review = f.review && f.review.verdict ? ` (${f.review.verdict})` : '';
    lines.push(`| ${escapeMarkdownCell(f.id)} | ${escapeMarkdownCell(f.name)} | ${icon} ${escapeMarkdownCell(f.status)}${escapeMarkdownCell(review)} | ${escapeMarkdownCell(assigned)} | ${escapeMarkdownCell(branch)} | ${tested} | ${escapeMarkdownCell(commit)} |`);
  }

  lines.push('');

  // Activity log — show completed features with timestamps
  const completedFeatures = features.filter(f => f.completed_at);
  if (completedFeatures.length > 0) {
    lines.push('## Activity Log');
    lines.push('');
    lines.push('| Time | Feature | Agent | Commit |');
    lines.push('|------|---------|-------|--------|');
    for (const f of completedFeatures) {
      const agent = f.assigned_to || '—';
      const commit = f.git && f.git.hash ? f.git.hash.substring(0, 7) : '—';
      lines.push(`| ${f.completed_at} | ${f.id} ${f.name} | ${agent} | ${commit} |`);
    }
    lines.push('');
  }

  // Last updated
  if (sprint.last_updated) {
    lines.push('---');
    lines.push('');
    lines.push(`*Last updated: ${sprint.last_updated} by ${sprint.last_updated_by || 'unknown'}*`);
  }

  lines.push('');
  return lines.join('\n');
}

// --- Main ---
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = input ? JSON.parse(input) : {};
    const normalized = normalizeHookInput(data);
    const filePath = normalized.filePaths.find(candidate => /(^|\/)sprint\/sprint\.json$/.test(candidate)) || '';

    // Only trigger on sprint.json files
    if (!filePath) {
      process.exit(0);
    }

    // Read sprint.json
    const absolutePath = path.resolve(normalized.cwd, filePath);
    if (!fs.existsSync(absolutePath)) {
      process.exit(0);
    }

    const sprintContent = readFileSafe(absolutePath);
    if (!sprintContent) {
      process.exit(0);
    }

    let sprint;
    try {
      sprint = JSON.parse(sprintContent);
    } catch (e) {
      process.stderr.write(`⚠️ sprint-sync.js: invalid JSON in ${absolutePath}\n`);
      process.exit(0);
    }

    // Generate sprint.md
    const sprintMd = generateSprintMd(sprint);

    // Write to sprint/sprint.md (same directory as sprint.json)
    const sprintDir = path.dirname(absolutePath);
    const mdPath = path.join(sprintDir, 'sprint.md');
    fs.writeFileSync(mdPath, sprintMd);

    process.stderr.write(`🔄 sprint.md regenerated from sprint.json\n`);
  } catch (err) {
    process.stderr.write(`⚠️ sprint-sync.js error: ${err.message}\n`);
  }

  // Always exit 0 — never block
  process.exit(0);
});
