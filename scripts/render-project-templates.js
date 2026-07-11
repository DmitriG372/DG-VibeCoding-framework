#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');

function replaceIfPresent(filePath, replacements) {
  if (!fs.existsSync(filePath)) return;
  let content = fs.readFileSync(filePath, 'utf8');
  for (const [token, value] of Object.entries(replacements)) {
    content = content.split(`{{${token}}}`).join(value);
  }
  fs.writeFileSync(filePath, content);
}

const projectRoot = path.resolve(process.argv[2] || '.');
const replacements = {
  PROJECT_NAME: path.basename(projectRoot),
  STATUS: 'initialized',
  TIMESTAMP: new Date().toISOString(),
};
replaceIfPresent(path.join(projectRoot, 'manifest.md'), replacements);
replaceIfPresent(path.join(projectRoot, '.claude', 'SNAPSHOT.md'), replacements);
