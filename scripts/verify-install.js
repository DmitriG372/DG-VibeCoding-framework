#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');

function walk(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry => {
    const full = path.join(dir, entry.name);
    return entry.isDirectory() ? walk(full) : [full];
  });
}

function verifyInstall(projectRoot) {
  const errors = [];
  const frameworkPath = path.join(projectRoot, 'framework.json');
  if (!fs.existsSync(frameworkPath)) return ['framework.json is missing'];
  const framework = JSON.parse(fs.readFileSync(frameworkPath, 'utf8'));

  for (const entry of framework.install?.entries || []) {
    const target = path.join(projectRoot, entry.to);
    if (!fs.existsSync(target)) errors.push(`missing installed artifact: ${entry.to}`);
  }

  for (const file of walk(path.join(projectRoot, '.claude', 'skills'))) {
    if (path.basename(file) !== 'SKILL.md') continue;
    const content = fs.readFileSync(file, 'utf8');
    for (const match of content.matchAll(/`(references\/[^`]+)`/g)) {
      const reference = path.resolve(path.dirname(file), match[1]);
      if (!fs.existsSync(reference)) errors.push(`missing skill reference: ${path.relative(projectRoot, reference)}`);
    }
  }

  for (const configRelative of ['.claude/settings.local.json', '.codex/hooks.json']) {
    const configPath = path.join(projectRoot, configRelative);
    if (!fs.existsSync(configPath)) continue;
    let config;
    try { config = JSON.parse(fs.readFileSync(configPath, 'utf8')); } catch (error) {
      errors.push(`${configRelative} is invalid JSON: ${error.message}`);
      continue;
    }
    for (const groups of Object.values(config.hooks || {})) {
      for (const group of groups) {
        for (const hook of group.hooks || []) {
          const match = /^node \.\/hooks\/(\S+)$/.exec(hook.command || '');
          if (match && !fs.existsSync(path.join(projectRoot, 'hooks', match[1]))) {
            errors.push(`${configRelative} references missing hook: hooks/${match[1]}`);
          }
        }
      }
    }
  }
  return errors;
}

if (require.main === module) {
  const projectRoot = path.resolve(process.argv[2] || '.');
  const errors = verifyInstall(projectRoot);
  if (errors.length) {
    for (const error of errors) process.stderr.write(`- ${error}\n`);
    process.exit(1);
  }
  process.stdout.write('install-valid\n');
}

module.exports = { verifyInstall };
