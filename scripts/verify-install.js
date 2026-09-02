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
  const warnings = [];
  const frameworkPath = path.join(projectRoot, 'framework.json');
  if (!fs.existsSync(frameworkPath)) return { errors: ['framework.json is missing'], warnings };
  const framework = JSON.parse(fs.readFileSync(frameworkPath, 'utf8'));

  // `local: true` entries are seeded once by the installer and then gitignored
  // (.claude/settings.local.json, manifest.md). A fresh clone or a new worktree
  // legitimately has neither, so their absence is a warning to act on, not a
  // failed install — otherwise every clone reports the same two false errors and
  // the check stops being read.
  for (const entry of framework.install?.entries || []) {
    const target = path.join(projectRoot, entry.to);
    if (fs.existsSync(target)) continue;
    if (entry.local) warnings.push(`local artifact not seeded here: ${entry.to}`);
    else errors.push(`missing installed artifact: ${entry.to}`);
  }

  // Codex reads .agents/skills, Claude Code reads .claude/skills; a project
  // normally links one to the other, so dedupe by real path.
  const skillFiles = new Set();
  for (const root of [['.agents', 'skills'], ['.claude', 'skills']]) {
    for (const file of walk(path.join(projectRoot, ...root))) {
      if (path.basename(file) === 'SKILL.md') skillFiles.add(fs.realpathSync(file));
    }
  }
  for (const file of skillFiles) {
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
  return { errors, warnings };
}

if (require.main === module) {
  const projectRoot = path.resolve(process.argv[2] || '.');
  const { errors, warnings } = verifyInstall(projectRoot);
  for (const warning of warnings) process.stderr.write(`! ${warning}\n`);
  if (errors.length) {
    for (const error of errors) process.stderr.write(`- ${error}\n`);
    process.exit(1);
  }
  process.stdout.write('install-valid\n');
}

module.exports = { verifyInstall };
