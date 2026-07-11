#!/usr/bin/env node

const readline = require('node:readline');

let lastMessage = '';
const lines = readline.createInterface({ input: process.stdin, crlfDelay: Infinity });
lines.on('line', line => {
  if (!line.trim()) return;
  try {
    const event = JSON.parse(line);
    const item = event.item || event;
    if (item.type === 'agent_message') {
      lastMessage = item.text || item.content || item.agent_message || '';
    } else if (event.agent_message) {
      lastMessage = event.agent_message;
    }
  } catch { /* ignore non-JSON diagnostic lines */ }
});
lines.on('close', () => {
  if (!lastMessage) {
    process.stderr.write('parse-codex-jsonl: no agent message found\n');
    process.exit(1);
  }
  process.stdout.write(`${lastMessage}\n`);
});
