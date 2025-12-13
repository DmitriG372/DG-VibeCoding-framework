#!/usr/bin/env node
/**
 * Post-tool-use hook: Track skill and command usage
 *
 * Logs which skills, slash commands, and Task tool agents are used.
 * Helps verify framework components are being invoked.
 *
 * Usage in .claude/settings.local.json:
 * {
 *   "hooks": {
 *     "PostToolUse": [{
 *       "matcher": "Skill|SlashCommand|Task",
 *       "hooks": [{
 *         "type": "command",
 *         "command": "node ./hooks/usage-tracker.js"
 *       }]
 *     }]
 *   }
 * }
 *
 * View log: cat .claude/usage.log
 * Clear log: rm .claude/usage.log
 *
 * Exit codes: 0 = success (always, post-tool can't block)
 */

const fs = require('fs');
const path = require('path');

const LOG_FILE = '.claude/usage.log';
const MAX_LOG_SIZE = 100 * 1024; // 100KB max

let input = '';

process.stdin.on('data', chunk => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const toolName = data.tool_name || 'unknown';
    const toolInput = data.tool_input || {};

    // Extract what was used
    let usage = '';
    const timestamp = new Date().toISOString();

    switch (toolName) {
      case 'Skill':
        usage = `SKILL: ${toolInput.skill || 'unknown'}`;
        break;
      case 'SlashCommand':
        usage = `COMMAND: ${toolInput.command || 'unknown'}`;
        break;
      case 'Task':
        const agentType = toolInput.subagent_type || 'general';
        const desc = toolInput.description || '';
        usage = `AGENT: ${agentType} (${desc})`;
        break;
      default:
        usage = `TOOL: ${toolName}`;
    }

    // Format log entry
    const logEntry = `${timestamp} | ${usage}\n`;

    // Ensure .claude directory exists
    const logDir = path.dirname(LOG_FILE);
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }

    // Rotate log if too large
    if (fs.existsSync(LOG_FILE)) {
      const stats = fs.statSync(LOG_FILE);
      if (stats.size > MAX_LOG_SIZE) {
        const backup = LOG_FILE + '.old';
        if (fs.existsSync(backup)) {
          fs.unlinkSync(backup);
        }
        fs.renameSync(LOG_FILE, backup);
      }
    }

    // Append to log
    fs.appendFileSync(LOG_FILE, logEntry);

    // Output for Claude to see
    console.error(`📊 Tracked: ${usage}`);

    process.exit(0);

  } catch (error) {
    console.error(`Usage tracker error: ${error.message}`);
    process.exit(0);
  }
});
