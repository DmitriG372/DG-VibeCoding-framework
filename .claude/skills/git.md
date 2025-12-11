---
name: git
description: "Git patterns: branching strategies, conventional commits, rebase workflow, conflict resolution"
---

# Git Patterns

> Version control best practices and workflows.

---

## Initial Setup

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
```

### Useful Aliases
```bash
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --decorate -20"
git config --global alias.last "log -1 HEAD --stat"
```

---

## Conventional Commits

### Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change (no feature/fix) |
| `docs` | Documentation only |
| `style` | Formatting (no code change) |
| `test` | Adding/fixing tests |
| `chore` | Build, CI, dependencies |
| `perf` | Performance improvement |

### Examples
```bash
git commit -m "feat(auth): add login with Google"
git commit -m "fix(api): handle null response from server"
git commit -m "refactor(utils): extract date formatting"
git commit -m "docs: update README installation steps"
```

---

## Branching Strategy

### Feature Branch Workflow
```bash
# Create feature branch
git checkout -b feat/user-auth

# Work on feature
git add .
git commit -m "feat(auth): implement login form"

# Update from main
git fetch origin
git rebase origin/main

# Push and create PR
git push -u origin feat/user-auth
```

### Branch Naming
```
feat/description    # New feature
fix/description     # Bug fix
refactor/description # Refactoring
docs/description    # Documentation
```

---

## Common Operations

### Undo Changes
```bash
# Undo uncommitted changes
git checkout -- file.txt
git restore file.txt

# Undo staged changes
git reset HEAD file.txt
git restore --staged file.txt

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

### Stashing
```bash
# Save work in progress
git stash

# With message
git stash push -m "WIP: user form"

# List stashes
git stash list

# Apply and remove
git stash pop

# Apply without removing
git stash apply stash@{0}
```

### Interactive Rebase
```bash
# Rebase last 3 commits
git rebase -i HEAD~3

# Commands:
# pick   - use commit
# reword - change message
# squash - combine with previous
# drop   - remove commit
```

---

## Conflict Resolution

```bash
# During merge/rebase
git status  # See conflicted files

# Edit files, resolve conflicts
# Look for:
# <<<<<<< HEAD
# your changes
# =======
# their changes
# >>>>>>> branch

# After resolving
git add resolved-file.txt
git rebase --continue  # or git merge --continue

# Abort if needed
git rebase --abort
git merge --abort
```

---

## Useful Commands

```bash
# View history
git log --oneline -20
git log --graph --decorate

# Search commits
git log --grep="fix"
git log -S "function_name"

# Show changes
git diff                    # Unstaged
git diff --staged           # Staged
git diff main...feature     # Branch diff

# Blame
git blame file.txt

# Find when bug introduced
git bisect start
git bisect bad              # Current is bad
git bisect good v1.0        # Known good
# Git will binary search
```

---

## Git Hooks (pre-commit)

```bash
# .husky/pre-commit
#!/bin/sh
pnpm lint-staged

# package.json
{
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md}": ["prettier --write"]
  }
}
```

---

## Best Practices

### DO
- Write meaningful commit messages
- Keep commits atomic (one change per commit)
- Rebase before merging to keep history clean
- Use feature branches
- Pull with rebase

### DON'T
- Force push to shared branches
- Commit secrets or credentials
- Make huge commits with unrelated changes
- Rebase public/shared branches
