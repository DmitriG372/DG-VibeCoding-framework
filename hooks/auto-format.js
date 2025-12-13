#!/usr/bin/env node
/**
 * Post-tool-use hook: Auto-format files
 *
 * Runs Prettier on edited JS/TS files.
 *
 * Usage in .claude/settings.local.json:
 * {
 *   "hooks": {
 *     "PostToolUse": [{
 *       "matcher": "Edit",
 *       "hooks": [{
 *         "type": "command",
 *         "command": "node ./hooks/auto-format.js"
 *       }]
 *     }]
 *   }
 * }
 *
 * Exit codes: 0 = success (always, post-tool can't block)
 * stderr output is sent to Claude as feedback
 */

const { execSync } = require('child_process');

const FORMATTABLE_EXTENSIONS = /\.(js|jsx|ts|tsx|json|css|scss|md)$/;

let input = '';

process.stdin.on('data', chunk => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const filePath = data.tool_input?.file_path || '';

    // Only format supported file types
    if (!filePath.match(FORMATTABLE_EXTENSIONS)) {
      process.exit(0);
    }

    try {
      execSync(`npx prettier --write "${filePath}"`, {
        stdio: 'ignore',
        timeout: 10000
      });
      console.error(`✨ Formatted: ${filePath}`);
    } catch (error) {
      // Prettier not installed or file not formattable - ignore
    }

    process.exit(0);

  } catch (error) {
    console.error(`Hook error: ${error.message}`);
    process.exit(0);
  }
});
