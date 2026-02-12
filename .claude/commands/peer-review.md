---
description: Peer code review — CC reviews CX or CX reviews CC
context: fork
allowed-tools:
  - Bash
  - Read
  - Glob
  - Edit
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
/peer-review --headless                    # Headless review uncommitted changes
/peer-review --headless feat/auth          # Headless review branch
/peer-review --headless --full src/        # Headless full audit
/peer-review --headless --tool codex       # Use Codex instead of Claude
```

## Your Task

### Step 1: Determine Review Mode

If `$ARGUMENTS` contains `--headless`:
- **Headless mode** — invoke external review agent
- Parse additional flags: `--tool`, `--full`, `--branch`
- Proceed to **Step 7** (Headless Review)

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

### Step 7: Headless Review

When `--headless` flag is present:

1. **Determine target:**
   - Branch argument → `--branch <name>`
   - File/directory argument → pass as target
   - No argument → uncommitted changes (default)

2. **Read tool preference from framework.json:**
   ```bash
   # Read review.tool from framework.json (default: claude)
   TOOL=$(python3 -c "import json; print(json.load(open('framework.json')).get('review',{}).get('tool','claude'))")
   ```
   Override with `--tool claude|codex` in arguments.

3. **Execute headless review:**
   ```bash
   ./scripts/headless-review.sh \
     --tool $TOOL \
     --mode quick \
     --branch $BRANCH \
     --output /tmp/review-report.json
   ```
   Use `--mode full` if `--full` flag was provided.
   Use `--staged` if reviewing staged changes.
   Pass file/directory path as positional target.

4. **Read and display results:**
   Read `/tmp/review-report.json` and display:
   - Verdict + score
   - Issues grouped by severity (CRITICAL → MAJOR → MINOR)
   - Summary

5. **Offer auto-fix:**
   "Do you want me to fix these issues? [Y/n]"
   If yes → fix each issue using the Edit tool, then re-run headless review to verify.

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
