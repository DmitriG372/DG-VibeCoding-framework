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

> Full checklist, mode comparison, and JSON output contract live in `.claude/skills/partnership/references/peer-review-modes.md`. This command wires them to sprint state.

## Usage

```
/peer-review [<branch|file|directory>] [--full] [--headless] [--tool claude|codex]
```

Examples:
```
/peer-review cx/F003-add-auth-api            # CC reviews CX branch
/peer-review --full cx/F007-refactor-db      # 35-point deep review
/peer-review src/services/                   # review a directory
/peer-review --headless                      # headless, uncommitted changes
/peer-review --headless --tool codex         # cross-model review
```

## Instructions

### Step 1: Detect agent identity
- Context from `CLAUDE.md` → `$AGENT_ID = "cc"`
- Context from `AGENTS.md` → `$AGENT_ID = "cx"`

### Step 2: Determine mode
- `--headless` present → headless mode (Step 6)
- `cx/...` or `cc/...` branch argument → interactive branch review
- File/directory argument → standard review of that path
- `--full` → 35-point audit, else 17-point quick review

### Step 3: Gather changes
For branch review:
```bash
BASE_BRANCH=$(node -e "const s=require('./sprint/sprint.json'); process.stdout.write(s.base_branch)")
git log "$BASE_BRANCH"..<branch> --oneline
git diff "$BASE_BRANCH"...<branch> --stat
git diff "$BASE_BRANCH"...<branch>
```
For path review, read files directly.

### Step 4: Apply checklist
Load the 17- or 35-point checklist from `.claude/skills/partnership/references/peer-review-modes.md`. Categories: Correctness, Security, Quality, Git hygiene, Documentation. (Deep mode adds Performance, a11y, i18n, observability, deps, migration, rollback.)

### Step 5: Score and produce JSON report
Output contract:
```json
{
  "score": 14,
  "max": 17,
  "verdict": "approve" | "approve_with_comments" | "request_changes",
  "issues": [
    { "severity": "blocker|major|minor", "file": "<path>", "line": 0, "note": "..." }
  ]
}
```

Verdict thresholds:
| Score | Quick (17) | Full (35) |
|-------|-----------|-----------|
| approve | 15–17 | 28–35 |
| with_comments | 10–14 | 20–27 |
| request_changes | 0–9 | 0–19 |

### Step 6: Headless mode
If `--headless`:
```bash
TOOL=$(python3 -c "import json; print(json.load(open('framework.json')).get('review',{}).get('tool','claude'))")
./scripts/headless-review.sh \
  --tool $TOOL \
  --mode ${FULL:+full}${FULL:-quick} \
  --branch "$BRANCH" \
  --output /tmp/review-report.json
```
Then read `/tmp/review-report.json` and format the same JSON contract.

### Step 7: Update sprint.json (when reviewing a branch)
1. Read `sprint/sprint.json`
2. Find feature whose `branch` matches the reviewed branch
3. Update based on verdict:
   - `approve` → `status: "completed"`, fill `review` + `completed_at`
   - `approve_with_comments` → `status: "in_review"`, fill `review.notes`
   - `request_changes` → `status: "in_progress"`, fill `review.notes`
4. Set root `last_updated_by: "$AGENT_ID"`
5. Write sprint.json

If no matching feature → stop and report a sprint/branch contract mismatch.

### Step 8: Offer auto-fix
For non-blocker issues: "Fix these? [Y/n]". If yes, use Edit tool and re-run review to verify.

## Rules

- Always review against `PROJECT.md` patterns
- Always check security (items 5–8 of checklist)
- Never auto-merge without user confirmation
- For partner branches: inspect `git diff`, not just final state
- Update sprint.json atomically (one write)

## Input / Output

- **Input:** `$ARGUMENTS` — branch, file, or directory
- **Output:** JSON report + updated `sprint.json` (if applicable) + optional auto-fix diff
