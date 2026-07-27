const test = require('node:test');
const assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const { validateSprint } = require('../scripts/validate-sprint');

function task(overrides = {}) {
  return {
    id: 'T1',
    title: 'Add attachment registry',
    assigned_to: 'cx',
    status: 'in_progress',
    branch: 'cx/t1-attachment-registry',
    ...overrides,
  };
}

function sprint(tasks = [task()], overrides = {}) {
  return {
    schema_version: 4,
    base_branch: 'dev',
    updated: '2026-07-27T10:00:00Z',
    tasks,
    ...overrides,
  };
}

test('accepts a minimal coordination file', () => {
  const result = validateSprint(sprint());
  assert.equal(result.valid, true, result.errors.join('\n'));
});

test('accepts an empty task list', () => {
  const result = validateSprint(sprint([]));
  assert.equal(result.valid, true, result.errors.join('\n'));
});

test('ignores unknown keys instead of failing the file', () => {
  const result = validateSprint(sprint([task({ notes: 'free text' })], { north_star: 'ship it' }));
  assert.equal(result.valid, true, result.errors.join('\n'));
});

test('rejects the v3 schema version', () => {
  const result = validateSprint(sprint([], { schema_version: 'sprint-v3' }));
  assert.ok(result.errors.some(error => error.includes('schema_version must be 4')));
});

test('rejects uppercase assigned_to', () => {
  const result = validateSprint(sprint([task({ assigned_to: 'CX' })]));
  assert.ok(result.errors.some(error => error.includes('assigned_to')));
});

test('rejects a status outside the four allowed values', () => {
  const result = validateSprint(sprint([task({ status: 'completed' })]));
  assert.ok(result.errors.some(error => error.includes('status')));
});

test('accepts every documented status and both agents', () => {
  // Without this, renaming a single enum member — say in_review → review —
  // passes the whole suite while breaking every real coordination file.
  for (const status of ['planned', 'in_progress', 'in_review', 'done']) {
    const result = validateSprint(sprint([task({ status })]));
    assert.equal(result.valid, true, `status "${status}" must be valid: ${result.errors.join(', ')}`);
  }
  for (const assigned_to of ['cc', 'cx']) {
    const result = validateSprint(sprint([task({ assigned_to })]));
    assert.equal(result.valid, true, `assigned_to "${assigned_to}" must be valid`);
  }
});

test('the validator and the published schema agree on every enum', () => {
  const schema = JSON.parse(
    fs.readFileSync(path.resolve(__dirname, '../templates/sprint.schema.json'), 'utf8')
  );
  const taskProps = schema.properties.tasks.items.properties;

  for (const status of taskProps.status.enum) {
    assert.equal(validateSprint(sprint([task({ status })])).valid, true,
      `schema allows status "${status}" but the validator rejects it`);
  }
  for (const agent of taskProps.assigned_to.enum) {
    assert.equal(validateSprint(sprint([task({ assigned_to: agent })])).valid, true,
      `schema allows assigned_to "${agent}" but the validator rejects it`);
  }
  assert.equal(schema.properties.schema_version.const, 4);
  assert.deepEqual(
    [...schema.properties.tasks.items.required].sort(),
    ['assigned_to', 'branch', 'id', 'status', 'title']
  );
});

test('reports malformed tasks without crashing or inventing a duplicate', () => {
  for (const tasks of [[null, null], [{}, {}], [1, 2], [undefined, undefined]]) {
    const result = validateSprint(sprint(tasks));
    assert.equal(result.valid, false);
    assert.ok(!result.errors.some(error => error.includes('duplicate')),
      `malformed tasks must not report a duplicate id: ${result.errors.join(', ')}`);
  }
});

test('rejects duplicate task ids', () => {
  const result = validateSprint(sprint([task(), task({ title: 'Duplicate' })]));
  assert.ok(result.errors.some(error => error.includes('duplicate task id T1')));
});

test('allows two agents to be in progress at the same time', () => {
  const parallel = [task(), task({ id: 'T2', assigned_to: 'cc', branch: 'cc/t2-search' })];
  const result = validateSprint(sprint(parallel));
  assert.equal(result.valid, true, result.errors.join('\n'));
});

test('CLI exits 0 on a valid file and 1 on an invalid one', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'dg-sprint-cli-'));
  const validator = path.resolve(__dirname, '../scripts/validate-sprint.js');
  const run = data => {
    const filePath = path.join(directory, 'sprint.json');
    fs.writeFileSync(filePath, JSON.stringify(data));
    return spawnSync(process.execPath, [validator, filePath], { encoding: 'utf8' });
  };

  assert.equal(run(sprint()).status, 0);
  assert.equal(run(sprint([task({ assigned_to: 'CX' })])).status, 1);

  fs.rmSync(directory, { recursive: true, force: true });
});
