#!/usr/bin/env node
// DG-VibeCoding v8.0 — Decomposition Guard
// PreToolUse hook on Edit|Write|MultiEdit.
// Blokeerib editi kui aktiivne feature (status=in_progress) ei sisalda steps ja pole märgistatud trivial:true.
// Eesmärk: jõustada Operating Protocol Rule 1 — dekomponeeri enne tegutsemist.

const fs = require('fs');
const path = require('path');
const { normalizeHookInput } = require('./lib/hook-input');

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (c) => (data += c));
    process.stdin.on('end', () => resolve(data));
  });
}

function findSprintJson(cwd) {
  const candidates = [
    path.resolve(cwd, 'sprint/sprint.json'),
    path.resolve(cwd, '.claude/sprint/sprint.json'),
  ];
  return candidates.find((p) => fs.existsSync(p));
}

(async () => {
  try {
    const raw = await readStdin();
    if (!raw.trim()) return process.exit(0);

    const payload = JSON.parse(raw);
    const normalized = normalizeHookInput(payload);
    if (!normalized.isEdit) return process.exit(0);

    const sprintPath = findSprintJson(normalized.cwd);
    if (!sprintPath) return process.exit(0); // sprint pole projektis — skip vaikselt

    const sprint = JSON.parse(fs.readFileSync(sprintPath, 'utf8'));
    const features = Array.isArray(sprint.features) ? sprint.features : [];
    const activeFeatures = features.filter((f) => f.status === 'in_progress');
    if (activeFeatures.length > 1) {
      process.stderr.write('[decomposition-guard] multiple in_progress features; fix sprint state first\n');
      return process.exit(2);
    }
    const active = sprint.current_feature
      ? features.find((f) => f.id === sprint.current_feature && f.status === 'in_progress')
      : activeFeatures[0];
    if (!active) return process.exit(0); // pole aktiivset feature't — luba

    if (active.trivial === true) return process.exit(0);

    const steps = Array.isArray(active.steps) ? active.steps : [];
    if (steps.length >= 5) return process.exit(0); // ≥5 sammu = piisav dekompositsioon

    // Bloki edit
    const fileBeingEdited = normalized.filePaths.join(', ') || '<patch>';
    const reason =
      `Decomposition guard: feature ${active.id || '<no-id>'} "${active.name || ''}" ` +
      `has ${steps.length} steps (need ≥5). Add steps to sprint.json or set trivial:true. ` +
      `Blocked: ${normalized.toolName} on ${fileBeingEdited}. See OPERATING PROTOCOL Rule 1.`;

    const output = {
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason: reason,
      },
    };
    process.stdout.write(JSON.stringify(output));
    process.exit(0);
  } catch (err) {
    // Hook fail-open — ära kunagi blokeeri vaikse vea pärast
    process.stderr.write(`[decomposition-guard] error: ${err.message}\n`);
    process.exit(0);
  }
})();
