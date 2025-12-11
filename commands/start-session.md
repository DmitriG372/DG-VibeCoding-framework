Start new session for: $ARGUMENTS

## Instructions

### Step 0: Git Sync Check (MANDATORY)

1. **Check if sprint/sprint.json exists**
   - If yes: Run `/sync --verify` to ensure all files match git history
   - Compare sprint.json features with actual git commits
   - Report any discrepancies found

2. **If mismatch detected:**
   - Show discrepancy: "Feature F003 marked done but no git commit found"
   - Ask user: "Run /sprint-reconstruct to fix? (y/n)"
   - If yes: rebuild sprint.json from git history

3. **Report sync status:**

   ```text
   ✓ Git history verified
   ✓ Framework files synced
   Sprint: <name> | Progress: [████████░░] 80%
   Last commit: feat(scope): F008 description (abc1234)
   ```

### Main Steps

1. Read PROJECT.md for full project context
2. Read SESSION_LOG.md for last session summary
3. Skills auto-activate based on task context (`.claude/skills/`)
4. Show last session summary to user
5. Ask what to focus on today (or continue from last session)

## Output Format

### Project Context

**Name:** [from PROJECT.md]
**Status:** [from PROJECT.md]
**Stack:** [from PROJECT.md]

---

### Last Session Summary

**Date:** [from SESSION_LOG.md]
**Focus:** [topic]

#### Completed

- [tasks from last session]

#### Left In Progress

- [incomplete tasks]

#### Key Decisions Made

- [decisions that affect today's work]

#### Blockers/Notes

- [anything to be aware of]

---

### Pending Tasks

[From PROJECT.md#current-sprint, unchecked items]

---

### Today's Focus

**Suggested:** [Continue from last session OR new priority]

What would you like to work on?

1. [Option based on pending tasks]
2. [Option based on last session]
3. Something else?

---

## Skills

Skills in `.claude/skills/` auto-activate based on task context.

---

*Part of DG-SuperVibe-Framework v2.3*
