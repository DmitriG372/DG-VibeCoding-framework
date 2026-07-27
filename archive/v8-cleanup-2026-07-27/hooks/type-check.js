#!/usr/bin/env node

const { execFileSync } = require('node:child_process');
const crypto = require('node:crypto');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { normalizeHookInput, resolveLocalNodeBinary } = require('./lib/hook-input');

const DEBOUNCE_MS = 5000;

function resolveTypecheck(cwd) {
  const packagePath = path.join(cwd, 'package.json');
  if (fs.existsSync(packagePath)) {
    try {
      const pkg = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
      if (pkg.scripts?.typecheck) {
        if (fs.existsSync(path.join(cwd, 'pnpm-lock.yaml'))) return { command: 'pnpm', args: ['run', 'typecheck'] };
        if (fs.existsSync(path.join(cwd, 'yarn.lock'))) return { command: 'yarn', args: ['typecheck'] };
        return { command: 'npm', args: ['run', 'typecheck'] };
      }
    } catch { return null; }
  }
  if (fs.existsSync(path.join(cwd, 'tsconfig.json'))) {
    const tsc = resolveLocalNodeBinary(cwd, 'tsc', fs.existsSync);
    if (tsc) return { command: tsc, args: ['--noEmit'] };
  }
  return null;
}

function debounced(cwd) {
  const hash = crypto.createHash('sha256').update(cwd).digest('hex').slice(0, 20);
  const marker = path.join(os.tmpdir(), `dg-typecheck-${hash}`);
  try {
    const age = Date.now() - Number(fs.readFileSync(marker, 'utf8'));
    if (age >= 0 && age < DEBOUNCE_MS) return true;
  } catch { /* first run */ }
  try { fs.writeFileSync(marker, String(Date.now())); } catch { /* non-fatal */ }
  return false;
}

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  let payload;
  try { payload = JSON.parse(input || '{}'); } catch (error) {
    process.stderr.write(`[type-check] Invalid hook payload: ${error.message}\n`);
    return process.exit(0);
  }
  const normalized = normalizeHookInput(payload);
  if (!normalized.filePaths.some(filePath => /\.(ts|tsx|mts|cts)$/.test(filePath))) return process.exit(0);
  if (debounced(normalized.cwd)) return process.exit(0);
  const invocation = resolveTypecheck(normalized.cwd);
  if (!invocation) return process.exit(0);

  try {
    execFileSync(invocation.command, invocation.args, {
      cwd: normalized.cwd,
      stdio: ['ignore', 'pipe', 'pipe'],
      timeout: 30000,
    });
  } catch (error) {
    const message = (error.stderr?.toString() || error.stdout?.toString() || error.message).trim();
    process.stderr.write(`[type-check] failed: ${message}\n`);
  }
  process.exit(0);
});
