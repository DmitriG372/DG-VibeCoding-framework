---
description: Orchestrate complex multi-step tasks with agent coordination
---

# /orchestrate

Coordinate complex tasks that require multiple specialist agents.

> Agent behaviors live in `.claude/agents/*.md`. Execution integrity rules live in `.claude/rules/execution-integrity.md`. This command wires them together.

## Instructions

1. **Load orchestrator agent:** Read `.claude/agents/orchestrator.md`.
2. **Classify complexity:**
   - LOW: single file / simple change → route directly to `implementer`
   - MEDIUM: multi-file, needs review → `implementer` + `reviewer`
   - HIGH: cross-domain, architecture → full team
3. **Select team** from this matrix:

   | Task type | Primary | Support |
   |-----------|---------|---------|
   | New feature | implementer | reviewer, tester |
   | Bug fix | debugger | reviewer, tester |
   | Code review | reviewer | tester |
   | Testing | tester | debugger |
   | Cross-domain | implementer | reviewer, tester, debugger |
   | High volume | — | delegate via `/feature` or `/handoff` |

4. **Create a plan under 5 steps** (enforces execution-integrity Rule 1). If the task needs more, split into Phase 1 and defer Phase 2+ until Phase 1 verifies.
5. **Enforce evidence gates per step** (execution-integrity Rule 3):
   - Each step has a concrete "Expected output" (file path, test result, command output)
   - Vague outputs like "architecture designed" are rejected
   - After each step, show real vs expected output + DONE/FAILED status

## Output Format

```yaml
## Orchestration Plan

Task: <description>
Complexity: LOW | MEDIUM | HIGH
Phase: 1/N

Steps (max 5):
  1. <name>
     agent: <agent>
     action: <specific action>
     expected: <verifiable output>
     status: PENDING
  ...

Checkpoint: Report real vs expected + status after each step.
```

## Parallel Execution

| Phase | Parallel? | Notes |
|-------|-----------|-------|
| Planning | no | one plan at a time |
| Exploration | yes | up to 3 parallel file/search agents |
| Implementation | partial | only for truly independent components |
| Testing | yes | independent suites in parallel |
| Review | no | sequential, needs complete picture |

Rules:
- Max 3–4 parallel agents (rate limits)
- Never parallelize git operations (conflicts)
- Database migrations are sequential
- Review is always last

## Sprint Mode

If `sprint/sprint.json` exists, enforce one-feature-per-agent focus. The orchestrator does not start a new feature until the current one reaches `in_review` or later.

## Background Execution

Use `Ctrl+B` while `/orchestrate` is running to push it into the background. Useful for:
- Large test/doc generation
- Migration tasks
- Any task that would block the prompt for >1 minute

View results with `/tasks` or `TaskOutput <id>`.
