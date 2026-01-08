---
name: git
description: "Git patterns: conventional commits, branch naming, pre-commit hooks"
---

# Git Patterns

> Project-specific version control conventions.

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

## Branch Naming

```
feat/description    # New feature
fix/description     # Bug fix
refactor/description # Refactoring
docs/description    # Documentation
```

### Workflow
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

---

## Pre-commit Hooks

```bash
# .husky/pre-commit
#!/bin/sh
pnpm lint-staged
```

```json
// package.json
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
