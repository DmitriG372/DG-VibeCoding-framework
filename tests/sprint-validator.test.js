const test = require('node:test');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const { calculateStats, validateSprint } = require('../scripts/validate-sprint');

function feature(overrides = {}) {
  return {
    id: 'F001',
    name: 'Harden sprint contract',
    description: 'Make sprint state deterministic and validated.',
    acceptance_criteria: ['The sprint validator rejects malformed state.'],
    steps: [
      { id: 'S1', desc: 'Write tests', done: false },
      { id: 'S2', desc: 'Implement validator', done: false },
      { id: 'S3', desc: 'Update schema', done: false },
      { id: 'S4', desc: 'Update commands', done: false },
      { id: 'S5', desc: 'Run verification', done: false },
    ],
    corridor: { allowed: ['scripts/**', 'tests/**'], forbidden: ['.env*'] },
    trivial: false,
    complexity: 'medium',
    status: 'in_progress',
    assigned_to: 'cc',
    branch: 'cc/F001-harden-sprint',
    tested: false,
    notes: '',
    git: { hash: null, message: null, timestamp: null },
    completed_at: null,
    review: { score: null, verdict: null, reviewer: null },
    ...overrides,
  };
}

function sprint(features = [feature()], overrides = {}) {
  return {
    $schema: '../templates/sprint.schema.json',
    schema_version: 'sprint-v3',
    sprint_id: 'S01',
    created: '2026-07-11T10:00:00Z',
    branch_strategy: 'worktree',
    base_branch: 'main',
    current_feature: features.find(item => item.status === 'in_progress')?.id || null,
    features,
    stats: calculateStats(features),
    last_updated: '2026-07-11T10:00:00Z',
    last_updated_by: 'cc',
    ...overrides,
  };
}

test('accepts a valid non-trivial sprint', () => {
  const result = validateSprint(sprint());
  assert.equal(result.valid, true, result.errors.join('\n'));
});

test('accepts a trivial feature without decomposition steps', () => {
  const item = feature({ trivial: true, complexity: 'trivial', steps: [] });
  const result = validateSprint(sprint([item]));
  assert.equal(result.valid, true, result.errors.join('\n'));
});

test('rejects duplicate feature IDs', () => {
  const result = validateSprint(sprint([feature(), feature({ name: 'Duplicate' })]));
  assert.ok(result.errors.some(error => error.includes('duplicate feature id F001')));
});

test('rejects non-trivial features with fewer than five steps', () => {
  const item = feature({ steps: [{ id: 'S1', desc: 'Only step', done: false }] });
  const result = validateSprint(sprint([item]));
  assert.ok(result.errors.some(error => error.includes('5-10 steps')));
});

test('rejects empty acceptance criteria', () => {
  const result = validateSprint(sprint([feature({ acceptance_criteria: [] })]));
  assert.ok(result.errors.some(error => error.includes('acceptance_criteria')));
});

test('rejects current_feature that does not identify the active feature', () => {
  const result = validateSprint(sprint([feature()], { current_feature: 'F999' }));
  assert.ok(result.errors.some(error => error.includes('current_feature')));
});

test('rejects multiple in-progress features', () => {
  const second = feature({ id: 'F002', name: 'Second active feature' });
  const result = validateSprint(sprint([feature(), second]));
  assert.ok(result.errors.some(error => error.includes('multiple in_progress')));
});

test('reports stale stats and returns normalized values', () => {
  const data = sprint([feature({ status: 'completed' })], {
    current_feature: null,
    stats: { total: 0, pending: 0, in_progress: 0, in_review: 0, completed: 0, blocked: 0 },
  });
  const result = validateSprint(data);
  assert.ok(result.errors.some(error => error.includes('stats do not match')));
  assert.deepEqual(result.normalizedStats, {
    total: 1,
    pending: 0,
    in_progress: 0,
    in_review: 0,
    completed: 1,
    blocked: 0,
  });
});

test('CLI --write-stats repairs stale stats before deciding validity', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'dg-sprint-cli-'));
  const filePath = path.join(directory, 'sprint.json');
  const data = sprint([feature({ status: 'completed' })], {
    current_feature: null,
    stats: { total: 0, pending: 0, in_progress: 0, in_review: 0, completed: 0, blocked: 0 },
  });
  fs.writeFileSync(filePath, JSON.stringify(data));
  const result = spawnSync(process.execPath, [
    path.resolve(__dirname, '../scripts/validate-sprint.js'),
    filePath,
    '--write-stats',
  ], { encoding: 'utf8' });
  fs.rmSync(directory, { recursive: true, force: true });
  assert.equal(result.status, 0, result.stderr);
});
