---
name: partnership
description: "CC + CX equal partnership coordination. Activates when mentioning Codex, CX, partnership, handoff, worktree, dual-agent, peer review, or task board."
---

# Partnership Skill

## Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│  EQUAL PARTNERSHIP MODEL (v4.0.0)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  CC (Claude Code)              CX (Codex)                   │
│  ┌─────────────────┐          ┌─────────────────┐          │
│  │ • Interactive    │          │ • Headless       │          │
│  │ • Reasoning      │ <─────> │ • Volume          │          │
│  │ • Design         │ .tasks/ │ • Autonomous      │          │
│  │ • Exploration    │  board  │ • Parallel         │          │
│  └─────────────────┘          └─────────────────┘          │
│                                                             │
│  Both are EQUAL partners. Neither is subordinate.           │
└─────────────────────────────────────────────────────────────┘
```

> **Core Principle:** Two agents, different strengths, shared context via PROJECT.md and .tasks/board.md

## When to Use Which Partner

| Task | Best Partner | Why |
|------|-------------|-----|
| Interactive UI design | CC | Needs user dialogue, iteration |
| Large refactor (10+ files) | CX | Volume, autonomous execution |
| Bug investigation | CC | Reasoning, exploration, tools |
| Bulk implementation | CX | Headless, parallel in worktree |
| Architecture decisions | CC | Ambiguity, trade-offs, user input |
| Test generation | CX | Repetitive, pattern-based |
| Code review | Either | `/peer-review` works both ways |
| Documentation | CX | Volume, templated output |
| Prototyping | CC | Fast iteration with user |
| Migration (framework/deps) | CX | Systematic, large-scale |

## Worktree Pattern

CX works in a separate git worktree to avoid conflicts:

```
project/                          ← CC works here (main worktree)
../project-wt-cx-<branch>/       ← CX works here (separate worktree)
```

### Setup
```bash
# From project root:
scripts/worktree-setup.sh cx/<task-slug>
```

### Cleanup
```bash
# After merge:
scripts/worktree-cleanup.sh cx/<task-slug>
```

## Handoff Protocol

### CC → CX (giving task to CX)

1. Define task clearly in `.tasks/board.md`
2. Assign to CX section
3. Create branch and worktree: `scripts/worktree-setup.sh cx/<slug>`
4. Start CX: `cd ../<project>-wt-cx-<slug>/ && codex --full-auto`

Use `/handoff` command for automated workflow.

### CX → CC (returning work)

1. CX moves task to "In Review" in board.md
2. CX commits all changes to `cx/<slug>` branch
3. CC reviews: `/peer-review cx/<slug>`
4. CC merges or requests changes

## Peer Review

Either agent can review the other's work:

- **CC reviews CX:** `/peer-review cx/<branch>` — interactive review with user
- **CX reviews CC:** `codex exec --json "Review code on branch feat/..."` — headless

Review uses the same 17/35-point checklist regardless of reviewer.

## CX Background Launch

```bash
# Full auto mode (CX decides everything)
cd ../<project>-wt-cx-<branch>/
codex --full-auto

# With specific task from board
codex exec --full-auto "Read .tasks/board.md, complete task assigned to CX"
```

## Task Board Coordination

**File:** `.tasks/board.md`

### Sections
- **Backlog** — Unassigned tasks
- **Assigned to: CC** — CC's current work
- **Assigned to: CX** — CX's current work
- **In Review** — Completed, awaiting peer review
- **Completed** — Done and merged

### Task Flow
```
Backlog → Assigned (CC or CX) → In Review → Completed
```

### Rules
- One task per agent at a time (focus)
- Always update board.md when status changes
- Include TASK-ID in commits: `feat(TASK-001): description`
- CC controls task assignment (user decides routing)

## Integration with Commands

| Command | Purpose |
|---------|---------|
| `/handoff` | Assign task to CX, setup worktree |
| `/peer-review` | Review partner's work |
| `/sync-tasks` | Show board status and branches |
| `/orchestrate` | Multi-agent routing (includes CX) |

---

*DG-VibeCoding-Framework v4.0.0 — Equal Partnership Model*
