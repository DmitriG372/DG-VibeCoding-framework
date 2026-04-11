---
name: debugging
description: "Use when a bug needs reproduction, diagnosis, or root-cause analysis. NOT for writing new features or refactors where nothing is broken yet."
triggers: ["bug", "error", "broken", "fix", "diagnose", "reproduce", "stack trace", "why doesn't", "regression"]
negative_triggers: ["new feature", "refactor clean code", "write first version", "documentation only"]
paths: "**/*.ts, **/*.tsx, **/*.js, **/*.jsx, **/*.py, **/*.vue"
level: "2"
---

# Debugging with Claude Code

> Systematic debugging optimised for AI-assisted development.

## Protocol: Reproduce → Diagnose → Fix → Verify

1. **Reproduce** — confirm the bug exists, get exact error
2. **Diagnose** — read error, form hypothesis, gather evidence
3. **Fix** — minimal change, one thing at a time
4. **Verify** — run the code, show actual output as proof

## Claude Code Debugging Tools

### Screenshots
Share screenshots with Claude for visual bugs. Ask the user to provide screenshots or use browser MCP.

### Browser MCP (Chrome, Playwright)
Let Claude see console logs, network requests, and DOM state directly:
- Claude in Chrome: `mcp__claude-in-chrome__read_console_messages`
- Playwright: `mcp__playwright__browser_snapshot`

### Background Tasks
Run long-running processes (dev server, test watch) as **background tasks** for better log visibility:
```
"Run the dev server as a background task so I can see logs"
```

### Agentic Search (glob + grep)
Better than RAG for code debugging — search the actual codebase:
```
Glob: find files by pattern
Grep: find code by content
Read: examine specific files
```
Always search before guessing.

### /doctor
Run `/doctor` for Claude Code diagnostics when Claude itself seems broken.

## Recovery Strategies

### Context Lost
If Claude seems confused or repeats mistakes:
- Run `/context-refresh` to reload project state
- Check sprint.json for current feature
- Re-read PROJECT.md

### Going Off Track
- `Esc Esc` or `/rewind` to undo — better than trying to fix in same context
- Start fresh session if context is corrupted

### Cross-Model QA
Use a second agent (or Codex) to review findings:
```
/peer-review --headless
```
One agent can cause bugs, another (same model) can find them.

## Anti-Patterns

- "This should work" → RUN it, show output
- Guessing without reading error → READ the actual error first
- Fixing symptoms not causes → find ROOT CAUSE before patching
- Large speculative changes → make ONE small change, verify, repeat
