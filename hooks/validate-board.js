#!/usr/bin/env node
// DG-VibeCoding-Framework v4.1.0 — Board Validation Hook
// PostToolUse hook: validates .tasks/board.md structure after Edit|Write.
// Warnings only (exit 0) — never blocks.

const fs = require('fs');

const REQUIRED_SECTIONS = [
  'Backlog',
  'Assigned to: CC',
  'Assigned to: CX',
  'In Review',
  'Completed',
];

const CONTAMINATION_PATTERNS = [
  /^##\s+Rules\b/m,
  /^##\s+Patterns\b/m,
  /^##\s+Tech Stack\b/m,
  /^##\s+Commands\b/m,
  /^##\s+Stack\b/m,
];

const TASK_ID_REGEX = /TASK-\d{3,}/;

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = input ? JSON.parse(input) : {};
    const filePath = data.tool_input?.file_path || '';

    // Only validate board.md files
    if (!filePath.includes('board.md') || !filePath.includes('.tasks')) {
      process.exit(0);
    }

    // Read the file
    if (!fs.existsSync(filePath)) {
      process.exit(0);
    }

    const content = fs.readFileSync(filePath, 'utf8');
    const warnings = [];

    // Check required sections
    for (const section of REQUIRED_SECTIONS) {
      const regex = new RegExp(`^##\\s+${section.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`, 'm');
      if (!regex.test(content)) {
        warnings.push(`Missing required section: "## ${section}"`);
      }
    }

    // Check for rules contamination
    for (const pattern of CONTAMINATION_PATTERNS) {
      if (pattern.test(content)) {
        const match = content.match(pattern);
        warnings.push(`Rules contamination detected: "${match[0]}" — rules belong in PROJECT.md, not board.md`);
      }
    }

    // Check TASK-ID format (warning only)
    const lines = content.split('\n');
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      // Look for task-like lines that don't use TASK-ID format
      if (line.match(/^[-*]\s+\[/) && !TASK_ID_REGEX.test(line) && line.includes(']')) {
        // Only warn if it looks like a task item without proper ID
        if (line.match(/^[-*]\s+\[[ x]\]/i)) {
          warnings.push(`Line ${i + 1}: Task without TASK-ID format — consider using TASK-XXX`);
        }
      }
    }

    // Output warnings
    if (warnings.length > 0) {
      process.stderr.write(`⚠️ board.md validation (${warnings.length} warning${warnings.length > 1 ? 's' : ''}):\n`);
      for (const w of warnings) {
        process.stderr.write(`  - ${w}\n`);
      }
    }
  } catch (err) {
    process.stderr.write(`⚠️ validate-board.js error: ${err.message}\n`);
  }

  // Always exit 0 — never block
  process.exit(0);
});
