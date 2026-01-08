# Codex Integration

> OpenAI Codex as secondary code reviewer via headless CLI.

**Philosophy:** Claude Code = Builder, Codex = Critic

---

## Installation

```bash
# Install Codex CLI
npm install -g @openai/codex

# Verify installation
codex --version
# Expected: codex-cli 0.63.0 or higher

# Set API key
export OPENAI_API_KEY=sk-...
```

---

## Configuration

Codex reads configuration from:

| Location | Scope | Purpose |
|----------|-------|---------|
| `~/.codex/AGENTS.md` | Global | Default instructions for all projects |
| `~/.codex/config.toml` | Global | Model, permissions, settings |
| `project/AGENTS.md` | Project | Project-specific rules |
| `~/.codex/prompts/*.md` | Global | Custom slash prompts |
| `~/.codex/skills/*/SKILL.md` | Global | Reusable skills |

### Example config.toml

```toml
model = "o4-mini"

[shell_environment_policy]
inherit = "all"
set = {}

[[notify]]
trigger = "always"
command = ["terminal-notifier", "-message", "Codex done", "-title", "Codex"]
```

---

## CC + Codex Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │     │ Claude Code │     │   Codex     │
│             │     │  (Builder)  │     │  (Critic)   │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       │ /codex-review     │                   │
       ├──────────────────►│                   │
       │                   │                   │
       │                   │ codex exec --json │
       │                   ├──────────────────►│
       │                   │                   │
       │                   │   JSON results    │
       │                   │◄──────────────────┤
       │                   │                   │
       │  Issues + verdict │                   │
       │◄──────────────────┤                   │
       │                   │                   │
       │ "Fix issues?"     │                   │
       ├──────────────────►│                   │
       │                   │                   │
       │   Fixed code      │                   │
       │◄──────────────────┤                   │
       └───────────────────┴───────────────────┘
```

---

## Commands

| Command | Codex Action | Checklist |
|---------|--------------|-----------|
| `/codex-review path` | Quick review | 17 points |
| `/codex-review --full path` | Full audit | 35 points |

---

## `codex exec` Reference

Headless (non-interactive) mode:

```bash
# Basic execution
codex exec "prompt" path/to/file

# JSON output (machine-readable)
codex exec --json "prompt" path/

# Output to file
codex exec --output-last-message result.md "prompt" path/

# With output schema
codex exec --output-schema schema.json "prompt" path/

# Resume previous session
codex exec resume --last
```

### Parse JSON Output

```bash
# Get final message content
codex exec --json "Review code" src/file.ts | \
  jq -r 'select(.type == "item.message") | .content' | tail -1
```

### JSON Stream Format

```json
{"type": "thread.started", "threadId": "..."}
{"type": "turn.started"}
{"type": "item.message", "content": "## Review Summary..."}
{"type": "turn.completed", "usage": {"input_tokens": 1234, "output_tokens": 567}}
```

---

## Severity Levels

| Level | Description | Examples | Action |
|-------|-------------|----------|--------|
| **CRITICAL** | Security risk, crash, data loss | SQL injection, exposed secrets | BLOCKS |
| **MAJOR** | Bug, performance, maintainability | Race condition, O(n²) loop | MUST FIX |
| **MINOR** | Style, naming | Inconsistent naming | OPTIONAL |

---

## Best Practices

1. **Before commit** → Quick review
2. **Before PR merge** → Full audit (critical components)
3. **Before release** → Full audit + security focus
4. **Quarterly** → Full audit entire codebase

---

## Integration with CI/CD

```yaml
# GitHub Actions example
- name: Codex Review
  run: |
    npm install -g @openai/codex
    codex exec --output-last-message review.md \
      "Review for security issues" \
      src/
    cat review.md
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

---

## Troubleshooting

### Codex not found

```bash
npm install -g @openai/codex
```

### API key missing

```bash
export OPENAI_API_KEY=sk-...
# Or add to ~/.zshrc / ~/.bashrc
```

### Permission denied

```bash
chmod +x $(which codex)
```

### JSON parsing fails

```bash
# Ensure jq is installed
brew install jq  # macOS
apt-get install jq  # Ubuntu
```

---

## Comparison: CC Review vs Codex Review

| Aspect | `/review` (CC) | `/codex-review` |
|--------|----------------|-----------------|
| Model | Claude | Codex (GPT-4) |
| Perspective | Builder's view | Critic's view |
| Context | Full project context | File-focused |
| Fixes | Suggests | Reports only |
| Best for | Architecture review | Bug hunting |

**Recommendation:** Use both for comprehensive coverage.

---

## Links

- [Codex CLI Reference](https://developers.openai.com/codex/cli/reference/)
- [Codex Non-Interactive Mode](https://developers.openai.com/codex/noninteractive/)
- [AGENTS.md Guide](https://developers.openai.com/codex/guides/agents-md/)

---

*Part of DG-VibeCoding-Framework v2.6*
