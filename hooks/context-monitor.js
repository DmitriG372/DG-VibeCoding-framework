#!/usr/bin/env node
// DG-VibeCoding-Framework — Context Monitor Hook
// Inspired by GSD's context-monitor pattern
// Warns when context window is filling up (PostToolUse)
//
// Reads context % from statusline bridge file written by Claude Code.
// Bridge file: /tmp/claude-ctx-{session_id}.json
// Debounce: warns every 10 tool uses (unless severity escalates)

const fs = require('fs');
const path = require('path');

const WARN_THRESHOLD = 35;    // % remaining → WARNING
const CRITICAL_THRESHOLD = 25; // % remaining → CRITICAL
const DEBOUNCE_INTERVAL = 10;  // tool uses between repeated warnings

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const sessionId = data.session_id || 'unknown';

    // Try to read context usage from bridge file
    const bridgePath = `/tmp/claude-ctx-${sessionId}.json`;
    const counterPath = `/tmp/claude-ctx-counter-${sessionId}`;

    // Read or initialize tool-use counter
    let counter = 0;
    try {
      counter = parseInt(fs.readFileSync(counterPath, 'utf8'), 10) || 0;
    } catch { /* first run */ }
    counter++;
    fs.writeFileSync(counterPath, String(counter));

    // Try to read context info from environment or bridge file
    let remaining = null;

    // Method 1: Bridge file from statusline hook
    try {
      const bridge = JSON.parse(fs.readFileSync(bridgePath, 'utf8'));
      remaining = bridge.context_remaining_pct || bridge.remaining || null;
    } catch { /* no bridge file yet */ }

    // Method 2: Estimate from tool use count (rough heuristic)
    // Average ~500 tokens per tool use, 200K context = ~400 tool uses
    if (remaining === null) {
      const estimatedUsed = counter * 500;
      const contextSize = 200000;
      remaining = Math.max(0, Math.round((1 - estimatedUsed / contextSize) * 100));
    }

    if (remaining === null) {
      process.exit(0); // Can't determine context usage
    }

    // Check thresholds
    let severity = null;
    if (remaining <= CRITICAL_THRESHOLD) {
      severity = 'CRITICAL';
    } else if (remaining <= WARN_THRESHOLD) {
      severity = 'WARNING';
    }

    if (!severity) {
      process.exit(0); // All good
    }

    // Debounce: check if we already warned recently
    const lastWarnPath = `/tmp/claude-ctx-lastwarn-${sessionId}`;
    let lastWarnCounter = 0;
    let lastSeverity = '';
    try {
      const lastWarn = JSON.parse(fs.readFileSync(lastWarnPath, 'utf8'));
      lastWarnCounter = lastWarn.counter || 0;
      lastSeverity = lastWarn.severity || '';
    } catch { /* first warning */ }

    // Skip if same severity and within debounce window
    const sinceLastWarn = counter - lastWarnCounter;
    if (severity === lastSeverity && sinceLastWarn < DEBOUNCE_INTERVAL) {
      process.exit(0);
    }

    // Save warning state
    fs.writeFileSync(lastWarnPath, JSON.stringify({
      counter,
      severity,
      timestamp: new Date().toISOString()
    }));

    // Emit warning
    if (severity === 'CRITICAL') {
      process.stderr.write(`\n⛔ CONTEXT CRITICAL (~${remaining}% remaining)\n`);
      process.stderr.write(`Kontekstiaken on peaaegu täis. Soovitused:\n`);
      process.stderr.write(`  1. Lõpeta praegune samm ja committa töö\n`);
      process.stderr.write(`  2. Kasuta /compact konteksti tihendamiseks\n`);
      process.stderr.write(`  3. Või alusta uut sessiooni (/clear)\n\n`);
    } else {
      process.stderr.write(`\n⚠️  CONTEXT WARNING (~${remaining}% remaining)\n`);
      process.stderr.write(`Kontekstiaken täitub. Plaani töö lõpetamist lähima 50 tööriistakutse jooksul.\n\n`);
    }

  } catch (err) {
    // Fail-open: never block on monitor errors
    process.stderr.write(`[context-monitor] Error: ${err.message}\n`);
  }

  process.exit(0);
});
