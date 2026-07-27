# Peer Review Modes — Reference

> Level 3 reference loaded on demand from `skills/partnership/SKILL.md`.

## Three Modes

| Mode | When | Command |
|------|------|---------|
| **Headless (same session)** | Quick sanity check | `/peer-review --headless` |
| **Headless + deep** | Thorough audit, no tests | `/peer-review --headless --full` |
| **Worktree review** | Need to run tests, full exploration | `/handoff "Review cx/F003-<slug> branch"` |

## Headless Review (quick)

Runs `claude -p` or `codex exec` in the current session, no context switch:

- Uses tool configured in `framework.json#review.tool`
- Returns JSON report with score + issue list
- CC offers to auto-fix findings interactively

Best for:
- Mid-feature sanity checks
- Pre-commit review
- Small PRs (<10 files)

## Deep Headless Review

Same as headless, but:
- Loads full diff context
- Runs more exhaustive 35-point checklist
- Longer runtime (60–120s)

Best for:
- End-of-feature review
- Medium PRs (10–30 files)
- Cross-model second opinion

## Worktree Review

Creates a dedicated worktree where the reviewer agent has:
- Full repo access
- Ability to run tests
- Ability to navigate related code

Best for:
- Large refactors
- Security-sensitive changes
- When tests need to be executed as part of review

## Invocation Examples

```bash
# Quick CC-reviews-CX after CX returns feature
/peer-review cx/F003-add-auth-api

# CC self-reviews with headless CX
/peer-review --headless

# Deep review with different model
/peer-review --headless --tool codex --full

# Worktree review (async)
/handoff "Review cx/F003-add-auth-api branch thoroughly"
```

## 17/35-Point Checklist Summary

Used by all review modes. Short version (17 points) for quick, full version (35) for deep.

### Correctness (4)
1. Does it compile / type-check?
2. Does it pass the existing test suite?
3. Does new logic have test coverage?
4. Are edge cases handled?

### Security (4)
5. No secrets committed?
6. Input validation on boundaries?
7. No SQL injection / XSS / command injection?
8. Auth checks on protected paths?

### Quality (5)
9. Follows PROJECT.md patterns?
10. No dead code / commented-out blocks?
11. No unnecessary abstractions?
12. Error handling matches project style?
13. No TODO/FIXME stubs left behind?

### Git hygiene (2)
14. Commit messages conform (`feat(scope): FXXX ...`)?
15. One logical change per commit?

### Documentation (2)
16. PROJECT.md updated if patterns changed?
17. Public API documented?

### Deep-mode additional (+18)
18–35. Performance, accessibility, i18n, observability, dependency audit, migration safety, rollback plan, etc.

## Output Contract

Every review mode produces JSON with this shape:

```json
{
  "score": 14,
  "max": 17,
  "issues": [
    { "severity": "blocker", "file": "src/auth/login.ts", "line": 45, "note": "..." }
  ],
  "recommendation": "request_changes" | "approve" | "approve_with_comments"
}
```

## Anti-Patterns

- Running deep review on every commit → wasted tokens, use quick mode
- Ignoring blocker-severity issues → defeats the purpose
- Auto-fixing without showing diff → reviewer loses control
- Using same-model review when cross-model is available → less independent signal
