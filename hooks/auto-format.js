#!/usr/bin/env node
// DG-VibeCoding-Framework v5.1.0 — Auto Format Hook
// PostToolUse hook: best-effort formatting for common text/code files.

const { execSync } = require('child_process');
const fs = require('fs');

function readJsonFromStdin(callback) {
  let input = '';
  process.stdin.on('data', chunk => {
    input += chunk;
  });
  process.stdin.on('end', () => {
    try {
      callback(input ? JSON.parse(input) : {});
    } catch (error) {
      process.stderr.write(`[auto-format] Invalid hook payload: ${error.message}\n`);
      process.exit(0);
    }
  });
}

function shouldFormat(filePath) {
  return /\.(js|jsx|ts|tsx|json|md|css|scss|html|yaml|yml|toml|vue|svelte)$/.test(filePath);
}

function resolveFormatter() {
  if (!fs.existsSync('package.json')) {
    return null;
  }

  try {
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    const hasPrettier =
      (pkg.devDependencies && pkg.devDependencies.prettier) ||
      (pkg.dependencies && pkg.dependencies.prettier);

    if (hasPrettier) {
      return filePath => `npx prettier --write "${filePath}"`;
    }
  } catch {
    return null;
  }

  return null;
}

readJsonFromStdin(data => {
  const filePath = data.tool_input?.file_path || '';

  if (!filePath || !shouldFormat(filePath) || !fs.existsSync(filePath)) {
    process.exit(0);
  }

  const formatter = resolveFormatter();
  if (!formatter) {
    process.exit(0);
  }

  try {
    execSync(formatter(filePath), {
      stdio: ['ignore', 'ignore', 'pipe'],
      timeout: 15000,
    });
  } catch (error) {
    const stderr = error.stderr?.toString()?.trim();
    if (stderr) {
      process.stderr.write(`⚠️ auto-format skipped for ${filePath}\n${stderr}\n`);
    }
  }

  process.exit(0);
});
