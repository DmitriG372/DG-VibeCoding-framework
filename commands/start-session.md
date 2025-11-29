Start new session for: $ARGUMENTS

## Instructions

1. Read PROJECT.md for full project context
2. Read SESSION_LOG.md for last session summary
3. Load `framework-philosophy.skill` (always)
4. Auto-detect and load relevant skills based on $ARGUMENTS keywords
5. Show last session summary to user
6. Ask what to focus on today (or continue from last session)

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

## Skills Loaded
- framework-philosophy.skill (always)
- [auto-detected skills based on focus]
