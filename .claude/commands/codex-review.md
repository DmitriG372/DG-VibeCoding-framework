---
description: Run OpenAI Codex as secondary code reviewer (headless)
---

# /codex-review

Invoke OpenAI Codex CLI in headless mode for "second opinion" code review.

> **Concept:** Claude Code = Builder, Codex = Critic
> Two AI systems reviewing from different angles catch more issues.

## Usage

```
/codex-review [file|directory]
/codex-review src/components/Timer.vue
/codex-review --full src/services/
```

## Workflow

### Step 1: Determine Target

If `$ARGUMENTS` provided, use that path.
Otherwise, ask user what to review.

### Step 2: Execute Codex (Headless)

Run Codex in non-interactive mode:

```bash
# Quick review (default)
codex exec --json "You are a strict code reviewer. Review this code for:

## Checklist
1. Security vulnerabilities (injection, XSS, auth bypass)
2. Memory leaks (unclosed resources, event listeners)
3. Performance issues (N+1, inefficient loops)
4. Error handling gaps (unhandled promises, missing try-catch)
5. Type safety issues (any types, missing null checks)

## Output Format
### Issues Found

#### CRITICAL (blocks deployment)
- [issue description + file:line]

#### MAJOR (should fix)
- [issue description + file:line]

#### MINOR (nice to fix)
- [issue description + file:line]

### Verdict
PASS | NEEDS_CHANGES | FAIL

### Score
X/17" $TARGET
```

For full audit, add `--full` flag:

```bash
# Full audit (extended)
codex exec --json "You are a meticulous code auditor. Perform comprehensive audit:

## Extended Checklist (35 points)

### Code Quality (10)
- Dead code
- Code duplication
- Naming conventions
- Complexity metrics
- Single responsibility
- Documentation gaps
- Magic numbers
- Deep nesting
- Long functions
- Unclear logic

### Security (8)
- Input validation
- Output encoding
- Auth/authz
- Secrets exposure
- SQL injection
- XSS vectors
- CSRF protection
- Rate limiting

### Performance (7)
- N+1 queries
- Memory leaks
- Inefficient algorithms
- Missing caching
- Bundle size impact
- Lazy loading gaps
- Unnecessary re-renders

### Reliability (6)
- Error handling
- Edge cases
- Null safety
- Race conditions
- Timeout handling
- Retry logic

### Maintainability (4)
- Test coverage gaps
- Dependency health
- Tech debt markers
- Upgrade blockers

## Output Format
[Same as quick review but with extended details]

### Verdict
PASS (28-35) | NEEDS_ATTENTION (20-27) | FAIL (0-19)

### Score
X/35" $TARGET
```

### Step 3: Parse Results

Extract from JSON output:
```bash
# Get the final message content
codex exec --json "..." | jq -r 'select(.type == "item.message") | .content' | tail -1
```

Or use file output:
```bash
codex exec --output-last-message /tmp/codex-review-result.md "..." $TARGET
cat /tmp/codex-review-result.md
```

### Step 4: Display Results

Show Codex findings to user with clear formatting:

```markdown
## Codex Review Results

**Target:** [file/directory]
**Mode:** Quick Review | Full Audit
**Verdict:** [PASS/NEEDS_CHANGES/FAIL]
**Score:** X/17 or X/35

### Issues from Codex

[Display parsed issues here]

---

**Next Steps:**
1. Review the findings
2. Do you want me to fix CRITICAL issues? [Y/n]
3. Do you want me to fix MAJOR issues? [Y/n]
```

### Step 5: Fix Issues (Optional)

If user confirms:
1. Take each CRITICAL issue
2. Fix it using Claude Code's edit capabilities
3. Mark as fixed in todo list
4. Re-run Codex to verify (optional)

## Error Handling

If Codex not installed:
```
Codex CLI not found. Install with:
npm install -g @openai/codex
```

If Codex exec fails:
```
Codex review failed. Check:
1. OPENAI_API_KEY is set
2. Target path exists
3. Codex has read permissions
```

## Integration Notes

- **Read-only:** Codex only reports, Claude Code fixes
- **Separate context:** Each AI reviews independently
- **Combined strength:** Different models catch different issues
- **Workflow:** CC builds → Codex reviews → CC fixes

## Example Session

```
User: /codex-review src/composables/useTimer.ts

Claude Code: Running Codex review...

[Executes: codex exec --json "..." src/composables/useTimer.ts]

## Codex Review Results

**Target:** src/composables/useTimer.ts
**Mode:** Quick Review
**Verdict:** NEEDS_CHANGES
**Score:** 13/17

### Issues from Codex

#### CRITICAL (1)
- Memory leak: setInterval not cleared in cleanup
  Location: useTimer.ts:45

#### MAJOR (2)
- Missing error handling for localStorage access
  Location: useTimer.ts:23
- No type guard for parsed JSON
  Location: useTimer.ts:28

#### MINOR (1)
- Magic number 1000 should be named constant
  Location: useTimer.ts:45

---

Do you want me to fix these issues? [Y/n]

User: Y

Claude Code: Fixing CRITICAL issue first...
[Uses Edit tool to add cleanup]
[Marks todo as complete]

Fixed! Re-running Codex to verify...
```

---

*Part of DG-VibeCoding-Framework v2.5 - CC + Codex Integration*
