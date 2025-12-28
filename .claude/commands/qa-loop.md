---
description: Automated QA loop with self-healing - run tests, fix issues, repeat
---

# /qa-loop

Automaatne kvaliteedikontrolli tsükkel, mis käivitab teste, analüüsib vigu ja parandab need automaatselt.

Inspireeritud: Auto-Claude QA Reviewer + QA Fixer pattern.

## Parameetrid

```
/qa-loop [max_iterations] [target]
```

- `max_iterations` - maksimaalne korduste arv (vaikimisi: 10)
- `target` - testimise sihtmärk (vaikimisi: kogu projekt)

## Instructions

1. **Load agents:**
   ```
   Read: agents/tester.md
   Read: agents/debugger.md
   Read: agents/implementer.md
   ```

2. **Read project context:**
   ```
   Read: PROJECT.md
   ```

3. **Initialize QA state:**
   ```yaml
   qa_state:
     iteration: 0
     max_iterations: 10
     status: "running"
     issues_found: []
     issues_fixed: []
     tests_passing: false
   ```

4. **Run QA Loop:**

   ```
   WHILE iteration < max_iterations AND status == "running":

     # Step 1: Run tests
     Execute: npm test / pytest / cargo test (based on PROJECT.md)

     # Step 2: Analyze results
     IF all tests pass:
       status = "success"
       BREAK

     # Step 3: Parse failures
     failures = parse_test_output()

     # Step 4: Categorize issues
     FOR each failure:
       - Determine root cause
       - Estimate fix complexity (TRIVIAL / MODERATE / COMPLEX)
       - Add to issues_found

     # Step 5: Fix issues (in order of complexity)
     FOR each issue WHERE complexity != COMPLEX:
       - Apply fix using implementer agent
       - Add to issues_fixed
       - Run affected test to verify

     # Step 6: Check for complex issues
     IF only COMPLEX issues remain:
       status = "needs_human"
       BREAK

     iteration++

   IF iteration >= max_iterations:
     status = "max_iterations_reached"
   ```

5. **Output QA Report:**

```yaml
## QA Loop Report

### Summary
**Status:** SUCCESS | NEEDS_HUMAN | MAX_ITERATIONS_REACHED
**Iterations:** X / Y
**Duration:** Xm Ys

### Test Results
- Total tests: X
- Passing: X
- Failing: X

### Issues Found (this session)
| # | Issue | Severity | File | Fixed? |
|---|-------|----------|------|--------|
| 1 | [description] | HIGH/MED/LOW | file:line | YES/NO |

### Fixes Applied
1. **[issue]** - [what was changed]
   - File: `path/to/file.ts`
   - Lines: X-Y

### Remaining Issues (need human attention)
1. **[issue]** - [why automated fix failed]
   - Complexity: COMPLEX
   - Suggestion: [manual fix approach]

### Recommendations
- [any patterns noticed]
- [suggested preventive measures]
```

## Safety Rules

1. **Max 10 iterations** - prevents infinite loops
2. **No destructive changes** - only modify test-related code
3. **Skip COMPLEX issues** - hand off to human
4. **Preserve git state** - all changes are in working tree
5. **Stop on regression** - if new tests break, halt

## Exit Conditions

| Condition | Status | Action |
|-----------|--------|--------|
| All tests pass | SUCCESS | Report and exit |
| Only COMPLEX issues | NEEDS_HUMAN | Report and exit |
| Max iterations reached | MAX_ITERATIONS | Report and exit |
| New regression | ERROR | Revert last fix, report |
| Git conflict | ERROR | Report and exit |

## Example

Input: `/qa-loop 5 src/components`

Output:
```yaml
## QA Loop Report

### Summary
**Status:** SUCCESS
**Iterations:** 3 / 5
**Duration:** 2m 34s

### Test Results
- Total tests: 47
- Passing: 47
- Failing: 0

### Issues Found (this session)
| # | Issue | Severity | File | Fixed? |
|---|-------|----------|------|--------|
| 1 | TypeError: undefined | HIGH | Button.tsx:23 | YES |
| 2 | Missing await | MED | api.ts:45 | YES |
| 3 | Snapshot mismatch | LOW | Card.test.tsx | YES |

### Fixes Applied
1. **TypeError** - Added null check
   - File: `src/components/Button.tsx`
   - Lines: 23-25

2. **Missing await** - Added async/await
   - File: `src/api/api.ts`
   - Lines: 45

3. **Snapshot** - Updated snapshot
   - File: `src/components/__snapshots__/Card.test.tsx.snap`

### Recommendations
- Consider adding stricter TypeScript null checks
- API calls should use try/catch pattern
```

## Integration with Sprint

When in sprint mode:
```
If exists: sprint/sprint.json
Then:
  - Only run tests for current feature
  - Log QA results to sprint.json
  - Update feature status on success
```

---

*Part of DG-VibeCoding-Framework v2.5*
*Inspired by Auto-Claude QA Loop pattern*
