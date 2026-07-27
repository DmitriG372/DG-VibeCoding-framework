#!/usr/bin/env node
// DG-VibeCoding-Framework — Usage Tracker Hook
// PostToolUse hook: appends lightweight JSONL usage events to .claude/usage.log.

const fs = require('fs');
const path = require('path');

function readJsonFromStdin(callback) {
  let input = '';
  process.stdin.on('data', chunk => {
    input += chunk;
  });
  process.stdin.on('end', () => {
    try {
      callback(input ? JSON.parse(input) : {});
    } catch (error) {
      process.stderr.write(`[usage-tracker] Invalid hook payload: ${error.message}\n`);
      process.exit(0);
    }
  });
}

readJsonFromStdin(data => {
  try {
    const claudeDir = path.join(process.cwd(), '.claude');
    fs.mkdirSync(claudeDir, { recursive: true });

    const event = {
      timestamp: new Date().toISOString(),
      session_id: data.session_id || null,
      tool_name: data.tool_name || null,
      matcher: data.matcher || null,
      file_path: data.tool_input?.file_path || data.tool_input?.path || null,
    };

    fs.appendFileSync(
      path.join(claudeDir, 'usage.log'),
      `${JSON.stringify(event)}\n`
    );
  } catch (error) {
    process.stderr.write(`[usage-tracker] ${error.message}\n`);
  }

  process.exit(0);
});
