# Claude Code Hooks (v2.5)

> **Hooks** = commands that run before/after Claude executes tools

---

## Quick Reference

| Hook Type | When | Can Block? | Use Case |
|-----------|------|------------|----------|
| Pre-tool use | Before execution | ✅ Yes | Block sensitive files, validate actions |
| Post-tool use | After execution | ❌ No | Type checking, format, test |

---

## Hook Configuration Locations

Hooks can be defined in three locations (priority order):

```
1. ~/.claude/settings.json          # Global (all projects)
2. .claude/settings.json            # Project (committed, shared with team)
3. .claude/settings.local.json      # Project local (personal, not committed)
```

**Command:** Use `/hooks` inside Claude Code to configure interactively.

---

## Configuration Format

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Grep",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/block-env.js"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/type-check.js"
          }
        ]
      }
    ]
  }
}
```

### Hook Types (Events)

| Event | Purpose |
|-------|---------|
| `PreToolUse` | Before tool execution (can block) |
| `PostToolUse` | After successful tool execution |
| `PostToolUseFailure` | After failed tool execution |
| `UserPromptSubmit` | When user submits prompt |
| `SessionStart` | When session starts |
| `SessionEnd` | When session ends |
| `Notification` | On notifications |
| `Stop` | When stop is triggered |
| `SubagentStart` | When subagent starts |
| `SubagentStop` | When subagent stops |
| `PreCompact` | Before context compaction |
| `PermissionRequest` | On permission requests |

### Hook Execution Types

```json
{
  "type": "command",
  "command": "node ./hooks/my-hook.js",
  "timeout": 30,
  "statusMessage": "Running validation..."
}
```

| Type | Description |
|------|-------------|
| `command` | Execute shell command |
| `prompt` | LLM prompt evaluation |
| `agent` | Agentic verifier |

### Matcher Syntax

- Single tool: `"Read"`
- Multiple tools: `"Read|Grep|Edit"` (pipe-separated)
- Tool names are **case-sensitive** (use exact tool names: `Read`, `Edit`, `Grep`, `Write`, `Bash`)

---

## Exit Codes

| Code | Meaning | Effect |
|------|---------|--------|
| 0 | Allow | Tool call proceeds |
| 2 | Block | Tool call blocked (pre-tool only) |

- **stdout** → ignored
- **stderr** → sent to Claude as feedback

---

## Tool Call Data

Hook receives JSON via stdin:

```json
{
  "session_id": "abc123",
  "tool_name": "read",
  "tool_input": {
    "file_path": "/project/.env"
  }
}
```

---

## Useful Hooks

### 1. Block Sensitive Files (Pre-tool)

Prevents Claude from reading `.env`, credentials, secrets.

**`hooks/block-env.js`:**

```javascript
#!/usr/bin/env node
const fs = require('fs');

// Read tool call from stdin
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  const data = JSON.parse(input);
  const filePath = data.tool_input?.file_path || data.tool_input?.path || '';

  const blocked = ['.env', 'credentials', 'secrets', '.pem', '.key'];
  const isBlocked = blocked.some(b => filePath.toLowerCase().includes(b));

  if (isBlocked) {
    console.error(`⛔ Blocked: ${filePath} contains sensitive data`);
    process.exit(2);
  }

  process.exit(0);
});
```

**Config:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Grep",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/block-env.js"
          }
        ]
      }
    ]
  }
}
```

---

### 2. TypeScript Type Checker (Post-tool)

Run `tsc --no-emit` after TypeScript file edits, feed errors to Claude.

**`hooks/type-check.js`:**

```javascript
#!/usr/bin/env node
const { execSync } = require('child_process');
const fs = require('fs');

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  const data = JSON.parse(input);
  const filePath = data.tool_input?.file_path || '';

  // Only check TypeScript files
  if (!filePath.match(/\.(ts|tsx)$/)) {
    process.exit(0);
  }

  try {
    execSync('npx tsc --noEmit', {
      stdio: ['ignore', 'pipe', 'pipe'],
      timeout: 30000
    });
    process.exit(0);
  } catch (error) {
    // Send type errors to Claude for fixing
    console.error(`⚠️ TypeScript errors found:\n${error.stderr?.toString() || error.stdout?.toString()}`);
    process.exit(0); // Don't block, just inform
  }
});
```

---

### 3. Auto-Format After Edit (Post-tool)

Run Prettier/ESLint after file edits.

**`hooks/auto-format.js`:**

```javascript
#!/usr/bin/env node
const { execSync } = require('child_process');

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  const data = JSON.parse(input);
  const filePath = data.tool_input?.file_path || '';

  // Only format JS/TS files
  if (!filePath.match(/\.(js|jsx|ts|tsx|json)$/)) {
    process.exit(0);
  }

  try {
    execSync(`npx prettier --write "${filePath}"`, { stdio: 'ignore' });
  } catch (e) {
    // Ignore formatting errors
  }

  process.exit(0);
});
```

---

## Framework Integration

### Recommended Hooks for VibeCoding

Add to `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": ["...existing..."]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Grep",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/block-env.js"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/type-check.js"
          },
          {
            "type": "command",
            "command": "node ./hooks/auto-format.js"
          }
        ]
      },
      {
        "matcher": "Skill|SlashCommand|Task",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/usage-tracker.js"
          }
        ]
      }
    ]
  }
}
```

### Directory Structure

```
project/
├── .claude/
│   ├── settings.local.json    # Hook configuration
│   ├── commands/              # Slash commands
│   ├── skills/*/SKILL.md      # Skills (v2.4 subdirectory format)
│   └── usage.log              # Usage tracking output
├── hooks/                     # Hook scripts
│   ├── block-env.js           # Block sensitive file access
│   ├── type-check.js          # TypeScript error detection
│   ├── auto-format.js         # Auto-format on edit
│   └── usage-tracker.js       # Track skill/command/agent usage
└── ...
```

---

### 4. Usage Tracker (Post-tool)

Track when skills, slash commands, and agents are used. Helps verify framework components work.

**`hooks/usage-tracker.js`:**

```javascript
#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const LOG_FILE = '.claude/usage.log';

let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  const data = JSON.parse(input);
  const toolName = data.tool_name || 'unknown';
  const toolInput = data.tool_input || {};

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
      usage = `AGENT: ${toolInput.subagent_type || 'general'}`;
      break;
  }

  fs.appendFileSync(LOG_FILE, `${timestamp} | ${usage}\n`);
  console.error(`📊 Tracked: ${usage}`);
  process.exit(0);
});
```

**Config:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Skill|SlashCommand|Task",
        "hooks": [
          {
            "type": "command",
            "command": "node ./hooks/usage-tracker.js"
          }
        ]
      }
    ]
  }
}
```

**View usage:**
```bash
cat .claude/usage.log
```

---

## Important Notes

1. **Restart required** — Restart Claude Code after hook changes
2. **Performance** — Hooks add latency; use sparingly on critical paths
3. **Debugging** — Test hooks manually: `echo '{"tool_name":"read","tool_input":{"file_path":".env"}}' | node ./hooks/block-env.js`
4. **Exit codes** — Only `2` blocks (pre-tool only); `0` allows, anything else allows with warning

---

## References

- Claude Code `/hooks` command for interactive setup
- [Anthropic Docs: Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks)
