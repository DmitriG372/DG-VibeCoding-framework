#!/usr/bin/env node
/**
 * Session Initialization Hook (runs once per session)
 * Part of DG-VibeCoding-Framework v2.6
 *
 * Uses CC 2.1.0 "once: true" feature to run only at session start.
 */

const fs = require('fs');
const path = require('path');

const LOG_FILE = '.claude/usage.log';

// Ensure .claude directory exists
const claudeDir = path.dirname(LOG_FILE);
if (!fs.existsSync(claudeDir)) {
  fs.mkdirSync(claudeDir, { recursive: true });
}

// Log session start
const timestamp = new Date().toISOString();
const logEntry = `${timestamp} | SESSION_START\n`;

try {
  fs.appendFileSync(LOG_FILE, logEntry);
} catch (e) {
  // Ignore write errors
}

// Check for PROJECT.md
if (!fs.existsSync('PROJECT.md')) {
  console.error('⚠️ PROJECT.md not found - run framework setup or create PROJECT.md');
}

// Check for sprint in progress
if (fs.existsSync('sprint/sprint.json')) {
  try {
    const sprint = JSON.parse(fs.readFileSync('sprint/sprint.json', 'utf8'));
    const inProgress = sprint.features?.filter(f => f.status === 'in_progress') || [];
    if (inProgress.length > 0) {
      console.error(`📋 Sprint in progress: ${inProgress.map(f => f.id).join(', ')}`);
    }
  } catch (e) {
    // Ignore parse errors
  }
}

process.exit(0);
