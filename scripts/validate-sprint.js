#!/usr/bin/env node

const fs = require('node:fs');

const STATUSES = ['pending', 'in_progress', 'in_review', 'completed', 'blocked'];
const COMPLEXITIES = ['trivial', 'low', 'medium', 'high'];
const AGENTS = ['cc', 'cx', null];

function calculateStats(features) {
  const stats = {
    total: features.length,
    pending: 0,
    in_progress: 0,
    in_review: 0,
    completed: 0,
    blocked: 0,
  };

  for (const feature of features) {
    if (STATUSES.includes(feature.status)) stats[feature.status] += 1;
  }
  return stats;
}

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function validateFeature(feature, index, errors) {
  const prefix = `features[${index}]`;
  if (!feature || typeof feature !== 'object' || Array.isArray(feature)) {
    errors.push(`${prefix} must be an object`);
    return;
  }

  if (!/^F\d{3,}$/.test(feature.id || '')) errors.push(`${prefix}.id must match FNNN`);
  if (!isNonEmptyString(feature.name)) errors.push(`${prefix}.name must be non-empty`);
  if (!isNonEmptyString(feature.description)) errors.push(`${prefix}.description must be non-empty`);
  if (!Array.isArray(feature.acceptance_criteria) || feature.acceptance_criteria.length === 0 ||
      feature.acceptance_criteria.some(item => !isNonEmptyString(item))) {
    errors.push(`${prefix}.acceptance_criteria must contain non-empty criteria`);
  }
  if (!STATUSES.includes(feature.status)) errors.push(`${prefix}.status is invalid`);
  if (!COMPLEXITIES.includes(feature.complexity)) errors.push(`${prefix}.complexity is invalid`);
  if (!AGENTS.includes(feature.assigned_to)) errors.push(`${prefix}.assigned_to is invalid`);
  if (typeof feature.trivial !== 'boolean') errors.push(`${prefix}.trivial must be boolean`);
  if (typeof feature.tested !== 'boolean') errors.push(`${prefix}.tested must be boolean`);

  const steps = Array.isArray(feature.steps) ? feature.steps : [];
  if (!Array.isArray(feature.steps)) errors.push(`${prefix}.steps must be an array`);
  if (feature.trivial !== true && (steps.length < 5 || steps.length > 10)) {
    errors.push(`${prefix} must contain 5-10 steps unless trivial=true`);
  }

  const stepIds = new Set();
  for (const [stepIndex, step] of steps.entries()) {
    const stepPrefix = `${prefix}.steps[${stepIndex}]`;
    if (!step || typeof step !== 'object' || Array.isArray(step)) {
      errors.push(`${stepPrefix} must be an object`);
      continue;
    }
    if (!/^S\d+$/.test(step.id || '')) errors.push(`${stepPrefix}.id must match S<number>`);
    if (stepIds.has(step.id)) errors.push(`${prefix} has duplicate step id ${step.id}`);
    stepIds.add(step.id);
    if (!isNonEmptyString(step.desc)) errors.push(`${stepPrefix}.desc must be non-empty`);
    if (typeof step.done !== 'boolean') errors.push(`${stepPrefix}.done must be boolean`);
  }

  if (!feature.corridor || typeof feature.corridor !== 'object' ||
      !Array.isArray(feature.corridor.allowed) || !Array.isArray(feature.corridor.forbidden)) {
    errors.push(`${prefix}.corridor must define allowed and forbidden arrays`);
  } else {
    for (const key of ['allowed', 'forbidden']) {
      if (feature.corridor[key].some(pattern => !isNonEmptyString(pattern))) {
        errors.push(`${prefix}.corridor.${key} must contain non-empty patterns`);
      }
    }
  }
}

function validateSprint(sprint) {
  const errors = [];
  if (!sprint || typeof sprint !== 'object' || Array.isArray(sprint)) {
    return { valid: false, errors: ['sprint must be an object'], normalizedStats: calculateStats([]) };
  }

  if (sprint.schema_version !== 'sprint-v3') errors.push('schema_version must equal sprint-v3');
  if (!isNonEmptyString(sprint.$schema)) errors.push('$schema must reference the sprint schema');
  if (!/^S\d{2,}$/.test(sprint.sprint_id || '')) errors.push('sprint_id must match SNN');
  if (!['sequential', 'worktree'].includes(sprint.branch_strategy)) {
    errors.push('branch_strategy must be sequential or worktree');
  }
  if (!isNonEmptyString(sprint.base_branch)) errors.push('base_branch must be non-empty');

  const features = Array.isArray(sprint.features) ? sprint.features : [];
  if (!Array.isArray(sprint.features)) errors.push('features must be an array');
  features.forEach((feature, index) => validateFeature(feature, index, errors));

  const ids = new Set();
  for (const feature of features) {
    if (ids.has(feature.id)) errors.push(`duplicate feature id ${feature.id}`);
    ids.add(feature.id);
  }

  const active = features.filter(feature => feature.status === 'in_progress');
  if (active.length > 1) errors.push('multiple in_progress features are not allowed');
  if (active.length === 1 && sprint.current_feature !== active[0].id) {
    errors.push('current_feature must identify the in_progress feature');
  }
  if (active.length === 0 && sprint.current_feature !== null) {
    errors.push('current_feature must be null when no feature is in_progress');
  }
  if (sprint.current_feature !== null && !ids.has(sprint.current_feature)) {
    errors.push('current_feature must reference an existing feature');
  }

  const normalizedStats = calculateStats(features);
  const stats = sprint.stats || {};
  if (Object.keys(normalizedStats).some(key => stats[key] !== normalizedStats[key])) {
    errors.push('stats do not match feature statuses');
  }

  return { valid: errors.length === 0, errors, normalizedStats };
}

function main(argv) {
  const args = argv.slice(2);
  const writeStats = args.includes('--write-stats');
  const filePath = args.find(arg => arg !== '--write-stats');
  if (!filePath) {
    process.stderr.write('Usage: validate-sprint.js <sprint.json> [--write-stats]\n');
    return 64;
  }

  let sprint;
  try {
    sprint = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    process.stderr.write(`Invalid sprint JSON: ${error.message}\n`);
    return 1;
  }

  let result = validateSprint(sprint);
  if (writeStats) {
    sprint.stats = result.normalizedStats;
    fs.writeFileSync(filePath, `${JSON.stringify(sprint, null, 2)}\n`);
    result = validateSprint(sprint);
  }
  if (!result.valid) {
    for (const error of result.errors) process.stderr.write(`- ${error}\n`);
    return 1;
  }
  process.stdout.write(`sprint-valid: ${sprint.sprint_id} (${sprint.features.length} features)\n`);
  return 0;
}

if (require.main === module) process.exit(main(process.argv));

module.exports = { calculateStats, validateSprint };
