#!/usr/bin/env node
// DG-VibeCoding-Framework — Type Check Hook
// PostToolUse hook: runs a non-blocking TypeScript check after TS edits.

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
      process.stderr.write(`[type-check] Invalid hook payload: ${error.message}\n`);
      process.exit(0);
    }
  });
}

function findTypecheckCommand() {
  if (fs.existsSync('package.json')) {
    try {
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      if (pkg.scripts && pkg.scripts.typecheck) {
        return 'npm run typecheck';
      }
    } catch {
      // Ignore malformed package.json here; the project itself can surface that separately.
    }
  }

  if (fs.existsSync('tsconfig.json')) {
    return 'npx tsc --noEmit';
  }

  return null;
}

readJsonFromStdin(data => {
  const filePath = data.tool_input?.file_path || '';

  if (!/\.(ts|tsx|mts|cts)$/.test(filePath)) {
    process.exit(0);
  }

  const command = findTypecheckCommand();
  if (!command) {
    process.exit(0);
  }

  try {
    execSync(command, {
      stdio: ['ignore', 'pipe', 'pipe'],
      timeout: 30000,
    });
  } catch (error) {
    const stderr = error.stderr?.toString() || '';
    const stdout = error.stdout?.toString() || '';
    const message = (stderr || stdout || error.message).trim();

    if (message) {
      process.stderr.write(`⚠️ type-check failed after editing ${filePath}\n${message}\n`);
    }
  }

  process.exit(0);
});
