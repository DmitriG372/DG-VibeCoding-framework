#!/usr/bin/env node
/**
 * Pre-tool-use hook: Block sensitive file access
 *
 * Prevents Claude from reading .env, credentials, secrets, keys.
 *
 * Usage in .claude/settings.local.json:
 * {
 *   "hooks": {
 *     "PreToolUse": [{
 *       "matcher": "Read|Grep",
 *       "hooks": [{
 *         "type": "command",
 *         "command": "node ./hooks/block-env.js"
 *       }]
 *     }]
 *   }
 * }
 *
 * Exit codes: 0 = allow, 2 = block
 * stderr output is sent to Claude as feedback
 */

const BLOCKED_PATTERNS = [
  '.env',
  'credentials',
  'secrets',
  '.pem',
  '.key',
  'private_key',
  'api_key',
  'password',
  '.secret'
];

let input = '';

process.stdin.on('data', chunk => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const filePath = (
      data.tool_input?.file_path ||
      data.tool_input?.path ||
      ''
    ).toLowerCase();

    const isBlocked = BLOCKED_PATTERNS.some(pattern =>
      filePath.includes(pattern.toLowerCase())
    );

    if (isBlocked) {
      console.error(`⛔ BLOCKED: "${filePath}" contains sensitive data.`);
      console.error(`   Add to .gitignore and use environment variables instead.`);
      process.exit(2); // Block the tool call
    }

    process.exit(0); // Allow the tool call
  } catch (error) {
    console.error(`Hook error: ${error.message}`);
    process.exit(0); // Allow on error (fail open)
  }
});
