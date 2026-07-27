#!/usr/bin/env node

/**
 * Validate the optional CC/CX coordination file (schema v4).
 *
 * The file exists only to say who is working on what, on which branch. It is
 * not a plan, not a spec, and never a precondition for writing code. Unknown
 * keys are ignored on purpose — a stricter contract only ever cost us working
 * days when a hand-edited file stopped validating.
 */

const fs = require('node:fs');

const STATUSES = ['planned', 'in_progress', 'in_review', 'done'];
const AGENTS = ['cc', 'cx'];

const isNonEmptyString = value => typeof value === 'string' && value.trim().length > 0;

function validateTask(task, index, errors) {
  const at = `tasks[${index}]`;
  if (!task || typeof task !== 'object' || Array.isArray(task)) {
    errors.push(`${at} must be an object`);
    return;
  }
  if (!isNonEmptyString(task.id)) errors.push(`${at}.id must be a non-empty string`);
  if (!isNonEmptyString(task.title)) errors.push(`${at}.title must be a non-empty string`);
  if (!AGENTS.includes(task.assigned_to)) errors.push(`${at}.assigned_to must be "cc" or "cx"`);
  if (!STATUSES.includes(task.status)) errors.push(`${at}.status must be one of ${STATUSES.join(', ')}`);
  if (!isNonEmptyString(task.branch)) errors.push(`${at}.branch must be a non-empty string`);
}

function validateSprint(sprint) {
  const errors = [];
  if (!sprint || typeof sprint !== 'object' || Array.isArray(sprint)) {
    return { valid: false, errors: ['sprint must be an object'] };
  }

  if (sprint.schema_version !== 4) errors.push('schema_version must be 4');
  if (!isNonEmptyString(sprint.base_branch)) errors.push('base_branch must be a non-empty string');

  const tasks = Array.isArray(sprint.tasks) ? sprint.tasks : [];
  if (!Array.isArray(sprint.tasks)) errors.push('tasks must be an array');
  tasks.forEach((task, index) => validateTask(task, index, errors));

  // Only well-formed ids take part: a malformed task has already been reported,
  // and `undefined === undefined` would otherwise invent a duplicate — or crash
  // on `task.id` when the task itself is null.
  const seen = new Set();
  for (const task of tasks) {
    const id = task && typeof task === 'object' ? task.id : undefined;
    if (!isNonEmptyString(id)) continue;
    if (seen.has(id)) errors.push(`duplicate task id ${id}`);
    seen.add(id);
  }

  return { valid: errors.length === 0, errors };
}

function main(argv) {
  const filePath = argv.slice(2).find(arg => !arg.startsWith('--'));
  if (!filePath) {
    process.stderr.write('Usage: validate-sprint.js <sprint.json>\n');
    return 64;
  }

  let sprint;
  try {
    sprint = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    process.stderr.write(`Invalid sprint JSON: ${error.message}\n`);
    return 1;
  }

  const result = validateSprint(sprint);
  if (!result.valid) {
    for (const error of result.errors) process.stderr.write(`- ${error}\n`);
    return 1;
  }

  process.stdout.write(`sprint-valid: ${sprint.tasks.length} task(s)\n`);
  return 0;
}

if (require.main === module) process.exit(main(process.argv));

module.exports = { validateSprint };
