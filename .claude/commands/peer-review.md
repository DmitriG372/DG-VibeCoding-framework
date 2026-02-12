---
description: Peer code review — CC reviews CX or CX reviews CC
context: fork
allowed-tools:
  - Bash
  - Read
  - Glob
---

# /peer-review

Peer code review between CC and CX. Either partner can review the other's work.

> **Philosophy:** Equal partnership means mutual accountability. Both agents review each other.

## Usage

```
/peer-review [branch|file|directory]
/peer-review cx/add-auth-api          # CC reviews CX's branch
/peer-review --full cx/refactor-db    # Full audit (35 points)
/peer-review src/services/            # Review specific directory
```

## Your Task

### Step 1: Determine Review Mode

If `$ARGUMENTS` contains a `cx/` branch prefix:
- **CC is reviewing CX's work** — interactive mode
- Check out the branch diff: `git diff main...cx/<branch>`

If `$ARGUMENTS` is a file/directory:
- **Standard review** — review the specified path

If `--full` flag present:
- Use Full Audit checklist (35 points)
- Otherwise use Quick Review (17 points)

### Step 2: Gather Changes

```bash
# For branch review
git log main..cx/<branch> --oneline
git diff main...cx/<branch> --stat
git diff main...cx/<branch>

# For file/directory review
# Read the files directly
```

### Step 3: Apply Review Checklist

#### Quick Review (17 points)

**Code Quality (5):**
- [ ] Readability and clarity
- [ ] Function length (<50 lines)
- [ ] Nesting depth (<4 levels)
- [ ] Naming conventions
- [ ] DRY compliance

**Security (5):**
- [ ] No hardcoded secrets
- [ ] Input validation
- [ ] No injection vulnerabilities
- [ ] Auth/authz checks
- [ ] Data sanitization

**Performance (4):**
- [ ] Algorithm complexity
- [ ] Memory management
- [ ] Async patterns
- [ ] Database queries

**Patterns (3):**
- [ ] Project consistency (matches PROJECT.md)
- [ ] Architecture compliance
- [ ] No anti-patterns

#### Full Audit (35 points)

Includes Quick Review plus:

**Documentation (5):**
- README, API docs, inline, types, changelog

**Test Coverage (5):**
- Unit, integration, edge cases, error paths, >=70%

**Dependencies (4):**
- Vulnerabilities, outdated, unused, license

**Tech Debt (4):**
- TODOs, deprecated, complexity, duplication

### Step 4: Score and Verdict

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

### Step 5: Display Results

```markdown
## Peer Review Results

**Target:** [branch/file/directory]
**Reviewer:** CC
**Mode:** Quick Review | Full Audit
**Verdict:** [PASS/NEEDS_CHANGES/FAIL]
**Score:** X/17 or X/35

### Issues Found

#### CRITICAL (blocks merge)
- [issue + file:line]

#### MAJOR (should fix)
- [issue + file:line]

#### MINOR (nice to fix)
- [issue + file:line]

---

**Next Steps:**
1. Fix CRITICAL issues before merge
2. Do you want me to fix MAJOR issues? [Y/n]
```

### Step 6: Update Task Board

If reviewing a CX branch with task in board.md:
- If PASS → Move task to "Completed", note review score
- If NEEDS_CHANGES → Keep in "In Review", add review notes

### Step 7: CX as Reviewer (Headless)

To have CX review CC's work:

```bash
cd ../<project>-wt-cx-<review-branch>/
codex exec --json "You are a strict code reviewer. Review the diff between main and feat/<branch>:

## Checklist
[Same 17/35-point checklist]

## Output Format
### Issues Found
#### CRITICAL | MAJOR | MINOR
### Verdict: PASS | NEEDS_CHANGES | FAIL
### Score: X/17"
```

Parse JSON output and display results.

## Rules

- ALWAYS review against PROJECT.md patterns
- ALWAYS check for security issues
- NEVER auto-merge without user confirmation
- For CX branches: ALWAYS check git diff, not just final state

## Input

$ARGUMENTS — Branch name, file, or directory to review

## Output

- Scored review with issues categorized by severity
- Updated task board (if branch review)
- Fix suggestions

---

*DG-VibeCoding-Framework v4.0.0 — Equal Partnership*
