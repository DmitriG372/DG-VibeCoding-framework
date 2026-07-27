#!/usr/bin/env node
/**
 * PreToolUse hook (Read|Grep): block access to secret-bearing files.
 *
 * Matching is anchored to the basename and to whole path segments. A substring
 * match would block ordinary source files such as `src/auth/password-reset.ts`
 * or `docs/api_key_rotation.md`, which carry no secrets.
 *
 * Exit codes: 0 = allow, 2 = block. stderr is fed back to the agent.
 */

// Directory names that hold secrets, matched as whole path segments.
const BLOCKED_DIRS = new Set(['secrets', '.secrets', '.ssh', '.gnupg']);

// File extensions that are private key material.
const BLOCKED_EXTENSIONS = /\.(pem|key|p12|pfx|jks|keystore)$/;

// Basenames that are secret files. `.env.example` and friends stay readable —
// they are templates and are the normal way to learn what a project needs.
const BLOCKED_BASENAMES = [
  /^\.env(\.|$)(?!example|template|sample|dist)/,
  /^credentials(\.(json|ya?ml|ini|toml))?$/,
  /^id_(rsa|dsa|ecdsa|ed25519)$/,
  /^\.npmrc$/,
  /^\.pgpass$/,
  /^\.netrc$/,
  /^service[-_]account.*\.json$/,
];

function isBlocked(rawPath) {
  const filePath = String(rawPath).replace(/\\/g, '/');
  const segments = filePath.split('/').filter(Boolean);
  const basename = (segments[segments.length - 1] || '').toLowerCase();

  if (segments.slice(0, -1).some(segment => BLOCKED_DIRS.has(segment.toLowerCase()))) return true;
  if (BLOCKED_EXTENSIONS.test(basename)) return true;
  return BLOCKED_BASENAMES.some(pattern => pattern.test(basename));
}

function main() {
  let input = '';
  process.stdin.on('data', chunk => { input += chunk; });

  process.stdin.on('end', () => {
    try {
      const data = JSON.parse(input);
      const filePath = data.tool_input?.file_path || data.tool_input?.path || '';

      if (filePath && isBlocked(filePath)) {
        console.error(`BLOCKED: "${filePath}" holds credentials or key material.`);
        console.error('Read the values from the environment instead, or ask the user.');
        process.exit(2);
      }

      process.exit(0);
    } catch (error) {
      console.error(`block-env hook error: ${error.message}`);
      process.exit(0); // fail open — a broken hook must not stop work
    }
  });
}

if (require.main === module) main();

module.exports = { isBlocked };
