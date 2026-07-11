#!/usr/bin/env node

const fs = require('node:fs');
const { calculateStats, validateSprint } = require('./validate-sprint');

const DEFAULT_STEPS = [
  'Review current behavior and constraints',
  'Write or update a failing regression test',
  'Implement the smallest scoped change',
  'Run targeted verification',
  'Run the full relevant test suite',
];

function normalizeSteps(steps, trivial) {
  if (Array.isArray(steps) && steps.length > 0) {
    return steps.slice(0, 10).map((step, index) => {
      if (typeof step === 'string') return { id: `S${index + 1}`, desc: step, done: false };
      return {
        id: step.id || `S${index + 1}`,
        desc: step.desc || step.description || `Step ${index + 1}`,
        done: step.done === true || step.status === 'done',
      };
    });
  }
  if (trivial) return [];
  return DEFAULT_STEPS.map((desc, index) => ({ id: `S${index + 1}`, desc, done: false }));
}

function migrateSprint(input) {
  const features = Array.isArray(input.features) ? input.features.map((item, index) => {
    const trivial = item.trivial === true || item.complexity === 'trivial';
    const status = item.status === 'done' ? 'completed' : item.status || 'pending';
    return {
      id: item.id || `F${String(index + 1).padStart(3, '0')}`,
      name: item.name || `Migrated feature ${index + 1}`,
      description: item.description || item.name || `Migrated feature ${index + 1}`,
      acceptance_criteria: Array.isArray(item.acceptance_criteria) && item.acceptance_criteria.length
        ? item.acceptance_criteria
        : ['Preserve the documented legacy behavior.'],
      steps: normalizeSteps(item.steps, trivial),
      corridor: {
        allowed: Array.isArray(item.corridor?.allowed) && item.corridor.allowed.length
          ? item.corridor.allowed
          : ['**'],
        forbidden: Array.isArray(item.corridor?.forbidden) && item.corridor.forbidden.length
          ? item.corridor.forbidden
          : ['.env*', 'secrets/**'],
      },
      trivial,
      complexity: item.complexity || (trivial ? 'trivial' : 'medium'),
      status,
      assigned_to: item.assigned_to ?? null,
      branch: item.branch ?? null,
      tested: item.tested === true,
      notes: item.notes || '',
      git: {
        hash: item.git?.hash ?? null,
        message: item.git?.message ?? null,
        timestamp: item.git?.timestamp ?? null,
      },
      completed_at: item.completed_at ?? null,
      review: {
        score: item.review?.score ?? null,
        verdict: item.review?.verdict ?? null,
        reviewer: item.review?.reviewer ?? null,
      },
    };
  }) : [];

  const active = features.filter(item => item.status === 'in_progress');
  const current = active.length === 1 ? active[0].id : null;
  const migrated = {
    $schema: '../templates/sprint.schema.json',
    schema_version: 'sprint-v3',
    sprint_id: input.sprint_id || 'S01',
    created: input.created || '',
    branch_strategy: input.branch_strategy === 'worktree' ? 'worktree' : 'sequential',
    base_branch: input.base_branch || 'main',
    current_feature: current,
    features,
    stats: calculateStats(features),
    last_updated: input.last_updated || new Date().toISOString(),
    last_updated_by: input.last_updated_by ?? null,
  };
  const result = validateSprint(migrated);
  if (!result.valid) throw new Error(result.errors.join('; '));
  return migrated;
}

if (require.main === module) {
  const [inputPath, outputPath] = process.argv.slice(2);
  if (!inputPath || !outputPath) {
    process.stderr.write('Usage: migrate-sprint-v3.js <input.json> <output.json>\n');
    process.exit(64);
  }
  try {
    const input = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
    fs.writeFileSync(outputPath, `${JSON.stringify(migrateSprint(input), null, 2)}\n`);
  } catch (error) {
    process.stderr.write(`migrate-sprint-v3: ${error.message}\n`);
    process.exit(1);
  }
}

module.exports = { migrateSprint, normalizeSteps };
