# Scale: Normal

> For standard projects with some complexity

## When to Use

- 1-4 weeks of work
- Multiple features
- Needs maintainability
- Will be revisited later

## PROJECT.md Additions

Add these sections to your PROJECT.md:

```markdown
---

## Architecture

### Key Decisions
- [Decision]: [Rationale]
- [Decision]: [Rationale]

### Data Flow
```
[input] → [process] → [output]
```

---

## Sprint: [Current]

**Goal:** [What to achieve]
**Deadline:** [Date]

### Tasks
- [ ] [Task] — [estimate]
- [ ] [Task] — [estimate]

### Blockers
- [Any blockers]

---

## Changelog

### [Date]
- Added: [feature]
- Fixed: [bug]
- Changed: [modification]
```

## DevOps

Add from `devops/`:
- `pre-commit.yaml` — Quality gates
- Basic CI (optional)

## Skills

Load as needed:
- `ui.skill` — Frontend
- `database.skill` — DB work
- `testing.skill` — Tests
- `api.skill` — APIs

## Workflow

```
Plan → Branch → Code → Test → PR → Merge → Deploy
```

Use feature branches, review before merge.
