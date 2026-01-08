---
name: codex
description: "OpenAI Codex integration for secondary code review. Aktiveerub kui mainitakse Codex, headless review, dual-AI workflow, või CC + Codex koostöö."
---

# Codex Integration Skill

## Philosophy

> "Two eyes are good, but four are better!"

| Agent | Role | Focus |
|-------|------|-------|
| **Claude Code** | Builder | "How to build this?" |
| **Codex** | Critic | "What could go wrong?" |

Codex acts as a **Devil's Advocate** auditor:
- Searches for bugs, not confirmation
- Asks questions the developer didn't ask
- Views code through an external auditor's eyes
- Does NOT fix code — only reports

## Headless Mode

`codex exec` runs Codex non-interactively:

```bash
# Quick review
codex exec --json "Review code for issues" path/to/file

# With file output
codex exec --output-last-message /tmp/review.md "Review" path/

# Parse JSON results
codex exec --json "..." | jq -r 'select(.type == "item.message") | .content'
```

## /codex-review Command

```bash
/codex-review src/components/Timer.vue    # Quick review (17 points)
/codex-review --full src/services/        # Full audit (35 points)
```

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **CRITICAL** | Security risk, crash, data loss | BLOCKS deployment |
| **MAJOR** | Bug, performance, maintainability | MUST FIX |
| **MINOR** | Style, naming conventions | OPTIONAL |

## Review Checklists

### Quick Review (17 points)

**Code Quality (5):**
- Readability and clarity
- Function length (<50 lines)
- Nesting depth (<4 levels)
- Naming conventions
- DRY compliance

**Security (5):**
- No hardcoded secrets
- Input validation
- No injection vulnerabilities
- Auth/authz checks
- Data sanitization

**Performance (4):**
- Algorithm complexity
- Memory management
- Async patterns
- Database queries

**Patterns (3):**
- Project consistency
- Architecture compliance
- No anti-patterns

### Full Audit (35 points)

Includes Quick Review checklist plus:
- Documentation (5): README, API docs, inline, types, changelog
- Test Coverage (5): unit, integration, edge cases, error paths, >=70%
- Dependencies (4): vulnerabilities, outdated, unused, license
- Tech Debt (4): TODOs, deprecated, complexity, duplication

## Verdict Rules

**Quick Review:**
| Score | Verdict |
|-------|---------|
| 15-17 | PASS |
| 10-14 | NEEDS_CHANGES |
| 0-9 | FAIL |

**Full Audit:**
| Score | Verdict |
|-------|---------|
| 28-35 | PASS |
| 20-27 | NEEDS_ATTENTION |
| 0-19 | FAIL |

## Workflow

```
1. Claude Code writes code
2. User invokes: /codex-review path/to/file
3. Codex runs headless, returns JSON
4. Claude Code parses and displays issues
5. User confirms which to fix
6. Claude Code fixes issues
7. (Optional) Re-run Codex to verify
```

## Best Practices

1. **Before commit** → Quick review
2. **Before PR merge** → Full audit (critical components)
3. **Before release** → Full audit + security focus
4. **Quarterly** → Full audit entire codebase

## Codex Configuration

Codex reads instructions from:

```
~/.codex/AGENTS.md         # Global instructions
~/.codex/config.toml       # Settings
project/AGENTS.md          # Project-specific rules
```

## Installation

```bash
# Install Codex CLI
npm install -g @openai/codex

# Verify
codex --version

# Requires OPENAI_API_KEY
export OPENAI_API_KEY=sk-...
```

---

*Part of DG-VibeCoding-Framework v2.6 — CC + Codex Integration*
