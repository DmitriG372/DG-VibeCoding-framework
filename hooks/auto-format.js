#!/usr/bin/env node

const { execFileSync } = require('node:child_process');
const crypto = require('node:crypto');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { normalizeHookInput, resolveLocalNodeBinary } = require('./lib/hook-input');

const FORMAT_EXTENSIONS = /\.(js|jsx|ts|tsx|json|md|css|scss|html|yaml|yml|toml|vue|svelte)$/;
const DEBOUNCE_MS = 1500;

function recentlyProcessed(filePath) {
  const hash = crypto.createHash('sha256').update(filePath).digest('hex').slice(0, 20);
  const marker = path.join(os.tmpdir(), `dg-format-${hash}`);
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
    process.stderr.write(`[auto-format] Invalid hook payload: ${error.message}\n`);
    return process.exit(0);
  }

  const normalized = normalizeHookInput(payload);
  for (const filePath of normalized.filePaths) {
    if (!FORMAT_EXTENSIONS.test(filePath)) continue;
    const absolutePath = path.resolve(normalized.cwd, filePath);
    if (!fs.existsSync(absolutePath) || recentlyProcessed(absolutePath)) continue;

    const prettier = resolveLocalNodeBinary(normalized.cwd, 'prettier', fs.existsSync);
    if (!prettier) continue;
    try {
      execFileSync(prettier, ['--write', absolutePath], {
        cwd: normalized.cwd,
        stdio: ['ignore', 'ignore', 'pipe'],
        timeout: 15000,
      });
    } catch (error) {
      const message = error.stderr?.toString()?.trim() || error.message;
      process.stderr.write(`[auto-format] skipped ${filePath}: ${message}\n`);
    }
  }
  process.exit(0);
});
