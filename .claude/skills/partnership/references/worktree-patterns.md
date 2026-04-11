# Git Worktree Patterns — Reference

> Level 3 reference loaded on demand from `skills/partnership/SKILL.md`.

## When to use worktrees

Use worktrees when:
- Both agents actively editing the same project AND
- Their tasks touch different files AND
- You want to avoid branch-switch overhead

Skip worktrees when:
- Only one agent is active
- Tasks are fully sequential (handoff with pause)
- Project is very small (<200 files)

Worktree usage is **optional** — determined by `branch_strategy` field in `sprint/sprint.json`.

## Directory Layout

```
project/                           ← CC works here (main worktree)
../project-wt-cx-<branch>/         ← CX works here (separate worktree)
```

Both worktrees share the same `.git` but have independent working trees and checked-out branches.

## Setup

```bash
# From project root
scripts/worktree-setup.sh cx/FXXX-<slug>
```

Under the hood:
```bash
git worktree add ../project-wt-cx-FXXX-slug -b cx/FXXX-<slug>
```

## Cleanup (after merge)

```bash
scripts/worktree-cleanup.sh cx/FXXX-<slug>
```

Under the hood:
```bash
git worktree remove ../project-wt-cx-FXXX-slug
git branch -d cx/FXXX-<slug>  # only if merged
```

## Inspection

```bash
git worktree list           # all worktrees
git worktree prune          # remove stale refs
```

## Best Practices

- Name worktrees predictably: `project-wt-<agent>-<branch>`
- Never commit changes in stale worktrees (check with `git status` first)
- Clean up immediately after merge — stale worktrees confuse next session
- If worktree directory is deleted manually, run `git worktree prune` before re-creating

## Anti-Patterns

- Two agents editing the same file across worktrees → last commit wins silently
- Leaving worktrees around for weeks → disk bloat, confusion
- Creating worktrees outside project parent → breaks `scripts/worktree-*` conventions
