#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');

function hookKey(hook) {
  return `${hook.type || ''}\0${hook.command || ''}`;
}

function mergeGroups(baseGroups = [], customGroups = []) {
  const groups = [];
  for (const incoming of [...baseGroups, ...customGroups]) {
    const matcher = incoming.matcher ?? '';
    let group = groups.find(item => (item.matcher ?? '') === matcher);
    if (!group) {
      group = { ...incoming, hooks: [] };
      groups.push(group);
    }
    const seen = new Set(group.hooks.map(hookKey));
    for (const hook of incoming.hooks || []) {
      if (!seen.has(hookKey(hook))) {
        group.hooks.push(hook);
        seen.add(hookKey(hook));
      }
    }
  }
  return groups;
}

function mergeConfig(base, custom) {
  const result = { ...base, ...custom, hooks: {} };
  if (base.permissions || custom.permissions) {
    result.permissions = {
      ...(base.permissions || {}),
      ...(custom.permissions || {}),
      allow: [...new Set([...(base.permissions?.allow || []), ...(custom.permissions?.allow || [])])],
      deny: [...new Set([...(base.permissions?.deny || []), ...(custom.permissions?.deny || [])])],
    };
  }
  const events = new Set([...Object.keys(base.hooks || {}), ...Object.keys(custom.hooks || {})]);
  for (const event of events) {
    result.hooks[event] = mergeGroups(base.hooks?.[event], custom.hooks?.[event]);
  }
  return result;
}

function main() {
  const [targetPath, templatePath] = process.argv.slice(2);
  if (!targetPath || !templatePath) {
    process.stderr.write('Usage: merge-hook-config.js <target.json> <template.json>\n');
    return 64;
  }
  const base = JSON.parse(fs.readFileSync(templatePath, 'utf8'));
  const custom = fs.existsSync(targetPath)
    ? JSON.parse(fs.readFileSync(targetPath, 'utf8'))
    : {};
  const merged = mergeConfig(base, custom);
  fs.mkdirSync(path.dirname(targetPath), { recursive: true });
  const temporary = `${targetPath}.tmp-${process.pid}`;
  fs.writeFileSync(temporary, `${JSON.stringify(merged, null, 2)}\n`);
  fs.renameSync(temporary, targetPath);
  return 0;
}

if (require.main === module) process.exit(main());
module.exports = { mergeConfig, mergeGroups };
