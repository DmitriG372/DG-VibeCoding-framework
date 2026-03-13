---
name: partnership
description: "CC + CX equal partnership coordination. Activates when mentioning Codex, CX, partnership, handoff, worktree, dual-agent, peer review, or sprint."
---

# Partnership Skill

## Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│  EQUAL PARTNERSHIP MODEL (v5.0.0)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  CC (Claude Code)              CX (Codex)                   │
│  ┌─────────────────┐          ┌─────────────────┐          │
│  │ • Interactive    │          │ • Headless       │          │
│  │ • Reasoning      │ <─────> │ • Volume          │          │
│  │ • Design         │ sprint  │ • Autonomous      │          │
│  │ • Exploration    │  .json  │ • Parallel         │          │
│  └─────────────────┘          └─────────────────┘          │
│                                                             │
│  Both are EQUAL partners. Neither is subordinate.           │
└─────────────────────────────────────────────────────────────┘
```

> **Core Principle:** Two agents, different strengths, shared context via PROJECT.md and sprint/sprint.json

## Agent Identity Detection

Identity is determined by the entry point file loaded at session start:
- `CLAUDE.md` → agent is **CC**, branch prefix `cc/`
- `AGENTS.md` → agent is **CX**, branch prefix `cx/`

No manual configuration needed. Branch naming is symmetric: `cc/FXXX-slug` and `cx/FXXX-slug`.

## When to Use Which Partner

| Task | Best Partner | Why |
|------|-------------|-----|
| Interactive UI design | CC | Needs user dialogue, iteration |
| Large refactor (10+ files) | CX | Volume, autonomous execution |
| Bug investigation | CC | Reasoning, exploration, tools |
| Bulk implementation | CX | Headless, parallel execution |
| Architecture decisions | CC | Ambiguity, trade-offs, user input |
| Test generation | CX | Repetitive, pattern-based |
| Code review | Either | `/peer-review` works both ways |
| Documentation | CX | Volume, templated output |
| Prototyping | CC | Fast iteration with user |
| Migration (framework/deps) | CX | Systematic, large-scale |

## Worktree Pattern

Worktree usage is **optional** — determined by `branch_strategy` in sprint.json.

### When using worktrees
```
project/                          ← CC works here (main worktree)
../project-wt-cx-<branch>/       ← CX works here (separate worktree)
```

### Setup
```bash
# From project root:
scripts/worktree-setup.sh cx/FXXX-<slug>
```

### Cleanup
```bash
# After merge:
scripts/worktree-cleanup.sh cx/FXXX-<slug>
```

### When NOT using worktrees
Both agents work on separate branches in the same repo. Branch strategy is defined per-sprint in sprint.json.

## Handoff Protocol

### CC → CX (giving feature to CX)

1. Define feature in `sprint/sprint.json` via `/sprint-init`
2. Assign feature to CX (`assigned_to: "cx"`)
3. Optionally create worktree: `scripts/worktree-setup.sh cx/FXXX-<slug>`
4. Start CX: `codex --full-auto` (CX reads sprint.json for its assignments)

Use `/handoff` command for automated workflow.

### CX → CC (returning work)

1. CX uses `/done` command — updates feature status to `in_review` in sprint.json
2. CX commits all changes to `cx/FXXX-<slug>` branch
3. CC reviews: `/peer-review cx/FXXX-<slug>`
4. CC merges or requests changes

## Peer Review

Either agent can review the other's work:

- **CC reviews CX:** `/peer-review cx/FXXX-<branch>` — interactive review with user
- **CX reviews CC:** `/peer-review --headless` — automated headless review

Review uses the same 17/35-point checklist regardless of reviewer.

## Headless Review Pattern

CC can invoke headless review within the same session:

### Quick Review (same session)
```
/peer-review --headless
```
- Runs `claude -p` or `codex exec` (configured in framework.json `review.tool`)
- Returns JSON report with score + issues
- CC offers to auto-fix

### Deep Review (worktree)
```
/handoff "Review feat/auth branch"
```
- CX gets full worktree access
- More thorough, can run tests
- Async workflow

### When to Use Which
| Scenario | Approach |
|----------|----------|
| Quick sanity check | `--headless` |
| Thorough audit | `--headless --full` |
| Need tests run | `/handoff` (worktree) |
| Different model perspective | `--headless --tool codex` |

## CX Background Launch

```bash
# Full auto mode (CX decides everything)
cd ../<project>-wt-cx-<branch>/
codex --full-auto

# With specific feature from sprint
codex exec --full-auto "Read sprint/sprint.json, complete features assigned to CX"
```

## Sprint Coordination

**File:** `sprint/sprint.json`

### Feature States
```
todo → in_progress → in_review → completed
```

### Assignment
- Features have `assigned_to: "cc"` or `assigned_to: "cx"`
- CC controls feature assignment (user decides routing)
- One active feature per agent recommended (focus)

### Rules
- Always use `/done` command to update feature status
- Include feature ID in commits: `feat(F001): description`
- sprint.md is auto-generated — never edit directly

## Integration with Commands

| Command | Purpose |
|---------|---------|
| `/handoff` | Assign feature to CX, optionally setup worktree |
| `/peer-review` | Review partner's work |
| `/sprint-status` | Show sprint state and branches |
| `/orchestrate` | Multi-agent routing (includes CX) |

---

*DG-VibeCoding-Framework v5.0.0 — Equal Partnership Model*
