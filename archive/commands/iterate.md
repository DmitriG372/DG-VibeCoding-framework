---
description: "Log iteration: $ARGUMENTS"
---

Log iteration: $ARGUMENTS

## Instructions

1. Document the current attempt/iteration
2. Capture what was requested, what happened, and what was learned
3. Add entry to PROJECT.md under ## Iteration Log
4. If pattern is reusable across projects, suggest adding to `.claude/skills/`
5. Keep older iterations in collapsed section (after 5+ entries)

## Output Format

### Iteration Logged

#### Attempt [N] — [timestamp]

**Request:**
$ARGUMENTS

**Result:**
[What actually happened - success, partial, failure]

**Feedback:**
[What needs to be different next time]

**Learned:**
[Pattern or insight for future reference]

---

### Analysis

**Was this successful?** [Yes/Partial/No]

**Root cause (if failed):**
[Why it didn't work as expected]

**Reusable pattern?**

- [ ] Yes → Consider adding to `.claude/skills/`
- [x] No → Project-specific learning

---

### Next Action
[What to try next based on this iteration]

---

*Entry added to PROJECT.md#iteration-log*

## Example

```markdown
#### Attempt 3 — 2025-11-26 14:30

**Request:**
Add email validation to user registration

**Result:**
Validation works but error messages don't show in UI

**Feedback:**
Need to handle form error state in React component

**Learned:**
Always wire up error display when adding validation -
check: field state, error message component, form submission handler
```
