---
description: "Create PR for: $ARGUMENTS"
---

Create PR for: $ARGUMENTS

## Instructions

1. Analyze current branch changes: `git diff main...HEAD`
2. Review all commits on branch: `git log main..HEAD --oneline`
3. Generate comprehensive PR description
4. Create PR using gh CLI

## Pre-checks

Before creating PR:
- [ ] All tests pass
- [ ] No linting errors
- [ ] Types check successfully
- [ ] Changes are committed

## Output Format

### PR Analysis

**Branch:** [current branch name]
**Target:** main
**Commits:** [number of commits]

---

### Changes Summary

#### Files Modified
- `path/to/file.ts` — [what changed]
- `path/to/other.ts` — [what changed]

#### Type of Change
- [ ] Bug fix (non-breaking)
- [ ] New feature (non-breaking)
- [ ] Breaking change
- [ ] Documentation
- [ ] Refactoring

---

### Generated PR

**Title:**
`<type>(<scope>): <description>`

**Body:**

```markdown
## Summary
- [Key change 1]
- [Key change 2]
- [Key change 3]

## Changes
- [Detailed change description]

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing performed
- [ ] Edge cases considered

## Breaking Changes
[None / List any breaking changes]

## Screenshots
[If UI changes, add screenshots]
```

---

### Command to Execute

```bash
gh pr create \
  --title "<type>(<scope>): <description>" \
  --body "..." \
  --base main
```

---

**Confirm PR creation?** [Y/n]

After confirmation, execute the gh command and return PR URL.
