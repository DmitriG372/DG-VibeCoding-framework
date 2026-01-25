#!/usr/bin/env node
/**
 * Post-tool-use hook: TypeScript Type Checker
 *
 * Runs tsc --noEmit after TypeScript file edits.
 * Feeds type errors back to Claude for automatic fixing.
 *
 * Usage in .claude/settings.local.json:
 * {
 *   "hooks": {
 *     "PostToolUse": [{
 *       "matcher": "Edit",
 *       "hooks": [{
 *         "type": "command",
 *         "command": "node ./hooks/type-check.js"
 *       }]
 *     }]
 *   }
 * }
 *
 * Exit codes: 0 = success (always, post-tool can't block)
 * stderr output is sent to Claude as feedback
 */

const { execSync } = require('child_process');

let input = '';

process.stdin.on('data', chunk => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const filePath = data.tool_input?.file_path || '';

    // Only check TypeScript/TSX files
    if (!filePath.match(/\.(ts|tsx)$/)) {
      process.exit(0);
    }

    try {
      execSync('npx tsc --noEmit', {
        stdio: ['ignore', 'pipe', 'pipe'],
        timeout: 30000,
        encoding: 'utf-8'
      });

      console.error('✅ TypeScript: No errors');
      process.exit(0);

    } catch (tscError) {
      const output = tscError.stdout || tscError.stderr || '';

      if (output.includes('error TS')) {
        console.error(`\n⚠️ TypeScript errors detected after editing ${filePath}:\n`);
        console.error(output);
        console.error(`\n💡 Please fix these type errors.`);
      }

      process.exit(0); // Don't block, just inform
    }

  } catch (error) {
    console.error(`Hook error: ${error.message}`);
    process.exit(0);
  }
});
