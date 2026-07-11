#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');

function copyEntry(sourceRoot, targetRoot, entry) {
  const source = path.join(sourceRoot, entry.from);
  const target = path.join(targetRoot, entry.to);
  if (!fs.existsSync(source)) throw new Error(`framework source missing: ${entry.from}`);
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.cpSync(source, target, { recursive: true, force: true });
  if (entry.executable) fs.chmodSync(target, 0o755);
}

function installFramework(sourceRoot, targetRoot) {
  const manifest = JSON.parse(fs.readFileSync(path.join(sourceRoot, 'framework.json'), 'utf8'));
  for (const entry of manifest.install.entries) copyEntry(sourceRoot, targetRoot, entry);
}

if (require.main === module) {
  const [sourceRoot, targetRoot] = process.argv.slice(2);
  if (!sourceRoot || !targetRoot) {
    process.stderr.write('Usage: install-framework.js <framework-root> <project-root>\n');
    process.exit(64);
  }
  try {
    installFramework(path.resolve(sourceRoot), path.resolve(targetRoot));
  } catch (error) {
    process.stderr.write(`install-framework: ${error.message}\n`);
    process.exit(1);
  }
}

module.exports = { copyEntry, installFramework };
