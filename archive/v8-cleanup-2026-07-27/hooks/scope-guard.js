#!/usr/bin/env node
// DG-VibeCoding v8.0 — Scope Guard
// PostToolUse hook on Edit|Write|MultiEdit.
// Hoiatab kui muudetud fail langeb aktiivse feature corridor.forbidden alla või on väljaspool corridor.allowed.
// Ei blokeeri (PostToolUse ei saa) — annab stderr-i kaudu mudelile feedbacki.
// Eesmärk: jõustada Operating Protocol Rule 4 — kirurgilised muudatused.

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

// Lihtne glob → regex (toetab * ja **). Pole täisväärtuslik minimatch, aga piisab corridor mustritele.
function globToRegex(glob) {
  let re = '';
  for (let i = 0; i < glob.length; i++) {
    const c = glob[i];
    if (c === '*' && glob[i + 1] === '*') { re += '.*'; i++; }
    else if (c === '*') { re += '[^/]*'; }
    else if (c === '?') { re += '[^/]'; }
    else if ('.+^$(){}[]|\\'.includes(c)) { re += '\\' + c; }
    else { re += c; }
  }
  return new RegExp('^' + re + '$');
}

function matchesAny(filePath, patterns) {
  return patterns.some((p) => globToRegex(p).test(filePath));
}

(async () => {
  try {
    const raw = await readStdin();
    if (!raw.trim()) return process.exit(0);

    const payload = JSON.parse(raw);
    const normalized = normalizeHookInput(payload);
    if (!normalized.isEdit) return process.exit(0);
    if (normalized.filePaths.length === 0) {
      process.stderr.write('[scope-guard] edit path unavailable; scope could not be checked\n');
      return process.exit(0);
    }

    const sprintPath = findSprintJson(normalized.cwd);
    if (!sprintPath) return process.exit(0);

    const sprint = JSON.parse(fs.readFileSync(sprintPath, 'utf8'));
    const features = Array.isArray(sprint.features) ? sprint.features : [];
    const active = sprint.current_feature
      ? features.find((f) => f.id === sprint.current_feature && f.status === 'in_progress')
      : features.find((f) => f.status === 'in_progress');
    if (!active || !active.corridor) return process.exit(0);

    const forbidden = Array.isArray(active.corridor.forbidden) ? active.corridor.forbidden : [];
    const allowed = Array.isArray(active.corridor.allowed) ? active.corridor.allowed : [];

    for (const filePath of normalized.filePaths) {
      const absolute = path.resolve(normalized.cwd, filePath);
      const rel = path.relative(normalized.cwd, absolute);
      if (forbidden.length && matchesAny(rel, forbidden)) {
        process.stderr.write(
          `[scope-guard] ⚠️ "${rel}" matches feature ${active.id} corridor.forbidden — ` +
          `Rule 4 (Surgical). Revert if not intentional.\n`
        );
      } else if (allowed.length && !matchesAny(rel, allowed)) {
        process.stderr.write(
          `[scope-guard] ⚠️ "${rel}" outside feature ${active.id} corridor.allowed [${allowed.join(', ')}] — ` +
          `Rule 4 (Surgical). Was this intentional?\n`
        );
      }
    }

    process.exit(0);
  } catch (err) {
    process.stderr.write(`[scope-guard] error: ${err.message}\n`);
    process.exit(0);
  }
})();
